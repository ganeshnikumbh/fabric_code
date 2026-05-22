# Notebook: nb_maintenance_silver_s1_cdf
# Layer:    Silver S1 (lh_silver)
# Purpose:  Check that every Delta table in silver_s1 has Change Data Feed
#           enabled (delta.enableChangeDataFeed = true). Tables that are missing
#           the property are patched with ALTER TABLE ... SET TBLPROPERTIES.
#
# How to run:
#   - Attach lh_silver as the default lakehouse before running.
#   - Can be run standalone or called from a Fabric Data Pipeline.
#   - Optional pipeline parameter p_schema to target a different schema.

import time
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_maintenance_silver_s1_cdf").getOrCreate()

_notebook_start = time.time()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_schema  = "silver_s1"   # schema to check
p_dry_run = False         # set True to report only — no ALTER TABLE executed

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Resolve schema to full Fabric namespace
#
# Fabric Spark returns "namespace" from SHOW SCHEMAS as a fully-qualified
# three-part value: workspace.lakehouse.schema
# e.g. "EQ-Fabric-NP-Dev-Data-Ops.lh_silver.silver_s1"
# Each part is backtick-quoted individually for use in Spark SQL.
# ══════════════════════════════════════════════════════════════════════════════

def _quote_namespace(namespace: str) -> str:
    """Backtick-quote each part of a dot-separated namespace for Spark SQL."""
    return ".".join(f"`{p}`" for p in namespace.split("."))

_all_ns  = [row["namespace"] for row in spark.sql("SHOW SCHEMAS").collect()]
_matches = [ns for ns in _all_ns if ns.split(".")[-1].lower() == p_schema.lower()]

if not _matches:
    raise ValueError(f"Schema '{p_schema}' not found. Available schemas: {_all_ns}")

full_namespace = _matches[0]
quoted_ns      = _quote_namespace(full_namespace)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Discover tables
# ══════════════════════════════════════════════════════════════════════════════

rows = spark.sql(f"SHOW TABLES IN {quoted_ns}").collect()
tables = [row["tableName"] for row in rows if not row["isTemporary"]]

print(f"Schema    : {p_schema}")
print(f"Namespace : {full_namespace}")
print(f"Tables    : {len(tables)} discovered")
print(f"Dry run   : {p_dry_run}")
print()

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — CDF check and patch loop
# ══════════════════════════════════════════════════════════════════════════════

results = []   # list of dicts — one per table

for table in tables:
    full_table = f"{quoted_ns}.`{table}`"
    status = {
        "table":       f"{p_schema}.{table}",
        "cdf_before":  None,
        "action":      None,
        "error":       None,
    }

    try:
        detail     = spark.sql(f"DESCRIBE DETAIL {full_table}").collect()[0]
        props      = detail["properties"] or {}
        cdf_before = props.get("delta.enableChangeDataFeed", "false").lower() == "true"
        status["cdf_before"] = cdf_before

        if cdf_before:
            status["action"] = "already_enabled"
            print(f"[OK]     {p_schema}.{table} — CDF already enabled")
        elif p_dry_run:
            status["action"] = "would_enable"
            print(f"[DRY]    {p_schema}.{table} — CDF missing (dry run, no change made)")
        else:
            spark.sql(
                f"ALTER TABLE {full_table} "
                f"SET TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true')"
            )
            status["action"] = "enabled"
            print(f"[FIXED]  {p_schema}.{table} — CDF enabled")

    except Exception as e:
        status["action"] = "FAILED"
        status["error"]  = str(e)
        print(f"[ERROR]  {p_schema}.{table} — {e}")

    results.append(status)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

elapsed      = time.time() - _notebook_start
already_ok   = [r for r in results if r["action"] == "already_enabled"]
fixed        = [r for r in results if r["action"] == "enabled"]
would_fix    = [r for r in results if r["action"] == "would_enable"]
failed       = [r for r in results if r["action"] == "FAILED"]

print("\n" + "=" * 70)
print(f"nb_maintenance_silver_s1_cdf — COMPLETE")
print(f"  Schema           : {p_schema}")
print(f"  Tables checked   : {len(results)}")
print(f"  Already enabled  : {len(already_ok)}")
if p_dry_run:
    print(f"  Would enable     : {len(would_fix)}  (dry run — no changes made)")
else:
    print(f"  Fixed            : {len(fixed)}")
print(f"  Errors           : {len(failed)}")
print(f"  Total elapsed    : {elapsed:.1f}s")
print("=" * 70)

if fixed:
    print("\nTables patched:")
    for r in fixed:
        print(f"  {r['table']}")

if would_fix:
    print("\nTables that would be patched (dry run):")
    for r in would_fix:
        print(f"  {r['table']}")

if failed:
    print("\nFailed tables:")
    for r in failed:
        print(f"  {r['table']} — {r['error']}")
    raise RuntimeError(
        f"nb_maintenance_silver_s1_cdf completed with {len(failed)} error(s). "
        "See output above for details."
    )
