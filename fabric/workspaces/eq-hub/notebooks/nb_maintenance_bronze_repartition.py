# Notebook: nb_maintenance_bronze_repartition
# Layer:    Bronze (lh_bronze)
# Purpose:  One-time migration — rewrite every Delta table across all schemas
#           in lh_bronze so it is partitioned by ingestion_date.
#
#           Delta Lake cannot add partitioning to an existing table in place,
#           so each table is rewritten with
#             CREATE OR REPLACE TABLE ... PARTITIONED BY (ingestion_date)
#             AS SELECT * FROM <same table>
#           This is atomic (readers see old data until the commit) and keeps
#           the table's Delta history, so time travel to pre-migration
#           versions still works.
#
#           Per table the notebook:
#             - skips it if it has no ingestion_date column   (reported)
#             - skips it if already partitioned by ingestion_date (idempotent)
#             - rewrites it, then verifies row count before vs after
#
# !! This rewrites every data file in the lakehouse — schedule it in a quiet
#    window. Run with p_dry_run = True first to review the plan.
#
# How to run:
#   - Attach lh_bronze as the default lakehouse before running.
#   - Optional pipeline parameter p_schema (e.g. "bronze_eqwarehouse") to target
#     a single schema. Leave empty to run across all schemas.
#   - Optional pipeline parameter p_exclude_schemas (comma-separated) to skip
#     specific schemas on top of the built-in system schema exclusions.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_maintenance_bronze_repartition").getOrCreate()

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_partition_column = "ingestion_date"  # column to partition every table by
p_schema           = ""                # optional — target a single schema
p_exclude_schemas  = ""                # optional comma-separated schemas to skip
p_dry_run          = True              # True = report plan only, no rewrites

print("=" * 70)
print("  nb_maintenance_bronze_repartition — START")
print("=" * 70)
print(f"  partition column : {p_partition_column}")
print(f"  schema filter    : {p_schema or '(all schemas)'}")
print(f"  dry run          : {p_dry_run}")
print("=" * 70)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Discover schemas and tables dynamically
#
# In Microsoft Fabric, SHOW SCHEMAS returns a column called "namespace" with
# fully-qualified three-part values: workspace.lakehouse.schema
# Each part must be backtick-quoted individually when used in Spark SQL.
# ══════════════════════════════════════════════════════════════════════════════

def _quote_namespace(namespace: str) -> str:
    """Backtick-quote each part of a dot-separated namespace for Spark SQL."""
    return ".".join(f"`{p}`" for p in namespace.split("."))

# Schemas that are always excluded — Fabric/Spark system namespaces
_SYSTEM_SCHEMAS = {"information_schema", "default"}

_user_exclude = {s.strip().lower() for s in p_exclude_schemas.split(",") if s.strip()}
_excluded     = _SYSTEM_SCHEMAS | _user_exclude

_schema_filter = p_schema.strip().lower()   # non-empty = single-schema mode

all_namespaces = [
    row["namespace"]
    for row in spark.sql("SHOW SCHEMAS").collect()
    if row["namespace"].split(".")[-1].lower() not in _excluded
    and (not _schema_filter or row["namespace"].split(".")[-1].lower() == _schema_filter)
]

if _schema_filter and not all_namespaces:
    raise ValueError(f"Schema '{p_schema}' not found in this lakehouse.")

print(f"Schemas to process : {len(all_namespaces)}")

# list of (quoted_ns, schema_label, table) tuples
tables_to_process = []
for ns in all_namespaces:
    schema_label = ns.split(".")[-1]
    quoted_ns    = _quote_namespace(ns)
    rows = spark.sql(f"SHOW TABLES IN {quoted_ns}").collect()
    schema_tables = [
        (quoted_ns, schema_label, row["tableName"])
        for row in rows
        if not row["isTemporary"]
    ]
    print(f"  {schema_label}: {len(schema_tables)} table(s)")
    tables_to_process.extend(schema_tables)

print(f"\nTotal tables to check: {len(tables_to_process)}\n")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Repartition loop
# ══════════════════════════════════════════════════════════════════════════════

repartitioned = []   # (display_name, row_count)
already_ok    = []   # already partitioned by the target column
no_column     = []   # tables lacking the partition column
errors        = []   # (display_name, message)

for quoted_ns, schema_label, table in tables_to_process:
    full_table   = f"{quoted_ns}.`{table}`"
    display_name = f"{schema_label}.{table}"
    t0 = time.time()

    # ── 3a. Column check ──────────────────────────────────────────────────
    try:
        cols = [c.lower() for c in spark.table(full_table).columns]
    except Exception as e:
        errors.append((display_name, f"read columns failed: {e}"))
        print(f"  ERROR        {display_name}: {e}")
        continue

    if p_partition_column.lower() not in cols:
        no_column.append(display_name)
        print(f"  NO COLUMN    {display_name:<55} — '{p_partition_column}' missing, skipped")
        continue

    # ── 3b. Already partitioned? (idempotency) ────────────────────────────
    try:
        detail = spark.sql(f"DESCRIBE DETAIL {full_table}").collect()[0]
        current_parts = [c.lower() for c in (detail["partitionColumns"] or [])]
    except Exception as e:
        errors.append((display_name, f"DESCRIBE DETAIL failed: {e}"))
        print(f"  ERROR        {display_name}: {e}")
        continue

    if current_parts == [p_partition_column.lower()]:
        already_ok.append(display_name)
        print(f"  OK           {display_name:<55} — already partitioned")
        continue

    # ── 3c. Rewrite ───────────────────────────────────────────────────────
    if p_dry_run:
        print(f"  WOULD REWRITE {display_name:<54} — partitions now: {current_parts or 'none'}")
        repartitioned.append((display_name, None))
        continue

    try:
        rows_before = spark.table(full_table).count()

        spark.sql(f"""
            CREATE OR REPLACE TABLE {full_table}
            USING DELTA
            PARTITIONED BY ({p_partition_column})
            AS SELECT * FROM {full_table}
        """)

        rows_after = spark.table(full_table).count()
        if rows_after != rows_before:
            raise RuntimeError(
                f"row count mismatch after rewrite: before={rows_before}, after={rows_after}"
            )

        repartitioned.append((display_name, rows_after))
        print(f"  REWRITTEN    {display_name:<55} — {rows_after} rows ({time.time() - t0:.1f}s)")
    except Exception as e:
        errors.append((display_name, str(e)))
        print(f"  ERROR        {display_name}: {e}")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 1)

print("\n" + "=" * 70)
print("  nb_maintenance_bronze_repartition — COMPLETE")
print(f"  Tables checked        : {len(tables_to_process)}")
print(f"  {'Would rewrite' if p_dry_run else 'Rewritten'}         : {len(repartitioned)}")
print(f"  Already partitioned   : {len(already_ok)}")
print(f"  Missing column        : {len(no_column)}")
print(f"  Errors                : {len(errors)}")
print(f"  Elapsed               : {_elapsed}s")
if no_column:
    print("\n  Tables missing the partition column (not rewritten):")
    for tbl in no_column:
        print(f"    {tbl}")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 70)

if errors:
    raise RuntimeError(
        f"{len(errors)} table(s) failed to repartition. See output above for details."
    )
