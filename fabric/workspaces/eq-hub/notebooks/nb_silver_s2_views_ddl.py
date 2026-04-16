# Notebook: nb_silver_s2_views_ddl
# Layer:    Silver S2
# Purpose:  Creates Fabric Materialized Lake Views in lh_silver.dbo over
#           silver_s1 tables.  Reads active entities from dbo.ingestion_config
#           via JDBC to determine which tables exist and whether each is SCD2.
#
# View strategy:
#   is_scd2 = 1  →  two views per table:
#                     lh_silver.dbo.<table_name>_current  — active records only (is_current = 1)
#                     lh_silver.dbo.<table_name>_history  — full history (all rows, no filter)
#   is_scd2 = 0  →  one view per table:
#                     lh_silver.dbo.<table_name>          — all rows, no filter
#
# Columns excluded from every view (audit / pipeline metadata):
#   ingestion_date, data_timestamp, source_system, ingestion_run_id, ingestion_timestamp
#
# SCD2 structural columns (effective_timestamp, expiration_timestamp, is_current)
# are included — they carry business-relevant versioning information.
#
# DDL used:
#   CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS lh_silver.dbo.<view_name> AS
#   SELECT <cols> FROM lh_silver.silver_s1.<table_name> [WHERE is_current = 1]
#
# Note: IF NOT EXISTS is a no-op when the view already exists — re-running this
#       notebook will not overwrite or refresh an existing materialized lake view.
#       Drop the view manually before re-running if you need to redefine it.
#
# Pipeline / manual run:
#   Notebook activity   : nb_silver_s2_views_ddl
#   Parameters          : p_jdbc_url, p_source_name
#   Default lakehouse   : lh_silver
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - silver_s1 tables must exist before views can be created over them.

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_silver_s2_views_ddl").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_jdbc_url    = ""              # REQUIRED — Fabric SQL DB JDBC connection string
p_source_name = "EQ_Warehouse"  # REQUIRED — source name to filter ingestion_config

if not p_jdbc_url or not p_jdbc_url.strip():
    raise ValueError("Parameter 'p_jdbc_url' is required.")
if not p_source_name or not p_source_name.strip():
    raise ValueError("Parameter 'p_source_name' is required.")

# Target lakehouse and schema for materialized lake views
_TARGET_LH     = "lh_silver"
_TARGET_SCHEMA = "dbo"

# Source lakehouse and schema where silver_s1 Delta tables live
_SOURCE_LH     = "lh_silver"
_SOURCE_SCHEMA = "silver_s1"

# Audit columns excluded from every view
_AUDIT_COLS = {
    "ingestion_date",
    "data_timestamp",
    "source_system",
    "ingestion_run_id",
    "ingestion_timestamp",
}

print("=" * 65)
print("  nb_silver_s2_views_ddl — START")
print("=" * 65)
print(f"  source_name    : {p_source_name}")
print(f"  source         : {_SOURCE_LH}.{_SOURCE_SCHEMA}")
print(f"  target         : {_TARGET_LH}.{_TARGET_SCHEMA}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read active ingestion_config
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/2] Reading active ingestion_config for source '{p_source_name}'")

active_rows = get_ingestion_config_by_source(p_jdbc_url, p_source_name).collect()  # noqa: F821  # type: ignore[name-defined]
print(f"  Active entities : {len(active_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Create materialized lake views
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/2] Creating materialized lake views in {_TARGET_LH}.{_TARGET_SCHEMA}")

views_created  = 0
views_existing = 0
views_skipped  = 0
errors         = []

for row in active_rows:
    target_table = row["target_table"]
    is_scd2      = bool(row["is_scd2"]) if row["is_scd2"] is not None else False
    src_ref      = f"{_SOURCE_LH}.{_SOURCE_SCHEMA}.{target_table}"

    # ── Guard: skip if silver_s1 source table doesn't exist yet ──────────────
    if not spark.catalog.tableExists(src_ref):
        print(f"  SKIP     {src_ref:<58} — not found in {_SOURCE_SCHEMA}")
        views_skipped += 1
        continue

    # ── Derive column list (exclude audit cols) ───────────────────────────────
    all_cols    = spark.table(src_ref).columns
    select_cols = [c for c in all_cols if c.lower() not in _AUDIT_COLS]
    col_list    = ",\n               ".join(select_cols)

    try:
        if is_scd2:
            # ── View 1: current records only (is_current = 1) ─────────────────
            view_current     = f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}_current"
            current_exists   = spark.catalog.tableExists(view_current)

            if current_exists:
                print(f"  EXISTS   {view_current}")
                views_existing += 1
            else:
                spark.sql(f"""
                    CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {view_current} AS
                    SELECT {col_list}
                    FROM   {_SOURCE_LH}.{_SOURCE_SCHEMA}.{target_table}
                    WHERE  is_current = 1
                """)
                print(f"  CREATED  {view_current}")
                views_created += 1

            # ── View 2: full history (all rows) ───────────────────────────────
            view_history   = f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}_history"
            history_exists = spark.catalog.tableExists(view_history)

            if history_exists:
                print(f"  EXISTS   {view_history}")
                views_existing += 1
            else:
                spark.sql(f"""
                    CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {view_history} AS
                    SELECT {col_list}
                    FROM   {_SOURCE_LH}.{_SOURCE_SCHEMA}.{target_table}
                """)
                print(f"  CREATED  {view_history}")
                views_created += 1

        else:
            # ── Single view, no row filter ────────────────────────────────────
            view_name    = f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}"
            view_exists  = spark.catalog.tableExists(view_name)

            if view_exists:
                print(f"  EXISTS   {view_name}")
                views_existing += 1
            else:
                spark.sql(f"""
                    CREATE MATERIALIZED LAKE VIEW IF NOT EXISTS {view_name} AS
                    SELECT {col_list}
                    FROM   {_SOURCE_LH}.{_SOURCE_SCHEMA}.{target_table}
                """)
                print(f"  CREATED  {view_name}")
                views_created += 1

    except Exception as e:
        errors.append((target_table, str(e)))
        print(f"  ERROR    {target_table}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_silver_s2_views_ddl — COMPLETE")
print(f"  Views created   : {views_created}")
print(f"  Views existing  : {views_existing}  (IF NOT EXISTS — no change made)")
print(f"  Tables skipped  : {views_skipped}  (not yet in {_SOURCE_SCHEMA})")
print(f"  Errors          : {len(errors)}")
print(f"  Elapsed         : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} materialized lake view(s) failed to create. "
        f"See output above for details."
    )
