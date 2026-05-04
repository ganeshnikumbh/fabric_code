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
        "       partition_by_column_names, is_scd2, src_busn_asst "
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
        f"       partition_by_column_names, is_scd2, src_busn_asst "
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
        f"             batch_size, partition_by_column_names, is_scd2, src_busn_asst "
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
        StructField("src_busn_asst",             StringType(),  nullable=True),
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
    src_busn_asst:       str = None,
):
    """
    Append the standard pipeline audit columns to a DataFrame.

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
    src_busn_asst       : Business assistant / source grouping tag from ingestion_config
                          (e.g. 'elic').  Written to every bronze and silver row so that
                          downstream consumers can partition or filter by business unit.

    Returns
    -------
    DataFrame with audit columns appended:
      ingestion_date, data_timestamp, source_system, ingestion_run_id,
      ingestion_timestamp, src_busn_asst
    """
    from pyspark.sql.column import Column as _Column
    data_ts_col = (
        data_timestamp
        if isinstance(data_timestamp, _Column)
        else F.lit(data_timestamp).cast(TimestampType())
    )
    result = (
        df
        .withColumn("ingestion_date",      F.lit(ingestion_date).cast("date"))
        .withColumn("data_timestamp",      data_ts_col)
        .withColumn("source_system",       F.lit(source_system).cast(StringType()))
        .withColumn("ingestion_run_id",    F.lit(ingestion_run_id).cast(StringType()))
        .withColumn("ingestion_timestamp", F.lit(ingestion_timestamp).cast(TimestampType()))
        .withColumn("src_busn_asst",       F.lit(src_busn_asst).cast(StringType()))
    )
    return result


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


def deduplicate_by_md5(df, label: str = ""):
    """
    Remove duplicate rows from a DataFrame based on the md5_hash column.

    Retains one row per distinct md5_hash value (arbitrary row when duplicates
    exist — row content is identical by definition since the hash is computed
    from all business columns).  Logs the number of rows removed.

    Parameters
    ----------
    df    : Input DataFrame.  Must contain an 'md5_hash' column.
    label : Optional descriptive label printed in the log line (e.g. table name).

    Returns
    -------
    DataFrame with duplicate md5_hash rows removed.

    Example
    -------
    source_df = deduplicate_by_md5(source_df, label="client_base")
    """
    before  = df.count()
    deduped = df.dropDuplicates(["md5_hash"])
    after   = deduped.count()
    removed = before - after
    prefix  = f"[{label}] " if label else ""
    if removed > 0:
        print(f"  {prefix}Deduplication : {removed:,} duplicate(s) removed  ({before:,} → {after:,} rows)")
    else:
        print(f"  {prefix}Deduplication : no duplicates found  ({before:,} rows)")
    return deduped


def make_surrogate_key(*col_exprs):
    """
    Compute a deterministic BIGINT surrogate key from one or more Column expressions.

    Algorithm:
      1. Coerce each expression to STRING, replacing NULL with empty string.
      2. Concatenate with pipe delimiter.
      3. Take the MD5 digest (32 hex chars).
      4. Take the first 15 hex characters (60 bits — fits safely in BIGINT).
      5. Convert hex string to decimal, cast to LONG (BIGINT).

    Parameters
    ----------
    *col_exprs : One or more PySpark Column expressions (F.col(...), literals, etc.)
                 passed in the desired hashing order.  The order is significant —
                 changing it will produce a different key for the same data.

    Returns
    -------
    PySpark Column expression that evaluates to BIGINT.

    Example
    -------
    df = df.withColumn("agent_key", make_surrogate_key(
        F.col("agent_number"),
        F.col("display_name"),
        F.col("agent_type"),
    ))
    """
    return (
        F.conv(
            F.substring(
                F.md5(F.concat_ws("|", *[F.coalesce(e.cast("string"), F.lit("")) for e in col_exprs])),
                1, 15,
            ),
            16, 10,
        ).cast("long")
    )


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
      "validate_required_params, add_audit_columns, compute_md5_hash, "
      "deduplicate_by_md5, make_surrogate_key, write_delta_create, "
      "apply_scd2, apply_scd1, compute_md5Hash, add_audit_column, add_scd_column, "
      "resolve_dim_key, GoldLoader")


# ── GOLD LAYER ADDITIONS ──────────────────────────────────────────────────────
# All Gold layer utilities are appended here. Nothing above this line is modified.

import logging as _logging
import inspect as _inspect
from delta.tables import DeltaTable as _DeltaTable

_logger = _logging.getLogger("nb_utils")


# ─────────────────────────────────────────────────────────────────────────────
# apply_scd2 — reusable SCD Type 2 merge (extracted from nb_silver_s1_ingestion)
# ─────────────────────────────────────────────────────────────────────────────

def apply_scd2(
    spark: SparkSession,
    source_df: DataFrame,
    qualified_target: str,
    effective_timestamp_val: str = None,
    partition_cols: list = None,
    tbl_properties: dict = None,
) -> tuple:
    """
    Apply SCD Type 2 (md5-hash-only) merge strategy into a Delta table.

    source_df must contain an md5_hash column.  SCD2 structural columns
    (effective_timestamp, expiration_timestamp, is_current) are added to
    source_df inside this function — any values set by callers are overwritten.

    Strategy matrix:
      MD5 in source | MD5 in target (is_current=1) | Action
      YES           | YES                          | SKIP  — unchanged
      YES           | NO                           | INSERT — new / changed row
      NO            | YES                          | EXPIRE — set expiration + is_current=0
      NO            | NO                           | ignore — already expired

    Parameters
    ----------
    spark                   : Active SparkSession.
    source_df               : Incoming records DataFrame.  Must contain 'md5_hash'.
    qualified_target        : Fully qualified Delta table, e.g. 'silver_s1.client_base'.
    effective_timestamp_val : ISO timestamp string for the effective date of this load.
                              When None, CURRENT_TIMESTAMP() is used.
    partition_cols          : Column names to partition by on first-run table creation.
    tbl_properties          : Delta table properties for first-run create.
                              Defaults to {"delta.enableChangeDataFeed": "true"}.

    Returns
    -------
    tuple  (rows_inserted: int, rows_updated: int)
    """
    _OPEN_TS   = "9999-12-31 00:00:00"
    _tbl_props = tbl_properties or {"delta.enableChangeDataFeed": "true"}

    # Resolve effective_timestamp: accept explicit string or fall back to NOW
    _eff_ts = (
        F.lit(effective_timestamp_val).cast(TimestampType())
        if effective_timestamp_val
        else F.current_timestamp()
    )

    # Add SCD2 structural columns only when not already present on source_df.
    # Callers that ran add_scd_column() in their transform step will already
    # have these fields; apply_scd2 preserves those values and only fills gaps.
    _existing = set(source_df.columns)
    if "effective_timestamp"  not in _existing:
        source_df = source_df.withColumn("effective_timestamp",  _eff_ts)
    if "expiration_timestamp" not in _existing:
        source_df = source_df.withColumn("expiration_timestamp", F.lit(_OPEN_TS).cast(TimestampType()))
    if "is_current"           not in _existing:
        source_df = source_df.withColumn("is_current",           F.lit(1).cast(IntegerType()))

    table_exists  = spark.catalog.tableExists(qualified_target)
    rows_inserted = 0
    rows_updated  = 0

    if not table_exists:
        # First run — write the full source as the initial state
        _logger.info("[apply_scd2] '%s' does not exist — creating via full write", qualified_target)
        write_delta_create(source_df, qualified_target, partition_cols, _tbl_props)
        rows_inserted = source_df.count()

    else:
        target_df = spark.table(qualified_target)

        # New records: source md5 does NOT appear anywhere in the target
        new_records_df = source_df.join(
            target_df.select("md5_hash"),
            on  = "md5_hash",
            how = "left_anti",
        )

        # Expired records: currently-active target rows whose md5 is absent from source
        expired_df = (
            target_df
            .filter(F.col("is_current") == 1)
            .join(source_df.select("md5_hash"), on="md5_hash", how="left_anti")
            .select("md5_hash")
        )

        rows_inserted = new_records_df.count()
        rows_updated  = expired_df.count()
        _logger.info(
            "[apply_scd2] %s — new=%d, to_expire=%d",
            qualified_target, rows_inserted, rows_updated,
        )

        # Expire stale active records — match on md5_hash AND is_current=1 so
        # already-expired history rows are never touched
        if rows_updated > 0:
            (
                _DeltaTable.forName(spark, qualified_target).alias("tgt")
                .merge(
                    source    = expired_df.alias("src"),
                    condition = "tgt.md5_hash = src.md5_hash AND tgt.is_current = 1",
                )
                .whenMatchedUpdate(set={
                    "is_current":           F.lit(0).cast(IntegerType()),
                    "expiration_timestamp": _eff_ts,
                })
                .execute()
            )
            _logger.info("[apply_scd2] Expired %d record(s) in '%s'", rows_updated, qualified_target)

        # Append new / changed records — md5 uniqueness guaranteed by left_anti above
        if rows_inserted > 0:
            (
                new_records_df.write
                .format("delta")
                .mode("append")
                .saveAsTable(qualified_target)
            )
            _logger.info("[apply_scd2] Appended %d new record(s) to '%s'", rows_inserted, qualified_target)

    return rows_inserted, rows_updated


# ─────────────────────────────────────────────────────────────────────────────
# apply_scd1 — reusable SCD Type 1 UPSERT (extracted from nb_silver_s1_ingestion)
# ─────────────────────────────────────────────────────────────────────────────

def apply_scd1(
    spark: SparkSession,
    source_df: DataFrame,
    qualified_target: str,
    business_key_cols: list,
    partition_cols: list = None,
    tbl_properties: dict = None,
) -> tuple:
    """
    Apply SCD Type 1 UPSERT strategy into a Delta table.

    Performs a Delta MERGE matched on business_key_cols:
      WHEN MATCHED     → UPDATE all columns (overwrite with latest source values)
      WHEN NOT MATCHED → INSERT full row

    On first run (table does not exist) a full write is performed instead of a
    MERGE, which is equivalent and avoids the overhead of an empty-table merge.

    This function is intentionally key-agnostic: callers choose the match key.
    For the Silver layer the match key is ["md5_hash"] (content-hash uniqueness),
    which is equivalent to the former insert-only behaviour because a matching
    md5 means the row content is identical and the UPDATE is a no-op.
    For the Gold layer callers pass the actual business primary-key columns.

    Parameters
    ----------
    spark             : Active SparkSession.
    source_df         : Incoming records DataFrame.
    qualified_target  : Fully qualified Delta table, e.g. 'silver_s1.client_base'.
    business_key_cols : Column names used as the MERGE join condition.
    partition_cols    : Column names to partition by on first-run table creation.
    tbl_properties    : Delta table properties for first-run create.
                        Defaults to {"delta.enableChangeDataFeed": "true"}.

    Returns
    -------
    tuple  (rows_inserted: int, rows_updated: int)
    """
    _tbl_props  = tbl_properties or {"delta.enableChangeDataFeed": "true"}
    table_exists = spark.catalog.tableExists(qualified_target)
    rows_inserted = 0
    rows_updated  = 0

    if not table_exists:
        # First run — create table with full write
        _logger.info("[apply_scd1] '%s' does not exist — creating via full write", qualified_target)
        write_delta_create(source_df, qualified_target, partition_cols, _tbl_props)
        rows_inserted = source_df.count()

    else:
        target_df = spark.table(qualified_target)

        # Pre-count inserts vs updates before the MERGE for summary reporting.
        # existing_keys holds every distinct business-key combination in target.
        existing_keys_df = target_df.select(business_key_cols).distinct()

        # Rows whose business key is NOT yet in target → will be inserted
        new_rows_df = source_df.join(existing_keys_df, on=business_key_cols, how="left_anti")
        # Rows whose business key already exists in target → will be updated
        upd_rows_df = source_df.join(existing_keys_df, on=business_key_cols, how="inner")

        rows_inserted = new_rows_df.count()
        rows_updated  = upd_rows_df.count()
        _logger.info(
            "[apply_scd1] %s — to_insert=%d, to_update=%d",
            qualified_target, rows_inserted, rows_updated,
        )

        # Build merge condition: AND of all business key columns
        _merge_cond = " AND ".join(
            [f"tgt.{col} = src.{col}" for col in business_key_cols]
        )

        (
            _DeltaTable.forName(spark, qualified_target).alias("tgt")
            .merge(
                source    = source_df.alias("src"),
                condition = _merge_cond,
            )
            .whenMatchedUpdateAll()
            .whenNotMatchedInsertAll()
            .execute()
        )
        _logger.info("[apply_scd1] MERGE complete for '%s'", qualified_target)

    return rows_inserted, rows_updated


# ─────────────────────────────────────────────────────────────────────────────
# Gold-layer transform utility functions
#
# Each function accepts df as its first positional argument and returns a
# DataFrame.  This uniform signature is required by GoldLoader.transform().
# Any function added here with that signature becomes automatically available
# to all GoldLoader instances via self._function_registry — no other changes
# are needed.
# ─────────────────────────────────────────────────────────────────────────────

def compute_md5Hash(df: DataFrame, *cols: str) -> DataFrame:
    """
    Add or replace the md5_hash column computed from the supplied column names.

    Delegates to compute_md5_hash() so the hashing logic is not duplicated.
    Accepts column names as individual positional arguments (unlike
    compute_md5_hash which takes a list) so GoldLoader.transform() can pass
    JSON 'parameters' arrays directly as *args.

    Parameters
    ----------
    df   : Input DataFrame.
    *cols: Column names to include in the hash, in the supplied order.

    Returns
    -------
    DataFrame with md5_hash column added or replaced.
    """
    return compute_md5_hash(df, list(cols))


def add_audit_column(df: DataFrame) -> DataFrame:
    """
    Append a gold-layer ingestion_timestamp column using CURRENT_TIMESTAMP().

    Intended as a zero-parameter transform step in GoldLoader pipelines where
    full pipeline context (run_id, ingestion_date, source_system) is not
    available in the config JSON.

    Parameters
    ----------
    df : Input DataFrame.

    Returns
    -------
    DataFrame with ingestion_timestamp column added or replaced.
    """
    return df.withColumn("ingestion_timestamp", F.current_timestamp())


def add_scd_column(df: DataFrame) -> DataFrame:
    """
    Add SCD2 structural columns to df with sentinel initial values.

    Columns added / replaced:
      effective_timestamp  : CURRENT_TIMESTAMP()
      expiration_timestamp : '9999-12-31 00:00:00'  (open-ended sentinel)
      is_current           : 1 (INTEGER)

    Note: when load(is_scd2=True) is called, apply_scd2() overwrites these
    columns with the authoritative effective_timestamp for the load run.
    This transform step is provided so callers can inspect or persist the
    SCD2 schema at intermediate stages if needed.

    Parameters
    ----------
    df : Input DataFrame.

    Returns
    -------
    DataFrame with SCD2 structural columns added or replaced.
    """
    _OPEN_TS = "9999-12-31 00:00:00"
    return (
        df
        .withColumn("effective_timestamp",  F.current_timestamp())
        .withColumn("expiration_timestamp", F.lit(_OPEN_TS).cast(TimestampType()))
        .withColumn("is_current",           F.lit(1).cast(IntegerType()))
    )


# ─────────────────────────────────────────────────────────────────────────────
# resolve_dim_key — surrogate key lookup helper for Gold fact/bridge tables
# ─────────────────────────────────────────────────────────────────────────────

def resolve_dim_key(
    spark,
    source_df: DataFrame,
    source_col: str,
    dim_table: str,
    dim_bk_col: str,
    dim_sk_col: str,
    target_col_name: str,
    unknown_key: int = -1,
    is_current_col: str = None,
) -> DataFrame:
    """
    Resolve a dimension surrogate key by left-joining source_df to a dim table.

    Adds target_col_name to source_df containing the matched surrogate key.
    Rows that find no match in the dim (late-arriving or missing dimension
    members) receive unknown_key instead of NULL.

    Parameters
    ----------
    spark           : Active SparkSession.
    source_df       : Source DataFrame containing the FK column.
    source_col      : FK column name in source_df (e.g. "client_id").
    dim_table       : Fully qualified dim table (e.g. "lh_gold.gold.dim_client").
    dim_bk_col      : Business key column in the dim table that matches source_col
                      (e.g. "source_client_id").
    dim_sk_col      : Surrogate key column in the dim table (e.g. "client_key").
    target_col_name : Name of the SK column to add to the output DataFrame.
    unknown_key     : Value to use when no dim match is found (default -1).
                      Follows the standard unknown member convention so fact rows
                      are never orphaned with NULL foreign keys.
    is_current_col  : Name of the SCD2 currency flag column in the dim table.
                      When supplied, only rows where this column equals 1 are
                      considered (active records only).  Pass None for non-SCD2
                      dims.

    Returns
    -------
    DataFrame — source_df with target_col_name appended.

    Notes
    -----
    dim_bk_col is aliased to a private temp name before the join so that
    `.drop()` never accidentally removes a same-named column from source_df
    (which would happen with a plain `.drop(dim_bk_col)` when
    source_col == dim_bk_col).
    """
    # Private temp alias for the dim business key — isolates the join key from
    # any same-named column on source_df so the subsequent drop is always safe.
    _BK_TMP = "__dim_bk_tmp__"

    dim_df = spark.table(dim_table)

    if is_current_col:
        # SCD2 dim: restrict to the currently-active version of each member
        dim_df = dim_df.filter(F.col(is_current_col) == 1)

    # Narrow the dim to only what the join needs — keeps shuffle data small
    dim_df = dim_df.select(
        F.col(dim_bk_col).alias(_BK_TMP),
        F.col(dim_sk_col).alias(target_col_name),
    )

    result_df = (
        source_df
        # DataFrame-qualified reference on both sides avoids column ambiguity
        # when source_col and dim_bk_col share the same name
        .join(dim_df, source_df[source_col] == F.col(_BK_TMP), "left")
        # Drop only the private alias — source_df[source_col] is preserved
        .drop(_BK_TMP)
        # Coalesce NULL (no match) to unknown_key; cast to long to match the
        # BIGINT type produced by make_surrogate_key
        .withColumn(
            target_col_name,
            F.coalesce(F.col(target_col_name), F.lit(unknown_key).cast("long")),
        )
    )
    return result_df


# ─────────────────────────────────────────────────────────────────────────────
# GoldLoader — metadata-driven Extract / Transform / Load orchestrator
# ─────────────────────────────────────────────────────────────────────────────

class GoldLoader:
    """
    Metadata-driven ETL orchestrator for the Gold layer.

    All behaviour is driven by three config dicts (pre-parsed from JSON files).
    Adding a new transform step requires only adding a new function to nb_utils —
    GoldLoader picks it up automatically via self._function_registry.

    Typical usage:
        loader      = GoldLoader(spark)
        extract_df  = loader.extract(extract_config)
        transformed = loader.transform(extract_df, transform_config)
        loader.load(transformed, load_config["target_table"],
                    load_config["is_scd2"], load_config["business_key_col"],
                    load_config["surrogate_key_col"])
    """

    def __init__(self, spark: SparkSession, config_base_path: str = None) -> None:
        """
        Initialise and build the function registry.

        The registry maps every public module-level function name to its
        callable.  Because it is built from globals() at instantiation time,
        any function added to nb_utils after the initial load will NOT be
        registered until a new GoldLoader is instantiated — re-run nb_utils
        or re-instantiate GoldLoader to pick up new additions.

        Parameters
        ----------
        spark            : Active SparkSession.
        config_base_path : Optional base folder path used to resolve relative
                           file references in extract / transform configs
                           (e.g. "Files/config/gold/dim_agent").
                           When set, paths like "./extract_query.sql" in the
                           config JSON are resolved against this base.
        """
        self.spark             = spark
        self._config_base_path = (config_base_path or "").rstrip("/")

        # Include only plain Python functions (not classes, modules, or built-ins)
        # that do not start with an underscore (i.e. public API only).
        self._function_registry: dict = {
            name: obj
            for name, obj in globals().items()
            if _inspect.isfunction(obj) and not name.startswith("_")
        }
        _logger.info(
            "[GoldLoader] Registry built — %d functions: %s",
            len(self._function_registry),
            sorted(self._function_registry.keys()),
        )

    # ── private helpers ───────────────────────────────────────────────────────

    def _resolve_path(self, file_path: str) -> str:
        """
        Resolve a relative config file path against self._config_base_path.

        Paths starting with "./" or without a leading "/" are treated as
        relative.  Absolute paths are returned unchanged.
        """
        if self._config_base_path and not file_path.startswith("/"):
            name = file_path.lstrip("./")
            return f"{self._config_base_path}/{name}"
        return file_path

    def _read_text_file(self, file_path: str) -> str:
        """
        Read a plain-text file from the Fabric lakehouse using spark.read.text.

        Parameters
        ----------
        file_path : Relative or absolute path to the file.

        Returns
        -------
        str — full file contents as a single string.

        Raises
        ------
        RuntimeError : If the file cannot be read (path not found, permissions, etc.)
        """
        resolved = self._resolve_path(file_path)
        try:
            rows = self.spark.read.text(resolved).collect()
            return "\n".join(row["value"] for row in rows)
        except Exception as e:
            raise RuntimeError(
                f"[GoldLoader] Cannot read file '{resolved}'. "
                f"Ensure config_base_path is set correctly and the file exists.\n{e}"
            )

    # ── extract ──────────────────────────────────────────────────────────────

    def extract(self, config: dict) -> DataFrame:
        """
        Execute the SQL query defined in config and return the resulting DataFrame.

        Supported config shapes:

          Inline SQL:
            { "query_type": "extract", "query_string": "SELECT ..." }

          SQL from file (query_file_path takes precedence over query_string
          when both are present):
            { "query_type": "extract", "query_file_path": "./extract_query.sql" }

        When query_file_path is used, the file is read via _read_text_file()
        and resolved against self._config_base_path if the path is relative.

        Parameters
        ----------
        config : Pre-parsed extract config dict.

        Returns
        -------
        DataFrame  — result of spark.sql(<resolved query>).

        Raises
        ------
        ValueError : If query_type != 'extract' or no valid query is provided.
        RuntimeError : If query_file_path is set but the file cannot be read.
        """
        if config.get("query_type") != "extract":
            raise ValueError(
                f"[GoldLoader.extract] Expected query_type='extract', "
                f"got '{config.get('query_type')}'."
            )

        query_file   = config.get("query_file_path", "").strip()
        query_string = config.get("query_string",    "").strip()

        if query_file:
            # File path takes precedence — read SQL from the lakehouse file
            _logger.info("[GoldLoader.extract] Reading SQL from file: %s", query_file)
            query_string = self._read_text_file(query_file).strip()

        if not query_string:
            raise ValueError(
                "[GoldLoader.extract] Either 'query_string' or 'query_file_path' "
                "is required and must resolve to a non-empty SQL string."
            )

        _logger.info("[GoldLoader.extract] Running query: %.200s", query_string)
        return self.spark.sql(query_string)

    # ── transform ────────────────────────────────────────────────────────────

    def transform(self, df: DataFrame, config: dict) -> DataFrame:
        """
        Apply a sequence of transformation steps to df.

        Two config formats are supported:

        ── New array format (preferred) ────────────────────────────────────
          {
            "query_type": "transform",
            "transformations": [
              {
                "transformation_type": "python_function",
                "transformation_details": {
                  "utility_function": "compute_md5Hash",
                  "parameters": ["col1", "col2"]
                }
              },
              {
                "transformation_type": "sql_file",
                "transformation_details": {
                  "sql_file": "./my_transform.sql"
                }
              }
            ]
          }

          transformation_type values:
            "python_function" — calls a function from self._function_registry as
                                func(df, *parameters); must return a DataFrame.
            "sql_file"        — reads a SQL file, registers current df as the
                                temporary view '_transform_input', executes the
                                SQL, and replaces df with the result.

        ── Legacy flat format (backward compatible) ─────────────────────────
          {
            "query_type": "transform",
            "<step_name>": {
              "utility_function": "<function_in_registry>",
              "parameters": ["col1", "col2"]
            },
            ...
          }

        Steps in both formats are applied sequentially — the output DataFrame
        of each step is the input of the next.

        Parameters
        ----------
        df     : Input DataFrame from extract() (or a prior step).
        config : Pre-parsed transform config dict.

        Returns
        -------
        DataFrame — result after all steps have been applied.

        Raises
        ------
        ValueError : If query_type is wrong, a required field is missing, or
                     a named function / transformation_type is unrecognised.
        RuntimeError : If a sql_file step cannot read the referenced file.
        """
        if config.get("query_type") != "transform":
            raise ValueError(
                f"[GoldLoader.transform] Expected query_type='transform', "
                f"got '{config.get('query_type')}'."
            )

        # ── New array format ─────────────────────────────────────────────────
        if "transformations" in config:
            transformations = config["transformations"]
            if not isinstance(transformations, list):
                raise ValueError(
                    "[GoldLoader.transform] 'transformations' must be a list of step dicts."
                )
            return self._apply_transformations(df, transformations)

        # ── Legacy flat format ───────────────────────────────────────────────
        for step_name, step_config in config.items():
            if step_name == "query_type":
                continue

            if not isinstance(step_config, dict):
                raise ValueError(
                    f"[GoldLoader.transform] Step '{step_name}' value must be a dict, "
                    f"got {type(step_config).__name__}."
                )

            func_name  = step_config.get("utility_function")
            parameters = step_config.get("parameters", [])

            if not func_name:
                raise ValueError(
                    f"[GoldLoader.transform] Step '{step_name}' is missing 'utility_function'."
                )

            func = self._function_registry.get(func_name)
            if func is None:
                raise ValueError(
                    f"[GoldLoader.transform] Function '{func_name}' (step '{step_name}') "
                    f"not found in registry. "
                    f"Available: {sorted(self._function_registry.keys())}"
                )

            _logger.info(
                "[GoldLoader.transform] Step '%s' → %s(%s)",
                step_name, func_name,
                ", ".join(str(p) for p in parameters) if parameters else "",
            )
            df = func(df, *parameters)

        return df

    def _apply_transformations(self, df: DataFrame, transformations: list) -> DataFrame:
        """
        Dispatch each step in the new 'transformations' array format.

        Supported transformation_type values:
          "python_function" — look up utility_function in registry, call func(df, *params).
          "sql_file"        — read SQL file, register df as '_transform_input' temp view,
                              run spark.sql(), replace df with the result.

        Parameters
        ----------
        df              : Current working DataFrame.
        transformations : List of step dicts from config["transformations"].

        Returns
        -------
        DataFrame — after all steps applied.
        """
        for i, step in enumerate(transformations):
            if not isinstance(step, dict):
                raise ValueError(
                    f"[GoldLoader.transform] Step at index {i} must be a dict, "
                    f"got {type(step).__name__}."
                )

            t_type  = step.get("transformation_type")
            details = step.get("transformation_details", {})

            if not t_type:
                raise ValueError(
                    f"[GoldLoader.transform] Step at index {i} is missing 'transformation_type'."
                )

            # ── python_function ──────────────────────────────────────────────
            if t_type == "python_function":
                func_name  = details.get("utility_function")
                parameters = details.get("parameters", [])

                if not func_name:
                    raise ValueError(
                        f"[GoldLoader.transform] python_function step at index {i} "
                        f"is missing 'utility_function' in transformation_details."
                    )

                func = self._function_registry.get(func_name)
                if func is None:
                    raise ValueError(
                        f"[GoldLoader.transform] Function '{func_name}' (step {i}) "
                        f"not found in registry. "
                        f"Available: {sorted(self._function_registry.keys())}"
                    )

                _logger.info(
                    "[GoldLoader.transform] Step %d (python_function) → %s(%s)",
                    i, func_name,
                    ", ".join(str(p) for p in parameters) if parameters else "",
                )
                # First arg is always df; JSON parameters are additional positional args
                df = func(df, *parameters)

            # ── sql_file ─────────────────────────────────────────────────────
            elif t_type == "sql_file":
                sql_file = details.get("sql_file", "").strip()
                if not sql_file:
                    raise ValueError(
                        f"[GoldLoader.transform] sql_file step at index {i} "
                        f"is missing 'sql_file' in transformation_details."
                    )

                _logger.info(
                    "[GoldLoader.transform] Step %d (sql_file) → reading '%s'",
                    i, sql_file,
                )
                sql_content = self._read_text_file(sql_file).strip()
                if not sql_content:
                    raise ValueError(
                        f"[GoldLoader.transform] sql_file '{sql_file}' is empty."
                    )

                # Register the current state of df as a temp view so the SQL
                # can reference it.  The view name is fixed so SQL files are
                # portable across different entity pipelines.
                df.createOrReplaceTempView("_transform_input")
                _logger.info(
                    "[GoldLoader.transform] Registered '_transform_input' temp view, "
                    "running SQL from '%s'", sql_file,
                )
                df = self.spark.sql(sql_content)

            else:
                raise ValueError(
                    f"[GoldLoader.transform] Unknown transformation_type '{t_type}' "
                    f"at step index {i}. Supported: 'python_function', 'sql_file'."
                )

        return df

    # ── load ─────────────────────────────────────────────────────────────────

    def load(
        self,
        df: DataFrame,
        target_table: str,
        is_scd2: bool,
        business_key_cols: list,
        surrogate_key_col: str,
        hash_col: str = "md5_hash",
    ) -> None:
        """
        Persist the transformed DataFrame to a Gold Delta table.

        Pre-write steps (always applied):
          1. Adds a BIGINT surrogate key column (surrogate_key_col) derived
             deterministically from business_key_cols via make_surrogate_key().
          2. Adds/overwrites hash_col with an MD5 hash of business_key_cols
             for consistent merge-key computation.

        Write path (chosen by is_scd2):
          is_scd2=True  → apply_scd2() : SCD Type 2 history tracking.
          is_scd2=False → Delta MERGE  : WHEN MATCHED UPDATE ALL,
                                         WHEN NOT MATCHED INSERT ALL,
                                         matched on every business_key_cols column.
                          First run    : full write via write_delta_create().

        All Delta operations are idempotent — safe to re-run.

        Parameters
        ----------
        df                : Transformed DataFrame from transform().
        target_table      : Fully qualified Delta table, e.g. 'lh_gold.gold.dim_agent'.
        is_scd2           : True  → SCD Type 2 via apply_scd2().
                            False → standard UPSERT MERGE.
        business_key_cols : Columns that uniquely identify a business entity.
                            Used for surrogate key generation and MERGE condition.
        surrogate_key_col : Name of the BIGINT surrogate key column to add.
        hash_col          : Name of the MD5 hash column (default 'md5_hash').

        Returns
        -------
        None  — raises ValueError if df is empty or business keys are missing.
        """
        # Guard: surrogate_key_col must be a plain string — passing a list causes a
        # Py4JError (withColumn receives ArrayList instead of String) with no clear
        # error message from Spark.  Catch it here with a descriptive ValueError.
        if not isinstance(surrogate_key_col, str) or not surrogate_key_col.strip():
            raise ValueError(
                f"[GoldLoader.load] 'surrogate_key_col' must be a non-empty string, "
                f"got {type(surrogate_key_col).__name__}: {surrogate_key_col!r}. "
                f"Check that the load config JSON has surrogate_key_col as a string "
                f"(e.g. \"surrogate_key_col\": \"agent_key\"), not an array."
            )

        # Guard: skip empty DataFrame — log warning and return rather than raising
        if df.isEmpty():
            _logger.warning(
                "[GoldLoader.load] Source DataFrame is empty — skipping write to '%s'.",
                target_table,
            )
            return

        # Validate business key columns exist in the DataFrame
        missing_bk = [c for c in business_key_cols if c not in df.columns]
        if missing_bk:
            raise ValueError(
                f"[GoldLoader.load] Business key column(s) {missing_bk} not found in DataFrame. "
                f"Available: {df.columns}"
            )

        # Step 1: Deterministic BIGINT surrogate key from business key columns
        df = df.withColumn(
            surrogate_key_col,
            make_surrogate_key(*[F.col(c) for c in business_key_cols]),
        )
        _logger.info(
            "[GoldLoader.load] Added surrogate key '%s' from %s",
            surrogate_key_col, business_key_cols,
        )

        # Step 2: MD5 hash of business key columns for merge-key computation.
        # compute_md5_hash always writes to 'md5_hash'; rename if caller uses a
        # different column name.
        df = compute_md5_hash(df, business_key_cols)
        if hash_col != "md5_hash":
            df = df.withColumnRenamed("md5_hash", hash_col)
        _logger.info(
            "[GoldLoader.load] Computed '%s' from %s", hash_col, business_key_cols
        )

        # Step 3a: SCD Type 2 — history tracking via apply_scd2
        if is_scd2:
            _logger.info("[GoldLoader.load] is_scd2=True — calling apply_scd2 for '%s'", target_table)
            rows_inserted, rows_updated = apply_scd2(
                spark            = self.spark,
                source_df        = df,
                qualified_target = target_table,
            )
            _logger.info(
                "[GoldLoader.load] apply_scd2 done — inserted=%d, expired=%d",
                rows_inserted, rows_updated,
            )

        # Step 3b: SCD Type 1 UPSERT — delegated to apply_scd1()
        else:
            _logger.info("[GoldLoader.load] is_scd2=False — calling apply_scd1 for '%s'", target_table)
            rows_inserted, rows_updated = apply_scd1(
                spark             = self.spark,
                source_df         = df,
                qualified_target  = target_table,
                business_key_cols = business_key_cols,
            )
            _logger.info(
                "[GoldLoader.load] apply_scd1 done — inserted=%d, updated=%d",
                rows_inserted, rows_updated,
            )
