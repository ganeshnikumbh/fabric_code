# Notebook: nb_maintenance_gold
# Layer:    Gold (lh_gold)
# Purpose:  Run OPTIMIZE and VACUUM (4-hour retention) on every Delta table
#           in the gold schema. Tables are discovered dynamically at runtime —
#           no hardcoding required.
#
# !! VACUUM with RETAIN 4 HOURS is below the Delta Lake default minimum (7 days).
#    This notebook disables the retention-duration safety check. Only schedule
#    this when you are certain no active queries or time-travel reads depend on
#    older file versions.
#
# How to run:
#   - Attach lh_gold as the default lakehouse before running.
#   - Can be run standalone or called from a Fabric Data Pipeline.
#   - Optional pipeline parameter p_schema to target a different schema.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_maintenance_gold").getOrCreate()

# Allow VACUUM retention below the 7-day Delta Lake default minimum
spark.conf.set("spark.databricks.delta.retentionDurationCheck.enabled", "false")

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_schema                 = "gold"   # schema to maintain
p_vacuum_retention_hours = 4        # hours to retain Delta log history

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Discover tables dynamically
#
# In Microsoft Fabric, SHOW SCHEMAS returns column "namespace" with fully-
# qualified values: workspace.lakehouse.schema. We resolve p_schema to its
# full namespace so SHOW TABLES and OPTIMIZE/VACUUM use the correct reference.
# ══════════════════════════════════════════════════════════════════════════════

def _quote_namespace(namespace: str) -> str:
    """Backtick-quote each part of a dot-separated namespace for Spark SQL."""
    return ".".join(f"`{p}`" for p in namespace.split("."))

# Resolve p_schema to its full qualified namespace
_all_ns = [row["namespace"] for row in spark.sql("SHOW SCHEMAS").collect()]
_matches = [ns for ns in _all_ns if ns.split(".")[-1].lower() == p_schema.lower()]

if not _matches:
    raise ValueError(f"Schema '{p_schema}' not found. Available schemas: {_all_ns}")

full_namespace = _matches[0]
quoted_ns      = _quote_namespace(full_namespace)

rows = spark.sql(f"SHOW TABLES IN {quoted_ns}").collect()
tables_to_process = [
    row["tableName"]
    for row in rows
    if not row["isTemporary"]
]

print(f"Schema    : {p_schema}")
print(f"Namespace : {full_namespace}")
print(f"Tables    : {len(tables_to_process)} discovered")
for t in tables_to_process:
    print(f"  - {t}")
print()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Maintenance loop
# ══════════════════════════════════════════════════════════════════════════════

results = []

for table in tables_to_process:
    full_table = f"{quoted_ns}.`{table}`"
    status = {"table": f"{p_schema}.{table}", "optimize": None, "vacuum": None, "error": None}
    t0 = time.time()

    try:
        print(f"[OPTIMIZE] {p_schema}.{table} ...", end=" ")
        spark.sql(f"OPTIMIZE {full_table}")
        status["optimize"] = "ok"
        print(f"done ({time.time() - t0:.1f}s)")
    except Exception as e:
        status["optimize"] = "FAILED"
        status["error"] = str(e)
        print(f"FAILED — {e}")

    try:
        t1 = time.time()
        print(f"[VACUUM]   {p_schema}.{table} RETAIN {p_vacuum_retention_hours} HOURS ...", end=" ")
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
print(f"nb_maintenance_gold — COMPLETE")
print(f"  Schema           : {p_schema}")
print(f"  Tables processed : {total}")
print(f"  Failures         : {len(failed)}")
print(f"  Total elapsed    : {elapsed:.1f}s")
print("=" * 70)

if failed:
    print("\nFailed tables:")
    for r in failed:
        print(f"  {r['table']}")
        print(f"    optimize : {r['optimize']}")
        print(f"    vacuum   : {r['vacuum']}")
        print(f"    error    : {r['error']}")
    raise RuntimeError(
        f"nb_maintenance_gold completed with {len(failed)} failure(s). "
        "See output above for details."
    )
