# Notebook: nb_silver_s1_activity
# Layer: SILVER S1
# Purpose: SCD Type 2 transformation for silver_s1.activity.
#          Reads bronze_eqwarehouse.activity_base for a given data_date,
#          applies cleansing/standardization, computes MD5 hash on business columns,
#          and merges into silver_s1.activity using Delta Lake SCD2 pattern.
#
# Note on monetary null handling:
#   activity.amount -> null coalesced to 0.0 (0 is a valid financial amount — e.g. informational activities)
#   This differs from unknown/missing text which defaults to 'unknown'.
#
# Parameters (passed by orchestration pipeline):
#   data_date     : DATE   — business date to process
#   run_id        : STRING — UUID shared across all tables in this pipeline run
#   environment   : STRING — dev | qa | tst | prod
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F
from delta.tables import DeltaTable

%run nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
data_date   = dbutils.widgets.get("data_date")
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/activity_base"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/activity"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="silver_s1",
    object_name="activity",
    environment=ENVIRONMENT,
)

# ─── Business columns driving MD5 hash ───────────────────────────────────────
HASH_COLUMNS_ACTIVITY = [
    "contract_id",
    "activity_type_id",
    "process_date_key",
    "effective_date_activity",
    "transaction_date",
    "amount",
    "units",
    "text_value",
    "distribution_type_code",
    "is_reversal",
    "reversal_activity_id",
    "is_processed",
]

# ─── Step 1: Read Bronze partition ────────────────────────────────────────────
logger.info(f"Reading bronze_eqwarehouse.activity_base for data_date={data_date}")

bronze_df = (
    spark.read.format("delta")
    .load(BRONZE_PATH)
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("after_bronze_read", bronze_df.count())

# ─── Step 2: Cleanse ─────────────────────────────────────────────────────────
logger.info("Applying cleansing transformations")

cleansed_df = (
    bronze_df
    .withColumn("distribution_type_code",
                F.upper(F.trim(F.col("distribution_type_code"))))
    # Round monetary amounts to 4 decimal places
    .withColumn("amount", F.round(F.col("amount"), 4))
    .withColumn("units",  F.round(F.col("units"), 6))
    # Monetary nulls → 0.0 (0 is a valid financial amount for informational activities)
    .withColumn("amount", F.coalesce(F.col("amount"), F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("units",  F.coalesce(F.col("units"),  F.lit(0.0).cast("decimal(18,6)")))
    # Text null → 'unknown'
    .withColumn("text_value",              F.coalesce(F.col("text_value"), F.lit("unknown")))
    .withColumn("distribution_type_code",  F.coalesce(F.col("distribution_type_code"), F.lit("UNKNOWN")))
    # Boolean nulls → false
    .withColumn("is_reversal",   F.coalesce(F.col("is_reversal"),   F.lit(False)))
    .withColumn("is_processed",  F.coalesce(F.col("is_processed"),  F.lit(False)))
)

logger.record_count("after_cleanse", cleansed_df.count())

# ─── Step 3: Compute MD5 hash ─────────────────────────────────────────────────
hash_input_expr = F.concat_ws(
    "||",
    *[F.coalesce(F.col(c).cast("string"), F.lit("__NULL__")) for c in HASH_COLUMNS_ACTIVITY]
)
cleansed_df = cleansed_df.withColumn("md5_hash", F.md5(hash_input_expr))

# ─── Step 4: Add SCD2 and audit columns ──────────────────────────────────────
incoming_df = (
    cleansed_df
    .withColumn("effective_date",   F.lit(TODAY).cast("date"))
    .withColumn("expiration_date",  F.lit(None).cast("date"))
    .withColumn("is_current",       F.lit(True))
    .withColumn("ingestion_date",   F.lit(TODAY).cast("date"))
    .withColumn("data_date",        F.lit(data_date).cast("date"))
    .withColumn("source_system",    F.lit("eqwarehouse"))
    .withColumn("ingestion_run_id", F.lit(run_id))
)

# ─── Step 5: Delta Merge (SCD2) ───────────────────────────────────────────────
logger.info("Executing Delta merge (SCD2) into silver_s1.activity")

silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

silver_table.alias("target").merge(
    incoming_df.alias("source"),
    condition="target.activity_id = source.activity_id AND target.is_current = true"
).whenMatchedUpdate(
    condition="target.md5_hash <> source.md5_hash",
    set={
        "is_current":       F.lit(False),
        "expiration_date":  F.lit(TODAY).cast("date"),
    }
).execute()

logger.info("SCD2 merge step 1 complete — closed changed records")

(
    incoming_df
    .join(
        silver_table.toDF().filter("is_current = true").select("activity_id"),
        on="activity_id",
        how="left_anti"
    )
    .write
    .format("delta")
    .mode("append")
    .save(SILVER_S1_PATH)
)

logger.info("SCD2 merge step 2 complete — inserted new/changed versions")

# ─── Step 6: Verify ──────────────────────────────────────────────────────────
final_count = (
    spark.read.format("delta").load(SILVER_S1_PATH)
    .filter(F.col("is_current") == True)
    .count()
)
logger.record_count("silver_s1_current_records", final_count)
logger.info(f"silver_s1.activity SCD2 complete — {final_count:,} current records")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
