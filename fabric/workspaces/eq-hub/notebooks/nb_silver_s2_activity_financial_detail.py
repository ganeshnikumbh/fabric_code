# Notebook: nb_silver_s2_activity_financial_detail
# Layer: SILVER S2
# Purpose: Joins silver_s1.activity (is_current=true) with bronze_eqwarehouse.activity_financial_base.
#          LEFT join — not all activities have financial detail.
#          NULL financial amounts coalesced to 0.0.
#          Write mode: replaceWhere on data_date partition.
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

STORAGE_ACCOUNT    = "__STORAGE_ACCOUNT__"
SILVER_S1_PATH     = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1"
BRONZE_PATH        = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse"
SILVER_S2_PATH     = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s2/activity_financial_detail"
AUDIT_TABLE_PATH   = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY              = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="silver_s2",
    object_name="activity_financial_detail",
    environment=ENVIRONMENT,
)

# ─── Step 1: Read Silver S1 activity (current records) ───────────────────────
logger.info(f"Reading silver_s1.activity is_current=true for data_date={data_date}")

activity_df = (
    spark.read.format("delta")
    .load(f"{SILVER_S1_PATH}/activity")
    .filter(F.col("is_current") == True)
    .filter(F.col("data_date") == data_date)
    .select(
        "activity_id", "contract_id", "activity_type_id", "process_date_key",
        "effective_date_activity", "transaction_date", "amount", "units",
        "text_value", "distribution_type_code", "is_reversal", "reversal_activity_id",
        "is_processed",
    )
)
logger.record_count("activity_current_read", activity_df.count())

# ─── Step 2: Read Bronze activity_financial_base ──────────────────────────────
logger.info(f"Reading bronze_eqwarehouse.activity_financial_base for data_date={data_date}")

fin_df = (
    spark.read.format("delta")
    .load(f"{BRONZE_PATH}/activity_financial_base")
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
    .select(
        "activity_id",
        F.col("activity_financial_id"),
        "gross_amount",
        "federal_withholding_amount",
        "state_withholding_amount",
        F.col("net_amount").alias("net_financial_amount"),
        "penalty_amount",
        "surrender_charge_amount",
        "market_value_adjustment",
    )
)
logger.record_count("activity_financial_read", fin_df.count())

# ─── Step 3: LEFT JOIN activity + financial detail ────────────────────────────
# LEFT join — not all activities have financial detail (informational activities have none)
logger.info("Joining activity with financial detail (LEFT JOIN)")

joined_df = (
    activity_df.alias("act")
    .join(fin_df.alias("fin"), on="activity_id", how="left")
    # Coalesce NULL financial amounts to 0.0 (NULL = no financial detail row, not missing data)
    .withColumn("gross_amount",               F.coalesce(F.col("fin.gross_amount"),               F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("federal_withholding_amount",  F.coalesce(F.col("fin.federal_withholding_amount"),  F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("state_withholding_amount",    F.coalesce(F.col("fin.state_withholding_amount"),    F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("net_amount",                  F.coalesce(F.col("fin.net_financial_amount"),         F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("penalty_amount",              F.coalesce(F.col("fin.penalty_amount"),              F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("surrender_charge_amount",     F.coalesce(F.col("fin.surrender_charge_amount"),     F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("market_value_adjustment",     F.coalesce(F.col("fin.market_value_adjustment"),     F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("activity_financial_id",       F.col("fin.activity_financial_id"))
    # Add audit columns
    .withColumn("data_date",        F.lit(data_date).cast("date"))
    .withColumn("ingestion_date",   F.lit(TODAY).cast("date"))
    .withColumn("source_system",    F.lit("eqwarehouse"))
    .withColumn("ingestion_run_id", F.lit(run_id))
    .select(
        "activity_id", "contract_id", "activity_type_id", "process_date_key",
        "effective_date_activity", "transaction_date",
        "act.amount", "units", "text_value", "distribution_type_code",
        "is_reversal", "reversal_activity_id", "is_processed",
        "activity_financial_id",
        "gross_amount", "federal_withholding_amount", "state_withholding_amount",
        "net_amount", "penalty_amount", "surrender_charge_amount", "market_value_adjustment",
        "data_date", "ingestion_date", "source_system", "ingestion_run_id",
    )
)
logger.record_count("after_join", joined_df.count())

# ─── Step 4: Write to Silver S2 (replaceWhere partition) ─────────────────────
logger.info(f"Writing to silver_s2.activity_financial_detail — replaceWhere data_date={data_date}")

(
    joined_df
    .write
    .format("delta")
    .mode("overwrite")
    .option("replaceWhere", f"data_date = '{data_date}'")
    .save(SILVER_S2_PATH)
)

# ─── Step 5: Optimize (Z-order) ──────────────────────────────────────────────
logger.info("Running OPTIMIZE ZORDER on silver_s2.activity_financial_detail")
spark.sql(f"""
    OPTIMIZE delta.`{SILVER_S2_PATH}`
    WHERE data_date = '{data_date}'
    ZORDER BY (contract_id, process_date_key, activity_type_id)
""")

final_count = spark.read.format("delta").load(SILVER_S2_PATH).filter(F.col("data_date") == data_date).count()
logger.record_count("silver_s2_written", final_count)
logger.info(f"silver_s2.activity_financial_detail complete — {final_count:,} rows for {data_date}")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
