#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_activity_type
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


# Notebook: nb_gold_dim_activity_type
# Layer:    Gold
# Purpose:  Insert-only junk dimension.  Collapses eight low-cardinality
#           classification columns off fact_activity into one key.
#
#           Built from SELECT DISTINCT over task and event — it has no source
#           table of its own.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.4
# Build order: 4 of 10.  No dependency on any other gold table.
#
# Write pattern: INSERT-ONLY (SCD Type 1).  A combination is looked up, inserted
#                if unseen, and then never updated or expired.  Idempotency is
#                enforced here by a LEFT ANTI JOIN against the existing target
#                before the write, so re-running the notebook is a no-op.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_activity_type").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_activity_type"
_is_scd2           = False
_surrogate_key_col = "activity_type_key"
_hash_col          = "md5_hash"

# For a junk dimension the whole attribute combination IS the business key.
_business_key_cols = [
    "activity_class",
    "activity_subtype",
    "activity_category",
    "call_direction",
    "subject_type",
    "subject_sub_type",
    "activity_status",
    "priority_level",
    "availability_status",
    "is_high_priority",
    "is_closed",
    "is_all_day_event",
    "is_recurring",
]

print("=" * 65)
print("  nb_gold_dim_activity_type — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read distinct combinations from task + event
# ══════════════════════════════════════════════════════════════════════════════
#
# Every text attribute uses 'Unknown' instead of NULL: this is a junk dimension
# and NULLs would split what should be one group and break the fact lookup.
#
# Columns that only exist on one side get the documented default on the other:
#   events  -> is_closed = 1  (an event that happened is complete)
#   tasks   -> is_all_day_event = 0
#   events  -> activity_status / priority_level / is_high_priority not sourced

print(f"\n[1/4] Reading distinct combinations from task and event")

activity_type_df = spark.sql(f"""
SELECT DISTINCT
    'Task'                                                              AS activity_class,
    COALESCE(NULLIF(TRIM(t.task_subtype),       'NOT_PROVIDED'), 'Unknown') AS activity_subtype,
    COALESCE(NULLIF(TRIM(t.type),               'NOT_PROVIDED'), 'Unknown') AS activity_category,
    COALESCE(NULLIF(TRIM(t.call_type_c),        'NOT_PROVIDED'), 'Unknown') AS call_direction,
    COALESCE(NULLIF(TRIM(t.subject_type_c),     'NOT_PROVIDED'), 'Unknown') AS subject_type,
    COALESCE(NULLIF(TRIM(t.subject_sub_type_c), 'NOT_PROVIDED'), 'Unknown') AS subject_sub_type,
    COALESCE(NULLIF(TRIM(t.status),             'NOT_PROVIDED'), 'Unknown') AS activity_status,
    COALESCE(NULLIF(TRIM(t.priority),           'NOT_PROVIDED'), 'Unknown') AS priority_level,
    'Unknown'                                                           AS availability_status,
    CAST(COALESCE(t.is_high_priority, 0) AS TINYINT)                    AS is_high_priority,
    CAST(COALESCE(t.is_closed, 0)        AS TINYINT)                    AS is_closed,
    CAST(0                               AS TINYINT)                    AS is_all_day_event,
    CAST(COALESCE(t.is_recurrence, 0)    AS TINYINT)                    AS is_recurring
FROM lh_silver.silver_s2.task t
WHERE t.ingestion_date = '{p_ingestion_date}'

UNION

SELECT DISTINCT
    'Event'                                                             AS activity_class,
    COALESCE(NULLIF(TRIM(e.event_subtype),      'NOT_PROVIDED'), 'Unknown') AS activity_subtype,
    COALESCE(NULLIF(TRIM(e.type),               'NOT_PROVIDED'), 'Unknown') AS activity_category,
    COALESCE(NULLIF(TRIM(e.call_type_c),        'NOT_PROVIDED'), 'Unknown') AS call_direction,
    COALESCE(NULLIF(TRIM(e.subject_type_c),     'NOT_PROVIDED'), 'Unknown') AS subject_type,
    COALESCE(NULLIF(TRIM(e.subject_sub_type_c), 'NOT_PROVIDED'), 'Unknown') AS subject_sub_type,
    'Unknown'                                                           AS activity_status,
    'Unknown'                                                           AS priority_level,
    COALESCE(NULLIF(TRIM(e.show_as),            'NOT_PROVIDED'), 'Unknown') AS availability_status,
    CAST(0                                 AS TINYINT)                  AS is_high_priority,
    CAST(1                                 AS TINYINT)                  AS is_closed,
    CAST(COALESCE(e.is_all_day_event, 0)   AS TINYINT)                  AS is_all_day_event,
    CAST(COALESCE(e.is_recurrence, 0)      AS TINYINT)                  AS is_recurring
FROM lh_silver.silver_s2.event e
WHERE e.ingestion_date = '{p_ingestion_date}'
""")

source_count = activity_type_df.count()
print(f"  Distinct combinations in this batch : {source_count:,}")
display(activity_type_df.limit(10))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Keep only combinations not already in the dimension
# ══════════════════════════════════════════════════════════════════════════════
# The surrogate key is a deterministic hash of the whole attribute combination
# (make_surrogate_key), so a combination that already exists produces the same
# key.  Anti-joining on that key makes the load insert-only and idempotent.

activity_type_df = activity_type_df.withColumn(
    _surrogate_key_col,
    make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
)

if spark.catalog.tableExists(_target_table):
    _existing_keys = spark.table(_target_table).select(_surrogate_key_col)
    activity_type_df = activity_type_df.join(
        _existing_keys, on=_surrogate_key_col, how="left_anti"
    )
    print(f"\n[2/4] Existing dimension found — keeping only unseen combinations")
else:
    print(f"\n[2/4] Dimension does not exist yet — first load")

# GoldLoader recomputes the surrogate key itself, so drop the helper column.
activity_type_df = activity_type_df.select(*_business_key_cols)

gold_count = activity_type_df.count()
print(f"  New combinations to insert : {gold_count:,}")
display(activity_type_df.limit(10))


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
    df                  = activity_type_df,
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


# ── Unknown / default row (activity_type_key = -1) ────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("activity_type_key"),
    F.lit("Unknown")                 .alias("activity_class"),
    F.lit("Unknown")                 .alias("activity_subtype"),
    F.lit("Unknown")                 .alias("activity_category"),
    F.lit("Unknown")                 .alias("call_direction"),
    F.lit("Unknown")                 .alias("subject_type"),
    F.lit("Unknown")                 .alias("subject_sub_type"),
    F.lit("Unknown")                 .alias("activity_status"),
    F.lit("Unknown")                 .alias("priority_level"),
    F.lit("Unknown")                 .alias("availability_status"),
    F.lit(0)         .cast("tinyint").alias("is_high_priority"),
    F.lit(0)         .cast("tinyint").alias("is_closed"),
    F.lit(0)         .cast("tinyint").alias("is_all_day_event"),
    F.lit(0)         .cast("tinyint").alias("is_recurring"),
    F.lit("Salesforce")              .alias("source_system"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.activity_type_key = src.activity_type_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (activity_type_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Data quality (mapping document section 4, checks 2-4)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT activity_type_key FROM {_target_table}
        GROUP BY activity_type_key HAVING COUNT(*) > 1
     ))                                                        AS dup_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_high_priority IS NULL OR is_high_priority NOT IN (0, 1)
         OR is_closed IS NULL        OR is_closed        NOT IN (0, 1)
         OR is_all_day_event IS NULL OR is_all_day_event NOT IN (0, 1)
         OR is_recurring IS NULL     OR is_recurring     NOT IN (0, 1))
                                                               AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE activity_subtype = 'NOT_PROVIDED'
         OR call_direction   = 'NOT_PROVIDED'
         OR subject_sub_type = 'NOT_PROVIDED')                  AS sentinel_leak_rows
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate keys      : {_dq['dup_keys']}")
print(f"  bad flag rows       : {_dq['bad_flag_rows']}")
print(f"  sentinel leak rows  : {_dq['sentinel_leak_rows']}")

if _dq["dup_keys"] or _dq["bad_flag_rows"] or _dq["sentinel_leak_rows"]:
    raise ValueError(f"[nb_gold_dim_activity_type] Hard data quality check failed: {_dq}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_activity_type — COMPLETE")
print(f"  Combinations in batch : {source_count:,}")
print(f"  Newly inserted        : {gold_count:,}")
print(f"  Elapsed               : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
