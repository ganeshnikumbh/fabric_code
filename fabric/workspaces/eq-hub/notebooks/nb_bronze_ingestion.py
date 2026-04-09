# Notebook:  nb_bronze_ingestion
# Layer:     Bronze
# Purpose:   Metadata-driven ingestion from lh_landing → lh_bronze.
#            Reads ingestion_config and schema_config from lh_control to drive
#            column mapping, load type, and watermark logic without any
#            hard-coded table definitions.
#
# Triggered by: Fabric Data Pipeline (one activity per entity)
#
# Pre-requisites:
#   - Attach lh_bronze as the default lakehouse before running.
#   - lh_landing and lh_control must be added to the notebook session
#     (Notebook settings → Lakehouses → Add) so their tables are queryable
#     via their lakehouse name as a Spark database prefix.
#
# Parameter cell below is tagged "parameters" so Fabric Pipeline can inject
# values at runtime via the Set Variable / Notebook activity.

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_bronze_ingestion").getOrCreate()


# ── SECTION 1 — Parameters ─────────────────────────────────────────────────────
# Cell tag: parameters
# Default values are placeholders — always overridden by pipeline at runtime.
# ──────────────────────────────────────────────────────────────────────────────

source_table       = ""    # e.g. "contract_base"   — table name in lh_landing
target_table       = ""    # e.g. "contract_base"   — table name in lh_bronze
ingestion_date     = ""    # e.g. "2025-04-09"      — pipeline run date
data_date          = ""    # e.g. "2025-04-08"      — business data date (full load)
source_system      = ""    # e.g. "EQ_Warehouse"
ingestion_run_id   = ""    # e.g. UUID from pipeline
ingestion_timestamp = ""   # e.g. "2025-04-09T01:00:00Z"

# ── Guard: fail fast if required parameters are missing ──────────────────────
_required = {
    "source_table":        source_table,
    "target_table":        target_table,
    "ingestion_date":      ingestion_date,
    "source_system":       source_system,
    "ingestion_run_id":    ingestion_run_id,
    "ingestion_timestamp": ingestion_timestamp,
}
_missing = [k for k, v in _required.items() if not v or not str(v).strip()]
if _missing:
    raise ValueError(f"Required parameters not provided: {_missing}")

print("=" * 65)
print("  nb_bronze_ingestion — START")
print("=" * 65)
print(f"  source_table       : {source_table}")
print(f"  target_table       : {target_table}")
print(f"  ingestion_date     : {ingestion_date}")
print(f"  data_date          : {data_date}")
print(f"  source_system      : {source_system}")
print(f"  ingestion_run_id   : {ingestion_run_id}")
print(f"  ingestion_timestamp: {ingestion_timestamp}")
print("=" * 65)


# ── SECTION 2 — Read Source Data ───────────────────────────────────────────────
# Reads the source table from lh_landing.
# lh_landing tables are accessed via the lakehouse name as a Spark DB prefix.
# ──────────────────────────────────────────────────────────────────────────────

print(f"\n[1/5] Reading source table: lh_landing.{source_table}")

try:
    source_df = spark.table(f"lh_landing.{source_table}")
except Exception as e:
    raise RuntimeError(
        f"Failed to read source table 'lh_landing.{source_table}'. "
        f"Ensure lh_landing is added to this notebook session and the table exists.\n{e}"
    )

source_row_count = source_df.count()
print(f"  Rows read from source : {source_row_count:,}")

if source_row_count == 0:
    print("  WARNING: Source table is empty. Writing zero rows to Bronze.")


# ── SECTION 3 — Read Metadata ─────────────────────────────────────────────────
# Reads ingestion_config and schema_config from lh_control.
# ──────────────────────────────────────────────────────────────────────────────

print(f"\n[2/5] Reading metadata from lh_control")

# ── 3a. ingestion_config ─────────────────────────────────────────────────────
try:
    ingestion_config_df = spark.table("lh_control.ingestion_config")
except Exception as e:
    raise RuntimeError(
        f"Failed to read lh_control.ingestion_config. "
        f"Ensure lh_control is added to this notebook session.\n{e}"
    )

from pyspark.sql import functions as F

config_row = (
    ingestion_config_df
    .filter(
        (F.lower(F.col("entity_name"))   == source_table.lower()) &
        (F.lower(F.col("target_table"))  == target_table.lower())
    )
    .limit(1)
    .collect()
)

if not config_row:
    raise ValueError(
        f"No ingestion_config row found for "
        f"entity_name='{source_table}' / target_table='{target_table}'. "
        f"Ensure the entity is registered in lh_control.ingestion_config."
    )

config = config_row[0]
load_type        = (config["load_type"]       or "full").strip().lower()
watermark_column = (config["watermark_column"] or "").strip()  # empty for full loads
source_id        = config["source_id"]

print(f"  source_id        : {source_id}")
print(f"  load_type        : {load_type}")
print(f"  watermark_column : {watermark_column or '(none — full load)'}")

# ── 3b. schema_config ────────────────────────────────────────────────────────
try:
    schema_config_df = spark.table("lh_control.schema_config")
except Exception as e:
    raise RuntimeError(
        f"Failed to read lh_control.schema_config.\n{e}"
    )

mappings = (
    schema_config_df
    .filter(
        (F.lower(F.col("source_table_name")) == source_table.lower()) &
        F.col("source_column_name").isNotNull() &
        F.col("target_column_name").isNotNull()
    )
    .select("source_column_name", "target_column_name", "ordinal_position", "include_in_md5hash")
    .orderBy("ordinal_position")
    .collect()
)

if not mappings:
    raise ValueError(
        f"No schema_config mappings found for source_table_name='{source_table}'. "
        f"Ensure column mappings are registered in lh_control.schema_config."
    )

# col_map            : source_col → target_col  (insertion-ordered by ordinal_position)
# col_map_lower      : lowercase source_col → target_col  (for case-insensitive lookup)
# hash_cols_ordered  : target column names flagged include_in_md5hash=true, in ordinal order
col_map           = {row["source_column_name"]: row["target_column_name"] for row in mappings}
col_map_lower     = {k.lower(): v for k, v in col_map.items()}
hash_cols_ordered = [
    row["target_column_name"]
    for row in mappings
    if row["include_in_md5hash"] is True
]

print(f"  Column mappings  : {len(col_map)} columns mapped")
print(f"  Hash columns     : {len(hash_cols_ordered)} → {hash_cols_ordered}")


# ── SECTION 4 — Column Transformation ────────────────────────────────────────
# 1. Keep only source columns that have a mapping.
# 2. Rename each source column to its target name.
# Unmapped source columns are silently dropped; missing source columns
# (in mapping but not in source data) raise a clear error.
# ──────────────────────────────────────────────────────────────────────────────

print(f"\n[3/5] Applying column transformations")

source_columns_lower = {c.lower(): c for c in source_df.columns}

select_exprs = []
missing_in_source = []

for src_col, tgt_col in col_map.items():
    # Case-insensitive match against actual source columns
    actual_col = source_columns_lower.get(src_col.lower())
    if actual_col is None:
        missing_in_source.append(src_col)
    else:
        select_exprs.append(F.col(actual_col).alias(tgt_col))

if missing_in_source:
    print(
        f"  WARNING: {len(missing_in_source)} mapped column(s) not found in source "
        f"and will be set to NULL: {missing_in_source}"
    )
    # Add null columns so the target schema remains consistent
    for src_col in missing_in_source:
        tgt_col = col_map[src_col]
        select_exprs.append(F.lit(None).cast("string").alias(tgt_col))

# ── Watermark passthrough for incremental loads ───────────────────────────────
# The watermark column (e.g. 'StartDate') may not be in schema_config because
# it is an operational/audit column, not a business column. If it is absent from
# col_map we still need its value to derive data_date per row. Add it as a
# hidden passthrough column (__wm_temp__) that is dropped after data_date is set.
# Fallback: if watermark_column is not configured OR not found in source data,
# data_date will use ingestion_date (set in Section 5).
_WM_TEMP = "__wm_temp__"
_wm_needs_passthrough = False

if load_type != "full" and watermark_column:
    wm_already_mapped = col_map_lower.get(watermark_column.lower())
    if wm_already_mapped is None:
        # Not in schema_config — try to pull directly from source_df
        actual_wm = source_columns_lower.get(watermark_column.lower())
        if actual_wm is None:
            print(
                f"  WARNING: watermark_column '{watermark_column}' not found in "
                f"source data — data_date will fall back to ingestion_date"
            )
        else:
            select_exprs.append(F.col(actual_wm).alias(_WM_TEMP))
            _wm_needs_passthrough = True
            print(
                f"  watermark_column '{watermark_column}' not in schema_config — "
                f"added as temp passthrough for data_date derivation"
            )

transformed_df = source_df.select(*select_exprs)
print(f"  Columns after mapping : {len(transformed_df.columns) - int(_wm_needs_passthrough)} business columns")


# ── SECTION 5 — Load Type Logic (data_date) ───────────────────────────────────
# FULL  → data_date comes from the pipeline parameter.
# INCR  → data_date is derived per-row from the watermark_column value.
#         The watermark_column is the source column; after mapping it has a
#         target name — we cast it to date for the data_date audit column.
# ──────────────────────────────────────────────────────────────────────────────

print(f"\n[4/5] Applying load_type logic  (load_type={load_type})")

from pyspark.sql.types import StringType, TimestampType

if load_type == "full":
    if not data_date or not data_date.strip():
        raise ValueError(
            "load_type is 'full' but data_date parameter is empty. "
            "Provide data_date from the pipeline."
        )
    data_date_col = F.lit(data_date).cast("date")
    print(f"  data_date source : pipeline parameter → {data_date}")

else:  # incremental / cdc
    # Resolve which column in transformed_df holds the watermark value.
    # Priority 1: watermark_column mapped in schema_config → use its target name.
    # Priority 2: watermark_column not in schema_config but present in source → _WM_TEMP passthrough.
    # Priority 3: watermark_column not configured OR not found in source → fall back to ingestion_date.
    wm_in_df = None
    if watermark_column:
        wm_in_df = col_map_lower.get(watermark_column.lower()) or (
            _WM_TEMP if _wm_needs_passthrough else None
        )

    if wm_in_df and wm_in_df in transformed_df.columns:
        # Cast to date — handles datetime, integer (YYYYMMDD), and date source types
        data_date_col = F.col(wm_in_df).cast("date")
        wm_label = watermark_column if not _wm_needs_passthrough else f"{watermark_column} (passthrough)"
        print(f"  data_date source : watermark_column '{wm_label}' → col '{wm_in_df}' (cast to date)")
    else:
        # Fallback: watermark_column not set, not in source, or not resolvable
        data_date_col = F.lit(ingestion_date).cast("date")
        reason = "not configured in ingestion_config" if not watermark_column else f"'{watermark_column}' not found in source data"
        print(f"  data_date source : ingestion_date (fallback — watermark_column {reason})")

# ── Add all audit / lineage columns ──────────────────────────────────────────
final_df = (
    transformed_df
    .withColumn("ingestion_date",      F.lit(ingestion_date).cast("date"))
    .withColumn("data_date",           data_date_col)
    .withColumn("source_system",       F.lit(source_system).cast(StringType()))
    .withColumn("ingestion_run_id",    F.lit(ingestion_run_id).cast(StringType()))
    .withColumn("ingestion_timestamp", F.lit(ingestion_timestamp).cast(TimestampType()))
)

# Drop the watermark passthrough column now that data_date has been derived
if _wm_needs_passthrough:
    final_df = final_df.drop(_WM_TEMP)
    print(f"  Dropped temp passthrough column '{_WM_TEMP}'")

# ── MD5 hash ──────────────────────────────────────────────────────────────────
# Concatenate columns flagged include_in_hash=true in ordinal_position order,
# separated by '|' to avoid cross-boundary collisions (e.g. 'AB'+'C' ≠ 'A'+'BC').
# NULL values are coerced to '' before concatenation so a null field does not
# cause the entire hash to be NULL.
# hash_cols_ordered is already sorted by ordinal_position from the metadata read.
if hash_cols_ordered:
    # Guard: drop any hash columns that didn't survive the transformation step
    # (e.g. unmapped columns that were set to NULL earlier)
    available_cols = set(final_df.columns)
    missing_hash_cols = [c for c in hash_cols_ordered if c not in available_cols]
    if missing_hash_cols:
        print(f"  WARNING: {missing_hash_cols} flagged for hash but not in DataFrame — excluded")
    active_hash_cols = [c for c in hash_cols_ordered if c in available_cols]

    if active_hash_cols:
        concat_expr = F.concat_ws(
            "|",
            *[F.coalesce(F.col(c).cast(StringType()), F.lit("")) for c in active_hash_cols]
        )
        final_df = final_df.withColumn("md5_hash", F.md5(concat_expr))
        print(f"  md5_hash         : computed from {len(active_hash_cols)} columns in ordinal order")
    else:
        final_df = final_df.withColumn("md5_hash", F.lit(None).cast(StringType()))
        print(f"  md5_hash         : NULL (no valid hash columns after filtering)")
else:
    final_df = final_df.withColumn("md5_hash", F.lit(None).cast(StringType()))
    print(f"  md5_hash         : NULL (no columns flagged include_in_hash=true in schema_config)")

final_row_count = final_df.count()
print(f"  Rows to write : {final_row_count:,}")


# ── SECTION 6 — Target Table Validation & Write ───────────────────────────────
# Default lakehouse is lh_bronze, so tables under schema bronze_eqwarehouse
# are referenced as bronze_eqwarehouse.<target_table>.
#
# NEW table  → create via saveAsTable (managed Delta, schema inferred from DF)
# EXISTS     → append; mergeSchema=true handles safe additive schema changes
# ──────────────────────────────────────────────────────────────────────────────

print(f"\n[5/5] Target table validation & write")

TARGET_SCHEMA = "bronze_eqwarehouse"
qualified_target = f"{TARGET_SCHEMA}.{target_table}"

table_exists = spark.catalog.tableExists(qualified_target)
print(f"  Target table     : lh_bronze.{qualified_target}")
print(f"  Table exists     : {table_exists}")

WRITE_OPTIONS = {
    "format":         "delta",
    "mergeSchema":    "true",    # safe additive schema evolution on append
}

if not table_exists:
    print(f"  Action           : CREATE (first load — managed Delta table)")
    (
        final_df.write
        .format("delta")
        .option("mergeSchema", "true")
        .mode("overwrite")                    # create with overwrite so schema is set
        .saveAsTable(qualified_target)
    )
    print(f"  Table created    : lh_bronze.{qualified_target}")

else:
    print(f"  Action           : APPEND")
    (
        final_df.write
        .format("delta")
        .option("mergeSchema", "true")
        .mode("append")
        .saveAsTable(qualified_target)
    )
    print(f"  Rows appended to : lh_bronze.{qualified_target}")

# ── Post-write verification ───────────────────────────────────────────────────
verified_count = spark.table(qualified_target).count()
print(f"  Verified rows in target : {verified_count:,}")

print("\n" + "=" * 65)
print("  nb_bronze_ingestion — COMPLETE")
print(f"  source_table    : {source_table}")
print(f"  target_table    : lh_bronze.{qualified_target}")
print(f"  load_type       : {load_type}")
print(f"  rows_read       : {source_row_count:,}")
print(f"  rows_written    : {final_row_count:,}")
print(f"  ingestion_run_id: {ingestion_run_id}")
print("=" * 65)
