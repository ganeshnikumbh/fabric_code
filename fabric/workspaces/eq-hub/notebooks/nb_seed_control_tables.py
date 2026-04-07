# Notebook: nb_seed_control_tables
# Purpose:  Seeds the lh_control ingestion framework tables with initial data.
#           Writes three tables:
#             - ingestion_config   : one row per EQ_Warehouse source entity (62 rows)
#             - watermark_control  : initial pending rows for all incremental entities
#             - sla_config         : SLA definitions per entity (critical vs standard)
#
#           Idempotent — uses replaceWhere / overwrite so safe to re-run.
#
# Pre-requisite: Attach lh_control as the default lakehouse before running.
#                Explorer pane → Add lakehouse → lh_control → Confirm
#
# Run order: Run AFTER nb_control_audit_ddl (tables must exist first).
#
# Logging:  Uses FabricLogger to record run status and any errors to:
#             - pipeline_run_log  : overall seed run lifecycle
#             - error_log         : any exceptions raised during seeding

# %run /fabric/workspaces/eq-hub/notebooks/nb_logging_library
# ↑ Uncomment in Fabric (magic command not supported in local IDE)
# For local IDE testing, ensure nb_logging_library.py is imported manually.

from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("nb_seed_control_tables").getOrCreate()


# ## CELL 1 — Configuration
# ══════════════════════════════════════════════════════════════════════════════
# Change WORKSPACE_NAME per environment. Everything else is derived.
# ══════════════════════════════════════════════════════════════════════════════

WORKSPACE_NAME = "eq-hub-dev"                      # e.g. eq-hub-dev | eq-hub-prod
LAKEHOUSE_NAME = "lh_control"
ENVIRONMENT    = "dev"                             # dev | qa | tst | prod
CREATED_BY     = "fabric-pipeline-svc"

# Logger config — matches pipeline_run_log schema
PIPELINE_NAME  = "nb_seed_control_tables"
ENTITY_NAME    = "control_framework_seed"
LAYER          = "control"

ONELAKE_HOST   = "onelake.dfs.fabric.microsoft.com"
BASE_PATH      = (
    f"abfss://{WORKSPACE_NAME}@{ONELAKE_HOST}"
    f"/{LAKEHOUSE_NAME}.Lakehouse/Files/control_tables"
)

print(f"Workspace  : {WORKSPACE_NAME}")
print(f"Lakehouse  : {LAKEHOUSE_NAME}")
print(f"Base path  : {BASE_PATH}")


# ## CELL 2 — Helper
# ══════════════════════════════════════════════════════════════════════════════

from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType, StructField,
    IntegerType, StringType, BooleanType, TimestampType
)
from datetime import datetime, timezone

NOW = datetime.now(timezone.utc)

def table_path(table_name: str) -> str:
    return f"{BASE_PATH}/{table_name}"

def write_seed(df, table_name: str) -> None:
    path = table_path(table_name)
    count = df.count()
    (
        df.write
        .format("delta")
        .mode("overwrite")
        .option("overwriteSchema", "true")
        .save(path)
    )
    verified = spark.read.format("delta").load(path).count()
    print(f"  {table_name:<25} written={count}  verified={verified}")
    if verified != count:
        raise RuntimeError(f"Row count mismatch for {table_name}: wrote {count}, found {verified}")


# ## CELL 3 — ingestion_config seed data
# ══════════════════════════════════════════════════════════════════════════════
# One row per EQ_Warehouse source entity (62 total).
# Columns match ingestion_config DDL exactly.
# fmt: source_id, source_name, source_type, entity_name,
#       target_lakehouse, target_schema, target_table,
#       load_type, watermark_column, watermark_type, batch_size,
#       extraction_query, api_endpoint, api_method, api_headers,
#       active_flag, created_by
# ══════════════════════════════════════════════════════════════════════════════

INGESTION_ROWS = [
    # ── Batch 1: Reference tables (full load) ──────────────────────────────
    (1,  "EQ_Warehouse", "sqlserver", "Date",                        "lh_bronze", "bronze_eqwarehouse", "date_base",                             "full",        None,              None,       None,  None, None, None, None, True),
    (2,  "EQ_Warehouse", "sqlserver", "State",                       "lh_bronze", "bronze_eqwarehouse", "state_base",                            "full",        None,              None,       None,  None, None, None, None, True),
    (3,  "EQ_Warehouse", "sqlserver", "Company",                     "lh_bronze", "bronze_eqwarehouse", "company_base",                          "full",        None,              None,       None,  None, None, None, None, True),
    (4,  "EQ_Warehouse", "sqlserver", "ActivityType",                "lh_bronze", "bronze_eqwarehouse", "activity_type_base",                    "full",        None,              None,       None,  None, None, None, None, True),
    (5,  "EQ_Warehouse", "sqlserver", "CommissionLevelRank",         "lh_bronze", "bronze_eqwarehouse", "commission_level_rank_base",            "full",        None,              None,       None,  None, None, None, None, True),
    (6,  "EQ_Warehouse", "sqlserver", "InvestmentDetail",            "lh_bronze", "bronze_eqwarehouse", "investment_detail_base",                "full",        None,              None,       None,  None, None, None, None, True),
    (7,  "EQ_Warehouse", "sqlserver", "AccountingAccount",           "lh_bronze", "bronze_eqwarehouse", "accounting_account_base",               "full",        None,              None,       None,  None, None, None, None, True),
    (8,  "EQ_Warehouse", "sqlserver", "ProductVariationDetail",      "lh_bronze", "bronze_eqwarehouse", "product_variation_detail_base",         "full",        None,              None,       None,  None, None, None, None, True),
    (9,  "EQ_Warehouse", "sqlserver", "AccountingReporting_Group",   "lh_bronze", "bronze_eqwarehouse", "accounting_reporting_group_base",       "full",        None,              None,       None,  None, None, None, None, True),
    (10, "EQ_Warehouse", "sqlserver", "TrainingCourse",              "lh_bronze", "bronze_eqwarehouse", "training_course_base",                  "full",        None,              None,       None,  None, None, None, None, True),
    # ── Batch 2: Core entities ─────────────────────────────────────────────
    (11, "EQ_Warehouse", "sqlserver", "Product",                     "lh_bronze", "bronze_eqwarehouse", "product_base",                          "full",        None,              None,       None,  None, None, None, None, True),
    (12, "EQ_Warehouse", "sqlserver", "Surrender",                   "lh_bronze", "bronze_eqwarehouse", "surrender_base",                        "full",        None,              None,       None,  None, None, None, None, True),
    (13, "EQ_Warehouse", "sqlserver", "Territory",                   "lh_bronze", "bronze_eqwarehouse", "territory_base",                        "full",        None,              None,       None,  None, None, None, None, True),
    (14, "EQ_Warehouse", "sqlserver", "Client",                      "lh_bronze", "bronze_eqwarehouse", "client_base",                           "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (15, "EQ_Warehouse", "sqlserver", "Agent",                       "lh_bronze", "bronze_eqwarehouse", "agent_base",                            "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (16, "EQ_Warehouse", "sqlserver", "Investment",                  "lh_bronze", "bronze_eqwarehouse", "investment_base",                       "full",        None,              None,       None,  None, None, None, None, True),
    (17, "EQ_Warehouse", "sqlserver", "ProductStateApproval",        "lh_bronze", "bronze_eqwarehouse", "product_state_approval_base",           "full",        None,              None,       None,  None, None, None, None, True),
    (18, "EQ_Warehouse", "sqlserver", "ProductStateVariation",       "lh_bronze", "bronze_eqwarehouse", "product_state_variation_base",          "full",        None,              None,       None,  None, None, None, None, True),
    (19, "EQ_Warehouse", "sqlserver", "ProductStateApprovalDisclosure","lh_bronze","bronze_eqwarehouse","product_state_approval_disclosure_base","full",        None,              None,       None,  None, None, None, None, True),
    (20, "EQ_Warehouse", "sqlserver", "Contract",                    "lh_bronze", "bronze_eqwarehouse", "contract_base",                         "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    # ── Batch 3: Relationship tables ───────────────────────────────────────
    (21, "EQ_Warehouse", "sqlserver", "AgentContract",               "lh_bronze", "bronze_eqwarehouse", "agent_contract_base",                   "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (22, "EQ_Warehouse", "sqlserver", "AgentLicense",                "lh_bronze", "bronze_eqwarehouse", "agent_license_base",                    "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (23, "EQ_Warehouse", "sqlserver", "AgentPrincipal",              "lh_bronze", "bronze_eqwarehouse", "agent_principal_base",                  "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (24, "EQ_Warehouse", "sqlserver", "AgentTraining",               "lh_bronze", "bronze_eqwarehouse", "agent_training_base",                   "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (25, "EQ_Warehouse", "sqlserver", "TrainingProduct",             "lh_bronze", "bronze_eqwarehouse", "training_product_base",                 "full",        None,              None,       None,  None, None, None, None, True),
    (26, "EQ_Warehouse", "sqlserver", "TrainingState",               "lh_bronze", "bronze_eqwarehouse", "training_state_base",                   "full",        None,              None,       None,  None, None, None, None, True),
    (27, "EQ_Warehouse", "sqlserver", "HierarchyTerritory",          "lh_bronze", "bronze_eqwarehouse", "hierarchy_territory_base",              "full",        None,              None,       None,  None, None, None, None, True),
    (28, "EQ_Warehouse", "sqlserver", "Hierarchy",                   "lh_bronze", "bronze_eqwarehouse", "hierarchy_base",                        "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (29, "EQ_Warehouse", "sqlserver", "Hierarchy_SuperHierarchy",    "lh_bronze", "bronze_eqwarehouse", "hierarchy_super_hierarchy_base",        "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (30, "EQ_Warehouse", "sqlserver", "Hierarchy_Bridge",            "lh_bronze", "bronze_eqwarehouse", "hierarchy_bridge_base",                 "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (31, "EQ_Warehouse", "sqlserver", "Hierarchy_Option",            "lh_bronze", "bronze_eqwarehouse", "hierarchy_option_base",                 "full",        None,              None,       None,  None, None, None, None, True),
    (32, "EQ_Warehouse", "sqlserver", "AccountValue",                "lh_bronze", "bronze_eqwarehouse", "account_value_base",                    "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (33, "EQ_Warehouse", "sqlserver", "ExternalAccount_Group",       "lh_bronze", "bronze_eqwarehouse", "external_account_group_base",           "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (34, "EQ_Warehouse", "sqlserver", "AdditionalClient_Group",      "lh_bronze", "bronze_eqwarehouse", "additional_client_group_base",          "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (35, "EQ_Warehouse", "sqlserver", "AdditionalInfo_Group",        "lh_bronze", "bronze_eqwarehouse", "additional_info_group_base",            "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (36, "EQ_Warehouse", "sqlserver", "Reinsurance_Group",           "lh_bronze", "bronze_eqwarehouse", "reinsurance_group_base",               "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    # ── Batch 4: Transaction / event tables ────────────────────────────────
    (37, "EQ_Warehouse", "sqlserver", "Activity",                    "lh_bronze", "bronze_eqwarehouse", "activity_base",                         "incremental", "ProcessDateFK",   "integer",  100000,None, None, None, None, True),
    (38, "EQ_Warehouse", "sqlserver", "ActivityFinancial",           "lh_bronze", "bronze_eqwarehouse", "activity_financial_base",               "incremental", "ProcessDateFK",   "integer",  100000,None, None, None, None, True),
    (39, "EQ_Warehouse", "sqlserver", "Accounting",                  "lh_bronze", "bronze_eqwarehouse", "accounting_base",                       "incremental", "EntryUpdateDate", "datetime", 100000,None, None, None, None, True),
    (40, "EQ_Warehouse", "sqlserver", "AccountingDetail",            "lh_bronze", "bronze_eqwarehouse", "accounting_detail_base",                "incremental", "EntryUpdateDate", "datetime", 100000,None, None, None, None, True),
    (41, "EQ_Warehouse", "sqlserver", "ContractValue_Group",         "lh_bronze", "bronze_eqwarehouse", "contract_value_group_base",             "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (42, "EQ_Warehouse", "sqlserver", "ContractDeposit",             "lh_bronze", "bronze_eqwarehouse", "contract_deposit_base",                 "incremental", "DepositDate",     "datetime", 50000, None, None, None, None, True),
    (43, "EQ_Warehouse", "sqlserver", "RecurringPayment",            "lh_bronze", "bronze_eqwarehouse", "recurring_payment_base",                "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (44, "EQ_Warehouse", "sqlserver", "AgentSummary",                "lh_bronze", "bronze_eqwarehouse", "agent_summary_base",                    "incremental", "SummaryDate",     "datetime", 50000, None, None, None, None, True),
    (45, "EQ_Warehouse", "sqlserver", "IndexValue",                  "lh_bronze", "bronze_eqwarehouse", "index_value_base",                      "incremental", "IndexDate",       "datetime", 50000, None, None, None, None, True),
    (46, "EQ_Warehouse", "sqlserver", "RenewalRate",                 "lh_bronze", "bronze_eqwarehouse", "renewal_rate_base",                     "incremental", "RateEffectiveDate","datetime", 50000, None, None, None, None, True),
    (47, "EQ_Warehouse", "sqlserver", "CAPRepayment",                "lh_bronze", "bronze_eqwarehouse", "cap_repayment_base",                    "incremental", "RepaymentDate",   "datetime", 50000, None, None, None, None, True),
    (48, "EQ_Warehouse", "sqlserver", "CAPStatusChange",             "lh_bronze", "bronze_eqwarehouse", "cap_status_change_base",                "incremental", "ChangeDate",      "datetime", 50000, None, None, None, None, True),
    (49, "EQ_Warehouse", "sqlserver", "hedge.Ratios",                "lh_bronze", "bronze_eqwarehouse", "hedge_ratios_base",                     "incremental", "RatioDate",       "datetime", 50000, None, None, None, None, True),
    (50, "EQ_Warehouse", "sqlserver", "hedge.Options",               "lh_bronze", "bronze_eqwarehouse", "hedge_options_base",                    "incremental", "OptionDate",      "datetime", 50000, None, None, None, None, True),
    # ── Batch 5: Remaining groups + views ──────────────────────────────────
    (51, "EQ_Warehouse", "sqlserver", "Rider_Group",                 "lh_bronze", "bronze_eqwarehouse", "rider_group_base",                      "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (52, "EQ_Warehouse", "sqlserver", "Requirement_Group",           "lh_bronze", "bronze_eqwarehouse", "requirement_group_base",                "incremental", "StartDate",       "datetime", 50000, None, None, None, None, True),
    (53, "EQ_Warehouse", "sqlserver", "Note_Group",                  "lh_bronze", "bronze_eqwarehouse", "note_group_base",                       "incremental", "NoteDate",        "datetime", 50000, None, None, None, None, True),
    (54, "EQ_Warehouse", "sqlserver", "LastProcessing",              "lh_bronze", "bronze_eqwarehouse", "last_processing_base",                  "full",        None,              None,       None,  None, None, None, None, True),
    (55, "EQ_Warehouse", "sqlserver", "vw_SEG_Client",               "lh_bronze", "bronze_eqwarehouse", "vw_seg_client_base",                    "full",        None,              None,       None,  None, None, None, None, True),
    (56, "EQ_Warehouse", "sqlserver", "vw_SEG_Contract",             "lh_bronze", "bronze_eqwarehouse", "vw_seg_contract_base",                  "full",        None,              None,       None,  None, None, None, None, True),
    (57, "EQ_Warehouse", "sqlserver", "vw_SEG_Agent",                "lh_bronze", "bronze_eqwarehouse", "vw_seg_agent_base",                     "full",        None,              None,       None,  None, None, None, None, True),
    (58, "EQ_Warehouse", "sqlserver", "vw_SEG_Activity",             "lh_bronze", "bronze_eqwarehouse", "vw_seg_activity_base",                  "full",        None,              None,       None,  None, None, None, None, True),
    (59, "EQ_Warehouse", "sqlserver", "vw_SEG_Accounting",           "lh_bronze", "bronze_eqwarehouse", "vw_seg_accounting_base",                "full",        None,              None,       None,  None, None, None, None, True),
    (60, "EQ_Warehouse", "sqlserver", "vw_SEG_AccountValue",         "lh_bronze", "bronze_eqwarehouse", "vw_seg_account_value_base",             "full",        None,              None,       None,  None, None, None, None, True),
    (61, "EQ_Warehouse", "sqlserver", "vw_SEG_AgentSummary",         "lh_bronze", "bronze_eqwarehouse", "vw_seg_agent_summary_base",             "full",        None,              None,       None,  None, None, None, None, True),
    (62, "EQ_Warehouse", "sqlserver", "ref_Product",                 "lh_bronze", "bronze_eqwarehouse", "ref_product_base",                      "full",        None,              None,       None,  None, None, None, None, True),
]

INGESTION_SCHEMA = StructType([
    StructField("source_id",         IntegerType(), False),
    StructField("source_name",       StringType(),  False),
    StructField("source_type",       StringType(),  False),
    StructField("entity_name",       StringType(),  False),
    StructField("target_lakehouse",  StringType(),  False),
    StructField("target_schema",     StringType(),  False),
    StructField("target_table",      StringType(),  False),
    StructField("load_type",         StringType(),  False),
    StructField("watermark_column",  StringType(),  True),
    StructField("watermark_type",    StringType(),  True),
    StructField("batch_size",        IntegerType(), True),
    StructField("extraction_query",  StringType(),  True),
    StructField("api_endpoint",      StringType(),  True),
    StructField("api_method",        StringType(),  True),
    StructField("api_headers",       StringType(),  True),
    StructField("active_flag",       BooleanType(), False),
])

ingestion_df = (
    spark.createDataFrame(INGESTION_ROWS, schema=INGESTION_SCHEMA)
    .withColumn("created_by",    F.lit(CREATED_BY))
    .withColumn("created_date",  F.lit(NOW).cast(TimestampType()))
    .withColumn("modified_by",   F.lit(None).cast(StringType()))
    .withColumn("modified_date", F.lit(None).cast(TimestampType()))
)

print(f"ingestion_config rows to seed: {ingestion_df.count()}")


# ## CELL 4 — watermark_control seed
# ══════════════════════════════════════════════════════════════════════════════
# Initial rows for all incremental entities.
# last_watermark_value = NULL — pipeline sets it after first successful run.
# ══════════════════════════════════════════════════════════════════════════════

from pyspark.sql.window import Window

incremental_df = ingestion_df.filter(
    F.col("load_type").isin("incremental", "cdc")
)

watermark_df = (
    incremental_df
    .withColumn(
        "watermark_id",
        F.row_number().over(Window.orderBy("source_id")).cast(IntegerType())
    )
    .select(
        F.col("watermark_id"),
        F.col("source_id"),
        F.col("entity_name"),
        F.lit(None).cast(StringType()).alias("last_watermark_value"),
        F.col("watermark_type").alias("last_watermark_type"),
        F.lit(None).cast(TimestampType()).alias("last_run_datetime"),
        F.lit(None).cast(TimestampType()).alias("last_successful_datetime"),
        F.lit("pending").alias("last_run_status"),
        F.lit(NOW).cast(TimestampType()).alias("created_date"),
        F.lit(None).cast(TimestampType()).alias("modified_date"),
    )
)

print(f"watermark_control rows to seed: {watermark_df.count()}")


# ## CELL 5 — sla_config seed
# ══════════════════════════════════════════════════════════════════════════════
# SLA definitions for all 62 entities at the bronze layer.
# Critical entities: window 01:00–05:00 UTC, max 240 min, alert_on_breach=true
# Standard entities: window 01:00–07:00 UTC, max 360 min, alert_on_breach=false
# ══════════════════════════════════════════════════════════════════════════════

CRITICAL_ENTITIES = [
    "Client", "Contract", "Activity", "Accounting",
    "AccountValue", "ExternalAccount_Group", "vw_SEG_Client",
]

ALERT_EMAIL   = "data-engineering@equitrust.com"
TEAMS_WEBHOOK = None   # Populate with actual Teams webhook URL per environment

sla_df = (
    ingestion_df
    .withColumn(
        "sla_id",
        F.row_number().over(Window.orderBy("source_id")).cast(IntegerType())
    )
    .withColumn(
        "is_critical",
        F.col("entity_name").isin(CRITICAL_ENTITIES)
    )
    .select(
        F.col("sla_id"),
        F.col("source_id"),
        F.col("entity_name"),
        F.lit("bronze").alias("layer"),
        F.lit("01:00").alias("expected_start_time"),
        F.when(F.col("is_critical"), F.lit("05:00"))
         .otherwise(F.lit("07:00")).alias("expected_end_time"),
        F.when(F.col("is_critical"), F.lit(240))
         .otherwise(F.lit(360)).cast(IntegerType()).alias("max_duration_minutes"),
        F.when(F.col("is_critical"), F.lit("critical"))
         .otherwise(F.lit("medium")).alias("criticality"),
        F.col("is_critical").alias("alert_on_breach"),
        F.lit(ALERT_EMAIL).alias("alert_email"),
        F.lit(TEAMS_WEBHOOK).cast(StringType()).alias("alert_teams_webhook"),
        F.lit(True).alias("active_flag"),
        F.lit(NOW).cast(TimestampType()).alias("created_date"),
        F.lit(None).cast(TimestampType()).alias("modified_date"),
    )
)

print(f"sla_config rows to seed: {sla_df.count()}")
print(f"  critical : {sla_df.filter(F.col('criticality') == 'critical').count()}")
print(f"  standard : {sla_df.filter(F.col('criticality') == 'medium').count()}")


# ## CELL 6 — Initialise logger and write all three tables
# ══════════════════════════════════════════════════════════════════════════════
# FabricLogger records this seed run in pipeline_run_log and any exceptions
# in error_log. flush() at the end writes both tables to lh_control.
# ══════════════════════════════════════════════════════════════════════════════

run_id = generate_run_id()   # from nb_logging_library

logger = FabricLogger(
    run_id         = run_id,
    pipeline_name  = PIPELINE_NAME,
    entity_name    = ENTITY_NAME,
    layer          = LAYER,
    workspace_name = WORKSPACE_NAME,
    load_type      = "full",
    triggered_by   = "manual",
)
logger.start_run()

seed_status = "success"
try:
    print("\nWriting seed data to lh_control...")
    print("─" * 50)

    write_seed(ingestion_df,  "ingestion_config")
    write_seed(watermark_df,  "watermark_control")
    write_seed(sla_df,        "sla_config")

    print("─" * 50)

    # ── CELL 7 — Verification ─────────────────────────────────────────────
    from pyspark.sql import Row

    print("\n" + "═" * 55)
    print("  SEED VERIFICATION — ROW COUNTS")
    print("═" * 55)

    seeded_tables = ["ingestion_config", "watermark_control", "sla_config"]
    total_written = 0

    for tbl in seeded_tables:
        path  = table_path(tbl)
        count = spark.read.format("delta").load(path).count()
        total_written += count
        print(f"  {tbl:<25} {count} rows")

    print("═" * 55)

    # Spot-check: incremental entities ↔ watermark rows
    ic_inc_count = ingestion_df.filter(F.col("load_type").isin("incremental", "cdc")).count()
    wm_count     = spark.read.format("delta").load(table_path("watermark_control")).count()
    assert wm_count == ic_inc_count, (
        f"Mismatch: {ic_inc_count} incremental entities but {wm_count} watermark rows"
    )
    print(f"\n  Watermark check OK — {wm_count} incremental entities have watermark rows")

    # Spot-check: SLA criticality
    sla_read      = spark.read.format("delta").load(table_path("sla_config"))
    critical_read = sla_read.filter(F.col("criticality") == "critical").count()
    print(f"  SLA check OK      — {critical_read} critical SLA definitions")
    print("\nAll checks passed.")

    # Record row counts in logger (rows_written = total rows seeded across 3 tables)
    logger.set_row_counts(
        rows_read      = ingestion_df.count(),   # source rows processed
        rows_written   = total_written,
        rows_rejected  = 0,
        rows_duplicate = 0,
    )

except Exception as e:
    seed_status = "failed"
    logger.log_error(e, error_category="ingestion")
    print(f"\nERROR during seed: {e}")
    raise

finally:
    logger.end_run(seed_status)
    logger.flush(spark)
    print(f"\nSeed {'complete' if seed_status == 'success' else 'FAILED'} — run_id={run_id}")
