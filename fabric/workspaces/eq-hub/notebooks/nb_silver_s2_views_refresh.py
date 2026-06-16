# Notebook: nb_silver_s2_views_refresh
# Layer:    Silver S2
# Purpose:  FULL-refreshes the Fabric Materialized Lake Views in lh_silver.silver_s2.
#           Entities are read from the p_ingestion_config_json parameter — the
#           full ingestion_config JSON array injected by the pipeline (same
#           pattern as nb_silver_s1_ingestion) — so no JDBC / config-table query
#           is needed.  Whether each table is SCD2 drives how many views exist.
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
#   is_scd2 = 1  →  <silver_table>_current  and  <silver_table>_history
#   is_scd2 = 0  →  <silver_table>
#
# Pipeline / manual run:
#   Parameters        : p_ingestion_config_json
#   Default lakehouse : lh_silver
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - The materialized lake views must already exist (run nb_silver_s2_views_ddl
#     first).  Views that don't exist yet are skipped, not created.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_silver_s2_views_refresh").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_config_json = ""    # REQUIRED — full ingestion_config JSON array

_required = {
    "p_ingestion_config_json": p_ingestion_config_json,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

# Target lakehouse and schema where the materialized lake views live
_TARGET_LH     = "lh_silver"
_TARGET_SCHEMA = "silver_s2"

print("=" * 65)
print("  nb_silver_s2_views_refresh — START")
print("=" * 65)
print(f"  target         : {_TARGET_LH}.{_TARGET_SCHEMA}")
print(f"  refresh mode   : FULL")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read entities from the ingestion_config JSON parameter
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/2] Parsing ingestion_config JSON")

ingestion_config_df = ingestion_config_df_from_json(p_ingestion_config_json)  # noqa: F821  # type: ignore[name-defined]
config_rows = ingestion_config_df.collect()
print(f"  Entities in config : {len(config_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Build the list of views to refresh, then full-refresh each
#
# For each entity, derive the view name(s) using the same SCD2 rule as
# nb_silver_s2_views_ddl, so the two notebooks stay in lock-step.
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/2] Full-refreshing materialized lake views in {_TARGET_LH}.{_TARGET_SCHEMA}")

# Collect (view_name) targets first so the summary reflects everything attempted.
view_targets = []
for row in config_rows:
    silver_table = row["silver_table"]
    is_scd2      = bool(row["is_scd2"]) if row["is_scd2"] is not None else False

    if not silver_table:
        continue  # skip rows without a silver_table (no view is built for them)

    if is_scd2:
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{silver_table}_current")
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{silver_table}_history")
    else:
        view_targets.append(f"{_TARGET_LH}.{_TARGET_SCHEMA}.{silver_table}")

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
