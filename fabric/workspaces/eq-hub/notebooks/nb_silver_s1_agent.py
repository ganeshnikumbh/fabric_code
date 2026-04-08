# Notebook: nb_silver_s1_agent
# Layer: SILVER S1
# Purpose: SCD Type 2 transformation for silver_s1.agent.
#          Reads bronze_eqwarehouse.agent_base for a given data_date,
#          applies cleansing, computes MD5 hash on 9 business columns,
#          and merges into silver_s1.agent using Delta Lake SCD2 pattern.
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
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/agent_base"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/agent"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="silver_s1",
    object_name="agent",
    environment=ENVIRONMENT,
)

# ─── Business columns driving MD5 hash ───────────────────────────────────────
HASH_COLUMNS_AGENT = [
    "agent_number",
    "client_id",
    "display_name",
    "national_producer_number",
    "nasd_finra_number",
    "agent_type_code",
    "hire_date",
    "termination_date",
    "status_code",
]

# ─── Step 1: Read Bronze partition ────────────────────────────────────────────
logger.info(f"Reading bronze_eqwarehouse.agent_base for data_date={data_date}")

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
    .withColumn("agent_number",     F.upper(F.trim(F.col("agent_number"))))
    .withColumn("status_code",      F.upper(F.trim(F.col("status_code"))))
    .withColumn("agent_type_code",  F.upper(F.trim(F.col("agent_type_code"))))
    # Remove all whitespace from regulatory IDs
    .withColumn("national_producer_number",
                F.regexp_replace(F.col("national_producer_number"), r"\s+", ""))
    .withColumn("nasd_finra_number",
                F.regexp_replace(F.col("nasd_finra_number"), r"\s+", ""))
    .withColumn("display_name",     F.trim(F.col("display_name")))
    # Null defaulting
    .withColumn("status_code",      F.coalesce(F.col("status_code"), F.lit("UNKNOWN")))
    .withColumn("agent_type_code",  F.coalesce(F.col("agent_type_code"), F.lit("UNKNOWN")))
    .withColumn("agent_number",     F.coalesce(F.col("agent_number"), F.lit("UNKNOWN")))
    .withColumn("display_name",     F.coalesce(F.col("display_name"), F.lit("unknown")))
)

logger.record_count("after_cleanse", cleansed_df.count())

# ─── Step 3: Compute MD5 hash ─────────────────────────────────────────────────
hash_input_expr = F.concat_ws(
    "||",
    *[F.coalesce(F.col(c).cast("string"), F.lit("__NULL__")) for c in HASH_COLUMNS_AGENT]
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
logger.info("Executing Delta merge (SCD2) into silver_s1.agent")

silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

silver_table.alias("target").merge(
    incoming_df.alias("source"),
    condition="target.agent_id = source.agent_id AND target.is_current = true"
).whenMatchedUpdate(
    condition="target.md5_hash <> source.md5_hash",
    set={
        "is_current":       F.lit(False),
        "expiration_date":  F.lit(TODAY).cast("date"),
    }
).execute()

logger.info("SCD2 merge step 1 complete — closed changed records")

# Insert new versions (net-new + changed)
(
    incoming_df
    .join(
        silver_table.toDF().filter("is_current = true").select("agent_id"),
        on="agent_id",
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
logger.info(f"silver_s1.agent SCD2 complete — {final_count:,} current records")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
