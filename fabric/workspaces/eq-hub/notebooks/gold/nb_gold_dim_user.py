#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_user
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


# Notebook: nb_gold_dim_user
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_user from lh_silver.silver_s2.user.
#           Internal CRM staff (wholesalers, sales support, marketing, service
#           accounts) — distinct from agents, which live in dim_agent.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.1
# Build order: 1 of 10.  No dependency on any other gold table.
#
# Write pattern: SCD Type 2 via GoldLoader.  Change detection is md5-hash based;
#                the hash is computed by GoldLoader over _business_key_cols, so
#                that list is the full attribute set, not just the natural key.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_user").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_user"
_is_scd2           = True
_surrogate_key_col = "user_key"
_hash_col          = "md5_hash"

# Full attribute set drives both the surrogate key and the SCD2 change hash.
# last_login_timestamp is deliberately EXCLUDED: it changes on every login and
# would open a new SCD2 version on every run without any attribute really
# changing.  It is still stored on the row, just not part of the hash.
_business_key_cols = [
    "user_id",
    "source_user_id",
    "user_full_name",
    "user_first_name",
    "user_last_name",
    "user_alias",
    "email_address",
    "job_title",
    "department_name",
    "division_name",
    "company_name",
    "user_type",
    "source_role_id",
    "source_profile_id",
    "manager_user_key",
    "employee_number",
    "city_name",
    "state_code",
    "time_zone_name",
    "is_active",
    "is_service_account",
    "source_created_timestamp",
    "source_modified_timestamp",
]

print("=" * 65)
print("  nb_gold_dim_user — START")
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
# manager_id is a self-reference into this same dimension.  On the very first
# run dim_user does not exist yet, so the join is skipped and every
# manager_user_key resolves to -1.  Per the mapping document manager_id is
# empty throughout the current extract, so -1 is the expected value either way.

_dim_user_exists = spark.catalog.tableExists(_target_table)

if _dim_user_exists:
    _manager_select = "COALESCE(mgr.user_key, -1)"
    _manager_join   = """
    LEFT JOIN lh_gold.gold.dim_user mgr
           ON mgr.source_user_id = NULLIF(TRIM(u.manager_id), 'NOT_PROVIDED')
          AND mgr.is_current     = 1
    """
else:
    _manager_select = "-1"
    _manager_join   = ""

print(f"\n[1/4] Reading lh_silver.silver_s2.user "
      f"(dim_user exists = {_dim_user_exists})")

user_dim_df = spark.sql(f"""
SELECT
    -- ── Keys ──────────────────────────────────────────────────────────────
    -- Business key.  The sandbox extract appends '.partial' to usernames.
    REPLACE(NULLIF(TRIM(u.username), 'NOT_PROVIDED'), '.partial', '')   AS user_id,
    NULLIF(TRIM(u.id), 'NOT_PROVIDED')                                  AS source_user_id,

    -- ── Names ─────────────────────────────────────────────────────────────
    NULLIF(TRIM(u.name),       'NOT_PROVIDED')                          AS user_full_name,
    NULLIF(TRIM(u.first_name), 'NOT_PROVIDED')                          AS user_first_name,
    NULLIF(TRIM(u.last_name),  'NOT_PROVIDED')                          AS user_last_name,
    NULLIF(TRIM(u.alias),      'NOT_PROVIDED')                          AS user_alias,

    -- Sandbox extracts append '.invalid' to every email address.
    LOWER(REPLACE(NULLIF(TRIM(u.email), 'NOT_PROVIDED'), '.invalid', '')) AS email_address,

    -- ── Organisation ──────────────────────────────────────────────────────
    NULLIF(TRIM(u.title), 'NOT_PROVIDED')                               AS job_title,
    -- Source mixes 'Sales & Marketing' and 'Sales and Marketing'.
    CASE WHEN TRIM(u.department) = 'Sales and Marketing' THEN 'Sales & Marketing'
         ELSE NULLIF(TRIM(u.department), 'NOT_PROVIDED')
    END                                                                 AS department_name,
    NULLIF(TRIM(u.division),     'NOT_PROVIDED')                        AS division_name,
    NULLIF(TRIM(u.company_name), 'NOT_PROVIDED')                        AS company_name,
    NULLIF(TRIM(u.user_type),    'NOT_PROVIDED')                        AS user_type,

    NULLIF(TRIM(u.user_role_id), 'NOT_PROVIDED')                        AS source_role_id,
    NULLIF(TRIM(u.profile_id),   'NOT_PROVIDED')                        AS source_profile_id,

    -- ── Self-referencing FK ───────────────────────────────────────────────
    CAST({_manager_select} AS BIGINT)                                   AS manager_user_key,

    NULLIF(TRIM(u.employee_number), 'NOT_PROVIDED')                     AS employee_number,

    -- ── Location ──────────────────────────────────────────────────────────
    NULLIF(TRIM(u.city), 'NOT_PROVIDED')                                AS city_name,
    -- Source mixes 'IOWA' and 'IA'.
    CASE WHEN UPPER(TRIM(u.state)) = 'IOWA' THEN 'IA'
         ELSE NULLIF(UPPER(TRIM(u.state)), 'NOT_PROVIDED')
    END                                                                 AS state_code,
    NULLIF(TRIM(u.time_zone_sid_key), 'NOT_PROVIDED')                   AS time_zone_name,

    -- ── Flags ─────────────────────────────────────────────────────────────
    CAST(COALESCE(u.is_active, 0) AS TINYINT)                           AS is_active,
    -- Lets reports exclude automation / integration accounts.
    CASE WHEN TRIM(u.user_type) <> 'Standard' THEN 1 ELSE 0 END         AS is_service_account,

    -- ── Timestamps (3000-01-01 is the silver NULL sentinel) ───────────────
    CASE WHEN u.last_login_date     >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE u.last_login_date     END                                 AS last_login_timestamp,
    CASE WHEN u.created_date        >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE u.created_date        END                                 AS source_created_timestamp,
    CASE WHEN u.last_modified_date  >= TIMESTAMP'3000-01-01' THEN NULL
         ELSE u.last_modified_date  END                                 AS source_modified_timestamp

FROM lh_silver.silver_s2.`user` u
{_manager_join}
WHERE u.ingestion_date = '{p_ingestion_date}'
  AND NULLIF(TRIM(u.username), 'NOT_PROVIDED') IS NOT NULL
""")

source_count = user_dim_df.count()
print(f"  Users read : {source_count:,}")
display(user_dim_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Final column order
# ══════════════════════════════════════════════════════════════════════════════
# GoldLoader adds user_key / md5_hash itself, so they are not selected here.

user_dim_df = user_dim_df.select(
    "user_id",
    "source_user_id",
    "user_full_name",
    "user_first_name",
    "user_last_name",
    "user_alias",
    "email_address",
    "job_title",
    "department_name",
    "division_name",
    "company_name",
    "user_type",
    "source_role_id",
    "source_profile_id",
    "manager_user_key",
    "employee_number",
    "city_name",
    "state_code",
    "time_zone_name",
    "is_active",
    "is_service_account",
    "last_login_timestamp",
    "source_created_timestamp",
    "source_modified_timestamp",
).dropDuplicates(["user_id"])

gold_count = user_dim_df.count()
print(f"\n[2/4] Transformed rows : {gold_count:,}")
display(user_dim_df.limit(5))


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
    df                  = user_dim_df,
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


# ── Unknown / default row (user_key = -1) ─────────────────────────────────────
# GoldLoader recalculates the surrogate key from business_key_cols for every
# row, so the -1 unknown row is written separately via a Delta MERGE that
# targets the surrogate key directly.  WHEN NOT MATCHED only — never overwrite.
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)        .cast("long")   .alias("user_key"),
    F.lit("Unknown")                 .alias("user_id"),
    F.lit("Unknown")                 .alias("source_user_id"),
    F.lit("Unknown")                 .alias("user_full_name"),
    F.lit("Unknown")                 .alias("user_first_name"),
    F.lit("Unknown")                 .alias("user_last_name"),
    F.lit("Unknown")                 .alias("user_alias"),
    F.lit("Unknown")                 .alias("user_type"),
    F.lit(-1)        .cast("long")   .alias("manager_user_key"),
    F.lit(0)         .cast("tinyint").alias("is_active"),
    F.lit(0)         .cast("tinyint").alias("is_service_account"),
    F.lit(1)         .cast("int")    .alias("is_current"),
    F.lit("Salesforce")              .alias("source_system"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.user_key = src.user_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (user_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Data quality (mapping document section 4, checks 1-4)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT user_id FROM {_target_table}
        WHERE is_current = 1 GROUP BY user_id HAVING COUNT(*) > 1
     ))                                                        AS dup_current_business_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_active IS NULL OR is_active NOT IN (0, 1)
         OR is_service_account IS NULL
         OR is_service_account NOT IN (0, 1))                   AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE user_full_name = 'NOT_PROVIDED'
         OR email_address  = 'NOT_PROVIDED')                    AS sentinel_leak_rows
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  dup current business keys : {_dq['dup_current_business_keys']}")
print(f"  bad flag rows             : {_dq['bad_flag_rows']}")
print(f"  sentinel leak rows        : {_dq['sentinel_leak_rows']}")

if _dq["dup_current_business_keys"] or _dq["bad_flag_rows"] or _dq["sentinel_leak_rows"]:
    raise ValueError(f"[nb_gold_dim_user] Hard data quality check failed: {_dq}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_user — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows staged      : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
