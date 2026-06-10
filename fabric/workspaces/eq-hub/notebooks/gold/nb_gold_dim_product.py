#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_product
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


# Notebook: nb_gold_dim_product
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_product from
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

spark = SparkSession.builder.appName("nb_gold_dim_product").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()




_target_table = "lh_gold.gold.dim_product"
_business_key_cols = ['product_name','marketing_name','alt_marketing_name','group_name','agent_comm_statement_abbr','gl_abbr','gl_line_of_business','product_context','product_type','cusip_number'
]   # list
_is_scd2           = True
_surrogate_key_col = "product_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_product — START")
print("=" * 65)
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


product_dim_df = spark.sql('''select 
product_name,
marketing_name,
alt_marketing_name,
group_name,
agent_comm_statement_abbr,
gl_abbr,
gl_line_of_business,
product_context,
product_type,
cusip_number,
sort_order,
effective_date,
status,
product_id as source_product_id,
case when effective_date < effective_timestamp then effective_date
else effective_timestamp end as effective_timestamp,
expiration_timestamp,
is_current
from silver_s2.product_base_current''')


# In[ ]:


display(product_dim_df.limit(2))


# In[ ]:


product_dim_df = (
    product_dim_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    # Input: all agent business columns (excludes audit + SCD2 metadata cols)
    .withColumn(_surrogate_key_col, make_surrogate_key(*[F.col(c) for c in _business_key_cols]))
    .select(
        _surrogate_key_col,
        "product_name",
        "marketing_name",
        "alt_marketing_name",
        "group_name",
        "agent_comm_statement_abbr",
        "gl_abbr",
        "gl_line_of_business",
        "product_context",
        "product_type",
        "cusip_number",
        "sort_order",
        "effective_date",
        "status",
        "source_product_id",
        "effective_timestamp",
        "expiration_timestamp",
        "is_current"
    )
)


# In[ ]:


display(product_dim_df.limit(2))                                                                           


# In[ ]:


# ── Load ──────────────────────────────────────────────────────────────────────

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = product_dim_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (product_key = -1) ──────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("product_key"),
    F.lit("Unknown")                   .alias("product_name"),
    F.lit("Unknown")                   .alias("marketing_name"),
    F.lit("Unknown")                   .alias("alt_marketing_name"),
    F.lit("Unknown")                   .alias("group_name"),
    F.lit("Unknown")                   .alias("agent_comm_statement_abbr"),
    F.lit("Unknown")                   .alias("gl_abbr"),
    F.lit("Unknown")                   .alias("gl_line_of_business"),
    F.lit("Unknown")                   .alias("product_context"),
    F.lit("Unknown")                   .alias("product_type"),
    F.lit("Unknown")                   .alias("cusip_number"),
    F.lit(0)        .cast("int")       .alias("sort_order"),
    F.lit(None)     .cast("date")      .alias("effective_date"),
    F.lit("Unknown")                   .alias("status"),
    F.lit(0)        .cast("int")       .alias("source_product_id"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.product_key = src.product_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (product_key=-1) ensured in '{_target_table}'")

