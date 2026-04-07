# Notebook: nb_control_audit_ddl
# Purpose:  Creates all external Delta control, audit, SLA, and DQ tables
#           in lh_control lakehouse for the metadata-driven ingestion framework.
#           Idempotent — DROP IF EXISTS before every CREATE.
# Run once: during initial environment provisioning, before any ingestion runs.

# In Microsoft Fabric Notebooks, SparkSession is pre-initialized as `spark`.
# getOrCreate() returns that existing session inside Fabric, or creates one locally.
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("nb_control_audit_ddl").getOrCreate()

# ## CELL 1 — Environment Configuration
# ══════════════════════════════════════════════════════════════════════════════
# All environment-specific values are defined here.
# Change only this block when deploying to a new environment.
# ══════════════════════════════════════════════════════════════════════════════

# Fabric workspace and lakehouse identifiers
WORKSPACE_ID   = "__HUB_WORKSPACE_ID__"          # Replace with actual workspace GUID
LAKEHOUSE_NAME = "lh_control"                     # Control lakehouse name
ENVIRONMENT    = "__ENVIRONMENT__"                # dev | qa | tst | prod

# OneLake base path for all control tables
# Pattern: abfss://<workspace>@onelake.dfs.fabric.microsoft.com/<lakehouse>.Lakehouse/Files/control_tables/<table>/
ONELAKE_HOST   = "onelake.dfs.fabric.microsoft.com"
BASE_PATH      = (
    f"abfss://{WORKSPACE_ID}@{ONELAKE_HOST}"
    f"/{LAKEHOUSE_NAME}.Lakehouse/Files/control_tables"
)

# Control database / schema name
CONTROL_DB = "control_db"

print(f"Environment  : {ENVIRONMENT}")
print(f"Lakehouse    : {LAKEHOUSE_NAME}")
print(f"Base path    : {BASE_PATH}")
print(f"Control DB   : {CONTROL_DB}")


# ## CELL 2 — Create Control Database
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"CREATE DATABASE IF NOT EXISTS {CONTROL_DB}")
spark.sql(f"USE {CONTROL_DB}")
print(f"Database '{CONTROL_DB}' ready.")


# ## CELL 3 — Table 1: ingestion_config
# Master configuration table for all source entities across all sources.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.ingestion_config")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.ingestion_config (
    source_id           INT         NOT NULL  COMMENT 'Primary key — unique identifier for each source entity configuration',
    source_name         STRING      NOT NULL  COMMENT 'Human-readable name for the source system (e.g. EQ_Warehouse, MortalityAPI)',
    source_type         STRING      NOT NULL  COMMENT 'Source technology type: sqlserver | oracle | api | sftp | blob',
    entity_name         STRING      NOT NULL  COMMENT 'Source table or API endpoint entity name (e.g. policy_master, mortality_rates)',
    target_lakehouse    STRING      NOT NULL  COMMENT 'Target Fabric lakehouse name (e.g. lh_bronze, lh_silver)',
    target_schema       STRING      NOT NULL  COMMENT 'Target schema/database within the lakehouse (e.g. bronze_eqwarehouse)',
    target_table        STRING      NOT NULL  COMMENT 'Target Delta table name in the destination lakehouse',
    load_type           STRING      NOT NULL  COMMENT 'Ingestion strategy: full | incremental | cdc',
    watermark_column    STRING                COMMENT 'Source column used for incremental filtering (e.g. ModifiedDate, PolicyID)',
    watermark_type      STRING                COMMENT 'Data type of the watermark column: datetime | integer | string',
    batch_size          INT                   COMMENT 'Number of rows per micro-batch for large incremental loads; NULL = no batching',
    extraction_query    STRING                COMMENT 'Custom SQL override query for complex source extractions; NULL = SELECT * FROM entity',
    api_endpoint        STRING                COMMENT 'Full API URL for REST source types; NULL for database sources',
    api_method          STRING                COMMENT 'HTTP method for API sources: GET | POST | PUT',
    api_headers         STRING                COMMENT 'JSON string of HTTP headers required for API authentication/content-type',
    active_flag         BOOLEAN     NOT NULL  COMMENT 'true = entity is included in pipeline runs; false = entity is skipped',
    created_by          STRING      NOT NULL  COMMENT 'User or service principal that created this configuration record',
    created_date        TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this record was first created',
    modified_by         STRING                COMMENT 'User or service principal that last modified this record',
    modified_date       TIMESTAMP             COMMENT 'UTC timestamp of the most recent modification'
)
USING DELTA
LOCATION '{BASE_PATH}/ingestion_config'
COMMENT 'Master configuration table — defines every source entity, target, load strategy, and connectivity settings for the metadata-driven ingestion framework.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.ingestion_config")


# ## CELL 4 — Table 2: watermark_control
# Tracks the last successful load state per source entity.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.watermark_control")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.watermark_control (
    watermark_id                INT         NOT NULL  COMMENT 'Primary key — unique identifier for each watermark tracking record',
    source_id                   INT         NOT NULL  COMMENT 'Foreign key to ingestion_config.source_id',
    entity_name                 STRING      NOT NULL  COMMENT 'Source entity name — denormalized for fast lookup without join',
    last_watermark_value        STRING                COMMENT 'Last successfully processed watermark value stored as string; cast at runtime to watermark_type',
    last_watermark_type         STRING                COMMENT 'Data type of the stored watermark value: datetime | integer | string',
    last_run_datetime           TIMESTAMP             COMMENT 'UTC datetime when the most recent pipeline run started for this entity',
    last_successful_datetime    TIMESTAMP             COMMENT 'UTC datetime of the last run that completed with status = success',
    last_run_status             STRING                COMMENT 'Outcome of the most recent run: success | failed | running',
    created_date                TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this watermark record was first created',
    modified_date               TIMESTAMP             COMMENT 'UTC timestamp of the most recent watermark update'
)
USING DELTA
LOCATION '{BASE_PATH}/watermark_control'
COMMENT 'Watermark state tracker — stores the last successful load boundary per source entity to enable accurate incremental and CDC ingestion restarts.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.watermark_control")


# ## CELL 5 — Table 3: schema_config
# Column-level mapping and transformation rules per source entity.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.schema_config")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.schema_config (
    schema_id               INT         NOT NULL  COMMENT 'Primary key — unique identifier for each column mapping rule',
    source_id               INT         NOT NULL  COMMENT 'Foreign key to ingestion_config.source_id',
    entity_name             STRING      NOT NULL  COMMENT 'Source entity name this column mapping belongs to',
    source_column_name      STRING      NOT NULL  COMMENT 'Exact column name as it appears in the source system',
    target_column_name      STRING      NOT NULL  COMMENT 'Column name in the target Delta table after rename/standardisation',
    source_data_type        STRING                COMMENT 'Data type in the source system (e.g. varchar(50), int, datetime2)',
    target_data_type        STRING                COMMENT 'Target Delta/Spark data type (e.g. STRING, INT, TIMESTAMP, DECIMAL(18,4))',
    transformation_rule     STRING                COMMENT 'Optional M or PySpark expression applied during ingestion (e.g. upper(trim(col)), cast to date)',
    is_pii                  BOOLEAN               COMMENT 'true = column contains personally identifiable information; CLS enforced in semantic model',
    is_nullable             BOOLEAN               COMMENT 'true = column allows NULL values in the target table',
    is_primary_key          BOOLEAN               COMMENT 'true = column is part of the natural/business key for this entity',
    default_value           STRING                COMMENT 'Value applied when source column is NULL (e.g. UNKNOWN, 0, false)',
    ordinal_position        INT                   COMMENT 'Column position in the target table; used to enforce consistent schema ordering',
    active_flag             BOOLEAN     NOT NULL  COMMENT 'true = column is included in ingestion; false = column is excluded/deprecated',
    created_date            TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this column mapping was first created',
    modified_date           TIMESTAMP             COMMENT 'UTC timestamp of the most recent modification to this mapping rule'
)
USING DELTA
LOCATION '{BASE_PATH}/schema_config'
COMMENT 'Column-level schema mapping and transformation registry — defines source-to-target column renames, type casts, PII flags, and transformation expressions per entity.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.schema_config")


# ## CELL 6 — Table 4: pipeline_run_log
# Execution log for every pipeline run across all layers and entities.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.pipeline_run_log")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.pipeline_run_log (
    run_id                  STRING      NOT NULL  COMMENT 'Primary key — UUID uniquely identifying this pipeline execution',
    parent_run_id           STRING                COMMENT 'UUID of the parent pipeline run; NULL for top-level runs; used to link child activity runs',
    pipeline_name           STRING      NOT NULL  COMMENT 'Name of the Fabric Data Pipeline or Notebook that produced this log entry',
    source_id               INT                   COMMENT 'Foreign key to ingestion_config.source_id; NULL for non-entity pipelines',
    entity_name             STRING                COMMENT 'Source entity being processed in this run (e.g. policy_master)',
    layer                   STRING      NOT NULL  COMMENT 'Processing layer: landing | bronze | silver | gold | control',
    load_type               STRING                COMMENT 'Load strategy used in this run: full | incremental | cdc',
    run_start_time          TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when the pipeline run started',
    run_end_time            TIMESTAMP             COMMENT 'UTC timestamp when the pipeline run completed; NULL if still running',
    duration_seconds        INT                   COMMENT 'Total elapsed time in seconds for this run; computed at completion',
    status                  STRING      NOT NULL  COMMENT 'Execution outcome: success | failed | running | skipped',
    rows_read               BIGINT                COMMENT 'Total rows read from the source in this run',
    rows_written            BIGINT                COMMENT 'Total rows successfully written to the target Delta table',
    rows_rejected           BIGINT                COMMENT 'Rows that failed data quality or schema validation and were quarantined',
    rows_duplicate          BIGINT                COMMENT 'Rows identified as duplicates and excluded from the target write',
    file_name               STRING                COMMENT 'Source file name for landing/API/SFTP loads; NULL for database sources',
    watermark_from          STRING                COMMENT 'Watermark value at the start of this incremental load window',
    watermark_to            STRING                COMMENT 'Watermark value at the end of this incremental load window',
    triggered_by            STRING                COMMENT 'How the pipeline was triggered: schedule | manual | event | api',
    fabric_workspace_id     STRING                COMMENT 'Fabric workspace GUID where this pipeline executed',
    fabric_pipeline_id      STRING                COMMENT 'Fabric pipeline item GUID for direct link to the run in the portal',
    error_message           STRING                COMMENT 'Short error summary if status = failed; NULL on success',
    created_date            TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this log record was written'
)
USING DELTA
LOCATION '{BASE_PATH}/pipeline_run_log'
COMMENT 'Pipeline execution log — captures start/end times, row counts, status, watermarks, and error messages for every pipeline run across all layers and entities.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.pipeline_run_log")


# ## CELL 7 — Table 5: data_quality_log
# Results of data quality rule checks per entity per run.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.data_quality_log")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.data_quality_log (
    dq_log_id           STRING          NOT NULL  COMMENT 'Primary key — UUID uniquely identifying this DQ check result',
    run_id              STRING          NOT NULL  COMMENT 'Foreign key to pipeline_run_log.run_id — links DQ result to its pipeline run',
    entity_name         STRING          NOT NULL  COMMENT 'Entity on which the DQ rule was executed (e.g. policy_master)',
    layer               STRING          NOT NULL  COMMENT 'Layer where the DQ check was applied: bronze | silver | gold',
    dq_rule_name        STRING          NOT NULL  COMMENT 'Unique name of the DQ rule executed (e.g. policy_id_not_null, premium_amount_positive)',
    dq_rule_description STRING                    COMMENT 'Human-readable description of what the DQ rule validates',
    dq_category         STRING          NOT NULL  COMMENT 'DQ dimension category: completeness | validity | uniqueness | consistency | timeliness',
    records_tested      BIGINT                    COMMENT 'Total number of records evaluated by this DQ rule',
    records_passed      BIGINT                    COMMENT 'Number of records that passed the DQ rule check',
    records_failed      BIGINT                    COMMENT 'Number of records that failed the DQ rule check',
    failure_rate        DECIMAL(10, 4)            COMMENT 'Proportion of records that failed: records_failed / records_tested',
    threshold_rate      DECIMAL(10, 4)            COMMENT 'Maximum acceptable failure rate before the check is flagged (e.g. 0.0500 = 5%)',
    status              STRING          NOT NULL  COMMENT 'Overall DQ check outcome: passed | failed | warning',
    action_taken        STRING          NOT NULL  COMMENT 'Remediation action applied to failed records: log | quarantine | reject',
    checked_at          TIMESTAMP       NOT NULL  COMMENT 'UTC timestamp when this DQ rule was executed',
    created_date        TIMESTAMP       NOT NULL  COMMENT 'UTC timestamp when this DQ log record was written'
)
USING DELTA
LOCATION '{BASE_PATH}/data_quality_log'
COMMENT 'Data quality rule execution log — records the outcome of every DQ check per entity per run, including failure rates, thresholds, and the remediation action taken.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.data_quality_log")


# ## CELL 8 — Table 6: error_log
# Detailed error and exception capture across all pipeline runs.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.error_log")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.error_log (
    error_id            STRING      NOT NULL  COMMENT 'Primary key — UUID uniquely identifying this error record',
    run_id              STRING      NOT NULL  COMMENT 'Foreign key to pipeline_run_log.run_id — links error to its pipeline run',
    pipeline_name       STRING      NOT NULL  COMMENT 'Name of the pipeline or notebook where the error occurred',
    entity_name         STRING                COMMENT 'Source entity being processed when the error occurred; NULL for infrastructure errors',
    layer               STRING                COMMENT 'Layer where the error occurred: landing | bronze | silver | gold | control',
    error_code          STRING                COMMENT 'Short error code or exception class (e.g. SCHEMA_MISMATCH, SQL_TIMEOUT, HTTP_401)',
    error_category      STRING      NOT NULL  COMMENT 'Error classification: ingestion | transformation | dq | schema | connectivity',
    error_message       STRING      NOT NULL  COMMENT 'Concise error description suitable for alerting and dashboards',
    error_details       STRING                COMMENT 'Full stack trace, JSON payload, or detailed diagnostic context for debugging',
    error_time          TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when the error occurred',
    retry_count         INT                   COMMENT 'Number of retry attempts made before this error record was written',
    max_retries         INT                   COMMENT 'Maximum retry attempts configured for this pipeline (from pipeline_config)',
    is_retriable        BOOLEAN               COMMENT 'true = error type is eligible for automatic retry (e.g. transient connectivity); false = requires manual intervention',
    is_resolved         BOOLEAN               COMMENT 'true = error has been acknowledged and resolved; false = error is still open',
    resolved_by         STRING                COMMENT 'User or service principal that marked the error as resolved',
    resolved_date       TIMESTAMP             COMMENT 'UTC timestamp when the error was marked as resolved',
    created_date        TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this error record was written'
)
USING DELTA
LOCATION '{BASE_PATH}/error_log'
COMMENT 'Centralised error and exception log — captures full diagnostic detail for every pipeline failure including error category, retry state, and resolution tracking.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.error_log")


# ## CELL 9 — Table 7: sla_config
# SLA definitions and alerting configuration per entity per layer.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.sla_config")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.sla_config (
    sla_id                  INT         NOT NULL  COMMENT 'Primary key — unique identifier for each SLA definition',
    source_id               INT         NOT NULL  COMMENT 'Foreign key to ingestion_config.source_id',
    entity_name             STRING      NOT NULL  COMMENT 'Entity to which this SLA applies (e.g. policy_master)',
    layer                   STRING      NOT NULL  COMMENT 'Layer to which this SLA applies: bronze | silver | gold',
    expected_start_time     STRING                COMMENT 'Expected pipeline start time in HH:MM (24hr UTC) format (e.g. 02:00)',
    expected_end_time       STRING                COMMENT 'Expected pipeline completion time in HH:MM (24hr UTC) format (e.g. 04:00)',
    max_duration_minutes    INT                   COMMENT 'Maximum allowed duration in minutes before an SLA breach is logged',
    criticality             STRING      NOT NULL  COMMENT 'Business impact level of a breach: low | medium | high | critical',
    alert_on_breach         BOOLEAN     NOT NULL  COMMENT 'true = send notification when SLA is breached; false = log only',
    alert_email             STRING                COMMENT 'Comma-separated email addresses to notify on SLA breach',
    alert_teams_webhook     STRING                COMMENT 'Microsoft Teams incoming webhook URL for SLA breach notifications',
    active_flag             BOOLEAN     NOT NULL  COMMENT 'true = SLA is actively monitored; false = SLA check is disabled',
    created_date            TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this SLA definition was created',
    modified_date           TIMESTAMP             COMMENT 'UTC timestamp of the most recent modification to this SLA definition'
)
USING DELTA
LOCATION '{BASE_PATH}/sla_config'
COMMENT 'SLA definition and alerting configuration — specifies expected run windows, maximum durations, criticality levels, and notification targets per entity per layer.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.sla_config")


# ## CELL 10 — Table 8: sla_breach_log
# Log of all SLA breaches with notification tracking.
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"DROP TABLE IF EXISTS {CONTROL_DB}.sla_breach_log")

spark.sql(f"""
CREATE EXTERNAL TABLE {CONTROL_DB}.sla_breach_log (
    breach_id               STRING      NOT NULL  COMMENT 'Primary key — UUID uniquely identifying this SLA breach event',
    sla_id                  INT         NOT NULL  COMMENT 'Foreign key to sla_config.sla_id — identifies the breached SLA definition',
    entity_name             STRING      NOT NULL  COMMENT 'Entity whose pipeline run triggered the SLA breach',
    layer                   STRING      NOT NULL  COMMENT 'Layer where the SLA breach occurred: bronze | silver | gold',
    run_date                STRING      NOT NULL  COMMENT 'Business date (YYYY-MM-DD) of the pipeline run that breached the SLA',
    run_id                  STRING      NOT NULL  COMMENT 'Foreign key to pipeline_run_log.run_id — links breach to its pipeline run',
    expected_end_time       TIMESTAMP             COMMENT 'UTC timestamp by which the pipeline was expected to complete per sla_config',
    actual_end_time         TIMESTAMP             COMMENT 'UTC timestamp when the pipeline actually completed (or NULL if still running)',
    breach_minutes          INT                   COMMENT 'Number of minutes by which the expected end time was exceeded',
    breach_reason           STRING                COMMENT 'Brief explanation of the breach cause (e.g. upstream delay, volume spike, retry exhaustion)',
    notification_sent       BOOLEAN               COMMENT 'true = breach alert was successfully dispatched; false = notification failed or suppressed',
    notification_sent_at    TIMESTAMP             COMMENT 'UTC timestamp when the breach notification was dispatched',
    acknowledged_by         STRING                COMMENT 'User who acknowledged the breach in the monitoring portal',
    acknowledged_at         TIMESTAMP             COMMENT 'UTC timestamp when the breach was acknowledged',
    created_date            TIMESTAMP   NOT NULL  COMMENT 'UTC timestamp when this breach record was written'
)
USING DELTA
LOCATION '{BASE_PATH}/sla_breach_log'
COMMENT 'SLA breach event log — records every SLA violation with breach duration, notification dispatch status, and acknowledgement tracking for operational governance.'
TBLPROPERTIES (
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true',
    'layer'                            = 'control',
    'domain'                           = 'life_insurance'
)
""")
print("Created: control_db.sla_breach_log")


# ## CELL 11 — Sample Data: ingestion_config
# 2 realistic rows: SQL Server source (policy_master) + API source (mortality_rates)
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.ingestion_config VALUES
(
    1, 'EQ_Warehouse', 'sqlserver', 'policy_master',
    'lh_bronze', 'bronze_eqwarehouse', 'policy_master_base',
    'incremental', 'ModifiedDate', 'datetime', 50000,
    NULL, NULL, NULL, NULL,
    true, 'fabric-pipeline-svc', current_timestamp(), NULL, NULL
),
(
    2, 'MortalityAPI', 'api', 'mortality_rates',
    'lh_bronze', 'bronze_api', 'mortality_rates_base',
    'full', NULL, NULL, 10000,
    NULL,
    'https://api.mortalitydata.org/v2/rates',
    'GET',
    '{{"Authorization": "Bearer __API_TOKEN__", "Content-Type": "application/json"}}',
    true, 'fabric-pipeline-svc', current_timestamp(), NULL, NULL
)
""")
print("Inserted 2 rows into ingestion_config")


# ## CELL 12 — Sample Data: watermark_control
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.watermark_control VALUES
(
    1, 1, 'policy_master',
    '2024-03-31 23:59:59', 'datetime',
    current_timestamp(), current_timestamp(),
    'success', current_timestamp(), current_timestamp()
),
(
    2, 2, 'mortality_rates',
    NULL, NULL,
    current_timestamp(), current_timestamp(),
    'success', current_timestamp(), current_timestamp()
)
""")
print("Inserted 2 rows into watermark_control")


# ## CELL 13 — Sample Data: schema_config
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.schema_config VALUES
(
    1, 1, 'policy_master',
    'PolicyID', 'policy_id',
    'int', 'INT',
    NULL, false, false, true,
    NULL, 1, true,
    current_timestamp(), NULL
),
(
    2, 1, 'policy_master',
    'TaxID', 'tax_id_hash',
    'varbinary(256)', 'BINARY',
    'cast as binary — do not decode', true, true, false,
    NULL, 2, true,
    current_timestamp(), NULL
),
(
    3, 2, 'mortality_rates',
    'age_band', 'age_band',
    'varchar(20)', 'STRING',
    'upper(trim(col))', false, false, true,
    'UNKNOWN', 1, true,
    current_timestamp(), NULL
),
(
    4, 2, 'mortality_rates',
    'mortality_rate', 'mortality_rate',
    'decimal(10,6)', 'DECIMAL(10,6)',
    'round(col, 6)', false, true, false,
    '0.0', 2, true,
    current_timestamp(), NULL
)
""")
print("Inserted 4 rows into schema_config")


# ## CELL 14 — Sample Data: pipeline_run_log
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.pipeline_run_log VALUES
(
    'a1b2c3d4-0001-4000-8000-000000000001',
    NULL,
    'pl_bronze_sqlserver_incremental',
    1, 'policy_master', 'bronze', 'incremental',
    current_timestamp() - INTERVAL 30 MINUTES,
    current_timestamp(),
    1800,
    'success',
    1250000, 1249800, 200, 0,
    NULL,
    '2024-03-30 23:59:59', '2024-03-31 23:59:59',
    'schedule',
    '__HUB_WORKSPACE_ID__', 'fabric-pipeline-item-guid-001',
    NULL,
    current_timestamp()
),
(
    'a1b2c3d4-0002-4000-8000-000000000002',
    NULL,
    'pl_bronze_api_full',
    2, 'mortality_rates', 'bronze', 'full',
    current_timestamp() - INTERVAL 15 MINUTES,
    current_timestamp(),
    900,
    'success',
    48500, 48500, 0, 0,
    'mortality_rates_20240401.json',
    NULL, NULL,
    'schedule',
    '__HUB_WORKSPACE_ID__', 'fabric-pipeline-item-guid-002',
    NULL,
    current_timestamp()
)
""")
print("Inserted 2 rows into pipeline_run_log")


# ## CELL 15 — Sample Data: data_quality_log
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.data_quality_log VALUES
(
    'dq-0001-4000-8000-000000000001',
    'a1b2c3d4-0001-4000-8000-000000000001',
    'policy_master', 'bronze',
    'policy_id_not_null',
    'PolicyID must not be null — it is the primary key for policy_master',
    'completeness',
    1250000, 1250000, 0,
    0.0000, 0.0000,
    'passed', 'log',
    current_timestamp(), current_timestamp()
),
(
    'dq-0002-4000-8000-000000000002',
    'a1b2c3d4-0001-4000-8000-000000000001',
    'policy_master', 'bronze',
    'premium_amount_non_negative',
    'PremiumAmount must be >= 0 for all active policies',
    'validity',
    1250000, 1249800, 200,
    0.0002, 0.0050,
    'warning', 'quarantine',
    current_timestamp(), current_timestamp()
)
""")
print("Inserted 2 rows into data_quality_log")


# ## CELL 16 — Sample Data: error_log
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.error_log VALUES
(
    'err-0001-4000-8000-000000000001',
    'a1b2c3d4-0001-4000-8000-000000000001',
    'pl_bronze_sqlserver_incremental',
    'policy_master', 'bronze',
    'SQL_TIMEOUT',
    'connectivity',
    'SQL Server connection timed out after 300 seconds',
    '{{"server": "eq-sql-prod-01", "timeout_seconds": 300, "retry_attempt": 1}}',
    current_timestamp() - INTERVAL 45 MINUTES,
    1, 3,
    true, true,
    'fabric-pipeline-svc', current_timestamp(),
    current_timestamp()
),
(
    'err-0002-4000-8000-000000000002',
    'a1b2c3d4-0002-4000-8000-000000000002',
    'pl_bronze_api_full',
    'mortality_rates', 'bronze',
    'HTTP_401',
    'connectivity',
    'API authentication failed — bearer token expired',
    '{{"url": "https://api.mortalitydata.org/v2/rates", "http_status": 401, "response": "Unauthorized"}}',
    current_timestamp() - INTERVAL 20 MINUTES,
    0, 3,
    true, false,
    NULL, NULL,
    current_timestamp()
)
""")
print("Inserted 2 rows into error_log")


# ## CELL 17 — Sample Data: sla_config
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.sla_config VALUES
(
    1, 1, 'policy_master', 'bronze',
    '01:00', '03:00', 120,
    'critical', true,
    'data-engineering@equitrust.com',
    'https://equitrust.webhook.office.com/webhookb2/__WEBHOOK_ID__',
    true,
    current_timestamp(), NULL
),
(
    2, 2, 'mortality_rates', 'bronze',
    '02:00', '02:30', 30,
    'high', true,
    'data-engineering@equitrust.com',
    'https://equitrust.webhook.office.com/webhookb2/__WEBHOOK_ID__',
    true,
    current_timestamp(), NULL
)
""")
print("Inserted 2 rows into sla_config")


# ## CELL 18 — Sample Data: sla_breach_log
# ══════════════════════════════════════════════════════════════════════════════

spark.sql(f"""
INSERT INTO {CONTROL_DB}.sla_breach_log VALUES
(
    'breach-0001-4000-8000-000000000001',
    1, 'policy_master', 'bronze',
    '2024-03-31',
    'a1b2c3d4-0001-4000-8000-000000000001',
    to_timestamp('2024-04-01 03:00:00'),
    to_timestamp('2024-04-01 03:47:00'),
    47,
    'Source volume 40% higher than baseline — SQL timeout on retry 1 added 30 min delay',
    true, current_timestamp() - INTERVAL 10 MINUTES,
    'data.engineer@equitrust.com',
    current_timestamp(),
    current_timestamp()
),
(
    'breach-0002-4000-8000-000000000002',
    2, 'mortality_rates', 'bronze',
    '2024-04-01',
    'a1b2c3d4-0002-4000-8000-000000000002',
    to_timestamp('2024-04-01 02:30:00'),
    to_timestamp('2024-04-01 02:53:00'),
    23,
    'API bearer token expired — manual token rotation required before retry succeeded',
    true, current_timestamp() - INTERVAL 5 MINUTES,
    NULL, NULL,
    current_timestamp()
)
""")
print("Inserted 2 rows into sla_breach_log")


# ## CELL 19 — Verification: Row Counts for All 8 Control Tables
# ══════════════════════════════════════════════════════════════════════════════

print("\n" + "═" * 55)
print("  CONTROL TABLE VERIFICATION — ROW COUNTS")
print("═" * 55)

control_tables = [
    "ingestion_config",
    "watermark_control",
    "schema_config",
    "pipeline_run_log",
    "data_quality_log",
    "error_log",
    "sla_config",
    "sla_breach_log",
]

results = []
for table in control_tables:
    count = spark.sql(f"SELECT COUNT(*) AS cnt FROM {CONTROL_DB}.{table}").collect()[0]["cnt"]
    results.append((table, count))

# Display as a single unified output
from pyspark.sql import Row
summary_df = spark.createDataFrame(
    [Row(table_name=t, row_count=c) for t, c in results]
)
summary_df.show(truncate=False)

# Also verify all tables are EXTERNAL Delta tables
print("\n" + "═" * 55)
print("  EXTERNAL TABLE VERIFICATION")
print("═" * 55)
for table in control_tables:
    detail = spark.sql(f"DESCRIBE DETAIL {CONTROL_DB}.{table}").collect()[0]
    table_type  = detail["type"]
    location    = detail["location"]
    ok = "✓" if table_type == "EXTERNAL" and location.startswith("abfss://") else "✗"
    print(f"  {ok}  {table:<30}  type={table_type:<10}  location=.../{table}/")

print("\nControl table provisioning COMPLETE.")
