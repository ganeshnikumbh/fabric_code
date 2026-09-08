#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_activity
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


# Notebook: nb_gold_fact_activity
# Layer:    Gold
# Purpose:  Transaction fact.  One row per task or event; the two sources are
#           unioned and activity_class separates them.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.7
# Build order: 7 of 10.
#
# Write pattern: the batch identified by p_ingestion_date is written with
#                replaceWhere on snapshot_date_key, so re-running a date is
#                idempotent and a restatement of that batch replaces it.
#                NOTE: mapping section 2.8 lists this fact as unpartitioned.
#                It is partitioned here because replaceWhere is what makes the
#                re-run safe.  Drop the partition only if you also replace the
#                write strategy.
#
# Expected unresolved foreign keys (mapping section 4 — these are normal, not
# defects):
#   campaign_key : ~99% on tasks, ~37% on events (only events carry a 701 what_id)
#   agent_key    : low on tasks, ~98% on events  (what_id is 001 on every task)
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - All six gold dimensions (1-6 in the build order) must already be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_activity").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_activity"
_is_scd2           = False
_surrogate_key_col = "activity_key"
_hash_col          = "md5_hash"
# activity_id is unique across task and event by construction, so it alone is
# the business key — the surrogate stays stable across runs.
_business_key_cols = ["activity_id"]

p_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print("=" * 65)
print("  nb_gold_fact_activity — START")
print("=" * 65)
print(f"  target             : {_target_table}")
print(f"  ingestion_date     : {p_ingestion_date}")
print(f"  snapshot_date_key  : {p_snapshot_date_key}")
print(f"  src_busn_asst      : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Shared agent lookup (mapping section 2.7)
# ══════════════════════════════════════════════════════════════════════════════

spark.sql("""
CREATE OR REPLACE TEMP VIEW agent_lookup AS
SELECT
    x.agent_id,
    x.source_contact_id,
    x.source_account_id,
    a.agent_key
FROM lh_gold.gold.dim_agent_extended_salesforce x
JOIN lh_gold.gold.dim_agent a
  ON a.agent_id = x.agent_id AND a.is_current = 1
WHERE x.is_current = 1
""")

print("  TEMP VIEW agent_lookup created")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Read, union and resolve
# ══════════════════════════════════════════════════════════════════════════════
#
# activity_base unions the two sources into one shape.  The thirteen junk
# attributes are derived here with exactly the same expressions as
# nb_gold_dim_activity_type uses, so the junk-dimension join below matches.

print(f"\n[1/4] Reading task and event for ingestion_date = {p_ingestion_date}")

activity_df = spark.sql(f"""
WITH activity_base AS (

    -- ══ Tasks ═════════════════════════════════════════════════════════════
    SELECT
        NULLIF(TRIM(t.id), 'NOT_PROVIDED')                                  AS activity_id,
        'Task'                                                              AS activity_class,
        NULLIF(TRIM(t.subject), 'NOT_PROVIDED')                             AS activity_subject,

        -- Timestamps (3000-01-01 is the silver NULL sentinel)
        COALESCE(
            CASE WHEN t.completed_date_time >= TIMESTAMP'3000-01-01' THEN NULL
                 ELSE t.completed_date_time END,
            CASE WHEN t.activity_date >= DATE'3000-01-01' THEN NULL
                 ELSE CAST(t.activity_date AS TIMESTAMP) END
        )                                                                   AS activity_datetime,
        CAST(NULL AS TIMESTAMP)                                             AS activity_end_datetime,
        CASE WHEN t.created_date >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE t.created_date END                                        AS created_datetime,
        CASE WHEN t.completed_date_time >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE t.completed_date_time END                                 AS completed_datetime,
        CASE WHEN t.follow_up_date_c >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE CAST(t.follow_up_date_c AS DATE) END                      AS follow_up_date,

        -- Source ids used for foreign key resolution
        NULLIF(TRIM(t.what_id),        'NOT_PROVIDED')                      AS what_id,
        NULLIF(TRIM(t.campaign_name_c),'NOT_PROVIDED')                      AS campaign_name,
        NULLIF(TRIM(t.product_c),      'NOT_PROVIDED')                      AS product_name,
        NULLIF(TRIM(t.owner_id),       'NOT_PROVIDED')                      AS owner_id,
        NULLIF(TRIM(t.created_by_id),  'NOT_PROVIDED')                      AS created_by_id,

        -- Measures
        CAST(0 AS INT)                                                      AS duration_minutes,
        CASE WHEN t.completed_date_time >= TIMESTAMP'3000-01-01'
               OR t.created_date        >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE CAST((UNIX_TIMESTAMP(t.completed_date_time)
                        - UNIX_TIMESTAMP(t.created_date)) / 60 AS INT)
        END                                                                 AS minutes_to_complete,
        CAST(t.sum_of_initial_premium_c AS DECIMAL(18,2))                   AS initial_premium_amount,

        -- Flags
        CAST(COALESCE(t.is_closed, 0)        AS TINYINT)                    AS is_completed,
        CASE WHEN TRIM(t.call_type_c) = 'Inbound'  THEN 1 ELSE 0 END        AS is_inbound_call,
        CASE WHEN TRIM(t.call_type_c) = 'Outbound' THEN 1 ELSE 0 END        AS is_outbound_call,
        CAST(COALESCE(t.is_high_priority, 0) AS TINYINT)                    AS is_high_priority,
        CAST(COALESCE(t.first_contract_c, 0) AS TINYINT)                    AS is_first_contract,
        CASE WHEN t.follow_up_date_c IS NOT NULL
              AND t.follow_up_date_c < TIMESTAMP'3000-01-01' THEN 1 ELSE 0 END
                                                                            AS is_follow_up_required,
        CAST(COALESCE(t.is_archived, 0)      AS TINYINT)                    AS is_deleted,

        -- Junk dimension attributes — must match nb_gold_dim_activity_type
        COALESCE(NULLIF(TRIM(t.task_subtype),       'NOT_PROVIDED'), 'Unknown') AS activity_subtype,
        COALESCE(NULLIF(TRIM(t.type),               'NOT_PROVIDED'), 'Unknown') AS activity_category,
        COALESCE(NULLIF(TRIM(t.call_type_c),        'NOT_PROVIDED'), 'Unknown') AS call_direction,
        COALESCE(NULLIF(TRIM(t.subject_type_c),     'NOT_PROVIDED'), 'Unknown') AS subject_type,
        COALESCE(NULLIF(TRIM(t.subject_sub_type_c), 'NOT_PROVIDED'), 'Unknown') AS subject_sub_type,
        COALESCE(NULLIF(TRIM(t.status),             'NOT_PROVIDED'), 'Unknown') AS activity_status,
        COALESCE(NULLIF(TRIM(t.priority),           'NOT_PROVIDED'), 'Unknown') AS priority_level,
        'Unknown'                                                               AS availability_status,
        CAST(0 AS TINYINT)                                                      AS is_all_day_event,
        CAST(COALESCE(t.is_recurrence, 0) AS TINYINT)                           AS is_recurring
    FROM lh_silver.silver_s2.task t
    WHERE t.ingestion_date = '{p_ingestion_date}'

    UNION ALL

    -- ══ Events ════════════════════════════════════════════════════════════
    SELECT
        NULLIF(TRIM(e.id), 'NOT_PROVIDED')                                  AS activity_id,
        'Event'                                                             AS activity_class,
        NULLIF(TRIM(e.subject), 'NOT_PROVIDED')                             AS activity_subject,

        COALESCE(
            CASE WHEN e.activity_date_time >= TIMESTAMP'3000-01-01' THEN NULL
                 ELSE e.activity_date_time END,
            CASE WHEN e.start_date_time    >= TIMESTAMP'3000-01-01' THEN NULL
                 ELSE e.start_date_time    END
        )                                                                   AS activity_datetime,
        CASE WHEN e.end_date_time >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE e.end_date_time END                                       AS activity_end_datetime,
        CASE WHEN e.created_date  >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE e.created_date  END                                       AS created_datetime,
        CAST(NULL AS TIMESTAMP)                                             AS completed_datetime,
        CASE WHEN e.follow_up_date_c >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE CAST(e.follow_up_date_c AS DATE) END                      AS follow_up_date,

        NULLIF(TRIM(e.what_id),        'NOT_PROVIDED')                      AS what_id,
        NULLIF(TRIM(e.campaign_name_c),'NOT_PROVIDED')                      AS campaign_name,
        NULLIF(TRIM(e.product_c),      'NOT_PROVIDED')                      AS product_name,
        NULLIF(TRIM(e.owner_id),       'NOT_PROVIDED')                      AS owner_id,
        NULLIF(TRIM(e.created_by_id),  'NOT_PROVIDED')                      AS created_by_id,

        -- All-day events carry 1440 at source; that is the real value, kept as is.
        CAST(COALESCE(e.duration_in_minutes, 0) AS INT)                     AS duration_minutes,
        CAST(NULL AS INT)                                                   AS minutes_to_complete,
        CAST(e.sum_of_initial_premium_c AS DECIMAL(18,2))                   AS initial_premium_amount,

        -- An event that is on the calendar is treated as complete.
        CAST(1 AS TINYINT)                                                  AS is_completed,
        CASE WHEN TRIM(e.call_type_c) = 'Inbound'  THEN 1 ELSE 0 END        AS is_inbound_call,
        CASE WHEN TRIM(e.call_type_c) = 'Outbound' THEN 1 ELSE 0 END        AS is_outbound_call,
        CAST(0 AS TINYINT)                                                  AS is_high_priority,
        CAST(COALESCE(e.first_contract_c, 0) AS TINYINT)                    AS is_first_contract,
        CASE WHEN e.follow_up_date_c IS NOT NULL
              AND e.follow_up_date_c < TIMESTAMP'3000-01-01' THEN 1 ELSE 0 END
                                                                            AS is_follow_up_required,
        CAST(COALESCE(e.is_archived, 0)      AS TINYINT)                    AS is_deleted,

        COALESCE(NULLIF(TRIM(e.event_subtype),      'NOT_PROVIDED'), 'Unknown') AS activity_subtype,
        COALESCE(NULLIF(TRIM(e.type),               'NOT_PROVIDED'), 'Unknown') AS activity_category,
        COALESCE(NULLIF(TRIM(e.call_type_c),        'NOT_PROVIDED'), 'Unknown') AS call_direction,
        COALESCE(NULLIF(TRIM(e.subject_type_c),     'NOT_PROVIDED'), 'Unknown') AS subject_type,
        COALESCE(NULLIF(TRIM(e.subject_sub_type_c), 'NOT_PROVIDED'), 'Unknown') AS subject_sub_type,
        'Unknown'                                                               AS activity_status,
        'Unknown'                                                               AS priority_level,
        COALESCE(NULLIF(TRIM(e.show_as),            'NOT_PROVIDED'), 'Unknown') AS availability_status,
        CAST(COALESCE(e.is_all_day_event, 0) AS TINYINT)                        AS is_all_day_event,
        CAST(COALESCE(e.is_recurrence, 0)    AS TINYINT)                        AS is_recurring
    FROM lh_silver.silver_s2.event e
    WHERE e.ingestion_date = '{p_ingestion_date}'
)

SELECT
    ab.activity_id,
    CAST({p_snapshot_date_key} AS INT)                                      AS snapshot_date_key,

    -- ── Time ──────────────────────────────────────────────────────────────
    ab.activity_datetime,
    ab.activity_end_datetime,
    ab.created_datetime,
    ab.completed_datetime,
    ab.follow_up_date,

    -- ── Degenerate dimensions ─────────────────────────────────────────────
    ab.activity_class,
    ab.activity_subject,
    -- Raw polymorphic id, kept for audit and for prefixes other than 001/701.
    ab.what_id                                                              AS related_record_id,

    -- ── Dimension foreign keys ────────────────────────────────────────────
    CAST(COALESCE(dat.activity_type_key, -1) AS BIGINT)                     AS activity_type_key,
    -- Tasks: what_id is a 001 account id.  Events: fall back to account_id.
    CAST(COALESCE(al.agent_key, -1) AS BIGINT)                              AS agent_key,
    -- Events: what_id with a 701 prefix is a campaign id.
    -- Tasks:  fall back to matching campaign_name_c by name.
    CAST(COALESCE(dc_id.campaign_key, dc_nm.campaign_key, -1) AS BIGINT)    AS campaign_key,
    CAST(COALESCE(dp.product_key,  -1) AS BIGINT)                           AS product_key,
    CAST(COALESCE(du_own.user_key, -1) AS BIGINT)                           AS owner_user_key,
    CAST(COALESCE(du_cre.user_key, -1) AS BIGINT)                           AS created_by_user_key,

    -- ── Measures ──────────────────────────────────────────────────────────
    CAST(1 AS INT)                                                          AS activity_count,
    ab.duration_minutes,
    ab.minutes_to_complete,
    ab.initial_premium_amount,

    -- ── Flags ─────────────────────────────────────────────────────────────
    ab.is_completed,
    ab.is_inbound_call,
    ab.is_outbound_call,
    ab.is_high_priority,
    ab.is_first_contract,
    ab.is_follow_up_required,
    ab.is_deleted

FROM activity_base ab

-- ── Junk dimension: matched on the full attribute combination ─────────────
LEFT JOIN lh_gold.gold.dim_activity_type dat
       ON dat.activity_class      = ab.activity_class
      AND dat.activity_subtype    = ab.activity_subtype
      AND dat.activity_category   = ab.activity_category
      AND dat.call_direction      = ab.call_direction
      AND dat.subject_type        = ab.subject_type
      AND dat.subject_sub_type    = ab.subject_sub_type
      AND dat.activity_status     = ab.activity_status
      AND dat.priority_level      = ab.priority_level
      AND dat.availability_status = ab.availability_status
      AND dat.is_high_priority    = ab.is_high_priority
      AND dat.is_closed           = ab.is_completed
      AND dat.is_all_day_event    = ab.is_all_day_event
      AND dat.is_recurring        = ab.is_recurring

-- ── Agent: account id path ────────────────────────────────────────────────
LEFT JOIN agent_lookup al
       ON al.source_account_id = ab.what_id

-- ── Campaign: id path (events), then name path (tasks) ────────────────────
LEFT JOIN lh_gold.gold.dim_campaign dc_id
       ON dc_id.campaign_id = ab.what_id
      AND dc_id.is_current  = 1
LEFT JOIN lh_gold.gold.dim_campaign dc_nm
       ON dc_nm.campaign_name = ab.campaign_name
      AND dc_nm.is_current    = 1

-- ── Product ───────────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_product dp
       ON dp.product_name = ab.product_name

-- ── Internal users ────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du_own
       ON du_own.source_user_id = ab.owner_id
      AND du_own.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_cre
       ON du_cre.source_user_id = ab.created_by_id
      AND du_cre.is_current     = 1

WHERE ab.activity_id IS NOT NULL
""")

source_count = activity_df.count()
print(f"  Activities read : {source_count:,}")
display(activity_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Enforce the grain
# ══════════════════════════════════════════════════════════════════════════════
# dim_campaign is joined twice (id path and name path).  If the name path ever
# matched more than one current campaign the join would fan out, so collapse to
# one row per activity_id before writing.

activity_df = activity_df.dropDuplicates(["activity_id"])

gold_count = activity_df.count()
print(f"\n[2/4] Rows after grain enforcement : {gold_count:,}")
if gold_count != source_count:
    print(f"  WARNING: {source_count - gold_count:,} fan-out row(s) collapsed — "
          f"check dim_campaign for duplicate campaign_name")
display(activity_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Load via GoldLoader
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = activity_df,
    target_table        = _target_table,
    is_scd2             = _is_scd2,
    business_key_cols   = _business_key_cols,
    surrogate_key_col   = _surrogate_key_col,
    hash_col            = _hash_col,
    partition_cols      = ["snapshot_date_key"],
    ingestion_date      = p_ingestion_date,
    data_timestamp      = p_ingestion_timestamp,
    source_system       = "Salesforce",
    ingestion_run_id    = p_ingestion_run_id,
    ingestion_timestamp = p_ingestion_timestamp,
    src_busn_asst       = p_src_busn_asst,
    replace_where       = f"snapshot_date_key = {p_snapshot_date_key}",
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Data quality (mapping document section 4, checks 3, 5, 7, 10, 12)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT activity_id FROM {_target_table}
        GROUP BY activity_id HAVING COUNT(*) > 1
     ))                                                        AS dup_activity_ids,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_completed IS NULL    OR is_completed    NOT IN (0, 1)
         OR is_inbound_call IS NULL OR is_inbound_call NOT IN (0, 1)
         OR is_outbound_call IS NULL OR is_outbound_call NOT IN (0, 1)
         OR is_high_priority IS NULL OR is_high_priority NOT IN (0, 1)
         OR is_first_contract IS NULL OR is_first_contract NOT IN (0, 1)
         OR is_follow_up_required IS NULL OR is_follow_up_required NOT IN (0, 1)
         OR is_deleted IS NULL     OR is_deleted     NOT IN (0, 1))
                                                               AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table} f
      WHERE NOT EXISTS (SELECT 1 FROM lh_gold.gold.dim_date d
                        WHERE d.date_key = f.snapshot_date_key))
                                                               AS orphan_snapshot_date_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE snapshot_date_key = {p_snapshot_date_key} AND agent_key    = -1)
                                                               AS unresolved_agent_key,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE snapshot_date_key = {p_snapshot_date_key} AND campaign_key = -1)
                                                               AS unresolved_campaign_key,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE duration_minutes < 0 OR minutes_to_complete < 0)    AS negative_durations
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate activity_id      : {_dq['dup_activity_ids']}          [hard]")
print(f"  bad flag rows              : {_dq['bad_flag_rows']}          [hard]")
print(f"  orphan snapshot_date_key   : {_dq['orphan_snapshot_date_keys']}          [hard]")
print(f"  unresolved agent_key (-1)  : {_dq['unresolved_agent_key']}          [soft]")
print(f"  unresolved campaign_key(-1): {_dq['unresolved_campaign_key']}          [soft]")
print(f"  negative durations         : {_dq['negative_durations']}          [soft]")

if (_dq["dup_activity_ids"] or _dq["bad_flag_rows"]
        or _dq["orphan_snapshot_date_keys"]):
    raise ValueError(f"[nb_gold_fact_activity] Hard data quality check failed: {_dq}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_activity — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
