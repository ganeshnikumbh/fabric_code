#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_campaign
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


# Notebook: nb_gold_dim_campaign
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_campaign from lh_silver.silver_s2.campaign.
#
#           Descriptive attributes ONLY.  Every rollup, count and rate lives in
#           fact_campaign_performance, because the source rollups mutate in
#           place and would otherwise open a new SCD2 version every single run.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.3
# Build order: 3 of 10.  Depends on dim_user, dim_product and
#              dim_agent_extended_salesforce (for the account/contact -> agent
#              resolution paths described in mapping section 2.7).
#
# Write pattern: SCD Type 2 via GoldLoader (md5-hash change detection).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - gold.dim_user, gold.dim_product, gold.dim_agent and
#     gold.dim_agent_extended_salesforce must already be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_campaign").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_campaign"
_is_scd2           = True
_surrogate_key_col = "campaign_key"
_hash_col          = "md5_hash"

_business_key_cols = [
    "campaign_id",
    "campaign_name",
    "campaign_type",
    "campaign_status",
    "line_of_business",
    "campaign_topic",
    "product_key",
    "campaign_quarter",
    "parent_campaign_key",
    "owner_user_key",
    "primary_host_user_key",
    "secondary_host_user_key",
    "imo_agent_key",
    "primary_contact_agent_key",
    "start_date",
    "end_date",
    "start_timestamp",
    "end_timestamp",
    "venue_name",
    "transportation_mode",
    "is_active",
    "is_speaking_event",
    "is_raffle_held",
    "is_booth_needed",
    "is_video_needed",
    "is_w9_needed",
    "is_webinar_recorded",
    "is_platform_campaign",
    "source_created_timestamp",
    "source_modified_timestamp",
]

print("=" * 65)
print("  nb_gold_dim_campaign — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Shared agent lookup (mapping section 2.7)
# ══════════════════════════════════════════════════════════════════════════════
# campaign.imo_agent_c holds an ACCOUNT id and campaign.primary_contact_c holds
# a CONTACT id.  Both have to land on the same agent_key, so both go through
# the satellite that carries the two CRM record ids.

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
# SECTION 3 — Read & transform
# ══════════════════════════════════════════════════════════════════════════════
#
# parent_id is a self-reference into this same dimension.  On the first run
# dim_campaign does not exist yet, so the join is skipped and every
# parent_campaign_key resolves to -1.  Per the mapping document parent_id is
# empty throughout the current extract, so -1 is expected either way.

_dim_campaign_exists = spark.catalog.tableExists(_target_table)

if _dim_campaign_exists:
    _parent_select = "COALESCE(pc.campaign_key, -1)"
    _parent_join   = """
    LEFT JOIN lh_gold.gold.dim_campaign pc
           ON pc.campaign_id = NULLIF(TRIM(c.parent_id), 'NOT_PROVIDED')
          AND pc.is_current  = 1
    """
else:
    _parent_select = "-1"
    _parent_join   = ""

print(f"\n[1/4] Reading lh_silver.silver_s2.campaign "
      f"(dim_campaign exists = {_dim_campaign_exists})")

campaign_dim_df = spark.sql(f"""
SELECT
    -- ── Keys ──────────────────────────────────────────────────────────────
    NULLIF(TRIM(c.id), 'NOT_PROVIDED')                                  AS campaign_id,

    -- ── Descriptive attributes ────────────────────────────────────────────
    NULLIF(TRIM(c.name),   'NOT_PROVIDED')                              AS campaign_name,
    NULLIF(TRIM(c.type),   'NOT_PROVIDED')                              AS campaign_type,
    NULLIF(TRIM(c.status), 'NOT_PROVIDED')                              AS campaign_status,
    -- Low-cardinality classifier: 'Unknown' rather than NULL so it groups.
    COALESCE(NULLIF(TRIM(c.line_of_business_c), 'NOT_PROVIDED'), 'Unknown')
                                                                        AS line_of_business,
    NULLIF(TRIM(c.topic_c),            'NOT_PROVIDED')                  AS campaign_topic,
    NULLIF(TRIM(c.campaign_quarter_c), 'NOT_PROVIDED')                  AS campaign_quarter,

    -- ── Dimension foreign keys ────────────────────────────────────────────
    CAST(COALESCE(dp.product_key, -1) AS BIGINT)                        AS product_key,
    CAST({_parent_select} AS BIGINT)                                    AS parent_campaign_key,
    CAST(COALESCE(du_own.user_key, -1) AS BIGINT)                       AS owner_user_key,
    CAST(COALESCE(du_ph.user_key,  -1) AS BIGINT)                       AS primary_host_user_key,
    CAST(COALESCE(du_sh.user_key,  -1) AS BIGINT)                       AS secondary_host_user_key,
    -- imo_agent_c  -> account id -> agent_id -> dim_agent.agent_key
    CAST(COALESCE(al_imo.agent_key, -1) AS BIGINT)                      AS imo_agent_key,
    -- primary_contact_c -> contact id -> agent_id -> dim_agent.agent_key
    CAST(COALESCE(al_pc.agent_key,  -1) AS BIGINT)                      AS primary_contact_agent_key,

    -- ── Dates and times (3000-01-01 is the silver NULL sentinel) ──────────
    CASE WHEN c.start_date      >= DATE'3000-01-01'      THEN NULL
         ELSE c.start_date      END                                     AS start_date,
    CASE WHEN c.end_date        >= DATE'3000-01-01'      THEN NULL
         ELSE c.end_date        END                                     AS end_date,
    -- Time-of-day analysis uses these directly; there is no dim_time.
    CASE WHEN c.start_date_time_c >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.start_date_time_c END                                   AS start_timestamp,
    CASE WHEN c.end_date_time_c   >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.end_date_time_c   END                                   AS end_timestamp,

    -- ── Logistics ─────────────────────────────────────────────────────────
    NULLIF(TRIM(c.hotel_name_address_c), 'NOT_PROVIDED')                AS venue_name,
    NULLIF(TRIM(c.transportation_c),     'NOT_PROVIDED')                AS transportation_mode,

    -- ── Flags ─────────────────────────────────────────────────────────────
    CAST(COALESCE(c.is_active, 0) AS TINYINT)                           AS is_active,
    -- These five are 'Yes'/'No' free text at source, not booleans.
    CASE WHEN TRIM(c.speaking_event_c) = 'Yes' THEN 1 ELSE 0 END        AS is_speaking_event,
    CASE WHEN TRIM(c.raffle_c)         = 'Yes' THEN 1 ELSE 0 END        AS is_raffle_held,
    CASE WHEN TRIM(c.booth_needed_c)   = 'Yes' THEN 1 ELSE 0 END        AS is_booth_needed,
    CASE WHEN TRIM(c.video_needed_c)   = 'Yes' THEN 1 ELSE 0 END        AS is_video_needed,
    CASE WHEN TRIM(c.w9_needed_c)      = 'Yes' THEN 1 ELSE 0 END        AS is_w9_needed,
    CAST(COALESCE(c.webinar_recorded_c, 0)   AS TINYINT)                AS is_webinar_recorded,
    CAST(COALESCE(c.equitrust_platform_c, 0) AS TINYINT)                AS is_platform_campaign,

    -- ── Source audit timestamps ───────────────────────────────────────────
    CASE WHEN c.created_date       >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.created_date       END                                  AS source_created_timestamp,
    CASE WHEN c.last_modified_date >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE c.last_modified_date END                                  AS source_modified_timestamp

FROM lh_silver.silver_s2.campaign c

-- ── Product lookup ────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_product dp
       ON dp.product_name = NULLIF(TRIM(c.product_c), 'NOT_PROVIDED')

-- ── Internal user lookups ─────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du_own
       ON du_own.source_user_id = NULLIF(TRIM(c.owner_id), 'NOT_PROVIDED')
      AND du_own.is_current     = 1
LEFT JOIN lh_gold.gold.dim_user du_ph
       ON du_ph.source_user_id  = NULLIF(TRIM(c.primary_host_c), 'NOT_PROVIDED')
      AND du_ph.is_current      = 1
LEFT JOIN lh_gold.gold.dim_user du_sh
       ON du_sh.source_user_id  = NULLIF(TRIM(c.secondary_host_c), 'NOT_PROVIDED')
      AND du_sh.is_current      = 1

-- ── Agent lookups via the two CRM record id paths ─────────────────────────
LEFT JOIN agent_lookup al_imo
       ON al_imo.source_account_id = NULLIF(TRIM(c.imo_agent_c), 'NOT_PROVIDED')
LEFT JOIN agent_lookup al_pc
       ON al_pc.source_contact_id  = NULLIF(TRIM(c.primary_contact_c), 'NOT_PROVIDED')
{_parent_join}
WHERE c.ingestion_date = '{p_ingestion_date}'
  AND NULLIF(TRIM(c.id), 'NOT_PROVIDED') IS NOT NULL
""")

source_count = campaign_dim_df.count()
print(f"  Campaigns read : {source_count:,}")
display(campaign_dim_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Final column order
# ══════════════════════════════════════════════════════════════════════════════
# GoldLoader adds campaign_key / md5_hash itself.

campaign_dim_df = campaign_dim_df.select(*_business_key_cols).dropDuplicates(["campaign_id"])

gold_count = campaign_dim_df.count()
print(f"\n[2/4] Transformed rows : {gold_count:,}")
display(campaign_dim_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Load via GoldLoader (SCD2)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = campaign_dim_df,
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


# ── Unknown / default row (campaign_key = -1) ─────────────────────────────────
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("campaign_key"),
    F.lit("Unknown")                 .alias("campaign_id"),
    F.lit("Unknown")                 .alias("campaign_name"),
    F.lit("Unknown")                 .alias("campaign_type"),
    F.lit("Unknown")                 .alias("campaign_status"),
    F.lit("Unknown")                 .alias("line_of_business"),
    F.lit(-1)        .cast("long")   .alias("product_key"),
    F.lit(-1)        .cast("long")   .alias("parent_campaign_key"),
    F.lit(-1)        .cast("long")   .alias("owner_user_key"),
    F.lit(-1)        .cast("long")   .alias("primary_host_user_key"),
    F.lit(-1)        .cast("long")   .alias("secondary_host_user_key"),
    F.lit(-1)        .cast("long")   .alias("imo_agent_key"),
    F.lit(-1)        .cast("long")   .alias("primary_contact_agent_key"),
    F.lit(0)         .cast("tinyint").alias("is_active"),
    F.lit(0)         .cast("tinyint").alias("is_speaking_event"),
    F.lit(0)         .cast("tinyint").alias("is_raffle_held"),
    F.lit(0)         .cast("tinyint").alias("is_booth_needed"),
    F.lit(0)         .cast("tinyint").alias("is_video_needed"),
    F.lit(0)         .cast("tinyint").alias("is_w9_needed"),
    F.lit(0)         .cast("tinyint").alias("is_webinar_recorded"),
    F.lit(0)         .cast("tinyint").alias("is_platform_campaign"),
    F.lit(1)         .cast("int")    .alias("is_current"),
    F.lit("Salesforce")              .alias("source_system"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.campaign_key = src.campaign_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (campaign_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Data quality (mapping document section 4, checks 1-4)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT campaign_id FROM {_target_table}
        WHERE is_current = 1 GROUP BY campaign_id HAVING COUNT(*) > 1
     ))                                                        AS dup_current_business_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_active IS NULL         OR is_active         NOT IN (0, 1)
         OR is_speaking_event IS NULL OR is_speaking_event NOT IN (0, 1)
         OR is_raffle_held IS NULL    OR is_raffle_held    NOT IN (0, 1)
         OR is_booth_needed IS NULL   OR is_booth_needed   NOT IN (0, 1)
         OR is_video_needed IS NULL   OR is_video_needed   NOT IN (0, 1)
         OR is_w9_needed IS NULL      OR is_w9_needed      NOT IN (0, 1)
         OR is_webinar_recorded IS NULL  OR is_webinar_recorded  NOT IN (0, 1)
         OR is_platform_campaign IS NULL OR is_platform_campaign NOT IN (0, 1))
                                                               AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE campaign_name = 'NOT_PROVIDED'
         OR venue_name    = 'NOT_PROVIDED'
         OR start_date   >= DATE'3000-01-01')                   AS sentinel_leak_rows
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  dup current business keys : {_dq['dup_current_business_keys']}")
print(f"  bad flag rows             : {_dq['bad_flag_rows']}")
print(f"  sentinel leak rows        : {_dq['sentinel_leak_rows']}")

if _dq["dup_current_business_keys"] or _dq["bad_flag_rows"] or _dq["sentinel_leak_rows"]:
    raise ValueError(f"[nb_gold_dim_campaign] Hard data quality check failed: {_dq}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_campaign — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows staged      : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
