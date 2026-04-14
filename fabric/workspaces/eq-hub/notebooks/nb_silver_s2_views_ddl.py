# Notebook: nb_silver_s2_ddl
# Layer:    Silver S2
# Purpose:  Creates views in the silver_s2 schema of lh_silver over silver_s1 tables.
#           Reads active entities from dbo.ingestion_config via JDBC to determine
#           which tables exist and whether each is SCD2.
#
# View strategy:
#   is_scd2 = 1  →  two views per table:
#                     <table_name>_current  — active records only (is_current = 1)
#                     <table_name>_history  — full history (all rows, no filter)
#   is_scd2 = 0  →  one view per table:
#                     <table_name>          — all rows, no filter
#
# Columns excluded from every view (audit / pipeline metadata):
#   ingestion_date, data_timestamp, source_system, ingestion_run_id, ingestion_timestamp
#
# SCD2 structural columns (effective_timestamp, expiration_timestamp, is_current)
# are included — they carry business-relevant versioning information.
#
# Pipeline / manual run:
#   Notebook activity   : nb_silver_s2_ddl
#   Parameters          : p_jdbc_url, p_source_name
#   Default lakehouse   : lh_silver (so silver_s1 and silver_s2 resolve correctly)
#
# Idempotent — uses CREATE OR REPLACE VIEW throughout.
# Tables absent from silver_s1 at run time are skipped with a warning.
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_silver_s2_ddl").getOrCreate()

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

# Audit columns excluded from every view
_AUDIT_COLS = {
    "ingestion_date",
    "data_timestamp",
    "source_system",
    "ingestion_run_id",
    "ingestion_timestamp",
}

print("=" * 65)
print("  nb_silver_s2_ddl — START")
print("=" * 65)
print(f"  source_name : {p_source_name}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read active ingestion_config
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/3] Reading active ingestion_config for source '{p_source_name}'")

active_rows = get_ingestion_config_by_source(p_jdbc_url, p_source_name).collect()  # noqa: F821  # type: ignore[name-defined]
print(f"  Active entities : {len(active_rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Ensure silver_s2 schema exists
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/3] Ensuring silver_s2 schema exists")
spark.sql("CREATE SCHEMA IF NOT EXISTS silver_s2")
print(f"  Schema silver_s2 ready")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Create views
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Creating views in silver_s2")

views_created = 0
views_skipped = 0
errors        = []

for row in active_rows:
    target_table = row["target_table"]
    is_scd2      = bool(row["is_scd2"]) if row["is_scd2"] is not None else False
    src_ref      = f"silver_s1.{target_table}"

    # ── Guard: skip if silver_s1 table doesn't exist yet ─────────────────────
    if not spark.catalog.tableExists(src_ref):
        print(f"  SKIP  {src_ref:<55} — not found in silver_s1")
        views_skipped += 1
        continue

    # ── Derive column list (exclude audit cols) ───────────────────────────────
    all_cols    = spark.table(src_ref).columns
    select_cols = [c for c in all_cols if c.lower() not in _AUDIT_COLS]
    col_list    = ",\n           ".join(select_cols)

    try:
        if is_scd2:
            # ── View 1: current records only ──────────────────────────────────
            view_current = f"silver_s2.{target_table}_current"
            spark.sql(f"""
                CREATE OR REPLACE VIEW {view_current} AS
                SELECT {col_list}
                FROM   silver_s1.{target_table}
                WHERE  is_current = 1
            """)
            print(f"  CREATED {view_current}")
            views_created += 1

            # ── View 2: full history ──────────────────────────────────────────
            view_history = f"silver_s2.{target_table}_history"
            spark.sql(f"""
                CREATE OR REPLACE VIEW {view_history} AS
                SELECT {col_list}
                FROM   silver_s1.{target_table}
            """)
            print(f"  CREATED {view_history}")
            views_created += 1

        else:
            # ── Single view, no row filter ────────────────────────────────────
            view_name = f"silver_s2.{target_table}"
            spark.sql(f"""
                CREATE OR REPLACE VIEW {view_name} AS
                SELECT {col_list}
                FROM   silver_s1.{target_table}
            """)
            print(f"  CREATED {view_name}")
            views_created += 1

    except Exception as e:
        errors.append((target_table, str(e)))
        print(f"  ERROR {target_table}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_silver_s2_ddl — COMPLETE")
print(f"  Views created   : {views_created}")
print(f"  Tables skipped  : {views_skipped}  (not yet in silver_s1)")
print(f"  Errors          : {len(errors)}")
print(f"  Elapsed         : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} view(s) failed to create. "
        f"See output above for details."
    )
