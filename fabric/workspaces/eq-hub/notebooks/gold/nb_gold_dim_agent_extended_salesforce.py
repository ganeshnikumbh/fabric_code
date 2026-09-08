#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_agent_extended_salesforce
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


# Notebook: nb_gold_dim_agent_extended_salesforce
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_agent_extended_salesforce — a thin 1:1
#           satellite on the existing gold.dim_agent.
#
#           dim_agent stays the master for agent identity, name, address,
#           classification, contract terms and hierarchy.  NONE of that is
#           repeated here.  This table holds only CRM-resident attributes the
#           master cannot source: record ownership, consent / marketing
#           preferences, platform capability flags, and the CRM record ids that
#           every other Salesforce fact needs to resolve agent_key.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.2
# Build order: 2 of 10.  Depends on dim_user (owner lookups) and dim_agent.
#
# Source:   lh_silver.silver_s2.contact  (driving)
#           lh_silver.silver_s2.account  (LEFT JOIN on agent_id)
#
# Write pattern: SCD Type 2 via GoldLoader (md5-hash change detection).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - gold.dim_user and gold.dim_agent must already be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_agent_extended_salesforce").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_agent_extended_salesforce"
_is_scd2           = True
_surrogate_key_col = "agent_extended_key"
_hash_col          = "md5_hash"

_business_key_cols = [
    "agent_id",
    "agent_key",
    "source_contact_id",
    "source_account_id",
    "owner_user_key",
    "account_owner_user_key",
    "is_opted_out_of_email",
    "is_email_bounced",
    "is_do_not_mail",
    "is_do_not_email_upline",
    "is_do_not_email_downline",
    "is_do_not_email_related_account",
    "is_do_not_email_for",
    "is_firelight_distributor",
    "is_dtcc_enabled",
    "is_cannex_enabled",
    "is_api_enabled",
    "is_reged_distributor",
    "is_ltc_focused",
    "is_agency_reporting_enabled",
    "is_hubspot_suppressed",
    "is_marketing_sync_enabled",
    "producer_status",
    "is_deleted",
    "source_created_timestamp",
    "source_modified_timestamp",
]

print("=" * 65)
print("  nb_gold_dim_agent_extended_salesforce — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read & transform
# ══════════════════════════════════════════════════════════════════════════════
#
# agent_id is the grain and the join key to the master.  It is LPAD-ed to 5
# characters because the source drops leading zeros and dim_agent does not.

print(f"\n[1/4] Reading contact + account from lh_silver.silver_s2")

agent_ext_df = spark.sql(f"""
WITH contact_src AS (
    SELECT
        LPAD(NULLIF(TRIM(c.agent_id_c), 'NOT_PROVIDED'), 5, '0')        AS agent_id,
        NULLIF(TRIM(c.id),       'NOT_PROVIDED')                        AS source_contact_id,
        NULLIF(TRIM(c.owner_id), 'NOT_PROVIDED')                        AS contact_owner_id,
        c.has_opted_out_of_email,
        c.is_email_bounced,
        c.do_not_mail_c,
        c.do_not_email_per_upline_c,
        c.do_not_email_per_related_account_c,
        c.do_not_email_for_c,
        c.supress_hubspot_integration_c,
        c.sync_with_salesforce_c,
        NULLIF(TRIM(c.producer_agent_status_del_c), 'NOT_PROVIDED')     AS producer_status,
        c.is_deleted,
        c.created_date,
        c.last_modified_date
    FROM lh_silver.silver_s2.contact c
    WHERE c.ingestion_date = '{p_ingestion_date}'
      AND NULLIF(TRIM(c.agent_id_c), 'NOT_PROVIDED') IS NOT NULL
),

account_src AS (
    SELECT
        LPAD(NULLIF(TRIM(a.agent_id), 'NOT_PROVIDED'), 5, '0')          AS agent_id,
        NULLIF(TRIM(a.id),       'NOT_PROVIDED')                        AS source_account_id,
        NULLIF(TRIM(a.owner_id), 'NOT_PROVIDED')                        AS account_owner_id,
        a.do_not_mail,
        a.do_not_email_downline,
        a.firelight_distributor,
        a.dtcc_access,
        a.cannex,
        a.api,
        a.reged_distributor,
        a.ltc_focused,
        a.agency_report_indicator,
        a.supress_hubspot_integration
    FROM lh_silver.silver_s2.account a
    WHERE a.ingestion_date = '{p_ingestion_date}'
      AND NULLIF(TRIM(a.agent_id), 'NOT_PROVIDED') IS NOT NULL
)

SELECT
    -- ── Keys ──────────────────────────────────────────────────────────────
    c.agent_id,
    CAST(COALESCE(da.agent_key, -1) AS BIGINT)                          AS agent_key,
    c.source_contact_id,
    a.source_account_id,

    -- ── CRM record ownership ──────────────────────────────────────────────
    CAST(COALESCE(du_c.user_key, -1) AS BIGINT)                         AS owner_user_key,
    CAST(COALESCE(du_a.user_key, -1) AS BIGINT)                         AS account_owner_user_key,

    -- ── Consent / marketing preference flags ──────────────────────────────
    CAST(COALESCE(c.has_opted_out_of_email, 0) AS TINYINT)              AS is_opted_out_of_email,
    CAST(COALESCE(c.is_email_bounced, 0)       AS TINYINT)              AS is_email_bounced,
    CAST(COALESCE(c.do_not_mail_c, a.do_not_mail, 0) AS TINYINT)        AS is_do_not_mail,
    CAST(COALESCE(c.do_not_email_per_upline_c, 0)          AS TINYINT)  AS is_do_not_email_upline,
    CAST(COALESCE(a.do_not_email_downline, 0)              AS TINYINT)  AS is_do_not_email_downline,
    CAST(COALESCE(c.do_not_email_per_related_account_c, 0) AS TINYINT)  AS is_do_not_email_related_account,
    CAST(COALESCE(c.do_not_email_for_c, 0)                 AS TINYINT)  AS is_do_not_email_for,

    -- ── Platform capability flags (agency level) ──────────────────────────
    CAST(COALESCE(a.firelight_distributor, 0)   AS TINYINT)             AS is_firelight_distributor,
    CAST(COALESCE(a.dtcc_access, 0)             AS TINYINT)             AS is_dtcc_enabled,
    CAST(COALESCE(a.cannex, 0)                  AS TINYINT)             AS is_cannex_enabled,
    CAST(COALESCE(a.api, 0)                     AS TINYINT)             AS is_api_enabled,
    CAST(COALESCE(a.reged_distributor, 0)       AS TINYINT)             AS is_reged_distributor,
    CAST(COALESCE(a.ltc_focused, 0)             AS TINYINT)             AS is_ltc_focused,
    CAST(COALESCE(a.agency_report_indicator, 0) AS TINYINT)             AS is_agency_reporting_enabled,

    CAST(COALESCE(c.supress_hubspot_integration_c,
                  a.supress_hubspot_integration, 0) AS TINYINT)         AS is_hubspot_suppressed,
    CAST(COALESCE(c.sync_with_salesforce_c, 0)  AS TINYINT)             AS is_marketing_sync_enabled,

    -- ── Status ────────────────────────────────────────────────────────────
    -- NOTE: the source column carries a _del suffix but is fully populated.
    --       Open item 6 in the mapping document — confirm before exposing it.
    c.producer_status,
    CAST(COALESCE(c.is_deleted, 0) AS TINYINT)                          AS is_deleted,

    -- ── Timestamps (3000-01-01 is the silver NULL sentinel) ───────────────
    CASE WHEN c.created_date       >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.created_date       END                                  AS source_created_timestamp,
    CASE WHEN c.last_modified_date >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.last_modified_date END                                  AS source_modified_timestamp

FROM contact_src c
LEFT JOIN account_src a
       ON a.agent_id = c.agent_id

-- ── Master agent lookup ───────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_agent da
       ON da.agent_id   = c.agent_id
      AND da.is_current = 1

-- ── Internal user lookups ─────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du_c
       ON du_c.source_user_id = c.contact_owner_id
      AND du_c.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_a
       ON du_a.source_user_id = a.account_owner_id
      AND du_a.is_current     = 1
""")

source_count = agent_ext_df.count()
print(f"  Agents read : {source_count:,}")
display(agent_ext_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Final column order
# ══════════════════════════════════════════════════════════════════════════════
# GoldLoader adds agent_extended_key / md5_hash itself.

agent_ext_df = agent_ext_df.select(*_business_key_cols).dropDuplicates(["agent_id"])

gold_count = agent_ext_df.count()
print(f"\n[2/4] Transformed rows : {gold_count:,}")
display(agent_ext_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD2)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = agent_ext_df,
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


# ── Unknown / default row (agent_extended_key = -1) ───────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("agent_extended_key"),
    F.lit("Unknown")                 .alias("agent_id"),
    F.lit(-1)        .cast("long")   .alias("agent_key"),
    F.lit("Unknown")                 .alias("source_contact_id"),
    F.lit("Unknown")                 .alias("source_account_id"),
    F.lit(-1)        .cast("long")   .alias("owner_user_key"),
    F.lit(-1)        .cast("long")   .alias("account_owner_user_key"),
    F.lit("Unknown")                 .alias("producer_status"),
    F.lit(0)         .cast("tinyint").alias("is_deleted"),
    F.lit(1)         .cast("int")    .alias("is_current"),
    F.lit("Salesforce")              .alias("source_system"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.agent_extended_key = src.agent_extended_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (agent_extended_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Shared agent lookup view
# ══════════════════════════════════════════════════════════════════════════════
# Mapping document section 2.7.  Four different source columns have to resolve
# to agent_key; this view is the single place that knows how.  Downstream
# notebooks re-create it themselves — it is materialised here only so the
# unresolved rate can be measured right after the satellite is built.

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

print("\n  TEMP VIEW agent_lookup created")
display(spark.sql("SELECT COUNT(*) AS resolvable_agents FROM agent_lookup"))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Data quality (mapping document section 4, checks 1-4)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT agent_id FROM {_target_table}
        WHERE is_current = 1 GROUP BY agent_id HAVING COUNT(*) > 1
     ))                                                        AS dup_current_business_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_deleted IS NULL OR is_deleted NOT IN (0, 1)
         OR is_do_not_mail IS NULL OR is_do_not_mail NOT IN (0, 1))
                                                               AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE agent_id = 'NOT_PROVIDED' OR producer_status = 'NOT_PROVIDED')
                                                               AS sentinel_leak_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_current = 1 AND agent_key = -1)                  AS unresolved_agent_key
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  dup current business keys : {_dq['dup_current_business_keys']}")
print(f"  bad flag rows             : {_dq['bad_flag_rows']}")
print(f"  sentinel leak rows        : {_dq['sentinel_leak_rows']}")
print(f"  unresolved agent_key (-1) : {_dq['unresolved_agent_key']}   [soft — logged only]")

if _dq["dup_current_business_keys"] or _dq["bad_flag_rows"] or _dq["sentinel_leak_rows"]:
    raise ValueError(
        f"[nb_gold_dim_agent_extended_salesforce] Hard data quality check failed: {_dq}"
    )


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_agent_extended_salesforce — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows staged      : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
