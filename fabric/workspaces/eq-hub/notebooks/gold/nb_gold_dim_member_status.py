#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_member_status
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED
p_src_busn_asst       = "elic"    # REQUIRED


# In[ ]:


# Notebook: nb_gold_dim_member_status
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.dim_member_status (Meeting-Campaign star).
#           A small SEEDED dimension of Salesforce CampaignMember statuses.
#           Rows: Sent, Responded, Registered, Attended, No Show.
#           (Design drawio: member_status_key, status_name, is_responded_flag,
#            status_sort_order.)
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_member_status").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_member_status"
_business_key_cols = ["status_name"]
_is_scd2           = False
_surrogate_key_col = "member_status_key"
_hash_col          = "md5_hash"

print("=" * 65)
print("  nb_gold_dim_member_status — START")
print("=" * 65)
print(f"  target : {_target_table}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Seed rows
# (status_name, is_responded_flag, status_sort_order)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Building seed rows")

_seed = [
    ("Sent",       0, 1),
    ("Responded",  1, 2),
    ("Registered", 1, 3),
    ("Attended",   1, 4),
    ("No Show",    0, 5),
]
status_df = spark.createDataFrame(_seed, ["status_name", "is_responded_flag", "status_sort_order"])

status_df = (
    status_df
    .withColumn(_surrogate_key_col,
        make_surrogate_key(*[F.col(c) for c in _business_key_cols]))  # noqa: F821 # type: ignore[name-defined]
    .withColumn("is_responded_flag", F.col("is_responded_flag").cast("int"))
    .withColumn("status_sort_order", F.col("status_sort_order").cast("int"))
    .select(_surrogate_key_col, "status_name", "is_responded_flag", "status_sort_order")
)

gold_count = status_df.count()
print(f"  Seed rows : {gold_count:,}")
display(status_df)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Load via GoldLoader (SCD1) + Not-Applicable row
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/3] Loading via GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

_load_start = time.time()
loader.load(
    df                = status_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]
_na_df = spark.range(1).select(
    F.lit(-1).cast("long").alias("member_status_key"),
    F.lit("Unknown").alias("status_name"),
    F.lit(0).cast("int").alias("is_responded_flag"),
    F.lit(-1).cast("int").alias("status_sort_order"),
    F.lit(None).cast("timestamp").alias("effective_timestamp"),
    F.lit(None).cast("timestamp").alias("expiration_timestamp"),
    F.lit(1).cast("int").alias("is_current"),
    F.lit(None).cast("string").alias("md5_hash"),
)
(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_na_df.alias("src"), "tgt.member_status_key = src.member_status_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (member_status_key=-1) ensured")


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)
print("\n" + "=" * 65)
print("  nb_gold_dim_member_status — COMPLETE")
print(f"  Rows written : {gold_count:,}  (+1 Unknown)")
print(f"  Elapsed      : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
