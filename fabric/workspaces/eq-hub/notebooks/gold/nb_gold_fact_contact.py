#!/usr/bin/env python
# coding: utf-8

# ## nb_gold_fact_contact
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


# Notebook: nb_gold_fact_contact
# Layer:    Gold
# Purpose:  SCD Type-1 (full-refresh merge) load of gold.fact_contact.
#
#           GRAIN: one row per Webex contact — csr_base.id.
#           ~2,149 contacts/day; serves all four CC KPIs.
#
#           PRIMARY LEG RULE (from mapping spec):
#             Enrich each contact with the EARLIEST (MIN created_time) clr_base
#             row where call_leg_type='main' AND direction='inbound'.
#             Consult legs are NEVER attached.
#             Contacts with no qualifying leg → has_primary_leg=0, all leg_* NULL.
#             Join key: clr_base.task_id = csr_base.id
#
#           ABANDONMENT RULE:
#             is_abandoned=1 when contact_handle_type='abandoned'.
#             Fallback (when handle_type IS NULL): is_offered=1 AND is_handled=0.
#             sudden_disconnect is NOT counted as abandoned.
#
#           DURATIONS: epoch-ms source → ROUND(value/1000) → integer seconds.
#           TIMESTAMPS: epoch-ms source → UTC TIMESTAMP.
#           DATE KEY: created_time → YYYYMMDD LONG (joins lh_gold.gold.dim_date).
#
#           dim_agent dependency: agent_key defaults to -1 pending
#             nb_gold_webex_dim_agent.py (TODO).
#
#           SCD2 FK note: queue_key and agent_key are resolved via is_current=1
#             lookup (current-row). True as-of SCD2 join is a future enhancement.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session.
#   - Run dim notebooks first: dim_queue, dim_team, dim_site, dim_entry_point,
#     dim_channel (and dim_date via nb_gold_dim_date.py).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_fact_contact").getOrCreate()

_notebook_start = time.time()

_target_table      = "lh_gold.gold.fact_contact"
_business_key_cols = ["contact_id"]
_is_scd2           = False
_surrogate_key_col = "contact_key"
_hash_col          = "md5_hash"

_SRC_CSR = "lh_silver.silver_s2.csr_base"
_SRC_CLR = "lh_silver.silver_s2.clr_base"

print("=" * 65)
print("  nb_gold_fact_contact — START")
print("=" * 65)
print(f"  target          : {_target_table}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read: join csr_base + primary clr leg
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading csr_base and joining primary clr leg")

# ── CTE: select the single earliest main-inbound leg per contact ───────────────
# ROW_NUMBER() partitioned by task_id, ordered by created_time ASC → rn=1 is primary.
contact_df = spark.sql(f"""
    WITH primary_legs AS (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY task_id
                   ORDER BY     created_time ASC
               ) AS _rn
        FROM   {_SRC_CLR}
        WHERE  call_leg_type = 'main'
          AND  direction     = 'inbound'
    ),
    primary_leg AS (
        SELECT * FROM primary_legs WHERE _rn = 1
    )
    SELECT
        -- ── Contact identity ───────────────────────────────────────────
        c.id                                         AS contact_id,

        -- ── Channel descriptors (for FK derivation later) ─────────────
        c.channel_type,
        c.channel_sub_type,

        -- ── Degenerate dimensions ──────────────────────────────────────
        c.direction,
        c.contact_handle_type,
        c.status                                     AS contact_status,
        c.routing_type,

        -- ── Contact flags ──────────────────────────────────────────────
        CAST(CASE WHEN c.direction = 'inbound' THEN 1 ELSE 0 END AS INT)
                                                     AS is_inbound,
        CAST(COALESCE(c.is_contact_offered, 0) AS INT)
                                                     AS is_offered,
        CAST(COALESCE(c.is_contact_handled, 0) AS INT)
                                                     AS is_handled,

        -- ── Duration measures (ms → seconds) ──────────────────────────
        CAST(ROUND(c.total_duration     / 1000) AS INT) AS total_duration_sec,
        CAST(ROUND(c.connected_duration / 1000) AS INT) AS connected_duration_sec,
        CAST(ROUND(c.hold_duration      / 1000) AS INT) AS hold_duration_sec,
        CAST(ROUND(c.wrapup_duration    / 1000) AS INT) AS wrapup_duration_sec,

        -- ── Primary leg presence flag ──────────────────────────────────
        CAST(CASE WHEN pl.id IS NOT NULL THEN 1 ELSE 0 END AS INT)
                                                     AS has_primary_leg,

        -- ── Primary leg identity ───────────────────────────────────────
        pl.id                                        AS primary_leg_id,

        -- ── Primary leg SLA measures (ms → seconds) ───────────────────
        CAST(ROUND(pl.queue_duration    / 1000) AS INT) AS leg_queue_duration_sec,
        CAST(ROUND(pl.ringing_duration  / 1000) AS INT) AS leg_ringing_duration_sec,
        CAST(ROUND(pl.handle_time       / 1000) AS INT) AS leg_handle_time_sec,
        CAST(pl.sla_value AS SMALLINT)               AS leg_sla_value,
        CAST(COALESCE(pl.is_within_service_level, 0) AS INT)
                                                     AS leg_is_within_service_level,
        CAST(COALESCE(pl.abandoned_sl_count, 0) AS INT)
                                                     AS leg_abandoned_sl_count,

        -- ── Timestamps (epoch-ms → UTC) ────────────────────────────────
        TO_TIMESTAMP(c.created_time / 1000)          AS created_ts_utc,
        TO_TIMESTAMP(c.ended_time   / 1000)          AS ended_ts_utc,

        -- ── FK source columns (kept for dim lookups below) ─────────────
        c.created_time                               AS _created_time_ms,
        c.last_queue_id,
        c.last_queue_name,
        c.last_team_id,
        c.last_team_name,
        c.last_site_id,
        c.last_site_name,
        c.last_entry_point_id,
        c.last_entry_point_name,

        -- ── Audit / lineage ────────────────────────────────────────────
        c.source_system,
        c.ingestion_run_id,
        c.md5_hash                                   AS src_md5_hash

    FROM   {_SRC_CSR}   c
    LEFT JOIN primary_leg pl
           ON pl.task_id = c.id
""")

source_count = contact_df.count()
print(f"  Source contacts : {source_count:,}")
display(contact_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform: derive flags, FKs, surrogate key
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Applying transformations")

# ── is_abandoned ──────────────────────────────────────────────────────────────
# 1 when handle_type = 'abandoned'.
# Fallback when handle_type IS NULL: is_offered=1 AND is_handled=0.
# sudden_disconnect is NOT abandoned.
_is_abandoned = (
    F.when(F.col("contact_handle_type") == F.lit("abandoned"), F.lit(1))
     .when(
         F.col("contact_handle_type").isNull(),
         F.when(
             (F.col("is_offered") == F.lit(1)) & (F.col("is_handled") == F.lit(0)),
             F.lit(1)
         ).otherwise(F.lit(0))
     )
     .otherwise(F.lit(0))
     .cast("int")
)

# ── is_self_service ───────────────────────────────────────────────────────────
_is_self_service = (
    F.when(F.col("contact_handle_type") == F.lit("self_service"), F.lit(1))
     .otherwise(F.lit(0))
     .cast("int")
)

# ── date_key (YYYYMMDD LONG — joins existing lh_gold.gold.dim_date) ───────────
_date_key = (
    F.date_format(
        F.to_timestamp(F.col("_created_time_ms") / 1000),
        "yyyyMMdd"
    ).cast("long")
)

# ── SCD1 FK surrogate keys (deterministic hash matching how each dim was built) ─
# team, site, entry_point, channel: computed from same business_key_cols used in
# their dim notebooks → no join needed, keys are identical by construction.
_team_key = F.coalesce(
    F.when(
        F.col("last_team_id").isNotNull(),
        make_surrogate_key(F.col("last_team_id"), F.col("last_team_name"))  # noqa: F821 # type: ignore[name-defined]
    ),
    F.lit(-1).cast("long")
)

_site_key = F.coalesce(
    F.when(
        F.col("last_site_id").isNotNull(),
        make_surrogate_key(F.col("last_site_id"), F.col("last_site_name"))  # noqa: F821 # type: ignore[name-defined]
    ),
    F.lit(-1).cast("long")
)

_entry_point_key = F.coalesce(
    F.when(
        F.col("last_entry_point_id").isNotNull(),
        make_surrogate_key(F.col("last_entry_point_id"), F.col("last_entry_point_name"))  # noqa: F821 # type: ignore[name-defined]
    ),
    F.lit(-1).cast("long")
)

_channel_key = F.coalesce(
    F.when(
        F.col("channel_type").isNotNull(),
        make_surrogate_key(F.col("channel_type"), F.col("channel_sub_type"))  # noqa: F821 # type: ignore[name-defined]
    ),
    F.lit(-1).cast("long")
)

# ── Apply flag and FK columns ─────────────────────────────────────────────────
contact_df = (
    contact_df
    .withColumn("is_abandoned",      _is_abandoned)
    .withColumn("is_self_service",   _is_self_service)
    .withColumn("date_key",          _date_key)
    .withColumn("team_key",          _team_key)
    .withColumn("site_key",          _site_key)
    .withColumn("entry_point_key",   _entry_point_key)
    .withColumn("channel_key",       _channel_key)
    .withColumn("gold_load_ts_utc",  F.lit(p_ingestion_timestamp).cast("timestamp"))
)

# ── SCD2 FK: queue_key via resolve_dim_key (current-row lookup) ───────────────
# resolve_dim_key joins on dim_bk_col (queue_id) and filters to is_current=1.
# Note: dim_queue was built with business_key_cols=['queue_id','queue_name'],
#       so we resolve on the single natural key queue_id for the lookup join.
contact_df = resolve_dim_key(  # noqa: F821  # type: ignore[name-defined]
    spark           = spark,
    source_df       = contact_df,
    source_col      = "last_queue_id",
    dim_table       = "gold.dim_queue",
    dim_bk_col      = "queue_id",
    dim_sk_col      = "queue_key",
    target_col_name = "queue_key",
    unknown_key     = -1,
    is_current_col  = "is_current",
)

# ── agent_key: defaults to -1 pending nb_gold_webex_dim_agent.py ─────────────
# TODO: replace with resolve_dim_key call once dim_agent is available for CC.
contact_df = contact_df.withColumn("agent_key", F.lit(-1).cast("long"))

# ── contact_key surrogate ─────────────────────────────────────────────────────
contact_df = contact_df.withColumn(
    _surrogate_key_col,
    make_surrogate_key(*[F.col(c) for c in _business_key_cols])  # noqa: F821 # type: ignore[name-defined]
)

# ── Final column selection in DDL order ───────────────────────────────────────
contact_df = contact_df.select(
    # ── Keys ──────────────────────────────────────────────────────────────
    _surrogate_key_col,          # contact_key
    "contact_id",
    "date_key",
    "agent_key",
    "queue_key",
    "team_key",
    "site_key",
    "entry_point_key",
    "channel_key",
    # ── Degenerate dims ───────────────────────────────────────────────────
    "direction",
    "contact_handle_type",
    "contact_status",
    "routing_type",
    # ── Contact flags/measures ────────────────────────────────────────────
    "is_inbound",
    "is_offered",
    "is_handled",
    "is_abandoned",
    "is_self_service",
    # ── Duration measures ─────────────────────────────────────────────────
    "total_duration_sec",
    "connected_duration_sec",
    "hold_duration_sec",
    "wrapup_duration_sec",
    # ── Primary leg measures ──────────────────────────────────────────────
    "has_primary_leg",
    "primary_leg_id",
    "leg_queue_duration_sec",
    "leg_ringing_duration_sec",
    "leg_handle_time_sec",
    "leg_sla_value",
    "leg_is_within_service_level",
    "leg_abandoned_sl_count",
    # ── Timestamps ────────────────────────────────────────────────────────
    "created_ts_utc",
    "ended_ts_utc",
    # ── Audit / lineage ───────────────────────────────────────────────────
    "source_system",
    "ingestion_run_id",
    "src_md5_hash",
    "gold_load_ts_utc",
)

gold_count = contact_df.count()
print(f"  Transformed rows : {gold_count:,}")

_has_leg = contact_df.filter(F.col("has_primary_leg") == 1).count()
print(f"  Contacts with primary leg : {_has_leg:,}  ({round(100*_has_leg/gold_count,1)}%)")
print(f"  Contacts without leg      : {gold_count - _has_leg:,}")

display(contact_df.limit(2))


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Load via GoldLoader (SCD1)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Instantiating GoldLoader")

loader = GoldLoader(spark)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")

print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")

_load_start = time.time()
loader.load(
    df                = contact_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
    partition_cols    = ["date_key"],
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Null-key validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[4/4] Null-key and FK validation")

_fk_cols = ["date_key", "queue_key", "team_key", "site_key", "entry_point_key", "channel_key"]

_null_checks = (
    spark.table(_target_table)
    .select([
        F.sum(F.when(F.col(c).isNull() | (F.col(c) < F.lit(-1)), 1).otherwise(0)).alias(c)
        for c in _fk_cols
    ])
)
print("  FK null/invalid counts (should all be 0):")
_null_checks.show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — KPI spot-check (from mapping KPI_logic tab)
# ══════════════════════════════════════════════════════════════════════════════

print("\n  KPI spot-check (day-level expected ranges from mapping spec):")
print("  Calls Count      ≈ 1,982")
print("  Abandonment %    ≈ 4.19%")
print("  ASA              ≈ 64 s")
print("  Answered <30s %  ≈ 62.8%")
print()

_kpi_df = spark.sql(f"""
    SELECT
        COUNT(*) FILTER (WHERE is_inbound = 1 AND channel_type = 'telephony')
            AS calls_count,
        ROUND(100.0 * SUM(is_abandoned) / NULLIF(SUM(is_offered), 0), 2)
            AS abandonment_rate_pct,
        ROUND(
            SUM(CASE WHEN has_primary_leg = 1 AND is_inbound = 1
                     THEN leg_queue_duration_sec + leg_ringing_duration_sec END)
            / NULLIF(COUNT(*) FILTER (WHERE has_primary_leg = 1 AND is_inbound = 1), 0),
        1)  AS asa_sec,
        ROUND(
            100.0 * SUM(CASE WHEN has_primary_leg = 1 AND leg_sla_value = 30
                             THEN leg_is_within_service_level END)
            / NULLIF(COUNT(*) FILTER (WHERE has_primary_leg = 1 AND leg_sla_value = 30), 0),
        1)  AS pct_answered_30s
    FROM {_target_table}
    JOIN lh_silver.silver_s2.csr_base src ON src.id = contact_id
""")

_kpi_df.show(truncate=False)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_fact_contact — COMPLETE")
print(f"  Source contacts  : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Has primary leg  : {_has_leg:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
