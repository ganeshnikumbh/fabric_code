#!/usr/bin/env python
# coding: utf-8

# ## nb_silver_s1_ingestion_v2
#
# Same behaviour as nb_silver_s1_ingestion, reorganised for readability: instead
# of one long try/except block, each operation is its own plain function, and a
# short "driver" section at the bottom calls them in order. No frameworks — just
# functions, a small config dictionary (meta), and a single try/except. A plain
# `if source_row_count > 0:` handles the 0-row skip.
#
# Logging: uses the shared Logger from nb_utils via `logger` — every console
# message is timestamped, levelled (INFO/WARNING/ERROR), and tagged with the
# notebook name, instead of bare print().
#
# Performance: the fully-transformed source frame is cached ONCE and its row count
# materialised a single time, so validation and the SCD write reuse the same
# computed data instead of re-running the read->dedup->cast->project chain per
# action.

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %%configure
# {
#     "defaultLakehouse": {
#         "name":        { "variableName": "$(/**/vl_lakehouse_config/lh_bronze_name)" },
#         "id":          { "variableName": "$(/**/vl_lakehouse_config/lh_bronze_id)" },
#         "workspaceId": { "variableName": "$(/**/vl_lakehouse_config/lh_workspace_id)" }
#     }
# }


# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# Notebook: nb_silver_s1_ingestion_v2
# Layer:    Silver S1
# Purpose:  Metadata-driven bronze -> silver_s1 load with type-casting, defaults,
#           NOT NULL enforcement, and an SCD2 / non-SCD write.
#
# The work is split into one function per step. The driver at the bottom runs
# them in this order:
#   1. resolve_metadata()    — schema_config mappings + ingestion_config flags
#   2. read_bronze_source()  — read bronze for the ingestion_date
#   3. swap_audit_columns()  — drop bronze audit cols, add fresh silver-run audit cols
#   4. deduplicate()         — dedup on md5_hash
#   5. cast_and_default()    — cast bronze -> silver types, replace null/blank/junk
#   6. project_columns()     — keep mapped silver + system columns only
#      → cache + count once here (drives the 0-row skip and feeds later steps)
#   7. validate()            — silver validation           (only if rows > 0)
#   8. write_silver()        — SCD2 merge or non-SCD append (only if rows > 0)
#   9. enforce_not_null()    — SET NOT NULL on is_nullable=0 columns
#  10. verify_target()       — target row count
#  Then: log success, and (non-fatal) refresh silver_s2 materialized lake view(s).
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse before running.
#   - lh_bronze must be added to the notebook session.

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import StringType, TimestampType, IntegerType
from delta.tables import DeltaTable

spark = SparkSession.builder.appName("nb_silver_s1_ingestion_v2").getOrCreate()
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")

# Shared notebook logger (create_logger provided by nb_utils via %run above).
logger = create_logger("nb_silver_s1_ingestion_v2")  # noqa: F821  # type: ignore[name-defined]

_notebook_start = time.time()


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_source_schema          = ""   # REQUIRED — bronze schema, e.g. "bronze_eqwarehouse"
p_source_table           = ""   # REQUIRED — bronze table name, e.g. "client_base"
p_target_table           = ""   # REQUIRED — silver table name, e.g. "client_base"
p_source_system          = ""   # REQUIRED — source system name, e.g. "EQ_Warehouse"
p_ingestion_run_id       = ""   # REQUIRED — UUID from pipeline
p_ingestion_timestamp    = ""   # REQUIRED — e.g. "2025-04-09T01:00:00Z"
p_ingestion_date         = ""   # REQUIRED — e.g. "2025-04-09"
p_ingestion_config_json  = ""   # REQUIRED — full ingestion_config JSON array
p_schema_config_json     = ""   # REQUIRED — full schema_config JSON array
p_debug                  = False # OPTIONAL — True = take exact row counts for logging.
                                 # False (default) skips operational counts; control
                                 # flow uses cheap existence checks instead.


# In[ ]:


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

# Fixed table references.
qualified_source = f"lh_bronze.{p_source_schema}.{p_source_table}"
qualified_target = f"lh_silver.silver_s1.{p_target_table}"

# Bronze audit columns carried through from bronze — dropped and replaced with
# silver-run values. src_busn_asst is re-applied from ingestion_config.
_BRONZE_AUDIT_COLS = {
    "ingestion_date", "data_timestamp", "source_system",
    "ingestion_run_id", "ingestion_timestamp", "src_busn_asst",
}

# Derived silver_s2-only columns: silver_table -> list of "EXPR AS name" appended
# to the MLV projection. Lets a table expose computed columns (e.g. a DATE cut
# from a TIMESTAMP) in silver_s2 WITHOUT storing them in silver_s1 or including
# them in the md5 hash. Add future exceptions here; most tables have none.
_SILVER_S2_DERIVED_COLUMNS = {
    "marketing_events": [
        "CAST(start_timestamp AS DATE) AS start_date",
        "CAST(end_timestamp AS DATE) AS end_date",
    ],
}


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Step functions
# One function per operation. Each takes what it needs and returns its result;
# the driver (Section 3) calls them in order. `meta` is a plain dictionary that
# carries the config resolved in step 1 to the later steps.
# ══════════════════════════════════════════════════════════════════════════════

def resolve_metadata():
    """Step 1 — read schema_config mappings and ingestion_config flags. Returns
    `meta`, a dict of everything later steps need."""
    logger.info("[1/10] Resolving metadata from JSON parameters")

    # ── schema_config → mappings + entity_name ───────────────────────────────
    schema_config_df = schema_config_df_from_json(p_schema_config_json)  # noqa: F821  # type: ignore[name-defined]
    mappings = (
        schema_config_df
        .filter(
            (F.lower(F.col("bronze_table_name")) == p_source_table.lower()) &
            (F.col("bronze_column_name") != "N/A")
        )
        .orderBy("ordinal_position")
        .collect()
    )
    if not mappings:
        raise ValueError(
            f"No schema_config mappings found for bronze_table_name='{p_source_table}'. "
            f"Ensure column mappings are registered with the correct bronze_table_name."
        )

    # ── ingestion_config → is_scd2, partition_cols, src_busn_asst ────────────
    ingestion_config_df = ingestion_config_df_from_json(p_ingestion_config_json)  # noqa: F821  # type: ignore[name-defined]
    ic_row = (
        ingestion_config_df
        .filter(F.lower(F.col("silver_table")) == p_target_table.lower())
        .limit(1)
        .collect()
    )
    ic = ic_row[0] if ic_row else None

    meta = {
        "mappings":       mappings,
        "entity_name":    mappings[0]["landing_table_name"],
        "is_scd2":        bool(ic["is_scd2"]) if ic and ic["is_scd2"] else False,
        "partition_cols": (
            [c.strip() for c in (ic["partition_by_column_names"] or "").split(",") if c.strip()]
            if ic else []
        ),
        "src_busn_asst":  ((ic["src_busn_asst"] or "").strip() or None) if ic else None,
    }

    logger.info(f"entity_name='{meta['entity_name']}' (bronze_table_name='{p_source_table}'), "
                f"mappings={len(meta['mappings'])}, is_scd2={meta['is_scd2']}, "
                f"partition_cols={meta['partition_cols'] or '(none)'}, "
                f"src_busn_asst={meta['src_busn_asst'] or '(none)'}")
    return meta


def read_bronze_source():
    """Step 2 — read bronze for this ingestion_date. Returns source_df (lazy).
    The row count is taken once, later, off the cached projected frame."""
    logger.info(f"[2/10] Reading bronze source: {qualified_source}")
    try:
        source_df = spark.table(qualified_source).filter(
            F.col("ingestion_date") == p_ingestion_date
        )
    except Exception as e:
        raise RuntimeError(
            f"Failed to read '{qualified_source}'. "
            f"Ensure lh_bronze is added to this notebook session.\n{e}"
        )
    return source_df


def swap_audit_columns(source_df, meta):
    """Step 3 — drop the bronze-run audit columns and add fresh silver-run ones."""
    logger.info("[3/10] Swapping audit columns (bronze -> silver-run)")
    drop_cols = [c for c in source_df.columns if c in _BRONZE_AUDIT_COLS]
    if drop_cols:
        source_df = source_df.drop(*drop_cols)
    source_df = add_audit_columns(  # noqa: F821  # type: ignore[name-defined]
        source_df,
        ingestion_date      = p_ingestion_date,
        data_timestamp      = p_ingestion_timestamp,
        source_system       = p_source_system,
        ingestion_run_id    = p_ingestion_run_id,
        ingestion_timestamp = p_ingestion_timestamp,
        src_busn_asst       = meta["src_busn_asst"],
    )
    logger.info(f"Replaced audit cols: {drop_cols or '(none found — added fresh)'}")
    return source_df


def deduplicate(source_df):
    """Step 4 — remove duplicate rows by md5_hash (lazy transform)."""
    logger.info("[4/10] Deduplicating on md5_hash")
    return deduplicate_by_md5(source_df, label=p_source_table, debug=p_debug)  # noqa: F821  # type: ignore[name-defined]


def cast_and_default(source_df, meta):
    """Step 5 — cast bronze columns to silver types and replace null/blank/junk."""
    logger.info("[5/10] Casting bronze -> silver types + defaults")
    source_df = cast_and_default_silver_columns(source_df, meta["mappings"])  # noqa: F821  # type: ignore[name-defined]
    logger.info(f"Silver cast + defaults: {len(meta['mappings'])} columns typed & non-null")
    return source_df


def project_columns(source_df, meta):
    """Step 6 — keep only mapped silver columns + system columns (drop leaked ones)."""
    logger.info("[6/10] Projecting to mapped silver + system columns")
    mapped = [m["silver_column_name"] for m in meta["mappings"]
              if m["silver_column_name"] and m["silver_column_name"] in source_df.columns]
    system = [c for c in source_df.columns if c in (_BRONZE_AUDIT_COLS | {"md5_hash"})]
    keep   = list(dict.fromkeys(mapped + system))
    source_df = source_df.select(*keep)
    logger.info(f"Projection: {len(mapped)} mapped + {len(system)} system column(s)")
    return source_df


def validate(source_df, meta):
    """Step 7 — run silver validation checks (raises on a CRITICAL failure)."""
    logger.info("[7/10] Validating silver load")
    validate_silver_load(source_df, meta["mappings"], p_target_table, p_ingestion_date)  # noqa: F821  # type: ignore[name-defined]


def write_silver(source_df, meta):
    """Step 8 — SCD2 merge or non-SCD append. Returns (rows_inserted, rows_updated)."""
    strategy = "SCD Type 2 (md5-only)" if meta["is_scd2"] else "SCD Type 1 (md5 insert-only)"
    logger.info(f"[8/10] Writing into {qualified_target}  [strategy: {strategy}]")
    merge_start = time.time()

    if meta["is_scd2"]:
        rows_inserted, rows_updated = apply_scd2(  # noqa: F821  # type: ignore[name-defined]
            spark                   = spark,
            source_df               = source_df,
            qualified_target        = qualified_target,
            effective_timestamp_val = p_ingestion_timestamp,
            partition_cols          = meta["partition_cols"],
            tbl_properties          = {"delta.enableChangeDataFeed": "true"},
            debug                   = p_debug,
        )
        logger.info(f"New records={rows_inserted}, Records expired={rows_updated}  "
                    f"(-1 = present but not counted; enable p_debug for exact)")
    else:
        # Non-SCD append: add is_current, partition by ingestion_date (+ config),
        # replaceWhere the ingestion_date slice so re-runs replace rather than dup.
        src = source_df.withColumn("is_current", F.lit(1).cast(IntegerType()))
        noscd_partition_cols = ["ingestion_date"] + [c for c in meta["partition_cols"] if c != "ingestion_date"]
        rows_inserted, rows_updated = apply_noscd(  # noqa: F821  # type: ignore[name-defined]
            spark             = spark,
            source_df         = src,
            qualified_target  = qualified_target,
            business_key_cols = ["md5_hash"],
            partition_cols    = noscd_partition_cols,
            tbl_properties    = {"delta.enableChangeDataFeed": "true"},
            replace_where     = f"ingestion_date = '{p_ingestion_date}'",
            debug             = p_debug,
        )
        logger.info(f"Rows loaded={rows_inserted} (replaceWhere ingestion_date={p_ingestion_date}; "
                    f"-1 = written but not counted)")

    logger.info(f"Merge duration: {round(time.time() - merge_start, 6)}s")
    return rows_inserted, rows_updated


def enforce_not_null(meta):
    """Step 9 — SET NOT NULL on is_nullable=0 silver columns (no-op if no table yet)."""
    logger.info("[9/10] Enforcing NOT NULL on is_nullable=0 columns")
    nn_cols = enforce_silver_not_null(spark, qualified_target, meta["mappings"])  # noqa: F821  # type: ignore[name-defined]
    logger.info(f"NOT NULL enforced: {len(nn_cols)} column(s)")


def verify_target():
    """Step 10 — count rows in the target table (operational only). Returns -1 when
    p_debug is False (count skipped)."""
    logger.info("[10/10] Verifying target")
    if not p_debug:
        logger.info("Target row count skipped (p_debug=False)")
        return -1
    count = (
        spark.table(qualified_target).count()
        if spark.catalog.tableExists(qualified_target) else 0
    )
    logger.info(f"Rows in {qualified_target}: {count:,}")
    return count


def refresh_silver_s2_mlv(meta):
    """Non-fatal tail — refresh/create the silver_s2 materialized lake view(s).
    silver_s1 already loaded; a stale/failed MLV is logged as a WARNING. Change the
    `logger.warning` in the except to `raise` to fail the pipeline activity instead."""
    logger.info(f"[MLV] Refreshing/creating silver_s2 materialized lake view(s) for '{p_target_table}'")
    if not spark.catalog.tableExists(qualified_target):
        logger.info(f"SKIP: '{qualified_target}' does not exist (no data loaded) — MLV refresh skipped.")
        return

    mlv_lh     = "lh_silver"
    mlv_schema = "silver_s2"
    base_cols  = spark.table(qualified_target).columns
    derived    = _SILVER_S2_DERIVED_COLUMNS.get(p_target_table, [])
    col_list   = ",\n               ".join(base_cols + derived)
    if derived:
        logger.info(f"Derived s2 cols: {', '.join(derived)}")

    if meta["is_scd2"]:
        mlv_targets = [
            (f"{mlv_lh}.{mlv_schema}.{p_target_table}_current", "WHERE is_current = 1"),
            (f"{mlv_lh}.{mlv_schema}.{p_target_table}_history", ""),
        ]
    else:
        mlv_targets = [(f"{mlv_lh}.{mlv_schema}.{p_target_table}", "")]

    try:
        for mlv_name, mlv_where in mlv_targets:
            status = ensure_mlv_and_refresh(  # noqa: F821  # type: ignore[name-defined]
                spark        = spark,
                view_name    = mlv_name,
                source_ref   = qualified_target,
                col_list     = col_list,
                where_clause = mlv_where,
            )
            logger.info(f"{status.upper():<9} {mlv_name}")
    except Exception as mlv_exc:
        logger.warning(f"MLV refresh/create failed for '{p_target_table}': {mlv_exc}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Driver
# Runs the steps in order. One try/except: on any failure, log it and re-raise so
# the pipeline marks the activity as failed. The 0-row skip is a plain `if`.
#
# Performance: the transformed frame is cached ONCE (persist) and counted ONCE.
# That single count materialises the read->dedup->cast->project chain, and both
# validate() and write_silver() then read the cached data instead of recomputing
# the whole chain per action. The cache is released after the write.
# ══════════════════════════════════════════════════════════════════════════════

logger.info("=" * 55)
logger.info("nb_silver_s1_ingestion_v2 — START")
logger.info(f"source={qualified_source} | target={qualified_target} | "
            f"ingestion_date={p_ingestion_date} | run_id={p_ingestion_run_id}")

rows_inserted    = 0
rows_updated     = 0
source_row_count = 0
target_row_count = 0
meta             = None
source_df        = None

try:
    meta = resolve_metadata()

    source_df = read_bronze_source()
    source_df = swap_audit_columns(source_df, meta)
    source_df = deduplicate(source_df)
    source_df = cast_and_default(source_df, meta)
    source_df = project_columns(source_df, meta)

    # Cache the fully-transformed frame. The 0-row skip is driven by a cheap
    # existence check (take(1)); the exact source count is operational only, so it
    # is taken solely in debug. Either way one full materialisation of the source
    # chain occurs (existence check or the first validate/write action), and
    # validate() / write_silver() reuse the cached data.
    source_df = source_df.persist()
    source_has_rows  = bool(source_df.take(1))
    source_row_count = source_df.count() if p_debug else (-1 if source_has_rows else 0)
    logger.info(f"Source has rows: {source_has_rows}"
                + (f" | count={source_row_count:,}" if p_debug else " (exact count skipped, p_debug=False)"))
    if not source_has_rows:
        logger.warning(f"No source rows for ingestion_date={p_ingestion_date} — "
                       f"silver table will not be updated.")

    if source_has_rows:
        validate(source_df, meta)
        rows_inserted, rows_updated = write_silver(source_df, meta)
    else:
        logger.info(f"[7-8/10] Validate + write SKIPPED — 0 source rows for "
                    f"ingestion_date={p_ingestion_date}. Silver table left unchanged.")

    # Done reading source_df — release the cache before the target-side steps.
    source_df.unpersist()

    enforce_not_null(meta)
    target_row_count = verify_target()

    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_silver_s1_ingestion_v2",
        table_name     = qualified_target,
        operation_type = "MERGE",
        # Row counts are -1 when p_debug is False (operational counts skipped).
        rows_before    = (target_row_count - rows_inserted) if p_debug else -1,
        rows_after     = target_row_count if p_debug else -1,
        execution_time = round(time.time() - _notebook_start, 6),
        message        = (
            f"source={qualified_source} | entity={meta['entity_name']} | "
            f"inserted={rows_inserted} | updated={rows_updated} | "
            f"debug={p_debug} | run_id={p_ingestion_run_id}"
        ),
    )

    logger.info("=" * 55)
    logger.info("nb_silver_s1_ingestion_v2 — COMPLETE")
    logger.info(f"source={qualified_source} | target={qualified_target} | "
                f"entity={meta['entity_name']}")
    logger.info(f"source_rows={source_row_count} | rows_inserted={rows_inserted} | "
                f"rows_updated={rows_updated} | target_total={target_row_count} | "
                f"debug={p_debug} | run_id={p_ingestion_run_id}  "
                f"(-1 = not counted; set p_debug=True for exact figures)")
    logger.info("=" * 55)

except Exception as _exc:
    logger.error(f"FAILED — source={p_source_table} | run_id={p_ingestion_run_id} | {_exc}")
    # Best-effort cache release on failure.
    try:
        if source_df is not None:
            source_df.unpersist()
    except Exception:
        pass
    log_fabric_operation(  # noqa: F821  # type: ignore[name-defined]
        notebook_name  = "nb_silver_s1_ingestion_v2",
        table_name     = qualified_target,
        operation_type = "MERGE",
        rows_before    = 0,
        rows_after     = 0,
        execution_time = round(time.time() - _notebook_start, 6),
        error_message  = str(_exc),
        message        = f"FAILED | source={p_source_table} | run_id={p_ingestion_run_id}",
    )
    raise


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Silver S2 materialized lake view(s)  (non-fatal, runs after success)
# ══════════════════════════════════════════════════════════════════════════════

refresh_silver_s2_mlv(meta)
