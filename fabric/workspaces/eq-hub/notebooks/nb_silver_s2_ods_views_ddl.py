# Notebook: nb_silver_s2_ods_views_ddl
# Layer:    Silver S2
# Purpose:  Creates Fabric Materialized Lake Views in lh_silver.dbo that
#           replicate the EQ_ODS view semantics over silver_s1 base tables.
#
# Views created (all in lh_silver.dbo):
#   vw_SEG_Client                 — ClientRole ⟷ ClientDetail
#   vw_SEG_Agent                  — Agent ⟷ ClientRole ⟷ ClientDetail
#   vw_SEG_ContractClient         — ClientRole ⟷ ClientDetail ⟷ ContractClient ⟷ ContractClientAllocation
#   vw_SEG_ContractTreaty         — ContractTreaty ⟷ Treaty ⟷ TreatyGroup
#   vw_SEG_ContractRider          — Segment (rider segments only: SegmentFK IS NOT NULL)
#   vw_SEG_ContractPrimarySegment — Segment (primary segments only: SegmentFK IS NULL) ⟷ ProductStructure
#   vw_SEG_ContractTrx            — EDITTrx ⟷ ClientSetup ⟷ ContractClient ⟷ EDITTrxHistory ⟷ FinancialHistory ⟷ ContractClientAllocation
#
# Source base tables: lh_silver.silver_s1.*_base
# Target views:       lh_silver.dbo.vw_SEG_*
#
# DDL used:
#   CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS lh_silver.dbo.<view_name> AS
#   <SELECT ... FROM ... JOIN ...>
#
# Note: IF NOT EXISTS is a no-op when the view already exists — re-running will
#       not overwrite an existing view.  Drop manually before re-running if needed.
#
# Pipeline / manual run:
#   Notebook activity   : nb_silver_s2_ods_views_ddl
#   Parameters          : (none — all source/target paths are fixed)
#   Default lakehouse   : lh_silver

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_silver_s2_ods_views_ddl").getOrCreate()

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Configuration
# ══════════════════════════════════════════════════════════════════════════════

_TARGET_LH     = "lh_silver"
_TARGET_SCHEMA = "silver_s2"
_SOURCE_LH     = "lh_silver"
_SOURCE_SCHEMA = "silver_s1"

_SRC  = f"{_SOURCE_LH}.{_SOURCE_SCHEMA}"   # lh_silver.silver_s1
_TGT  = f"{_TARGET_LH}.{_TARGET_SCHEMA}"   # lh_silver.silver_s2

print("=" * 70)
print("  nb_silver_s2_ods_views_ddl — START")
print("=" * 70)
print(f"  source : {_SRC}")
print(f"  target : {_TGT}")
print("=" * 70)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — View DDL definitions
# ══════════════════════════════════════════════════════════════════════════════
#
# Each entry is a dict:
#   view_name : str   — unqualified view name (lh_silver.dbo.<name>)
#   ddl       : str   — full CREATE MATERIALIZED LAKE VIEW statement
#
# Column names reflect silver_s1 snake_case target names from schema_config.
# Table aliases match the first letters of the base table name for readability.
#
# WHERE-clause translations from EQ_ODS:
#   OverrideStatus = 'P'                   → <alias>.override_status = 'P'
#   ISNULL(TerminationDate,'12/31/9999')   → COALESCE(<alias>.termination_date,
#     > GETDATE()                              CAST('9999-12-31' AS TIMESTAMP))
#                                              > CURRENT_TIMESTAMP()
# ──────────────────────────────────────────────────────────────────────────────

_VIEW_DEFS = []


# ── [1] vw_SEG_Client ─────────────────────────────────────────────────────────
# Original: ClientRole RIGHT JOIN ClientDetail ON ClientRole.ClientDetailFK = ClientDetailPK
_VIEW_DEFS.append({
    "view_name": "vw_SEG_Client",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_Client AS
        SELECT
            cr.client_role_id,
            cr.preference_id,
            cr.tax_profile_id,
            cr.role_type_code,
            cr.override_status,
            cd.client_detail_id,
            cd.client_identification,
            cd.tax_identification,
            cd.last_name,
            cd.first_name,
            cd.middle_name,
            cd.name_prefix,
            cd.name_suffix,
            cd.corporate_name,
            cd.birth_date,
            cd.mothers_maiden_name,
            cd.occupation,
            cd.date_of_death,
            cd.operator,
            cd.maint_datetime,
            cd.gender_code,
            cd.trust_type_code,
            cd.status_code,
            cd.is_privacy,
            cd.last_ofac_check_date,
            cd.state_of_death_code,
            cd.resident_state_at_death_code,
            cd.proof_of_death_received_date,
            cd.case_tracking_process,
            cd.notification_received_date,
            cd.override_status  AS client_detail_override_status
        FROM  {_SRC}.client_role_base   cr
        RIGHT JOIN {_SRC}.client_detail_base  cd
               ON  cr.client_detail_id = cd.client_detail_id
    """,
})


# ── [2] vw_SEG_Agent ──────────────────────────────────────────────────────────
# Original: Agent INNER JOIN ClientRole ON Agent.AgentPK = ClientRole.AgentFK
#           INNER JOIN ClientDetail ON ClientRole.ClientDetailFK = ClientDetail.ClientDetailPK
_VIEW_DEFS.append({
    "view_name": "vw_SEG_Agent",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_Agent AS
        SELECT
            a.agent_id,
            a.hire_date,
            a.termination_date,
            a.agent_status_code,
            a.agent_type_code,
            a.withholding_status,
            a.department,
            a.region,
            a.branch,
            a.npn,
            a.int_debit_bal_status_code,
            a.hold_comm_status,
            a.operator,
            a.maint_datetime,
            a.disbursement_address_type_code,
            a.correspondence_address_type_code,
            a.rehire_eligible_date,
            a.company_id,
            cr.client_role_id,
            cr.preference_id,
            cr.tax_profile_id,
            cr.role_type_code,
            cr.reference_id  AS agent_number,
            cd.client_detail_id,
            cd.client_identification,
            cd.tax_identification,
            cd.last_name,
            cd.first_name,
            cd.middle_name,
            cd.name_prefix,
            cd.name_suffix,
            cd.corporate_name,
            cd.birth_date,
            cd.mothers_maiden_name,
            cd.occupation,
            cd.date_of_death,
            cd.gender_code,
            cd.trust_type_code,
            cd.status_code,
            cd.is_privacy,
            cd.last_ofac_check_date,
            cd.state_of_death_code,
            cd.resident_state_at_death_code,
            cd.proof_of_death_received_date,
            cd.case_tracking_process,
            cd.notification_received_date
        FROM  {_SRC}.agent_ods_base      a
        INNER JOIN {_SRC}.client_role_base   cr ON a.agent_id = cr.agent_id
        INNER JOIN {_SRC}.client_detail_base cd ON cr.client_detail_id = cd.client_detail_id
    """,
})


# ── [3] vw_SEG_ContractClient ─────────────────────────────────────────────────
# Original: ClientRole INNER JOIN ClientDetail ON ClientRole.ClientDetailFK = ClientDetailPK
#           INNER JOIN ContractClient ON ClientRole.ClientRolePK = ContractClient.ClientRoleFK
#           LEFT  JOIN ContractClientAllocation ca ON ca.ContractClientFK = ContractClientPK
#                                                 AND ca.OverrideStatus = 'P'
# WHERE: ContractClient.OverrideStatus = 'P'
#    AND ClientRole.OverrideStatus     = 'P'
#    AND ISNULL(ContractClient.TerminationDate,'12/31/9999') > GETDATE()
_VIEW_DEFS.append({
    "view_name": "vw_SEG_ContractClient",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_ContractClient AS
        SELECT
            cc.contract_client_id,
            cc.segment_id,
            cc.issue_age,
            cc.effective_date,
            cc.termination_date,
            cc.relationship_to_insured_code,
            cc.telephone_authorization_code,
            cc.class_code,
            cc.flat_extra,
            cc.flat_extra_age,
            cc.flat_extra_duration,
            cc.percent_extra,
            cc.percent_extra_age,
            cc.percent_extra_duration,
            cc.table_rating_code,
            cc.disbursement_address_type_code,
            cc.correspondence_address_type_code,
            cc.is_pending_class_change,
            cc.payor_of_code,
            cc.rated_gender_code,
            cc.underwriting_class_code,
            cc.termination_reason_code,
            cc.is_edelivery,
            cr.client_role_id,
            cr.preference_id,
            cr.tax_profile_id,
            cr.role_type_code,
            cr.new_issues_eligibility_status_code,
            cr.new_issues_eligibility_start_date,
            cr.reference_id,
            cd.client_detail_id,
            cd.client_identification,
            cd.tax_identification,
            cd.last_name,
            cd.first_name,
            cd.middle_name,
            cd.name_prefix,
            cd.name_suffix,
            cd.corporate_name,
            cd.birth_date,
            cd.mothers_maiden_name,
            cd.occupation,
            cd.date_of_death,
            cd.operator,
            cd.gender_code,
            cd.trust_type_code,
            cd.status_code,
            cd.is_privacy,
            cd.last_ofac_check_date,
            cd.state_of_death_code,
            cd.resident_state_at_death_code,
            cd.proof_of_death_received_date,
            cd.case_tracking_process,
            cd.notification_received_date,
            ca.contract_client_allocation_id,
            ca.allocation_percent,
            ca.allocation_dollars,
            ca.is_split_equal
        FROM  {_SRC}.client_role_base                  cr
        INNER JOIN {_SRC}.client_detail_base           cd  ON  cr.client_detail_id       = cd.client_detail_id
        INNER JOIN {_SRC}.contract_client_base         cc  ON  cr.client_role_id         = cc.client_role_id
        LEFT  JOIN {_SRC}.contract_client_allocation_base ca
               ON  ca.contract_client_id = cc.contract_client_id
               AND ca.override_status    = 'P'
        WHERE  cc.override_status = 'P'
          AND  cr.override_status = 'P'
          AND  COALESCE(cc.termination_date, CAST('9999-12-31' AS TIMESTAMP)) > CURRENT_TIMESTAMP()
    """,
})


# ── [4] vw_SEG_ContractTreaty ─────────────────────────────────────────────────
# Original: ContractTreaty INNER JOIN Treaty ON ContractTreaty.TreatyFK = Treaty.TreatyPK
#           INNER JOIN TreatyGroup ON Treaty.TreatyGroupFK = TreatyGroup.TreatyGroupPK
_VIEW_DEFS.append({
    "view_name": "vw_SEG_ContractTreaty",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_ContractTreaty AS
        SELECT
            ct.contract_treaty_id,
            ct.segment_id,
            ct.reinsurance_indicator_code,
            ct.effective_date,
            ct.reinsurance_class_code,
            ct.retention_amount,
            ct.pool_percentage,
            ct.reinsurance_type_code,
            ct.table_rating_code,
            ct.flat_extra,
            ct.flat_extra_age,
            ct.flat_extra_duration,
            ct.percent_extra,
            ct.percent_extra_age,
            ct.percent_extra_duration,
            ct.max_reinsurance_amount,
            ct.is_treaty_override,
            ct.is_policy_override,
            ct.status,
            t.start_date,
            t.stop_date,
            t.settlement_period,
            t.payment_mode_code,
            t.calculation_mode_code,
            t.last_check_date,
            t.reinsurer_balance,
            tg.treaty_group_id,
            tg.treaty_group_number,
            t.treaty_id,
            t.coinsurance_percentage
        FROM  {_SRC}.contract_treaty_base  ct
        INNER JOIN {_SRC}.treaty_base       t   ON  ct.treaty_id       = t.treaty_id
        INNER JOIN {_SRC}.treaty_group_base tg  ON  t.treaty_group_id  = tg.treaty_group_id
    """,
})


# ── [5] vw_SEG_ContractRider ──────────────────────────────────────────────────
# Original: SELECT * FROM SEG_EDITSOLUTIONS.dbo.Segment
#           WHERE SegmentFK IS NOT NULL
#             AND SegmentNameCT NOT IN ('DFA','Payout','Traditional','Life')
# Maps to: segment_base where parent_segment_id IS NOT NULL (rider/sub-segments)
_VIEW_DEFS.append({
    "view_name": "vw_SEG_ContractRider",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_ContractRider AS
        SELECT
            s.segment_id,
            s.parent_segment_id,
            s.product_structure_id,
            s.contract_number,
            s.effective_date,
            s.amount,
            s.qual_non_qual_code,
            s.is_exchange,
            s.cost_basis,
            s.recovered_cost_basis,
            s.termination_date,
            s.status_change_date,
            s.segment_name_code,
            s.segment_status_code,
            s.option_code,
            s.issue_state_code,
            s.qualified_type_code,
            s.quote_date,
            s.charges,
            s.loads,
            s.fees,
            s.tax_reporting_group,
            s.issue_date,
            s.is_cash_with_app,
            s.is_waiver_in_effect,
            s.free_amount_remaining,
            s.free_amount,
            s.date_in_effect,
            s.creation_operator,
            s.creation_date,
            s.last_anniversary_date,
            s.application_signed_date,
            s.application_received_date,
            s.savings_percent,
            s.annual_insurance_amount,
            s.annual_investment_amount,
            s.dismemberment_percent,
            s.policy_delivery_date,
            s.is_waive_free_look,
            s.free_look_days_override,
            s.free_look_end_date,
            s.is_point_in_scale,
            s.is_charge_deduct_division,
            s.dialable_sales_load_percentage,
            s.charge_deduct_amount,
            s.rider_number,
            s.is_commitment,
            s.commitment_amount,
            s.charge_code_status,
            s.is_roth_conversion,
            s.date_of_death_value,
            s.supp_original_contract_number,
            s.open_claim_end_date,
            s.annuitization_value,
            s.casetracking_option_code,
            s.print_line_1,
            s.print_line_2,
            s.total_active_beneficiaries,
            s.remaining_beneficiaries,
            s.settlement_amount,
            s.last_settlement_val_date,
            s.contract_type_code,
            s.total_face_amount,
            s.income_start_date,
            s.income_start_age,
            s.extended_income_period_date,
            s.benefit_base,
            s.benefit_base_last_val_date,
            s.income_wd_amount,
            s.remaining_income_wd_amount,
            s.sys_gain_accum,
            s.first_notify_date
        FROM  {_SRC}.segment_base  s
        WHERE  s.parent_segment_id IS NOT NULL
          AND  s.segment_name_code NOT IN ('DFA', 'Payout', 'Traditional', 'Life')
    """,
})


# ── [6] vw_SEG_ContractPrimarySegment ────────────────────────────────────────
# Original: Segment LEFT JOIN ProductStructure ON Segment.ProductStructureFK = ProductStructure.ProductStructurePK
#           WHERE Segment.SegmentFK IS NULL
#             AND Segment.SegmentNameCT IN ('DFA','Payout','Traditional','Life')
_VIEW_DEFS.append({
    "view_name": "vw_SEG_ContractPrimarySegment",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_ContractPrimarySegment AS
        SELECT
            s.segment_id,
            s.parent_segment_id,
            s.contract_number,
            s.effective_date,
            s.amount,
            s.qual_non_qual_code,
            s.is_exchange,
            s.cost_basis,
            s.recovered_cost_basis,
            s.termination_date,
            s.status_change_date,
            s.segment_name_code,
            s.segment_status_code,
            s.option_code,
            s.issue_state_code,
            s.qualified_type_code,
            s.quote_date,
            s.charges,
            s.loads,
            s.fees,
            s.tax_reporting_group,
            s.issue_date,
            s.is_cash_with_app,
            s.is_waiver_in_effect,
            s.free_amount_remaining,
            s.free_amount,
            s.date_in_effect,
            s.creation_operator,
            s.creation_date,
            s.last_anniversary_date,
            s.application_signed_date,
            s.application_received_date,
            s.savings_percent,
            s.annual_insurance_amount,
            s.annual_investment_amount,
            s.dismemberment_percent,
            s.policy_delivery_date,
            s.is_waive_free_look,
            s.free_look_days_override,
            s.free_look_end_date,
            s.is_point_in_scale,
            s.is_charge_deduct_division,
            s.dialable_sales_load_percentage,
            s.charge_deduct_amount,
            s.rider_number,
            s.is_commitment,
            s.commitment_amount,
            s.charge_code_status,
            s.is_roth_conversion,
            s.date_of_death_value,
            s.supp_original_contract_number,
            s.open_claim_end_date,
            s.annuitization_value,
            s.casetracking_option_code,
            s.print_line_1,
            s.print_line_2,
            s.total_active_beneficiaries,
            s.remaining_beneficiaries,
            s.settlement_amount,
            s.last_settlement_val_date,
            s.contract_type_code,
            s.total_face_amount,
            s.income_start_date,
            s.income_start_age,
            s.extended_income_period_date,
            s.benefit_base,
            s.benefit_base_last_val_date,
            s.income_wd_amount,
            s.remaining_income_wd_amount,
            s.sys_gain_accum,
            s.bill_schedule_id,
            ps.marketing_package_name,
            ps.product_structure_id,
            ps.product_structure_id  AS company_structure_id,
            ps.business_contract_name,
            ps.product_type_code
        FROM  {_SRC}.segment_base           s
        LEFT  JOIN {_SRC}.product_structure_base  ps
               ON  s.product_structure_id = ps.product_structure_id
        WHERE  s.parent_segment_id IS NULL
          AND  s.segment_name_code IN ('DFA', 'Payout', 'Traditional', 'Life')
    """,
})


# ── [7] vw_SEG_ContractTrx ────────────────────────────────────────────────────
# Original:
#   EDITTrx INNER JOIN ClientSetup ON EDITTrx.ClientSetupFK = ClientSetup.ClientSetupPK
#   LEFT JOIN ContractClient ON ClientSetup.ContractClientFK = ContractClient.ContractClientPK
#   LEFT JOIN EDITTrxHistory ON EDITTrxHistory.EDITTrxFK = EDITTrx.EDITTrxPK
#   LEFT JOIN FinancialHistory ON FinancialHistory.EDITTrxHistoryFK = EDITTrxHistory.EDITTrxHistoryPK
#   LEFT JOIN ContractClientAllocation ca
#       ON ca.ContractClientFK = ContractClient.ContractClientPK AND ca.OverrideStatus = 'P'
_VIEW_DEFS.append({
    "view_name": "vw_SEG_ContractTrx",
    "ddl": f"""
        CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_TGT}.vw_SEG_ContractTrx AS
        SELECT
            cc.segment_id,
            cs.client_setup_id,
            cs.client_role_id,
            et.edit_trx_id,
            et.effective_date,
            et.status,
            et.pending_status,
            et.sequence_number,
            et.tax_year,
            et.trx_amount,
            et.due_date,
            et.transaction_type_code,
            et.is_trx_rescheduled,
            et.reapply_edit_trx_id,
            et.commission_status,
            et.is_look_back,
            et.originating_trx_id,
            et.is_no_correspondence,
            et.is_no_accounting,
            et.is_no_commission,
            et.maint_datetime,
            et.operator,
            et.notification_amount,
            et.notification_amount_received,
            et.transfer_type_code,
            et.advance_notification_override,
            et.accounting_period,
            et.reinsurance_status,
            et.bonus_commission_amount,
            et.excess_bonus_commission_amount,
            et.date_contribution_excess,
            et.transfer_units_type,
            et.is_no_check_eft,
            et.interest_proceeds_override,
            et.new_policy_number,
            et.reversal_reason_code,
            et.check_adjustment_id,
            et.trx_percent,
            et.original_accounting_period,
            eth.edit_trx_history_id,
            eth.cycle_date,
            eth.original_process_datetime,
            eth.accounting_pending_status,
            eth.control_number,
            eth.release_date,
            eth.return_date,
            eth.correspondence_type_code,
            eth.process_id,
            eth.is_real_time,
            eth.address_type_code,
            eth.process_datetime,
            fh.financial_history_id,
            fh.gross_amount,
            fh.net_amount,
            fh.check_amount,
            fh.free_amount,
            fh.taxable_benefit,
            fh.disbursement_source_code,
            fh.liability,
            fh.commissionable_amount,
            fh.max_commission_amount,
            fh.cost_basis,
            fh.accumulated_value,
            fh.surrender_value,
            fh.guar_accumulated_value,
            fh.prior_due_date,
            fh.prior_extract_date,
            fh.prior_fixed_amount,
            fh.prev_complex_change_value,
            fh.is_taxable,
            fh.net_amount_at_risk,
            fh.distribution_code,
            fh.net_income_attributable,
            fh.interest_proceeds,
            fh.prior_initial_cy_accum_value,
            fh.insurance_inforce,
            fh.seven_pay_rate,
            cs.contract_setup_id,
            ca.contract_client_allocation_id,
            ca.allocation_percent,
            ca.override_status  AS allocation_override_status,
            ca.allocation_dollars,
            ca.is_split_equal,
            et.bga
        FROM  {_SRC}.edit_trx_base                    et
        INNER JOIN {_SRC}.client_setup_base            cs  ON  et.client_setup_id         = cs.client_setup_id
        LEFT  JOIN {_SRC}.contract_client_base         cc  ON  cs.contract_client_id      = cc.contract_client_id
        LEFT  JOIN {_SRC}.edit_trx_history_base        eth ON  eth.edit_trx_id            = et.edit_trx_id
        LEFT  JOIN {_SRC}.financial_history_base       fh  ON  fh.edit_trx_history_id    = eth.edit_trx_history_id
        LEFT  JOIN {_SRC}.contract_client_allocation_base ca
               ON  ca.contract_client_id = cc.contract_client_id
               AND ca.override_status    = 'P'
    """,
})


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Create views
# ══════════════════════════════════════════════════════════════════════════════

print(f"\nCreating {len(_VIEW_DEFS)} materialized lake views in {_TGT}\n")

views_created  = 0
views_existing = 0
errors         = []

for defn in _VIEW_DEFS:
    view_name     = defn["view_name"]
    full_ref      = f"{_TGT}.{view_name}"
    ddl           = defn["ddl"]

    try:
        if spark.catalog.tableExists(full_ref):
            print(f"  EXISTS   {full_ref}")
            views_existing += 1
        else:
            spark.sql(ddl)
            print(f"  CREATED  {full_ref}")
            views_created += 1
    except Exception as e:
        errors.append((view_name, str(e)))
        print(f"  ERROR    {view_name}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 70)
print("  nb_silver_s2_ods_views_ddl — COMPLETE")
print(f"  Views created   : {views_created}")
print(f"  Views existing  : {views_existing}  (IF NOT EXISTS — no change made)")
print(f"  Errors          : {len(errors)}")
print(f"  Elapsed         : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for vw, msg in errors:
        print(f"    {vw}: {msg}")
print("=" * 70)

if errors:
    raise RuntimeError(
        f"{len(errors)} materialized lake view(s) failed to create. "
        f"See output above for details."
    )
