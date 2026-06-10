#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_client
# 
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"


# In[ ]:


# Notebook: nb_gold_dim_client
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_client from
#           lh_silver.dbo.agent_base_current (SCD2 _current view).
#
#           agency_name is NOT available in agent_base; the column is written
#           as NULL until the source join path is confirmed (see open item #3 in
#           docs/gold_mapping_agent_training_star_schema.md).
#
# Write pattern: full OVERWRITE on every run.  Because the source is the
#                _current view (active records only), reloading the full table
#                is the safest way to keep the gold dim in sync.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_client").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()




_target_table = "lh_gold.gold.dim_client"
_business_key_cols = ['tax_id_hash','last_4_hash','last_4_token','display_name','first_name','middle_name','last_name','prefix','suffix','corporate_name','gender','phone_number','email_address','fax_number','birth_date','date_of_death','status'
]   # list
_is_scd2           = True
_surrogate_key_col = "client_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_client — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


client_dim_df = spark.sql('''select tax_id_hash,
last_4_hash,
last_4_token,
display_name,
first_name,
middle_name,
last_name,
prefix,
suffix,
corporate_name,
gender,
phone_number,
email_address,
fax_number,
birth_date,
date_of_death,
status,
pay_preference,
external_account_group_key as source_external_account_group_key,
address_line_1,
address_line_2,
address_line_3,
address_line_4,
city,
state_code,
zip_code,
county,
country_code,
additional_info_group_key source_additional_info_group_key,
verification_details,
is_no_new_business,
effective_date,
client_id as source_client_id,
source_key,
case when c.start_timestamp < c.effective_timestamp then c.start_timestamp
else c.effective_timestamp end as effective_timestamp,
case when c.end_timestamp < c.expiration_timestamp then c.end_timestamp
else c.expiration_timestamp end as expiration_timestamp,
is_current
from silver_s2.client_base_current c''')


# In[ ]:


display(client_dim_df.limit(2))


# In[ ]:


client_dim_df = (
    client_dim_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    # Input: all agent business columns (excludes audit + SCD2 metadata cols)
    .withColumn(_surrogate_key_col, make_surrogate_key(*[F.col(c) for c in _business_key_cols]))
    # # ── Agent identifiers ──────────────────────────────────────────────────
    # .withColumn("agent_number",             F.col("agent_number").cast("string"))
    # .withColumn("agent_name",               F.col("display_name").cast("string"))   # rename
    # .withColumn("agent_type",               F.col("agent_type").cast("string"))
    # .withColumn("national_producer_number", F.col("national_producer_number").cast("string"))
    # .withColumn("nasd_finra_number",        F.col("nasd_finra_number").cast("string"))
    # # ── Status and dates ───────────────────────────────────────────────────
    # .withColumn("status",           F.col("status").cast("string"))
    # .withColumn("hire_date",        F.col("hire_date").cast("date"))
    # .withColumn("termination_date", F.col("termination_date").cast("date"))
    # # ── SCD2 tracking (carried from silver) ────────────────────────────────
    # .withColumn("effective_timestamp",  F.col("effective_timestamp").cast("timestamp"))
    # .withColumn("expiration_timestamp", F.col("expiration_timestamp").cast("timestamp"))
    # # ── Pipeline audit ─────────────────────────────────────────────────────
    # .withColumn("src_busn_asst",       F.lit(p_src_busn_asst).cast("string"))
    # .withColumn("ingestion_date",      F.lit(p_ingestion_date).cast("date"))
    # .withColumn("ingestion_timestamp", F.lit(p_ingestion_timestamp).cast("timestamp"))
    # # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        _surrogate_key_col,
        "tax_id_hash",
        "last_4_hash",
        "last_4_token",
        "display_name",
        "first_name",
        "middle_name",
        "last_name",
        "prefix",
        "suffix",
        "corporate_name",
        "gender",
        "phone_number",
        "email_address",
        "fax_number",
        "birth_date",
        "date_of_death",
        "status",
        "pay_preference",
        "source_external_account_group_key",
        "address_line_1",
        "address_line_2",
        "address_line_3",
        "address_line_4",
        "city",
        "state_code",
        "zip_code",
        "county",
        "country_code",
        "source_additional_info_group_key",
        "verification_details",
        "is_no_new_business",
        "effective_date",
        "source_client_id",
        "source_key",
        "effective_timestamp",
        "expiration_timestamp",
        "is_current"
    )
)


# In[ ]:


display(client_dim_df.limit(2))                                                                           


# In[ ]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = client_dim_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (client_key = -1) ───────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("client_key"),
    F.lit("Unknown")                   .alias("tax_id_hash"),
    F.lit("Unknown")                   .alias("last_4_hash"),
    F.lit("Unknown")                   .alias("last_4_token"),
    F.lit("Unknown")                   .alias("display_name"),
    F.lit("Unknown")                   .alias("first_name"),
    F.lit("Unknown")                   .alias("middle_name"),
    F.lit("Unknown")                   .alias("last_name"),
    F.lit("Unknown")                   .alias("prefix"),
    F.lit("Unknown")                   .alias("suffix"),
    F.lit("Unknown")                   .alias("corporate_name"),
    F.lit("Unknown")                   .alias("gender"),
    F.lit("Unknown")                   .alias("phone_number"),
    F.lit("Unknown")                   .alias("email_address"),
    F.lit("Unknown")                   .alias("fax_number"),
    F.lit(None)     .cast("date")      .alias("birth_date"),
    F.lit(None)     .cast("date")      .alias("date_of_death"),
    F.lit("Unknown")                   .alias("status"),
    F.lit("Unknown")                   .alias("pay_preference"),
    F.lit(0)        .cast("int")       .alias("source_external_account_group_key"),
    F.lit("Unknown")                   .alias("address_line_1"),
    F.lit("Unknown")                   .alias("address_line_2"),
    F.lit("Unknown")                   .alias("address_line_3"),
    F.lit("Unknown")                   .alias("address_line_4"),
    F.lit("Unknown")                   .alias("city"),
    F.lit("Unknown")                   .alias("state_code"),
    F.lit("Unknown")                   .alias("zip_code"),
    F.lit("Unknown")                   .alias("county"),
    F.lit("Unknown")                   .alias("country_code"),
    F.lit(0)        .cast("int")       .alias("source_additional_info_group_key"),
    F.lit("Unknown")                   .alias("verification_details"),
    F.lit(0)        .cast("int")       .alias("is_no_new_business"),
    F.lit(None)     .cast("date")      .alias("effective_date"),
    F.lit(0)        .cast("int")       .alias("source_client_id"),
    F.lit("Unknown")                   .alias("source_key"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.client_key = src.client_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (client_key=-1) ensured in '{_target_table}'")

