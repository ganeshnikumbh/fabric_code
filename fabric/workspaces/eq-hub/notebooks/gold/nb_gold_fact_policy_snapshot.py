#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_policy_snapshot
# 
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_silver_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_silver_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date = "2026-08-19"
p_ingestion_timestamp = "2026-08-19T00:00:00Z"
p_src_busn_asst = "elic"
p_ingestion_run_id = "8c020222-a8e4-42db-a11c-b344be4ea73c"


# In[ ]:


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

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()

# F.col("agent_number"),
#         F.col("display_name"),
#         F.col("agent_type"),
#         F.col("national_producer_number"),
#         F.col("nasd_finra_number")


_target_table = "lh_gold.gold.fact_policy_snapshot"
_business_key_cols = ['snapshot_date_key','issue_date_key','policy_key','owner_key','annuitant_key','product_key','agent_key','company_key','is_writing_agent','is_servicing_agent','hierarchy_order','agent_contract_key','reverse_level','split_percent','commission_level_rank_key']   # list
_is_scd2           = False
_surrogate_key_col = "policy_snapshot_key"
_hash_col          = "md5_hash"
p_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print(p_snapshot_date_key)

print("=" * 65)
print("  nb_gold_fact_policy_snapshot — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


policy_snapshot_df = spark.sql(f'''WITH

-- ── 1. Flatten both hierarchy tables ─────────────────────────────────────
hierarchy_flat AS (

    SELECT DISTINCT hierarchy_group_key,split_percent,servicing_agent_indicator,commission_only_indicator,
    hierarchy_order,hierarchy_set_key,reverse_level,agent_contract_key,agent_number,commission_level_rank_key
    from
    (
        SELECT
            brg.hierarchy_group_key,
            brg.split_percent,
            brg.servicing_agent_indicator,
            brg.commission_only_indicator,
            brg.hierarchy_order,
            sh.hierarchy_set_key,
            sh.reverse_level,
            gac.agent_contract_key,
            ac.agent_number,
            COALESCE(gclr.commission_level_rank_key,-1) as commission_level_rank_key
        FROM silver_s2.hierarchy_current sh
        INNER JOIN silver_s2.agent_contract ac ON ac.agent_contract_id = sh.agent_contract_id
        INNER JOIN silver_s2.hierarchy_bridge_current brg ON brg.hierarchy_set_key = sh.hierarchy_set_key
        LEFT JOIN lh_gold.gold.dim_agent_contract gac ON ac.agent_contract_id = gac.source_agent_contract_id
        LEFT JOIN lh_gold.gold.dim_commission_level_rank gclr ON gclr.commission_level=ac.commission_level
        

        UNION ALL

        SELECT
            brg.hierarchy_group_key,
            brg.split_percent,
            brg.servicing_agent_indicator,
            brg.commission_only_indicator,
            brg.hierarchy_order,
            h.hierarchy_set_key,
            h.reverse_level,
            COALESCE(gac.agent_contract_key,-1) as agent_contract_key,
            ac.agent_number,
            COALESCE(gclr.commission_level_rank_key,-1) as commission_level_rank_key
        FROM silver_s2.hierarchy_current h
        INNER JOIN silver_s2.agent_contract ac ON ac.agent_contract_id = h.agent_contract_id
        INNER JOIN silver_s2.hierarchy_bridge_current brg ON brg.hierarchy_set_key = h.hierarchy_set_key
        LEFT JOIN lh_gold.gold.dim_agent_contract gac ON ac.agent_contract_id = gac.source_agent_contract_id 
        LEFT JOIN lh_gold.gold.dim_commission_level_rank gclr ON gclr.commission_level=ac.commission_level
    --where hierarchy_group_key=406163
    ) as tab
),

-- ── 7. Base contracts ─────────────────────────────────────────────────────
contract AS (
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
    FROM silver_s2.contract_current
    where is_current = 1
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
    SUM(CASE WHEN at.activity_type_name='CAP Repayment' THEN a.gross_amount ELSE 0 END ) AS  gross_cap_repayment,
    SUM(CASE WHEN at.activity_type_name='CAP Repayment' THEN a.net_amount ELSE 0 END ) AS  net_cap_repayment,
    SUM(CASE WHEN at.activity_type_name='Premium Refund' THEN a.gross_amount ELSE 0 END ) AS  gross_premium_refund,
    SUM(CASE WHEN at.activity_type_name='Premium Refund' THEN a.net_amount ELSE 0 END ) AS  net_premium_refund,
    SUM(CASE WHEN at.activity_type_name='Commission' THEN a.gross_amount ELSE 0 END ) AS  gross_commission,
    SUM(CASE WHEN at.activity_type_name='Commission' THEN a.net_amount ELSE 0 END ) AS  net_commission,
    SUM(CASE WHEN at.activity_type_name='Death' THEN a.gross_amount ELSE 0 END ) AS  gross_death,
    SUM(CASE WHEN at.activity_type_name='Death' THEN a.net_amount ELSE 0 END ) AS  net_death,
    SUM(CASE WHEN at.activity_type_name='FullSurrender' THEN a.gross_amount ELSE 0 END ) AS  gross_full_surrender,
    SUM(CASE WHEN at.activity_type_name='FullSurrender' THEN a.net_amount ELSE 0 END ) AS  net_full_surrender
    from silver_s2.activity a
    left join silver_s2.activity_type_current at
    on a.activity_type_id = at.activity_type_id
    where a.ingestion_date = '{p_ingestion_date}'
    GROUP BY
    a.contract_id

),
-- ── 8. Contract value EAV → pivot ────────────────────────────────────────
contract_values AS (
    SELECT
    contract_value_key,
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
            contract_value_key,
            value_type,
            value
        FROM silver_s2.contract_value_group
        WHERE ingestion_date = '{p_ingestion_date}'
        and (value_type <> 'Year End Value'
        OR value_type IS NULL)
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
    COALESCE(rate_calculation_basis,'Unknown') AS surrender_rate_calculation_basis
    from silver_s2.surrender s
    where ingestion_date = '{p_ingestion_date}'
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
    -1 as writing_agent_key,
    -1 as imo_agent_key,
    -1 as nmo_agent_key,
    -1 as servicing_agent_key,

    COALESCE(dco.company_key,-1) as company_key,
    
    -- ── Split ─────────────────────────────────────────────────────────────
    -- Taken from bridge; sums to 1.0 across all hierarchy_orders per contract
    CAST(hf.split_percent AS DECIMAL(5,4))                  AS split_percent,
    CAST(COALESCE(cb.cost_basis, 0) AS DECIMAL(13,2))        AS cost_basis,
    CAST(COALESCE(cb.recovered_cost_basis,0) AS DECIMAL(13,2))         AS recovered_cost_basis,
    CAST(cb.coverage_ratio AS DECIMAL(5,4)) AS coverage_ratio,

    --- Activity measures

    CAST(COALESCE(ak.gross_premium, 0) AS DECIMAL(28,4)) AS gross_premium,
    CAST(COALESCE(ak.net_premium, 0) AS DECIMAL(28,4)) AS net_premium,
    CAST(COALESCE(ak.gross_commission_held, 0) AS DECIMAL(28,4)) AS gross_commission_held,
    CAST(COALESCE(ak.net_commission_held, 0) AS DECIMAL(28,4)) AS net_commission_held,
    CAST(COALESCE(ak.gross_print, 0) AS DECIMAL(28,4)) AS gross_print,
    CAST(COALESCE(ak.net_print, 0) AS DECIMAL(28,4)) AS net_print,
    CAST(COALESCE(ak.gross_suitability, 0) AS DECIMAL(28,4)) AS gross_suitability,
    CAST(COALESCE(ak.net_suitability, 0) AS DECIMAL(28,4)) AS net_suitability,
    CAST(COALESCE(ak.gross_claim_payment, 0) AS DECIMAL(28,4)) AS gross_claim_payment,
    CAST(COALESCE(ak.net_claim_payment, 0) AS DECIMAL(28,4)) AS net_claim_payment,
    CAST(COALESCE(ak.gross_commission_paid, 0) AS DECIMAL(28,4)) AS gross_commission_paid,
    CAST(COALESCE(ak.net_commission_paid, 0) AS DECIMAL(28,4)) AS net_commission_paid,
    CAST(COALESCE(ak.gross_lapse, 0) AS DECIMAL(28,4)) AS gross_lapse,
    CAST(COALESCE(ak.net_lapse, 0) AS DECIMAL(28,4)) AS net_lapse,
    CAST(COALESCE(ak.gross_annuitization, 0) AS DECIMAL(28,4)) AS gross_annuitization,
    CAST(COALESCE(ak.net_annuitization, 0) AS DECIMAL(28,4)) AS net_annuitization,
    CAST(COALESCE(ak.gross_loan, 0) AS DECIMAL(28,4)) AS gross_loan,
    CAST(COALESCE(ak.net_loan, 0) AS DECIMAL(28,4)) AS net_loan,
    CAST(COALESCE(ak.gross_payout, 0) AS DECIMAL(28,4)) AS gross_payout,
    CAST(COALESCE(ak.net_payout, 0) AS DECIMAL(28,4)) AS net_payout,
    CAST(COALESCE(ak.gross_tax_conversion, 0) AS DECIMAL(28,4)) AS gross_tax_conversion,
    CAST(COALESCE(ak.net_tax_conversion, 0) AS DECIMAL(28,4)) AS net_tax_conversion,
    CAST(COALESCE(ak.gross_withdrawal, 0) AS DECIMAL(28,4)) AS gross_withdrawal,
    CAST(COALESCE(ak.net_withdrawal, 0) AS DECIMAL(28,4)) AS net_withdrawal,
    CAST(COALESCE(ak.gross_internal_replacement, 0) AS DECIMAL(28,4)) AS gross_internal_replacement,
    CAST(COALESCE(ak.net_internal_replacement, 0) AS DECIMAL(28,4)) AS net_internal_replacement,
    CAST(COALESCE(ak.gross_cap_repayment, 0) AS DECIMAL(28,4)) AS gross_cap_repayment,
    CAST(COALESCE(ak.net_cap_repayment, 0) AS DECIMAL(28,4)) AS net_cap_repayment,
    CAST(COALESCE(ak.gross_premium_refund, 0) AS DECIMAL(28,4)) AS gross_premium_refund,
    CAST(COALESCE(ak.net_premium_refund, 0) AS DECIMAL(28,4)) AS net_premium_refund,
    CAST(COALESCE(ak.gross_commission, 0) AS DECIMAL(28,4)) AS gross_commission,
    CAST(COALESCE(ak.net_commission, 0) AS DECIMAL(28,4)) AS net_commission,
    CAST(COALESCE(ak.gross_death, 0) AS DECIMAL(28,4)) AS gross_death,
    CAST(COALESCE(ak.net_death, 0) AS DECIMAL(28,4)) AS net_death,
    CAST(COALESCE(ak.gross_full_surrender, 0) AS DECIMAL(28,4)) AS gross_full_surrender,
    CAST(COALESCE(ak.net_full_surrender, 0) AS DECIMAL(28,4)) AS net_full_surrender,

    CAST(COALESCE(cv.annual_ratchet_amount,                    0) AS DECIMAL(14,4)) AS annual_ratchet_amount,
    CAST(COALESCE(cv.anticipated_premium,                      0) AS DECIMAL(14,4)) AS anticipated_premium,
    CAST(COALESCE(cv.cash_surrender_value,                     0) AS DECIMAL(14,4)) AS cash_surrender_value,
    CAST(COALESCE(cv.certain_end_date,                         0) AS DECIMAL(14,4)) AS certain_end_date,
    CAST(COALESCE(cv.death_benefit,                            0) AS DECIMAL(14,4)) AS death_benefit,
    CAST(COALESCE(cv.enhanced_accumulation_value,              0) AS DECIMAL(14,4)) AS enhanced_accumulation_value,
    CAST(COALESCE(cv.face_amount,                              0) AS DECIMAL(14,4)) AS face_amount,
    CAST(COALESCE(cv.free_amount_remaining,                    0) AS DECIMAL(14,4)) AS free_amount_remaining,
    CAST(COALESCE(cv.frequency,                                0) AS DECIMAL(14,4)) AS frequency,
    CAST(COALESCE(cv.guaranteed_enhanced_accumulation_value,   0) AS DECIMAL(14,4)) AS guaranteed_enhanced_accumulation_value,
    CAST(COALESCE(cv.ibr_benefit_base,                         0) AS DECIMAL(14,4)) AS ibr_benefit_base,
    CAST(COALESCE(cv.loan_balance,                             0) AS DECIMAL(14,4)) AS loan_balance,
    CAST(COALESCE(cv.ltc_benefit_amount,                       0) AS DECIMAL(14,4)) AS ltc_benefit_amount,
    CAST(COALESCE(cv.ltc_benefit_base,                         0) AS DECIMAL(14,4)) AS ltc_benefit_base,
    CAST(COALESCE(cv.mva_charge,                               0) AS DECIMAL(14,4)) AS mva_charge,
    CAST(COALESCE(cv.next_payment_date,                        0) AS DECIMAL(14,4)) AS next_payment_date,
    CAST(COALESCE(cv.payment_amount,                           0) AS DECIMAL(14,4)) AS payment_amount,
    CAST(COALESCE(cv.premium_received,                         0) AS DECIMAL(14,4)) AS premium_received,
    CAST(COALESCE(cv.surrender_charge,                         0) AS DECIMAL(14,4)) AS surrender_charge,
    CAST(COALESCE(cv.vested_benefit_base,                      0) AS DECIMAL(14,4)) AS vested_benefit_base,
    CAST(COALESCE(cv.vested_eav,                               0) AS DECIMAL(14,4)) AS vested_eav,
    CAST(COALESCE(cv.vested_geav,                              0) AS DECIMAL(14,4)) AS vested_geav,
    CAST(COALESCE(cv.vested_total_ltc_benefits,                0) AS DECIMAL(14,4)) AS vested_total_ltc_benefits,
    CAST(COALESCE(cv.vested_wellness_credit,                   0) AS DECIMAL(14,4)) AS vested_wellness_credit,
    CAST(COALESCE(cv.wellness_credit,                          0) AS DECIMAL(14,4)) AS wellness_credit,
    CAST(COALESCE(cv.withdrawals_since_inception,              0) AS DECIMAL(14,4)) AS withdrawals_since_inception,
    
    COALESCE(sd.surrender_customer_age,0) AS surrender_customer_age,
    COALESCE(sd.surrender_policy_year,0) AS surrender_policy_year,
    COALESCE(sd.surrender_penalty_duration_years,0) AS surrender_penalty_duration_years,
    CAST(COALESCE(sd.surrender_penalty_percentage,0) AS DECIMAL(5,4)) AS surrender_penalty_percentage,
    case when (sd.surrender_rate_calculation_basis is null or 
    sd.surrender_rate_calculation_basis='') then 'NOT PROVIDED' 
    else sd.surrender_rate_calculation_basis end AS surrender_rate_calculation_basis,
    
    COALESCE(dwa.agent_key,-1) as agent_key,
    case when COALESCE(hf.servicing_agent_indicator,'N') = 'N' then 1 else 0 end as is_writing_agent,
    case when COALESCE(hf.servicing_agent_indicator,'N') = 'Y' then 1 else 0 end as is_servicing_agent,
    case when COALESCE(hf.commission_only_indicator,'N') = 'Y' then 1 else 0 end as is_commission_only,
    COALESCE(hf.hierarchy_order,99) as hierarchy_order,
    CAST(COALESCE(hf.reverse_level,99) AS DECIMAL(11,1)) as reverse_level,
    COALESCE(hf.agent_contract_key,-1) as agent_contract_key,
    COALESCE(hf.commission_level_rank_key,-1) as commission_level_rank_key
    

FROM contract cb

-- ── Hierarchy joins ───────────────────────────────────────────────────────
-- writing_agents expands the grain: one row per hierarchy_order per contract
LEFT JOIN activity_kpis ak
    ON cb.contract_id = ak.contract_id
LEFT JOIN hierarchy_flat hf
    ON  hf.hierarchy_group_key  = cb.hierarchy_group_key
LEFT JOIN contract_values cv
    ON  cv.contract_value_key = cb.contract_value_group_key
-- ── Gold dim surrogate key lookups ────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_policy dp
    ON  dp.policy_number          = cb.contract_number
    AND dp.is_current           = 1
LEFT JOIN lh_gold.gold.dim_product dprod
    ON  dprod.source_product_id        = cb.product_id
    AND dprod.is_current        = 1
LEFT JOIN lh_gold.gold.dim_agent dwa
    ON  dwa.agent_number   = hf.agent_number
    AND dwa.is_current          = 1
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


# In[ ]:


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
        "surrender_rate_calculation_basis",
        "agent_key",
        "is_writing_agent",
        "is_servicing_agent",
        "is_commission_only",
        "hierarchy_order",
        "reverse_level",
        "agent_contract_key",
        "commission_level_rank_key"
    )
)


# In[ ]:


policy_snapshot_df = policy_snapshot_df.dropDuplicates()


# In[ ]:


display(policy_snapshot_df.limit(2))

#  ['agent_number','agent_name','agent_type','national_producer_number','nasd_finra_number','status'] 


# In[ ]:


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
    partition_cols = ['snapshot_date_key'],
    ingestion_date = p_ingestion_date,
    data_timestamp = p_ingestion_timestamp,
    source_system = "EQ_Warehouse",
    ingestion_run_id = p_ingestion_run_id,
    ingestion_timestamp = p_ingestion_timestamp,
    src_busn_asst = p_src_busn_asst,
    replace_where     = f"snapshot_date_key = '{p_snapshot_date_key}'"
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%sql

# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_agent_factpolicysnapshot_imoagent FULL;
# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_agent_factpolicysnapshot_nmoagent FULL;
# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_agent_factpolicysnapshot_servicingagent FULL;
# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_agent_factpolicysnapshot_writingagent FULL;
# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_client_factpolicysnapshot_annuitant FULL;
# -- REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_client_factpolicysnapshot_owner FULL;
# REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_date_factpolicysnapshot_issuedate FULL;
# REFRESH MATERIALIZED LAKE VIEW lh_gold.gold.rp_dim_date_factpolicysnapshot_snapshotdate FULL;

