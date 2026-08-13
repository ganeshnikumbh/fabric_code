#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_campaign_member
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED
p_src_busn_asst       = "elic"    # REQUIRED


# In[ ]:


# Notebook: nb_gold_fact_campaign_member
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.fact_campaign_member.
#
#           GRAIN: one agent × campaign (design doc §3.1) — the per-agent campaign
#           membership that E7 (Total Reach), G9, P5 and H1 depend on.
#
#           ⚠️  DEPENDENCY — SOURCE NOT YET IN THE EXTRACT (design doc §5.7):
#           Salesforce CampaignMember is not currently ingested. This notebook is
#           written to the expected shape so it is ready the moment the object is
#           added to ingestion_config + schema_config and lands at
#           lh_silver.silver_s2.campaign_member. Until then it SKIPS cleanly
#           (guarded on table existence). When it lands, confirm the silver column
#           names against schema_config and adjust the SELECT in Section 3.
#
#           DIMENSION FKs via direct LEFT JOINs to lh_gold.gold.dim_* (is_current=1),
#           defaulting to the -1 member:
#             campaign_key             ← campaign_id        → dim_campaign.sf_campaign_id
#             agent_key                ← contact_id         → dim_agent.sf_contact_id
#             member_status_key        ← status             → dim_member_status.member_status
#             first_responded_date_key ← first_responded_date → dim_date (YYYYMMDD)
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run first: dim_date, dim_campaign, dim_agent, dim_member_status.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_campaign_member").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_campaign_member"
_business_key_cols = ["sf_campaign_member_id"]
_is_scd2           = False
_surrogate_key_col = "campaign_member_key"
_hash_col          = "md5_hash"

_SRC_MEMBER = "lh_silver.silver_s2.campaign_member"

print("=" * 65)
print("  nb_gold_fact_campaign_member — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  source          : {_SRC_MEMBER}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Guard: skip cleanly until CampaignMember is in the extract
# ══════════════════════════════════════════════════════════════════════════════

if not spark.catalog.tableExists(_SRC_MEMBER):
    print(f"\n  SKIP: '{_SRC_MEMBER}' does not exist yet.")
    print("  Salesforce CampaignMember is not in the current extract (design doc §5.7).")
    print("  Add it to ingestion_config + schema_config; this notebook will then load "
          "fact_campaign_member on the next run.")
    mssparkutils.notebook.exit("SKIPPED — CampaignMember source not available")  # noqa: F821 # type: ignore[name-defined]


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Read CampaignMember + resolve FKs via direct LEFT JOINs
#            (assumed standard CampaignMember field names)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading {_SRC_MEMBER} and joining dimensions")

member_df = spark.sql(f"""
    SELECT
        m.id                                          AS sf_campaign_member_id,
        m.contact_id                                  AS contact_id,
        m.lead_id                                     AS lead_id,
        m.type                                        AS member_type,
        -- ── Dimension FKs (LEFT JOIN → -1 when unresolved) ────────────────
        CAST(COALESCE(dc.campaign_key, -1)     AS BIGINT) AS campaign_key,
        CAST(COALESCE(dag.agent_key, -1)       AS BIGINT) AS agent_key,
        CAST(COALESCE(dms.member_status_key, -1) AS BIGINT) AS member_status_key,
        CAST(COALESCE(
            CAST(date_format(m.first_responded_date, 'yyyyMMdd') AS BIGINT), -1) AS BIGINT
        )                                             AS first_responded_date_key,
        -- ── Measures / flags ──────────────────────────────────────────────
        CAST(1 AS INT)                                AS member_count,
        CAST(COALESCE(m.has_responded, 0) AS INT)     AS is_responded,
        -- ── Audit / lineage ───────────────────────────────────────────────
        m.source_system                               AS source_system,
        m.ingestion_run_id                            AS ingestion_run_id,
        m.md5_hash                                     AS src_md5_hash
    FROM {_SRC_MEMBER} m
    LEFT JOIN lh_gold.gold.dim_campaign      dc  ON m.campaign_id = dc.sf_campaign_id   AND dc.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_agent         dag ON m.contact_id  = dag.sf_contact_id   AND dag.is_current = 1
    LEFT JOIN lh_gold.gold.dim_member_status dms ON m.status      = dms.member_status   AND dms.is_current = 1
""")

source_count = member_df.count()
print(f"  Source members : {source_count:,}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Surrogate key + final projection
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/3] Building surrogate key and final projection")

member_df = (
    member_df
    .withColumn("gold_load_ts_utc", F.lit(p_ingestion_timestamp).cast("timestamp"))
    .withColumn(_surrogate_key_col, make_surrogate_key(F.col("sf_campaign_member_id")))  # noqa: F821 # type: ignore[name-defined]
    .select(
        # ── Keys ──────────────────────────────────────────────────────────
        _surrogate_key_col, "sf_campaign_member_id",
        "campaign_key", "agent_key", "member_status_key", "first_responded_date_key",
        # ── Degenerate dims ───────────────────────────────────────────────
        "contact_id", "lead_id", "member_type",
        # ── Measures / flags ──────────────────────────────────────────────
        "member_count", "is_responded",
        # ── Audit / lineage ───────────────────────────────────────────────
        "source_system", "ingestion_run_id", "src_md5_hash", "gold_load_ts_utc",
    )
)

gold_count = member_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(member_df.limit(3))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Load via GoldLoader (SCD1) + validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Loading via GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

_load_start = time.time()
loader.load(
    df                = member_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    partition_cols    = ["campaign_key"],
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

print("  Null / invalid FK validation (should all be 0):")
_fk_cols = ["campaign_key", "agent_key", "member_status_key", "first_responded_date_key"]
(
    spark.table(_target_table)
    .select([F.sum(F.when(F.col(c).isNull() | (F.col(c) < F.lit(-1)), 1).otherwise(0)).alias(c)
             for c in _fk_cols])
).show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_campaign_member — COMPLETE")
print(f"  Source members : {source_count:,}")
print(f"  Rows written   : {gold_count:,}")
print(f"  Elapsed        : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
