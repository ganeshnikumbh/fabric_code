# Notebook: nb_gold_fact_agent_training_event
# Layer:    Gold
# Purpose:  Full-refresh load of gold.fact_agent_training_event from
#           lh_silver.silver_s2.agent_training_base_current (SCD2 _current view).
#
# FK resolution strategy (joins to gold dimension tables):
#   agent_key            → lh_silver.silver_s2.agent_base_current to resolve agent_number
#                          from agent_id, then → lh_gold.gold.dim_agent on agent_number
#   product_training_key → gold.dim_product_training on training_code
#                          NOTE: dim_product_training has compound grain
#                          (course × product × state).  If agent_training_base
#                          does not carry product_id / state_code, the join will
#                          return multiple rows.  Add a filter or a more specific
#                          join condition once the source schema is confirmed.
#   completion_date_key  → gold.dim_date            on calendar_date
#   expiration_date_key  → gold.dim_date            on calendar_date (LEFT JOIN)
#
# Write pattern: full OVERWRITE on every run (source is the _current view).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).
#   - gold.dim_agent, gold.dim_product_training, gold.dim_date must be loaded
#     before running this notebook.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from delta.tables import DeltaTable

spark = SparkSession.builder.appName("nb_gold_fact_agent_training_event").getOrCreate()

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

_SOURCE_VIEW  = "lh_silver.silver_s2.agent_training_base_current"
_TARGET_TABLE = "lh_gold.gold.fact_agent_training_event"

print("=" * 65)
print("  nb_gold_fact_agent_training_event — START")
print("=" * 65)
print(f"  source          : {_SOURCE_VIEW}")
print(f"  target          : {_TARGET_TABLE}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read source and dimension tables
# ══════════════════════════════════════════════════════════════════════════════

print("\n[1/4] Reading source and dimension tables")

src_df         = spark.table(_SOURCE_VIEW)
agent_base_df  = spark.table("lh_silver.silver_s2.agent_base_current")
dim_agent_df   = spark.table("lh_gold.gold.dim_agent")
dim_pt_df      = spark.table("lh_gold.gold.dim_product_training")
dim_date_df    = spark.table("lh_gold.gold.dim_date")

source_count = src_df.count()
print(f"  {_SOURCE_VIEW:<50} : {source_count:,}")
print(f"  lh_silver.silver_s2.agent_base_current             : {agent_base_df.count():,}")
print(f"  lh_gold.gold.dim_agent                             : {dim_agent_df.count():,}")
print(f"  lh_gold.gold.dim_product_training                  : {dim_pt_df.count():,}")
print(f"  lh_gold.gold.dim_date                              : {dim_date_df.count():,}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Build fact DataFrame with resolved FKs
# ══════════════════════════════════════════════════════════════════════════════

print("\n[2/4] Resolving foreign keys and computing surrogate key")

# ── Prepare dimension lookup DataFrames ────────────────────────────────────────

# dim_agent: keep only current records, select lookup key + SK
agent_lookup = (
    dim_agent_df
    .filter(F.col("is_current") == True)  # noqa: E712
    .select(
        F.col("agent_number").alias("lkp_agent_number"),
        F.col("agent_key").alias("resolved_agent_key"),
    )
)

# dim_product_training: select training_code + SK
# NOTE: If one training_code maps to multiple (product × state) combinations
#       in dim_product_training, this join will fanout fact rows.  Refine the
#       join condition (add product_id / state_code from the fact source) once
#       the agent_training_base schema is confirmed.
pt_lookup = (
    dim_pt_df
    .select(
        F.col("training_code").alias("lkp_training_code"),
        F.col("product_training_key").alias("resolved_product_training_key"),
    )
    .dropDuplicates(["lkp_training_code"])   # guard against fanout until join is refined
)

# dim_date: select calendar_date + SK for role-play columns
date_lookup = (
    dim_date_df
    .select(
        F.col("calendar_date").alias("lkp_calendar_date"),
        F.col("date_key").alias("resolved_date_key"),
    )
)

# ── Prepare source: derive date columns; enrich with agent_number from silver ───
# agent_training_base has agent_id (INT) but not agent_number.
# Join to agent_base_current to resolve agent_number before looking up dim_agent.

src_prepared = (
    src_df
    .withColumn("completion_date", F.col("completion_timestamp").cast("date"))
    .withColumn("expiration_date", F.col("expiration_timestamp").cast("date"))
    .join(
        agent_base_df.select(
            F.col("agent_id").alias("ab_agent_id"),
            F.col("agent_number").alias("ab_agent_number"),
        ),
        F.col("agent_id") == F.col("ab_agent_id"),
        "left",
    )
)

# ── Join to dimensions ─────────────────────────────────────────────────────────

fact_df = (
    src_prepared.alias("at")

    # agent_key — join on agent_number resolved from agent_base_current
    .join(
        agent_lookup.alias("da"),
        F.col("at.ab_agent_number") == F.col("da.lkp_agent_number"),
        "left",
    )

    # product_training_key — join on training_course_id (cast to string = dim training_code)
    .join(
        pt_lookup.alias("dpt"),
        F.col("at.training_course_id").cast("string") == F.col("dpt.lkp_training_code"),
        "left",
    )

    # completion_date_key
    .join(
        date_lookup.alias("dd_comp"),
        F.col("at.completion_date") == F.col("dd_comp.lkp_calendar_date"),
        "left",
    )

    # expiration_date_key
    .join(
        date_lookup.alias("dd_exp"),
        F.col("at.expiration_date") == F.col("dd_exp.lkp_calendar_date"),
        "left",
    )
)

# ── Compute event surrogate key and select final columns ───────────────────────

gold_df = (
    fact_df
    .withColumn("agent_training_event_key", make_surrogate_key(  # noqa: F821  # type: ignore[name-defined]
        F.col("at.agent_id"),
        F.col("at.training_course_id"),
        F.col("at.completion_timestamp"),
    ))
    .withColumn("agent_key",            F.col("da.resolved_agent_key"))
    .withColumn("product_training_key", F.col("dpt.resolved_product_training_key"))
    .withColumn("completion_date_key",  F.col("dd_comp.resolved_date_key"))
    .withColumn("expiration_date_key",  F.col("dd_exp.resolved_date_key"))   # NULL when no expiry
    # ── Pipeline audit ─────────────────────────────────────────────────────
    .withColumn("src_busn_asst",        F.lit(p_src_busn_asst).cast("string"))
    .withColumn("ingestion_date",       F.lit(p_ingestion_date).cast("date"))
    .withColumn("ingestion_timestamp",  F.lit(p_ingestion_timestamp).cast("timestamp"))
    # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        "agent_training_event_key",
        "agent_key",
        "product_training_key",
        "completion_date_key",
        "expiration_date_key",
        "src_busn_asst",
        "ingestion_date",
        "ingestion_timestamp",
    )
)

gold_count = gold_df.count()
print(f"  Fact rows (after FK resolution) : {gold_count:,}")

# Warn if FK resolution produced more rows than source (fanout indicator)
if gold_count > source_count:
    print(f"  WARNING: row count grew from {source_count:,} to {gold_count:,} — "
          f"check dim_product_training join (training_code may map to multiple product/state rows)")

# Report unresolved FKs
unresolved_agent = gold_df.filter(F.col("agent_key").isNull()).count()
unresolved_pt    = gold_df.filter(F.col("product_training_key").isNull()).count()
unresolved_comp  = gold_df.filter(F.col("completion_date_key").isNull()).count()
if unresolved_agent > 0:
    print(f"  WARNING: {unresolved_agent:,} row(s) with NULL agent_key — agent not found in dim_agent")
if unresolved_pt > 0:
    print(f"  WARNING: {unresolved_pt:,} row(s) with NULL product_training_key — training not in dim_product_training")
if unresolved_comp > 0:
    print(f"  WARNING: {unresolved_comp:,} row(s) with NULL completion_date_key — date not in dim_date")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Write to gold
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Writing {_TARGET_TABLE} (full overwrite)")

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
print("  nb_gold_fact_agent_training_event — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)
