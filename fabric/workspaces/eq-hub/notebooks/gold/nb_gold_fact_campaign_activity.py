#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_campaign_activity
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


# Notebook: nb_gold_fact_campaign_activity
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.fact_campaign_activity.
#
#           GRAIN: one Salesforce Activity (Task OR Event) — design doc §3A.
#           Task (00T…) and Event (00U…) IDs never collide, so sf_activity_id is a
#           clean degenerate key. Merged natively (SF subtypes both from Activity).
#
#           SILVER SOURCE COLUMNS: from schema_config_salesforce_v2.sql
#           (silver_column_name) — lh_silver.silver_s2.task and .event.
#
#           CAMPAIGN LINKAGE (design doc §3A.1) — two paths, both LEFT JOINs:
#             • Event → Campaign ID join  : event.what_id (701…) = dim_campaign.sf_campaign_id
#             • Task  → Campaign NAME join: UPPER(TRIM(task.campaign_name_c)) = normalised dim_campaign.campaign_name
#           campaign_match_method records which path resolved each row.
#           NAME MATCHING IS LOSSY. The name lookup is pre-deduped to one key per
#           normalised name (MIN) so it cannot fan-out the fact. TODO: replace with
#           a persisted campaign_name_alias table and get the SF team to add a
#           Campaign lookup to the Task extract so this becomes deterministic.
#
#           DURATION (design doc §3A.2): one conformed measure, duration_seconds —
#             Task = call_duration_in_seconds ; Event = duration_in_minutes × 60.
#
#           SPARSE COLUMNS (§3A.3): unused FKs → -1 ; unused flags → NULL (never 0).
#
#           activity_key resolves to dim_campaign_activity BY CONSTRUCTION — the
#           same ordered descriptor list + make_surrogate_key as the junk dim; no
#           join needed.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run first: dim_date, dim_campaign, dim_owner, dim_agent, dim_account,
#     dim_product, and nb_gold_dim_campaign_activity.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_activity").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_activity"
_business_key_cols = ["sf_activity_id"]
_is_scd2           = False
_surrogate_key_col = "campaign_activity_key"
_hash_col          = "md5_hash"

_SRC_TASK  = "lh_silver.silver_s2.task"
_SRC_EVENT = "lh_silver.silver_s2.event"

# Same ordered descriptor list as nb_gold_dim_campaign_activity — activity_key is
# computed identically here so it matches the junk dimension by construction.
_KEY_COLS = [
    "activity_object", "activity_type", "activity_subtype",
    "subject_type", "subject_sub_type", "call_type",
    "status", "priority", "is_high_priority", "is_closed", "call_disposition",
    "group_event_type", "show_as", "is_all_day", "is_group_event",
]

print("=" * 65)
print("  nb_gold_fact_campaign_activity — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read: Task ∪ Event onto one activity grain + resolve FKs via JOINs
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading Task ∪ Event and joining dimensions")

activity_df = spark.sql(f"""
    WITH task_act AS (
        SELECT
            id                                            AS sf_activity_id,
            'Task'                                        AS activity_object,
            subject                                       AS subject,
            activity_date                                 AS activity_date,
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
            CAST(NULL AS INT)                             AS is_group_event,
            who_id                                        AS who_id,
            CAST(NULL AS STRING)                          AS event_campaign_id,
            campaign_name_c                               AS campaign_name_text,
            account_id                                    AS account_id,
            owner_id                                      AS owner_id,
            product_c                                     AS product_name,
            call_duration_in_seconds                      AS duration_seconds,
            sum_of_initial_premium_c                      AS initial_premium,
            CAST(first_contract_c AS INT)                 AS is_first_contract,
            source_system                                 AS source_system,
            ingestion_run_id                              AS ingestion_run_id,
            md5_hash                                       AS src_md5_hash
        FROM {_SRC_TASK}
    ),
    event_act AS (
        SELECT
            id                                            AS sf_activity_id,
            'Event'                                       AS activity_object,
            subject                                       AS subject,
            activity_date                                 AS activity_date,
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
            CAST(is_group_event AS INT)                   AS is_group_event,
            who_id                                        AS who_id,
            what_id                                       AS event_campaign_id,
            CAST(NULL AS STRING)                          AS campaign_name_text,
            account_id                                    AS account_id,
            owner_id                                      AS owner_id,
            product_c                                     AS product_name,
            CAST(ROUND(duration_in_minutes * 60) AS INT)  AS duration_seconds,
            sum_of_initial_premium_c                      AS initial_premium,
            CAST(first_contract_c AS INT)                 AS is_first_contract,
            source_system                                 AS source_system,
            ingestion_run_id                              AS ingestion_run_id,
            md5_hash                                       AS src_md5_hash
        FROM {_SRC_EVENT}
    ),
    activities AS (
        SELECT * FROM task_act
        UNION ALL
        SELECT * FROM event_act
    ),
    -- one campaign_key per normalised campaign name (MIN) so the lossy name
    -- match cannot fan-out the fact into duplicate activity rows.
    camp_name AS (
        SELECT UPPER(TRIM(campaign_name)) AS name_norm, MIN(campaign_key) AS campaign_key
        FROM   lh_gold.gold.dim_campaign
        WHERE  is_current = 1 AND campaign_name IS NOT NULL
        GROUP BY UPPER(TRIM(campaign_name))
    )
    SELECT
        a.*,
        CAST(COALESCE(cid.campaign_key, cnm.campaign_key, -1) AS BIGINT) AS campaign_key,
        CASE WHEN cid.campaign_key IS NOT NULL THEN 'id'
             WHEN cnm.campaign_key IS NOT NULL THEN 'name'
             ELSE 'unmatched' END                                       AS campaign_match_method,
        CAST(COALESCE(dag.agent_key, -1)    AS BIGINT)                  AS agent_key,
        CAST(COALESCE(dow.owner_key, -1)    AS BIGINT)                  AS owner_key,
        CAST(COALESCE(dacc.account_key, -1) AS BIGINT)                  AS account_key,
        CAST(COALESCE(dp.product_key, -1)   AS BIGINT)                  AS product_key
    FROM activities a
    LEFT JOIN lh_gold.gold.dim_campaign cid ON a.event_campaign_id = cid.sf_campaign_id AND cid.is_current = 1
    LEFT JOIN camp_name                 cnm ON UPPER(TRIM(a.campaign_name_text)) = cnm.name_norm
    LEFT JOIN lh_gold.gold.dim_agent    dag ON a.who_id     = dag.sf_contact_id  AND dag.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_owner    dow ON a.owner_id   = dow.sf_user_id     AND dow.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_account  dacc ON a.account_id = dacc.sf_account_id AND dacc.is_current = 1
    LEFT JOIN lh_gold.gold.dim_product  dp  ON a.product_name = dp.product_name  AND dp.is_current   = 1
""")

source_count = activity_df.count()
print(f"  Source activities : {source_count:,}")
activity_df.groupBy("activity_object").count().show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform: date key, junk key (by construction), surrogate, project
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Deriving date_key, activity_key, surrogate key")

# ── activity_date_key (YYYYMMDD LONG — joins lh_gold.gold.dim_date) ────────────
_date_key = F.date_format(F.col("activity_date"), "yyyyMMdd").cast("long")

# ── activity_key by construction (identical to the junk dim) ──────────────────
_key_exprs = [F.coalesce(F.col(c).cast("string"), F.lit("N/A")) for c in _KEY_COLS]

# ── is_qualifying_action (funnel flag on the fact — design doc §4) ────────────
_is_qualifying = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit(1))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit(1))
     .otherwise(F.lit(0))
     .cast("int")
)

activity_df = (
    activity_df
    .withColumn("activity_date_key", F.coalesce(_date_key, F.lit(-1).cast("long")))
    .withColumn("activity_key",      make_surrogate_key(*_key_exprs))  # noqa: F821 # type: ignore[name-defined]
    .withColumn("is_qualifying_action", _is_qualifying)
    .withColumn("duration_seconds",  F.col("duration_seconds").cast("int"))
    .withColumn("initial_premium",   F.col("initial_premium").cast("decimal(18,4)"))
    .withColumn("gold_load_ts_utc",  F.lit(p_ingestion_timestamp).cast("timestamp"))
    .withColumn(_surrogate_key_col,  make_surrogate_key(F.col("sf_activity_id")))  # noqa: F821 # type: ignore[name-defined]
    .select(
        # ── Keys ──────────────────────────────────────────────────────────
        _surrogate_key_col,          # campaign_activity_key
        "sf_activity_id",            # degenerate NK
        "activity_date_key",
        "campaign_key",
        "agent_key",
        "owner_key",
        "account_key",
        "product_key",
        "activity_key",              # junk dimension
        # ── Degenerate dims ───────────────────────────────────────────────
        "activity_object",
        "subject",
        "campaign_match_method",
        # ── Measures ──────────────────────────────────────────────────────
        "duration_seconds",
        "initial_premium",
        # ── Funnel / flags (NULL = does not apply) ────────────────────────
        "is_qualifying_action",
        "is_first_contract",
        # ── Audit / lineage ───────────────────────────────────────────────
        "source_system",
        "ingestion_run_id",
        "src_md5_hash",
        "gold_load_ts_utc",
    )
)

gold_count = activity_df.count()
print(f"  Transformed rows : {gold_count:,}")
print("  campaign_match_method distribution:")
activity_df.groupBy("campaign_match_method").count().orderBy("campaign_match_method").show(truncate=False)
display(activity_df.limit(3))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD1) + null-key validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Loading via GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

_load_start = time.time()
loader.load(
    df                = activity_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    partition_cols    = ["activity_date_key"],
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

print(f"\n[4/4] Null / invalid FK validation (should all be 0)")
_fk_cols = ["activity_date_key", "campaign_key", "agent_key", "owner_key",
            "account_key", "product_key", "activity_key"]
(
    spark.table(_target_table)
    .select([F.sum(F.when(F.col(c).isNull() | (F.col(c) < F.lit(-1)), 1).otherwise(0)).alias(c)
             for c in _fk_cols])
).show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_campaign_activity — COMPLETE")
print(f"  Source activities : {source_count:,}")
print(f"  Rows written      : {gold_count:,}")
print(f"  Elapsed           : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
