# Notebook: nb_gold_dim_date
# Layer: GOLD
# Purpose: Builds dim_date from bronze_eqwarehouse.date_base (latest FULL load partition).
#          Renames date_id → date_key (natural key from source, serves as surrogate).
#          Full overwrite — no partitioning on dimension tables.
#          OPTIMIZE ZORDER applied after write.
#
# Parameters (passed by orchestration pipeline):
#   run_id        : STRING — UUID shared across all tables in this pipeline run
#   environment   : STRING — dev | qa | tst | prod
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/date_base"
GOLD_PATH        = f"abfss://gold@{STORAGE_ACCOUNT}.dfs.core.windows.net/dim_date"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="gold",
    object_name="dim_date",
    environment=ENVIRONMENT,
)

# ─── Step 1: Read latest partition of date_base ────────────────────────────
# date_base is a FULL load table — use the most recent data_date partition
logger.info("Reading latest partition of bronze_eqwarehouse.date_base")

date_base_df = spark.read.format("delta").load(BRONZE_PATH)

latest_data_date = date_base_df.agg(F.max("data_date")).collect()[0][0]
logger.info(f"Latest data_date in date_base: {latest_data_date}")

date_df = (
    date_base_df
    .filter(F.col("data_date") == latest_data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("date_base_read", date_df.count())

# ─── Step 2: Build dim_date ────────────────────────────────────────────────
# date_id (YYYYMMDD integer) serves as the natural + surrogate key for dim_date
dim_date_df = (
    date_df
    .withColumnRenamed("date_id", "date_key")  # date_id → date_key per Gold naming convention
    .select(
        "date_key",         # YYYYMMDD integer — primary key
        "full_date",        # DATE type
        "year",
        "quarter",
        "month",
        "month_name",
        "week_of_year",
        "day_of_week",
        "day_name",
        "is_weekend",
        "is_holiday",
        "fiscal_year",
        "fiscal_quarter",
        "fiscal_month",
    )
    .withColumn("dw_created_date",   F.lit(TODAY).cast("date"))
    .withColumn("dw_source_system",  F.lit("eqwarehouse"))
    .withColumn("dw_run_id",         F.lit(run_id))
)

# Add unknown date member (date_key = -1) for fact table joins where date is unknown
unknown_date = spark.createDataFrame([{
    "date_key": -1,
    "full_date": None,
    "year": -1,
    "quarter": -1,
    "month": -1,
    "month_name": "Unknown",
    "week_of_year": -1,
    "day_of_week": -1,
    "day_name": "Unknown",
    "is_weekend": None,
    "is_holiday": None,
    "fiscal_year": -1,
    "fiscal_quarter": -1,
    "fiscal_month": -1,
    "dw_created_date": TODAY,
    "dw_source_system": "eqwarehouse",
    "dw_run_id": run_id,
}])

final_dim_date = unknown_date.union(dim_date_df)
logger.record_count("dim_date_rows", final_dim_date.count())

# ─── Step 3: Full overwrite ───────────────────────────────────────────────────
logger.info("Writing gold.dim_date — full overwrite")

(
    final_dim_date
    .write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "false")
    .save(GOLD_PATH)
)

# ─── Step 4: Optimize (Z-order) ──────────────────────────────────────────────
logger.info("Running OPTIMIZE ZORDER on gold.dim_date")
spark.sql(f"OPTIMIZE delta.`{GOLD_PATH}` ZORDER BY (date_key, year, month)")

final_count = spark.read.format("delta").load(GOLD_PATH).count()
logger.record_count("dim_date_final", final_count)
logger.info(f"gold.dim_date complete — {final_count:,} rows (including unknown member)")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
