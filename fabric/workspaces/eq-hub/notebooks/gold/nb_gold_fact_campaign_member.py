#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_campaign_member
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


# Notebook: nb_gold_fact_campaign_member
# Layer:    Gold
# Purpose:  Transaction fact.  One row per campaign per member.
#
#           Production amounts on campaign_member are live formula fields that
#           mirror the parent account, so they are deliberately NOT carried
#           here — fact_agent_production_snapshot is the place for them.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.8
# Build order: 8 of 10.
#
# Write pattern: the batch identified by p_ingestion_date is written with
#                replaceWhere on snapshot_date_key, so re-running a date is
#                idempotent.  See the note in nb_gold_fact_activity about the
#                partitioning choice.
#
# Expected unresolved foreign keys (mapping section 4):
#   agent_key : ~6%  (agent_id_c is populated on 94% of rows)
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - gold.dim_campaign, gold.dim_campaign_member_status, gold.dim_user,
#     gold.dim_agent and gold.dim_agent_extended_salesforce must be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_member").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_member"
_is_scd2           = False
_surrogate_key_col = "campaign_member_key"
_hash_col          = "md5_hash"
_business_key_cols = ["campaign_member_id"]

p_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print("=" * 65)
print("  nb_gold_fact_campaign_member — START")
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
# SECTION 3 — Read & resolve
# ══════════════════════════════════════════════════════════════════════════════
#
# agent_key has three resolution paths, tried in order:
#   1. agent_id_c   — the business key, populated on 94% of rows
#   2. account_id   — CRM account record id
#   3. contact_id   — CRM contact record id

print(f"\n[1/4] Reading campaign_member for ingestion_date = {p_ingestion_date}")

member_df = spark.sql(f"""
WITH member_base AS (
    SELECT
        NULLIF(TRIM(cm.id), 'NOT_PROVIDED')                                 AS campaign_member_id,
        NULLIF(TRIM(cm.travel_event_member_auto_number_c), 'NOT_PROVIDED')  AS member_reference_number,
        NULLIF(TRIM(cm.campaign_id), 'NOT_PROVIDED')                        AS source_campaign_id,

        -- Agent resolution inputs
        LPAD(NULLIF(TRIM(cm.agent_id_c), 'NOT_PROVIDED'), 5, '0')           AS agent_id,
        NULLIF(TRIM(cm.account_id), 'NOT_PROVIDED')                         AS source_account_id,
        NULLIF(TRIM(cm.contact_id), 'NOT_PROVIDED')                         AS source_contact_id,

        -- User resolution inputs
        NULLIF(TRIM(cm.assigned_to_c),             'NOT_PROVIDED')          AS assigned_to_id,
        NULLIF(TRIM(cm.created_by_id),             'NOT_PROVIDED')          AS created_by_id,
        NULLIF(TRIM(cm.lead_or_contact_owner_id),  'NOT_PROVIDED')          AS owner_id,

        -- Degenerate: the lead object is not extracted, so there is no dim_lead.
        NULLIF(TRIM(cm.lead_id), 'NOT_PROVIDED')                            AS lead_id,

        -- Timestamps (3000-01-01 is the silver NULL sentinel)
        CASE WHEN cm.created_date >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE cm.created_date END                                       AS member_created_datetime,
        CASE WHEN cm.first_responded_date >= TIMESTAMP'3000-01-01' THEN NULL
             ELSE cm.first_responded_date END                               AS first_responded_datetime,

        CAST(COALESCE(cm.has_responded, 0) AS TINYINT)                      AS is_responded,
        CAST(COALESCE(cm.is_deleted, 0)    AS TINYINT)                      AS is_deleted,

        -- Junk dimension attributes — must match nb_gold_dim_campaign_member_status
        COALESCE(NULLIF(TRIM(cm.status),             'NOT_PROVIDED'), 'Unknown') AS member_status,
        COALESCE(NULLIF(TRIM(cm.type),               'NOT_PROVIDED'), 'Unknown') AS member_type,
        COALESCE(NULLIF(TRIM(cm.call_status_c),      'NOT_PROVIDED'), 'Unknown') AS call_status,
        COALESCE(NULLIF(TRIM(cm.follow_up_status_c), 'NOT_PROVIDED'), 'Unknown') AS follow_up_status,
        COALESCE(NULLIF(TRIM(cm.channel_c),          'NOT_PROVIDED'), 'Unknown') AS channel_name
    FROM lh_silver.silver_s2.campaign_member cm
    WHERE cm.ingestion_date = '{p_ingestion_date}'
)

SELECT
    mb.campaign_member_id,
    CAST({p_snapshot_date_key} AS INT)                                      AS snapshot_date_key,

    -- ── Degenerate dimensions ─────────────────────────────────────────────
    mb.member_reference_number,
    mb.lead_id,

    -- ── Dimension foreign keys ────────────────────────────────────────────
    CAST(COALESCE(dc.campaign_key, -1) AS BIGINT)                           AS campaign_key,
    CAST(COALESCE(al_id.agent_key,
                  al_acc.agent_key,
                  al_con.agent_key, -1) AS BIGINT)                          AS agent_key,
    CAST(COALESCE(dms.member_status_key, -1) AS BIGINT)                     AS member_status_key,
    CAST(COALESCE(du_asg.user_key, -1) AS BIGINT)                           AS assigned_to_user_key,
    CAST(COALESCE(du_cre.user_key, -1) AS BIGINT)                           AS created_by_user_key,
    CAST(COALESCE(du_own.user_key, -1) AS BIGINT)                           AS owner_user_key,

    -- ── Time ──────────────────────────────────────────────────────────────
    mb.member_created_datetime,
    mb.first_responded_datetime,

    -- ── Measures ──────────────────────────────────────────────────────────
    CAST(1 AS INT)                                                          AS member_count,
    CAST(mb.is_responded AS INT)                                            AS responded_count,
    CASE WHEN mb.first_responded_datetime IS NULL
              OR mb.member_created_datetime IS NULL THEN NULL
         ELSE DATEDIFF(mb.first_responded_datetime, mb.member_created_datetime)
    END                                                                     AS days_to_respond,

    -- ── Flags ─────────────────────────────────────────────────────────────
    mb.is_responded,
    mb.is_deleted

FROM member_base mb

-- ── Campaign ──────────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_campaign dc
       ON dc.campaign_id = mb.source_campaign_id
      AND dc.is_current  = 1

-- ── Agent: three resolution paths, first match wins in the COALESCE ───────
LEFT JOIN agent_lookup al_id
       ON al_id.agent_id           = mb.agent_id
LEFT JOIN agent_lookup al_acc
       ON al_acc.source_account_id = mb.source_account_id
LEFT JOIN agent_lookup al_con
       ON al_con.source_contact_id = mb.source_contact_id

-- ── Junk dimension: matched on the full attribute combination ─────────────
LEFT JOIN lh_gold.gold.dim_campaign_member_status dms
       ON dms.member_status    = mb.member_status
      AND dms.member_type      = mb.member_type
      AND dms.call_status      = mb.call_status
      AND dms.follow_up_status = mb.follow_up_status
      AND dms.channel_name     = mb.channel_name
      AND dms.is_responded     = mb.is_responded

-- ── Internal users ────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du_asg
       ON du_asg.source_user_id = mb.assigned_to_id
      AND du_asg.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_cre
       ON du_cre.source_user_id = mb.created_by_id
      AND du_cre.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_own
       ON du_own.source_user_id = mb.owner_id
      AND du_own.is_current     = 1

WHERE mb.campaign_member_id IS NOT NULL
""")

source_count = member_df.count()
print(f"  Campaign members read : {source_count:,}")
display(member_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Enforce the grain
# ══════════════════════════════════════════════════════════════════════════════

member_df = member_df.dropDuplicates(["campaign_member_id"])

gold_count = member_df.count()
print(f"\n[2/4] Rows after grain enforcement : {gold_count:,}")
if gold_count != source_count:
    print(f"  WARNING: {source_count - gold_count:,} fan-out row(s) collapsed — "
          f"check the agent_lookup view for duplicate ids")
display(member_df.limit(5))


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
    df                  = member_df,
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
# SECTION 6 — Data quality (mapping document section 4, checks 3, 5, 6, 10)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT campaign_key, campaign_member_id FROM {_target_table}
        GROUP BY campaign_key, campaign_member_id HAVING COUNT(*) > 1
     ))                                                        AS dup_grain,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_responded IS NULL OR is_responded NOT IN (0, 1)
         OR is_deleted IS NULL   OR is_deleted   NOT IN (0, 1)) AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table} f
      WHERE NOT EXISTS (SELECT 1 FROM lh_gold.gold.dim_date d
                        WHERE d.date_key = f.snapshot_date_key))
                                                               AS orphan_snapshot_date_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE snapshot_date_key = {p_snapshot_date_key} AND agent_key = -1)
                                                               AS unresolved_agent_key
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate (campaign_key, campaign_member_id) : {_dq['dup_grain']}   [hard]")
print(f"  bad flag rows                                : {_dq['bad_flag_rows']}   [hard]")
print(f"  orphan snapshot_date_key                     : {_dq['orphan_snapshot_date_keys']}   [hard]")
print(f"  unresolved agent_key (-1)                    : {_dq['unresolved_agent_key']}   [soft]")

if _dq["dup_grain"] or _dq["bad_flag_rows"] or _dq["orphan_snapshot_date_keys"]:
    raise ValueError(f"[nb_gold_fact_campaign_member] Hard data quality check failed: {_dq}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_campaign_member — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
