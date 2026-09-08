#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_campaign_member_status
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_silver_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_silver_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2026-09-08"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2026-09-08T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"
p_ingestion_run_id    = "00000000-0000-0000-0000-000000000000"


# In[ ]:


# Notebook: nb_gold_dim_campaign_member_status
# Layer:    Gold
# Purpose:  Insert-only junk dimension.  Five low-cardinality campaign-member
#           status columns collapsed to one key.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.6
# Build order: 6 of 10.  No dependency on any other gold table.
#
# Write pattern: INSERT-ONLY (SCD Type 1).  A combination is looked up,
#                inserted if unseen, and then never updated or expired.
#                Idempotency is enforced by a LEFT ANTI JOIN against the
#                existing target before the write.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_campaign_member_status").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_campaign_member_status"
_is_scd2           = False
_surrogate_key_col = "member_status_key"
_hash_col          = "md5_hash"

# For a junk dimension the whole attribute combination IS the business key.
_business_key_cols = [
    "member_status",
    "member_type",
    "call_status",
    "follow_up_status",
    "channel_name",
    "is_responded",
]

print("=" * 65)
print("  nb_gold_dim_campaign_member_status — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read distinct combinations from campaign_member
# ══════════════════════════════════════════════════════════════════════════════
# Every text attribute uses 'Unknown' instead of NULL: this is a junk dimension
# and a NULL would split what should be one group and break the fact lookup.

print(f"\n[1/4] Reading distinct status combinations from campaign_member")

member_status_df = spark.sql(f"""
SELECT DISTINCT
    COALESCE(NULLIF(TRIM(cm.status),             'NOT_PROVIDED'), 'Unknown') AS member_status,
    COALESCE(NULLIF(TRIM(cm.type),               'NOT_PROVIDED'), 'Unknown') AS member_type,
    COALESCE(NULLIF(TRIM(cm.call_status_c),      'NOT_PROVIDED'), 'Unknown') AS call_status,
    COALESCE(NULLIF(TRIM(cm.follow_up_status_c), 'NOT_PROVIDED'), 'Unknown') AS follow_up_status,
    COALESCE(NULLIF(TRIM(cm.channel_c),          'NOT_PROVIDED'), 'Unknown') AS channel_name,
    CAST(COALESCE(cm.has_responded, 0) AS TINYINT)                           AS is_responded
FROM lh_silver.silver_s2.campaign_member cm
WHERE cm.ingestion_date = '{p_ingestion_date}'
""")

source_count = member_status_df.count()
print(f"  Distinct combinations in this batch : {source_count:,}")
display(member_status_df.limit(20))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Keep only combinations not already in the dimension
# ══════════════════════════════════════════════════════════════════════════════
# The surrogate key is a deterministic hash of the whole attribute combination,
# so a combination that already exists produces the same key.  Anti-joining on
# that key makes the load insert-only and idempotent.

member_status_df = member_status_df.withColumn(
    _surrogate_key_col,
    make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
)

if spark.catalog.tableExists(_target_table):
    _existing_keys = spark.table(_target_table).select(_surrogate_key_col)
    member_status_df = member_status_df.join(
        _existing_keys, on=_surrogate_key_col, how="left_anti"
    )
    print(f"\n[2/4] Existing dimension found — keeping only unseen combinations")
else:
    print(f"\n[2/4] Dimension does not exist yet — first load")

# GoldLoader recomputes the surrogate key itself, so drop the helper column.
member_status_df = member_status_df.select(*_business_key_cols)

gold_count = member_status_df.count()
print(f"  New combinations to insert : {gold_count:,}")
display(member_status_df.limit(20))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (insert-only)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = member_status_df,
    target_table        = _target_table,
    is_scd2             = _is_scd2,
    business_key_cols   = _business_key_cols,
    surrogate_key_col   = _surrogate_key_col,
    hash_col            = _hash_col,
    ingestion_date      = p_ingestion_date,
    data_timestamp      = p_ingestion_timestamp,
    source_system       = "Salesforce",
    ingestion_run_id    = p_ingestion_run_id,
    ingestion_timestamp = p_ingestion_timestamp,
    src_busn_asst       = p_src_busn_asst,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (member_status_key = -1) ────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("member_status_key"),
    F.lit("Unknown")                 .alias("member_status"),
    F.lit("Unknown")                 .alias("member_type"),
    F.lit("Unknown")                 .alias("call_status"),
    F.lit("Unknown")                 .alias("follow_up_status"),
    F.lit("Unknown")                 .alias("channel_name"),
    F.lit(0)         .cast("tinyint").alias("is_responded"),
    F.lit("Salesforce")              .alias("source_system"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.member_status_key = src.member_status_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (member_status_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Data quality (mapping document section 4, checks 2-4)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT member_status_key FROM {_target_table}
        GROUP BY member_status_key HAVING COUNT(*) > 1
     ))                                                        AS dup_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_responded IS NULL OR is_responded NOT IN (0, 1)) AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE member_status    = 'NOT_PROVIDED'
         OR call_status      = 'NOT_PROVIDED'
         OR follow_up_status = 'NOT_PROVIDED'
         OR channel_name     = 'NOT_PROVIDED')                  AS sentinel_leak_rows
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate keys      : {_dq['dup_keys']}")
print(f"  bad flag rows       : {_dq['bad_flag_rows']}")
print(f"  sentinel leak rows  : {_dq['sentinel_leak_rows']}")

if _dq["dup_keys"] or _dq["bad_flag_rows"] or _dq["sentinel_leak_rows"]:
    raise ValueError(
        f"[nb_gold_dim_campaign_member_status] Hard data quality check failed: {_dq}"
    )


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_campaign_member_status — COMPLETE")
print(f"  Combinations in batch : {source_count:,}")
print(f"  Newly inserted        : {gold_count:,}")
print(f"  Elapsed               : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
