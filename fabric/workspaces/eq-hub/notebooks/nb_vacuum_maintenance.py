# Notebook: nb_vacuum_maintenance
# Layer: UTILITY
# Purpose: Runs VACUUM RETAIN 168 HOURS (7 days) on all Delta tables across all layers.
#          Disables retentionDurationCheck to allow sub-168h retention where configured.
#          Logs vacuumed/skipped counts. Scheduled weekly via Fabric.
#
# Safety: VACUUM only removes files beyond retention window.
#         Delta time travel is preserved for 168 hours post-vacuum.
#         For rollback, use: RESTORE TABLE ... TO VERSION AS OF N
#
# Parameters:
#   run_id        : STRING — UUID for this maintenance run
#   environment   : STRING — dev | qa | tst | prod
#   dry_run       : STRING — "true" to log without actually vacuuming (default: "false")
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")
dry_run     = dbutils.widgets.get("dry_run", "false").lower() == "true"

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
RETAIN_HOURS     = 168  # 7 days
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"

logger = FabricLogger(
    run_id=run_id,
    layer="utility",
    object_name="vacuum_maintenance",
    environment=ENVIRONMENT,
)

# Disable retention check to allow VACUUM with configured retention
spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")

if dry_run:
    logger.warning("DRY RUN mode — VACUUM commands will be logged but NOT executed")

# ─── Table inventory ──────────────────────────────────────────────────────────
BASE_BRONZE  = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse"
BASE_S1      = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1"
BASE_S2      = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s2"
BASE_GOLD    = f"abfss://gold@{STORAGE_ACCOUNT}.dfs.core.windows.net"
BASE_CONTROL = f"abfss://control@{STORAGE_ACCOUNT}.dfs.core.windows.net"
BASE_AUDIT   = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net"
BASE_Q       = f"abfss://quarantine@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse"

TABLES = {
    # Bronze — 50 tables
    "bronze": [
        f"{BASE_BRONZE}/date_base",
        f"{BASE_BRONZE}/state_base",
        f"{BASE_BRONZE}/company_base",
        f"{BASE_BRONZE}/activity_type_base",
        f"{BASE_BRONZE}/commission_level_rank_base",
        f"{BASE_BRONZE}/investment_detail_base",
        f"{BASE_BRONZE}/accounting_account_base",
        f"{BASE_BRONZE}/product_variation_detail_base",
        f"{BASE_BRONZE}/accounting_reporting_group_base",
        f"{BASE_BRONZE}/training_course_base",
        f"{BASE_BRONZE}/product_base",
        f"{BASE_BRONZE}/surrender_base",
        f"{BASE_BRONZE}/territory_base",
        f"{BASE_BRONZE}/client_base",
        f"{BASE_BRONZE}/agent_base",
        f"{BASE_BRONZE}/investment_base",
        f"{BASE_BRONZE}/product_state_approval_base",
        f"{BASE_BRONZE}/product_state_variation_base",
        f"{BASE_BRONZE}/product_state_approval_disclosure_base",
        f"{BASE_BRONZE}/contract_base",
        f"{BASE_BRONZE}/agent_contract_base",
        f"{BASE_BRONZE}/agent_license_base",
        f"{BASE_BRONZE}/agent_principal_base",
        f"{BASE_BRONZE}/agent_training_base",
        f"{BASE_BRONZE}/training_product_base",
        f"{BASE_BRONZE}/training_state_base",
        f"{BASE_BRONZE}/hierarchy_territory_base",
        f"{BASE_BRONZE}/hierarchy_base",
        f"{BASE_BRONZE}/hierarchy_super_hierarchy_base",
        f"{BASE_BRONZE}/hierarchy_bridge_base",
        f"{BASE_BRONZE}/hierarchy_option_base",
        f"{BASE_BRONZE}/account_value_base",
        f"{BASE_BRONZE}/external_account_group_base",
        f"{BASE_BRONZE}/additional_client_group_base",
        f"{BASE_BRONZE}/additional_info_group_base",
        f"{BASE_BRONZE}/reinsurance_group_base",
        f"{BASE_BRONZE}/activity_base",
        f"{BASE_BRONZE}/activity_financial_base",
        f"{BASE_BRONZE}/accounting_base",
        f"{BASE_BRONZE}/accounting_detail_base",
        f"{BASE_BRONZE}/contract_value_group_base",
        f"{BASE_BRONZE}/contract_deposit_base",
        f"{BASE_BRONZE}/recurring_payment_base",
        f"{BASE_BRONZE}/agent_summary_base",
        f"{BASE_BRONZE}/index_value_base",
        f"{BASE_BRONZE}/renewal_rate_base",
        f"{BASE_BRONZE}/cap_repayment_base",
        f"{BASE_BRONZE}/cap_status_change_base",
        f"{BASE_BRONZE}/hedge_ratios_base",
        f"{BASE_BRONZE}/hedge_options_base",
    ],
    # Silver S1 — 8 tables
    "silver_s1": [
        f"{BASE_S1}/contract",
        f"{BASE_S1}/client",
        f"{BASE_S1}/agent",
        f"{BASE_S1}/activity",
        f"{BASE_S1}/account_value",
        f"{BASE_S1}/accounting",
        f"{BASE_S1}/product",
        f"{BASE_S1}/investment",
    ],
    # Silver S2 — 3 tables
    "silver_s2": [
        f"{BASE_S2}/contract_enriched",
        f"{BASE_S2}/activity_financial_detail",
        f"{BASE_S2}/agent_production_summary",
    ],
    # Gold — 17 tables
    "gold": [
        f"{BASE_GOLD}/dim_date",
        f"{BASE_GOLD}/dim_contract",
        f"{BASE_GOLD}/dim_client",
        f"{BASE_GOLD}/dim_agent",
        f"{BASE_GOLD}/dim_product",
        f"{BASE_GOLD}/dim_investment",
        f"{BASE_GOLD}/dim_state",
        f"{BASE_GOLD}/dim_company",
        f"{BASE_GOLD}/dim_activity_type",
        f"{BASE_GOLD}/dim_accounting_account",
        f"{BASE_GOLD}/fact_activity",
        f"{BASE_GOLD}/fact_account_value",
        f"{BASE_GOLD}/fact_accounting",
        f"{BASE_GOLD}/fact_contract_value",
        f"{BASE_GOLD}/fact_contract_deposit",
        f"{BASE_GOLD}/fact_agent_summary",
        f"{BASE_GOLD}/fact_hedge",
    ],
    # Control — 4 tables
    "control": [
        f"{BASE_CONTROL}/ingestion_config",
        f"{BASE_CONTROL}/dataflow_config",
        f"{BASE_CONTROL}/watermark_state",
        f"{BASE_CONTROL}/pipeline_config",
    ],
    # Audit — 3 tables
    "audit": [
        f"{BASE_AUDIT}/pipeline_run_log",
        f"{BASE_AUDIT}/quarantine_log",
        f"{BASE_AUDIT}/schema_drift_log",
    ],
}

# ─── Vacuum execution ─────────────────────────────────────────────────────────
total_vacuumed = 0
total_skipped  = 0

for layer, paths in TABLES.items():
    logger.info(f"--- Vacuuming layer: {layer} ({len(paths)} tables) ---")
    for path in paths:
        table_name = path.split("/")[-1]
        try:
            if not dry_run:
                spark.sql(f"VACUUM delta.`{path}` RETAIN {RETAIN_HOURS} HOURS")
            logger.info(f"VACUUM OK: {layer}/{table_name}")
            total_vacuumed += 1
        except Exception as e:
            # Likely the table doesn't exist yet — skip with warning
            logger.warning(f"VACUUM SKIPPED: {layer}/{table_name} — {str(e)[:200]}")
            total_skipped += 1

logger.info(f"Vacuum maintenance complete: {total_vacuumed} vacuumed, {total_skipped} skipped")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
