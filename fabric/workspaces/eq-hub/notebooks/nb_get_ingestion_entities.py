# Notebook: nb_get_ingestion_entities
# Purpose:  Reads control metadata from Fabric SQL DB and returns a JSON string
#           via mssparkutils.notebook.exit() for use in pipeline ForEach activities.
#           Returns either ingestion_config or schema_config rows for a given source_name.
#
# Why this notebook exists:
#   Fabric Pipeline Lookup activity does not support Fabric SQL DB as a source.
#   This notebook bridges that gap — called once by the pipeline Notebook activity,
#   the exit value is consumed by a ForEach or Set Variable activity downstream.
#
# Pipeline wiring:
#   Notebook activity   : nb_get_ingestion_entities
#   Parameters          : p_jdbc_url, p_source_name, p_config_type
#   Read exit value     : @activity('nb_get_ingestion_entities').output.result.exitValue
#   ForEach items       : @json(activity('nb_get_ingestion_entities').output.result.exitValue)
#
# ── p_config_type = "ingestion_config" ────────────────────────────────────────
#   Returns active rows from dbo.ingestion_config filtered by source_name.
#
#   Output shape per item:
#   {
#     "source_id"       : 14,
#     "source_name"     : "EQ_Warehouse",
#     "source_table"    : "Client",
#     "target_table"    : "client_base",
#     "target_schema"   : "bronze_eqwarehouse",
#     "load_type"       : "incremental",
#     "watermark_column": "StartDate",
#     "watermark_type"  : "datetime",
#     "batch_size"      : 50000
#   }
#
# ── p_config_type = "schema_config" ───────────────────────────────────────────
#   Returns active column mappings from dbo.schema_config filtered by source_name.
#
#   Output shape per item:
#   {
#     "source_name"        : "EQ_Warehouse",
#     "source_table_name"  : "Client",
#     "source_column_name" : "ContractPK",
#     "target_column_name" : "contract_id",
#     "target_data_type"   : "INT",
#     "ordinal_position"   : 1,
#     "include_in_md5hash" : 1
#   }

from pyspark.sql import SparkSession
import json

spark = SparkSession.builder.appName("nb_get_ingestion_entities").getOrCreate()

%run nb_utils


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# ══════════════════════════════════════════════════════════════════════════════

p_jdbc_url    = ""                  # REQUIRED — Fabric SQL DB JDBC connection string
p_source_name = ""                  # REQUIRED — e.g. "EQ_Warehouse"
p_config_type = "ingestion_config"  # REQUIRED — "ingestion_config" | "schema_config"

# ── Guards ────────────────────────────────────────────────────────────────────
if not p_jdbc_url or not p_jdbc_url.strip():
    raise ValueError("Parameter 'p_jdbc_url' is required.")

if not p_source_name or not p_source_name.strip():
    raise ValueError("Parameter 'p_source_name' is required.")

_valid_config_types = {"ingestion_config", "schema_config"}
if p_config_type.strip().lower() not in _valid_config_types:
    raise ValueError(
        f"Parameter 'p_config_type' must be one of {_valid_config_types}. "
        f"Got: '{p_config_type}'"
    )

p_source_name = p_source_name.strip()
p_config_type = p_config_type.strip().lower()

print("=" * 65)
print("  nb_get_ingestion_entities — START")
print("=" * 65)
print(f"  p_source_name  : {p_source_name}")
print(f"  p_config_type  : {p_config_type}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Fetch and serialise based on p_config_type
# ══════════════════════════════════════════════════════════════════════════════

output_json = "[]"

# ── Branch A: ingestion_config ────────────────────────────────────────────────
if p_config_type == "ingestion_config":

    print(f"\n[1/1] Reading dbo.ingestion_config for source_name='{p_source_name}' ...")

    ingestion_df = get_ingestion_config_by_source(p_jdbc_url, p_source_name)  # noqa: F821 — injected by %run nb_utils
    rows = ingestion_df.collect()
    print(f"  Rows returned : {len(rows)}")

    if not rows:
        print(f"  WARNING: No active entities found for source_name='{p_source_name}'. Returning empty JSON array.")
    else:
        output_json = json.dumps(
            [
                {
                    "source_id"        : int(row["source_id"]),
                    "source_name"      : str(row["source_name"]),
                    "source_table"     : str(row["entity_name"]),
                    "source_schema"    : str(row["source_schema"]) if row["source_schema"] else "",
                    "target_table"     : str(row["target_table"]),
                    "target_schema"    : str(row["target_schema"]),
                    "load_type"        : str(row["load_type"]),
                    "watermark_column" : str(row["watermark_column"]) if row["watermark_column"] else "",
                    "watermark_type"   : str(row["watermark_type"])   if row["watermark_type"]   else "",
                    "batch_size"       : int(row["batch_size"])        if row["batch_size"]       else 0,
                }
                for row in rows
            ],
            ensure_ascii=False
        )

# ── Branch B: schema_config ───────────────────────────────────────────────────
elif p_config_type == "schema_config":

    print(f"\n[1/1] Reading dbo.schema_config for source_name='{p_source_name}' ...")

    schema_df = get_schema_config_by_source(p_jdbc_url, p_source_name)  # noqa: F821 — injected by %run nb_utils
    rows = schema_df.collect()
    print(f"  Rows returned : {len(rows)}")

    if not rows:
        print(f"  WARNING: No schema_config mappings found for source_name='{p_source_name}'. Returning empty JSON array.")
    else:
        output_json = json.dumps(
            [
                {
                    "source_name"        : str(row["source_name"]),
                    "source_table_name"  : str(row["source_table_name"]),
                    "source_column_name" : str(row["source_column_name"]),
                    "target_column_name" : str(row["target_column_name"]),
                    "target_data_type"   : str(row["target_data_type"]),
                    "ordinal_position"   : int(row["ordinal_position"]),
                    "include_in_md5hash" : int(row["include_in_md5hash"]) if row["include_in_md5hash"] is not None else 0,
                }
                for row in rows
            ],
            ensure_ascii=False
        )


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Exit
# ══════════════════════════════════════════════════════════════════════════════

item_count = len(json.loads(output_json))
print(f"\n  Serialised {item_count} items → {len(output_json):,} chars")
print("\n" + "=" * 65)
print("  nb_get_ingestion_entities — COMPLETE")
print("=" * 65)

# Pipeline reads this via:
#   @activity('nb_get_ingestion_entities').output.result.exitValue
mssparkutils.notebook.exit(output_json)
