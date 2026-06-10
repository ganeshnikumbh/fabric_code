#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_queue
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


# Notebook: nb_gold_dim_queue
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_queue from lh_silver.silver_s2.csr_base
#           and lh_silver.silver_s2.clr_base.
#
#           Queue attributes (caller_type, product, call_reason) are PARSED from
#           the structured queue_name pattern: DES_<n>_<CALLER_TYPE>_<PRODUCT>_<REASON>_CSQ
#           Queues that do not match that pattern emit a DQ WARNING.
#
# Write pattern: SCD Type-2 via GoldLoader (new version on queue rename / re-mapping).
#
# Conflict note: dim_queue is used by the Webex Contact Center star schema.
#                It is independent of the EquiTrust insurance-domain dimensions.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_queue").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_queue"
_business_key_cols = ["queue_id", "queue_name"]   # new SCD2 version on rename
_is_scd2           = True
_surrogate_key_col = "queue_key"
_hash_col          = "md5_hash"

_SRC_CSR = "lh_silver.silver_s2.csr_base"
_SRC_CLR = "lh_silver.silver_s2.clr_base"

print("=" * 65)
print("  nb_gold_dim_queue — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read & consolidate queue members
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading queue members from csr_base and clr_base")

# ── Collect distinct queue_id / queue_name pairs from both sources ────────────
queue_df = spark.sql(f"""
    SELECT DISTINCT last_queue_id  AS queue_id,
                    last_queue_name AS queue_name
    FROM   {_SRC_CSR}
    WHERE  last_queue_id IS NOT NULL

    UNION

    SELECT DISTINCT queue_id,
                    queue_name
    FROM   {_SRC_CLR}
    WHERE  queue_id IS NOT NULL
""")

source_count = queue_df.count()
print(f"  Distinct queue members : {source_count:,}")
display(queue_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform: parse queue_name pattern
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Parsing queue_name attributes")

# ── Pattern: DES_<n>_<CALLER_TYPE>_<PRODUCT>_<REASON>_CSQ ───────────────────
# Split tokens (0-indexed):
#   0=DES  1=<n>  2=CALLER_TYPE  3=PRODUCT  4=REASON  5=CSQ
# Outdial queues contain 'Outdial' in name and do NOT follow DES pattern.
# Anything else → Unknown with DQ warning.

_tokens = F.split(F.col("queue_name"), "_")

_is_des_pattern = (
    (F.size(_tokens) >= 6) &
    (_tokens.getItem(0) == F.lit("DES")) &
    (_tokens.getItem(F.size(_tokens) - 1) == F.lit("CSQ"))
)

queue_df = (
    queue_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    .withColumn(_surrogate_key_col,
        make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
    )
    # ── caller_type: token 2 when DES pattern matches ──────────────────────
    .withColumn("caller_type",
        F.when(_is_des_pattern, _tokens.getItem(2))
         .otherwise(F.lit("Unknown"))
    )
    # ── product: token 3 ──────────────────────────────────────────────────
    .withColumn("product",
        F.when(_is_des_pattern, _tokens.getItem(3))
         .otherwise(F.lit("Unknown"))
    )
    # ── call_reason: token 4 ──────────────────────────────────────────────
    .withColumn("call_reason",
        F.when(_is_des_pattern, _tokens.getItem(4))
         .otherwise(F.lit("Unknown"))
    )
    # ── is_outdial_queue ──────────────────────────────────────────────────
    .withColumn("is_outdial_queue",
        F.when(F.upper(F.col("queue_name")).contains("OUTDIAL"), F.lit(1))
         .otherwise(F.lit(0))
         .cast("int")
    )
    .select(
        _surrogate_key_col,
        "queue_id",
        "queue_name",
        "caller_type",
        "product",
        "call_reason",
        "is_outdial_queue",
    )
)

gold_count = queue_df.count()
print(f"  Transformed rows : {gold_count:,}")

# ── DQ check: rows that did not match DES pattern ─────────────────────────────
_dq_unknown = queue_df.filter(
    (F.col("caller_type") == "Unknown") & (~F.upper(F.col("queue_name")).contains("OUTDIAL"))
).count()
if _dq_unknown > 0:
    print(f"  DQ WARNING: {_dq_unknown} queue(s) did not match DES_<n>_<TYPE>_<PRODUCT>_<REASON>_CSQ pattern")

display(queue_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD2)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = queue_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (queue_key = -1) ────────────────────────────────────
# GoldLoader adds effective_timestamp, expiration_timestamp, is_current, md5_hash.
# The MERGE inserts only if -1 does not already exist — safe to re-run.
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")   .alias("queue_key"),
    F.lit("Unknown")                .alias("queue_id"),
    F.lit("Unknown")                .alias("queue_name"),
    F.lit("Unknown")                .alias("caller_type"),
    F.lit("Unknown")                .alias("product"),
    F.lit("Unknown")                .alias("call_reason"),
    F.lit(0)        .cast("int")    .alias("is_outdial_queue"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")    .alias("is_current"),
    F.lit(None)     .cast("string") .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.queue_key = src.queue_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (queue_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_queue — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  DQ unmatched     : {_dq_unknown:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
