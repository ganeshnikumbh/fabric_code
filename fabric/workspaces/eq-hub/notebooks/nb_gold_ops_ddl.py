# Notebook: nb_gold_ops_ddl
# Layer:    Gold
# Purpose:  Materializes silver_s2 views into physical Delta tables in the Gold
#           Lakehouse under the ops_eqwarehouse schema.
#           Reads active entities from dbo.ingestion_config via JDBC to determine
#           which objects to create and whether each is SCD2.
#
# Table strategy (mirrors silver_s2 view naming):
#   is_scd2 = 1  →  two tables per entity:
#                     <target_schema>.<table_name>_current  — SELECT * FROM silver_s2.<table_name>_current
#                     <target_schema>.<table_name>_history  — SELECT * FROM silver_s2.<table_name>_history
#   is_scd2 = 0  →  one table per entity:
#                     <target_schema>.<table_name>          — SELECT * FROM silver_s2.<table_name>
#
# Source objects absent from silver_s2 at run time are skipped with a warning.
#
# Pipeline / manual run:
#   Notebook activity   : nb_gold_ops_ddl
#   Parameters          : p_jdbc_url, p_source_name, p_source_schema, p_target_schema
#   Default lakehouse   : lh_gold (silver_s2 must be accessible via shortcut)
#
# Idempotent — uses CREATE OR REPLACE TABLE throughout.
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - silver_s2 views must be accessible (shortcut from lh_silver added to lh_gold).

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_gold_ops_ddl").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_jdbc_url      = ""               # REQUIRED — Fabric SQL DB JDBC connection string
p_source_name   = "EQ_Warehouse"   # REQUIRED — source name to filter ingestion_config
p_source_schema = "silver_s2"      # Source schema containing the views (default: silver_s2)
p_target_schema = "ops_eqwarehouse" # Target schema in Gold lakehouse (default: ops_eqwarehouse)

if not p_jdbc_url or not p_jdbc_url.strip():
    raise ValueError("Parameter 'p_jdbc_url' is required.")
if not p_source_name or not p_source_name.strip():
    raise ValueError("Parameter 'p_source_name' is required.")
if not p_source_schema or not p_source_schema.strip():
    raise ValueError("Parameter 'p_source_schema' is required.")
if not p_target_schema or not p_target_schema.strip():
    raise ValueError("Parameter 'p_target_schema' is required.")

print("=" * 65)
print("  nb_gold_ops_ddl — START")
print("=" * 65)
print(f"  source_name   : {p_source_name}")
print(f"  source_schema : {p_source_schema}")
print(f"  target_schema : {p_target_schema}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read active ingestion_config
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading active ingestion_config for source '{p_source_name}'")

active_rows = get_ingestion_config_by_source(p_jdbc_url, p_source_name).collect()  # noqa: F821  # type: ignore[name-defined]
print(f"  Active entities : {len(active_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Ensure target schema exists
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/3] Ensuring {p_target_schema} schema exists")
spark.sql(f"CREATE SCHEMA IF NOT EXISTS {p_target_schema}")
print(f"  Schema {p_target_schema} ready")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Materialize tables
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Materializing tables in {p_target_schema}")

tables_created = 0
tables_skipped = 0
errors         = []

for row in active_rows:
    target_table = row["target_table"]
    is_scd2      = bool(row["is_scd2"]) if row["is_scd2"] is not None else False

    try:
        if is_scd2:
            # ── Table 1: current records (sourced from _current view) ─────────
            src_current  = f"{p_source_schema}.{target_table}_current"
            tgt_current  = f"{p_target_schema}.{target_table}_current"

            if not spark.catalog.tableExists(src_current):
                print(f"  SKIP  {src_current:<60} — not found in {p_source_schema}")
                tables_skipped += 1
            else:
                spark.sql(f"""
                    CREATE OR REPLACE TABLE {tgt_current}
                    AS SELECT * FROM {src_current}
                """)
                print(f"  CREATED {tgt_current}")
                tables_created += 1

            # ── Table 2: full history (sourced from _history view) ────────────
            src_history  = f"{p_source_schema}.{target_table}_history"
            tgt_history  = f"{p_target_schema}.{target_table}_history"

            if not spark.catalog.tableExists(src_history):
                print(f"  SKIP  {src_history:<60} — not found in {p_source_schema}")
                tables_skipped += 1
            else:
                spark.sql(f"""
                    CREATE OR REPLACE TABLE {tgt_history}
                    AS SELECT * FROM {src_history}
                """)
                print(f"  CREATED {tgt_history}")
                tables_created += 1

        else:
            # ── Single table (sourced from non-SCD view) ──────────────────────
            src_view  = f"{p_source_schema}.{target_table}"
            tgt_table = f"{p_target_schema}.{target_table}"

            if not spark.catalog.tableExists(src_view):
                print(f"  SKIP  {src_view:<60} — not found in {p_source_schema}")
                tables_skipped += 1
            else:
                spark.sql(f"""
                    CREATE OR REPLACE TABLE {tgt_table}
                    AS SELECT * FROM {src_view}
                """)
                print(f"  CREATED {tgt_table}")
                tables_created += 1

    except Exception as e:
        errors.append((target_table, str(e)))
        print(f"  ERROR {target_table}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_ops_ddl — COMPLETE")
print(f"  Tables created  : {tables_created}")
print(f"  Objects skipped : {tables_skipped}  (not yet in {p_source_schema})")
print(f"  Errors          : {len(errors)}")
print(f"  Elapsed         : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} table(s) failed to create. "
        f"See output above for details."
    )
