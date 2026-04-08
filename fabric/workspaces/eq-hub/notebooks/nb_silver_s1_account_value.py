# Notebook: nb_silver_s1_account_value
# Layer: SILVER S1
# Purpose: SCD Type 2 for silver_s1.account_value.
#          0% quarantine threshold — any rejection fails the pipeline.
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
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/account_value_base"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/account_value"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(run_id=run_id, layer="silver_s1", object_name="account_value", environment=ENVIRONMENT)

HASH_COLUMNS = [
    "contract_id", "investment_id", "valuation_date",
    "account_value_amount", "surrender_value_amount",
    "units", "unit_value", "interest_rate", "value_type_code",
]

logger.info(f"Reading bronze_eqwarehouse.account_value_base for data_date={data_date}")
bronze_df = (
    spark.read.format("delta").load(BRONZE_PATH)
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("after_bronze_read", bronze_df.count())

cleansed_df = (
    bronze_df
    .withColumn("value_type_code",        F.upper(F.trim(F.col("value_type_code"))))
    .withColumn("value_type_code",        F.coalesce(F.col("value_type_code"), F.lit("UNKNOWN")))
    .withColumn("account_value_amount",   F.round(F.col("account_value_amount"), 4))
    .withColumn("surrender_value_amount", F.round(F.col("surrender_value_amount"), 4))
    .withColumn("units",                  F.round(F.col("units"), 6))
    .withColumn("unit_value",             F.round(F.col("unit_value"), 6))
    .withColumn("interest_rate",          F.round(F.col("interest_rate"), 6))
    # 0.0 for NULL financial amounts — absence of value = 0 for account valuation
    .withColumn("account_value_amount",   F.coalesce(F.col("account_value_amount"),   F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("surrender_value_amount", F.coalesce(F.col("surrender_value_amount"), F.lit(0.0).cast("decimal(18,4)")))
    .withColumn("units",                  F.coalesce(F.col("units"),                  F.lit(0.0).cast("decimal(18,6)")))
    .withColumn("unit_value",             F.coalesce(F.col("unit_value"),             F.lit(0.0).cast("decimal(18,6)")))
    .withColumn("interest_rate",          F.coalesce(F.col("interest_rate"),          F.lit(0.0).cast("decimal(10,6)")))
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

logger.info("Executing Delta merge (SCD2) into silver_s1.account_value")
silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

silver_table.alias("t").merge(
    incoming_df.alias("s"),
    "t.account_value_id = s.account_value_id AND t.is_current = true"
).whenMatchedUpdate(
    condition="t.md5_hash <> s.md5_hash",
    set={"is_current": F.lit(False), "expiration_date": F.lit(TODAY).cast("date")}
).execute()

(
    incoming_df
    .join(silver_table.toDF().filter("is_current = true").select("account_value_id"), "account_value_id", "left_anti")
    .write.format("delta").mode("append").save(SILVER_S1_PATH)
)

final_count = spark.read.format("delta").load(SILVER_S1_PATH).filter("is_current = true").count()
logger.record_count("silver_s1_current_records", final_count)
logger.info(f"silver_s1.account_value SCD2 complete — {final_count:,} current records")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
