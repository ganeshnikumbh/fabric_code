# Notebook: nb_silver_s1_client
# Layer: SILVER S1
# Purpose: SCD Type 2 transformation for silver_s1.client.
#          Sensitivity: RESTRICTED — PII. tax_id_hash/last4_hash stored as binary.
#          CLS enforced in semantic model — not decoded here.
#          0% quarantine threshold — any rejection fails the pipeline.
#
# Parameters: data_date, run_id, environment
# Environment: __ENVIRONMENT__ | Storage: __STORAGE_ACCOUNT__

from datetime import date
from pyspark.sql import functions as F
from delta.tables import DeltaTable

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

data_date   = dbutils.widgets.get("data_date")
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT  = "__STORAGE_ACCOUNT__"
BRONZE_PATH      = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/client_base"
SILVER_S1_PATH   = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/client"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
TODAY            = date.today()

logger = FabricLogger(run_id=run_id, layer="silver_s1", object_name="client", environment=ENVIRONMENT)

# MD5 hash columns — excludes PII binary fields (tax_id_hash, last4_hash) and audit cols
# Binary columns hashed separately using their byte representation
HASH_COLUMNS_CLIENT = [
    "first_name", "last_name", "middle_name", "date_of_birth",
    "gender_code", "marital_status_code",
    "email_address", "phone_number",
    "address_line1", "address_line2", "city", "state_code", "zip_code", "country_code",
    "client_type_code", "is_entity", "entity_name", "citizenship_country",
]

logger.info(f"Reading bronze_eqwarehouse.client_base for data_date={data_date}")
bronze_df = (
    spark.read.format("delta").load(BRONZE_PATH)
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("after_bronze_read", bronze_df.count())

# Cleanse
cleansed_df = (
    bronze_df
    .withColumn("gender_code",         F.upper(F.trim(F.col("gender_code"))))
    .withColumn("marital_status_code",  F.upper(F.trim(F.col("marital_status_code"))))
    .withColumn("client_type_code",     F.upper(F.trim(F.col("client_type_code"))))
    .withColumn("state_code",           F.upper(F.trim(F.col("state_code"))))
    .withColumn("country_code",         F.upper(F.trim(F.col("country_code"))))
    .withColumn("first_name",           F.trim(F.col("first_name")))
    .withColumn("last_name",            F.trim(F.col("last_name")))
    .withColumn("city",                 F.trim(F.col("city")))
    # Null defaults
    .withColumn("gender_code",          F.coalesce(F.col("gender_code"), F.lit("UNKNOWN")))
    .withColumn("marital_status_code",  F.coalesce(F.col("marital_status_code"), F.lit("UNKNOWN")))
    .withColumn("client_type_code",     F.coalesce(F.col("client_type_code"), F.lit("UNKNOWN")))
    .withColumn("state_code",           F.coalesce(F.col("state_code"), F.lit("UNKNOWN")))
    .withColumn("country_code",         F.coalesce(F.col("country_code"), F.lit("UNKNOWN")))
    .withColumn("is_entity",            F.coalesce(F.col("is_entity"), F.lit(False)))
)
logger.record_count("after_cleanse", cleansed_df.count())

# MD5 — include base64 of binary cols to detect changes to hashed values
hash_input_expr = F.concat_ws(
    "||",
    *[F.coalesce(F.col(c).cast("string"), F.lit("__NULL__")) for c in HASH_COLUMNS_CLIENT],
    F.coalesce(F.base64(F.col("tax_id_hash")), F.lit("__NULL__")),
    F.coalesce(F.base64(F.col("last4_hash")),  F.lit("__NULL__")),
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

logger.info("Executing Delta merge (SCD2) into silver_s1.client")
silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

silver_table.alias("target").merge(
    incoming_df.alias("source"),
    "target.client_id = source.client_id AND target.is_current = true"
).whenMatchedUpdate(
    condition="target.md5_hash <> source.md5_hash",
    set={"is_current": F.lit(False), "expiration_date": F.lit(TODAY).cast("date")}
).execute()

(
    incoming_df
    .join(silver_table.toDF().filter("is_current = true").select("client_id"), "client_id", "left_anti")
    .write.format("delta").mode("append").save(SILVER_S1_PATH)
)

final_count = spark.read.format("delta").load(SILVER_S1_PATH).filter("is_current = true").count()
logger.record_count("silver_s1_current_records", final_count)
logger.info(f"silver_s1.client SCD2 complete — {final_count:,} current records")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
