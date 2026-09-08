#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_agent_production_snapshot
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


# Notebook: nb_gold_fact_agent_production_snapshot
# Layer:    Gold
# Purpose:  Periodic snapshot fact.  One row per agent per snapshot date.
#
#           Every measure is a point-in-time balance held on the CRM account
#           record.  Semi-additive: sum across agents, never across snapshot
#           dates.  The two run-rate measures and rolling12m_average are
#           non-additive — do not sum them at all.
#
# Mapping:  docs/salesforce/sf3/gold_mapping_document.md  section 3.10
# Build order: 10 of 10.
#
# Write pattern: insert-only per batch, partitioned by snapshot_date_key and
#                written with replaceWhere so a re-run of the same date
#                replaces that snapshot instead of duplicating it.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - gold.dim_agent and gold.dim_user must be loaded.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_agent_production_snapshot").getOrCreate()

spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_agent_production_snapshot"
_is_scd2           = False
_surrogate_key_col = "agent_production_key"
_hash_col          = "md5_hash"
# snapshot_date_key is part of the logical grain, so it is part of the key.
_business_key_cols = ["snapshot_date_key", "agent_id"]

p_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print("=" * 65)
print("  nb_gold_fact_agent_production_snapshot — START")
print("=" * 65)
print(f"  target             : {_target_table}")
print(f"  ingestion_date     : {p_ingestion_date}")
print(f"  snapshot_date_key  : {p_snapshot_date_key}")
print(f"  src_busn_asst      : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read & resolve
# ══════════════════════════════════════════════════════════════════════════════
#
# agent_key and parent_agent_key both resolve straight against the dim_agent
# master on agent_id — no CRM record id hop is needed here, because account
# carries agent_id directly.

print(f"\n[1/4] Reading account for ingestion_date = {p_ingestion_date}")

production_df = spark.sql(f"""
SELECT
    CAST({p_snapshot_date_key} AS INT)                                      AS snapshot_date_key,

    -- ── Degenerate + dimension keys ───────────────────────────────────────
    LPAD(NULLIF(TRIM(a.agent_id), 'NOT_PROVIDED'), 5, '0')                  AS agent_id,
    CAST(COALESCE(da.agent_key, -1)     AS BIGINT)                          AS agent_key,
    CAST(COALESCE(da_par.agent_key, -1) AS BIGINT)                          AS parent_agent_key,
    CAST(COALESCE(du.user_key, -1)      AS BIGINT)                          AS owner_user_key,

    -- ── Annuity premium (semi-additive) ───────────────────────────────────
    CAST(COALESCE(a.ytd_dollar_amount_annuity, 0)     AS DECIMAL(18,2))     AS ytd_premium_annuity_amount,
    CAST(COALESCE(a.pytd_dollar_amount_annuity, 0)    AS DECIMAL(18,2))     AS pytd_premium_annuity_amount,
    CAST(COALESCE(a.pending_dollar_amount_annuity, 0) AS DECIMAL(18,2))     AS pending_premium_annuity_amount,
    -- Source RTM = rolling twelve months.
    CAST(COALESCE(a.rtm_dollar_amount_annuity, 0)     AS DECIMAL(18,2))     AS rolling12m_premium_annuity_amount,
    -- Non-additive average — do not sum.
    CAST(COALESCE(a.rtm_average_annuity, 0)           AS DECIMAL(18,2))     AS rolling12m_average_annuity_amount,
    CAST(COALESCE(a.annuity_last_year_premium, 0)     AS DECIMAL(18,2))     AS last_year_premium_annuity_amount,

    -- ── Annuity contract counts (semi-additive) ───────────────────────────
    CAST(COALESCE(a.ytd_of_contracts_annuity, 0)     AS INT)                AS ytd_contract_count_annuity,
    CAST(COALESCE(a.pytd_of_contracts_annuity, 0)    AS INT)                AS pytd_contract_count_annuity,
    CAST(COALESCE(a.pending_of_contracts_annuity, 0) AS INT)                AS pending_contract_count_annuity,
    CAST(COALESCE(a.rtm_of_contracts_annuity, 0)     AS INT)                AS rolling12m_contract_count_annuity,

    -- ── Life (all zero in the current extract; columns kept) ──────────────
    CAST(COALESCE(a.ytd_dollar_amount_life, 0)     AS DECIMAL(18,2))        AS ytd_premium_life_amount,
    CAST(COALESCE(a.pytd_dollar_amount_life, 0)    AS DECIMAL(18,2))        AS pytd_premium_life_amount,
    CAST(COALESCE(a.pending_dollar_amount_life, 0) AS DECIMAL(18,2))        AS pending_premium_life_amount,
    CAST(COALESCE(a.ytd_of_contracts_life, 0)      AS INT)                  AS ytd_contract_count_life,

    -- ── Run rates (non-additive) ──────────────────────────────────────────
    CAST(COALESCE(a.annuity_current_year_run_rate, 0) AS DECIMAL(18,2))     AS annuity_run_rate_amount,
    CAST(COALESCE(a.life_current_year_run_rate, 0)    AS DECIMAL(18,2))     AS life_run_rate_amount,

    -- ── Activity recency ──────────────────────────────────────────────────
    -- Only ~1.5% populated at source; prefer deriving this from fact_activity.
    CAST(a.days_since_last_activity AS INT)                                 AS days_since_last_activity,
    CASE WHEN a.last_activity_date >= DATE'3000-01-01' THEN NULL
         ELSE a.last_activity_date END                                      AS last_activity_date,

    -- ── Flags ─────────────────────────────────────────────────────────────
    CASE WHEN TRIM(a.status) = 'Active' THEN 1 ELSE 0 END                   AS is_active_contract

FROM lh_silver.silver_s2.account a

-- ── Agent master, direct on agent_id ──────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_agent da
       ON da.agent_id   = LPAD(NULLIF(TRIM(a.agent_id), 'NOT_PROVIDED'), 5, '0')
      AND da.is_current = 1

-- ── Upline IMO ────────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_agent da_par
       ON da_par.agent_id = LPAD(NULLIF(TRIM(a.parent_imo_agent_id_annuity), 'NOT_PROVIDED'), 5, '0')
      AND da_par.is_current = 1

-- ── Record owner ──────────────────────────────────────────────────────────
LEFT JOIN lh_gold.gold.dim_user du
       ON du.source_user_id = NULLIF(TRIM(a.owner_id), 'NOT_PROVIDED')
      AND du.is_current     = 1

WHERE a.ingestion_date = '{p_ingestion_date}'
  AND NULLIF(TRIM(a.agent_id), 'NOT_PROVIDED') IS NOT NULL
""")

source_count = production_df.count()
print(f"  Agent accounts read : {source_count:,}")
display(production_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Enforce the grain
# ══════════════════════════════════════════════════════════════════════════════

production_df = production_df.dropDuplicates(["snapshot_date_key", "agent_id"])

gold_count = production_df.count()
print(f"\n[2/4] Rows after grain enforcement : {gold_count:,}")
if gold_count != source_count:
    print(f"  WARNING: {source_count - gold_count:,} fan-out row(s) collapsed — "
          f"check dim_agent for duplicate current rows per agent_id")
display(production_df.limit(5))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                  = production_df,
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
# SECTION 5 — Data quality (mapping document section 4, checks 3, 5, 8, 10)
# ══════════════════════════════════════════════════════════════════════════════

_dq = spark.sql(f"""
SELECT
    (SELECT COUNT(*) FROM (
        SELECT agent_key, snapshot_date_key FROM {_target_table}
        WHERE agent_key <> -1
        GROUP BY agent_key, snapshot_date_key HAVING COUNT(*) > 1
     ))                                                        AS dup_grain,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE is_active_contract IS NULL
         OR is_active_contract NOT IN (0, 1))                   AS bad_flag_rows,
    (SELECT COUNT(*) FROM {_target_table} f
      WHERE NOT EXISTS (SELECT 1 FROM lh_gold.gold.dim_date d
                        WHERE d.date_key = f.snapshot_date_key))
                                                               AS orphan_snapshot_date_keys,
    (SELECT COUNT(*) FROM {_target_table}
      WHERE snapshot_date_key = {p_snapshot_date_key} AND agent_key = -1)
                                                               AS unresolved_agent_key
""").collect()[0]

print(f"\n[4/4] Data quality")
print(f"  duplicate (agent_key, snapshot_date_key) : {_dq['dup_grain']}   [hard]")
print(f"  bad flag rows                            : {_dq['bad_flag_rows']}   [hard]")
print(f"  orphan snapshot_date_key                 : {_dq['orphan_snapshot_date_keys']}   [hard]")
print(f"  unresolved agent_key (-1)                : {_dq['unresolved_agent_key']}   [soft]")

# NOTE: rows with agent_key = -1 are excluded from the uniqueness check —
# every unresolved agent shares that key, so including them would turn a
# dim_agent coverage gap into a false duplicate-grain failure.  Watch the
# unresolved count above instead.
if _dq["dup_grain"] or _dq["bad_flag_rows"] or _dq["orphan_snapshot_date_keys"]:
    raise ValueError(
        f"[nb_gold_fact_agent_production_snapshot] Hard data quality check failed: {_dq}"
    )


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_agent_production_snapshot — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
