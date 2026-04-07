# Notebook: nb_seed_control_tables
# Purpose:  Seeds the lh_control ingestion framework tables with initial data.
#           Reads source data from ingestion_config.csv and writes three tables:
#             - ingestion_config   : one row per EQ_Warehouse source entity (62 rows)
#             - watermark_control  : initial pending rows for all incremental entities
#             - sla_config         : SLA definitions per entity (critical vs standard)
#
#           Idempotent — overwrite mode, safe to re-run.
#
# Pre-requisite: Attach lh_control as the default lakehouse before running.
#                Explorer pane → Add lakehouse → lh_control → Confirm
#
#                Upload fabric/config/seed_data/ingestion_config.csv to:
#                lh_control → Files → seed_data → ingestion_config.csv
#
# Run order: Run AFTER nb_control_audit_ddl (tables must exist first).

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

ONELAKE_HOST   = "onelake.dfs.fabric.microsoft.com"
BASE_PATH      = (
    f"abfss://{WORKSPACE_NAME}@{ONELAKE_HOST}"
    f"/{LAKEHOUSE_NAME}.Lakehouse/Files/control_tables"
)

# CSV lives in lh_control Files/seed_data/ — accessible via the attached lakehouse mount
CSV_PATH = "/lakehouse/default/Files/seed_data/ingestion_config.csv"

print(f"Workspace  : {WORKSPACE_NAME}")
print(f"Lakehouse  : {LAKEHOUSE_NAME}")
print(f"Base path  : {BASE_PATH}")
print(f"CSV path   : {CSV_PATH}")


# ## CELL 2 — Helpers
# ══════════════════════════════════════════════════════════════════════════════

from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType, StringType, BooleanType, TimestampType
from datetime import datetime, timezone

NOW = datetime.now(timezone.utc)


def table_path(table_name: str) -> str:
    return f"{BASE_PATH}/{table_name}"


def write_seed(df, table_name: str) -> None:
    path  = table_path(table_name)
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
        raise RuntimeError(
            f"Row count mismatch for {table_name}: wrote {count}, found {verified}"
        )


# ## CELL 3 — Load ingestion_config from CSV
# ══════════════════════════════════════════════════════════════════════════════
# Reads fabric/config/seed_data/ingestion_config.csv (uploaded to lh_control
# Files/seed_data/ before running this notebook).
# All columns arrive as strings; coerce types explicitly below.
# ══════════════════════════════════════════════════════════════════════════════

raw_df = (
    spark.read
    .option("header", "true")
    .option("inferSchema", "false")      # keep everything as string first
    .option("nullValue", "")             # empty CSV cells → null
    .csv(CSV_PATH)
)

print(f"Loaded {raw_df.count()} rows from CSV")
raw_df.printSchema()

# ── Type coercions ────────────────────────────────────────────────────────────
ingestion_df = (
    raw_df
    # Numeric columns
    .withColumn("source_id",   F.col("source_id").cast(IntegerType()))
    .withColumn("batch_size",  F.col("batch_size").cast(IntegerType()))
    # Boolean
    .withColumn("active_flag", F.col("active_flag").cast(BooleanType()))
    # Nullify empty watermark fields (already handled by nullValue option,
    # but guard in case of whitespace-only values)
    .withColumn("watermark_column", F.when(
        F.trim(F.col("watermark_column")) == "", F.lit(None)
    ).otherwise(F.col("watermark_column")))
    .withColumn("watermark_type", F.when(
        F.trim(F.col("watermark_type")) == "", F.lit(None)
    ).otherwise(F.col("watermark_type")))
    # System-managed columns added by the notebook
    .withColumn("created_by",    F.lit(CREATED_BY))
    .withColumn("created_date",  F.lit(NOW).cast(TimestampType()))
    .withColumn("modified_by",   F.lit(None).cast(StringType()))
    .withColumn("modified_date", F.lit(None).cast(TimestampType()))
)

print(f"ingestion_config rows to seed: {ingestion_df.count()}")


# ## CELL 4 — watermark_control seed
# ══════════════════════════════════════════════════════════════════════════════
# Initial rows for all incremental/cdc entities.
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


# ## CELL 6 — Write all three tables
# ══════════════════════════════════════════════════════════════════════════════

print("\nWriting seed data to lh_control...")
print("─" * 50)

write_seed(ingestion_df, "ingestion_config")
write_seed(watermark_df, "watermark_control")
write_seed(sla_df,       "sla_config")

print("─" * 50)
print("Seed complete.")


# ## CELL 7 — Verification
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 55)
print("  SEED VERIFICATION — ROW COUNTS")
print("═" * 55)

for tbl in ["ingestion_config", "watermark_control", "sla_config"]:
    count = spark.read.format("delta").load(table_path(tbl)).count()
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
