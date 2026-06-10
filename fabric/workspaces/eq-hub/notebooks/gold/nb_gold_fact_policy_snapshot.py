#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_policy_snapshot
# 
# New notebook

# In[21]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[22]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2026-04-23"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2026-04-23T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"


# In[23]:


# Notebook: nb_gold_fact_policy_snapshot
# Layer:    Gold
# Purpose:  Full-refresh load of gold.fact_policy_snapshot from
#           lh_silver.dbo.agent_base_current (SCD2 _current view).
#
#           agency_name is NOT available in agent_base; the column is written
#           as NULL until the source join path is confirmed (see open item #3 in
#           docs/gold_mapping_agent_training_star_schema.md).
#
# Write pattern: full OVERWRITE on every run.  Because the source is the
#                _current view (active records only), reloading the full table
#                is the safest way to keep the gold dim in sync.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_policy_snapshot").getOrCreate()

_notebook_start = time.time()

# F.col("agent_number"),
#         F.col("display_name"),
#         F.col("agent_type"),
#         F.col("national_producer_number"),
#         F.col("nasd_finra_number")


_target_table = "lh_gold.gold.fact_policy_snapshot"
_business_key_cols = ['snapshot_date_key','issue_date_key','policy_key','owner_key','annuitant_key','product_key','writing_agent_key','imo_agent_key','nmo_agent_key','servicing_agent_key','company_key']   # list
_is_scd2           = False
_surrogate_key_col = "policy_snapshot_key"
_hash_col          = "md5_hash"


print("=" * 65)
print("  nb_gold_fact_policy_snapshot — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[24]:


policy_snapshot_df = spark.sql(f'''WITH

-- ── 1. Flatten both hierarchy tables ─────────────────────────────────────
hierarchy_flat AS (
    SELECT
        brg.hierarchy_group_key,
        brg.split_percent,
        brg.servicing_agent_indicator,
        brg.commission_only_indicator,
        brg.hierarchy_order,
        sh.hierarchy_set_key,
        sh.reverse_level,
        ac.agent_contract_id,
        ac.agent_number,
        ac.commission_level,
        clr.rank AS comm_rank
    FROM silver_s2.hierarchy_super_hierarchy_base_current sh
    INNER JOIN silver_s2.agent_contract_base                ac  ON ac.agent_contract_id = sh.agent_contract_id
    INNER JOIN silver_s2.commission_level_rank_base_current clr ON clr.commission_level = ac.commission_level
    INNER JOIN silver_s2.hierarchy_bridge_base_current      brg ON brg.hierarchy_set_key = sh.hierarchy_set_key
    WHERE ac.status            = 'Active'
      AND ac.is_current_record = 'Y'

    UNION ALL

    SELECT
        brg.hierarchy_group_key,
        brg.split_percent,
        brg.servicing_agent_indicator,
        brg.commission_only_indicator,
        brg.hierarchy_order,
        h.hierarchy_set_key,
        h.reverse_level,
        ac.agent_contract_id,
        ac.agent_number,
        ac.commission_level,
        clr.rank AS comm_rank
    FROM silver_s2.hierarchy_base_current               h
    INNER JOIN silver_s2.agent_contract_base                ac  ON ac.agent_contract_id = h.agent_contract_id
    INNER JOIN silver_s2.commission_level_rank_base_current clr ON clr.commission_level = ac.commission_level
    INNER JOIN silver_s2.hierarchy_bridge_base_current      brg ON brg.hierarchy_set_key = h.hierarchy_set_key
    WHERE ac.status            = 'Active'
      AND ac.is_current_record = 'Y'
),

-- ── 2. Tag every row with the min reverse_level of its chain ──────────────
hierarchy_ranked AS (
    SELECT
        *,
        MIN(reverse_level) OVER (PARTITION BY hierarchy_set_key) AS chain_min_rl
    FROM hierarchy_flat
) ,

-- ── 3. Writing agents ─────────────────────────────────────────────────────
writing_agents AS (
    SELECT
        hierarchy_group_key,
        hierarchy_order,
        hierarchy_set_key,
        agent_contract_id AS writing_agent_contract_id,
        agent_number      AS writing_agent_number,
        commission_level  AS wa_commission_level,
        split_percent
    FROM hierarchy_ranked
    WHERE reverse_level             = chain_min_rl
      AND servicing_agent_indicator = 'N'
) , -- select * from writing_agents where hierarchy_group_key=266612

-- ── 4. IMO within each chain ──────────────────────────────────────────────
imo_in_chain AS (
    SELECT
        hierarchy_set_key,
        agent_contract_id AS imo_agent_contract_id,
        agent_number      AS imo_agent_number
    FROM (
        SELECT
            hierarchy_set_key,
            agent_contract_id,
            agent_number,
            ROW_NUMBER() OVER (
                PARTITION BY hierarchy_set_key
                ORDER BY reverse_level DESC
            ) AS rn
        FROM hierarchy_flat
        WHERE commission_level          = 'IMO'
          AND servicing_agent_indicator = 'N'
    ) t
    WHERE rn = 1
),

-- ── 5. NMO within each chain ──────────────────────────────────────────────
nmo_in_chain AS (
    SELECT
        hierarchy_set_key,
        agent_contract_id AS nmo_agent_contract_id,
        agent_number      AS nmo_agent_number
    FROM (
        SELECT
            hierarchy_set_key,
            agent_contract_id,
            agent_number,
            ROW_NUMBER() OVER (
                PARTITION BY hierarchy_set_key
                ORDER BY reverse_level DESC
            ) AS rn
        FROM hierarchy_flat
        WHERE commission_level          = 'NMO'
          AND servicing_agent_indicator = 'N'
    ) t
    WHERE rn = 1
),

-- ── 6. Servicing agent ────────────────────────────────────────────────────
servicing_agents AS (
    SELECT
        hierarchy_group_key,
        agent_contract_id AS servicing_agent_contract_id,
        agent_number      AS servicing_agent_number
    FROM (
        SELECT
            hierarchy_group_key,
            agent_contract_id,
            agent_number,
            ROW_NUMBER() OVER (
                PARTITION BY hierarchy_group_key
                ORDER BY reverse_level ASC
            ) AS rn
        FROM hierarchy_flat
        WHERE servicing_agent_indicator = 'Y'
    ) t
    WHERE rn = 1
),

-- ── 7. Base contracts ─────────────────────────────────────────────────────
contract_base AS (
    SELECT
        contract_id,
        contract_number,
        hierarchy_group_key,
        contract_value_group_key,
        reinsurance_group_key,
        product_id,
        owner_client_id,
        annuitant_insured_client_id,
        funding_company_id,
        issue_timestamp,
        cost_basis,
        recovered_cost_basis,
        coverage_ratio,
        surrender_id
    FROM silver_s2.contract_base_current
    where start_timestamp <= '{p_ingestion_date}'
),

-- New Premium amount based on initial premium

activity_kpis AS (
    select a.contract_id, 
    SUM(CASE WHEN at.activity_type_name='CommissionHeld' THEN a.gross_amount ELSE 0 END ) AS gross_commission_held,
    SUM(CASE WHEN at.activity_type_name='CommissionHeld' THEN a.net_amount ELSE 0 END ) AS net_commission_held,
    SUM(CASE WHEN at.activity_type_name='Print' THEN a.gross_amount ELSE 0 END ) AS gross_print,
    SUM(CASE WHEN at.activity_type_name='Print' THEN a.net_amount ELSE 0 END ) AS net_print,
    SUM(CASE WHEN at.activity_type_name='Suitability' THEN a.gross_amount ELSE 0 END ) AS gross_suitability,
    SUM(CASE WHEN at.activity_type_name='Suitability' THEN a.net_amount ELSE 0 END ) AS net_suitability,
    SUM(CASE WHEN at.activity_type_name='ClaimPayment' THEN a.gross_amount ELSE 0 END ) AS gross_claim_payment,
    SUM(CASE WHEN at.activity_type_name='ClaimPayment' THEN a.net_amount ELSE 0 END ) AS net_claim_payment,
    SUM(CASE WHEN at.activity_type_name='CommissionPaid' THEN a.gross_amount ELSE 0 END ) AS gross_commission_paid,
    SUM(CASE WHEN at.activity_type_name='CommissionPaid' THEN a.net_amount ELSE 0 END ) AS net_commission_paid,
    SUM(CASE WHEN at.activity_type_name='Lapse' THEN a.gross_amount ELSE 0 END ) AS gross_lapse,
    SUM(CASE WHEN at.activity_type_name='Lapse' THEN a.net_amount ELSE 0 END ) AS net_lapse,
    SUM(CASE WHEN at.activity_type_name='Annuitization' THEN a.gross_amount ELSE 0 END ) AS gross_annuitization,
    SUM(CASE WHEN at.activity_type_name='Annuitization' THEN a.net_amount ELSE 0 END ) AS net_annuitization,
    SUM(CASE WHEN at.activity_type_name='Loan' THEN a.gross_amount ELSE 0 END ) AS gross_loan,
    SUM(CASE WHEN at.activity_type_name='Loan' THEN a.net_amount ELSE 0 END ) AS net_loan,
    SUM(CASE WHEN at.activity_type_name='Payout' THEN a.gross_amount ELSE 0 END ) AS gross_payout,
    SUM(CASE WHEN at.activity_type_name='Payout' THEN a.net_amount ELSE 0 END ) AS net_payout,
    SUM(CASE WHEN at.activity_type_name='TaxConversion' THEN a.gross_amount ELSE 0 END ) AS gross_tax_conversion,
    SUM(CASE WHEN at.activity_type_name='TaxConversion' THEN a.net_amount ELSE 0 END ) AS net_tax_conversion,
    SUM(CASE WHEN at.activity_type_name='Withdrawal' THEN a.gross_amount ELSE 0 END ) AS gross_withdrawal,
    SUM(CASE WHEN at.activity_type_name='Withdrawal' THEN a.net_amount ELSE 0 END ) AS net_withdrawal,
    SUM(CASE WHEN at.activity_type_name='InternalReplacement' THEN a.gross_amount ELSE 0 END ) AS gross_internal_replacement,
    SUM(CASE WHEN at.activity_type_name='InternalReplacement' THEN a.net_amount ELSE 0 END ) AS  net_internal_replacement,
    SUM(CASE WHEN at.activity_type_name='Premium' THEN a.gross_amount ELSE 0 END ) AS  gross_premium,
    SUM(CASE WHEN at.activity_type_name='Premium' THEN a.net_amount ELSE 0 END ) AS  net_premium,
    SUM(CASE WHEN at.activity_type_name='CAPRepayment' THEN a.gross_amount ELSE 0 END ) AS  gross_cap_repayment,
    SUM(CASE WHEN at.activity_type_name='CAPRepayment' THEN a.net_amount ELSE 0 END ) AS  net_cap_repayment,
    SUM(CASE WHEN at.activity_type_name='PremiumRefund' THEN a.gross_amount ELSE 0 END ) AS  gross_premium_refund,
    SUM(CASE WHEN at.activity_type_name='PremiumRefund' THEN a.net_amount ELSE 0 END ) AS  net_premium_refund,
    SUM(CASE WHEN at.activity_type_name='Commission' THEN a.gross_amount ELSE 0 END ) AS  gross_commission,
    SUM(CASE WHEN at.activity_type_name='Commission' THEN a.net_amount ELSE 0 END ) AS  net_commission,
    SUM(CASE WHEN at.activity_type_name='Death' THEN a.gross_amount ELSE 0 END ) AS  gross_death,
    SUM(CASE WHEN at.activity_type_name='Death' THEN a.net_amount ELSE 0 END ) AS  net_death,
    SUM(CASE WHEN at.activity_type_name='FullSurrender' THEN a.gross_amount ELSE 0 END ) AS  gross_full_surrender,
    SUM(CASE WHEN at.activity_type_name='FullSurrender' THEN a.net_amount ELSE 0 END ) AS  net_full_surrender
    from silver_s2.activity_base a
    left join silver_s2.activity_type_base_current at
    on a.activity_type_id = at.activity_type_id
    where a.effective_date_id <= cast(date_format('{p_ingestion_date}', 'yyyyMMdd') as int)
    GROUP BY
    a.contract_id

),
-- ── 8. Contract value EAV → pivot ────────────────────────────────────────
contract_values AS (
    SELECT
    contract_value_group_key,
    COALESCE(annual_ratchet_amount,                    0) AS annual_ratchet_amount,
    COALESCE(anticipated_premium,                      0) AS anticipated_premium,
    COALESCE(cash_surrender_value,                     0) AS cash_surrender_value,
    COALESCE(certain_end_date,                         0) AS certain_end_date,
    COALESCE(death_benefit,                            0) AS death_benefit,
    COALESCE(enhanced_accumulation_value,              0) AS enhanced_accumulation_value,
    COALESCE(face_amount,                              0) AS face_amount,
    COALESCE(free_amount_remaining,                    0) AS free_amount_remaining,
    COALESCE(frequency,                                0) AS frequency,
    COALESCE(guaranteed_enhanced_accumulation_value,   0) AS guaranteed_enhanced_accumulation_value,
    COALESCE(ibr_benefit_base,                         0) AS ibr_benefit_base,
    COALESCE(loan_balance,                             0) AS loan_balance,
    COALESCE(ltc_benefit_amount,                       0) AS ltc_benefit_amount,
    COALESCE(ltc_benefit_base,                         0) AS ltc_benefit_base,
    COALESCE(mva_charge,                               0) AS mva_charge,
    COALESCE(next_payment_date,                        0) AS next_payment_date,
    COALESCE(payment_amount,                           0) AS payment_amount,
    COALESCE(premium_received,                         0) AS premium_received,
    COALESCE(surrender_charge,                         0) AS surrender_charge,
    COALESCE(vested_benefit_base,                      0) AS vested_benefit_base,
    COALESCE(vested_eav,                               0) AS vested_eav,
    COALESCE(vested_geav,                              0) AS vested_geav,
    COALESCE(vested_total_ltc_benefits,                0) AS vested_total_ltc_benefits,
    COALESCE(vested_wellness_credit,                   0) AS vested_wellness_credit,
    COALESCE(wellness_credit,                          0) AS wellness_credit,
    COALESCE(withdrawals_since_inception,              0) AS withdrawals_since_inception
    FROM (
        SELECT
            contract_value_group_key,
            value_type,
            value
        FROM lh_silver.silver_s2.contract_value_group_base
        WHERE value_type <> 'Year End Value'
        and start_timestamp <= '{p_ingestion_date}'
        OR value_type IS NULL
    ) AS source
    PIVOT (
        MIN(value)
        FOR value_type IN (
            'Annual Ratchet Amount'                  AS annual_ratchet_amount,
            'Anticipated Premium'                    AS anticipated_premium,
            'Cash Surrender Value'                   AS cash_surrender_value,
            'Certain End Date'                       AS certain_end_date,
            'Death Benefit'                          AS death_benefit,
            'Enhanced Accumulation Value'            AS enhanced_accumulation_value,
            'Face Amount'                            AS face_amount,
            'Free Amount Remaining'                  AS free_amount_remaining,
            'Frequency'                              AS frequency,
            'Guaranteed Enhanced Accumulation Value' AS guaranteed_enhanced_accumulation_value,
            'IBR Benefit Base'                       AS ibr_benefit_base,
            'Loan Balance'                           AS loan_balance,
            'LTC Benefit Amount'                     AS ltc_benefit_amount,
            'LTC Benefit Base'                       AS ltc_benefit_base,
            'MVA Charge'                             AS mva_charge,
            'Next Payment Date'                      AS next_payment_date,
            'Payment Amount'                         AS payment_amount,
            'Premium Received'                       AS premium_received,
            'Surrender Charge'                       AS surrender_charge,
            'Vested Benefit Base'                    AS vested_benefit_base,
            'Vested EAV'                             AS vested_eav,
            'Vested GEAV'                            AS vested_geav,
            'Vested Total LTC Benefits'              AS vested_total_ltc_benefits,
            'Vested Wellness Credit'                 AS vested_wellness_credit,
            'Wellness Credit'                        AS wellness_credit,
            'Withdrawals Since Inception'            AS withdrawals_since_inception
        )
    ) 
),

--- surrender details

surrender_details AS (
    select surrender_id,
    COALESCE(customer_age,0) AS surrender_customer_age,
    COALESCE(policy_year,0) AS surrender_policy_year,
    COALESCE(penalty_duration_years,0) AS surrender_penalty_duration_years,
    COALESCE(penalty_percentage,0) AS surrender_penalty_percentage,
    COALESCE(rate_calculation_basis,0) AS surrender_rate_calculation_basis
    from (
    select s.surrender_id,
    s.customer_age,
    s.policy_year,
    s.penalty_duration_years,
    s.penalty_percentage,
    s.rate_calculation_basis,
    row_number() over(partition by s.surrender_id order by s.ingestion_date desc) as rnk
    from silver_s2.surrender_base s
    where s.ingestion_date <= '{p_ingestion_date}'
    )
    where rnk=1
)

-- ── 11. Final assembly ────────────────────────────────────────────────────
-- Grain: one row per contract × hierarchy_order × snapshot_date
-- Contracts with splits produce multiple rows (one per hierarchy_order)
-- INSERT INTO gold.fact_policy_snapshot
SELECT

    -- -- ── Date keys ─────────────────────────────────────────────────────────
    dd_snap.date_key                                        AS snapshot_date_key,
        -- ── Other dimension foreign keys ──────────────────────────────────────
    dp.policy_key,
    COALESCE(dd_issue.date_key,-1)                                       AS issue_date_key,
    COALESCE(oc.client_key ,-1)                                          AS owner_key,
    COALESCE(ac_dim.client_key,-1)                                       AS annuitant_key,
    COALESCE(dprod.product_key,-1) as product_key,

    -- ── Agent dimension foreign keys ──────────────────────────────────────
    COALESCE(dwa.agent_key,-1) as writing_agent_key,
    COALESCE(dimo.agent_key,-1) as imo_agent_key,
    COALESCE(dnmo.agent_key,-1) as nmo_agent_key,
    COALESCE(dsvc.agent_key,-1) as servicing_agent_key,

    COALESCE(dco.company_key,-1) as company_key,
    
    -- ── Split ─────────────────────────────────────────────────────────────
    -- Taken from bridge; sums to 1.0 across all hierarchy_orders per contract
    CAST(wa.split_percent AS DECIMAL(5,4))                  AS split_percent,
    COALESCE(cb.cost_basis,                       0)        AS cost_basis,
    COALESCE(cb.recovered_cost_basis,0)        AS recovered_cost_basis,
    CAST(cb.coverage_ratio AS DECIMAL(5,4)) AS coverage_ratio,

    --- Activity measures

    COALESCE(ak.gross_premium, 0) AS gross_premium,
    COALESCE(ak.net_premium, 0) AS net_premium,
    COALESCE(ak.gross_commission_held, 0) AS gross_commission_held,
    COALESCE(ak.net_commission_held, 0) AS net_commission_held,
    COALESCE(ak.gross_print, 0) AS gross_print,
    COALESCE(ak.net_print, 0) AS net_print,
    COALESCE(ak.gross_suitability, 0) AS gross_suitability,
    COALESCE(ak.net_suitability, 0) AS net_suitability,
    COALESCE(ak.gross_claim_payment, 0) AS gross_claim_payment,
    COALESCE(ak.net_claim_payment, 0) AS net_claim_payment,
    COALESCE(ak.gross_commission_paid, 0) AS gross_commission_paid,
    COALESCE(ak.net_commission_paid, 0) AS net_commission_paid,
    COALESCE(ak.gross_lapse, 0) AS gross_lapse,
    COALESCE(ak.net_lapse, 0) AS net_lapse,
    COALESCE(ak.gross_annuitization, 0) AS gross_annuitization,
    COALESCE(ak.net_annuitization, 0) AS net_annuitization,
    COALESCE(ak.gross_loan, 0) AS gross_loan,
    COALESCE(ak.net_loan, 0) AS net_loan,
    COALESCE(ak.gross_payout, 0) AS gross_payout,
    COALESCE(ak.net_payout, 0) AS net_payout,
    COALESCE(ak.gross_tax_conversion, 0) AS gross_tax_conversion,
    COALESCE(ak.net_tax_conversion, 0) AS net_tax_conversion,
    COALESCE(ak.gross_withdrawal, 0) AS gross_withdrawal,
    COALESCE(ak.net_withdrawal, 0) AS net_withdrawal,
    COALESCE(ak.gross_internal_replacement, 0) AS gross_internal_replacement,
    COALESCE(ak.net_internal_replacement, 0) AS net_internal_replacement,
    COALESCE(ak.gross_cap_repayment, 0) AS gross_cap_repayment,
    COALESCE(ak.net_cap_repayment, 0) AS net_cap_repayment,
    COALESCE(ak.gross_premium_refund, 0) AS gross_premium_refund,
    COALESCE(ak.net_premium_refund, 0) AS net_premium_refund,
    COALESCE(ak.gross_commission, 0) AS gross_commission,
    COALESCE(ak.net_commission, 0) AS net_commission,
    COALESCE(ak.gross_death, 0) AS gross_death,
    COALESCE(ak.net_death, 0) AS net_death,
    COALESCE(ak.gross_full_surrender, 0) AS gross_full_surrender,
    COALESCE(ak.net_full_surrender, 0) AS net_full_surrender,

    COALESCE(cv.annual_ratchet_amount,                    0) AS annual_ratchet_amount,
    COALESCE(cv.anticipated_premium,                      0) AS anticipated_premium,
    COALESCE(cv.cash_surrender_value,                     0) AS cash_surrender_value,
    COALESCE(cv.certain_end_date,                         0) AS certain_end_date,
    COALESCE(cv.death_benefit,                            0) AS death_benefit,
    COALESCE(cv.enhanced_accumulation_value,              0) AS enhanced_accumulation_value,
    COALESCE(cv.face_amount,                              0) AS face_amount,
    COALESCE(cv.free_amount_remaining,                    0) AS free_amount_remaining,
    COALESCE(cv.frequency,                                0) AS frequency,
    COALESCE(cv.guaranteed_enhanced_accumulation_value,   0) AS guaranteed_enhanced_accumulation_value,
    COALESCE(cv.ibr_benefit_base,                         0) AS ibr_benefit_base,
    COALESCE(cv.loan_balance,                             0) AS loan_balance,
    COALESCE(cv.ltc_benefit_amount,                       0) AS ltc_benefit_amount,
    COALESCE(cv.ltc_benefit_base,                         0) AS ltc_benefit_base,
    COALESCE(cv.mva_charge,                               0) AS mva_charge,
    COALESCE(cv.next_payment_date,                        0) AS next_payment_date,
    COALESCE(cv.payment_amount,                           0) AS payment_amount,
    COALESCE(cv.premium_received,                         0) AS premium_received,
    COALESCE(cv.surrender_charge,                         0) AS surrender_charge,
    COALESCE(cv.vested_benefit_base,                      0) AS vested_benefit_base,
    COALESCE(cv.vested_eav,                               0) AS vested_eav,
    COALESCE(cv.vested_geav,                              0) AS vested_geav,
    COALESCE(cv.vested_total_ltc_benefits,                0) AS vested_total_ltc_benefits,
    COALESCE(cv.vested_wellness_credit,                   0) AS vested_wellness_credit,
    COALESCE(cv.wellness_credit,                          0) AS wellness_credit,
    COALESCE(cv.withdrawals_since_inception,              0) AS withdrawals_since_inception,
    
    COALESCE(sd.surrender_customer_age,0) AS surrender_customer_age,
    COALESCE(sd.surrender_policy_year,0) AS surrender_policy_year,
    COALESCE(sd.surrender_penalty_duration_years,0) AS surrender_penalty_duration_years,
    CAST(COALESCE(sd.surrender_penalty_percentage,0) AS DECIMAL(5,4)) AS surrender_penalty_percentage,
    COALESCE(sd.surrender_rate_calculation_basis,0) AS surrender_rate_calculation_basis
    

FROM contract_base cb

-- ── Hierarchy joins ───────────────────────────────────────────────────────
-- writing_agents expands the grain: one row per hierarchy_order per contract
LEFT JOIN activity_kpis ak
    ON cb.contract_id = ak.contract_id
LEFT JOIN writing_agents wa
    ON  wa.hierarchy_group_key  = cb.hierarchy_group_key
LEFT JOIN imo_in_chain imo
    ON  imo.hierarchy_set_key   = wa.hierarchy_set_key
LEFT JOIN nmo_in_chain nmo
    ON  nmo.hierarchy_set_key   = wa.hierarchy_set_key
LEFT JOIN servicing_agents svc
    ON  svc.hierarchy_group_key = cb.hierarchy_group_key

LEFT JOIN contract_values cv
    ON  cv.contract_value_group_key = cb.contract_value_group_key
-- ── Gold dim surrogate key lookups ────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_policy dp
    ON  dp.policy_number          = cb.contract_number
    AND dp.is_current           = 1
LEFT JOIN lh_gold.gold.dim_product dprod
    ON  dprod.source_product_id        = cb.product_id
    AND dprod.is_current        = 1
LEFT JOIN lh_gold.gold.dim_agent dwa
    ON  dwa.agent_number   = wa.writing_agent_number
    AND dwa.is_current          = 1
LEFT JOIN lh_gold.gold.dim_agent dimo
    ON  dimo.agent_number  = imo.imo_agent_number
    AND dimo.is_current         = 1
LEFT JOIN lh_gold.gold.dim_agent dnmo
    ON  dnmo.agent_number  = nmo.nmo_agent_number
    AND dnmo.is_current         = 1
LEFT JOIN lh_gold.gold.dim_agent dsvc
    ON  dsvc.agent_number  = svc.servicing_agent_number
    AND dsvc.is_current         = 1
LEFT JOIN lh_gold.gold.dim_client oc
    ON  oc.source_client_id            = cb.owner_client_id
    AND oc.is_current           = 1
LEFT JOIN lh_gold.gold.dim_client ac_dim
    ON  ac_dim.source_client_id        = cb.annuitant_insured_client_id
    AND ac_dim.is_current       = 1
LEFT JOIN lh_gold.gold.dim_company dco
    ON  dco.source_company_id          = cb.funding_company_id
    AND dco.is_current          = 1

-- ── Date dim lookups ──────────────────────────────────────────────────────
INNER JOIN lh_gold.gold.dim_date dd_snap
    ON  dd_snap.calendar_date       = '{p_ingestion_date}'
LEFT JOIN lh_gold.gold.dim_date dd_issue
    ON  dd_issue.calendar_date      = TO_DATE(cb.issue_timestamp)
LEFT JOIN surrender_details sd
    ON cb.surrender_id=sd.surrender_id

WHERE dp.policy_key IS NOT NULL''')


# In[25]:


display(policy_snapshot_df.limit(2))


# In[26]:


policy_snapshot_df = (
    policy_snapshot_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    # Input: all agent business columns (excludes audit + SCD2 metadata cols)
    .withColumn(_surrogate_key_col, make_surrogate_key(*[F.col(c) for c in _business_key_cols]))   
    .select(
        _surrogate_key_col,
        "snapshot_date_key",
        "issue_date_key",
        "policy_key",
        "owner_key",
        "annuitant_key",
        "product_key",
        "writing_agent_key",
        "imo_agent_key",
        "nmo_agent_key",
        "servicing_agent_key",
        "company_key",
        "split_percent",
        "cost_basis",
        "recovered_cost_basis",
        "coverage_ratio",
        "gross_premium",
        "net_premium",
        "gross_commission_held",
        "net_commission_held",
        "gross_print",
        "net_print",
        "gross_suitability",
        "net_suitability",
        "gross_claim_payment",
        "net_claim_payment",
        "gross_commission_paid",
        "net_commission_paid",
        "gross_lapse",
        "net_lapse",
        "gross_annuitization",
        "net_annuitization",
        "gross_loan",
        "net_loan",
        "gross_payout",
        "net_payout",
        "gross_tax_conversion",
        "net_tax_conversion",
        "gross_withdrawal",
        "net_withdrawal",
        "gross_internal_replacement",
        "net_internal_replacement",
        "gross_cap_repayment",
        "net_cap_repayment",
        "gross_premium_refund",
        "net_premium_refund",
        "gross_commission",
        "net_commission",
        "gross_death",
        "net_death",
        "gross_full_surrender",
        "net_full_surrender",
        "annual_ratchet_amount",
        "anticipated_premium",
        "cash_surrender_value",
        "certain_end_date",
        "death_benefit",
        "enhanced_accumulation_value",
        "face_amount",
        "free_amount_remaining",
        "frequency",
        "guaranteed_enhanced_accumulation_value",
        "ibr_benefit_base",
        "loan_balance",
        "ltc_benefit_amount",
        "ltc_benefit_base",
        "mva_charge",
        "next_payment_date",
        "payment_amount",
        "premium_received",
        "surrender_charge",
        "vested_benefit_base",
        "vested_eav",
        "vested_geav",
        "vested_total_ltc_benefits",
        "vested_wellness_credit",
        "wellness_credit",
        "withdrawals_since_inception",
        "surrender_customer_age",
        "surrender_policy_year",
        "surrender_penalty_duration_years",
        "surrender_penalty_percentage",
        "surrender_rate_calculation_basis"
    )
)


# In[27]:


display(policy_snapshot_df.limit(2))

#  ['agent_number','agent_name','agent_type','national_producer_number','nasd_finra_number','status'] 


# In[28]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = policy_snapshot_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    partition_cols = ['snapshot_date_key']
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

