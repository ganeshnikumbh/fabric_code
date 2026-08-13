#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_meeting_campaign
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


# Notebook: nb_gold_dim_meeting_campaign
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_meeting_campaign (Salesforce Campaign 701).
#           One row per Salesforce campaign — webinars, conferences, office visits,
#           telemarketing. NK = sf_campaign_id.
#
#           SELF-REFERENCE: parent_campaign_key is set BY CONSTRUCTION —
#           make_surrogate_key(parent_id), i.e. the parent campaign's own key
#           (same deterministic hash used for meeting_campaign_key). No self-join,
#           no two-pass. Unset/absent parent → -1. The full hierarchy roll-up lives
#           in bridge_meeting_campaign_hierarchy (separate object).
#
#           STRING custom booleans (speaking_event_c, booth_needed_c) are derived
#           to 1/0/NULL flags.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_meeting_campaign").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_meeting_campaign"
_business_key_cols = ["sf_campaign_id"]
_is_scd2           = True
_surrogate_key_col = "meeting_campaign_key"
_hash_col          = "md5_hash"

_SRC_CAMPAIGN = "lh_silver.silver_s2.campaign"

print("=" * 65)
print("  nb_gold_dim_meeting_campaign — START")
print("=" * 65)
print(f"  target  : {_target_table}   (SCD2={_is_scd2})")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read campaign attributes
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading {_SRC_CAMPAIGN}")

camp_df = spark.sql(f"""
    SELECT
        id                                            AS sf_campaign_id,
        parent_id                                     AS sf_parent_campaign_id,
        name                                          AS campaign_name,
        type                                          AS campaign_type,
        status                                        AS campaign_status,
        line_of_business_c                            AS line_of_business,
        topic_c                                       AS topic,
        product_c                                     AS product_focus,
        start_date                                    AS start_date,
        end_date                                      AS end_date,
        CAST(is_active AS INT)                        AS is_active,
        record_type_id                                AS record_type,
        campaign_quarter_c                            AS campaign_quarter,
        CASE WHEN LOWER(TRIM(speaking_event_c)) IN ('true','yes','y','1') THEN 1
             WHEN speaking_event_c IS NULL THEN NULL ELSE 0 END  AS is_speaking_event,
        CAST(webinar_recorded_c AS INT)              AS is_webinar_recorded,
        CASE WHEN LOWER(TRIM(booth_needed_c)) IN ('true','yes','y','1') THEN 1
             WHEN booth_needed_c IS NULL THEN NULL ELSE 0 END    AS booth_needed
    FROM {_SRC_CAMPAIGN}
""")

source_count = camp_df.count()
print(f"  Source campaigns : {source_count:,}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Surrogate key + self-ref parent key (by construction)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Building keys")

camp_df = (
    camp_df
    .withColumn(_surrogate_key_col, make_surrogate_key(F.col("sf_campaign_id")))  # noqa: F821 # type: ignore[name-defined]
    # parent's key = same deterministic hash on the parent's business key
    .withColumn("parent_campaign_key",
        F.when(F.col("sf_parent_campaign_id").isNotNull(),
               make_surrogate_key(F.col("sf_parent_campaign_id")))  # noqa: F821 # type: ignore[name-defined]
         .otherwise(F.lit(-1).cast("long")))
    .select(
        _surrogate_key_col, "sf_campaign_id",
        "campaign_name", "campaign_type", "campaign_status", "line_of_business",
        "topic", "product_focus", "start_date", "end_date", "is_active",
        "record_type", "campaign_quarter",
        "is_speaking_event", "is_webinar_recorded", "booth_needed",
        "parent_campaign_key", "sf_parent_campaign_id",
    )
)

gold_count = camp_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(camp_df.limit(3))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD2) + Unknown row
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Loading via GoldLoader (SCD2)")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

_load_start = time.time()
loader.load(
    df                = camp_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]
_na = spark.range(1).select(
    F.lit(-1).cast("long").alias("meeting_campaign_key"),
    F.lit("N/A").alias("sf_campaign_id"),
    F.lit("Unknown Campaign").alias("campaign_name"),
    *[F.lit(None).cast("string").alias(c) for c in
      ("campaign_type", "campaign_status", "line_of_business", "topic", "product_focus",
       "record_type", "campaign_quarter", "sf_parent_campaign_id")],
    *[F.lit(None).cast("date").alias(c) for c in ("start_date", "end_date")],
    *[F.lit(None).cast("int").alias(c) for c in
      ("is_active", "is_speaking_event", "is_webinar_recorded", "booth_needed")],
    F.lit(-1).cast("long").alias("parent_campaign_key"),
    F.lit(None).cast("timestamp").alias("effective_timestamp"),
    F.lit(None).cast("timestamp").alias("expiration_timestamp"),
    F.lit(1).cast("int").alias("is_current"),
    F.lit(None).cast("string").alias("md5_hash"),
)
(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_na.alias("src"), "tgt.meeting_campaign_key = src.meeting_campaign_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (meeting_campaign_key=-1) ensured")


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)
print("\n" + "=" * 65)
print("  nb_gold_dim_meeting_campaign — COMPLETE")
print(f"  Source campaigns : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
