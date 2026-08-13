#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_campaign_activity
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
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"


# In[ ]:


# Notebook: nb_gold_dim_campaign_activity
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.dim_campaign_activity — a JUNK dimension that
#           is the cross-product of the low-cardinality descriptors hanging off a
#           Salesforce Activity (Task OR Event). One row per distinct combination.
#
#           GRAIN: one distinct combination of activity descriptors.
#           Built from DISTINCT combinations across SF task + event.
#           (Design doc §3A: ~314 Task + ~11 Event combinations ≈ 325 rows.)
#
#           DISCRIMINATOR: activity_object (Task | Event) — every query filters on
#           it first, so it lives here rather than as a degenerate fact column.
#
#           NULL CONVENTION (design doc §3A.3): an attribute that does not apply to
#           an activity type is NULL ("does not apply"), never 0 (which would drag
#           averages). Event-only attributes are NULL on Task rows and vice versa.
#
#           KEY BY CONSTRUCTION: activity_key = make_surrogate_key over the raw
#           descriptor columns (nulls coalesced to 'N/A' for a stable hash). The
#           fact computes the identical key the same way — no join needed, keys
#           match by construction (same pattern as the Webex dims).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_campaign_activity").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_campaign_activity"
_is_scd2           = False
_surrogate_key_col = "activity_key"
_hash_col          = "md5_hash"

_SRC_TASK  = "lh_silver.silver_s2.task"
_SRC_EVENT = "lh_silver.silver_s2.event"

# The raw descriptor columns whose combination defines a junk-dimension row.
# The surrogate key is computed from exactly these (coalesced to 'N/A'), and the
# fact must use the SAME ordered list so its activity_key matches by construction.
_KEY_COLS = [
    "activity_object", "activity_type", "activity_subtype",
    "subject_type", "subject_sub_type", "call_type",
    "status", "priority", "is_high_priority", "is_closed", "call_disposition",
    "group_event_type", "show_as", "is_all_day", "is_group_event",
]

print("=" * 65)
print("  nb_gold_dim_campaign_activity — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read: descriptor projection of Task + Event, then DISTINCT
#
# Each source is projected onto the SAME descriptor schema. Attributes that do
# not exist for that object type are emitted as NULL (the "does not apply" rule).
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Building descriptor projection (Task ∪ Event) and taking DISTINCT")

activity_desc_df = spark.sql(f"""
    WITH task_desc AS (
        SELECT
            'Task'                                        AS activity_object,
            type                                          AS activity_type,
            task_subtype                                  AS activity_subtype,
            subject_type_c                                AS subject_type,
            subject_sub_type_c                            AS subject_sub_type,
            COALESCE(call_type_c, call_type)              AS call_type,
            status                                        AS status,
            priority                                      AS priority,
            CAST(is_high_priority AS INT)                 AS is_high_priority,
            CAST(is_closed AS INT)                        AS is_closed,
            call_disposition                              AS call_disposition,
            CAST(NULL AS STRING)                          AS group_event_type,
            CAST(NULL AS STRING)                          AS show_as,
            CAST(NULL AS INT)                             AS is_all_day,
            CAST(NULL AS INT)                             AS is_group_event
        FROM {_SRC_TASK}
    ),
    event_desc AS (
        SELECT
            'Event'                                       AS activity_object,
            type                                          AS activity_type,
            event_subtype                                 AS activity_subtype,
            subject_type_c                                AS subject_type,
            subject_sub_type_c                            AS subject_sub_type,
            call_type_c                                   AS call_type,
            CAST(NULL AS STRING)                          AS status,
            CAST(NULL AS STRING)                          AS priority,
            CAST(NULL AS INT)                             AS is_high_priority,
            CAST(NULL AS INT)                             AS is_closed,
            CAST(NULL AS STRING)                          AS call_disposition,
            group_event_type                             AS group_event_type,
            show_as                                      AS show_as,
            CAST(is_all_day_event AS INT)                 AS is_all_day,
            CAST(is_group_event AS INT)                   AS is_group_event
        FROM {_SRC_EVENT}
    )
    SELECT DISTINCT * FROM (
        SELECT * FROM task_desc
        UNION ALL
        SELECT * FROM event_desc
    )
""")

source_count = activity_desc_df.count()
print(f"  Distinct descriptor combinations : {source_count:,}")
display(activity_desc_df.limit(3))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform: derived attributes + surrogate key
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Deriving funnel_stage / is_qualifying_action and the surrogate key")

# ── funnel_stage — a coarse funnel placement of the activity. This is a business
#    rule that will be refined with the marketing team; the mapping below is the
#    starting point (design doc §4: the "engaged" definition is deliberately kept
#    on a flag/attribute so it can change without reloading history).
_funnel_stage = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit("In-Person"))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit("Qualified"))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "calling campaign", "sales", "calling"), F.lit("Engagement"))
     .otherwise(F.lit("Contact"))
)

# ── is_qualifying_action_flag — 1 for actions that count as a qualified touch
#    (Q3 in-person attendance, Q4 illustration/transfer calls), else 0.
_is_qualifying = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit(1))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit(1))
     .otherwise(F.lit(0))
     .cast("int")
)

# ── Surrogate key by construction: hash the raw descriptor combination with
#    nulls coalesced to a stable 'N/A' token (so NULL vs NULL hashes the same).
_key_exprs = [F.coalesce(F.col(c).cast("string"), F.lit("N/A")) for c in _KEY_COLS]

activity_desc_df = (
    activity_desc_df
    .withColumn("funnel_stage",             _funnel_stage)
    .withColumn("is_qualifying_action_flag", _is_qualifying)
    .withColumn(_surrogate_key_col, make_surrogate_key(*_key_exprs))  # noqa: F821 # type: ignore[name-defined]
    .select(
        _surrogate_key_col,
        # ── Discriminator ──────────────────────────────────────────────────
        "activity_object",
        # ── Type ───────────────────────────────────────────────────────────
        "activity_type", "activity_subtype", "subject_type", "subject_sub_type", "call_type",
        # ── Status (Task) ──────────────────────────────────────────────────
        "status", "priority", "is_high_priority", "is_closed", "call_disposition",
        # ── Event-only ─────────────────────────────────────────────────────
        "group_event_type", "show_as", "is_all_day", "is_group_event",
        # ── Derived ────────────────────────────────────────────────────────
        "funnel_stage", "is_qualifying_action_flag",
    )
)

gold_count = activity_desc_df.count()
print(f"  Transformed rows : {gold_count:,}")
print("  By activity_object:")
activity_desc_df.groupBy("activity_object").count().show(truncate=False)
display(activity_desc_df.limit(3))


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
    df                = activity_desc_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _KEY_COLS,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── "Not Applicable" default row (activity_key = -1) ──────────────────────────
# Sparse fact FKs point here (design doc §3A.3). All descriptor columns are NULL.
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_na_df = spark.range(1).select(
    F.lit(-1).cast("long").alias("activity_key"),
    F.lit("N/A").alias("activity_object"),
    *[F.lit(None).cast("string").alias(c) for c in
      ("activity_type", "activity_subtype", "subject_type", "subject_sub_type",
       "call_type", "status", "priority", "call_disposition", "group_event_type", "show_as")],
    *[F.lit(None).cast("int").alias(c) for c in
      ("is_high_priority", "is_closed", "is_all_day", "is_group_event")],
    F.lit("N/A").alias("funnel_stage"),
    F.lit(0).cast("int").alias("is_qualifying_action_flag"),
    F.lit(None).cast("timestamp").alias("effective_timestamp"),
    F.lit(None).cast("timestamp").alias("expiration_timestamp"),
    F.lit(1).cast("int").alias("is_current"),
    F.lit(None).cast("string").alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_na_df.alias("src"), "tgt.activity_key = src.activity_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Not-Applicable row (activity_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_campaign_activity — COMPLETE")
print(f"  Distinct combinations : {source_count:,}")
print(f"  Rows written          : {gold_count:,}")
print(f"  Elapsed               : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
