# Notebook: nb_maintenance_bronze
# Layer:    Bronze (lh_bronze)
# Purpose:  Run OPTIMIZE and VACUUM (4-hour retention) on every Delta table
#           across all schemas in lh_bronze. Schemas and tables are discovered
#           dynamically at runtime — no hardcoding required.
#
# !! VACUUM with RETAIN 4 HOURS is below the Delta Lake default minimum (7 days).
#    This notebook disables the retention-duration safety check. Only schedule
#    this when you are certain no active queries or time-travel reads depend on
#    older file versions.
#
# How to run:
#   - Attach lh_bronze as the default lakehouse before running.
#   - Can be run standalone or called from a Fabric Data Pipeline.
#   - Optional pipeline parameter p_schema (e.g. "bronze_eqwarehouse") to target
#     a single schema. Leave empty to run across all schemas.
#   - Optional pipeline parameter p_exclude_schemas (comma-separated) to skip
#     specific schemas on top of the built-in system schema exclusions.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_maintenance_bronze").getOrCreate()

# Allow VACUUM retention below the 7-day Delta Lake default minimum
spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_vacuum_retention_hours = 4    # hours to retain Delta log history
p_schema                 = ""   # optional — target a single schema, e.g. "bronze_eqwarehouse"
                                # leave empty to run across all schemas
p_exclude_schemas        = ""   # optional comma-separated schemas to skip
                                # e.g. "scratch_staging,dev_local"

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Discover schemas and tables dynamically
#
# In Microsoft Fabric, SHOW SCHEMAS returns a column called "namespace" with
# fully-qualified three-part values: workspace.lakehouse.schema
# e.g. "EQ-Fabric-NP-Dev-Data-Ops.lh_bronze.bronze_eqwarehouse"
#
# Each part must be backtick-quoted individually when used in Spark SQL.
# Schema-level filtering compares against the last part only (the schema name).
# ══════════════════════════════════════════════════════════════════════════════

def _quote_namespace(namespace: str) -> str:
    """Backtick-quote each part of a dot-separated namespace for Spark SQL."""
    return ".".join(f"`{p}`" for p in namespace.split("."))

# Schemas that are always excluded — Fabric/Spark system namespaces
_SYSTEM_SCHEMAS = {"information_schema", "default"}

_user_exclude = {s.strip().lower() for s in p_exclude_schemas.split(",") if s.strip()}
_excluded     = _SYSTEM_SCHEMAS | _user_exclude

# SHOW SCHEMAS returns column "namespace" in Fabric Spark
_schema_filter = p_schema.strip().lower()   # non-empty = single-schema mode

all_namespaces = [
    row["namespace"]
    for row in spark.sql("SHOW SCHEMAS").collect()
    if row["namespace"].split(".")[-1].lower() not in _excluded           # always exclude system schemas
    and (not _schema_filter or row["namespace"].split(".")[-1].lower() == _schema_filter)  # p_schema filter
]

if _schema_filter and not all_namespaces:
    raise ValueError(f"Schema '{p_schema}' not found in this lakehouse.")

print(f"Mode               : {'single schema — ' + p_schema if _schema_filter else 'all schemas'}")
print(f"Schemas to process : {len(all_namespaces)}")
for ns in all_namespaces:
    print(f"  {ns}")

# list of (namespace, schema_label, table) tuples
tables_to_process = []
for ns in all_namespaces:
    schema_label = ns.split(".")[-1]   # last part — used for display only
    quoted_ns    = _quote_namespace(ns)
    rows = spark.sql(f"SHOW TABLES IN {quoted_ns}").collect()
    schema_tables = [
        (quoted_ns, schema_label, row["tableName"])
        for row in rows
        if not row["isTemporary"]
    ]
    print(f"  {schema_label}: {len(schema_tables)} table(s)")
    tables_to_process.extend(schema_tables)

print(f"\nTotal tables to maintain: {len(tables_to_process)}\n")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Maintenance loop
# ══════════════════════════════════════════════════════════════════════════════

results = []

for quoted_ns, schema_label, table in tables_to_process:
    full_table   = f"{quoted_ns}.`{table}`"
    display_name = f"{schema_label}.{table}"
    status = {"table": display_name, "optimize": None, "vacuum": None, "error": None}
    t0 = time.time()

    try:
        print(f"[OPTIMIZE] {display_name} ...", end=" ")
        spark.sql(f"OPTIMIZE {full_table}")
        status["optimize"] = "ok"
        print(f"done ({time.time() - t0:.1f}s)")
    except Exception as e:
        status["optimize"] = "FAILED"
        status["error"] = str(e)
        print(f"FAILED — {e}")

    try:
        t1 = time.time()
        print(f"[VACUUM]   {display_name} RETAIN {p_vacuum_retention_hours} HOURS ...", end=" ")
        spark.sql(f"VACUUM {full_table} RETAIN {p_vacuum_retention_hours} HOURS")
        status["vacuum"] = "ok"
        print(f"done ({time.time() - t1:.1f}s)")
    except Exception as e:
        status["vacuum"] = "FAILED"
        if status["error"] is None:
            status["error"] = str(e)
        print(f"FAILED — {e}")

    results.append(status)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

elapsed = time.time() - _notebook_start
total   = len(results)
failed  = [r for r in results if r["optimize"] == "FAILED" or r["vacuum"] == "FAILED"]

print("\n" + "=" * 70)
print(f"nb_maintenance_bronze — COMPLETE")
print(f"  Mode              : {'single schema — ' + p_schema if _schema_filter else 'all schemas'}")
print(f"  Schemas processed : {len(all_namespaces)}")
print(f"  Tables processed  : {total}")
print(f"  Failures          : {len(failed)}")
print(f"  Total elapsed     : {elapsed:.1f}s")
print("=" * 70)

if failed:
    print("\nFailed tables:")
    for r in failed:
        print(f"  {r['table']}")
        print(f"    optimize : {r['optimize']}")
        print(f"    vacuum   : {r['vacuum']}")
        print(f"    error    : {r['error']}")
    raise RuntimeError(
        f"nb_maintenance_bronze completed with {len(failed)} failure(s). "
        "See output above for details."
    )
