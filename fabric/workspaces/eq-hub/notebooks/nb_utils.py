# Notebook: nb_utils
# Purpose:  Shared utility functions for the EquiTrust ingestion framework.
#           Provides helpers to read control metadata from Fabric SQL DB using
#           the native com.microsoft.sqlserver.jdbc.spark connector and return
#           PySpark DataFrames. Also provides JSON → DataFrame helpers used by
#           nb_bronze_ingestion_v2 to avoid repeated DB calls per entity.
#
# Usage:
#   %run nb_utils
#
#   # Then call the functions directly:
#   jdbc_url     = "jdbc:sqlserver://<workspace>.database.fabric.microsoft.com:1433;database=<db>;"
#   ingestion_df = get_ingestion_config(jdbc_url)
#   schema_df    = get_schema_config(jdbc_url)
#
# Notes:
#   - Uses the com.microsoft.sqlserver.jdbc.spark connector (.mssql()) which is
#     pre-installed in Fabric Spark runtimes — no extra driver config needed.
#   - Authentication is handled via the JDBC URL (AAD token or SQL auth).
#   - All DB functions return DataFrames — callers .collect() only what they need.

import json

from pyspark.sql import SparkSession, DataFrame
from pyspark.sql import functions as F
from pyspark.sql.types import (
    StructType, StructField,
    StringType, IntegerType, TimestampType,
)
from typing import Optional
import com.microsoft.sqlserver.jdbc.spark


spark = SparkSession.builder.appName("nb_utils").getOrCreate()


# ─────────────────────────────────────────────────────────────────────────────
# Core SQL DB readers  (com.microsoft.sqlserver.jdbc.spark connector)
# ─────────────────────────────────────────────────────────────────────────────

def read_mssql_table(jdbc_url: str, table_name: str, schema: str = "dbo") -> DataFrame:
    """
    Read a full table from Fabric SQL DB using the native mssql connector.

    Parameters
    ----------
    jdbc_url   : JDBC connection string.
                 Example:
                   jdbc:sqlserver://<workspace>.database.fabric.microsoft.com:1433;
                   database=<db_name>;
    table_name : Unqualified table name (e.g. 'ingestion_config').
    schema     : SQL schema (default: 'dbo').

    Returns
    -------
    DataFrame  : Lazy Spark DataFrame.
    """
    qualified = f"{schema}.{table_name}"
    try:
        df = (
            spark.read
            .option("url", jdbc_url)
            .mssql(qualified)
        )
        print(f"[nb_utils] read_mssql_table: loaded '{qualified}'")
        return df
    except Exception as e:
        raise RuntimeError(
            f"[nb_utils] Failed to read '{qualified}' from Fabric SQL DB.\n"
            f"Check jdbc_url, network access, and table name.\n{e}"
        )


def read_mssql_query(jdbc_url: str, query: str) -> DataFrame:
    """
    Execute a custom SQL query against Fabric SQL DB and return a DataFrame.
    Wraps the query as a subquery so the mssql connector can handle it.

    Parameters
    ----------
    jdbc_url : JDBC connection string.
    query    : SQL SELECT statement.
               Example: "SELECT * FROM dbo.ingestion_config WHERE active_flag = 1"

    Returns
    -------
    DataFrame
    """
    try:
        df = (
            spark.read
            .option("url", jdbc_url)
            .mssql(f"({query}) AS _q")
        )
        print(f"[nb_utils] read_mssql_query: executed query")
        return df
    except Exception as e:
        raise RuntimeError(
            f"[nb_utils] Failed to execute query.\n"
            f"Query: {query}\n{e}"
        )


# ─────────────────────────────────────────────────────────────────────────────
# ingestion_config helpers
# ─────────────────────────────────────────────────────────────────────────────

def get_ingestion_config(jdbc_url: str) -> DataFrame:
    """
    Return all active rows from dbo.ingestion_config as a DataFrame.
    """
    return read_mssql_query(
        jdbc_url,
        "SELECT source_id, source_name, source_type, source_schema, entity_name, "
        "       target_lakehouse, target_schema, target_table, "
        "       load_type, watermark_column, watermark_type, batch_size, "
        "       partition_by_column_names, is_scd2 "
        "FROM dbo.ingestion_config "
        "WHERE active_flag = 1"
    )


def get_ingestion_config_by_source(jdbc_url: str, source_name: str) -> DataFrame:
    """
    Return active rows from dbo.ingestion_config filtered by source_name.

    Parameters
    ----------
    source_name : Value to match against source_name (case-insensitive).
                  E.g. 'EQ_Warehouse'
    """
    return read_mssql_query(
        jdbc_url,
        f"SELECT source_id, source_name, source_type, source_schema, entity_name, "
        f"       target_lakehouse, target_schema, target_table, "
        f"       load_type, watermark_column, watermark_type, batch_size, "
        f"       partition_by_column_names, is_scd2 "
        f"FROM dbo.ingestion_config "
        f"WHERE LOWER(source_name) = LOWER('{source_name}') "
        f"  AND active_flag = 1"
    )


def get_ingestion_config_for_entity(
    jdbc_url: str,
    source_table: str,
    target_table: str
) -> Optional[object]:
    """
    Return a single Row from dbo.ingestion_config matching source_table + target_table.
    Returns None if no matching row is found.
    """
    df = read_mssql_query(
        jdbc_url,
        f"SELECT TOP 1 source_id, source_schema, load_type, watermark_column, watermark_type, "
        f"             batch_size, partition_by_column_names, is_scd2 "
        f"FROM dbo.ingestion_config "
        f"WHERE LOWER(entity_name)  = LOWER('{source_table}') "
        f"  AND LOWER(target_table) = LOWER('{target_table}') "
        f"  AND active_flag = 1"
    )
    rows = df.collect()
    if not rows:
        return None
    return rows[0]


# ─────────────────────────────────────────────────────────────────────────────
# schema_config helpers
# ─────────────────────────────────────────────────────────────────────────────

def get_schema_config(jdbc_url: str) -> DataFrame:
    """
    Return all active rows from dbo.schema_config as a DataFrame.
    """
    return read_mssql_query(
        jdbc_url,
        "SELECT id, source_name, source_table_name, target_table_name, source_column_name, "
        "       target_column_name, target_data_type, ordinal_position, "
        "       include_in_md5hash, is_primary_key "
        "FROM dbo.schema_config "
        "WHERE is_active = 1"
    )


def get_schema_config_by_source(jdbc_url: str, source_name: str) -> DataFrame:
    """
    Return active rows from dbo.schema_config filtered by source_name.

    Parameters
    ----------
    source_name : Value to match against source_name (case-insensitive).
                  E.g. 'EQ_Warehouse'
    """
    return read_mssql_query(
        jdbc_url,
        f"SELECT id, source_name, source_table_name, target_table_name, source_column_name, "
        f"       target_column_name, target_data_type, ordinal_position, "
        f"       include_in_md5hash, is_primary_key "
        f"FROM dbo.schema_config "
        f"WHERE LOWER(source_name) = LOWER('{source_name}') "
        f"  AND is_active = 1"
    )


def get_schema_config_for_table(jdbc_url: str, source_table_name: str) -> list:
    """
    Return an ordered list of Row objects from dbo.schema_config for one source table.
    Rows are ordered by ordinal_position.

    Returns
    -------
    list[Row]  : Empty list if no mappings found.
    """
    df = read_mssql_query(
        jdbc_url,
        f"SELECT source_table_name, target_table_name, source_column_name, "
        f"       target_column_name, ordinal_position, include_in_md5hash, is_primary_key "
        f"FROM dbo.schema_config "
        f"WHERE LOWER(source_table_name) = LOWER('{source_table_name}') "
        f"  AND is_active = 1"
    )
    return df.collect()


# ─────────────────────────────────────────────────────────────────────────────
# source_load_control helpers
# ─────────────────────────────────────────────────────────────────────────────

def upsert_load_control(
    jdbc_url:           str,
    source_name:        str,
    entity_name:        str,
    bronze_run_status:  str,
    silver_run_status:  str  = "pending",
    last_load_date:     str  = None,
) -> None:
    """
    Insert or update a row in dbo.source_load_control for the given entity.

    Uses MERGE so repeated calls for the same (source_name, entity_name) pair
    update the existing row instead of inserting duplicates.

    Parameters
    ----------
    jdbc_url           : Fabric SQL DB JDBC connection string.
    source_name        : e.g. 'EQ_Warehouse'
    entity_name        : Source table name, e.g. 'Client' — matches ingestion_config.entity_name
    bronze_run_status  : 'success' | 'failed' | 'running' | 'skipped' | 'pending'
    silver_run_status  : 'success' | 'failed' | 'running' | 'skipped' | 'pending'  (default: 'pending')
    last_load_date     : ISO timestamp string for a successful load, e.g. '2025-04-09T01:00:00'.
                         Pass None to leave existing value unchanged on UPDATE,
                         or to write NULL on INSERT.

    Example
    -------
    upsert_load_control(
        jdbc_url          = jdbc_url,
        source_name       = "EQ_Warehouse",
        entity_name       = "Client",
        bronze_run_status = "success",
        last_load_date    = "2025-04-09T01:00:00",
    )
    """
    if last_load_date:
        last_load_sql = f"CONVERT(DATETIME2, '{last_load_date}', 126)"
    else:
        last_load_sql = "NULL"

    merge_sql = f"""
MERGE dbo.source_load_control AS tgt
USING (
    SELECT
        '{source_name}'       AS source_name,
        '{entity_name}'       AS entity_name,
        {last_load_sql}        AS last_load_date,
        '{bronze_run_status}' AS bronze_run_status,
        '{silver_run_status}' AS silver_run_status
) AS src
ON  tgt.source_name = src.source_name
AND tgt.entity_name = src.entity_name
WHEN MATCHED THEN
    UPDATE SET
        tgt.bronze_run_status = src.bronze_run_status,
        tgt.silver_run_status = src.silver_run_status,
        tgt.last_load_date    = CASE
                                    WHEN src.last_load_date IS NOT NULL
                                    THEN src.last_load_date
                                    ELSE tgt.last_load_date
                                END,
        tgt.modified_date     = SYSUTCDATETIME()
WHEN NOT MATCHED THEN
    INSERT (source_name, entity_name, last_load_date, bronze_run_status, silver_run_status)
    VALUES (src.source_name, src.entity_name, src.last_load_date, src.bronze_run_status, src.silver_run_status);
    """

    # Execute DML via raw JDBC connection (mssql connector is read-only)
    try:
        from py4j.java_gateway import java_import
        java_import(spark._jvm, "java.sql.DriverManager")
        conn  = spark._jvm.java.sql.DriverManager.getConnection(jdbc_url)
        stmt  = conn.createStatement()
        stmt.execute(merge_sql.strip())
        stmt.close()
        conn.close()
    except Exception as e:
        raise RuntimeError(
            f"[nb_utils] upsert_load_control failed for {source_name}.{entity_name}.\n{e}"
        )

    print(f"[nb_utils] upsert_load_control: {source_name}.{entity_name} → bronze={bronze_run_status}, silver={silver_run_status}")


def get_load_control_by_source(jdbc_url: str, source_name: str) -> DataFrame:
    """
    Return all rows from dbo.source_load_control for the given source_name.

    Returns one row per entity_name — the row with the latest last_load_date.
    Rows where last_load_date IS NULL (never loaded) are included but ranked
    after rows that have a date.
    Excludes created_date and modified_date.

    Parameters
    ----------
    source_name : e.g. 'EQ_Warehouse'
    """
    return read_mssql_query(
        jdbc_url,
        f"SELECT id, source_name, entity_name, last_load_date, "
        f"       bronze_run_status, silver_run_status "
        f"FROM ( "
        f"    SELECT id, source_name, entity_name, last_load_date, "
        f"           bronze_run_status, silver_run_status, "
        f"           ROW_NUMBER() OVER ( "
        f"               PARTITION BY entity_name "
        f"               ORDER BY "
        f"                   CASE WHEN last_load_date IS NULL THEN 1 ELSE 0 END, "
        f"                   last_load_date DESC "
        f"           ) AS _rn "
        f"    FROM dbo.source_load_control "
        f"    WHERE LOWER(source_name) = LOWER('{source_name}') "
        f") _ranked "
        f"WHERE _rn = 1"
    )


# ─────────────────────────────────────────────────────────────────────────────
# JSON schema definitions
# Used to create DataFrames from pipeline-passed JSON strings (no DB round-trip).
# ─────────────────────────────────────────────────────────────────────────────

def get_ingestion_config_schema() -> StructType:
    """
    Return the Spark StructType for ingestion_config JSON items.
    Matches the shape emitted by nb_get_ingestion_entities (p_config_type='ingestion_config').

    JSON shape per item:
    {
      "source_id", "source_name", "source_table", "source_schema",
      "target_table", "target_schema", "load_type",
      "watermark_column", "watermark_type", "batch_size"
    }
    """
    return StructType([
        StructField("source_id",                 IntegerType(), nullable=True),
        StructField("source_name",               StringType(),  nullable=True),
        StructField("source_table",              StringType(),  nullable=True),
        StructField("source_schema",             StringType(),  nullable=True),
        StructField("target_table",              StringType(),  nullable=True),
        StructField("target_schema",             StringType(),  nullable=True),
        StructField("load_type",                 StringType(),  nullable=True),
        StructField("watermark_column",          StringType(),  nullable=True),
        StructField("watermark_type",            StringType(),  nullable=True),
        StructField("batch_size",                IntegerType(), nullable=True),
        StructField("partition_by_column_names", StringType(),  nullable=True),
        StructField("is_scd2",                   IntegerType(), nullable=True),
    ])


def get_schema_config_schema() -> StructType:
    """
    Return the Spark StructType for schema_config JSON items.
    Matches the shape emitted by nb_get_ingestion_entities (p_config_type='schema_config').

    JSON shape per item:
    {
      "source_name", "source_table_name", "target_table_name",
      "source_column_name", "target_column_name", "target_data_type",
      "ordinal_position", "include_in_md5hash", "is_primary_key"
    }
    """
    return StructType([
        StructField("source_name",        StringType(),  nullable=True),
        StructField("source_table_name",  StringType(),  nullable=True),
        StructField("target_table_name",  StringType(),  nullable=True),
        StructField("source_column_name", StringType(),  nullable=True),
        StructField("target_column_name", StringType(),  nullable=True),
        StructField("target_data_type",   StringType(),  nullable=True),
        StructField("ordinal_position",   IntegerType(), nullable=True),
        StructField("include_in_md5hash", IntegerType(), nullable=True),
        StructField("is_primary_key",     IntegerType(), nullable=True),
    ])


def ingestion_config_df_from_json(json_str: str) -> DataFrame:
    """
    Create a typed DataFrame from an ingestion_config JSON string.
    Accepts either a JSON array '[{...},{...}]' or a single JSON object '{...}'.

    Parameters
    ----------
    json_str : JSON string produced by nb_get_ingestion_entities.

    Returns
    -------
    DataFrame with schema from get_ingestion_config_schema().
    """
    data = json.loads(json_str)
    if isinstance(data, dict):
        data = [data]
    return spark.createDataFrame(data, schema=get_ingestion_config_schema())


def schema_config_df_from_json(json_str: str) -> DataFrame:
    """
    Create a typed DataFrame from a schema_config JSON array string.
    Filter by source_table_name after creating the DataFrame to get
    mappings for a specific entity.

    Parameters
    ----------
    json_str : JSON array string produced by nb_get_ingestion_entities.

    Returns
    -------
    DataFrame with schema from get_schema_config_schema().
    """
    data = json.loads(json_str)
    return spark.createDataFrame(data, schema=get_schema_config_schema())


def get_load_control_schema() -> StructType:
    """
    Return the Spark StructType for source_load_control JSON items.
    Matches the shape emitted by nb_get_ingestion_entities (p_config_type='load_control').

    JSON shape per item:
    {
      "id", "source_name", "entity_name",
      "last_load_date",     ← ISO string e.g. "2025-04-09 01:00:00" or null
      "bronze_run_status", "silver_run_status"
    }
    """
    return StructType([
        StructField("id",                IntegerType(), nullable=True),
        StructField("source_name",       StringType(),  nullable=True),
        StructField("entity_name",       StringType(),  nullable=True),
        StructField("last_load_date",    StringType(),  nullable=True),
        StructField("bronze_run_status", StringType(),  nullable=True),
        StructField("silver_run_status", StringType(),  nullable=True),
    ])


def load_control_df_from_json(json_str: str) -> DataFrame:
    """
    Create a typed DataFrame from a source_load_control JSON array string.

    Parameters
    ----------
    json_str : JSON array string produced by nb_get_ingestion_entities
               with p_config_type='load_control'.

    Returns
    -------
    DataFrame with schema from get_load_control_schema().
    """
    data = json.loads(json_str)
    if isinstance(data, dict):
        data = [data]
    return spark.createDataFrame(data, schema=get_load_control_schema())


# ─────────────────────────────────────────────────────────────────────────────
# Derived mapping structures (built from schema_config rows)
# ─────────────────────────────────────────────────────────────────────────────

def build_col_maps(mappings: list) -> tuple:
    """
    Build column mapping structures from a list of schema_config Rows.

    Parameters
    ----------
    mappings : list[Row] — from get_schema_config_for_table() or .collect()

    Returns
    -------
    tuple of:
      col_map           : dict  source_col → target_col  (ordinal order)
      col_map_lower     : dict  lower(source_col) → target_col
      hash_cols_ordered : list  target cols where include_in_md5hash = 1, in ordinal order
    """
    col_map           = {row["source_column_name"]: row["target_column_name"] for row in mappings}
    col_map_lower     = {k.lower(): v for k, v in col_map.items()}
    hash_cols_ordered = [
        row["target_column_name"]
        for row in mappings
        if row["include_in_md5hash"] == 1 or row["include_in_md5hash"] is True
    ]
    return col_map, col_map_lower, hash_cols_ordered


# ─────────────────────────────────────────────────────────────────────────────
# DataFrame transformation utilities
# Shared helpers used by nb_bronze_ingestion_v2 and nb_silver_s1_ingestion.
# ─────────────────────────────────────────────────────────────────────────────

def validate_required_params(params: dict) -> None:
    """
    Raise ValueError listing all keys whose value is empty or whitespace-only.

    Parameters
    ----------
    params : dict  {param_name: value} — typically the notebook's _required dict.

    Example
    -------
    validate_required_params({
        "p_source_table" : p_source_table,
        "p_target_table" : p_target_table,
    })
    """
    missing = [k for k, v in params.items() if not str(v).strip()]
    if missing:
        raise ValueError(f"Required parameters not provided: {missing}")


def add_audit_columns(
    df,
    ingestion_date:      str,
    data_timestamp,
    source_system:       str,
    ingestion_run_id:    str,
    ingestion_timestamp: str,
):
    """
    Append the five standard pipeline audit columns to a DataFrame.

    Parameters
    ----------
    df                  : Input DataFrame.
    ingestion_date      : Pipeline run date string, e.g. '2025-04-09'  → cast to date.
    data_timestamp      : Business data timestamp.  Pass either:
                            - a PySpark Column expression (e.g. derived from watermark), or
                            - a plain string (e.g. p_ingestion_timestamp) → cast to timestamp.
    source_system       : Source system name, e.g. 'EQ_Warehouse'.
    ingestion_run_id    : Pipeline run UUID string.
    ingestion_timestamp : Pipeline run timestamp string → cast to timestamp.

    Returns
    -------
    DataFrame with audit columns appended:
      ingestion_date, data_timestamp, source_system, ingestion_run_id, ingestion_timestamp
    """
    from pyspark.sql.column import Column as _Column
    data_ts_col = (
        data_timestamp
        if isinstance(data_timestamp, _Column)
        else F.lit(data_timestamp).cast(TimestampType())
    )
    return (
        df
        .withColumn("ingestion_date",      F.lit(ingestion_date).cast("date"))
        .withColumn("data_timestamp",      data_ts_col)
        .withColumn("source_system",       F.lit(source_system).cast(StringType()))
        .withColumn("ingestion_run_id",    F.lit(ingestion_run_id).cast(StringType()))
        .withColumn("ingestion_timestamp", F.lit(ingestion_timestamp).cast(TimestampType()))
    )


def compute_md5_hash(df, hash_cols_ordered: list):
    """
    Add an md5_hash column to a DataFrame by concatenating specified columns.

    Columns are concatenated in the supplied order, pipe-delimited, with NULLs
    coerced to empty string before hashing.  The hash runs fully distributed
    via Spark's built-in md5() function.

    If hash_cols_ordered is empty, or none of the columns exist in the DataFrame,
    md5_hash is set to NULL.

    Parameters
    ----------
    df                : Input DataFrame.
    hash_cols_ordered : Ordered list of target column names to include in the hash.
                        Typically build_col_maps()[2].

    Returns
    -------
    DataFrame with md5_hash column appended.
    """
    available_cols    = set(df.columns)
    active_hash_cols  = [c for c in hash_cols_ordered if c in available_cols]
    skipped_hash_cols = [c for c in hash_cols_ordered if c not in available_cols]

    if skipped_hash_cols:
        print(f"  WARNING: {skipped_hash_cols} flagged for hash but not in DataFrame — excluded")

    if active_hash_cols:
        concat_expr = F.concat_ws(
            "|",
            *[F.coalesce(F.col(c).cast(StringType()), F.lit("")) for c in active_hash_cols],
        )
        result_df = df.withColumn("md5_hash", F.md5(concat_expr))
        print(f"  md5_hash : computed from {len(active_hash_cols)} columns in ordinal order")
    else:
        result_df = df.withColumn("md5_hash", F.lit(None).cast(StringType()))
        print(f"  md5_hash : NULL (no columns flagged include_in_md5hash=true in schema_config)")

    return result_df


def write_delta_create(
    df,
    qualified_target: str,
    partition_cols:   list = None,
    tbl_properties:   dict = None,
) -> None:
    """
    Write a DataFrame to a new Delta table, optionally partitioned and with
    Delta table properties (e.g. Change Data Feed).

    Uses overwrite + mergeSchema — safe on first run and idempotent if the
    target already exists and needs a full refresh.

    Parameters
    ----------
    df               : DataFrame to persist.
    qualified_target : Fully qualified table name, e.g. 'bronze_eqwarehouse.client_base'.
    partition_cols   : Optional list of column names to partition by.
    tbl_properties   : Optional dict of Delta table properties to set at creation time.
                       Keys and values are passed as .option() entries on the writer.
                       Example: {"delta.enableChangeDataFeed": "true"}

    Example
    -------
    write_delta_create(
        df               = final_df,
        qualified_target = "silver_s1.client_base",
        partition_cols   = ["ingestion_date"],
        tbl_properties   = {"delta.enableChangeDataFeed": "true"},
    )
    """
    _writer = (
        df.write
        .format("delta")
        .option("mergeSchema", "true")
        .mode("overwrite")
    )
    if partition_cols:
        _writer = _writer.partitionBy(*partition_cols)
        print(f"  Partitioning by  : {partition_cols}")
    if tbl_properties:
        for _k, _v in tbl_properties.items():
            _writer = _writer.option(_k, _v)
        print(f"  Table properties : {tbl_properties}")
    _writer.saveAsTable(qualified_target)
    print(f"  Created : {qualified_target}")


# ─────────────────────────────────────────────────────────────────────────────
# FabricLogger wrapper
# ─────────────────────────────────────────────────────────────────────────────

def log_fabric_operation(
    notebook_name:   str,
    table_name:      str,
    operation_type:  str,
    rows_before:     int   = 0,
    rows_after:      int   = 0,
    execution_time:  float = 0.0,
    message:         str   = None,
    error_message:   str   = None,
) -> None:
    """
    Write a log entry to LH_EquiTrust_Monitoring via nb_log_operation.

    Delegates to nb_log_operation via mssparkutils.notebook.run() so that
    FabricLogger always runs in its own isolated Spark session with NO default
    lakehouse attached. This prevents FabricLogger from creating its monitoring
    tables (dim_date, dim_time, monitoring_log) in the calling notebook's
    default lakehouse (e.g. lh_bronze).

    Never raises — logging failures are printed as warnings so ingestion
    is never blocked by a logging error.

    Parameters
    ----------
    notebook_name   : Name of the calling notebook.
    table_name      : Target table being operated on (e.g. 'bronze_eqwarehouse.client_base').
    operation_type  : 'LOAD' | 'EXTRACT' | 'TRANSFORM' | 'VALIDATE' | 'MERGE' etc.
    rows_before     : Row count before the operation.
    rows_after      : Row count after the operation.
    execution_time  : Elapsed seconds for the operation.
    message         : Optional success / info message.
    error_message   : Optional error description (None on success).
    """
    # Logging temporarily disabled — re-enable when nb_log_operation is wired up.
    pass


print("[nb_utils] Loaded — functions available: read_mssql_table, read_mssql_query, "
      "get_ingestion_config, get_ingestion_config_by_source, get_ingestion_config_for_entity, "
      "get_schema_config, get_schema_config_by_source, get_schema_config_for_table, "
      "get_load_control_by_source, "
      "upsert_load_control, log_fabric_operation, "
      "get_ingestion_config_schema, get_schema_config_schema, get_load_control_schema, "
      "ingestion_config_df_from_json, schema_config_df_from_json, load_control_df_from_json, "
      "build_col_maps, "
      "validate_required_params, add_audit_columns, compute_md5_hash, write_delta_create")
