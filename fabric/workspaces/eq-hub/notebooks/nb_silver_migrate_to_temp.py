#!/usr/bin/env python
# coding: utf-8

# ## nb_silver_migrate_to_temp
#
# One-time migration notebook.

# In[ ]:


# The command is not a standard IPython magic command. It is designed for use within Fabric notebooks only.
# %run nb_utils.py


# In[ ]:


# Notebook: nb_silver_migrate_to_temp
# Layer:    Silver S1  (one-time migration utility)
# Purpose:  Backfill an existing silver table into a NEW typed "_temp" table.
#           Reads every row from the source (old) silver table, casts each
#           mapped column to its silver_data_type, replaces NULL / blank / junk
#           values with the schema_config default_value, then (re)creates the
#           target _temp table and enforces NOT NULL on is_nullable = 0 columns.
#
#           This is the data-migration half of the cut-over strategy:
#             1. run silver ingestion into <table>_temp for one day (verify),
#             2. run THIS notebook to backfill history from <table> -> <table>_temp,
#             3. drop the original <table> and rename <table>_temp -> <table>.
#
#           Reuses the exact same transform used by nb_silver_s1_ingestion
#           (cast_and_default_silver_columns + enforce_silver_not_null) so the
#           migrated data is identical in shape to fresh ingestion.
#
# Idempotent: the target _temp table is dropped and recreated on every run.
#
# Pre-requisites:
#   - Attach lh_silver as the default lakehouse (or set p_silver_lakehouse).
#   - schema_config JSON must contain mappings whose silver_table_name matches
#     the target _temp table (falls back to the source name if not found).

import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("nb_silver_migrate_to_temp").getOrCreate()
# Legacy (pre-Gregorian) date/timestamp handling for old Parquet files:
#   read  LEGACY    — interpret legacy-calendar values written by older writers
#   write CORRECTED — persist in the Proleptic Gregorian calendar
# int96 covers the older INT96 timestamp encoding, which raises the same
# rebase error separately from the datetime one.
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.datetimeRebaseModeInRead", "LEGACY")
spark.conf.set("spark.sql.parquet.int96RebaseModeInWrite", "CORRECTED")
spark.conf.set("spark.sql.parquet.int96RebaseModeInRead", "LEGACY")

_notebook_start = time.time()


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

p_source_silver_table = ""   # REQUIRED — existing silver table, e.g. "territory"
p_schema_config_json  = ""   # REQUIRED — full schema_config JSON array
p_silver_lakehouse    = "lh_silver"    # lakehouse holding both tables
p_silver_schema       = "silver_s1"    # schema holding both tables

_required = {
    "p_source_silver_table" : p_source_silver_table,
    "p_schema_config_json"  : p_schema_config_json,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

# Target is always the source table with a _temp suffix.
p_target_silver_table = f"{p_source_silver_table}_temp"

qualified_source = f"{p_silver_lakehouse}.{p_silver_schema}.{p_source_silver_table}"
qualified_target = f"{p_silver_lakehouse}.{p_silver_schema}.{p_target_silver_table}"

print("=" * 65)
print("  nb_silver_migrate_to_temp — START")
print("=" * 65)
print(f"  source (old)   : {qualified_source}")
print(f"  target (temp)  : {qualified_target}")
print("=" * 65)


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Resolve column mappings from schema_config JSON
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/5] Resolving schema_config mappings")

schema_config_df = schema_config_df_from_json(p_schema_config_json)  # noqa: F821  # type: ignore[name-defined]

# schema_config.silver_table_name is keyed to the temp table during cut-over.
# Filter on the target name; fall back to the source name for flexibility.
mappings = (
    schema_config_df
    .filter(F.lower(F.col("silver_table_name")) == p_target_silver_table.lower())
    .orderBy("ordinal_position")
    .collect()
)
if not mappings:
    mappings = (
        schema_config_df
        .filter(F.lower(F.col("silver_table_name")) == p_source_silver_table.lower())
        .orderBy("ordinal_position")
        .collect()
    )
if not mappings:
    raise ValueError(
        f"No schema_config mappings found for silver_table_name "
        f"'{p_target_silver_table}' or '{p_source_silver_table}'."
    )

print(f"  Column mappings : {len(mappings)}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Read the source (old) silver table
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/5] Reading source: {qualified_source}")

if not spark.catalog.tableExists(qualified_source):
    raise RuntimeError(f"Source table '{qualified_source}' does not exist.")

source_df    = spark.table(qualified_source)
source_count = source_df.count()
print(f"  Source rows : {source_count:,}")

# Non-mapped columns (audit / md5_hash / SCD2 structural cols) are carried
# through unchanged; only mapped columns are cast + defaulted below.
_mapped_cols   = {row["silver_column_name"] for row in mappings}
_passthrough   = [c for c in source_df.columns if c not in _mapped_cols]
_missing_in_src = [c for c in _mapped_cols if c not in source_df.columns]
print(f"  Passthrough cols : {_passthrough}")
if _missing_in_src:
    print(f"  NOTE: {len(_missing_in_src)} mapped column(s) absent in source — "
          f"will be created from defaults: {sorted(_missing_in_src)}")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Cast to silver types + replace NULL/blank/junk with defaults
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/5] Casting + applying defaults ({len(mappings)} columns)")

migrated_df = cast_and_default_silver_columns(source_df, mappings)  # noqa: F821  # type: ignore[name-defined]

# Validate the transformed frame the same way fresh silver loads are validated.
validate_silver_load(migrated_df, mappings, qualified_target, "MIGRATION")  # noqa: F821  # type: ignore[name-defined]


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Drop + recreate the target _temp table, then enforce NOT NULL
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[4/5] (Re)creating {qualified_target}")

# Always start fresh. A previous run may have failed mid-write and left a
# partially-written table behind, so drop it and verify the drop actually took
# effect before recreating — otherwise stale rows could survive into this load.
_target_existed = spark.catalog.tableExists(qualified_target)
try:
    spark.sql(f"DROP TABLE IF EXISTS {qualified_target}")
except Exception as _drop_exc:
    raise RuntimeError(
        f"Could not drop '{qualified_target}' left over from a previous run. "
        f"Drop it manually and re-run.\n{_drop_exc}"
    )
if spark.catalog.tableExists(qualified_target):
    raise RuntimeError(
        f"'{qualified_target}' still exists after DROP — cannot guarantee a fresh load."
    )
print(f"  Dropped : {qualified_target} "
      f"({'existed — recreated fresh' if _target_existed else 'did not exist'})")

# Partition the _temp table by ingestion_date to match fresh silver ingestion
# (non-SCD2 tables are ingestion_date-partitioned). Skip if the migrated frame
# has no ingestion_date column.
_migrate_partition_cols = ["ingestion_date"] if "ingestion_date" in migrated_df.columns else None
print(f"  Partition by : {_migrate_partition_cols or '(none — ingestion_date absent)'}")

write_delta_create(  # noqa: F821  # type: ignore[name-defined]
    df               = migrated_df,
    qualified_target = qualified_target,
    partition_cols   = _migrate_partition_cols,
    tbl_properties   = {"delta.enableChangeDataFeed": "true"},
)

_nn_cols = enforce_silver_not_null(spark, qualified_target, mappings)  # noqa: F821  # type: ignore[name-defined]
print(f"  NOT NULL enforced : {len(_nn_cols)} column(s)")


# In[ ]:


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — Verify + summary
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[5/5] Verifying target")
target_count = spark.table(qualified_target).count()
_elapsed     = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_silver_migrate_to_temp — COMPLETE")
print(f"  source (old)     : {qualified_source}")
print(f"  target (temp)    : {qualified_target}")
print(f"  source_rows      : {source_count:,}")
print(f"  target_rows      : {target_count:,}")
print(f"  NOT NULL columns : {len(_nn_cols)}")
print(f"  Elapsed          : {_elapsed}s")
print("=" * 65)

if target_count != source_count:
    print(f"  WARNING: row count mismatch (source={source_count:,}, target={target_count:,})")

mssparkutils.notebook.exit("OK")  # noqa: F821  # type: ignore[name-defined]
