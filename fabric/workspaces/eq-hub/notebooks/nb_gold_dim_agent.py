# Notebook: nb_gold_dim_agent
# Layer: GOLD
# Purpose: Builds dim_agent from silver_s1.agent (is_current=true).
#          Generates surrogate key (agent_key) via row_number() window function.
#          Full overwrite — dimensions have no partition; full replace on each run.
#          OPTIMIZE ZORDER applied after write.
#
# Parameters (passed by orchestration pipeline):
#   run_id        : STRING — UUID shared across all tables in this pipeline run
#   environment   : STRING — dev | qa | tst | prod
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F
from pyspark.sql.window import Window

%run nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/agent"
GOLD_PATH        = f"abfss://gold@{STORAGE_ACCOUNT}.dfs.core.windows.net/dim_agent"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="gold",
    object_name="dim_agent",
    environment=ENVIRONMENT,
)

# ─── Step 1: Read Silver S1 agent (current records only) ─────────────────────
logger.info("Reading silver_s1.agent is_current=true")

agent_df = (
    spark.read.format("delta")
    .load(SILVER_S1_PATH)
    .filter(F.col("is_current") == True)
    .select(
        "agent_id",
        "agent_number",
        "client_id",
        "display_name",
        "national_producer_number",
        "nasd_finra_number",
        "agent_type_code",
        "hire_date",
        "termination_date",
        "status_code",
        "effective_date",       # SCD2 effective date — when current version became active
    )
)
logger.record_count("silver_s1_agent_current", agent_df.count())

# ─── Step 2: Add unknown member row (agent_key = -1) ─────────────────────────
# Gold standard: unknown dimension members get surrogate key -1 (not NULL)
# This ensures fact table foreign keys never contain NULL values
unknown_member = spark.createDataFrame([
    (-1, "UNKNOWN", None, "Unknown Agent", None, None, "UNKNOWN", None, None, "UNKNOWN", None)
], schema=agent_df.schema)

agent_with_unknown = unknown_member.union(agent_df)

# ─── Step 3: Generate surrogate key ──────────────────────────────────────────
logger.info("Generating surrogate key agent_key via row_number()")

# Unknown member already has -1; assign positive surrogate keys to all others
agent_known = agent_df.withColumn(
    "agent_key",
    F.row_number().over(Window.orderBy("agent_id"))
)

unknown_row = spark.createDataFrame([{
    "agent_key": -1,
    "agent_id": -1,
    "agent_number": "UNKNOWN",
    "client_id": None,
    "display_name": "Unknown Agent",
    "national_producer_number": None,
    "nasd_finra_number": None,
    "agent_type_code": "UNKNOWN",
    "hire_date": None,
    "termination_date": None,
    "status_code": "UNKNOWN",
    "effective_date": None,
}])

dim_agent_df = (
    unknown_row
    .union(agent_known)
    .withColumn("dw_created_date", F.lit(TODAY).cast("date"))
    .withColumn("dw_source_system", F.lit("eqwarehouse"))
    .withColumn("dw_run_id", F.lit(run_id))
    .select(
        "agent_key",
        "agent_id",
        "agent_number",
        "client_id",
        "display_name",
        "national_producer_number",
        "nasd_finra_number",
        "agent_type_code",
        "hire_date",
        "termination_date",
        "status_code",
        "effective_date",
        "dw_created_date",
        "dw_source_system",
        "dw_run_id",
    )
)

logger.record_count("dim_agent_rows", dim_agent_df.count())

# ─── Step 4: Full overwrite (no partition on dimensions) ─────────────────────
logger.info("Writing dim_agent — full overwrite")

(
    dim_agent_df
    .write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "false")
    .save(GOLD_PATH)
)

# ─── Step 5: Optimize (Z-order) ──────────────────────────────────────────────
logger.info("Running OPTIMIZE ZORDER on gold.dim_agent")
spark.sql(f"OPTIMIZE delta.`{GOLD_PATH}` ZORDER BY (agent_id, agent_number, status_code)")

final_count = spark.read.format("delta").load(GOLD_PATH).count()
logger.record_count("dim_agent_final", final_count)
logger.info(f"gold.dim_agent complete — {final_count:,} rows (including unknown member)")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
