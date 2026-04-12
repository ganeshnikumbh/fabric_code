# Notebook: nb_log_operation
# Purpose:  Writes a single log entry to the FabricLogger monitoring lakehouse.
#           Called via mssparkutils.notebook.run() from nb_bronze_ingestion_v2
#           (and other ingestion notebooks) so that FabricLogger runs in its
#           OWN Spark session with NO default lakehouse attached.
#
# WHY A SEPARATE NOTEBOOK:
#   FabricLogger creates its own lakehouse (LH_EquiTrust_Monitoring) and writes
#   Delta tables into it. If FabricLogger is initialised inside a notebook that
#   has lh_bronze attached as the default lakehouse, Spark resolves all
#   unqualified table names against lh_bronze — causing FabricLogger to create
#   its monitoring tables (dim_date, dim_time, monitoring_log) there instead of
#   in its own lakehouse.
#
#   Solution: this notebook has NO lakehouse attached. FabricLogger will then
#   create and use LH_EquiTrust_Monitoring as the default for its tables.
#
# SETUP (one-time):
#   1. Open this notebook in Fabric.
#   2. Go to Notebook settings → Lakehouses → ensure NO lakehouse is attached.
#   3. Upload fabric_logging_utils.py to this notebook's Resources/builtin/ folder.
#
# CLEANUP (if FabricLogger already polluted lh_bronze):
#   Run the following in a separate cell against lh_bronze to clean up:
#       spark.sql("DROP TABLE IF EXISTS dim_date")
#       spark.sql("DROP TABLE IF EXISTS dim_time")
#       spark.sql("DROP TABLE IF EXISTS monitoring_log")
#   Then re-run FabricLogger("EquiTrust") from THIS notebook (no lh attached)
#   so it recreates the tables in LH_EquiTrust_Monitoring.
#
# Called from nb_bronze_ingestion_v2 via:
#   mssparkutils.notebook.run(
#       "nb_log_operation",
#       timeout   = 60,
#       arguments = {
#           "p_notebook_name"  : "nb_bronze_ingestion_v2",
#           "p_table_name"     : "bronze_eqwarehouse.client_base",
#           "p_operation_type" : "LOAD",
#           "p_rows_before"    : "0",
#           "p_rows_after"     : "10000",
#           "p_execution_time" : "12.345",
#           "p_message"        : "run_id=...",
#           "p_error_message"  : "",
#       }
#   )

from pyspark.sql import SparkSession
from builtin.fabric_logging_utils import FabricLogger  # type: ignore[import]  — resolves in Fabric runtime only

spark  = SparkSession.builder.appName("nb_log_operation").getOrCreate()
logger = FabricLogger("EquiTrust")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters
# All values are passed as strings from mssparkutils.notebook.run() arguments.
# ══════════════════════════════════════════════════════════════════════════════

p_notebook_name   = ""      # REQUIRED — name of the calling notebook
p_table_name      = ""      # REQUIRED — target table name (e.g. "bronze_eqwarehouse.client_base")
p_operation_type  = "LOAD"  # REQUIRED — LOAD | EXTRACT | TRANSFORM | VALIDATE | etc.
p_rows_before     = "0"     # OPTIONAL — row count before operation
p_rows_after      = "0"     # OPTIONAL — row count after operation
p_execution_time  = "0.0"   # OPTIONAL — execution time in seconds
p_message         = ""      # OPTIONAL — success/info message
p_error_message   = ""      # OPTIONAL — error description (leave empty on success)

# ── Guards ────────────────────────────────────────────────────────────────────
if not p_notebook_name.strip():
    raise ValueError("Parameter 'p_notebook_name' is required.")
if not p_table_name.strip():
    raise ValueError("Parameter 'p_table_name' is required.")

# ── Type coercions (all params arrive as strings from notebook.run) ───────────
_rows_before    = int(p_rows_before)       if p_rows_before    else 0
_rows_after     = int(p_rows_after)        if p_rows_after     else 0
_execution_time = float(p_execution_time)  if p_execution_time else 0.0
_message        = p_message.strip()        if p_message        else None
_error_message  = p_error_message.strip()  if p_error_message  else None


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Log
# ══════════════════════════════════════════════════════════════════════════════

print(f"Logging operation: {p_notebook_name} | {p_table_name} | {p_operation_type}")

logger.log_operation(
    notebook_name  = p_notebook_name,
    table_name     = p_table_name,
    operation_type = p_operation_type,
    rows_before    = _rows_before,
    rows_after     = _rows_after,
    execution_time = _execution_time,
    message        = _message,
    error_message  = _error_message,
)

print("Log entry written to LH_EquiTrust_Monitoring.monitoring_log")
