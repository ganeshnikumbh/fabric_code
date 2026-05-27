# Notebook: nb_load_landing_to_bronze_v3
# Layer:    Bronze
# Purpose:  Metadata-driven ingestion from lh_landing → lh_bronze.
#           Dispatches on source_type from ingestion_config:
#             'api'  — reads raw_json column from landing (whole-text JSON string per file),
#                      extracts records using source_path, flattens each record using a
#                      JSON schema file stored at:
#                        /lakehouse/default/Files/{p_target_schema}/schemas/{p_target_table}.json
#                      Schema file drives column names, source paths, types, and whether
#                      to explode a nested array (array_explode_path).
#             other  — flat column rename using build_col_maps / expand_json_fields
#                      (same pattern as nb_bronze_ingestion_v2).
#           Always appends to an existing target table; creates on first run.
#
# Pipeline flow:
#   1. nb_get_ingestion_entities (p_config_type='ingestion_config') → JSON array
#      → stored in pipeline variable v_ingestion_config_json
#   2. nb_get_ingestion_entities (p_config_type='schema_config')    → JSON array
#      → stored in pipeline variable v_schema_config_json  (used only for non-API sources)
#   3. ForEach over ingestion_config items → calls this notebook per entity
#      Parameters per iteration:
#        p_source_table          : @item().source_table
#        p_source_schema         : @item().source_schema
#        p_target_table          : @item().target_table
#        p_ingestion_config_json : @variables('v_ingestion_config_json')
#        p_schema_config_json    : @variables('v_schema_config_json')
#        p_ingestion_date        : pipeline run date, e.g. '2025-04-09'
#        p_source_system         : e.g. 'HubSpot', 'Webex', 'EQ_Warehouse'
#        p_ingestion_run_id      : pipeline run UUID
#        p_ingestion_timestamp   : e.g. '2025-04-09T01:00:00Z'
#        p_context_json          : optional — JSON with pipeline context fields injected
#                                  into context_fields listed in the schema file
#                                  e.g. '{"object_type":"contacts"}' for crm_contacts
#
# JSON schema file format (for source_type='api'):
#   Located at /lakehouse/default/Files/{target_schema}/schemas/{target_table}.json
#   {
#     "table_name"         : "aar_base",
#     "source_path"        : "result.data",   ← overrides ingestion_config.source_path
#     "array_explode_path" : "",              ← set for child tables (e.g. "activities.nodes")
#     "context_fields"     : [],             ← field names injected from p_context_json
#     "fields": [
#       {"column": "id",    "source": "id",          "type": "string"},
#       {"column": "email", "source": "customer.email","type": "string"},
#       {"column": "x_json","source": "details",     "type": "json"}
#     ]
#   }
#
# source path conventions in schema file fields:
#   dot.path             — standard resolve_json_path() traversal (supports nested dicts)
#   '__top__.<key>'      — extracted from the raw response envelope, not the record
#   '__parent__.<path>'  — from the parent record when in array-explode mode
#   '__item__'           — the record itself (for string-array responses)
#   '$first'/$first_key' — first value / key of a dynamic-key dict
#   '$N'                 — element at index N of a list  (e.g. '$0')
#
# Dependencies:
#   %run nb_utils   — all standard utilities
#
# Pre-requisites:
#   - Attach lh_bronze as default lakehouse before running.
#   - lh_landing must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import json
import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_load_landing_to_bronze_v3").getOrCreate()
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_source_table          = ""    # REQUIRED — entity_name in ingestion_config
p_source_schema         = ""    # REQUIRED — schema in lh_landing (e.g. 'hubspot', 'webex', 'dbo')
p_target_table          = ""    # REQUIRED — target Delta table in lh_bronze
p_ingestion_config_json = ""    # REQUIRED — full ingestion_config JSON array for the source
                                #            Pipeline expression: @variables('v_ingestion_config_json')
p_schema_config_json    = ""    # REQUIRED — full schema_config JSON array for the source
                                #            Pipeline expression: @variables('v_schema_config_json')
p_ingestion_date        = ""    # e.g. '2025-04-09'
p_source_system         = ""    # e.g. 'HubSpot', 'Webex', 'EQ_Warehouse'
p_ingestion_run_id      = ""    # UUID from pipeline
p_ingestion_timestamp   = ""    # e.g. '2025-04-09T01:00:00Z'
p_context_json          = "{}"  # optional — JSON with pipeline context for N/A schema_config rows

_required = {
    "p_source_table"          : p_source_table,
    "p_source_schema"         : p_source_schema,
    "p_target_table"          : p_target_table,
    "p_ingestion_config_json" : p_ingestion_config_json,
    "p_schema_config_json"    : p_schema_config_json,
    "p_ingestion_date"        : p_ingestion_date,
    "p_source_system"         : p_source_system,
    "p_ingestion_run_id"      : p_ingestion_run_id,
    "p_ingestion_timestamp"   : p_ingestion_timestamp,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

qualified_target = p_target_table
source_row_count = 0
final_row_count  = 0
verified_count   = 0

print("=" * 65)
print("  nb_load_landing_to_bronze_v3 — START")
print("=" * 65)
print(f"  source_table      : {p_source_table}")
print(f"  source_schema     : {p_source_schema}")
print(f"  target_table      : {p_target_table}")
print(f"  ingestion_date    : {p_ingestion_date}")
print(f"  source_system     : {p_source_system}")
print(f"  ingestion_run_id  : {p_ingestion_run_id}")
print(f"  ingestion_timestamp: {p_ingestion_timestamp}")
print("=" * 65)


try:

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 2 — Read Source Data from lh_landing
    # ══════════════════════════════════════════════════════════════════════════

    _landing_ref = (
        f"lh_landing.{p_source_schema}.{p_source_table}"
        if p_source_schema.strip()
        else f"lh_landing.{p_source_table}"
    )
    print(f"\n[1/5] Reading source: {_landing_ref}")

    try:
        source_df = spark.table(_landing_ref)
    except Exception as e:
        raise RuntimeError(
            f"Failed to read '{_landing_ref}'. "
            f"Ensure lh_landing is added to this notebook session.\n{e}"
        )

    source_row_count = source_df.count()
    print(f"  Rows read : {source_row_count:,}")

    if source_row_count == 0:
        print("  WARNING: Source table is empty. Writing zero rows to Bronze.")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 3 — Read Metadata from JSON parameters
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[2/5] Reading metadata from JSON parameters")

    # ── 3a. ingestion_config ─────────────────────────────────────────────────
    ingestion_config_df = ingestion_config_df_from_json(p_ingestion_config_json)  # noqa: F821  # type: ignore[name-defined]

    config_row = (
        ingestion_config_df
        .filter(
            (F.lower(F.col("source_table")) == p_source_table.lower()) &
            (F.lower(F.col("target_table")) == p_target_table.lower())
        )
        .limit(1)
        .collect()
    )

    if not config_row:
        raise ValueError(
            f"No ingestion_config row for "
            f"source_table='{p_source_table}' / target_table='{p_target_table}'. "
            f"Ensure the entity is registered and active in ingestion_config."
        )

    config           = config_row[0]
    source_id        = config["source_id"]
    source_type      = (config["source_type"]   or "").strip().lower()
    source_schema    = (config["source_schema"]  or "").strip()
    target_schema    = (config["target_schema"]  or "").strip()
    source_path      = (config["source_path"]    or "").strip()
    qualified_target = f"{target_schema}.{p_target_table}" if target_schema else p_target_table
    partition_cols   = [c.strip() for c in (config["partition_by_column_names"] or "").split(",") if c.strip()]
    src_busn_asst    = (config["src_busn_asst"]  or "").strip() or None

    print(f"  source_id     : {source_id}")
    print(f"  source_type   : {source_type or '(not set)'}")
    print(f"  source_path   : {source_path or '(root)'}")
    print(f"  target_schema : {target_schema}")
    print(f"  partition_cols: {partition_cols or '(none)'}")
    print(f"  src_busn_asst : {src_busn_asst or '(none)'}")

    # ── 3b. Column mappings ──────────────────────────────────────────────────
    # API sources  → read JSON schema file from the default lakehouse Files section.
    # Flat sources → read column mappings from p_schema_config_json parameter.
    if source_type == "api":
        _schema_file = f"/lakehouse/default/Files/{p_source_schema}/schemas/{p_source_table}.json"
        print(f"  Schema file     : {_schema_file}")
        try:
            with open(_schema_file) as _sf:
                _table_schema = json.load(_sf)
        except FileNotFoundError:
            raise ValueError(
                f"Schema file not found: '{_schema_file}'. "
                f"Create a schema JSON file at {p_source_schema}/schemas/{p_source_table}.json."
            )
        _schema_fields      = _table_schema.get("fields", [])
        _context_fields     = _table_schema.get("context_fields", [])
        _array_explode_path = (_table_schema.get("array_explode_path") or "").strip()
        # schema file source_path overrides ingestion_config when explicitly set
        if _table_schema.get("source_path") is not None:
            source_path = _table_schema["source_path"].strip()
        print(f"  Schema fields   : {len(_schema_fields)}")
        print(f"  array_explode   : {_array_explode_path or '(none)'}")
        print(f"  source_path     : {source_path or '(root)'}")
        mappings = None
    else:
        schema_config_df = schema_config_df_from_json(p_schema_config_json)  # noqa: F821  # type: ignore[name-defined]
        mappings = (
            schema_config_df
            .filter(
                (F.lower(F.col("source_table_name")) == p_source_table.lower()) &
                (F.col("source_column_name") != "N/A")
            )
            .orderBy("ordinal_position")
            .collect()
        )
        if not mappings:
            raise ValueError(
                f"No schema_config mappings for source_table_name='{p_source_table}'. "
                f"Ensure column mappings are registered in schema_config."
            )
        print(f"  Column mappings : {len(mappings)}")

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_load_landing_to_bronze_v3",
        table_name     = qualified_target,
        operation_type = "EXTRACT",
        rows_before    = 0,
        rows_after     = source_row_count,
        execution_time = round(time.time() - _notebook_start, 6),
        message        = f"Source rows read from {_landing_ref} | run_id={p_ingestion_run_id}",
    )


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 4 — Build Records DataFrame
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[3/5] Building records DataFrame  (source_type={source_type or 'flat'})")

    if source_type == "api":

        # ── 4a. API path — schema-file-driven ────────────────────────────────
        # resolve_json_path and extract_api_records are injected by %run nb_utils.py

        def _cast_field(val, field_type):
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
            from pyspark.sql.types import (  # noqa: F811
                BooleanType, DoubleType, IntegerType, StringType, StructField, StructType,
            )
            _tmap = {
                "string": StringType(), "boolean": BooleanType(),
                "integer": IntegerType(), "float": DoubleType(),
                "double": DoubleType(), "json": StringType(),
            }
            return StructType([
                StructField(f["column"], _tmap.get(f["type"].lower(), StringType()), nullable=True)
                for f in fields
            ])

        _pipeline_context = {}
        if p_context_json and p_context_json.strip() not in ("", "{}"):
            _pipeline_context = json.loads(p_context_json)
        _ctx_row = {cf: _pipeline_context.get(cf) for cf in _context_fields}

        _raw_json_rows = source_df.select("raw_json").collect()
        rows = []

        if _array_explode_path:
            # ── child table: one output row per element in the nested array ──
            print(f"  Mode : array-explode  (path='{_array_explode_path}')")
            for _rjr in _raw_json_rows:
                _raw_str = _rjr["raw_json"]
                if not _raw_str:
                    continue
                _response       = json.loads(_raw_str)
                _parent_records = extract_api_records(_response, source_path)  # noqa: F821  # type: ignore[name-defined]
                for _parent_rec in _parent_records:
                    _child_array = resolve_json_path(_parent_rec, _array_explode_path)  # noqa: F821  # type: ignore[name-defined]
                    if not _child_array or not isinstance(_child_array, list):
                        continue
                    for _child_item in _child_array:
                        _row = {}
                        for _f in _schema_fields:
                            _src = _f["source"]
                            if _src.startswith("__parent__."):
                                _val = resolve_json_path(_parent_rec, _src[len("__parent__."):])  # noqa: F821  # type: ignore[name-defined]
                            elif _src.startswith("__top__."):
                                _val = _response.get(_src[len("__top__."):])
                            else:
                                _val = resolve_json_path(_child_item, _src)  # noqa: F821  # type: ignore[name-defined]
                            _row[_f["column"]] = _cast_field(_val, _f["type"])
                        _row.update(_ctx_row)
                        rows.append(_row)
        else:
            # ── parent table: one output row per record ───────────────────────
            print(f"  Mode : standard")
            for _rjr in _raw_json_rows:
                _raw_str = _rjr["raw_json"]
                if not _raw_str:
                    continue
                _response = json.loads(_raw_str)
                _records  = extract_api_records(_response, source_path)  # noqa: F821  # type: ignore[name-defined]
                for _rec in _records:
                    _row = {}
                    for _f in _schema_fields:
                        _src = _f["source"]
                        if _src.startswith("__top__."):
                            _val = _response.get(_src[len("__top__."):])
                        else:
                            _val = resolve_json_path(_rec, _src)  # noqa: F821  # type: ignore[name-defined]
                        _row[_f["column"]] = _cast_field(_val, _f["type"])
                    _row.update(_ctx_row)
                    rows.append(_row)

        print(f"  API records parsed : {len(rows):,}")

        _api_schema    = _build_spark_schema(_schema_fields)
        transformed_df = (
            spark.createDataFrame(rows, schema=_api_schema)
            if rows
            else spark.createDataFrame([], schema=_api_schema)
        )

        hash_cols_ordered = [f["column"] for f in _schema_fields if f.get("hash", True)]

    else:

        # ── 4b. Flat path (non-API) ───────────────────────────────────────────
        col_map, col_map_lower, hash_cols_ordered = build_col_maps(mappings)  # noqa: F821  # type: ignore[name-defined]

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
            transformed_df = expand_json_fields(transformed_df, mappings)  # noqa: F821  # type: ignore[name-defined]

        print(f"  Columns after mapping : {len(transformed_df.columns)}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 5 — Audit Columns + MD5 Hash
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[4/5] Applying audit columns and MD5 hash")

    final_df = add_audit_columns(  # noqa: F821  # type: ignore[name-defined]
        transformed_df,
        ingestion_date      = p_ingestion_date,
        data_timestamp      = p_ingestion_timestamp,
        source_system       = p_source_system,
        ingestion_run_id    = p_ingestion_run_id,
        ingestion_timestamp = p_ingestion_timestamp,
        src_busn_asst       = src_busn_asst,
    )
    final_df = compute_md5_hash(final_df, hash_cols_ordered)  # noqa: F821  # type: ignore[name-defined]

    final_row_count = final_df.count()
    print(f"  Rows to write : {final_row_count:,}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 6 — Write to lh_bronze
    # NEW table  → write_delta_create (overwrite to establish schema)
    # EXISTS     → append with mergeSchema=true
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[5/5] Target table validation & write")

    table_exists = spark.catalog.tableExists(qualified_target)
    rows_before  = spark.table(qualified_target).count() if table_exists else 0

    print(f"  Target : lh_bronze.{qualified_target}")
    print(f"  Exists : {table_exists}")

    _write_start = time.time()

    if not table_exists:
        print(f"  Action : CREATE")
        write_delta_create(final_df, qualified_target, partition_cols)  # noqa: F821  # type: ignore[name-defined]
    else:
        print(f"  Action : APPEND")
        (
            final_df.write
            .format("delta")
            .option("mergeSchema", "true")
            .mode("append")
            .saveAsTable(qualified_target)
        )
        print(f"  Appended to : lh_bronze.{qualified_target}")

    _write_secs    = round(time.time() - _write_start, 6)
    verified_count = spark.table(qualified_target).count()
    print(f"  Verified rows in target : {verified_count:,}")

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_load_landing_to_bronze_v3",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = rows_before,
        rows_after     = verified_count,
        execution_time = _write_secs,
        message        = f"source={p_source_table} | rows_written={final_row_count} | run_id={p_ingestion_run_id}",
    )

    print("\n" + "=" * 65)
    print("  nb_load_landing_to_bronze_v3 — COMPLETE")
    print(f"  source_table    : {p_source_table}")
    print(f"  target_table    : lh_bronze.{qualified_target}")
    print(f"  rows_read       : {source_row_count:,}")
    print(f"  rows_written    : {final_row_count:,}")
    print(f"  rows_in_target  : {verified_count:,}")
    print(f"  ingestion_run_id: {p_ingestion_run_id}")
    print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# Error handler — log failure then re-raise so the pipeline marks the
# activity as failed.
# ══════════════════════════════════════════════════════════════════════════════

except Exception as _exc:
    _elapsed = round(time.time() - _notebook_start, 6)
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_load_landing_to_bronze_v3",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = 0,
        rows_after     = 0,
        execution_time = _elapsed,
        error_message  = str(_exc),
        message        = f"FAILED | source={p_source_table} | run_id={p_ingestion_run_id}",
    )
    raise
