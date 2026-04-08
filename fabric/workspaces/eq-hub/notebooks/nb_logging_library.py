# Notebook: nb_logging_library
# Layer:    SHARED LIBRARY
# Purpose:  Central FabricLogger — REQUIRED in ALL notebooks with business logic.
#           Writes to three audit tables in lh_control:
#             - pipeline_run_log  : one row per notebook run (start → end + row counts)
#             - error_log         : one row per exception/error captured
#             - data_quality_log  : one row per DQ rule checked
#
# Usage:
#   %run nb_logging_library
#
#   logger = FabricLogger(
#       run_id        = generate_run_id(),
#       pipeline_name = "nb_bronze_contract",
#       entity_name   = "Contract",
#       layer         = "bronze",
#       source_id     = 20,           # from ingestion_config
#       load_type     = "incremental",
#       workspace_name= "eq-hub-dev",
#   )
#   logger.start_run()
#   try:
#       ...
#       logger.set_row_counts(rows_read=1000, rows_written=998, rows_rejected=2)
#       logger.log_dq("contract_id_not_null", "completeness", 1000, 1000, 0, 0.0, 0.0, "passed", "log")
#       logger.end_run("success")
#   except Exception as e:
#       logger.log_error(e, error_category="ingestion")
#       logger.end_run("failed")
#   finally:
#       logger.flush(spark)

import uuid
import traceback
from datetime import datetime, timezone
from typing import Optional, Any


# ── Constants ──────────────────────────────────────────────────────────────────
VALID_LAYERS      = {"landing", "bronze", "silver", "silver_s1", "silver_s2", "gold", "control", "utility"}
VALID_STATUSES    = {"success", "failed", "running", "skipped"}
VALID_DQ_CATS     = {"completeness", "validity", "uniqueness", "consistency", "timeliness"}
VALID_DQ_STATUSES = {"passed", "failed", "warning"}
VALID_DQ_ACTIONS  = {"log", "quarantine", "reject"}
VALID_ERR_CATS    = {"ingestion", "transformation", "dq", "schema", "connectivity"}


def generate_run_id() -> str:
    """Generate a UUID for a notebook execution. Call once per notebook run."""
    return str(uuid.uuid4())


# ── FabricLogger ───────────────────────────────────────────────────────────────

class FabricLogger:
    """
    Structured logger for EquiTrust Fabric notebooks.

    Buffers entries for three audit tables and flushes them all in one
    call to flush(spark) at the end of the notebook (success or failure).

    Tables written:
        pipeline_run_log  — one row per notebook/pipeline run
        error_log         — one row per captured exception
        data_quality_log  — one row per DQ rule execution
    """

    def __init__(
        self,
        run_id:         str,
        pipeline_name:  str,
        entity_name:    str,
        layer:          str,
        workspace_name: str,
        source_id:      Optional[int]  = None,
        load_type:      Optional[str]  = None,
        parent_run_id:  Optional[str]  = None,
        triggered_by:   str            = "manual",
        fabric_workspace_id:  Optional[str] = None,
        fabric_pipeline_id:   Optional[str] = None,
    ):
        if layer not in VALID_LAYERS:
            raise ValueError(f"Invalid layer '{layer}'. Must be one of: {VALID_LAYERS}")

        self.run_id              = run_id
        self.pipeline_name       = pipeline_name
        self.entity_name         = entity_name
        self.layer               = layer
        self.workspace_name      = workspace_name
        self.source_id           = source_id
        self.load_type           = load_type
        self.parent_run_id       = parent_run_id
        self.triggered_by        = triggered_by
        self.fabric_workspace_id = fabric_workspace_id
        self.fabric_pipeline_id  = fabric_pipeline_id

        # Row count accumulators — set via set_row_counts()
        self._rows_read      = None
        self._rows_written   = None
        self._rows_rejected  = None
        self._rows_duplicate = None
        self._watermark_from = None
        self._watermark_to   = None
        self._file_name      = None

        # Run timing
        self._run_start_time: Optional[datetime] = None
        self._run_status    : str                = "running"

        # Buffers — flushed in flush()
        self._run_log:  Optional[dict] = None
        self._errors:   list[dict]     = []
        self._dq_logs:  list[dict]     = []

    # ── Paths ──────────────────────────────────────────────────────────────────

    def _path(self, table: str) -> str:
        return (
            f"abfss://{self.workspace_name}@onelake.dfs.fabric.microsoft.com"
            f"/lh_control.Lakehouse/Files/control_tables/{table}"
        )

    # ── Run lifecycle ──────────────────────────────────────────────────────────

    def start_run(self) -> None:
        """Call at the very beginning of the notebook, before any processing."""
        self._run_start_time = datetime.now(timezone.utc)
        self._run_status     = "running"
        self._print("INFO", f"Run started — pipeline={self.pipeline_name} entity={self.entity_name}")

    def set_row_counts(
        self,
        rows_read:      Optional[int] = None,
        rows_written:   Optional[int] = None,
        rows_rejected:  Optional[int] = None,
        rows_duplicate: Optional[int] = None,
    ) -> None:
        """Set row count metrics to be written into pipeline_run_log at flush."""
        if rows_read      is not None: self._rows_read      = rows_read
        if rows_written   is not None: self._rows_written   = rows_written
        if rows_rejected  is not None: self._rows_rejected  = rows_rejected
        if rows_duplicate is not None: self._rows_duplicate = rows_duplicate
        self._print("INFO",
            f"Row counts — read={rows_read} written={rows_written} "
            f"rejected={rows_rejected} duplicate={rows_duplicate}"
        )

    def set_watermark(self, wm_from: str, wm_to: str) -> None:
        """Record the watermark window used in this incremental run."""
        self._watermark_from = str(wm_from)
        self._watermark_to   = str(wm_to)

    def set_file_name(self, file_name: str) -> None:
        """Record the source file name (for landing/API/SFTP loads)."""
        self._file_name = file_name

    def end_run(
        self,
        status:        str,
        error_message: Optional[str] = None,
    ) -> None:
        """
        Call at the end of the notebook (in both success and except blocks).
        Builds the pipeline_run_log entry — flushed by flush().
        """
        if status not in VALID_STATUSES:
            raise ValueError(f"Invalid status '{status}'. Must be one of: {VALID_STATUSES}")

        now     = datetime.now(timezone.utc)
        start   = self._run_start_time or now
        elapsed = int((now - start).total_seconds())

        self._run_status = status
        self._run_log = {
            "run_id":               self.run_id,
            "parent_run_id":        self.parent_run_id,
            "pipeline_name":        self.pipeline_name,
            "source_id":            self.source_id,
            "entity_name":          self.entity_name,
            "layer":                self.layer,
            "load_type":            self.load_type,
            "run_start_time":       start.isoformat(),
            "run_end_time":         now.isoformat(),
            "duration_seconds":     elapsed,
            "status":               status,
            "rows_read":            self._rows_read,
            "rows_written":         self._rows_written,
            "rows_rejected":        self._rows_rejected,
            "rows_duplicate":       self._rows_duplicate,
            "file_name":            self._file_name,
            "watermark_from":       self._watermark_from,
            "watermark_to":         self._watermark_to,
            "triggered_by":         self.triggered_by,
            "fabric_workspace_id":  self.fabric_workspace_id,
            "fabric_pipeline_id":   self.fabric_pipeline_id,
            "error_message":        error_message,
            "created_date":         now.isoformat(),
        }
        self._print("INFO" if status == "success" else "ERROR",
            f"Run ended — status={status} duration={elapsed}s"
        )

    # ── Error logging ──────────────────────────────────────────────────────────

    def log_error(
        self,
        exception:      Exception,
        error_category: str,
        error_code:     Optional[str] = None,
        is_retriable:   bool          = False,
        retry_count:    int           = 0,
        max_retries:    int           = 3,
    ) -> None:
        """
        Capture an exception into error_log.
        Call in the except block — also call end_run("failed") in the same block.

        Args:
            exception:      The caught exception object.
            error_category: ingestion | transformation | dq | schema | connectivity
            error_code:     Short code (e.g. SCHEMA_MISMATCH). Defaults to exception class name.
            is_retriable:   Whether the pipeline should auto-retry on this error.
            retry_count:    Retry attempts made so far.
            max_retries:    Max retries configured for this pipeline.
        """
        if error_category not in VALID_ERR_CATS:
            raise ValueError(f"Invalid error_category '{error_category}'. Must be one of: {VALID_ERR_CATS}")

        now = datetime.now(timezone.utc)
        entry = {
            "error_id":       str(uuid.uuid4()),
            "run_id":         self.run_id,
            "pipeline_name":  self.pipeline_name,
            "entity_name":    self.entity_name,
            "layer":          self.layer,
            "error_code":     error_code or type(exception).__name__,
            "error_category": error_category,
            "error_message":  str(exception)[:2000],
            "error_details":  traceback.format_exc(),
            "error_time":     now.isoformat(),
            "retry_count":    retry_count,
            "max_retries":    max_retries,
            "is_retriable":   is_retriable,
            "is_resolved":    False,
            "resolved_by":    None,
            "resolved_date":  None,
            "created_date":   now.isoformat(),
        }
        self._errors.append(entry)
        self._print("ERROR", f"[{entry['error_code']}] {entry['error_message'][:200]}")

    def log_error_message(
        self,
        error_message:  str,
        error_category: str,
        error_code:     Optional[str] = None,
        error_details:  Optional[str] = None,
        is_retriable:   bool          = False,
    ) -> None:
        """
        Log a plain-text error (no exception object).
        Use when you want to record a business-logic failure without raising.
        """
        if error_category not in VALID_ERR_CATS:
            raise ValueError(f"Invalid error_category '{error_category}'. Must be one of: {VALID_ERR_CATS}")

        now = datetime.now(timezone.utc)
        entry = {
            "error_id":       str(uuid.uuid4()),
            "run_id":         self.run_id,
            "pipeline_name":  self.pipeline_name,
            "entity_name":    self.entity_name,
            "layer":          self.layer,
            "error_code":     error_code or "PIPELINE_ERROR",
            "error_category": error_category,
            "error_message":  error_message[:2000],
            "error_details":  error_details,
            "error_time":     now.isoformat(),
            "retry_count":    0,
            "max_retries":    3,
            "is_retriable":   is_retriable,
            "is_resolved":    False,
            "resolved_by":    None,
            "resolved_date":  None,
            "created_date":   now.isoformat(),
        }
        self._errors.append(entry)
        self._print("ERROR", f"[{entry['error_code']}] {error_message[:200]}")

    # ── DQ logging ─────────────────────────────────────────────────────────────

    def log_dq(
        self,
        rule_name:       str,
        dq_category:     str,
        records_tested:  int,
        records_passed:  int,
        records_failed:  int,
        failure_rate:    float,
        threshold_rate:  float,
        status:          str,
        action_taken:    str,
        rule_description: Optional[str] = None,
    ) -> None:
        """
        Record a single DQ rule result into data_quality_log.

        Args:
            rule_name:       Unique rule identifier (e.g. contract_id_not_null)
            dq_category:     completeness | validity | uniqueness | consistency | timeliness
            records_tested:  Total rows evaluated
            records_passed:  Rows that passed
            records_failed:  Rows that failed
            failure_rate:    records_failed / records_tested (e.g. 0.0020)
            threshold_rate:  Max acceptable failure rate (e.g. 0.0500)
            status:          passed | failed | warning
            action_taken:    log | quarantine | reject
            rule_description: Optional human-readable description
        """
        if dq_category not in VALID_DQ_CATS:
            raise ValueError(f"Invalid dq_category '{dq_category}'. Must be one of: {VALID_DQ_CATS}")
        if status not in VALID_DQ_STATUSES:
            raise ValueError(f"Invalid DQ status '{status}'. Must be one of: {VALID_DQ_STATUSES}")
        if action_taken not in VALID_DQ_ACTIONS:
            raise ValueError(f"Invalid action_taken '{action_taken}'. Must be one of: {VALID_DQ_ACTIONS}")

        now = datetime.now(timezone.utc)
        entry = {
            "dq_log_id":          str(uuid.uuid4()),
            "run_id":             self.run_id,
            "entity_name":        self.entity_name,
            "layer":              self.layer,
            "dq_rule_name":       rule_name,
            "dq_rule_description":rule_description,
            "dq_category":        dq_category,
            "records_tested":     records_tested,
            "records_passed":     records_passed,
            "records_failed":     records_failed,
            "failure_rate":       round(float(failure_rate), 4),
            "threshold_rate":     round(float(threshold_rate), 4),
            "status":             status,
            "action_taken":       action_taken,
            "checked_at":         now.isoformat(),
            "created_date":       now.isoformat(),
        }
        self._dq_logs.append(entry)
        icon = "✓" if status == "passed" else "✗"
        self._print(
            "INFO" if status == "passed" else "WARNING",
            f"DQ {icon} [{rule_name}] {status} — "
            f"tested={records_tested:,} failed={records_failed:,} "
            f"rate={failure_rate:.4f} threshold={threshold_rate:.4f} action={action_taken}"
        )

    # ── Flush ──────────────────────────────────────────────────────────────────

    def flush(self, spark: Any) -> None:
        """
        Flush all buffered entries to the three audit Delta tables.
        Call in the finally block of every notebook — guaranteed to run
        whether the notebook succeeds or fails.

        Args:
            spark: Active SparkSession (pre-initialized in Fabric notebooks)
        """
        self._flush_pipeline_run_log(spark)
        self._flush_error_log(spark)
        self._flush_dq_log(spark)

    def _flush_pipeline_run_log(self, spark: Any) -> None:
        if not self._run_log:
            self._print("WARNING", "flush() called but end_run() was never called — skipping pipeline_run_log")
            return
        try:
            from pyspark.sql import Row
            from pyspark.sql.types import TimestampType
            df = spark.createDataFrame([Row(**self._run_log)])
            # Cast timestamp strings back to timestamp
            from pyspark.sql import functions as F
            for col in ["run_start_time", "run_end_time", "created_date"]:
                df = df.withColumn(col, F.col(col).cast(TimestampType()))
            (
                df.write.format("delta").mode("append")
                .save(self._path("pipeline_run_log"))
            )
            self._print("INFO", f"Flushed pipeline_run_log — run_id={self.run_id}")
        except Exception as e:
            self._print("ERROR", f"Failed to flush pipeline_run_log: {e}\n{self._run_log}")

    def _flush_error_log(self, spark: Any) -> None:
        if not self._errors:
            return
        try:
            from pyspark.sql import Row
            from pyspark.sql import functions as F
            from pyspark.sql.types import TimestampType
            df = spark.createDataFrame([Row(**e) for e in self._errors])
            for col in ["error_time", "resolved_date", "created_date"]:
                df = df.withColumn(col, F.col(col).cast(TimestampType()))
            (
                df.write.format("delta").mode("append")
                .save(self._path("error_log"))
            )
            self._print("INFO", f"Flushed error_log — {len(self._errors)} error(s)")
            self._errors.clear()
        except Exception as e:
            self._print("ERROR", f"Failed to flush error_log: {e}")
            for entry in self._errors:
                print(f"  [LOST ERROR] {entry['error_message']}")

    def _flush_dq_log(self, spark: Any) -> None:
        if not self._dq_logs:
            return
        try:
            from pyspark.sql import Row
            from pyspark.sql import functions as F
            from pyspark.sql.types import DecimalType, TimestampType
            df = spark.createDataFrame([Row(**d) for d in self._dq_logs])
            df = (
                df
                .withColumn("failure_rate",  F.col("failure_rate").cast(DecimalType(10, 4)))
                .withColumn("threshold_rate", F.col("threshold_rate").cast(DecimalType(10, 4)))
                .withColumn("checked_at",    F.col("checked_at").cast(TimestampType()))
                .withColumn("created_date",  F.col("created_date").cast(TimestampType()))
            )
            (
                df.write.format("delta").mode("append")
                .save(self._path("data_quality_log"))
            )
            self._print("INFO", f"Flushed data_quality_log — {len(self._dq_logs)} rule(s)")
            self._dq_logs.clear()
        except Exception as e:
            self._print("ERROR", f"Failed to flush data_quality_log: {e}")

    # ── Internal ───────────────────────────────────────────────────────────────

    def _print(self, level: str, message: str) -> None:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S")
        print(f"[{ts}] [{level:<8}] [{self.pipeline_name}/{self.entity_name}] {message}")
