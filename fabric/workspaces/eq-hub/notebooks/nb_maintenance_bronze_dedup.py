# Notebook: nb_maintenance_bronze_dedup
# Layer:    Bronze (lh_bronze)
# Purpose:  Maintenance — remove duplicate rows created by pipeline reruns that
#           appended the same ingestion_date more than once.
#
#           Scope: ONLY rows with ingestion_date = p_ingestion_date are
#           examined and deleted.  All other dates are never touched.
#
#           Dedup rule (per table, within the target ingestion_date):
#             - group rows by md5_hash
#             - keep the row with the latest ingestion_timestamp in each group
#             - delete the older copies
#
#           Safety:
#             - rows with a NULL md5_hash are never deleted (a NULL hash would
#               wrongly group distinct records together)
#             - tables missing md5_hash or ingestion_date are skipped (reported)
#             - tables with no duplicates for the date are skipped (no rewrite)
#             - row counts are verified after the rewrite
#
#           Rewrite uses Delta replaceWhere, which atomically replaces only the
#           target ingestion_date slice — other dates' files are not rewritten.
#
# How to run:
#   - Attach lh_bronze as the default lakehouse before running.
#   - Set p_ingestion_date (REQUIRED) to the date whose rerun duplicates
#     should be removed.
#   - Run with p_dry_run = True first to see per-table duplicate counts.
#   - Optional pipeline parameter p_schema to target a single schema.
#   - Optional pipeline parameter p_exclude_schemas (comma-separated) to skip
#     specific schemas on top of the built-in system schema exclusions.

import time
from pyspark.sql import SparkSession, Window
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_maintenance_bronze_dedup").getOrCreate()

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_ingestion_date  = ""     # REQUIRED — e.g. "2026-04-23"; only this date is deduped
p_schema          = ""     # optional — target a single schema
p_exclude_schemas = ""     # optional comma-separated schemas to skip
p_dry_run         = True   # True = report duplicate counts only, no deletes

_HASH_COL  = "md5_hash"
_DATE_COL  = "ingestion_date"
_ORDER_COL = "ingestion_timestamp"   # latest wins within each dedup group

if not p_ingestion_date or not p_ingestion_date.strip():
    raise ValueError("Parameter 'p_ingestion_date' is required, e.g. '2026-04-23'.")
p_ingestion_date = p_ingestion_date.strip()

print("=" * 70)
print("  nb_maintenance_bronze_dedup — START")
print("=" * 70)
print(f"  ingestion_date : {p_ingestion_date}  (only this date is deduped)")
print(f"  dedup group    : {_HASH_COL} within {_DATE_COL} = '{p_ingestion_date}'")
print(f"  keep           : latest {_ORDER_COL} per group")
print(f"  schema filter  : {p_schema or '(all schemas)'}")
print(f"  dry run        : {p_dry_run}")
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
# SECTION 3 — Dedup loop
# ══════════════════════════════════════════════════════════════════════════════

deduped      = []   # (display_name, rows_deleted)
clean        = []   # tables with no duplicates
missing_cols = []   # tables lacking md5_hash / ingestion_date
errors       = []   # (display_name, message)

for quoted_ns, schema_label, table in tables_to_process:
    full_table   = f"{quoted_ns}.`{table}`"
    display_name = f"{schema_label}.{table}"
    t0 = time.time()

    # ── 3a. Column check ──────────────────────────────────────────────────
    try:
        df   = spark.table(full_table)
        cols = [c.lower() for c in df.columns]
    except Exception as e:
        errors.append((display_name, f"read failed: {e}"))
        print(f"  ERROR      {display_name}: {e}")
        continue

    required = {_HASH_COL, _DATE_COL}
    if not required.issubset(set(cols)):
        missing_cols.append(display_name)
        print(f"  NO COLS    {display_name:<55} — missing {required - set(cols)}, skipped")
        continue

    # Order by ingestion_timestamp when present; otherwise group order is
    # arbitrary, which is still fine (the surviving rows are exact rerun copies).
    order_cols = (
        [F.col(_ORDER_COL).desc()] if _ORDER_COL in cols else [F.lit(1)]
    )

    # ── 3b. Count duplicates for the target ingestion_date ────────────────
    try:
        date_df    = df.filter(F.col(_DATE_COL) == F.lit(p_ingestion_date).cast("date"))
        nonnull_df = date_df.filter(F.col(_HASH_COL).isNotNull())
        date_rows  = date_df.count()
        dup_rows   = (
            nonnull_df.count()
            - nonnull_df.select(_HASH_COL).distinct().count()
        )
    except Exception as e:
        errors.append((display_name, f"duplicate count failed: {e}"))
        print(f"  ERROR      {display_name}: {e}")
        continue

    if date_rows == 0:
        clean.append(display_name)
        print(f"  NO DATA    {display_name:<55} — no rows for {p_ingestion_date}")
        continue

    if dup_rows == 0:
        clean.append(display_name)
        print(f"  CLEAN      {display_name:<55} — no duplicates for {p_ingestion_date}")
        continue

    if p_dry_run:
        print(f"  WOULD DEL  {display_name:<55} — {dup_rows} duplicate row(s) of "
              f"{date_rows} on {p_ingestion_date}")
        deduped.append((display_name, dup_rows))
        continue

    # ── 3c. Replace the target date's slice without duplicates ────────────
    try:
        total_rows = df.count()

        w = Window.partitionBy(_HASH_COL).orderBy(*order_cols)

        dedup_df = (
            nonnull_df
            .withColumn("_rn", F.row_number().over(w))
            .filter(F.col("_rn") == 1)
            .drop("_rn")
        )
        # NULL-hash rows are exempt from dedup — carry them over unchanged
        # (they are part of the replaced slice, so they must be re-written)
        result_df = dedup_df.unionByName(date_df.filter(F.col(_HASH_COL).isNull()))

        expected_rows = total_rows - dup_rows

        # replaceWhere atomically replaces ONLY the target date's slice;
        # rows for every other ingestion_date are untouched
        (
            result_df.select(*df.columns)
            .write
            .format("delta")
            .mode("overwrite")
            .option("replaceWhere", f"{_DATE_COL} = '{p_ingestion_date}'")
            .saveAsTable(full_table)
        )

        rows_after = spark.table(full_table).count()
        if rows_after != expected_rows:
            raise RuntimeError(
                f"row count mismatch after dedup: expected={expected_rows}, actual={rows_after}"
            )

        deduped.append((display_name, dup_rows))
        print(f"  DEDUPED    {display_name:<55} — deleted {dup_rows} row(s) for "
              f"{p_ingestion_date}, {rows_after} total remain ({time.time() - t0:.1f}s)")
    except Exception as e:
        errors.append((display_name, str(e)))
        print(f"  ERROR      {display_name}: {e}")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed   = round(time.time() - _notebook_start, 1)
total_dups = sum(n for _, n in deduped)

print("\n" + "=" * 70)
print("  nb_maintenance_bronze_dedup — COMPLETE")
print(f"  Ingestion date          : {p_ingestion_date}")
print(f"  Tables checked          : {len(tables_to_process)}")
print(f"  Tables with duplicates  : {len(deduped)}")
print(f"  Rows {'to delete' if p_dry_run else 'deleted'}          : {total_dups}")
print(f"  Clean / no data         : {len(clean)}")
print(f"  Missing dedup columns   : {len(missing_cols)}")
print(f"  Errors                  : {len(errors)}")
print(f"  Elapsed                 : {_elapsed}s")
if missing_cols:
    print("\n  Tables missing dedup columns (skipped):")
    for tbl in missing_cols:
        print(f"    {tbl}")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 70)

if errors:
    raise RuntimeError(
        f"{len(errors)} table(s) failed to dedup. See output above for details."
    )
