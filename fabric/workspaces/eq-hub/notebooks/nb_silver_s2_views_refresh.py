# Notebook: nb_silver_s2_views_refresh
# Layer:    Silver S2
# Purpose:  FULL-refreshes the Fabric Materialized Lake Views in lh_silver.dbo
#           for a given source.  Reads active entities from dbo.ingestion_config
#           via JDBC (same pattern as nb_silver_s2_views_ddl) to determine which
#           views exist and whether each table is SCD2.
#
#           NOTE — Fabric distinguishes a Materialized Lake View (MLV, a Spark/
#           Lakehouse object created with CREATE MATERIALIZED LAKE VIEW) from a
#           Warehouse Materialized View.  This notebook refreshes MLVs only,
#           using:
#               REFRESH MATERIALIZED LAKE VIEW <view> FULL
#           FULL forces a complete recompute from the source tables rather than
#           an incremental refresh.
#
# View naming (must match nb_silver_s2_views_ddl):
#   is_scd2 = 1  →  <table>_current  and  <table>_history
#   is_scd2 = 0  →  <table>
#
# Pipeline / manual run:
#   Parameters        : p_jdbc_url, p_source_name
#   Default lakehouse : lh_silver
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - The materialized lake views must already exist (run nb_silver_s2_views_ddl
#     first).  Views that don't exist yet are skipped, not created.

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_silver_s2_views_refresh").getOrCreate()

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

# Target lakehouse and schema where the materialized lake views live
_TARGET_LH     = "lh_silver"
_TARGET_SCHEMA = "dbo"

print("=" * 65)
print("  nb_silver_s2_views_refresh — START")
print("=" * 65)
print(f"  source_name    : {p_source_name}")
print(f"  target         : {_TARGET_LH}.{_TARGET_SCHEMA}")
print(f"  refresh mode   : FULL")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read active ingestion_config
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/2] Reading active ingestion_config for source '{p_source_name}'")

active_rows = get_ingestion_config_by_source(p_jdbc_url, p_source_name).collect()  # noqa: F821  # type: ignore[name-defined]
print(f"  Active entities : {len(active_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Build the list of views to refresh, then full-refresh each
#
# For each active entity, derive the view name(s) using the same SCD2 rule as
# nb_silver_s2_views_ddl, so the two notebooks stay in lock-step.
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/2] Full-refreshing materialized lake views in {_TARGET_LH}.{_TARGET_SCHEMA}")

# Collect (view_name) targets first so the summary reflects everything attempted.
view_targets = []
for row in active_rows:
    target_table = row["target_table"]
    is_scd2      = bool(row["is_scd2"]) if row["is_scd2"] is not None else False

    if is_scd2:
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}_current")
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}_history")
    else:
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{target_table}")

print(f"  Views to refresh : {len(view_targets)}")

refreshed = 0
skipped   = 0
errors    = []

for view_name in view_targets:
    # ── Guard: skip views that don't exist yet (DDL not run) ──────────────────
    if not spark.catalog.tableExists(view_name):
        print(f"  SKIP      {view_name:<60} — view does not exist")
        skipped += 1
        continue

    t0 = time.time()
    try:
        spark.sql(f"REFRESH MATERIALIZED LAKE VIEW {view_name} FULL")
        print(f"  REFRESHED {view_name:<60} ({time.time() - t0:.1f}s)")
        refreshed += 1
    except Exception as e:
        errors.append((view_name, str(e)))
        print(f"  ERROR     {view_name}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_silver_s2_views_refresh — COMPLETE")
print(f"  Views refreshed : {refreshed}")
print(f"  Views skipped   : {skipped}  (not found — run nb_silver_s2_views_ddl first)")
print(f"  Errors          : {len(errors)}")
print(f"  Elapsed         : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for view_name, msg in errors:
        print(f"    {view_name}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} materialized lake view(s) failed to refresh. "
        f"See output above for details."
    )
