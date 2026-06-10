#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_rp_dim_mat_fact_policy_snapshot
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# Notebook: nb_gold_rp_dim_mat_fact_policy_snapshot
# Layer:    Gold
# Purpose:  Creates and refreshes Materialized Lake Views for role-playing
#           dimensions of fact_policy_snapshot.
#
#           Regular SQL views cannot be imported into a Fabric semantic model
#           using Direct Lake mode.  Materialized Lake Views are backed by
#           Delta files and ARE compatible with Direct Lake.
#
#           Every run  : DROP MATERIALIZED LAKE VIEW IF EXISTS  → removes stale view
#                        CREATE MATERIALIZED LAKE VIEW          → recreates with latest data
#
#           Naming convention:
#             rp_dim_{base_dim}_{fact}_{role}
#
#           Views created (8 total):
#             dim_date   × 2 : snapshotdate, issuedate
#             dim_client × 2 : owner, annuitant
#             dim_agent  × 4 : writingagent, imoagent, nmoagent, servicingagent
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - fact_policy_snapshot and all base dims must exist in lh_gold.gold.
#   - Schedule after dim and fact notebooks complete.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_gold_rp_dim_mat_fact_policy_snapshot").getOrCreate()

_notebook_start = time.time()

_FACT        = "lh_gold.gold.fact_policy_snapshot"
_DIM_DATE    = "lh_gold.gold.dim_date"
_DIM_CLIENT  = "lh_gold.gold.dim_client"
_DIM_AGENT   = "lh_gold.gold.dim_agent"

print("=" * 65)
print("  nb_gold_rp_dim_mat_fact_policy_snapshot — START")
print("=" * 65)


# In[ ]:


# ── Materialized Lake View definitions ────────────────────────────────────────
# Each entry: (view_name, query, description)

_mat_views = [
    # ── dim_date × 2 ──────────────────────────────────────────────────────────
    (
        "gold.rp_dim_date_factpolicysnapshot_snapshotdate",
        f"""
        SELECT d.*
        FROM   {_DIM_DATE} d
        WHERE  d.date_key IN (
            SELECT DISTINCT f.snapshot_date_key
            FROM   {_FACT} f
        )
        """,
        "snapshot_date_key → dim_date",
    ),
    (
        "gold.rp_dim_date_factpolicysnapshot_issuedate",
        f"""
        SELECT d.*
        FROM   {_DIM_DATE} d
        WHERE  d.date_key IN (
            SELECT DISTINCT f.issue_date_key
            FROM   {_FACT} f
        )
        """,
        "issue_date_key → dim_date",
    ),

    # ── dim_client × 2 ────────────────────────────────────────────────────────
    (
        "gold.rp_dim_client_factpolicysnapshot_owner",
        f"""
        SELECT d.*
        FROM   {_DIM_CLIENT} d
        WHERE  d.client_key IN (
            SELECT DISTINCT f.owner_key
            FROM   {_FACT} f
        )
        """,
        "owner_key → dim_client",
    ),
    (
        "gold.rp_dim_client_factpolicysnapshot_annuitant",
        f"""
        SELECT d.*
        FROM   {_DIM_CLIENT} d
        WHERE  d.client_key IN (
            SELECT DISTINCT f.annuitant_key
            FROM   {_FACT} f
        )
        """,
        "annuitant_key → dim_client",
    ),

    # ── dim_agent × 4 ─────────────────────────────────────────────────────────
    (
        "gold.rp_dim_agent_factpolicysnapshot_writingagent",
        f"""
        SELECT d.*
        FROM   {_DIM_AGENT} d
        WHERE  d.agent_key IN (
            SELECT DISTINCT f.writing_agent_key
            FROM   {_FACT} f
        )
        """,
        "writing_agent_key → dim_agent",
    ),
    (
        "gold.rp_dim_agent_factpolicysnapshot_imoagent",
        f"""
        SELECT d.*
        FROM   {_DIM_AGENT} d
        WHERE  d.agent_key IN (
            SELECT DISTINCT f.imo_agent_key
            FROM   {_FACT} f
        )
        """,
        "imo_agent_key → dim_agent",
    ),
    (
        "gold.rp_dim_agent_factpolicysnapshot_nmoagent",
        f"""
        SELECT d.*
        FROM   {_DIM_AGENT} d
        WHERE  d.agent_key IN (
            SELECT DISTINCT f.nmo_agent_key
            FROM   {_FACT} f
        )
        """,
        "nmo_agent_key → dim_agent",
    ),
    (
        "gold.rp_dim_agent_factpolicysnapshot_servicingagent",
        f"""
        SELECT d.*
        FROM   {_DIM_AGENT} d
        WHERE  d.agent_key IN (
            SELECT DISTINCT f.servicing_agent_key
            FROM   {_FACT} f
        )
        """,
        "servicing_agent_key → dim_agent",
    ),
]


# In[ ]:


# ── Create / recreate all Materialized Lake Views ─────────────────────────────
# DROP   MATERIALIZED LAKE VIEW IF EXISTS — removes stale view if present
# CREATE MATERIALIZED LAKE VIEW           — (re)creates with latest data
# Full drop+create on every run ensures data is always current.

print(f"\nProcessing {len(_mat_views)} Materialized Lake Views ...\n")

_results = []

for _view_name, _query, _description in _mat_views:
    _t0 = time.time()

    spark.sql(f"DROP MATERIALIZED LAKE VIEW IF EXISTS {_view_name}")
    spark.sql(f"CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {_view_name} AS {_query}")

    _row_count = spark.table(_view_name).count()
    _elapsed_t = round(time.time() - _t0, 2)
    _results.append((_view_name, _description, _row_count, _elapsed_t))
    print(f"  ✓  {_view_name:<60}  {_row_count:>8,} rows  ({_elapsed_t}s)")


# In[ ]:


# ── Summary ───────────────────────────────────────────────────────────────────

_total_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_rp_dim_mat_fact_policy_snapshot — COMPLETE")
print(f"  Materialized views : {len(_results)}")
print(f"  Total elapsed      : {_total_elapsed}s")
print("=" * 65)
print(f"\n{'View':<60}  {'Rows':>8}  {'Secs':>6}")
print("-" * 78)
for _v, _d, _r, _e in _results:
    print(f"  {_v:<58}  {_r:>8,}  {_e:>6}")

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
