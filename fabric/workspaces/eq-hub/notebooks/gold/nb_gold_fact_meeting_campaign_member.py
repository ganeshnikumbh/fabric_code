#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_meeting_campaign_member
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


# Notebook: nb_gold_fact_meeting_campaign_member
# Layer:    Gold
# Purpose:  SCD Type-1 load of gold.fact_meeting_campaign_member.
#           GRAIN: 1 agent × meeting campaign (design doc §3). The per-agent
#           membership that E7 (reach), G4/G5, Q5 and P5 depend on.
#
#           ⚠️  BLOCKED — CampaignMember is NOT in the extract (design §5 item 1;
#           drawio "Path A"). This notebook is written to the expected shape and
#           SKIPS cleanly until lh_silver.silver_s2.campaign_member lands. When it
#           does, confirm the silver column names against schema_config and the
#           status→flag/date mapping in Section 3.
#
#           AGENT LINKAGE (Path A — preferred, deterministic):
#             campaign_member.contact_id → dim_agent.sf_contact_id → agent_key
#
#           DIMENSION FKs via direct LEFT JOINs to lh_gold.gold.dim_* (is_current=1).
#           channel_key is derived from the campaign type (channel_name ≈ campaign_type).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run first: dim_date, dim_meeting_campaign, dim_agent, dim_account, dim_owner,
#     dim_channel, dim_member_status.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_meeting_campaign_member").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_meeting_campaign_member"
_business_key_cols = ["sf_campaign_member_id"]
_is_scd2           = False
_surrogate_key_col = "meeting_campaign_member_key"
_hash_col          = "md5_hash"

_SRC_MEMBER = "lh_silver.silver_s2.campaign_member"

print("=" * 65)
print("  nb_gold_fact_meeting_campaign_member — START")
print("=" * 65)
print(f"  target : {_target_table}")
print(f"  source : {_SRC_MEMBER}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Guard: skip cleanly until CampaignMember is in the extract
# ══════════════════════════════════════════════════════════════════════════════

if not spark.catalog.tableExists(_SRC_MEMBER):
    print(f"\n  SKIP: '{_SRC_MEMBER}' does not exist yet.")
    print("  Salesforce CampaignMember is not in the current extract (design §5 item 1).")
    print("  Add it to ingestion_config + schema_config; this notebook will then load"
          " fact_meeting_campaign_member on the next run.")
    mssparkutils.notebook.exit("SKIPPED — CampaignMember source not available")  # noqa: F821 # type: ignore[name-defined]


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Read + resolve FKs (assumed standard CampaignMember fields)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading {_SRC_MEMBER} and joining dimensions")

member_df = spark.sql(f"""
    SELECT
        m.id                                          AS sf_campaign_member_id,
        -- ── Keys ──────────────────────────────────────────────────────────
        CAST(COALESCE(dmc.meeting_campaign_key, -1) AS BIGINT) AS meeting_campaign_key,
        CAST(COALESCE(dag.agent_key, -1)    AS BIGINT) AS agent_key,          -- Path A
        CAST(COALESCE(dacc.account_key, -1) AS BIGINT) AS account_key,
        CAST(COALESCE(dow.owner_key, -1)    AS BIGINT) AS owner_key,
        CAST(COALESCE(dch.channel_key, -1)  AS BIGINT) AS channel_key,
        CAST(COALESCE(dms.member_status_key, -1) AS BIGINT) AS member_status_key,
        CAST(COALESCE(CAST(date_format(m.created_date,          'yyyyMMdd') AS BIGINT), -1) AS BIGINT) AS invited_date_key,
        CAST(COALESCE(CAST(date_format(m.first_responded_date,  'yyyyMMdd') AS BIGINT), -1) AS BIGINT) AS registered_date_key,
        CAST(COALESCE(CAST(date_format(m.first_responded_date,  'yyyyMMdd') AS BIGINT), -1) AS BIGINT) AS attended_date_key,
        -- ── Measures / flags (derived from status — confirm mapping on landing) ─
        CAST(1 AS INT)                                AS member_count,
        CAST(1 AS INT)                                AS is_invited_flag,
        CASE WHEN LOWER(m.status) IN ('registered','attended','responded') THEN 1 ELSE 0 END AS is_registered_flag,
        CASE WHEN LOWER(m.status) = 'attended' THEN 1 ELSE 0 END AS is_attended_flag,
        CASE WHEN LOWER(m.status) = 'no show'  THEN 1 ELSE 0 END AS is_no_show_flag,
        DATEDIFF(m.first_responded_date, m.created_date)        AS days_invite_to_register,
        DATEDIFF(m.first_responded_date, m.created_date)        AS days_to_first_attendance,
        -- ── Degenerate / audit ────────────────────────────────────────────
        m.contact_id                                  AS contact_id,
        m.source_system                               AS source_system,
        m.ingestion_run_id                            AS ingestion_run_id,
        m.md5_hash                                     AS src_md5_hash
    FROM {_SRC_MEMBER} m
    LEFT JOIN lh_gold.gold.dim_meeting_campaign dmc ON m.campaign_id = dmc.sf_campaign_id AND dmc.is_current = 1
    LEFT JOIN lh_gold.gold.dim_agent   dag  ON m.contact_id = dag.sf_contact_id  AND dag.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_account dacc ON m.account_id = dacc.sf_account_id AND dacc.is_current = 1
    LEFT JOIN lh_gold.gold.dim_owner   dow  ON m.owner_id   = dow.sf_user_id     AND dow.is_current  = 1
    LEFT JOIN lh_gold.gold.dim_channel dch  ON dmc.campaign_type = dch.channel_name AND dch.is_current = 1
    LEFT JOIN lh_gold.gold.dim_member_status dms ON m.status = dms.status_name  AND dms.is_current = 1
""")

source_count = member_df.count()
print(f"  Source members : {source_count:,}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Surrogate key + final projection
# ══════════════════════════════════════════════════════════════════════════════

member_df = (
    member_df
    .withColumn("gold_load_ts_utc", F.lit(p_ingestion_timestamp).cast("timestamp"))
    .withColumn(_surrogate_key_col, make_surrogate_key(F.col("sf_campaign_member_id")))  # noqa: F821 # type: ignore[name-defined]
    .select(
        _surrogate_key_col, "sf_campaign_member_id",
        "meeting_campaign_key", "agent_key", "account_key", "owner_key", "channel_key",
        "member_status_key", "invited_date_key", "registered_date_key", "attended_date_key",
        "contact_id",
        "member_count", "is_invited_flag", "is_registered_flag", "is_attended_flag",
        "is_no_show_flag", "days_invite_to_register", "days_to_first_attendance",
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

print(f"\n[2/3] Loading via GoldLoader")

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
    partition_cols    = ["meeting_campaign_key"],
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")

print(f"\n[3/3] Null / invalid FK validation (should all be 0)")
_fk_cols = ["meeting_campaign_key", "agent_key", "account_key", "owner_key", "channel_key",
            "member_status_key", "invited_date_key", "registered_date_key", "attended_date_key"]
(
    spark.table(_target_table)
    .select([F.sum(F.when(F.col(c).isNull() | (F.col(c) < F.lit(-1)), 1).otherwise(0)).alias(c)
             for c in _fk_cols])
).show(truncate=False)


# In[ ]:


_elapsed = round(time.time() - _notebook_start, 2)
print("\n" + "=" * 65)
print("  nb_gold_fact_meeting_campaign_member — COMPLETE")
print(f"  Source members : {source_count:,}")
print(f"  Rows written   : {gold_count:,}")
print(f"  Elapsed        : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
