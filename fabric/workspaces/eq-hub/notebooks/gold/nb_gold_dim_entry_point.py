#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_entry_point
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


# Notebook: nb_gold_dim_entry_point
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.dim_entry_point from
#           lh_silver.silver_s2.csr_base and lh_silver.silver_s2.clr_base
#           (Webex Contact Center domain).
#           Entry points represent DNIS / lines of arrival
#           (e.g. EquiTrust_Main_15152265389).
#
# Write pattern: SCD Type-1 via GoldLoader (last-write-wins).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_entry_point").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_entry_point"
_business_key_cols = ["entry_point_id", "entry_point_name"]
_is_scd2           = False
_surrogate_key_col = "entry_point_key"
_hash_col          = "md5_hash"

_SRC_CSR = "lh_silver.silver_s2.csr_base"
_SRC_CLR = "lh_silver.silver_s2.clr_base"

print("=" * 65)
print("  nb_gold_dim_entry_point — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read & consolidate entry point members
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading entry point members from csr_base and clr_base")

ep_df = spark.sql(f"""
    SELECT DISTINCT last_entry_point_id  AS entry_point_id,
                    last_entry_point_name AS entry_point_name
    FROM   {_SRC_CSR}
    WHERE  last_entry_point_id IS NOT NULL

    UNION

    SELECT DISTINCT entry_point_id,
                    entry_point_name
    FROM   {_SRC_CLR}
    WHERE  entry_point_id IS NOT NULL
""")

source_count = ep_df.count()
print(f"  Distinct entry point members : {source_count:,}")
display(ep_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Applying transformations")

ep_df = (
    ep_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    .withColumn(_surrogate_key_col,
        make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
    )
    .select(
        _surrogate_key_col,
        "entry_point_id",
        "entry_point_name",
    )
)

gold_count = ep_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(ep_df.limit(2))


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
    df                = ep_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (entry_point_key = -1) ──────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("entry_point_key"),
    F.lit("Unknown")                   .alias("entry_point_id"),
    F.lit("Unknown")                   .alias("entry_point_name"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.entry_point_key = src.entry_point_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (entry_point_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_entry_point — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
