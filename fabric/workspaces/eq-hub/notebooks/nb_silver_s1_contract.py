# Notebook: nb_silver_s1_contract
# Layer: SILVER S1
# Purpose: SCD Type 2 transformation for silver_s1.contract.
#          Reads bronze_eqwarehouse.contract_base for a given data_date,
#          applies cleansing/standardization, computes MD5 hash on 39 business columns,
#          and merges into silver_s1.contract using Delta Lake merge (upsert).
#
# SCD2 Logic:
#   1. Compute MD5 hash on ordered business columns
#   2. Match on (contract_id, is_current=true)
#   3. If MD5 changed: close existing record (set expiration_date, is_current=false)
#   4. Insert new version with effective_date=today, expiration_date=NULL, is_current=true
#   5. Insert net-new records directly
#
# Parameters (passed by orchestration pipeline):
#   data_date     : DATE   — business date to process (e.g., 2024-01-15)
#   run_id        : STRING — UUID shared across all tables in this pipeline run
#   environment   : STRING — dev | qa | tst | prod
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

import hashlib
from datetime import date, datetime, timezone
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from delta.tables import DeltaTable

%run nb_logging_library

# ─── Parameters ──────────────────────────────────────────────────────────────
data_date   = dbutils.widgets.get("data_date")    # e.g. "2024-01-15"
run_id      = dbutils.widgets.get("run_id")
ENVIRONMENT = dbutils.widgets.get("environment")

STORAGE_ACCOUNT     = "__STORAGE_ACCOUNT__"
BRONZE_PATH         = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse/contract_base"
SILVER_S1_PATH      = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1/contract"
AUDIT_TABLE_PATH    = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"
SCD2_DEFAULT_EXPIRY = date(9999, 12, 31)
TODAY               = date.today()

logger = FabricLogger(
    run_id=run_id,
    layer="silver_s1",
    object_name="contract",
    environment=ENVIRONMENT,
)

# ─── Business columns driving MD5 hash ───────────────────────────────────────
# MUST be stable, ordered, and documented. Excludes: audit cols, SCD2 cols, md5_hash itself.
# Source effective_date has been renamed to effective_date_policy in Bronze.
HASH_COLUMNS = [
    "contract_number",
    "hierarchy_group_key",
    "contract_value_group_key",
    "surrender_id",
    "product_id",
    "owner_client_id",
    "owner2_client_id",
    "annuitant_insured_client_id",
    "annuitant_insured2_client_id",
    "application_received_date",
    "application_signed_date",
    "effective_date_policy",
    "issue_date",
    "issue_state_code",
    "issue_age",
    "attained_age",
    "status_code",
    "cost_basis_amount",
    "recovered_cost_basis_amount",
    "is_qualified",
    "qualification_type_code",
    "option_code",
    "certain_period",
    "mec_status_code",
    "has_spousal_continuation",
    "is_supplemental_contract",
    "is_qdro",
    "has_rider_claim",
    "is_roth_conversion",
    "is_internal_replacement",
    "is_partial_tax_conversion",
    "has_waiver_in_effect",
    "is_edelivery",
    "class_code",
    "underwriting_class_code",
    "underwriting_date",
    "coverage_ratio",
    "contract_end_date",
    "funding_company_id",
]

# ─── Step 1: Read Bronze partition ────────────────────────────────────────────
logger.info(f"Reading bronze_eqwarehouse.contract_base for data_date={data_date}")

bronze_df = (
    spark.read.format("delta")
    .load(BRONZE_PATH)
    .filter(F.col("data_date") == data_date)
    .filter(F.col("is_deleted") == False)
)
logger.record_count("after_bronze_read", bronze_df.count())

# ─── Step 2: Cleanse and standardize ─────────────────────────────────────────
logger.info("Applying cleansing transformations")

cleansed_df = (
    bronze_df
    # Uppercase code columns
    .withColumn("issue_state_code",      F.upper(F.trim(F.col("issue_state_code"))))
    .withColumn("status_code",           F.upper(F.trim(F.col("status_code"))))
    .withColumn("qualification_type_code", F.upper(F.trim(F.col("qualification_type_code"))))
    .withColumn("option_code",           F.upper(F.trim(F.col("option_code"))))
    .withColumn("mec_status_code",       F.upper(F.trim(F.col("mec_status_code"))))
    .withColumn("class_code",            F.upper(F.trim(F.col("class_code"))))
    .withColumn("underwriting_class_code", F.upper(F.trim(F.col("underwriting_class_code"))))
    # Round monetary amounts to 4 decimal places
    .withColumn("cost_basis_amount",           F.round(F.col("cost_basis_amount"), 4))
    .withColumn("recovered_cost_basis_amount", F.round(F.col("recovered_cost_basis_amount"), 4))
    # Trim string fields
    .withColumn("contract_number",    F.trim(F.col("contract_number")))
    .withColumn("hierarchy_group_key", F.trim(F.col("hierarchy_group_key")))
    # Null defaulting — strings to 'unknown', codes to 'UNKNOWN'
    .withColumn("status_code",               F.coalesce(F.col("status_code"), F.lit("UNKNOWN")))
    .withColumn("issue_state_code",          F.coalesce(F.col("issue_state_code"), F.lit("UNKNOWN")))
    .withColumn("qualification_type_code",   F.coalesce(F.col("qualification_type_code"), F.lit("UNKNOWN")))
    .withColumn("option_code",               F.coalesce(F.col("option_code"), F.lit("UNKNOWN")))
    .withColumn("mec_status_code",           F.coalesce(F.col("mec_status_code"), F.lit("UNKNOWN")))
    .withColumn("class_code",                F.coalesce(F.col("class_code"), F.lit("UNKNOWN")))
    .withColumn("contract_number",           F.coalesce(F.col("contract_number"), F.lit("unknown")))
    # Boolean nulls — default to false (absence of flag = false)
    .withColumn("is_qualified",              F.coalesce(F.col("is_qualified"), F.lit(False)))
    .withColumn("has_spousal_continuation",  F.coalesce(F.col("has_spousal_continuation"), F.lit(False)))
    .withColumn("is_supplemental_contract",  F.coalesce(F.col("is_supplemental_contract"), F.lit(False)))
    .withColumn("is_qdro",                   F.coalesce(F.col("is_qdro"), F.lit(False)))
    .withColumn("has_rider_claim",           F.coalesce(F.col("has_rider_claim"), F.lit(False)))
    .withColumn("is_roth_conversion",        F.coalesce(F.col("is_roth_conversion"), F.lit(False)))
    .withColumn("is_internal_replacement",   F.coalesce(F.col("is_internal_replacement"), F.lit(False)))
    .withColumn("is_partial_tax_conversion", F.coalesce(F.col("is_partial_tax_conversion"), F.lit(False)))
    .withColumn("has_waiver_in_effect",      F.coalesce(F.col("has_waiver_in_effect"), F.lit(False)))
    .withColumn("is_edelivery",              F.coalesce(F.col("is_edelivery"), F.lit(False)))
)

logger.record_count("after_cleanse", cleansed_df.count())

# ─── Step 3: Compute MD5 hash ─────────────────────────────────────────────────
logger.info(f"Computing MD5 hash on {len(HASH_COLUMNS)} business columns")

hash_input_expr = F.concat_ws(
    "||",
    *[F.coalesce(F.col(c).cast("string"), F.lit("__NULL__")) for c in HASH_COLUMNS]
)
cleansed_df = cleansed_df.withColumn("md5_hash", F.md5(hash_input_expr))

# ─── Step 4: Add SCD2 and audit columns for incoming records ─────────────────
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
logger.info("Executing Delta merge (SCD2) into silver_s1.contract")

silver_table = DeltaTable.forPath(spark, SILVER_S1_PATH)

# Close existing current records where MD5 has changed
silver_table.alias("target").merge(
    incoming_df.alias("source"),
    condition="target.contract_id = source.contract_id AND target.is_current = true"
).whenMatchedUpdate(
    condition="target.md5_hash <> source.md5_hash",
    set={
        "is_current":       F.lit(False),
        "expiration_date":  F.lit(TODAY).cast("date"),
    }
).execute()

logger.info("SCD2 merge step 1 complete — closed changed records")

# Insert new/changed versions
(
    incoming_df
    .join(
        silver_table.toDF().filter("is_current = true").select("contract_id", "md5_hash"),
        on="contract_id",
        how="left_anti"  # net-new records
    )
    .union(
        incoming_df.join(
            silver_table.toDF()
            .filter("is_current = false")
            .select("contract_id", F.col("md5_hash").alias("old_hash")),
            on=(
                (incoming_df.contract_id == F.col("contract_id")) &
                (incoming_df.md5_hash != F.col("old_hash"))
            ),
            how="inner"
        ).drop("old_hash")
    )
    .write
    .format("delta")
    .mode("append")
    .save(SILVER_S1_PATH)
)

logger.info("SCD2 merge step 2 complete — inserted new/changed versions")

# ─── Step 6: Verify counts ────────────────────────────────────────────────────
final_current_count = (
    spark.read.format("delta").load(SILVER_S1_PATH)
    .filter(F.col("is_current") == True)
    .count()
)
logger.record_count("silver_s1_current_records", final_current_count)
logger.info(f"silver_s1.contract SCD2 complete — {final_current_count:,} current records")

logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
