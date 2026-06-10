#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_channel
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


# Notebook: nb_gold_dim_channel
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.dim_channel from lh_silver.silver_s2.csr_base
#           (Webex Contact Center domain).
#           One row per unique channel_type + channel_sub_type combination.
#           interaction_class derived: telephony→Voice, email→Email, chat→Chat.
#
# Write pattern: SCD Type-1 via GoldLoader (last-write-wins).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_channel").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_channel"
_business_key_cols = ["channel_type", "channel_sub_type"]
_is_scd2           = False
_surrogate_key_col = "channel_key"
_hash_col          = "md5_hash"

_SRC_CSR = "lh_silver.silver_s2.csr_base"

print("=" * 65)
print("  nb_gold_dim_channel — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read distinct channel combinations
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading distinct channel type/sub_type from csr_base")

channel_df = spark.sql(f"""
    SELECT DISTINCT channel_type,
                    channel_sub_type
    FROM   {_SRC_CSR}
    WHERE  channel_type IS NOT NULL
""")

source_count = channel_df.count()
print(f"  Distinct channel combinations : {source_count:,}")
display(channel_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Applying transformations")

channel_df = (
    channel_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    .withColumn(_surrogate_key_col,
        make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
    )
    # ── interaction_class derived from channel_type ────────────────────────
    .withColumn("interaction_class",
        F.when(F.lower(F.col("channel_type")) == F.lit("telephony"), F.lit("Voice"))
         .when(F.lower(F.col("channel_type")) == F.lit("email"),     F.lit("Email"))
         .when(F.lower(F.col("channel_type")) == F.lit("chat"),      F.lit("Chat"))
         .otherwise(F.lit("Unknown"))
    )
    .select(
        _surrogate_key_col,
        "channel_type",
        "channel_sub_type",
        "interaction_class",
    )
)

gold_count = channel_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(channel_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD1)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = channel_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (channel_key = -1) ──────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("channel_key"),
    F.lit("Unknown")                   .alias("channel_type"),
    F.lit("Unknown")                   .alias("channel_sub_type"),
    F.lit("Unknown")                   .alias("interaction_class"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.channel_key = src.channel_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (channel_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_channel — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
