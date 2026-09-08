#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_campaign_performance
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


# Notebook: nb_gold_fact_campaign_performance
# Layer:    Gold
# Purpose:  Periodic snapshot fact.  One row per campaign per snapshot date.
#
#           Campaign rollups mutate in place at source, so they are snapshotted
#           here rather than stored on dim_campaign — otherwise every run would
#           open a new SCD2 version of the dimension.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.9
# Build order: 9 of 10.
#
# Write pattern: insert-only per batch, partitioned by snapshot_date_key and
#                written with replaceWhere so a re-run of the same date
#                replaces that snapshot instead of duplicating it.
#
# Semi-additive: every count is a point-in-time value.  Sum across campaigns,
#                never across snapshot dates.  The three _pct measures are
#                non-additive — average them, never sum them.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - gold.dim_campaign, gold.dim_user, gold.dim_product, gold.dim_agent and
#     gold.dim_agent_extended_salesforce must be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_performance").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_performance"
_is_scd2           = False
_surrogate_key_col = "campaign_performance_key"
_hash_col          = "md5_hash"
# snapshot_date_key is part of the logical grain, so it is part of the key.
_business_key_cols = ["snapshot_date_key", "campaign_id"]

p_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print("=" * 65)
print("  nb_gold_fact_campaign_performance — START")
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
# Several attendance / sponsorship columns are free-text STRING at source
# (expected_attendance_c, registered_attendees_c, actual_attendees_c,
# actual_response_c, sponsorship_amount_c).  TRY_CAST turns anything that is
# not a clean number into NULL rather than failing the whole notebook.

print(f"\n[1/4] Reading campaign for ingestion_date = {p_ingestion_date}")

perf_df = spark.sql(f"""
SELECT
    CAST({p_snapshot_date_key} AS INT)                                      AS snapshot_date_key,

    -- ── Degenerate + dimension keys ───────────────────────────────────────
    NULLIF(TRIM(c.id), 'NOT_PROVIDED')                                      AS campaign_id,
    CAST(COALESCE(dc.campaign_key, -1) AS BIGINT)                           AS campaign_key,
    CAST(COALESCE(du_own.user_key, -1) AS BIGINT)                           AS owner_user_key,
    CAST(COALESCE(du_ph.user_key,  -1) AS BIGINT)                           AS primary_host_user_key,
    CAST(COALESCE(al_imo.agent_key, -1) AS BIGINT)                          AS imo_agent_key,
    CAST(COALESCE(dp.product_key,  -1) AS BIGINT)                           AS product_key,

    -- ── Time ──────────────────────────────────────────────────────────────
    CASE WHEN c.start_date_time_c >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.start_date_time_c END                                       AS campaign_start_datetime,

    -- ── Attendance counts ─────────────────────────────────────────────────
    TRY_CAST(NULLIF(TRIM(c.expected_attendance_c),   'NOT_PROVIDED') AS INT) AS expected_attendee_count,
    TRY_CAST(NULLIF(TRIM(c.registered_attendees_c),  'NOT_PROVIDED') AS INT) AS registered_attendee_count,
    TRY_CAST(NULLIF(TRIM(c.actual_attendees_c),      'NOT_PROVIDED') AS INT) AS actual_attendee_count,

    -- ── Membership counts (semi-additive snapshot values) ─────────────────
    CAST(COALESCE(c.total_campaign_members_c, 0) AS INT)                    AS total_member_count,
    CAST(COALESCE(c.of_imo_agents_c, 0)          AS INT)                    AS imo_agent_member_count,
    CAST(COALESCE(c.number_of_contacts, 0)       AS INT)                    AS contact_member_count,
    CAST(COALESCE(c.number_of_leads, 0)          AS INT)                    AS lead_member_count,
    CAST(COALESCE(c.number_of_responses, 0)      AS INT)                    AS response_count,
    TRY_CAST(NULLIF(TRIM(c.actual_response_c),   'NOT_PROVIDED') AS INT)    AS actual_response_count,

    -- ── Call activity ─────────────────────────────────────────────────────
    CAST(COALESCE(c.calls_made_c, 0)     AS INT)                            AS calls_made_count,
    CAST(COALESCE(c.calls_answered_c, 0) AS INT)                            AS calls_answered_count,
    CAST(COALESCE(c.total_remaining_c, 0) AS INT)                           AS remaining_count,

    -- ── Money ─────────────────────────────────────────────────────────────
    TRY_CAST(NULLIF(TRIM(c.sponsorship_amount_c), 'NOT_PROVIDED') AS DECIMAL(18,2))
                                                                            AS sponsorship_amount,
    CAST(COALESCE(c.budgeted_cost, 0)            AS DECIMAL(18,2))          AS budgeted_cost_amount,
    CAST(COALESCE(c.actual_cost, 0)              AS DECIMAL(18,2))          AS actual_cost_amount,
    CAST(COALESCE(c.expected_revenue, 0)         AS DECIMAL(18,2))          AS expected_revenue_amount,
    CAST(COALESCE(c.amount_all_opportunities, 0) AS DECIMAL(18,2))          AS opportunity_amount,
    CAST(COALESCE(c.amount_won_opportunities, 0) AS DECIMAL(18,2))          AS won_opportunity_amount,

    -- ── Rates (non-additive — average, never sum) ─────────────────────────
    CAST(c.number_of_responses
         / NULLIF(c.total_campaign_members_c, 0) AS DECIMAL(9,4))           AS response_rate_pct,
    CAST(TRY_CAST(NULLIF(TRIM(c.actual_attendees_c), 'NOT_PROVIDED') AS DOUBLE)
         / NULLIF(TRY_CAST(NULLIF(TRIM(c.registered_attendees_c), 'NOT_PROVIDED') AS DOUBLE), 0)
         AS DECIMAL(9,4))                                                   AS attendance_rate_pct,
    CAST(c.calls_answered_c
         / NULLIF(c.calls_made_c, 0) AS DECIMAL(9,4))                       AS call_answer_rate_pct

FROM lh_silver.silver_s2.campaign c

-- ── Campaign dimension ────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_campaign dc
       ON dc.campaign_id = NULLIF(TRIM(c.id), 'NOT_PROVIDED')
      AND dc.is_current  = 1

-- ── Internal users ────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du_own
       ON du_own.source_user_id = NULLIF(TRIM(c.owner_id), 'NOT_PROVIDED')
      AND du_own.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_ph
       ON du_ph.source_user_id  = NULLIF(TRIM(c.primary_host_c), 'NOT_PROVIDED')
      AND du_ph.is_current      = 1

-- ── Agent via the account id path ─────────────────────────────────────────
LEFT JOIN agent_lookup al_imo
       ON al_imo.source_account_id = NULLIF(TRIM(c.imo_agent_c), 'NOT_PROVIDED')

-- ── Product ───────────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_product dp
       ON dp.product_name = NULLIF(TRIM(c.product_c), 'NOT_PROVIDED')

WHERE c.ingestion_date = '{p_ingestion_date}'
  AND NULLIF(TRIM(c.id), 'NOT_PROVIDED') IS NOT NULL
""")

source_count = perf_df.count()
print(f"  Campaigns read : {source_count:,}")
display(perf_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Enforce the grain
# ══════════════════════════════════════════════════════════════════════════════

perf_df = perf_df.dropDuplicates(["snapshot_date_key", "campaign_id"])

gold_count = perf_df.count()
print(f"\n[2/4] Rows after grain enforcement : {gold_count:,}")
if gold_count != source_count:
    print(f"  WARNING: {source_count - gold_count:,} fan-out row(s) collapsed — "
          f"check dim_product / agent_lookup for duplicate join keys")
display(perf_df.limit(5))


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
    df                  = perf_df,
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
# SECTION 6 — Data quality (mapping document section 4, checks 5, 9, 10, 13)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        -- campaign_key = -1 is excluded: every unresolved campaign shares that
        -- key, which would look like a duplicate grain when it is a coverage gap.
        SELECT campaign_key, snapshot_date_key FROM {_target_table}
        WHERE campaign_key <> -1
        GROUP BY campaign_key, snapshot_date_key HAVING COUNT(*) > 1
     ))                                                        AS dup_grain,
    (SELECT COUNT(*) FROM {_target_table} f
      WHERE NOT EXISTS (SELECT 1 FROM lh_gold.gold.dim_date d
                        WHERE d.date_key = f.snapshot_date_key))
                                                               AS orphan_snapshot_date_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE snapshot_date_key = {p_snapshot_date_key} AND campaign_key = -1)
                                                               AS unresolved_campaign_key,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE response_rate_pct IS NOT NULL
        AND (response_rate_pct < 0 OR response_rate_pct > 1))   AS response_rate_out_of_range
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate (campaign_key, snapshot_date_key) : {_dq['dup_grain']}   [hard]")
print(f"  orphan snapshot_date_key                    : {_dq['orphan_snapshot_date_keys']}   [hard]")
print(f"  unresolved campaign_key (-1)                : {_dq['unresolved_campaign_key']}   [soft]")
print(f"  response_rate_pct out of [0,1]              : {_dq['response_rate_out_of_range']}   [soft]")

if _dq["dup_grain"] or _dq["orphan_snapshot_date_keys"]:
    raise ValueError(
        f"[nb_gold_fact_campaign_performance] Hard data quality check failed: {_dq}"
    )


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_campaign_performance — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
