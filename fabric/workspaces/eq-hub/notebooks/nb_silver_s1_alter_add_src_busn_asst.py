# Notebook: nb_silver_s1_alter_add_src_busn_asst
# Purpose:  One-time migration — adds the src_busn_asst STRING column to every
#           existing silver_s1 Delta table for the given source.
#
#           Reads active entities from dbo.ingestion_config (same pattern as
#           nb_silver_s2_views_ddl) to determine which tables to alter.
#           Skips tables that already have the column or do not yet exist.
#
# Run once per source after deploying the src_busn_asst change.
# Safe to re-run — the column-exists check prevents duplicate ALTER errors.
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - p_jdbc_url must point to the Fabric SQL DB holding ingestion_config.

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_silver_s1_alter_add_src_busn_asst").getOrCreate()

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

_SOURCE_SCHEMA = "silver_s1"
_NEW_COLUMN    = "src_busn_asst"
_NEW_COL_TYPE  = "STRING"

print("=" * 65)
print("  nb_silver_s1_alter_add_src_busn_asst — START")
print("=" * 65)
print(f"  source_name    : {p_source_name}")
print(f"  target schema  : {_SOURCE_SCHEMA}")
print(f"  adding column  : {_NEW_COLUMN} {_NEW_COL_TYPE}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read active ingestion_config
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/2] Reading active ingestion_config for source '{p_source_name}'")

active_rows = get_ingestion_config_by_source(p_jdbc_url, p_source_name).collect()  # noqa: F821  # type: ignore[name-defined]
print(f"  Active entities : {len(active_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — ALTER each silver_s1 table
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/2] Altering tables in {_SOURCE_SCHEMA}")

altered   = []
skipped   = []
not_found = []
errors    = []

for row in active_rows:
    target_table = row["target_table"]
    qualified    = f"{_SOURCE_SCHEMA}.{target_table}"

    if not spark.catalog.tableExists(qualified):
        print(f"  NOT FOUND  {qualified:<55} — skipping (table does not exist yet)")
        not_found.append(target_table)
        continue

    existing_cols = [c.lower() for c in spark.table(qualified).columns]
    if _NEW_COLUMN.lower() in existing_cols:
        print(f"  EXISTS     {qualified:<55} — column already present")
        skipped.append(target_table)
        continue

    try:
        spark.sql(f"ALTER TABLE {qualified} ADD COLUMNS ({_NEW_COLUMN} {_NEW_COL_TYPE})")
        print(f"  ALTERED    {qualified}")
        altered.append(target_table)
    except Exception as e:
        errors.append((target_table, str(e)))
        print(f"  ERROR      {target_table}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_silver_s1_alter_add_src_busn_asst — COMPLETE")
print(f"  Altered        : {len(altered)}")
print(f"  Already exists : {len(skipped)}")
print(f"  Not found      : {len(not_found)}  (tables not yet created — no action needed)")
print(f"  Errors         : {len(errors)}")
print(f"  Elapsed        : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} table(s) failed to alter. See output above for details."
    )
