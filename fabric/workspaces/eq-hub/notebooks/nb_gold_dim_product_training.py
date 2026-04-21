# Notebook: nb_gold_dim_product_training
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_product_training.
#           Grain: one row per distinct (training course × product × state).
#
# Source joins:
#   tc   = lh_silver.dbo.training_course_base_current        (driving)
#   tpg  = lh_silver.dbo.training_product_group_base_current
#   tsg  = lh_silver.dbo.training_state_group_base_current
#   p    = lh_silver.dbo.product_base_current
#   s    = lh_silver.dbo.state_base_current
#
# ⚠  Open items (confirm before deploying — see mapping doc open items #4–6):
#   - Join key assumption: tpg.training_product_group_key = tc.training_course_id
#     and tsg.training_state_group_key = tc.training_course_id
#   - Column names in training_course_base (training_code, training_name, context,
#     description) are unverified against schema_config.
#   - product_name and state_name join column names are unverified.
#
# Write pattern: full OVERWRITE on every run.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_product_training").getOrCreate()

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

_TARGET_TABLE = "gold.dim_product_training"

print("=" * 65)
print("  nb_gold_dim_product_training — START")
print("=" * 65)
print(f"  target          : {_TARGET_TABLE}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  src_busn_asst   : {p_src_busn_asst}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read source views
# ══════════════════════════════════════════════════════════════════════════════

print("\n[1/3] Reading silver source views")

tc_df  = spark.table("lh_silver.dbo.training_course_base_current")
tpg_df = spark.table("lh_silver.dbo.training_product_group_base_current")
tsg_df = spark.table("lh_silver.dbo.training_state_group_base_current")
p_df   = spark.table("lh_silver.dbo.product_base_current")
s_df   = spark.table("lh_silver.dbo.state_base_current")

print(f"  training_course_base_current        : {tc_df.count():,}")
print(f"  training_product_group_base_current : {tpg_df.count():,}")
print(f"  training_state_group_base_current   : {tsg_df.count():,}")
print(f"  product_base_current                : {p_df.count():,}")
print(f"  state_base_current                  : {s_df.count():,}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Join and transform
# ══════════════════════════════════════════════════════════════════════════════

print("\n[2/3] Joining and transforming")

# Alias each DataFrame to avoid column name collisions
tc  = tc_df.alias("tc")
tpg = tpg_df.alias("tpg")
tsg = tsg_df.alias("tsg")
p   = p_df.alias("p")
s   = s_df.alias("s")

# ── Build the cross-product of (course × product group × state group) ──────
# Join assumption (verify!):
#   tpg.training_product_group_key = tc.training_course_id
#   tsg.training_state_group_key   = tc.training_course_id
joined_df = (
    tc
    .join(tpg, F.col("tpg.training_product_group_key") == F.col("tc.training_course_id"), "left")
    .join(tsg, F.col("tsg.training_state_group_key")   == F.col("tc.training_course_id"), "left")
    .join(p,   F.col("p.product_id")                   == F.col("tpg.product_id"),         "left")
    .join(s,   F.col("s.state_code")                   == F.col("tsg.state_code"),          "left")
)


gold_df = (
    joined_df
    # ── Surrogate key ──────────────────────────────────────────────────────
    .withColumn("product_training_key", make_surrogate_key(  # noqa: F821  # type: ignore[name-defined]
        F.col("tc.training_code"),
        F.col("tc.training_name"),
        F.col("tpg.product_id"),
        F.col("tsg.state_code"),
    ))
    # ── Business key ───────────────────────────────────────────────────────
    .withColumn("training_code",  F.col("tc.training_code").cast("string"))
    # ── Training course attributes ─────────────────────────────────────────
    .withColumn("training_name",  F.col("tc.training_name").cast("string"))
    .withColumn("context",        F.col("tc.context").cast("string"))
    .withColumn("description",    F.col("tc.description").cast("string"))
    # ── Product association ─────────────────────────────────────────────────
    .withColumn("product_key", make_surrogate_key(F.col("tpg.product_id")))  # noqa: F821  # type: ignore[name-defined]
    .withColumn("product_name",   F.col("p.product_name").cast("string"))
    # ── State association ───────────────────────────────────────────────────
    .withColumn("state_code",     F.col("tsg.state_code").cast("string"))
    .withColumn("state_name",     F.col("s.state_name").cast("string"))
    # ── Pipeline audit ─────────────────────────────────────────────────────
    .withColumn("src_busn_asst",       F.lit(p_src_busn_asst).cast("string"))
    .withColumn("ingestion_date",      F.lit(p_ingestion_date).cast("date"))
    .withColumn("ingestion_timestamp", F.lit(p_ingestion_timestamp).cast("timestamp"))
    # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        "product_training_key",
        "training_code",
        "training_name",
        "context",
        "description",
        "product_key",
        "product_name",
        "state_code",
        "state_name",
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
print("  nb_gold_dim_product_training — COMPLETE")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)
