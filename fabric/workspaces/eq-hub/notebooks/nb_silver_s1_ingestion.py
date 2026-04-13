# Notebook: nb_silver_s1_ingestion
# Layer:    Silver S1
# Purpose:  Metadata-driven MERGE from lh_bronze → lh_silver (silver_s1 schema).
#           Reads the last bronze batch using last_load_date from p_load_control_json,
#           then merges into the silver S1 table using primary keys from schema_config.
#           Rows are updated only when the source md5_hash differs from the target.
#
# Pipeline flow:
#   1. nb_get_ingestion_entities (p_config_type='ingestion_config') → v_ingestion_config_json
#   2. nb_get_ingestion_entities (p_config_type='schema_config')    → v_schema_config_json
#   3. nb_get_ingestion_entities (p_config_type='load_control')     → v_load_control_json
#   4. ForEach over ingestion_config items → calls this notebook per entity
#      Parameters per iteration:
#        p_source_schema         : @item().target_schema           ← bronze schema, e.g. bronze_eqwarehouse
#        p_source_table          : @item().target_table            ← bronze table,  e.g. client_base
#        p_target_table          : @item().target_table            ← silver table   (same name convention)
#        p_ingestion_config_json : @variables('v_ingestion_config_json')
#        p_schema_config_json    : @variables('v_schema_config_json')
#        p_load_control_json     : @variables('v_load_control_json')
#
# MERGE strategy  (SCD Type 1 — current state only):
#   WHEN MATCHED AND src.md5_hash IS DISTINCT FROM tgt.md5_hash → UPDATE all columns
#   WHEN NOT MATCHED BY TARGET                                   → INSERT
#   Rows unchanged (same md5_hash) are skipped — no write amplification.
#
# schema_config lookup note:
#   schema_config.target_table_name = bronze table name (e.g. 'client_base') = p_source_table.
#   Filtering schema_config by target_table_name gives both the column mappings AND the
#   source_table_name (landing entity name, e.g. 'Client') used for load_control lookup.
#   Primary key columns are target_column_name values where is_primary_key = 1
#   (target_column_name = bronze column name = silver column name).
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - lh_bronze must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time
from datetime import datetime, timedelta

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StringType, TimestampType
from delta.tables import DeltaTable

spark = SparkSession.builder.appName("nb_silver_s1_ingestion").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_source_schema          = ""   # REQUIRED — bronze schema, e.g. "bronze_eqwarehouse"
p_source_table           = ""   # REQUIRED — bronze table name, e.g. "client_base"
p_target_table           = ""   # REQUIRED — silver table name, e.g. "client_base"
p_source_system          = ""   # REQUIRED — source system name, e.g. "EQ_Warehouse"
                                #            Pipeline expression: @item().source_name
p_ingestion_run_id       = ""   # REQUIRED — UUID from pipeline
p_ingestion_timestamp    = ""   # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_ingestion_date         = ""   # REQUIRED — e.g. "2025-04-09"
p_ingestion_config_json  = ""   # REQUIRED — full ingestion_config JSON array
p_schema_config_json     = ""   # REQUIRED — full schema_config JSON array
p_load_control_json      = ""   # REQUIRED — full load_control JSON array

_required = {
    "p_source_schema"         : p_source_schema,
    "p_source_table"          : p_source_table,
    "p_target_table"          : p_target_table,
    "p_source_system"         : p_source_system,
    "p_ingestion_run_id"      : p_ingestion_run_id,
    "p_ingestion_timestamp"   : p_ingestion_timestamp,
    "p_ingestion_date"        : p_ingestion_date,
    "p_ingestion_config_json" : p_ingestion_config_json,
    "p_schema_config_json"    : p_schema_config_json,
    "p_load_control_json"     : p_load_control_json,
}
_missing = [k for k, v in _required.items() if not str(v).strip()]
if _missing:
    raise ValueError(f"Required parameters not provided: {_missing}")

# Placeholders so except block can always reference them
qualified_source = f"lh_bronze.{p_source_schema}.{p_source_table}"
qualified_target = f"silver_s1.{p_target_table}"
source_row_count = 0
rows_inserted    = 0
rows_updated     = 0

print("=" * 65)
print("  nb_silver_s1_ingestion — START")
print("=" * 65)
print(f"  source          : {qualified_source}")
print(f"  target          : lh_silver.{qualified_target}")
print(f"  ingestion_date  : {p_ingestion_date}")
print(f"  ingestion_run_id: {p_ingestion_run_id}")
print("=" * 65)

try:

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 2 — Resolve entity_name and schema mappings from JSON metadata
    # schema_config.target_table_name = bronze table name = p_source_table
    # schema_config.source_table_name = landing entity name used by load_control
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[1/5] Resolving metadata from JSON parameters")

    # ── 2a. schema_config → filter by target_table_name to get mappings and entity_name ──
    schema_config_df = schema_config_df_from_json(p_schema_config_json)  # noqa: F821  # type: ignore[name-defined]

    mappings = (
        schema_config_df
        .filter(
            (F.lower(F.col("target_table_name")) == p_source_table.lower()) &
            (F.col("source_column_name") != "N/A")
        )
        .orderBy("ordinal_position")
        .collect()
    )
    if not mappings:
        raise ValueError(
            f"No schema_config mappings found for target_table_name='{p_source_table}'. "
            f"Ensure column mappings are registered in schema_config with the correct target_table_name."
        )

    # entity_name = source_table_name (landing table, e.g. 'Client') — used for load_control lookup
    entity_name = mappings[0]["source_table_name"]
    print(f"  entity_name resolved : '{entity_name}' (from target_table_name='{p_source_table}')")

    # Primary key columns — these are target_column_name values (= bronze/silver column names)
    pk_cols = [
        row["target_column_name"]
        for row in mappings
        if row["is_primary_key"] == 1 or row["is_primary_key"] is True
    ]
    if not pk_cols:
        raise ValueError(
            f"No primary key columns defined in schema_config for '{entity_name}'. "
            f"Set is_primary_key = 1 for at least one column."
        )
    print(f"  Primary key cols     : {pk_cols}")
    print(f"  Schema mappings      : {len(mappings)} columns")

    # ── 2b. ingestion_config → is_scd2 and partition_by_column_names ─────────
    ingestion_config_df = ingestion_config_df_from_json(p_ingestion_config_json)  # noqa: F821  # type: ignore[name-defined]

    ic_row = (
        ingestion_config_df
        .filter(F.lower(F.col("target_table")) == p_target_table.lower())
        .limit(1)
        .collect()
    )
    ic_config      = ic_row[0] if ic_row else None
    is_scd2        = bool(ic_config["is_scd2"]) if ic_config and ic_config["is_scd2"] else False
    partition_cols = (
        [c.strip() for c in (ic_config["partition_by_column_names"] or "").split(",") if c.strip()]
        if ic_config else []
    )
    print(f"  is_scd2              : {is_scd2}")
    print(f"  partition_cols       : {partition_cols or '(none)'}")

    # ── 2c. load_control → last_load_date for bronze filter ──────────────────
    load_control_df = load_control_df_from_json(p_load_control_json)  # noqa: F821  # type: ignore[name-defined]

    lc_row = (
        load_control_df
        .filter(F.lower(F.col("entity_name")) == entity_name.lower())
        .limit(1)
        .collect()
    )
    last_load_date = lc_row[0]["last_load_date"] if lc_row else None
    filter_date    = last_load_date[:10] if last_load_date else None   # extract "YYYY-MM-DD"
    print(f"  last_load_date       : {last_load_date or '(none — will read all bronze rows)'}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 3 — Read Source Data from lh_bronze
    # Filter to rows written in the last bronze run (by ingestion_date).
    # If no last_load_date exists (first silver run) read all bronze rows.
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[2/5] Reading bronze source: {qualified_source}")

    try:
        bronze_df = spark.table(qualified_source)
    except Exception as e:
        raise RuntimeError(
            f"Failed to read '{qualified_source}'. "
            f"Ensure lh_bronze is added to this notebook session.\n{e}"
        )

    if filter_date:
        source_df = bronze_df.filter(F.col("ingestion_date") == filter_date)
        print(f"  Filter             : ingestion_date = '{filter_date}'")
    else:
        source_df = bronze_df
        print(f"  Filter             : none (first silver run — reading all rows)")

    source_row_count = source_df.count()
    print(f"  Rows to merge      : {source_row_count:,}")

    if source_row_count == 0:
        print("  WARNING: No source rows found for the given filter. Silver table will not be updated.")

    # ── Drop bronze audit columns and replace with silver-run values ──────────
    # These columns are carried through from bronze but represent the bronze run —
    # silver has its own run identity, date, and system context.
    _BRONZE_AUDIT_COLS = {
        "ingestion_date", "data_date", "source_system",
        "ingestion_run_id", "ingestion_timestamp",
    }
    _cols_to_drop = [c for c in source_df.columns if c in _BRONZE_AUDIT_COLS]
    if _cols_to_drop:
        source_df = source_df.drop(*_cols_to_drop)

    source_df = (
        source_df
        .withColumn("ingestion_date",      F.lit(p_ingestion_date).cast("date"))
        .withColumn("data_date",           F.lit(p_ingestion_date).cast("date"))
        .withColumn("source_system",       F.lit(p_source_system).cast(StringType()))
        .withColumn("ingestion_run_id",    F.lit(p_ingestion_run_id).cast(StringType()))
        .withColumn("ingestion_timestamp", F.lit(p_ingestion_timestamp).cast(TimestampType()))
    )
    print(f"  Replaced audit cols: {_cols_to_drop or '(none found — added fresh)'}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 4 — Write / MERGE into Silver S1
    #
    # SCD Type 1 (is_scd2=False):
    #   WHEN MATCHED AND md5_hash differs → UPDATE all columns
    #   WHEN NOT MATCHED                  → INSERT
    #
    # SCD Type 2 (is_scd2=True):
    #   Two-step merge to preserve full history:
    #   Step 1 — expire changed active records:
    #     WHEN MATCHED AND md5 differs AND tgt.expiration_timestamp = '9999-12-31' → UPDATE expiration_timestamp
    #   Step 2 — insert new / changed records:
    #     WHEN NOT MATCHED BY TARGET (against active records) → INSERT
    #   SCD2 columns added to all writes:
    #     effective_timestamp  = p_ingestion_date
    #     expiration_timestamp = 9999-12-31 00:00:00  (open/active sentinel)
    #
    # Partitioning (partition_cols non-empty):
    #   Applied only on first-run CREATE; Delta respects it on subsequent appends/merges.
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[3/5] Writing into lh_silver.{qualified_target}")
    print(f"  Strategy       : {'SCD Type 2' if is_scd2 else 'SCD Type 1'}")

    _OPEN_TS  = "9999-12-31 00:00:00"   # sentinel for active SCD2 records

    _merge_start = time.time()
    table_exists = spark.catalog.tableExists(qualified_target)

    # ── Prepare SCD2 columns on the source before any write ──────────────────
    if is_scd2:
        # expiration of the *previous* version = ingestion_date − 1 day
        _expiry_date = (
            datetime.strptime(p_ingestion_date, "%Y-%m-%d") - timedelta(days=1)
        ).strftime("%Y-%m-%d")
        _expiry_ts_str = f"{_expiry_date} 00:00:00"

        source_df = (
            source_df
            .withColumn("effective_timestamp",  F.lit(p_ingestion_date).cast(TimestampType()))
            .withColumn("expiration_timestamp", F.lit(_OPEN_TS).cast(TimestampType()))
        )
        print(f"  SCD2 expiry ts : {_expiry_ts_str}  (previous-version close date)")

    if not table_exists:
        # ── First run: create table with full write ───────────────────────────
        print(f"  Target does not exist — creating via full write")
        _writer = (
            source_df.write
            .format("delta")
            .option("mergeSchema", "true")
            .mode("overwrite")
        )
        if partition_cols:
            _writer = _writer.partitionBy(*partition_cols)
            print(f"  Partitioning by  : {partition_cols}")
        _writer.saveAsTable(qualified_target)
        rows_inserted = source_row_count
        rows_updated  = 0
        print(f"  Created lh_silver.{qualified_target}")

    elif is_scd2:
        # ── SCD Type 2: two-step merge ────────────────────────────────────────
        merge_condition        = " AND ".join([f"tgt.{pk} = src.{pk}" for pk in pk_cols])
        active_merge_condition = (
            merge_condition
            + f" AND tgt.expiration_timestamp = CAST('{_OPEN_TS}' AS TIMESTAMP)"
        )

        # Step 1 — expire changed active records
        (
            DeltaTable.forName(spark, qualified_target).alias("tgt")
            .merge(
                source    = source_df.alias("src"),
                condition = active_merge_condition,
            )
            .whenMatchedUpdate(
                condition = "src.md5_hash IS DISTINCT FROM tgt.md5_hash",
                set       = {"expiration_timestamp": F.lit(_expiry_ts_str).cast(TimestampType())},
            )
            .execute()
        )
        _step1_history  = (
            DeltaTable.forName(spark, qualified_target)
            .history(1).select("operationMetrics").collect()
        )
        _step1_metrics  = _step1_history[0]["operationMetrics"] if _step1_history else {}
        rows_expired    = int(_step1_metrics.get("numTargetRowsUpdated", 0))
        print(f"  Step 1 (expire)  : {rows_expired:,} records expired")

        # Step 2 — insert new records and new versions of changed records.
        # After Step 1 the expired records no longer have expiration_timestamp='9999-12-31',
        # so they will NOT match active_merge_condition → treated as WHEN NOT MATCHED → INSERT.
        (
            DeltaTable.forName(spark, qualified_target).alias("tgt")
            .merge(
                source    = source_df.alias("src"),
                condition = active_merge_condition,
            )
            .whenNotMatchedInsertAll()
            .execute()
        )
        _step2_history = (
            DeltaTable.forName(spark, qualified_target)
            .history(1).select("operationMetrics").collect()
        )
        _step2_metrics = _step2_history[0]["operationMetrics"] if _step2_history else {}
        rows_inserted  = int(_step2_metrics.get("numTargetRowsInserted", 0))
        rows_updated   = rows_expired   # semantic alias: "updated" = expired + re-inserted

    else:
        # ── SCD Type 1: standard MERGE ────────────────────────────────────────
        merge_condition = " AND ".join([f"tgt.{pk} = src.{pk}" for pk in pk_cols])
        update_set      = {col: f"src.{col}" for col in source_df.columns}

        (
            DeltaTable.forName(spark, qualified_target).alias("tgt")
            .merge(
                source    = source_df.alias("src"),
                condition = merge_condition,
            )
            .whenMatchedUpdate(
                # IS DISTINCT FROM handles NULLs: updates when hash changed OR one side is NULL
                condition = "src.md5_hash IS DISTINCT FROM tgt.md5_hash",
                set       = update_set,
            )
            .whenNotMatchedInsertAll()
            .execute()
        )

        _history = (
            DeltaTable.forName(spark, qualified_target)
            .history(1).select("operationMetrics").collect()
        )
        _metrics      = _history[0]["operationMetrics"] if _history else {}
        rows_inserted = int(_metrics.get("numTargetRowsInserted", 0))
        rows_updated  = int(_metrics.get("numTargetRowsUpdated",  0))

    _merge_secs = round(time.time() - _merge_start, 6)
    print(f"  Rows inserted  : {rows_inserted:,}")
    print(f"  Rows updated   : {rows_updated:,}")
    print(f"  Merge duration : {_merge_secs}s")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 5 — Verify target row count
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[4/5] Verifying target")
    target_row_count = spark.table(qualified_target).count()
    print(f"  Rows in lh_silver.{qualified_target} : {target_row_count:,}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 6 — Log operation
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[5/5] Logging")
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
        notebook_name  = "nb_silver_s1_ingestion",
        table_name     = qualified_target,
        operation_type = "MERGE",
        rows_before    = target_row_count - rows_inserted,
        rows_after     = target_row_count,
        execution_time = round(time.time() - _notebook_start, 6),
        message        = (
            f"source={qualified_source} | entity={entity_name} | "
            f"inserted={rows_inserted} | updated={rows_updated} | "
            f"run_id={p_ingestion_run_id}"
        ),
    )

    print("\n" + "=" * 65)
    print("  nb_silver_s1_ingestion — COMPLETE")
    print(f"  source          : {qualified_source}")
    print(f"  target          : lh_silver.{qualified_target}")
    print(f"  entity          : {entity_name}")
    print(f"  pk_cols         : {pk_cols}")
    print(f"  source_rows     : {source_row_count:,}")
    print(f"  rows_inserted   : {rows_inserted:,}")
    print(f"  rows_updated    : {rows_updated:,}")
    print(f"  target_total    : {target_row_count:,}")
    print(f"  ingestion_run_id: {p_ingestion_run_id}")
    print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# Error handler — log failure then re-raise so the pipeline marks the
# activity as failed.
# ══════════════════════════════════════════════════════════════════════════════

except Exception as _exc:
    _elapsed = round(time.time() - _notebook_start, 6)
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
        notebook_name  = "nb_silver_s1_ingestion",
        table_name     = qualified_target,
        operation_type = "MERGE",
        rows_before    = 0,
        rows_after     = 0,
        execution_time = _elapsed,
        error_message  = str(_exc),
        message        = f"FAILED | source={p_source_table} | run_id={p_ingestion_run_id}",
    )
    raise
