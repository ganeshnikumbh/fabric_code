#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_rp_dim_views_fact_policy_snapshot
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# Notebook: nb_gold_rp_dim_views_fact_policy_snapshot
# Layer:    Gold
# Purpose:  Creates role-playing dimension views for fact_policy_snapshot.
#           Each view is a filtered projection of a base dim table containing
#           only the rows whose key appears in the corresponding FK column of
#           fact_policy_snapshot.
#
#           Naming convention:
#             rp_dim_{base_dim}_{fact}_{role}
#             e.g. rp_dim_date_factpolicysnapshot_issuedate
#
#           Views created (8 total):
#             dim_date   × 2 : snapshotdate, issuedate
#             dim_client × 2 : owner, annuitant
#             dim_agent  × 4 : writingagent, imoagent, nmoagent, servicingagent
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - fact_policy_snapshot and all base dims must already exist in lh_gold.gold.
#   - Re-run this notebook whenever the base dim or fact schema changes.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_gold_rp_dim_views_fact_policy_snapshot").getOrCreate()

_notebook_start = time.time()

_FACT        = "lh_gold.gold.fact_policy_snapshot"
_DIM_DATE    = "lh_gold.gold.dim_date"
_DIM_CLIENT  = "lh_gold.gold.dim_client"
_DIM_AGENT   = "lh_gold.gold.dim_agent"

print("=" * 65)
print("  nb_gold_rp_dim_views_fact_policy_snapshot — START")
print("=" * 65)


# In[ ]:


# ── Role-playing view definitions ─────────────────────────────────────────────
# Pattern:
#   SELECT d.* FROM <base_dim> d
#   WHERE d.<pk_col> IN (
#       SELECT DISTINCT f.<fk_col>
#       FROM   <fact>  f
#   )
#
# The subquery restricts the view to only keys that exist in the fact, keeping
# the view small and query-engine friendly. The -1 unknown row is included when
# it appears as an FK value in the fact.

_views = [
    # ── dim_date role-playing views ───────────────────────────────────────────
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

    # ── dim_client role-playing views ─────────────────────────────────────────
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

    # ── dim_agent role-playing views ──────────────────────────────────────────
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


# ── Create / replace all views ────────────────────────────────────────────────

print(f"\nCreating {len(_views)} role-playing dimension views ...\n")

for _view_name, _view_sql, _description in _views:
    _ddl = f"CREATE OR REPLACE VIEW {_view_name} AS {_view_sql}"
    spark.sql(_ddl)
    print(f"  ✓  {_view_name:<60}  ({_description})")

print(f"\nAll views created successfully.")


# In[ ]:


# ── Verify — show row counts for each view ────────────────────────────────────

print(f"\n{'View':<60}  {'Rows':>8}")
print("-" * 70)

for _view_name, _, _ in _views:
    _count = spark.table(_view_name).count()
    print(f"  {_view_name:<58}  {_count:>8,}")


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_rp_dim_views_fact_policy_snapshot — COMPLETE")
print(f"  Views created : {len(_views)}")
print(f"  Elapsed       : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
