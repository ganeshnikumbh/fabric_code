#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_company
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


# Notebook: nb_gold_dim_company
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_company from
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

spark = SparkSession.builder.appName("nb_gold_dim_company").getOrCreate()

_notebook_start = time.time()

# F.col("agent_number"),
#         F.col("display_name"),
#         F.col("agent_type"),
#         F.col("national_producer_number"),
#         F.col("nasd_finra_number")


_target_table = "lh_gold.gold.dim_company"
_business_key_cols = ['company_code','name','display_name','address_line_1','address_line_2','city','state','zip_code','phone']   # list
_is_scd2           = True
_surrogate_key_col = "company_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_company — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


company_dim_df = spark.sql('''select  
company_code,
name,
display_name,
address_line_1,
address_line_2,
city,
state,
zip_code,
phone,
footer,
company_id as source_company_id,
agent_id as source_agnt_id,
effective_timestamp,
expiration_timestamp,
is_current
from silver_s2.company_base_current''')


# In[ ]:


display(company_dim_df.limit(2))


# In[ ]:


company_dim_df = resolve_dim_key(
    spark       = spark,
    source_df   = company_dim_df,
    source_col  = "source_agnt_id",
    dim_table   = "gold.dim_agent",
    dim_bk_col  = "source_agent_id",
    dim_sk_col  = "agent_key",
    target_col_name = "agent_key",
    is_current_col  = "is_current"
)


# In[ ]:


display(company_dim_df.limit(2))


# In[ ]:


company_dim_df = (
    company_dim_df
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
    # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        _surrogate_key_col,
        "company_code",
        "name",
        "display_name",
        "address_line_1",
        "address_line_2",
        "city",
        "state",
        "zip_code",
        "phone",
        "footer",
        "source_company_id",
        "agent_key",
        "effective_timestamp",
        "expiration_timestamp",
        "is_current"
    )
)


# In[ ]:


display(company_dim_df.limit(2))

#  ['agent_number','agent_name','agent_type','national_producer_number','nasd_finra_number','status'] 


# In[ ]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = company_dim_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (company_key = -1) ──────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("company_key"),
    F.lit("Unknown")                   .alias("company_code"),
    F.lit("Unknown")                   .alias("name"),
    F.lit("Unknown")                   .alias("display_name"),
    F.lit("Unknown")                   .alias("address_line_1"),
    F.lit("Unknown")                   .alias("address_line_2"),
    F.lit("Unknown")                   .alias("city"),
    F.lit("Unknown")                   .alias("state"),
    F.lit("Unknown")                   .alias("zip_code"),
    F.lit("Unknown")                   .alias("phone"),
    F.lit("Unknown")                   .alias("footer"),
    F.lit(0)        .cast("int")       .alias("source_company_id"),
    F.lit(-1)       .cast("long")      .alias("agent_key"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.company_key = src.company_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (company_key=-1) ensured in '{_target_table}'")

