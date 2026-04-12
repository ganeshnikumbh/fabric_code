# Notebook: nb_update_load_control
# Purpose:  Upserts a row in dbo.source_load_control for a given source entity.
#           Called from the Fabric Pipeline as a Notebook activity after each
#           bronze or silver ingestion run completes (success or failure).
#
# Pipeline wiring:
#   Activity type  : Notebook
#   Parameters     : p_jdbc_url, p_source_name, p_source_table_name,
#                    p_last_load_date, p_bronze_run_status, p_silver_run_status
#
# Notes:
#   - p_bronze_run_status and p_silver_run_status are optional — if not passed
#     (empty string / null) the existing value in the table is preserved.
#   - p_last_load_date is optional — pass only on a successful run.
#   - No lakehouse needs to be attached to this notebook.

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_update_load_control").getOrCreate()

%run nb_utils.py


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_jdbc_url            = ""   # REQUIRED — Fabric SQL DB JDBC connection string
p_source_name         = ""   # REQUIRED — e.g. "EQ_Warehouse"
p_source_table_name   = ""   # REQUIRED — entity_name in ingestion_config, e.g. "Client"
p_last_load_date      = ""   # OPTIONAL — ISO timestamp of last successful load
                             #            e.g. "2025-04-09T01:00:00"
                             #            leave empty to preserve existing value
p_bronze_run_status   = ""   # OPTIONAL — "success" | "failed" | "running" | "skipped"
                             #            leave empty to preserve existing value
p_silver_run_status   = ""   # OPTIONAL — "success" | "failed" | "running" | "skipped"
                             #            leave empty to preserve existing value

# ── Guards ────────────────────────────────────────────────────────────────────
if not p_jdbc_url or not p_jdbc_url.strip():
    raise ValueError("Parameter 'p_jdbc_url' is required.")
if not p_source_name or not p_source_name.strip():
    raise ValueError("Parameter 'p_source_name' is required.")
if not p_source_table_name or not p_source_table_name.strip():
    raise ValueError("Parameter 'p_source_table_name' is required.")

# ── Normalise optionals ───────────────────────────────────────────────────────
_bronze_status  = p_bronze_run_status.strip()  if p_bronze_run_status  else ""
_silver_status  = p_silver_run_status.strip()  if p_silver_run_status  else ""
_last_load_date = p_last_load_date.strip()      if p_last_load_date     else ""

_valid_statuses = {"success", "failed", "running", "skipped", "pending", ""}
if _bronze_status.lower() not in _valid_statuses:
    raise ValueError(f"p_bronze_run_status '{_bronze_status}' is not valid. Use: success | failed | running | skipped | pending")
if _silver_status.lower() not in _valid_statuses:
    raise ValueError(f"p_silver_run_status '{_silver_status}' is not valid. Use: success | failed | running | skipped | pending")

print("=" * 65)
print("  nb_update_load_control — START")
print("=" * 65)
print(f"  source_name       : {p_source_name}")
print(f"  source_table_name : {p_source_table_name}")
print(f"  last_load_date    : {_last_load_date or '(not provided — preserve existing)'}")
print(f"  bronze_run_status : {_bronze_status  or '(not provided — preserve existing)'}")
print(f"  silver_run_status : {_silver_status  or '(not provided — preserve existing)'}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Upsert
# ══════════════════════════════════════════════════════════════════════════════

upsert_load_control(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
    jdbc_url          = p_jdbc_url,
    source_name       = p_source_name,
    entity_name       = p_source_table_name,
    bronze_run_status = _bronze_status  or "pending",
    silver_run_status = _silver_status  or "pending",
    last_load_date    = _last_load_date or None,
)

print("\n" + "=" * 65)
print("  nb_update_load_control — COMPLETE")
print("=" * 65)
