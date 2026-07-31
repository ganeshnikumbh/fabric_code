#!/usr/bin/env python
# coding: utf-8

# ## nb_bronze_ingestion_v3
#
# Same behaviour as nb_bronze_ingestion_v2, reorganised for readability: instead
# of one long try/except block, each operation is its own plain function, and a
# short "driver" section at the bottom calls them in order. No frameworks — just
# functions, a small config dictionary (meta), and a single try/except.

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_landing_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_landing_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# Notebook: nb_bronze_ingestion_v3
# Layer:    Bronze
# Purpose:  Metadata-driven ingestion from lh_landing -> lh_bronze.
#
# The work is split into one function per step. The driver at the bottom runs
# them in this order:
#   1. read_landing_source()  — read lh_landing.<schema>.<table>
#   2. read_metadata()        — ingestion_config row + column mappings + EXTRACT log
#   3. build_records()        — API parse (schema file) or flat select/rename
#   4. add_audit_and_hash()   — audit columns + md5_hash
#   5. write_bronze()         — CREATE (first run) or replaceWhere by ingestion_date
#
# Pre-requisites:
#   - Attach lh_bronze as the default lakehouse before running.
#   - lh_landing must be added to the notebook session.
#   - fabric_logging_utils.py uploaded to nb_utils' Resources/builtin/ folder.

import time
import json

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StringType, TimestampType

spark = SparkSession.builder.appName("nb_bronze_ingestion_v3").getOrCreate()
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

_notebook_start = time.time()


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_landing_table_name    = ""    # REQUIRED — landing_table_name in ingestion_config
p_landing_schema        = ""    # REQUIRED — schema in lh_landing (e.g. 'hubspot', 'webex', 'dbo')
p_bronze_table          = ""    # REQUIRED — target Delta table in lh_bronze
p_ingestion_config_json = ""    # REQUIRED — full ingestion_config JSON array for the source
p_schema_config_json    = ""    # REQUIRED — full schema_config JSON array for the source
p_ingestion_date        = ""    # e.g. '2025-04-09'
p_source_system         = ""    # e.g. 'HubSpot', 'Webex', 'EQ_Warehouse'
p_ingestion_run_id      = ""    # UUID from pipeline
p_ingestion_timestamp   = ""    # e.g. '2025-04-09T01:00:00Z'
p_context_json          = "{}"  # optional — JSON with pipeline context for N/A schema_config rows


# In[ ]:


# Variable Library read works here (normal cell, post-session)
vl = notebookutils.variableLibrary.getLibrary("vl_lakehouse_config")
bronze_lh = vl.lh_bronze_name          # e.g. "lh_bronze"

current_default = spark.conf.get("trident.lakehouse.name")
print(f"Default (landing): {current_default}")
print(f"Bronze target:     {bronze_lh}")


# In[ ]:


_required = {
    "p_landing_table_name"    : p_landing_table_name,
    "p_landing_schema"        : p_landing_schema,
    "p_bronze_table"          : p_bronze_table,
    "p_ingestion_config_json" : p_ingestion_config_json,
    "p_schema_config_json"    : p_schema_config_json,
    "p_ingestion_date"        : p_ingestion_date,
    "p_source_system"         : p_source_system,
    "p_ingestion_run_id"      : p_ingestion_run_id,
    "p_ingestion_timestamp"   : p_ingestion_timestamp,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Step functions
# One function per operation. Each takes what it needs and returns its result;
# the driver (Section 3) calls them in order. `meta` is a plain dictionary that
# carries the config resolved in step 2 to the later steps.
# ══════════════════════════════════════════════════════════════════════════════

def read_landing_source():
    """Step 1 — read the landing table. Returns (source_df, row_count, landing_ref)."""
    landing_ref = (
        f"lh_landing.{p_landing_schema}.{p_landing_table_name}"
        if p_landing_schema.strip()
        else f"lh_landing.{p_landing_table_name}"
    )
    print(f"\n[1/5] Reading source: {landing_ref}")
    try:
        source_df = spark.table(landing_ref)
    except Exception as e:
        raise RuntimeError(
            f"Failed to read '{landing_ref}'. "
            f"Ensure lh_landing is added to this notebook session.\n{e}"
        )
    row_count = source_df.count()
    print(f"  Rows read : {row_count:,}")
    if row_count == 0:
        print("  WARNING: Source table is empty. Writing zero rows to Bronze.")
    return source_df, row_count, landing_ref


def read_metadata(source_row_count, landing_ref):
    """Step 2 — read the ingestion_config row and the column mappings, and write
    the EXTRACT audit-log row. Returns `meta`, a dict of everything later steps need."""
    print(f"\n[2/5] Reading metadata from JSON parameters")

    # ── ingestion_config row ─────────────────────────────────────────────────
    ingestion_config_df = ingestion_config_df_from_json(p_ingestion_config_json)  # noqa: F821  # type: ignore[name-defined]
    config_row = (
        ingestion_config_df
        .filter(
            (F.lower(F.col("landing_table_name")) == p_landing_table_name.lower()) &
            (F.lower(F.col("bronze_table")) == p_bronze_table.lower())
        )
        .limit(1)
        .collect()
    )
    if not config_row:
        raise ValueError(
            f"No ingestion_config row for landing_table_name='{p_landing_table_name}' / "
            f"bronze_table='{p_bronze_table}'. Ensure the entity is registered and active."
        )
    config = config_row[0]

    meta = {
        "source_id":          config["source_id"],
        "source_type":        (config["source_type"]  or "").strip().lower(),
        "bronze_schema":      (config["bronze_schema"] or "").strip(),
        "source_path":        (config["source_path"]   or "").strip(),
        "src_busn_asst":      (config["src_busn_asst"] or "").strip() or None,
        "partition_cols":     ["ingestion_date"],
        # filled below depending on source_type
        "mappings":           None,
        "schema_fields":      None,
        "context_fields":     None,
        "array_explode_path": "",
    }
    meta["qualified_target"] = (
        f"lh_bronze.{meta['bronze_schema']}.{p_bronze_table}"
        if meta["bronze_schema"] else p_bronze_table
    )

    print(f"  source_id     : {meta['source_id']}")
    print(f"  source_type   : {meta['source_type'] or '(not set)'}")
    print(f"  source_path   : {meta['source_path'] or '(root)'}")
    print(f"  bronze_schema : {meta['bronze_schema']}")
    print(f"  partition_cols: {meta['partition_cols']}")
    print(f"  src_busn_asst : {meta['src_busn_asst'] or '(none)'}")

    # ── column mappings: API → schema file; flat → schema_config ─────────────
    if meta["source_type"] == "api":
        schema_file = f"/lakehouse/default/Files/{p_landing_schema}/schemas/{p_landing_table_name}.json"
        print(f"  Schema file   : {schema_file}")
        try:
            with open(schema_file) as sf:
                table_schema = json.load(sf)
        except FileNotFoundError:
            raise ValueError(
                f"Schema file not found: '{schema_file}'. "
                f"Create a schema JSON at {p_landing_schema}/schemas/{p_landing_table_name}.json."
            )
        meta["schema_fields"]      = table_schema.get("fields", [])
        meta["context_fields"]     = table_schema.get("context_fields", [])
        meta["array_explode_path"] = (table_schema.get("array_explode_path") or "").strip()
        if table_schema.get("source_path") is not None:
            meta["source_path"] = table_schema["source_path"].strip()
        print(f"  Schema fields : {len(meta['schema_fields'])}")
        print(f"  array_explode : {meta['array_explode_path'] or '(none)'}")
        print(f"  source_path   : {meta['source_path'] or '(root)'}")
    else:
        schema_config_df = schema_config_df_from_json(p_schema_config_json)  # noqa: F821  # type: ignore[name-defined]
        mappings = (
            schema_config_df
            .filter(
                (F.lower(F.col("landing_table_name")) == p_landing_table_name.lower()) &
                (F.col("landing_column_name") != "N/A")
            )
            .orderBy("ordinal_position")
            .collect()
        )
        if not mappings:
            raise ValueError(
                f"No schema_config mappings for landing_table_name='{p_landing_table_name}'. "
                f"Ensure column mappings are registered in schema_config."
            )
        meta["mappings"] = mappings
        print(f"  Column mappings : {len(mappings)}")

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_bronze_ingestion_v3",
        table_name     = meta["qualified_target"],
        operation_type = "EXTRACT",
        rows_before    = 0,
        rows_after     = source_row_count,
        execution_time = round(time.time() - _notebook_start, 6),
        message        = f"Source rows read from {landing_ref} | landing_table={p_landing_table_name} | run_id={p_ingestion_run_id}",
    )
    return meta


def _cast_field(val, field_type):
    """Helper for API parsing — coerce a raw JSON value to the field's type."""
    if val is None:
        return None
    if isinstance(val, (dict, list)):
        return json.dumps(val)
    t = (field_type or "string").lower()
    if t == "boolean":
        return bool(val)
    elif t == "integer":
        try:    return int(val)
        except: return None
    elif t in ("float", "double"):
        try:    return float(val)
        except: return None
    return str(val)


def _build_spark_schema(fields):
    """Helper for API parsing — build the Spark schema from the schema-file fields."""
    from pyspark.sql.types import (  # noqa: F811
        BooleanType, DoubleType, LongType, StringType, StructField, StructType,
    )
    tmap = {
        "string": StringType(), "boolean": BooleanType(),
        "integer": LongType(), "float": DoubleType(),
        "double": DoubleType(), "json": StringType(),
    }
    return StructType([
        StructField(f["column"], tmap.get(f["type"].lower(), StringType()), nullable=True)
        for f in fields
    ])


def build_records_api(source_df, meta):
    """Step 3 (API sources) — parse raw_json into rows using the schema file."""
    pipeline_context = {}
    if p_context_json and p_context_json.strip() not in ("", "{}"):
        pipeline_context = json.loads(p_context_json)
    ctx_row = {cf: pipeline_context.get(cf) for cf in meta["context_fields"]}

    schema_fields      = meta["schema_fields"]
    source_path        = meta["source_path"]
    array_explode_path = meta["array_explode_path"]

    raw_json_rows = source_df.select("raw_json").collect()
    rows = []

    if array_explode_path:
        print(f"  Mode : array-explode  (path='{array_explode_path}')")
        for rjr in raw_json_rows:
            raw_str = rjr["raw_json"]
            if not raw_str:
                continue
            response       = json.loads(raw_str)
            parent_records = extract_api_records(response, source_path)  # noqa: F821  # type: ignore[name-defined]
            for parent_rec in parent_records:
                child_array = resolve_json_path(parent_rec, array_explode_path)  # noqa: F821  # type: ignore[name-defined]
                if not child_array or not isinstance(child_array, list):
                    continue
                for child_item in child_array:
                    row = {}
                    for f in schema_fields:
                        src = f["source"]
                        if src.startswith("__parent__."):
                            val = resolve_json_path(parent_rec, src[len("__parent__."):])  # noqa: F821  # type: ignore[name-defined]
                        elif src.startswith("__top__."):
                            val = response.get(src[len("__top__."):])
                        else:
                            val = resolve_json_path(child_item, src)  # noqa: F821  # type: ignore[name-defined]
                        row[f["column"]] = _cast_field(val, f["type"])
                    row.update(ctx_row)
                    rows.append(row)
    else:
        print(f"  Mode : standard")
        for rjr in raw_json_rows:
            raw_str = rjr["raw_json"]
            if not raw_str:
                continue
            response = json.loads(raw_str)
            records  = extract_api_records(response, source_path)  # noqa: F821  # type: ignore[name-defined]
            for rec in records:
                row = {}
                for f in schema_fields:
                    src = f["source"]
                    if src.startswith("__top__."):
                        val = response.get(src[len("__top__."):])
                    else:
                        val = resolve_json_path(rec, src)  # noqa: F821  # type: ignore[name-defined]
                    row[f["column"]] = _cast_field(val, f["type"])
                row.update(ctx_row)
                rows.append(row)

    print(f"  API records parsed : {len(rows):,}")
    api_schema = _build_spark_schema(schema_fields)
    transformed_df = (
        spark.createDataFrame(rows, schema=api_schema)
        if rows
        else spark.createDataFrame([], schema=api_schema)
    )
    hash_cols_ordered = [f["column"] for f in schema_fields if f.get("hash", True)]
    return transformed_df, hash_cols_ordered


def build_records_flat(source_df, meta):
    """Step 3 (flat sources) — select/rename source columns per schema_config."""
    col_map, col_map_lower, hash_cols_ordered = build_col_maps(meta["mappings"])  # noqa: F821  # type: ignore[name-defined]

    source_columns_lower = {c.lower(): c for c in source_df.columns}
    select_exprs         = []
    missing_in_source    = []
    json_expand_count    = 0

    for src_col, tgt_col in col_map.items():
        if "." in src_col:
            json_expand_count += 1
            continue
        actual_col = source_columns_lower.get(src_col.lower())
        if actual_col is None:
            missing_in_source.append(src_col)
        else:
            select_exprs.append(F.col(actual_col).alias(tgt_col))

    if missing_in_source:
        print(f"  WARNING: {len(missing_in_source)} mapped column(s) not in source — set to NULL: {missing_in_source}")
        for src_col in missing_in_source:
            select_exprs.append(F.lit(None).cast("string").alias(col_map[src_col]))

    transformed_df = source_df.select(*select_exprs)
    if json_expand_count > 0:
        transformed_df = expand_json_fields(transformed_df, meta["mappings"])  # noqa: F821  # type: ignore[name-defined]
    print(f"  Columns after mapping : {len(transformed_df.columns)}")
    return transformed_df, hash_cols_ordered


def build_records(source_df, meta):
    """Step 3 — build the records DataFrame. Returns (transformed_df, hash_cols)."""
    print(f"\n[3/5] Building records DataFrame  (source_type={meta['source_type'] or 'flat'})")
    if meta["source_type"] == "api":
        return build_records_api(source_df, meta)
    return build_records_flat(source_df, meta)


def add_audit_and_hash(transformed_df, hash_cols_ordered, meta):
    """Step 4 — add audit columns and the md5 hash. Returns (final_df, row_count)."""
    print(f"\n[4/5] Applying audit columns and MD5 hash")
    final_df = add_audit_columns(  # noqa: F821  # type: ignore[name-defined]
        transformed_df,
        ingestion_date      = p_ingestion_date,
        data_timestamp      = p_ingestion_timestamp,
        source_system       = p_source_system,
        ingestion_run_id    = p_ingestion_run_id,
        ingestion_timestamp = p_ingestion_timestamp,
        src_busn_asst       = meta["src_busn_asst"],
    )
    final_df = compute_md5_hash(final_df, hash_cols_ordered)  # noqa: F821  # type: ignore[name-defined]
    row_count = final_df.count()
    print(f"  Rows to write : {row_count:,}")
    return final_df, row_count


def write_bronze(final_df, meta, final_row_count):
    """Step 5 — CREATE the table on first run, else replaceWhere the ingestion_date
    slice. Writes the LOAD audit-log row. Returns the verified target row count."""
    qualified_target = meta["qualified_target"]
    print(f"\n[5/5] Target table validation & write")

    table_exists = spark.catalog.tableExists(qualified_target)
    rows_before  = spark.table(qualified_target).count() if table_exists else 0
    print(f"  Target : lh_bronze.{qualified_target}")
    print(f"  Exists : {table_exists}")

    write_start = time.time()
    if not table_exists:
        print(f"  Action : CREATE")
        write_delta_create(final_df, qualified_target, meta["partition_cols"])  # noqa: F821  # type: ignore[name-defined]
    else:
        print(f"  Action : REPLACE WHERE ingestion_date = '{p_ingestion_date}'")
        (
            final_df.write
            .format("delta")
            .option("mergeSchema", "true")
            .option("replaceWhere", f"ingestion_date = '{p_ingestion_date}'")
            .mode("overwrite")
            .saveAsTable(qualified_target)
        )
        print(f"  Written to : lh_bronze.{qualified_target}")

    write_secs     = round(time.time() - write_start, 6)
    verified_count = spark.table(qualified_target).count()
    print(f"  Verified rows in target : {verified_count:,}")

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_bronze_ingestion_v3",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = rows_before,
        rows_after     = verified_count,
        execution_time = write_secs,
        message        = f"landing_table={p_landing_table_name} | rows_written={final_row_count} | run_id={p_ingestion_run_id}",
    )
    return verified_count


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Driver
# Runs the steps in order. One try/except: on any failure, log it and re-raise so
# the pipeline marks the activity as failed.
# ══════════════════════════════════════════════════════════════════════════════

qualified_target = p_bronze_table    # fallback name for the failure log

print("=" * 65)
print("  nb_bronze_ingestion_v3 — START")
print("=" * 65)

try:
    source_df, source_row_count, landing_ref = read_landing_source()

    meta = read_metadata(source_row_count, landing_ref)
    qualified_target = meta["qualified_target"]

    transformed_df, hash_cols_ordered = build_records(source_df, meta)

    final_df, final_row_count = add_audit_and_hash(transformed_df, hash_cols_ordered, meta)

    verified_count = write_bronze(final_df, meta, final_row_count)

    print("\n" + "=" * 65)
    print("  nb_bronze_ingestion_v3 — COMPLETE")
    print(f"  landing_table   : {p_landing_table_name}")
    print(f"  bronze_table    : lh_bronze.{qualified_target}")
    print(f"  rows_read       : {source_row_count:,}")
    print(f"  rows_written    : {final_row_count:,}")
    print(f"  rows_in_target  : {verified_count:,}")
    print(f"  ingestion_run_id: {p_ingestion_run_id}")
    print("=" * 65)

except Exception as _exc:
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_bronze_ingestion_v3",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = 0,
        rows_after     = 0,
        execution_time = round(time.time() - _notebook_start, 6),
        error_message  = str(_exc),
        message        = f"FAILED | landing_table={p_landing_table_name} | run_id={p_ingestion_run_id}",
    )
    raise
