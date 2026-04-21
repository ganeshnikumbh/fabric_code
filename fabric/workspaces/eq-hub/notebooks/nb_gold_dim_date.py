# Notebook: nb_gold_dim_date
# Layer:    Gold
# Purpose:  Full-refresh load of gold.dim_date from lh_silver.silver_s2.date_base.
#           Derives fiscal_year, fiscal_quarter, is_quarter_end from calendar
#           attributes (fiscal year assumed to start 1-Jul — confirm with business).
#
# Write pattern: full OVERWRITE on every run (date_base is not SCD2; full table
#                is small enough to reload completely each time).
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_gold_dim_date").getOrCreate()

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

_SOURCE_VIEW  = "lh_silver.silver_s2.date_base"
_TARGET_TABLE = "lh_gold.gold.dim_date"

print("=" * 65)
print("  nb_gold_dim_date — START")
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
    # ── Surrogate key — YYYYMMDD integer (e.g. 20250409) ──────────────────
    .withColumn("date_key",
        F.date_format(F.col("calendar_timestamp").cast("date"), "yyyyMMdd").cast("long")
    )
    # ── Natural key ────────────────────────────────────────────────────────
    .withColumn("calendar_date",   F.col("calendar_timestamp").cast("date"))
    # ── Day attributes ─────────────────────────────────────────────────────
    .withColumn("day_of_month",    F.col("day_of_month").cast("int"))
    .withColumn("day_of_week",     F.col("day_of_week").cast("int"))
    .withColumn("day_name",        F.col("day_name").cast("string"))
    .withColumn("week_of_year",    F.col("week_of_year").cast("int"))
    # ── Month / quarter / year ─────────────────────────────────────────────
    .withColumn("month",           F.col("month").cast("int"))
    .withColumn("month_name",      F.col("month_name").cast("string"))
    .withColumn("quarter",         F.col("quarter").cast("int"))
    .withColumn("year",            F.col("year").cast("int"))
    # ── Fiscal calendar (fiscal year starts 1-Jul — confirm with business) ─
    .withColumn("fiscal_year",
        F.when(F.col("month").cast("int") >= 7, F.col("year").cast("int") + 1)
         .otherwise(F.col("year").cast("int"))
    )
    .withColumn("fiscal_quarter",
        F.when(F.col("month").cast("int").isin(7, 8, 9),   F.lit(1))
         .when(F.col("month").cast("int").isin(10, 11, 12), F.lit(2))
         .when(F.col("month").cast("int").isin(1, 2, 3),    F.lit(3))
         .otherwise(F.lit(4))
    )
    # ── Boolean flags ──────────────────────────────────────────────────────
    .withColumn("is_weekday",      F.col("is_weekday").cast("boolean"))
    .withColumn("is_holiday",      F.col("is_holiday").cast("boolean"))
    .withColumn("is_month_end",    F.col("is_last_day_of_month").cast("boolean"))
    .withColumn("is_quarter_end",
        (F.col("calendar_timestamp").cast("date") == F.col("last_day_of_quarter").cast("date"))
    )
    # ── Pipeline audit ─────────────────────────────────────────────────────
    .withColumn("src_busn_asst",       F.lit(p_src_busn_asst).cast("string"))
    .withColumn("ingestion_date",      F.lit(p_ingestion_date).cast("date"))
    .withColumn("ingestion_timestamp", F.lit(p_ingestion_timestamp).cast("timestamp"))
    # ── Select final gold columns in DDL order ─────────────────────────────
    .select(
        "date_key",
        "calendar_date",
        "day_of_month",
        "day_of_week",
        "day_name",
        "week_of_year",
        "month",
        "month_name",
        "quarter",
        "year",
        "fiscal_year",
        "fiscal_quarter",
        "is_weekday",
        "is_holiday",
        "is_month_end",
        "is_quarter_end",
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
print("  nb_gold_dim_date — COMPLETE")
print(f"  Source rows      : {source_count:,}")
print(f"  Rows written     : {gold_count:,}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)
