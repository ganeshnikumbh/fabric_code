# Notebook: nb_logging_library
# Layer: SHARED LIBRARY
# Purpose: Central FabricLogger class — REQUIRED in ALL notebooks with business logic.
#          Buffers log entries in memory and flushes to audit.pipeline_run_log at notebook end.
# Usage:
#   %run /fabric/workspaces/eq-hub/notebooks/nb_logging_library
#   logger = FabricLogger(run_id=run_id, layer="bronze", object_name="contract_base", environment="dev")
#   logger.info("Starting ingestion")
#   logger.record_count("after_read", df.count())
#   logger.flush_to_delta(spark, audit_table_path)

import uuid
import json
from datetime import datetime, timezone
from typing import Optional, Any


class FabricLogger:
    """
    Centralized structured logger for all EquiTrust Fabric notebooks.
    Buffers log entries and flushes to audit.pipeline_run_log Delta table.

    Fields written per entry:
        run_id, layer, object_name, environment, log_level, message,
        extra_json, log_timestamp, record_count_stage, record_count_value
    """

    VALID_LAYERS = {"bronze", "silver_s1", "silver_s2", "gold", "control", "audit", "utility"}
    VALID_LEVELS = {"INFO", "WARNING", "ERROR", "CRITICAL"}

    def __init__(
        self,
        run_id: str,
        layer: str,
        object_name: str,
        environment: str,
    ):
        if layer not in self.VALID_LAYERS:
            raise ValueError(f"Invalid layer '{layer}'. Must be one of: {self.VALID_LAYERS}")

        self.run_id = run_id
        self.layer = layer
        self.object_name = object_name
        self.environment = environment
        self._buffer: list[dict] = []

    def _append(
        self,
        level: str,
        message: str,
        extra: Optional[dict] = None,
        record_count_stage: Optional[str] = None,
        record_count_value: Optional[int] = None,
    ) -> None:
        entry = {
            "run_id": self.run_id,
            "layer": self.layer,
            "object_name": self.object_name,
            "environment": self.environment,
            "log_level": level,
            "message": message,
            "extra_json": json.dumps(extra) if extra else None,
            "log_timestamp": datetime.now(timezone.utc).isoformat(),
            "record_count_stage": record_count_stage,
            "record_count_value": record_count_value,
        }
        self._buffer.append(entry)
        print(f"[{entry['log_timestamp']}] [{level}] [{self.layer}/{self.object_name}] {message}")

    def info(self, message: str, extra: Optional[dict] = None) -> None:
        self._append("INFO", message, extra)

    def warning(self, message: str, extra: Optional[dict] = None) -> None:
        self._append("WARNING", message, extra)

    def error(self, message: str, extra: Optional[dict] = None) -> None:
        self._append("ERROR", message, extra)

    def critical(self, message: str, extra: Optional[dict] = None) -> None:
        self._append("CRITICAL", message, extra)

    def record_count(self, stage: str, count: int, extra: Optional[dict] = None) -> None:
        """Log a record count checkpoint at a named processing stage."""
        self._append(
            "INFO",
            f"Record count at stage '{stage}': {count:,}",
            extra,
            record_count_stage=stage,
            record_count_value=count,
        )

    def flush_to_delta(self, spark: Any, audit_table_path: str) -> None:
        """
        Flush all buffered log entries to the audit.pipeline_run_log Delta table.
        Call this at the END of every notebook — in both success and finally blocks.

        Args:
            spark: Active SparkSession
            audit_table_path: abfss:// path to audit.pipeline_run_log Delta table
        """
        if not self._buffer:
            return

        try:
            from pyspark.sql import Row
            rows = [Row(**entry) for entry in self._buffer]
            log_df = spark.createDataFrame(rows)
            (
                log_df.write
                .format("delta")
                .mode("append")
                .partitionBy("ingestion_date")
                .save(audit_table_path)
            )
            print(f"[FabricLogger] Flushed {len(self._buffer)} log entries to {audit_table_path}")
            self._buffer.clear()
        except Exception as e:
            print(f"[FabricLogger] WARNING: Failed to flush logs to Delta: {e}")
            print("[FabricLogger] Buffered entries:")
            for entry in self._buffer:
                print(f"  {entry}")


def generate_run_id() -> str:
    """Generate a unique run ID for a notebook execution."""
    return str(uuid.uuid4())
