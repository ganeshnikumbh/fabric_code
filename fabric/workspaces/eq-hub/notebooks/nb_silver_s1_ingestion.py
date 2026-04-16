# Notebook: nb_silver_s1_ingestion
# Layer:    Silver S1
# Purpose:  Metadata-driven SCD2 MERGE from lh_bronze → lh_silver (silver_s1 schema).
#           Reads the latest bronze batch by computing max(data_timestamp) directly from
#           the bronze table, then applies an md5-hash-only SCD2 strategy.
#
# Pipeline flow:
#   1. nb_get_ingestion_entities (p_config_type='ingestion_config') → v_ingestion_config_json
#   2. nb_get_ingestion_entities (p_config_type='schema_config')    → v_schema_config_json
#   3. ForEach over ingestion_config items → calls this notebook per entity
#      Parameters per iteration:
#        p_source_schema         : @item().target_schema           ← bronze schema, e.g. bronze_eqwarehouse
#        p_source_table          : @item().target_table            ← bronze table,  e.g. client_base
#        p_target_table          : @item().target_table            ← silver table   (same name convention)
#        p_ingestion_config_json : @variables('v_ingestion_config_json')
#        p_schema_config_json    : @variables('v_schema_config_json')
#
# Bronze filter:
#   max(data_timestamp) is derived directly from the bronze table at runtime.
#   All rows matching that max date are read as the current batch.
#
# schema_config lookup note:
#   schema_config.target_table_name = bronze table name (e.g. 'client_base') = p_source_table.
#   Filtering schema_config by target_table_name gives both the column mappings AND the
#   source_table_name (landing entity name, e.g. 'Client').
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - lh_bronze must be added to the notebook session
#     (Notebook settings → Lakehouses → Add).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import TimestampType, IntegerType
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
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

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
    # schema_config.source_table_name = landing entity name (e.g. 'Client')
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

    entity_name = mappings[0]["source_table_name"]
    print(f"  entity_name resolved : '{entity_name}' (from target_table_name='{p_source_table}')")
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

    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 3 — Read Source Data from lh_bronze
    # Derive the filter date by computing max(data_timestamp) directly from the
    # bronze table. All rows matching that date form the current batch.
    # ══════════════════════════════════════════════════════════════════════════

    print(f"\n[2/5] Reading bronze source: {qualified_source}")

    try:
        bronze_df = spark.table(qualified_source)
    except Exception as e:
        raise RuntimeError(
            f"Failed to read '{qualified_source}'. "
            f"Ensure lh_bronze is added to this notebook session.\n{e}"
        )

    # ── Derive filter date from bronze max(ingestion_date) ─────────────────────────
    max_ingestion_date_row = bronze_df.agg(F.max("ingestion_date").alias("max_ingestion_date")).collect()
    max_ingestion_date     = max_ingestion_date_row[0]["max_ingestion_date"] if max_ingestion_date_row else None

    if max_ingestion_date:
        source_df = bronze_df.filter(F.col("ingestion_date") == max_ingestion_date)
        print(f"  Filter             : ingestion_date = '{max_ingestion_date}'  (max from bronze)")
    else:
        source_df = bronze_df
        print(f"  Filter             : none (bronze table has no data_timestamp — reading all rows)")

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

    source_df = add_audit_columns(  # noqa: F821  # type: ignore[name-defined]
        source_df,
        ingestion_date      = p_ingestion_date,
        data_timestamp      = p_ingestion_timestamp,
        source_system       = p_source_system,
        ingestion_run_id    = p_ingestion_run_id,
        ingestion_timestamp = p_ingestion_timestamp,
    )
    print(f"  Replaced audit cols: {_cols_to_drop or '(none found — added fresh)'}")


    # ══════════════════════════════════════════════════════════════════════════
    # SECTION 4 — Write / MERGE into Silver S1
    #
    # Branched on is_scd2 flag from ingestion_config:
    #
    # is_scd2 = True  → SCD Type 2, md5-hash-only history tracking
    #   effective_timestamp, expiration_timestamp, is_current added to source.
    #   Steps 1-5: add columns → find new → find expired → expire → append new.
    #
    # is_scd2 = False → SCD Type 1, md5 insert-only (no history columns)
    #   Source rows with a new md5_hash are appended.
    #   Source rows whose md5_hash already exists in target are skipped entirely.
    #
    # Primary key is NOT used in any join — md5_hash is the sole matching key.
    # Partitioning applied only on first-run CREATE.
    # ══════════════════════════════════════════════════════════════════════════

    _strategy    = "SCD Type 2 (md5-only)" if is_scd2 else "SCD Type 1 (md5 insert-only)"
    print(f"\n[3/5] Writing into lh_silver.{qualified_target}  [strategy: {_strategy}]")

    _OPEN_TS     = "9999-12-31 00:00:00"   # sentinel for active SCD2 records
    _merge_start = time.time()
    table_exists = spark.catalog.tableExists(qualified_target)

    if is_scd2:
        # ══════════════════════════════════════════════════════════════════════
        # SCD TYPE 2 — md5-hash-only history tracking
        #
        #   MD5 in source | MD5 in target (active) | Action
        #   ──────────────|────────────────────────|──────────────────────────
        #   YES           | YES                    | SKIP  — unchanged
        #   YES           | NO                     | INSERT — new / changed row
        #   NO            | YES                    | EXPIRE — set expiration + is_current=0
        #   NO            | NO                     | ignore — already expired
        # ══════════════════════════════════════════════════════════════════════

        # ── Step 1: Add SCD2 columns to source ───────────────────────────────
        source_df = (
            source_df
            .withColumn("effective_timestamp",  F.lit(p_ingestion_timestamp).cast(TimestampType()))
            .withColumn("expiration_timestamp", F.lit(_OPEN_TS).cast(TimestampType()))
            .withColumn("is_current",           F.lit(1).cast(IntegerType()))
        )

        if not table_exists:
            # First run — create table with full write
            print(f"  Target does not exist — creating via full write")
            write_delta_create(source_df, qualified_target, partition_cols, tbl_properties={"delta.enableChangeDataFeed": "true"})  # noqa: F821  # type: ignore[name-defined]
            rows_inserted = source_row_count
            rows_updated  = 0

        else:
            target_df = spark.table(qualified_target)

            # ── Step 2: Identify NEW records ─────────────────────────────────
            # New = source rows whose md5_hash does not exist anywhere in target
            new_records_df = source_df.join(
                target_df.select("md5_hash"),
                on  = "md5_hash",
                how = "left_anti",
            )

            # ── Step 3: Identify EXPIRED records ─────────────────────────────
            # Expired = active target rows (is_current=1) whose md5 is absent from source
            expired_df = (
                target_df
                .filter(F.col("is_current") == 1)
                .join(source_df.select("md5_hash"), on="md5_hash", how="left_anti")
                .select("md5_hash")
            )

            rows_inserted = new_records_df.count()
            rows_updated  = expired_df.count()
            print(f"  New records      : {rows_inserted:,}")
            print(f"  Records to expire: {rows_updated:,}")

            # ── Step 4: MERGE — expire stale active records ───────────────────
            # Match on md5_hash AND is_current=1 so already-expired history rows
            # are never touched.
            if rows_updated > 0:
                (
                    DeltaTable.forName(spark, qualified_target).alias("tgt")
                    .merge(
                        source    = expired_df.alias("src"),
                        condition = "tgt.md5_hash = src.md5_hash AND tgt.is_current = 1",
                    )
                    .whenMatchedUpdate(set={
                        "is_current":           F.lit(0).cast(IntegerType()),
                        "expiration_timestamp": F.lit(p_ingestion_timestamp).cast(TimestampType()),
                    })
                    .execute()
                )
                print(f"  Step 4 (expire)  : {rows_updated:,} records expired")

            # ── Step 5: APPEND new / changed records ──────────────────────────
            # Plain append is safe — md5 uniqueness is guaranteed by Step 2.
            if rows_inserted > 0:
                (
                    new_records_df.write
                    .format("delta")
                    .mode("append")
                    .saveAsTable(qualified_target)
                )
                print(f"  Step 5 (append)  : {rows_inserted:,} new records appended")

    else:
        # ══════════════════════════════════════════════════════════════════════
        # SCD TYPE 1 — md5 insert-only (no history, no expiry columns)
        #
        # Source rows whose md5_hash already exists in the target are skipped.
        # Source rows with a new md5_hash are appended.
        # No updates to existing rows — md5 match = record unchanged.
        # ══════════════════════════════════════════════════════════════════════

        # ── Step 1: Add is_current columns to source ───────────────────────────────
        source_df = (
            source_df
            .withColumn("is_current",           F.lit(1).cast(IntegerType()))
        )

        if not table_exists:
            # First run — create table with full write
            print(f"  Target does not exist — creating via full write")
            write_delta_create(source_df, qualified_target, partition_cols, tbl_properties={"delta.enableChangeDataFeed": "true"})  # noqa: F821  # type: ignore[name-defined]
            rows_inserted = source_row_count
            rows_updated  = 0

        else:
            target_df = spark.table(qualified_target)

            # Insert only rows whose md5_hash is not already in the target
            new_records_df = source_df.join(
                target_df.select("md5_hash"),
                on  = "md5_hash",
                how = "left_anti",
            )

            rows_inserted = new_records_df.count()
            rows_updated  = 0
            print(f"  New records      : {rows_inserted:,}  (existing md5 matches skipped)")

            if rows_inserted > 0:
                (
                    new_records_df.write
                    .format("delta")
                    .mode("append")
                    .saveAsTable(qualified_target)
                )
                print(f"  Appended         : {rows_inserted:,} new records")

    _merge_secs = round(time.time() - _merge_start, 6)
    print(f"  Rows inserted  : {rows_inserted:,}")
    print(f"  Rows expired   : {rows_updated:,}")
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
