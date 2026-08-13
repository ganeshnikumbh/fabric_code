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
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED
p_src_busn_asst       = "elic"    # REQUIRED


# In[ ]:


# Notebook: nb_gold_dim_campaign_activity
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.dim_campaign_activity — the JUNK dimension for
#           the Meeting-Campaign star. One row per distinct combination of the
#           low-cardinality descriptors that hang off a Salesforce Activity
#           (Task OR Event). ~325 rows observed.
#
#           DISCRIMINATOR: activity_object (Task | Event).
#           NULL CONVENTION: an attribute that does not apply to an activity type
#           is NULL ("does not apply"), never 0.
#           KEY BY CONSTRUCTION: campaign_activity_key = make_surrogate_key over
#           the raw descriptor list (nulls → 'N/A'); fact_campaign_activity computes
#           the identical key, so they match with no join.
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
_surrogate_key_col = "campaign_activity_key"
_hash_col          = "md5_hash"

_SRC_TASK  = "lh_silver.silver_s2.task"
_SRC_EVENT = "lh_silver.silver_s2.event"

# Raw descriptor columns whose combination defines a junk-dim row. The fact uses
# this SAME ordered list so campaign_activity_key matches by construction.
_KEY_COLS = [
    "activity_object", "activity_type", "activity_subtype",
    "subject_type", "subject_sub_type", "call_type",
    "status", "priority", "is_high_priority", "is_closed", "call_disposition",
    "group_event_type", "show_as", "is_all_day", "is_group_event",
]

print("=" * 65)
print("  nb_gold_dim_campaign_activity — START")
print("=" * 65)
print(f"  target : {_target_table}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Descriptor projection of Task ∪ Event, DISTINCT
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Building descriptor projection (Task ∪ Event) and taking DISTINCT")

activity_desc_df = spark.sql(f"""
    WITH task_desc AS (
        SELECT
            'Task'                            AS activity_object,
            type                              AS activity_type,
            task_subtype                      AS activity_subtype,
            subject_type_c                    AS subject_type,
            subject_sub_type_c                AS subject_sub_type,
            COALESCE(call_type_c, call_type)  AS call_type,
            status                            AS status,
            priority                          AS priority,
            CAST(is_high_priority AS INT)     AS is_high_priority,
            CAST(is_closed AS INT)            AS is_closed,
            call_disposition                  AS call_disposition,
            CAST(NULL AS STRING)              AS group_event_type,
            CAST(NULL AS STRING)              AS show_as,
            CAST(NULL AS INT)                 AS is_all_day,
            CAST(NULL AS INT)                 AS is_group_event
        FROM {_SRC_TASK}
    ),
    event_desc AS (
        SELECT
            'Event'                           AS activity_object,
            type                              AS activity_type,
            event_subtype                     AS activity_subtype,
            subject_type_c                    AS subject_type,
            subject_sub_type_c                AS subject_sub_type,
            call_type_c                       AS call_type,
            CAST(NULL AS STRING)              AS status,
            CAST(NULL AS STRING)              AS priority,
            CAST(NULL AS INT)                 AS is_high_priority,
            CAST(NULL AS INT)                 AS is_closed,
            CAST(NULL AS STRING)              AS call_disposition,
            group_event_type                 AS group_event_type,
            show_as                          AS show_as,
            CAST(is_all_day_event AS INT)     AS is_all_day,
            CAST(is_group_event AS INT)       AS is_group_event
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


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Derived attributes + surrogate key
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Deriving funnel_stage / is_qualifying_action_flag and the key")

_funnel_stage = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit("In-Person"))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit("Qualified"))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "calling campaign", "sales"), F.lit("Engagement"))
     .otherwise(F.lit("Contact"))
)
_is_qualifying = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit(1))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit(1))
     .otherwise(F.lit(0))
     .cast("int")
)
_key_exprs = [F.coalesce(F.col(c).cast("string"), F.lit("N/A")) for c in _KEY_COLS]

activity_desc_df = (
    activity_desc_df
    .withColumn("funnel_stage",              _funnel_stage)
    .withColumn("is_qualifying_action_flag", _is_qualifying)
    .withColumn(_surrogate_key_col, make_surrogate_key(*_key_exprs))  # noqa: F821 # type: ignore[name-defined]
    .select(
        _surrogate_key_col,
        "activity_object",
        "activity_type", "activity_subtype", "subject_type", "subject_sub_type", "call_type",
        "status", "priority", "is_high_priority", "is_closed", "call_disposition",
        "group_event_type", "show_as", "is_all_day", "is_group_event",
        "funnel_stage", "is_qualifying_action_flag",
    )
)

gold_count = activity_desc_df.count()
print(f"  Transformed rows : {gold_count:,}")
activity_desc_df.groupBy("activity_object").count().show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD1) + Not-Applicable row
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Loading via GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

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

from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]
_na_df = spark.range(1).select(
    F.lit(-1).cast("long").alias("campaign_activity_key"),
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
    .merge(_na_df.alias("src"), "tgt.campaign_activity_key = src.campaign_activity_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Not-Applicable row (campaign_activity_key=-1) ensured")


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)
print("\n" + "=" * 65)
print("  nb_gold_dim_campaign_activity — COMPLETE")
print(f"  Distinct combinations : {source_count:,}")
print(f"  Rows written          : {gold_count:,}")
print(f"  Elapsed               : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
