# Notebook: nb_gold_dim_agent
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_agent from
#           lh_silver.silver_s2.agent_base_current (SCD2 _current view).
#
#           agency_name is NOT available in agent_base; the column is written
#           as NULL until the source join path is confirmed (see open item #3 in
#           docs/gold_mapping_agent_training_star_schema.md).
#
# Write pattern: full OVERWRITE on every run.  Because the source is the
#                _current view (active records only), reloading the full table
#                is the safest way to keep the gold dim in sync.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_agent").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date      = ""    # REQUIRED — e.g. "2025-04-09"
p_ingestion_timestamp = ""    # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_src_busn_asst       = ""    # REQUIRED — e.g. "elic"

_required = {
    "p_ingestion_date"      : p_ingestion_date,
    "p_ingestion_timestamp" : p_ingestion_timestamp,
    "p_src_busn_asst"       : p_src_busn_asst,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

_SOURCE_VIEW  = "lh_silver.silver_s2.agent_base_current"
_TARGET_TABLE = "lh_gold.gold.dim_agent"

print("=" * 65)
print("  nb_gold_dim_agent — START")
print("=" * 65)
print(f"  source          : {_SOURCE_VIEW}")
print(f"  target          : {_TARGET_TABLE}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read source view
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading {_SOURCE_VIEW}")

src_df = spark.table(_SOURCE_VIEW)
source_count = src_df.count()
print(f"  Source rows : {source_count:,}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Transform
# ══════════════════════════════════════════════════════════════════════════════

print("\n[2/3] Applying transformations")


gold_df = (
    src_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    # Input: all agent business columns (excludes audit + SCD2 metadata cols)
    .withColumn("agent_key", make_surrogate_key(  # noqa: F821  # type: ignore[name-defined]
        F.col("agent_number"),
        F.col("display_name"),
        F.col("agent_type"),
        F.col("national_producer_number"),
        F.col("nasd_finra_number"),
        F.col("status"),
        F.col("hire_date"),
        F.col("termination_date"),
        F.col("client_id"),
    ))
    # ── Agent identifiers ──────────────────────────────────────────────────
    .withColumn("agent_number",             F.col("agent_number").cast("string"))
    .withColumn("agent_name",               F.col("display_name").cast("string"))   # rename
    .withColumn("agent_type",               F.col("agent_type").cast("string"))
    .withColumn("national_producer_number", F.col("national_producer_number").cast("string"))
    .withColumn("nasd_finra_number",        F.col("nasd_finra_number").cast("string"))
    # ── Status and dates ───────────────────────────────────────────────────
    .withColumn("status",           F.col("status").cast("string"))
    .withColumn("hire_date",        F.col("hire_date").cast("date"))
    .withColumn("termination_date", F.col("termination_date").cast("date"))
    # ── Agency context — NOT IN agent_base; NULL until source confirmed ────
    .withColumn("agency_name", F.lit(None).cast("string"))
    # ── FK to future dim_client ────────────────────────────────────────────
    .withColumn("agent_client_key", make_surrogate_key(F.col("client_id")))  # noqa: F821  # type: ignore[name-defined]
    # ── SCD2 tracking (carried from silver) ────────────────────────────────
    .withColumn("effective_timestamp",  F.col("effective_timestamp").cast("timestamp"))
    .withColumn("expiration_timestamp", F.col("expiration_timestamp").cast("timestamp"))
    .withColumn("is_current",           F.col("is_current").cast("boolean"))
    # ── Pipeline audit ─────────────────────────────────────────────────────
    .withColumn("src_busn_asst",       F.lit(p_src_busn_asst).cast("string"))
    .withColumn("ingestion_date",      F.lit(p_ingestion_date).cast("date"))
    .withColumn("ingestion_timestamp", F.lit(p_ingestion_timestamp).cast("timestamp"))
    # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        "agent_key",
        "agent_number",
        "agent_name",
        "agent_type",
        "national_producer_number",
        "nasd_finra_number",
        "status",
        "hire_date",
        "termination_date",
        "agency_name",
        "agent_client_key",
        "effective_timestamp",
        "expiration_timestamp",
        "is_current",
        "src_busn_asst",
        "ingestion_date",
        "ingestion_timestamp",
    )
)

gold_count = gold_df.count()
print(f"  Transformed rows : {gold_count:,}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Write to gold
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Writing {_TARGET_TABLE} (full overwrite)")

write_delta_create(  # noqa: F821  # type: ignore[name-defined]
    df               = gold_df,
    qualified_target = _TARGET_TABLE,
    tbl_properties   = {"delta.enableChangeDataFeed": "true"},
)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dim_agent — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)
