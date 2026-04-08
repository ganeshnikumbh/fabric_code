# Notebook: nb_silver_s1_investment
# Layer: SILVER S1
# Purpose: SCD Type 2 for silver_s1.investment.
# Parameters: data_date, run_id, environment
# Environment: __ENVIRONMENT__ | Storage: __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F
from delta.tables import DeltaTable

%run nb_logging_library

data_date   = dbutils.widgets.get("data_date")
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/investment_base"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/investment"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(run_id=run_id, layer="silver_s1", object_name="investment", environment=ENVIRONMENT)

HASH_COLUMNS = [
    "investment_code", "investment_name", "investment_type_code",
    "fund_family", "ticker_symbol", "inception_date", "is_active",
]

logger.info(f"Reading bronze_eqwarehouse.investment_base for data_date={data_date}")
bronze_df = (
    spark.read.format("delta").load(BRONZE_PATH)
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("after_bronze_read", bronze_df.count())

cleansed_df = (
    bronze_df
    .withColumn("investment_type_code", F.upper(F.trim(F.col("investment_type_code"))))
    .withColumn("investment_code",      F.upper(F.trim(F.col("investment_code"))))
    .withColumn("investment_name",      F.trim(F.col("investment_name")))
    .withColumn("ticker_symbol",        F.upper(F.trim(F.col("ticker_symbol"))))
    .withColumn("investment_type_code", F.coalesce(F.col("investment_type_code"), F.lit("UNKNOWN")))
    .withColumn("investment_code",      F.coalesce(F.col("investment_code"), F.lit("UNKNOWN")))
    .withColumn("investment_name",      F.coalesce(F.col("investment_name"), F.lit("unknown")))
    .withColumn("is_active",            F.coalesce(F.col("is_active"), F.lit(False)))
)
logger.record_count("after_cleanse", cleansed_df.count())

hash_input_expr = F.concat_ws(
    "||",
    *[F.coalesce(F.col(c).cast("string"), F.lit("__NULL__")) for c in HASH_COLUMNS]
)
cleansed_df = cleansed_df.withColumn("md5_hash", F.md5(hash_input_expr))

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

logger.info("Executing Delta merge (SCD2) into silver_s1.investment")
silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

silver_table.alias("t").merge(
    incoming_df.alias("s"),
    "t.investment_id = s.investment_id AND t.is_current = true"
).whenMatchedUpdate(
    condition="t.md5_hash <> s.md5_hash",
    set={"is_current": F.lit(False), "expiration_date": F.lit(TODAY).cast("date")}
).execute()

(
    incoming_df
    .join(silver_table.toDF().filter("is_current = true").select("investment_id"), "investment_id", "left_anti")
    .write.format("delta").mode("append").save(SILVER_S1_PATH)
)

final_count = spark.read.format("delta").load(SILVER_S1_PATH).filter("is_current = true").count()
logger.record_count("silver_s1_current_records", final_count)
logger.info(f"silver_s1.investment SCD2 complete — {final_count:,} current records")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
