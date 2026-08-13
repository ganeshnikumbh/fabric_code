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
# Purpose:  SCD Type-1 load of gold.fact_campaign_activity (Meeting-Campaign star).
#           GRAIN: 1 Salesforce Activity (Task OR Event). sf_activity_id degenerate.
#
#           AGENT LINKAGE — three ranked paths (design §2, drawio page 2). Path A
#           (CampaignMember) is not on the activity, so this fact uses:
#             • Path B who_id           : activity.who_id → dim_agent.sf_contact_id
#             • Path C account_inferred : activity.account_id → single-contact
#               Account → contact.agent_id_c → dim_agent.agent_number
#           agent_key = COALESCE(B, C, -1); agent_link_method records which path
#           won ('who_id' / 'account_inferred' / 'unresolved') so inferred rows can
#           be excluded when precision matters. Path C only fires on accounts with
#           exactly ONE contact (fan-out guard); multi-contact accounts → -1.
#           agent_id_c arrives as float64 ("87306.0") — cast DOUBLE→BIGINT to strip
#           the ".0" (a naive string cast silently misses every join).
#
#           CAMPAIGN LINKAGE (dual path): Event by what_id → sf_campaign_id;
#           Task by normalised campaign_name_c → dim_meeting_campaign.campaign_name
#           (lossy, deduped to one key per name). campaign_match_method records it.
#
#           DURATION conformed to duration_seconds (task: call_duration_in_seconds;
#           event: duration_in_minutes × 60). Sparse FKs → -1; sparse flags → NULL.
#           campaign_activity_key matches dim_campaign_activity BY CONSTRUCTION.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run first: dim_date, dim_time_of_day, dim_meeting_campaign, dim_agent,
#     dim_account, dim_owner, dim_product, dim_channel, dim_campaign_activity.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_activity").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_activity"
_business_key_cols = ["sf_activity_id"]
_is_scd2           = False
_surrogate_key_col = "campaign_activity_fact_key"
_hash_col          = "md5_hash"

_SRC_TASK    = "lh_silver.silver_s2.task"
_SRC_EVENT   = "lh_silver.silver_s2.event"
_SRC_CONTACT = "lh_silver.silver_s2.contact"

# Same ordered descriptor list as nb_gold_dim_campaign_activity — the junk key is
# built identically here so campaign_activity_key matches by construction.
_KEY_COLS = [
    "activity_object", "activity_type", "activity_subtype",
    "subject_type", "subject_sub_type", "call_type",
    "status", "priority", "is_high_priority", "is_closed", "call_disposition",
    "group_event_type", "show_as", "is_all_day", "is_group_event",
]

print("=" * 65)
print("  nb_gold_fact_campaign_activity — START")
print("=" * 65)
print(f"  target : {_target_table}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read: Task ∪ Event + resolve FKs (incl. 3-path agent linkage)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading Task ∪ Event and joining dimensions")

activity_df = spark.sql(f"""
    WITH task_act AS (
        SELECT
            id AS sf_activity_id, 'Task' AS activity_object, subject AS activity_subject,
            CAST(NULL AS STRING) AS location,
            activity_date AS activity_date,
            completed_date_time AS ts_for_time,
            completed_date_time AS completed_ts,
            CAST(NULL AS DATE)  AS end_date_evt,
            type AS activity_type, task_subtype AS activity_subtype,
            subject_type_c AS subject_type, subject_sub_type_c AS subject_sub_type,
            COALESCE(call_type_c, call_type) AS call_type, status AS status, priority AS priority,
            CAST(is_high_priority AS INT) AS is_high_priority, CAST(is_closed AS INT) AS is_closed,
            call_disposition AS call_disposition,
            CAST(NULL AS STRING) AS group_event_type, CAST(NULL AS STRING) AS show_as,
            CAST(NULL AS INT) AS is_all_day, CAST(NULL AS INT) AS is_group_event,
            who_id AS who_id, CAST(NULL AS STRING) AS event_campaign_id, campaign_name_c AS campaign_name_text,
            account_id AS account_id, owner_id AS owner_id, host_c AS host_c, product_c AS product_name,
            call_duration_in_seconds AS duration_seconds,
            sum_of_initial_premium_c AS initial_premium, CAST(first_contract_c AS INT) AS is_first_contract,
            CAST(is_closed AS INT) AS is_completed_flag,
            CASE WHEN call_duration_in_seconds > 0 THEN 1 ELSE 0 END AS is_answered_flag,
            CAST(NULL AS INT) AS is_attended_flag,
            CAST(is_high_priority AS INT) AS is_high_priority_flag,
            CAST(NULL AS INT) AS is_all_day_flag,
            CAST(is_recurrence AS INT) AS is_recurrence_flag,
            source_system, ingestion_run_id, md5_hash AS src_md5_hash
        FROM {_SRC_TASK}
    ),
    event_act AS (
        SELECT
            id AS sf_activity_id, 'Event' AS activity_object, subject AS activity_subject,
            location AS location,
            activity_date AS activity_date,
            activity_date_time AS ts_for_time,
            CAST(NULL AS TIMESTAMP) AS completed_ts,
            end_date AS end_date_evt,
            type AS activity_type, event_subtype AS activity_subtype,
            subject_type_c AS subject_type, subject_sub_type_c AS subject_sub_type,
            call_type_c AS call_type, CAST(NULL AS STRING) AS status, CAST(NULL AS STRING) AS priority,
            CAST(NULL AS INT) AS is_high_priority, CAST(NULL AS INT) AS is_closed,
            CAST(NULL AS STRING) AS call_disposition,
            group_event_type AS group_event_type, show_as AS show_as,
            CAST(is_all_day_event AS INT) AS is_all_day, CAST(is_group_event AS INT) AS is_group_event,
            who_id AS who_id, what_id AS event_campaign_id, CAST(NULL AS STRING) AS campaign_name_text,
            account_id AS account_id, owner_id AS owner_id, host_c AS host_c, product_c AS product_name,
            CAST(ROUND(duration_in_minutes * 60) AS INT) AS duration_seconds,
            sum_of_initial_premium_c AS initial_premium, CAST(first_contract_c AS INT) AS is_first_contract,
            CAST(NULL AS INT) AS is_completed_flag,
            CAST(NULL AS INT) AS is_answered_flag,
            CAST(1 AS INT) AS is_attended_flag,
            CAST(NULL AS INT) AS is_high_priority_flag,
            CAST(is_all_day_event AS INT) AS is_all_day_flag,
            CAST(is_recurrence AS INT) AS is_recurrence_flag,
            source_system, ingestion_run_id, md5_hash AS src_md5_hash
        FROM {_SRC_EVENT}
    ),
    activities AS ( SELECT * FROM task_act UNION ALL SELECT * FROM event_act ),
    -- Path C map: single-contact accounts → that contact's agent number (BIGINT,
    -- ".0" stripped). HAVING COUNT(*)=1 is the fan-out guard; multi-contact
    -- accounts are excluded and fall through to the -1 Unknown Agent member.
    acct_single_agent AS (
        SELECT account_id,
               MAX(CAST(CAST(agent_id_c AS DOUBLE) AS BIGINT)) AS agent_number_norm
        FROM   {_SRC_CONTACT}
        WHERE  account_id IS NOT NULL AND agent_id_c IS NOT NULL
        GROUP BY account_id
        HAVING COUNT(*) = 1
    ),
    -- one meeting_campaign_key per normalised campaign name (deduped → no fan-out)
    camp_name AS (
        SELECT UPPER(TRIM(campaign_name)) AS name_norm, MIN(meeting_campaign_key) AS meeting_campaign_key
        FROM   lh_gold.gold.dim_meeting_campaign
        WHERE  is_current = 1 AND campaign_name IS NOT NULL
        GROUP BY UPPER(TRIM(campaign_name))
    )
    SELECT
        a.*,
        CAST(COALESCE(cid.meeting_campaign_key, cnm.meeting_campaign_key, -1) AS BIGINT) AS meeting_campaign_key,
        CASE WHEN cid.meeting_campaign_key IS NOT NULL THEN 'id'
             WHEN cnm.meeting_campaign_key IS NOT NULL THEN 'name' ELSE 'unmatched' END  AS campaign_match_method,
        CAST(COALESCE(dab.agent_key, dac.agent_key, -1) AS BIGINT)                       AS agent_key,
        CASE WHEN dab.agent_key IS NOT NULL THEN 'who_id'
             WHEN dac.agent_key IS NOT NULL THEN 'account_inferred' ELSE 'unresolved' END AS agent_link_method,
        CAST(COALESCE(dow.owner_key, -1)   AS BIGINT)  AS owner_key,
        CAST(COALESCE(dho.owner_key, -1)   AS BIGINT)  AS host_owner_key,
        CAST(COALESCE(dacc.account_key, -1) AS BIGINT) AS account_key,
        CAST(COALESCE(dp.product_key, -1)  AS BIGINT)  AS product_key,
        CAST(COALESCE(dch.channel_key, -1) AS BIGINT)  AS channel_key
    FROM activities a
    LEFT JOIN lh_gold.gold.dim_meeting_campaign cid ON a.event_campaign_id = cid.sf_campaign_id AND cid.is_current = 1
    LEFT JOIN camp_name                         cnm ON UPPER(TRIM(a.campaign_name_text)) = cnm.name_norm
    LEFT JOIN lh_gold.gold.dim_agent   dab ON a.who_id = dab.sf_contact_id AND dab.is_current = 1
    LEFT JOIN acct_single_agent        asa ON a.account_id = asa.account_id
    LEFT JOIN lh_gold.gold.dim_agent   dac ON asa.agent_number_norm = dac.agent_number AND dac.is_current = 1
    LEFT JOIN lh_gold.gold.dim_owner   dow ON a.owner_id = dow.sf_user_id AND dow.is_current = 1
    LEFT JOIN lh_gold.gold.dim_owner   dho ON a.host_c   = dho.sf_user_id AND dho.is_current = 1
    LEFT JOIN lh_gold.gold.dim_account dacc ON a.account_id = dacc.sf_account_id AND dacc.is_current = 1
    LEFT JOIN lh_gold.gold.dim_product dp  ON a.product_name = dp.product_name AND dp.is_current = 1
    LEFT JOIN lh_gold.gold.dim_channel dch
           ON dch.channel_name = CASE WHEN a.activity_object = 'Task' THEN 'Call' ELSE cid.campaign_type END
          AND dch.is_current = 1
""")

source_count = activity_df.count()
print(f"  Source activities : {source_count:,}")
activity_df.groupBy("activity_object").count().show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform: role-playing date/time keys, junk key, surrogate, project
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Deriving date/time keys, campaign_activity_key, surrogate key")

def _date_key(colname):
    return F.coalesce(F.date_format(F.col(colname), "yyyyMMdd").cast("long"), F.lit(-1).cast("long"))

_key_exprs = [F.coalesce(F.col(c).cast("string"), F.lit("N/A")) for c in _KEY_COLS]

_is_qualifying = (
    F.when(F.col("activity_object") == F.lit("Event"), F.lit(1))
     .when(F.lower(F.coalesce(F.col("subject_type"), F.lit(""))).isin(
         "transfer call", "illustration"), F.lit(1))
     .otherwise(F.lit(0))
     .cast("int")
)

activity_df = (
    activity_df
    .withColumn("activity_date_key",  _date_key("activity_date"))
    .withColumn("activity_time_key",
        F.coalesce(F.date_format(F.col("ts_for_time"), "HHmmss").cast("long"), F.lit(-1).cast("long")))
    .withColumn("completed_date_key", _date_key("completed_ts"))
    .withColumn("end_date_key",       _date_key("end_date_evt"))
    .withColumn("campaign_activity_key", make_surrogate_key(*_key_exprs))  # noqa: F821 # type: ignore[name-defined]
    .withColumn("is_qualifying_action", _is_qualifying)
    .withColumn("activity_count",  F.lit(1).cast("int"))
    .withColumn("duration_seconds", F.col("duration_seconds").cast("int"))
    .withColumn("sum_of_initial_premium", F.col("initial_premium").cast("decimal(18,4)"))
    .withColumn("days_open_to_complete",
        F.when(F.col("activity_object") == F.lit("Task"),
               F.datediff(F.col("completed_ts").cast("date"), F.col("activity_date"))))
    .withColumn("first_contract_flag", F.col("is_first_contract"))
    .withColumn("gold_load_ts_utc", F.lit(p_ingestion_timestamp).cast("timestamp"))
    .withColumn(_surrogate_key_col, make_surrogate_key(F.col("sf_activity_id")))  # noqa: F821 # type: ignore[name-defined]
    .select(
        # ── Keys ──────────────────────────────────────────────────────────
        _surrogate_key_col,
        "sf_activity_id",
        "activity_date_key", "activity_time_key", "completed_date_key", "end_date_key",
        "agent_key", "account_key", "owner_key", "host_owner_key",
        "meeting_campaign_key", "product_key", "campaign_activity_key", "channel_key",
        # ── Degenerate dims ───────────────────────────────────────────────
        "activity_object", "activity_subject", "location",
        "campaign_match_method", "agent_link_method",
        # ── Conformed measures ────────────────────────────────────────────
        "activity_count", "duration_seconds", "sum_of_initial_premium", "days_open_to_complete",
        # ── Flags (NULL = does not apply) ─────────────────────────────────
        "is_completed_flag", "is_answered_flag", "is_attended_flag",
        "is_high_priority_flag", "is_all_day_flag", "is_recurrence_flag",
        "is_qualifying_action", "first_contract_flag",
        # ── Audit / lineage ───────────────────────────────────────────────
        "source_system", "ingestion_run_id", "src_md5_hash", "gold_load_ts_utc",
    )
)

gold_count = activity_df.count()
print(f"  Transformed rows : {gold_count:,}")
print("  agent_link_method distribution:")
activity_df.groupBy("agent_link_method").count().orderBy("agent_link_method").show(truncate=False)
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
_fk_cols = ["activity_date_key", "agent_key", "account_key", "owner_key", "host_owner_key",
            "meeting_campaign_key", "product_key", "campaign_activity_key", "channel_key"]
(
    spark.table(_target_table)
    .select([F.sum(F.when(F.col(c).isNull() | (F.col(c) < F.lit(-1)), 1).otherwise(0)).alias(c)
             for c in _fk_cols])
).show(truncate=False)


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)
print("\n" + "=" * 65)
print("  nb_gold_fact_campaign_activity — COMPLETE")
print(f"  Source activities : {source_count:,}")
print(f"  Rows written      : {gold_count:,}")
print(f"  Elapsed           : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
