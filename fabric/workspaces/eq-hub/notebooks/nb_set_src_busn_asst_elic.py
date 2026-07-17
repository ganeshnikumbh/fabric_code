# Notebook: nb_set_src_busn_asst_elic
# Purpose:  Maintenance — walks every schema and table in the configured
#           lakehouses (lh_bronze, lh_silver), and for any table that has a
#           src_busn_asst column, sets it to 'elic'.
#
#           Discovery is done against the live catalog (SHOW SCHEMAS / SHOW
#           TABLES) rather than ingestion_config, so it covers every physical
#           table regardless of whether it is registered in the control tables.
#
#           Tables without the src_busn_asst column have it added
#           (ALTER TABLE ... ADD COLUMNS) before the value is set.  The UPDATE
#           only touches rows whose value is not already 'elic', so re-runs are
#           cheap and idempotent.
#
# Pre-requisites:
#   - Add lh_bronze and lh_silver to the notebook session
#     (Notebook settings -> Lakehouses -> Add) so three-part names resolve.

import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_set_src_busn_asst_elic").getOrCreate()

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_lakehouses    = ["lh_bronze", "lh_silver"]  # lakehouses to scan
p_target_column = "src_busn_asst"             # column to set
p_target_type   = "STRING"                     # type used when adding the column
p_target_value  = "elic"                      # value to write
p_dry_run       = False                       # True = report only, no writes

print("=" * 65)
print("  nb_set_src_busn_asst_elic — START")
print("=" * 65)
print(f"  lakehouses     : {', '.join(p_lakehouses)}")
print(f"  target column  : {p_target_column}")
print(f"  target value   : '{p_target_value}'")
print(f"  dry run        : {p_dry_run}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Helpers
# ══════════════════════════════════════════════════════════════════════════════

def list_schemas(lakehouse: str):
    """Return the schema names in a lakehouse."""
    rows = spark.sql(f"SHOW SCHEMAS IN {lakehouse}").collect()
    # column name is 'namespace' (or 'databaseName' on some runtimes)
    field = rows[0].__fields__[0] if rows else "namespace"
    return [r[field] for r in rows]


def list_tables(lakehouse: str, schema: str):
    """Return the table names in a lakehouse.schema."""
    rows = spark.sql(f"SHOW TABLES IN {lakehouse}.{schema}").collect()
    return [r["tableName"] for r in rows]


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Scan and update
# ══════════════════════════════════════════════════════════════════════════════

updated   = []   # (qualified, rows_changed)
added     = []   # tables where the column was added
errors    = []   # (qualified, message)
scanned   = 0

for lakehouse in p_lakehouses:
    print(f"\n[scan] {lakehouse}")

    try:
        schemas = list_schemas(lakehouse)
    except Exception as e:
        errors.append((lakehouse, f"list_schemas failed: {e}"))
        print(f"  ERROR      {lakehouse}: could not list schemas — {e}")
        continue

    for schema in schemas:
        try:
            tables = list_tables(lakehouse, schema)
        except Exception as e:
            errors.append((f"{lakehouse}.{schema}", f"list_tables failed: {e}"))
            print(f"  ERROR      {lakehouse}.{schema}: could not list tables — {e}")
            continue

        for table in tables:
            qualified = f"{lakehouse}.{schema}.{table}"
            scanned += 1

            try:
                cols = [c.lower() for c in spark.table(qualified).columns]
            except Exception as e:
                errors.append((qualified, f"read columns failed: {e}"))
                print(f"  ERROR      {qualified}: {e}")
                continue

            if p_target_column.lower() not in cols:
                if p_dry_run:
                    print(f"  WOULD ADD  {qualified:<60} — add column + set all rows")
                    added.append(qualified)
                    updated.append((qualified, None))
                    continue
                try:
                    spark.sql(
                        f"ALTER TABLE {qualified} "
                        f"ADD COLUMNS ({p_target_column} {p_target_type})"
                    )
                    added.append(qualified)
                    print(f"  ADDED COL  {qualified:<60} — column created")
                except Exception as e:
                    errors.append((qualified, f"add column failed: {e}"))
                    print(f"  ERROR      {qualified}: {e}")
                    continue
                # Column is brand new (all NULL) — fall through to the UPDATE
                # below, which will set every row to the target value.

            # Only count/update rows that are not already the target value.
            pending = spark.table(qualified).filter(
                f"{p_target_column} IS NULL OR {p_target_column} <> '{p_target_value}'"
            ).count()

            if pending == 0:
                print(f"  OK         {qualified:<60} — already set")
                updated.append((qualified, 0))
                continue

            if p_dry_run:
                print(f"  WOULD SET  {qualified:<60} — {pending} row(s)")
                updated.append((qualified, pending))
                continue

            try:
                spark.sql(
                    f"""UPDATE {qualified}
                        SET {p_target_column} = '{p_target_value}'
                        WHERE {p_target_column} IS NULL
                           OR {p_target_column} <> '{p_target_value}'"""
                )
                print(f"  UPDATED    {qualified:<60} — {pending} row(s)")
                updated.append((qualified, pending))
            except Exception as e:
                errors.append((qualified, f"update failed: {e}"))
                print(f"  ERROR      {qualified}: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed   = round(time.time() - _notebook_start, 2)
total_rows = sum(n for _, n in updated if n is not None)

print("\n" + "=" * 65)
print("  nb_set_src_busn_asst_elic — COMPLETE")
print(f"  Tables scanned      : {scanned}")
print(f"  Tables with column  : {len(updated)}")
print(f"  Rows {'to update' if p_dry_run else 'updated'}      : {total_rows}")
print(f"  Columns added       : {len(added)}")
print(f"  Errors              : {len(errors)}")
print(f"  Elapsed             : {_elapsed}s")
if errors:
    print("\n  Error details:")
    for tbl, msg in errors:
        print(f"    {tbl}: {msg}")
print("=" * 65)

if errors:
    raise RuntimeError(
        f"{len(errors)} item(s) failed. See output above for details."
    )
