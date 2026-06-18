#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_dim_customer_service_rep
#
# New notebook

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = "2025-05-03"    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = "2025-05-03T01:00:00Z"    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = "elic"    # REQUIRED — e.g. "elic"


# In[ ]:


# Notebook: nb_gold_dim_customer_service_rep
# Layer:    Gold
# Purpose:  SCD Type-2 load of gold.dim_customer_service_rep — the conformed
#           Contact Center agent dimension (Webex Contact Center domain).
#           Agent identity is conformed across four silver_s2 sources:
#             asr_base (agent_session)  — agent_id, agent_name, user_login_id,
#                                         skills_profile, multi_media_profile_type, team_id
#             aar_base (agent_activity) — agent_id, agent_name, user_login_id, team_id
#             csr_base (customer_session)— last_agent_id, last_agent_name,
#                                          last_agent_sign_in_id (login)
#             clr_base (call_leg)       — owner_id, owner_name
#
#           skills_profile and multi_media_profile_type exist ONLY in asr_base.
#           Per agent, the latest-known value of each attribute is taken
#           (MAX, nulls ignored) to produce one consolidated row.
#
# Write pattern: SCD Type-2 via GoldLoader. A new version is created whenever any
#                tracked attribute changes — so every versioned attribute is part
#                of the business key (same approach as dim_queue).
#
# Conflict note: dim_customer_service_rep belongs to the Webex Contact Center
#                star schema. It is independent of the EquiTrust insurance
#                dimensions (dim_agent, etc.).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_customer_service_rep").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.dim_customer_service_rep"
# Versioned attributes are all part of the business key so SCD2 detects changes.
_business_key_cols = [
    "customer_service_rep_id",
    "customer_service_rep_name",
    "user_login_id",
    "skills_profile",
    "multi_media_profile_type",
    "team_id",
]
_is_scd2           = True
_surrogate_key_col = "customer_service_rep_key"
_hash_col          = "md5_hash"

_SRC_ASR = "lh_silver.silver_s2.asr_base"
_SRC_AAR = "lh_silver.silver_s2.aar_base"
_SRC_CSR = "lh_silver.silver_s2.csr_base"
_SRC_CLR = "lh_silver.silver_s2.clr_base"

print("=" * 65)
print("  nb_gold_dim_customer_service_rep — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read & conform agent identity across the four sources
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Conforming agents from asr_base, aar_base, csr_base, clr_base")

# Each source contributes the attributes it carries; absent attributes are NULL
# so MAX(... ) below picks them up only from the sources that provide them.
rep_df = spark.sql(f"""
    WITH agent_obs AS (
        -- agent_session: full attribute set (only source of skills / mmpt)
        SELECT agent_id                  AS customer_service_rep_id,
               agent_name                AS customer_service_rep_name,
               user_login_id             AS user_login_id,
               skills_profile            AS skills_profile,
               multi_media_profile_type  AS multi_media_profile_type,
               team_id                   AS team_id
        FROM   {_SRC_ASR}
        WHERE  agent_id IS NOT NULL

        UNION ALL

        -- agent_activity: id, name, login, team
        SELECT agent_id,
               agent_name,
               user_login_id,
               CAST(NULL AS STRING),
               CAST(NULL AS STRING),
               team_id
        FROM   {_SRC_AAR}
        WHERE  agent_id IS NOT NULL

        UNION ALL

        -- customer_session: last_agent_* (sign-in id = login)
        SELECT last_agent_id,
               last_agent_name,
               last_agent_sign_in_id,
               CAST(NULL AS STRING),
               CAST(NULL AS STRING),
               CAST(NULL AS STRING)
        FROM   {_SRC_CSR}
        WHERE  last_agent_id IS NOT NULL

        UNION ALL

        -- call_leg: owner_* (id + name only)
        SELECT owner_id,
               owner_name,
               CAST(NULL AS STRING),
               CAST(NULL AS STRING),
               CAST(NULL AS STRING),
               CAST(NULL AS STRING)
        FROM   {_SRC_CLR}
        WHERE  owner_id IS NOT NULL
    )
    SELECT customer_service_rep_id,
           MAX(customer_service_rep_name)  AS customer_service_rep_name,
           MAX(user_login_id)              AS user_login_id,
           MAX(skills_profile)             AS skills_profile,
           MAX(multi_media_profile_type)   AS multi_media_profile_type,
           MAX(team_id)                    AS team_id
    FROM   agent_obs
    GROUP  BY customer_service_rep_id
""")

source_count = rep_df.count()
print(f"  Distinct agents : {source_count:,}")
display(rep_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Applying transformations")

rep_df = (
    rep_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    .withColumn(_surrogate_key_col,
        make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
    )
    .select(
        _surrogate_key_col,
        "customer_service_rep_id",
        "customer_service_rep_name",
        "user_login_id",
        "skills_profile",
        "multi_media_profile_type",
        "team_id",
    )
)

gold_count = rep_df.count()
print(f"  Transformed rows : {gold_count:,}")
display(rep_df.limit(2))


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
    df                = rep_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ── Unknown / default row (customer_service_rep_key = -1) ─────────────────────
# GoldLoader adds effective_timestamp, expiration_timestamp, is_current, md5_hash.
# The MERGE inserts only if -1 does not already exist — safe to re-run.
from delta.tables import DeltaTable  # noqa: F821  # type: ignore[import]

_unknown_df = spark.range(1).select(
    F.lit(-1)       .cast("long")      .alias("customer_service_rep_key"),
    F.lit("Unknown")                   .alias("customer_service_rep_id"),
    F.lit("Unknown")                   .alias("customer_service_rep_name"),
    F.lit("Unknown")                   .alias("user_login_id"),
    F.lit("Unknown")                   .alias("skills_profile"),
    F.lit("Unknown")                   .alias("multi_media_profile_type"),
    F.lit("Unknown")                   .alias("team_id"),
    F.lit(None)     .cast("timestamp") .alias("effective_timestamp"),
    F.lit(None)     .cast("timestamp") .alias("expiration_timestamp"),
    F.lit(1)        .cast("int")       .alias("is_current"),
    F.lit(None)     .cast("string")    .alias("md5_hash"),
)

(
    DeltaTable.forName(spark, _target_table).alias("tgt")
    .merge(_unknown_df.alias("src"), "tgt.customer_service_rep_key = src.customer_service_rep_key")
    .whenNotMatchedInsertAll()
    .execute()
)
print(f"  Unknown row (customer_service_rep_key=-1) ensured in '{_target_table}'")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_customer_service_rep — COMPLETE")
print(f"  Source agents    : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
