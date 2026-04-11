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
    StringType, IntegerType,
)
from typing import Optional

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
        "       load_type, watermark_column, watermark_type, batch_size "
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
        f"       load_type, watermark_column, watermark_type, batch_size "
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
        f"SELECT TOP 1 source_id, source_schema, load_type, watermark_column, watermark_type, batch_size "
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
        "SELECT id, source_name, source_table_name, source_column_name, target_column_name, "
        "       target_data_type, ordinal_position, include_in_md5hash "
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
        f"SELECT id, source_name, source_table_name, source_column_name, target_column_name, "
        f"       target_data_type, ordinal_position, include_in_md5hash "
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
        f"SELECT source_column_name, target_column_name, "
        f"       ordinal_position, include_in_md5hash "
        f"FROM dbo.schema_config "
        f"WHERE LOWER(source_table_name) = LOWER('{source_table_name}') "
        f"  AND is_active = 1"
    )
    return df.collect()


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
        StructField("source_id",        IntegerType(), nullable=False),
        StructField("source_name",      StringType(),  nullable=False),
        StructField("source_table",     StringType(),  nullable=False),
        StructField("source_schema",    StringType(),  nullable=True),
        StructField("target_table",     StringType(),  nullable=False),
        StructField("target_schema",    StringType(),  nullable=False),
        StructField("load_type",        StringType(),  nullable=False),
        StructField("watermark_column", StringType(),  nullable=True),
        StructField("watermark_type",   StringType(),  nullable=True),
        StructField("batch_size",       IntegerType(), nullable=True),
    ])


def get_schema_config_schema() -> StructType:
    """
    Return the Spark StructType for schema_config JSON items.
    Matches the shape emitted by nb_get_ingestion_entities (p_config_type='schema_config').

    JSON shape per item:
    {
      "source_name", "source_table_name", "source_column_name",
      "target_column_name", "target_data_type",
      "ordinal_position", "include_in_md5hash"
    }
    """
    return StructType([
        StructField("source_name",        StringType(),  nullable=False),
        StructField("source_table_name",  StringType(),  nullable=False),
        StructField("source_column_name", StringType(),  nullable=False),
        StructField("target_column_name", StringType(),  nullable=False),
        StructField("target_data_type",   StringType(),  nullable=False),
        StructField("ordinal_position",   IntegerType(), nullable=False),
        StructField("include_in_md5hash", IntegerType(), nullable=False),
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


print("[nb_utils] Loaded — functions available: read_mssql_table, read_mssql_query, "
      "get_ingestion_config, get_ingestion_config_by_source, get_ingestion_config_for_entity, "
      "get_schema_config, get_schema_config_by_source, get_schema_config_for_table, "
      "get_ingestion_config_schema, get_schema_config_schema, "
      "ingestion_config_df_from_json, schema_config_df_from_json, build_col_maps")
