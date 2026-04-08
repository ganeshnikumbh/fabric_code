# Notebook: nb_gold_fact_activity
# Layer: GOLD
# Purpose: Builds fact_activity from silver_s2.activity_financial_detail.
#          Joins all 6 Gold dimensions to resolve surrogate keys.
#          Unknown dimension members → -1 (never NULL — star schema integrity).
#          Write mode: replaceWhere on data_date partition.
#          OPTIMIZE ZORDER applied after write.
#
# Grain: one row per activity event (activity_id is unique)
#
# Parameters (passed by orchestration pipeline):
#   data_date     : DATE   — business date to process
#   run_id        : STRING — UUID shared across all tables in this pipeline run
#   environment   : STRING — dev | qa | tst | prod
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F

%run nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
data_date   = dbutils.widgets.get("data_date")
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
SILVER_S2_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s2"
GOLD_BASE_PATH   = f"abfss://gold@{STORAGE_ACCOUNT}.dfs.core.windows.net"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="gold",
    object_name="fact_activity",
    environment=ENVIRONMENT,
)


def read_dim(dim_name: str, key_col: str, id_col: str) -> "DataFrame":
    """Read a Gold dimension, selecting only surrogate key + natural key for joining."""
    return (
        spark.read.format("delta")
        .load(f"{GOLD_BASE_PATH}/{dim_name}")
        .select(F.col(key_col), F.col(id_col))
    )


# ─── Step 1: Read Silver S2 ───────────────────────────────────────────────────
logger.info(f"Reading silver_s2.activity_financial_detail for data_date={data_date}")

s2_df = (
    spark.read.format("delta")
    .load(f"{SILVER_S2_PATH}/activity_financial_detail")
    .filter(F.col("data_date") == data_date)
)
logger.record_count("silver_s2_read", s2_df.count())

# ─── Step 2: Read dimension tables ───────────────────────────────────────────
logger.info("Reading Gold dimension tables for surrogate key resolution")

dim_contract_df     = read_dim("dim_contract",      "contract_key",      "contract_id")
dim_agent_df        = read_dim("dim_agent",          "agent_key",         "agent_id")
dim_date_df         = read_dim("dim_date",           "date_key",          "date_key")
dim_activity_type_df = read_dim("dim_activity_type", "activity_type_key", "activity_type_id")
dim_product_df      = read_dim("dim_product",        "product_key",       "product_id")

# For contract → agent mapping, we need the agent on the contract
# Read contract agent mapping from silver_s1 (agent_contract relationship)
agent_contract_df = (
    spark.read.format("delta")
    .load(f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/agent_contract_base")
    .filter(F.col("is_primary") == True)
    .filter(F.col("data_date") == data_date)
    .select("contract_id", "agent_id")
)

# ─── Step 3: Resolve surrogate keys ──────────────────────────────────────────
# Unknown dimension members → -1 (coalesce ensures no NULLs in fact foreign keys)
logger.info("Resolving surrogate keys — unknown members → -1")

fact_df = (
    s2_df.alias("f")
    # contract_key
    .join(dim_contract_df.alias("dc"),
          s2_df.contract_id == dim_contract_df.contract_id, "left")
    .withColumn("contract_key",
                F.coalesce(F.col("dc.contract_key"), F.lit(-1)))
    # activity_type_key
    .join(dim_activity_type_df.alias("dat"),
          s2_df.activity_type_id == dim_activity_type_df.activity_type_id, "left")
    .withColumn("activity_type_key",
                F.coalesce(F.col("dat.activity_type_key"), F.lit(-1)))
    # effective_date_key (resolve date_key from process_date_key)
    .join(dim_date_df.alias("dd"),
          s2_df.process_date_key == dim_date_df.date_key, "left")
    .withColumn("effective_date_key",
                F.coalesce(F.col("dd.date_key"), F.lit(-1)))
    # agent_key via agent_contract mapping
    .join(agent_contract_df.alias("ac"),
          s2_df.contract_id == agent_contract_df.contract_id, "left")
    .join(dim_agent_df.alias("da"),
          F.col("ac.agent_id") == dim_agent_df.agent_id, "left")
    .withColumn("agent_key",
                F.coalesce(F.col("da.agent_key"), F.lit(-1)))
    # Select final fact columns
    .select(
        F.col("f.activity_id"),
        F.col("contract_key"),
        F.col("activity_type_key"),
        F.col("effective_date_key"),
        F.col("agent_key"),
        F.col("f.amount"),
        F.col("f.units"),
        F.col("f.gross_amount"),
        F.col("f.federal_withholding_amount"),
        F.col("f.state_withholding_amount"),
        F.col("f.net_amount"),
        F.col("f.penalty_amount"),
        F.col("f.surrender_charge_amount"),
        F.col("f.market_value_adjustment"),
        F.col("f.distribution_type_code"),
        F.col("f.is_reversal"),
        F.col("f.reversal_activity_id"),
        F.col("f.is_processed"),
        F.col("f.transaction_date"),
        F.col("f.effective_date_activity"),
        F.lit(data_date).cast("date").alias("data_date"),
        F.lit(TODAY).cast("date").alias("dw_created_date"),
        F.lit("eqwarehouse").alias("dw_source_system"),
        F.lit(run_id).alias("dw_run_id"),
    )
)

# Verify no NULLs in surrogate key columns
null_key_count = fact_df.filter(
    F.col("contract_key").isNull() |
    F.col("activity_type_key").isNull() |
    F.col("effective_date_key").isNull() |
    F.col("agent_key").isNull()
).count()

if null_key_count > 0:
    logger.warning(f"Found {null_key_count} rows with NULL surrogate keys — should have resolved to -1")

logger.record_count("fact_rows_before_write", fact_df.count())

# ─── Step 4: Write (replaceWhere partition) ───────────────────────────────────
logger.info(f"Writing fact_activity — replaceWhere data_date={data_date}")

FACT_PATH = f"{GOLD_BASE_PATH}/fact_activity"

(
    fact_df
    .write
    .format("delta")
    .mode("overwrite")
    .option("replaceWhere", f"data_date = '{data_date}'")
    .save(FACT_PATH)
)

# ─── Step 5: Optimize (Z-order) ──────────────────────────────────────────────
logger.info("Running OPTIMIZE ZORDER on gold.fact_activity")
spark.sql(f"""
    OPTIMIZE delta.`{FACT_PATH}`
    WHERE data_date = '{data_date}'
    ZORDER BY (contract_key, effective_date_key, activity_type_key)
""")

final_count = spark.read.format("delta").load(FACT_PATH).filter(F.col("data_date") == data_date).count()
logger.record_count("fact_activity_written", final_count)
logger.info(f"gold.fact_activity complete — {final_count:,} rows for {data_date}")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
