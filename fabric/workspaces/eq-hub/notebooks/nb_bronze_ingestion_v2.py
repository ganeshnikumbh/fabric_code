# Notebook: nb_bronze_ingestion_v2
# Layer:    Bronze
# Purpose:  Metadata-driven ingestion from lh_landing → lh_bronze.
#           Receives pre-fetched control metadata as JSON strings from the pipeline,
#           avoiding repeated JDBC calls for each entity. Mirrors the DataFrame-filter
#           pattern of nb_bronze_ingestion — same logic, no lh_control dependency.
#
# Pipeline flow:
#   1. nb_get_ingestion_entities (p_config_type='ingestion_config') → full JSON array
#      → stored in a pipeline variable (e.g. v_ingestion_config_json)
#   2. nb_get_ingestion_entities (p_config_type='schema_config')    → full JSON array
#      → stored in a pipeline variable (e.g. v_schema_config_json)
#   3. ForEach over ingestion_config JSON items → calls this notebook per entity
#      Parameters per iteration:
#        p_source_table          : @item().source_table
#        p_source_schema         : @item().source_schema
#        p_target_table          : @item().target_table
#        p_ingestion_config_json : @variables('v_ingestion_config_json')  ← full array
#        p_schema_config_json    : @variables('v_schema_config_json')      ← full array
#
# Dependencies:
#   %run nb_utils   — ingestion_config_df_from_json, schema_config_df_from_json,
#                      build_col_maps
#
# Pre-requisites:
#   - Attach lh_bronze as the default lakehouse before running.
#   - lh_landing must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).
#   - nb_log_operation notebook must exist in the same workspace with
#     NO lakehouse attached (so FabricLogger writes to LH_EquiTrust_Monitoring).
#   - fabric_logging_utils.py must be in nb_log_operation's Resources/builtin/ folder.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_bronze_ingestion_v2").getOrCreate()
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_source_table           = ""   # REQUIRED — entity_name in ingestion_config (e.g. "Client")
p_source_schema          = ""   # REQUIRED — schema in source system / lh_landing (e.g. "dbo")
p_target_table           = ""   # REQUIRED — target Delta table in lh_bronze (e.g. "client_base")
p_ingestion_config_json  = ""   # REQUIRED — full ingestion_config JSON array for the source
                                #            Pipeline expression: @variables('v_ingestion_config_json')
p_schema_config_json     = ""   # REQUIRED — full schema_config JSON array for the source
                                #            Pipeline expression: @variables('v_schema_config_json')
p_ingestion_date         = ""   # e.g. "2025-04-09"     — pipeline run date
p_source_system          = ""   # e.g. "EQ_Warehouse"
p_ingestion_run_id       = ""   # UUID from pipeline
p_ingestion_timestamp    = ""   # e.g. "2025-04-09T01:00:00Z"

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

# initialise placeholders so the except block can always reference them
qualified_target = f"bronze_eqwarehouse.{p_target_table}"
source_row_count = 0
final_row_count  = 0
verified_count   = 0

print("=" * 65)
print("  nb_bronze_ingestion_v2 — START")
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
    print(f"\n[1/5] Reading source table: {_landing_ref}")

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
    # Creates DataFrames from the pre-fetched JSON strings and filters them —
    # same pattern as the old notebook reading from lh_control, but no JDBC.
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
            f"No ingestion_config row found for "
            f"source_table='{p_source_table}' / target_table='{p_target_table}'. "
            f"Ensure the entity is registered and active in ingestion_config."
        )

    config           = config_row[0]
    source_id        = config["source_id"]
    source_schema    = (config["source_schema"]    or "").strip()
    target_schema    = (config["target_schema"]    or "bronze_eqwarehouse").strip()
    qualified_target = f"{target_schema}.{p_target_table}"
    partition_cols   = [c.strip() for c in (config["partition_by_column_names"] or "").split(",") if c.strip()]
    src_busn_asst    = (config["src_busn_asst"] or "").strip() or None

    print(f"  source_id        : {source_id}")
    print(f"  source_schema    : {source_schema or '(none)'}")
    print(f"  partition_cols   : {partition_cols or '(none)'}")
    print(f"  src_busn_asst    : {src_busn_asst or '(none)'}")

    # ── 3b. schema_config ────────────────────────────────────────────────────
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
            f"No schema_config mappings found for source_table_name='{p_source_table}'. "
            f"Ensure column mappings are registered in schema_config."
        )

    col_map, col_map_lower, hash_cols_ordered = build_col_maps(mappings)  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils

    print(f"  Column mappings  : {len(col_map)} columns mapped")
    print(f"  Hash columns     : {len(hash_cols_ordered)}")

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
        notebook_name  = "nb_bronze_ingestion_v2",
        table_name     = qualified_target,
        operation_type = "EXTRACT",
        rows_before    = 0,
        rows_after     = source_row_count,
        execution_time = round(time.time() - _notebook_start, 6),
        message        = f"Source rows read from {_landing_ref} | run_id={p_ingestion_run_id}",
    )


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 4 — Column Transformation
    # Rename source columns to target names using the schema_config mapping.
    # Unmapped columns are dropped; mapped columns missing from source become NULL.
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[3/5] Applying column transformations")

    source_columns_lower = {c.lower(): c for c in source_df.columns}
    select_exprs         = []
    missing_in_source    = []

    for src_col, tgt_col in col_map.items():
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
    print(f"  Columns after mapping : {len(transformed_df.columns)} business columns")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 5 — Audit Columns + MD5 Hash
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[4/5] Applying audit columns and MD5 hash")

    # ── Audit columns ─────────────────────────────────────────────────────────
    final_df = add_audit_columns(  # noqa: F821  # type: ignore[name-defined]
        transformed_df,
        ingestion_date      = p_ingestion_date,
        data_timestamp      = p_ingestion_timestamp,
        source_system       = p_source_system,
        ingestion_run_id    = p_ingestion_run_id,
        ingestion_timestamp = p_ingestion_timestamp,
        src_busn_asst       = src_busn_asst,
    )

    # ── MD5 hash ──────────────────────────────────────────────────────────────
    final_df = compute_md5_hash(final_df, hash_cols_ordered)  # noqa: F821  # type: ignore[name-defined]

    final_row_count = final_df.count()
    print(f"  Rows to write : {final_row_count:,}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 6 — Write to lh_bronze
    # NEW table  → saveAsTable (overwrite to establish schema)
    # EXISTS     → append with mergeSchema=true
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[5/5] Target table validation & write")

    table_exists = spark.catalog.tableExists(qualified_target)
    rows_before  = spark.table(qualified_target).count() if table_exists else 0

    print(f"  Target  : lh_bronze.{qualified_target}")
    print(f"  Exists  : {table_exists}")

    _write_start = time.time()

    if not table_exists:
        print(f"  Action  : CREATE")
        write_delta_create(final_df, qualified_target, partition_cols)  # noqa: F821  # type: ignore[name-defined]
    else:
        print(f"  Action  : APPEND")
        (
            final_df.write
            .format("delta")
            .option("mergeSchema", "true")
            .mode("append")
            .saveAsTable(qualified_target)
        )
        print(f"  Appended to : lh_bronze.{qualified_target}")

    _write_secs  = round(time.time() - _write_start, 6)
    verified_count = spark.table(qualified_target).count()
    print(f"  Verified rows in target : {verified_count:,}")

    # ── Log success ───────────────────────────────────────────────────────────
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
        notebook_name  = "nb_bronze_ingestion_v2",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = rows_before,
        rows_after     = verified_count,
        execution_time = _write_secs,
        message        = f"source={p_source_table} | rows_written={final_row_count} | run_id={p_ingestion_run_id}",
    )

    print("\n" + "=" * 65)
    print("  nb_bronze_ingestion_v2 — COMPLETE")
    print(f"  source_table    : {p_source_table}")
    print(f"  target_table    : lh_bronze.{qualified_target}")
    print(f"  rows_read       : {source_row_count:,}")
    print(f"  rows_written    : {final_row_count:,}")
    print(f"  rows_in_target  : {verified_count:,}")
    print(f"  ingestion_run_id: {p_ingestion_run_id}")
    print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# Error handler — log failure then re-raise so the pipeline marks the
# activity as failed and surfaces the error in the pipeline run history.
# ══════════════════════════════════════════════════════════════════════════════

except Exception as _exc:
    _elapsed = round(time.time() - _notebook_start, 6)
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
        notebook_name  = "nb_bronze_ingestion_v2",
        table_name     = qualified_target,
        operation_type = "LOAD",
        rows_before    = 0,
        rows_after     = 0,
        execution_time = _elapsed,
        error_message  = str(_exc),
        message        = f"FAILED | source={p_source_table} | run_id={p_ingestion_run_id}",
    )
    raise
