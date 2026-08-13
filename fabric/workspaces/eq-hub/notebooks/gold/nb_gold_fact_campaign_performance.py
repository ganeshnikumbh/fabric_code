#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_campaign_performance
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED — also the SNAPSHOT date
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED
p_src_busn_asst       = "elic"    # REQUIRED


# In[ ]:


# Notebook: nb_gold_fact_campaign_performance
# Layer:    Gold
# Purpose:  Periodic-snapshot load of gold.fact_campaign_performance.
#
#           GRAIN: one campaign × snapshot date (design doc §3.1). Periodic
#           snapshot of campaign-level aggregates — kept separate from
#           fact_campaign_activity to preserve the grain. Business key =
#           (sf_campaign_id, snapshot_date_key); each run stamps current
#           aggregates against p_ingestion_date.
#
#           SILVER SOURCE COLUMNS: taken from schema_config_salesforce_v2.sql
#           (silver_column_name), exposed by lh_silver.silver_s2.campaign.
#
#           DIMENSION FKs are resolved with direct LEFT JOINs to lh_gold.gold.dim_*
#           on is_current = 1; unresolved keys default to the -1 member:
#             campaign_key      ← id             → dim_campaign.sf_campaign_id
#             owner_key         ← owner_id       → dim_owner.sf_user_id
#             host_owner_key    ← primary_host_c → dim_owner.sf_user_id
#             imo_account_key   ← imo_agent_c    → dim_account.sf_account_id
#             primary_agent_key ← primary_contact_c → dim_agent.sf_contact_id
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run first: dim_date, dim_campaign, dim_owner, dim_account, dim_agent.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_performance").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_performance"
_business_key_cols = ["sf_campaign_id", "snapshot_date_key"]
_is_scd2           = False
_surrogate_key_col = "campaign_performance_key"
_hash_col          = "md5_hash"

_SRC_CAMPAIGN = "lh_silver.silver_s2.campaign"

# The snapshot date key (YYYYMMDD LONG) — this run's as-of date.
_snapshot_date_key = int(p_ingestion_date.replace("-", ""))

print("=" * 65)
print("  nb_gold_fact_campaign_performance — START")
print("=" * 65)
print(f"  target            : {_target_table}")
print(f"  snapshot_date_key : {_snapshot_date_key}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read campaign aggregates + resolve FKs via direct LEFT JOINs
# String-typed custom count fields are CAST to numeric (invalid text → NULL,
# per the design doc §5 column-shift artefacts).
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading campaign snapshot and joining dimensions")

perf_df = spark.sql(f"""
    SELECT
        -- ── Identity / degenerate ─────────────────────────────────────────
        c.id                                          AS sf_campaign_id,
        CAST({_snapshot_date_key} AS BIGINT)          AS snapshot_date_key,
        c.name                                        AS campaign_name,
        c.type                                        AS campaign_type,
        c.status                                      AS campaign_status,
        c.record_type_id                              AS record_type_id,
        c.line_of_business_c                          AS line_of_business,
        c.campaign_quarter_c                          AS campaign_quarter,
        CAST(c.is_active AS INT)                      AS is_active,
        -- ── Dimension FKs (LEFT JOIN → -1 when unresolved) ────────────────
        CAST(COALESCE(dc.campaign_key, -1)  AS BIGINT) AS campaign_key,
        CAST(COALESCE(do.owner_key, -1)     AS BIGINT) AS owner_key,
        CAST(COALESCE(dho.owner_key, -1)    AS BIGINT) AS host_owner_key,
        CAST(COALESCE(dacc.account_key, -1) AS BIGINT) AS imo_account_key,
        CAST(COALESCE(dag.agent_key, -1)    AS BIGINT) AS primary_agent_key,
        -- ── Standard campaign measures ────────────────────────────────────
        CAST(c.budgeted_cost AS DECIMAL(18,4))        AS budgeted_cost,
        CAST(c.actual_cost AS DECIMAL(18,4))          AS actual_cost,
        CAST(c.expected_revenue AS DECIMAL(18,4))     AS expected_revenue,
        CAST(c.expected_response AS DECIMAL(18,4))    AS expected_response,
        CAST(c.number_sent AS DECIMAL(18,4))          AS number_sent,
        c.number_of_leads                             AS number_of_leads,
        c.number_of_converted_leads                   AS number_of_converted_leads,
        c.number_of_contacts                          AS number_of_contacts,
        c.number_of_responses                         AS number_of_responses,
        c.number_of_opportunities                     AS number_of_opportunities,
        c.number_of_won_opportunities                 AS number_of_won_opportunities,
        CAST(c.amount_all_opportunities AS DECIMAL(18,4)) AS amount_all_opportunities,
        CAST(c.amount_won_opportunities AS DECIMAL(18,4)) AS amount_won_opportunities,
        -- ── Campaign-hierarchy rollups ────────────────────────────────────
        CAST(c.hierarchy_budgeted_cost AS DECIMAL(18,4))          AS hierarchy_budgeted_cost,
        CAST(c.hierarchy_actual_cost AS DECIMAL(18,4))            AS hierarchy_actual_cost,
        CAST(c.hierarchy_expected_revenue AS DECIMAL(18,4))       AS hierarchy_expected_revenue,
        CAST(c.hierarchy_amount_all_opportunities AS DECIMAL(18,4)) AS hierarchy_amount_all_opportunities,
        CAST(c.hierarchy_amount_won_opportunities AS DECIMAL(18,4)) AS hierarchy_amount_won_opportunities,
        c.hierarchy_number_of_contacts                AS hierarchy_number_of_contacts,
        c.hierarchy_number_of_converted_leads         AS hierarchy_number_of_converted_leads,
        c.hierarchy_number_of_leads                   AS hierarchy_number_of_leads,
        c.hierarchy_number_of_opportunities           AS hierarchy_number_of_opportunities,
        c.hierarchy_number_of_responses               AS hierarchy_number_of_responses,
        c.hierarchy_number_of_won_opportunities       AS hierarchy_number_of_won_opportunities,
        CAST(c.hierarchy_number_sent AS DECIMAL(18,4)) AS hierarchy_number_sent,
        -- ── EquiTrust event custom measures (some STRING in silver → CAST) ─
        CAST(c.expected_attendance_c AS INT)          AS expected_attendance,
        CAST(c.registered_attendees_c AS INT)         AS registered_attendees,
        CAST(c.actual_attendees_c AS INT)             AS actual_attendees,
        CAST(c.calls_made_c AS DECIMAL(18,4))         AS calls_made,
        CAST(c.calls_answered_c AS DECIMAL(18,4))     AS calls_answered,
        CAST(c.total_campaign_members_c AS DECIMAL(18,4)) AS total_campaign_members,
        CAST(c.of_contacts_c AS DECIMAL(18,4))        AS members_contacts,
        CAST(c.of_imo_agents_c AS DECIMAL(18,4))      AS members_imo_agents,
        CAST(c.total_remaining_c AS DECIMAL(18,4))    AS total_remaining,
        -- ── Audit / lineage ───────────────────────────────────────────────
        c.source_system                               AS source_system,
        c.ingestion_run_id                            AS ingestion_run_id,
        c.md5_hash                                     AS src_md5_hash
    FROM {_SRC_CAMPAIGN} c
    LEFT JOIN lh_gold.gold.dim_campaign dc  ON c.id              = dc.sf_campaign_id AND dc.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_owner   do   ON c.owner_id        = do.sf_user_id     AND do.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_owner   dho  ON c.primary_host_c  = dho.sf_user_id    AND dho.is_current = 1
    LEFT JOIN lh_gold.gold.dim_account dacc ON c.imo_agent_c     = dacc.sf_account_id AND dacc.is_current = 1
    LEFT JOIN lh_gold.gold.dim_agent   dag  ON c.primary_contact_c = dag.sf_contact_id AND dag.is_current = 1
""")

source_count = perf_df.count()
print(f"  Source campaigns : {source_count:,}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Surrogate key + final projection
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/3] Building surrogate key and final projection")

perf_df = (
    perf_df
    .withColumn("gold_load_ts_utc", F.lit(p_ingestion_timestamp).cast("timestamp"))
    .withColumn(_surrogate_key_col,
        make_surrogate_key(F.col("sf_campaign_id"), F.col("snapshot_date_key")))  # noqa: F821 # type: ignore[name-defined]
    .select(
        # ── Keys ──────────────────────────────────────────────────────────
        _surrogate_key_col, "sf_campaign_id", "snapshot_date_key",
        "campaign_key", "owner_key", "host_owner_key", "imo_account_key", "primary_agent_key",
        # ── Degenerate dims ───────────────────────────────────────────────
        "campaign_name", "campaign_type", "campaign_status", "record_type_id",
        "line_of_business", "campaign_quarter", "is_active",
        # ── Standard measures ─────────────────────────────────────────────
        "budgeted_cost", "actual_cost", "expected_revenue", "expected_response", "number_sent",
        "number_of_leads", "number_of_converted_leads", "number_of_contacts", "number_of_responses",
        "number_of_opportunities", "number_of_won_opportunities",
        "amount_all_opportunities", "amount_won_opportunities",
        # ── Hierarchy rollups ─────────────────────────────────────────────
        "hierarchy_budgeted_cost", "hierarchy_actual_cost", "hierarchy_expected_revenue",
        "hierarchy_amount_all_opportunities", "hierarchy_amount_won_opportunities",
        "hierarchy_number_of_contacts", "hierarchy_number_of_converted_leads", "hierarchy_number_of_leads",
        "hierarchy_number_of_opportunities", "hierarchy_number_of_responses",
        "hierarchy_number_of_won_opportunities", "hierarchy_number_sent",
        # ── EquiTrust event measures ──────────────────────────────────────
        "expected_attendance", "registered_attendees", "actual_attendees",
        "calls_made", "calls_answered", "total_campaign_members",
        "members_contacts", "members_imo_agents", "total_remaining",
        # ── Audit / lineage ───────────────────────────────────────────────
        "source_system", "ingestion_run_id", "src_md5_hash", "gold_load_ts_utc",
    )
)

gold_count = perf_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(perf_df.limit(3))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD1) + validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Loading via GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

_load_start = time.time()
loader.load(
    df                = perf_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    partition_cols    = ["snapshot_date_key"],
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

print("  Null / invalid FK validation (should all be 0):")
_fk_cols = ["snapshot_date_key", "campaign_key", "owner_key", "host_owner_key",
            "imo_account_key", "primary_agent_key"]
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
print("  nb_gold_fact_campaign_performance — COMPLETE")
print(f"  Source campaigns  : {source_count:,}")
print(f"  Rows written      : {gold_count:,}")
print(f"  snapshot_date_key : {_snapshot_date_key}")
print(f"  Elapsed           : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
