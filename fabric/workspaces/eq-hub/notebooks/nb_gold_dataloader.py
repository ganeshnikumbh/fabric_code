# Notebook: nb_gold_dataloader
# Layer:    Gold
# Purpose:  Single entry-point notebook for all Gold layer loads.
#           Reads three JSON config files (extract, transform, load) from a
#           shared base path, then orchestrates the full ETL pipeline via
#           GoldLoader (defined in nb_utils).
#
# Pipeline flow:
#   1. Read and parse extract_config, transform_config, load_config from JSON.
#   2. Instantiate GoldLoader(spark).
#   3. extract_df  = loader.extract(extract_config)
#   4. transformed = loader.transform(extract_df, transform_config)
#   5. loader.load(transformed, target_table, is_scd2, business_key_cols,
#                  surrogate_key_col, hash_col)
#   6. Print success summary.
#
# Config JSON schemas
# ───────────────────
# extract_config (agent_extract.json):
#   { "query_type": "extract", "query_string": "SELECT ..." }
#
# transform_config (agent_transform.json):
#   { "query_type": "transform",
#     "<step>": { "utility_function": "<name>", "parameters": [...] }, ... }
#
# load_config (agent_load.json):
#   { "query_type"      : "load",
#     "target_table"    : "lh_gold.gold.dim_agent",
#     "business_key_col": ["agent_id"],
#     "surrogate_key_col": "agent_key",
#     "is_scd2"         : true,
#     "hash_col"        : "md5_hash" }
#
# Pipeline / manual run:
#   Notebook activity   : nb_gold_dataloader
#   Parameters          : config_base_path, extract_config, transform_config, load_config
#   Default lakehouse   : lh_gold
#
# Pre-requisites:
#   - Attach lh_gold as the default lakehouse before running.
#   - lh_silver must be added to the notebook session if extract queries reference it.
#   - Config JSON files must exist at config_base_path/<filename>.

import json
import logging
import time

from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("nb_gold_dataloader").getOrCreate()

%run nb_utils.py

_notebook_start = time.time()
_logger         = logging.getLogger("nb_gold_dataloader")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parameters
# Cell tag: parameters — Fabric Pipeline injects values at runtime.
# ══════════════════════════════════════════════════════════════════════════════

config_base_path = ""   # REQUIRED — base folder where JSON configs are stored
                        #            e.g. "Files/config/gold/dim_agent"
extract_config   = ""   # REQUIRED — extract JSON filename, e.g. "agent_extract.json"
transform_config = ""   # REQUIRED — transform JSON filename, e.g. "agent_transform.json"
load_config      = ""   # REQUIRED — load JSON filename,    e.g. "agent_load.json"

_required = {
    "config_base_path": config_base_path,
    "extract_config":   extract_config,
    "transform_config": transform_config,
    "load_config":      load_config,
}
validate_required_params(_required)  # noqa: F821  # type: ignore[name-defined]

# Derive a display-friendly entity name from the extract config filename
# (strips the filename suffix, e.g. "agent_extract.json" → "agent_extract")
_entity_label = extract_config.rsplit(".", 1)[0]

print("=" * 65)
print("  nb_gold_dataloader — START")
print("=" * 65)
print(f"  entity          : {_entity_label}")
print(f"  config_base_path: {config_base_path}")
print(f"  extract_config  : {extract_config}")
print(f"  transform_config: {transform_config}")
print(f"  load_config     : {load_config}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Read and parse config JSON files
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[1/4] Reading config files from '{config_base_path}'")


def _read_json_config(base_path: str, filename: str) -> dict:
    """Read a JSON config file from the Fabric lakehouse Files area and parse it."""
    full_path = f"{base_path.rstrip('/')}/{filename}"
    try:
        raw = spark.read.text(full_path).collect()
        content = "\n".join(row["value"] for row in raw)
        parsed  = json.loads(content)
        _logger.info("Loaded config: %s", full_path)
        return parsed
    except Exception as e:
        raise RuntimeError(
            f"[nb_gold_dataloader] Failed to read config '{full_path}'.\n"
            f"Ensure the file exists at config_base_path and is valid JSON.\n{e}"
        )


extract_cfg   = _read_json_config(config_base_path, extract_config)
transform_cfg = _read_json_config(config_base_path, transform_config)
load_cfg      = _read_json_config(config_base_path, load_config)

# Validate load_config has required keys
_load_required = ["target_table", "business_key_col", "is_scd2", "surrogate_key_col"]
_load_missing  = [k for k in _load_required if k not in load_cfg]
if _load_missing:
    raise ValueError(
        f"[nb_gold_dataloader] load_config is missing required keys: {_load_missing}"
    )

_target_table      = load_cfg["target_table"]
_business_key_cols = load_cfg["business_key_col"]   # list
_is_scd2           = bool(load_cfg["is_scd2"])
_surrogate_key_col = load_cfg["surrogate_key_col"]
_hash_col          = load_cfg.get("hash_col", "md5_hash")

if isinstance(_business_key_cols, str):
    # Accept a plain string as a single-element list for convenience
    _business_key_cols = [_business_key_cols]

print(f"  target_table      : {_target_table}")
print(f"  business_key_cols : {_business_key_cols}")
print(f"  surrogate_key_col : {_surrogate_key_col}")
print(f"  is_scd2           : {_is_scd2}")
print(f"  hash_col          : {_hash_col}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Instantiate GoldLoader
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[2/4] Instantiating GoldLoader")

loader = GoldLoader(spark, config_base_path=config_base_path)  # noqa: F821  # type: ignore[name-defined]
print(f"  GoldLoader ready  : {len(loader._function_registry)} functions in registry")
print(f"  config_base_path  : {config_base_path}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Extract → Transform → Load
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/4] Running ETL pipeline")

# ── Extract ───────────────────────────────────────────────────────────────────
print("  [extract]  Running query ...")
_extract_start = time.time()
extract_df     = loader.extract(extract_cfg)
rows_extracted = extract_df.count()
print(f"  [extract]  Rows extracted : {rows_extracted:,}  ({round(time.time() - _extract_start, 2)}s)")

# ── Transform ─────────────────────────────────────────────────────────────────
print("  [transform] Applying transformation steps ...")
_transform_start = time.time()
transformed_df   = loader.transform(extract_df, transform_cfg)
rows_transformed = transformed_df.count()
print(f"  [transform] Rows after transform : {rows_transformed:,}  ({round(time.time() - _transform_start, 2)}s)")

# ── Load ──────────────────────────────────────────────────────────────────────
print(f"  [load] Writing to '{_target_table}' (is_scd2={_is_scd2}) ...")
_load_start = time.time()
loader.load(
    df                = transformed_df,
    target_table      = _target_table,
    is_scd2           = _is_scd2,
    business_key_cols = _business_key_cols,
    surrogate_key_col = _surrogate_key_col,
    hash_col          = _hash_col,
)
print(f"  [load]  Complete  ({round(time.time() - _load_start, 2)}s)")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Summary
# ══════════════════════════════════════════════════════════════════════════════

_elapsed = round(time.time() - _notebook_start, 2)

print("\n" + "=" * 65)
print("  nb_gold_dataloader — COMPLETE")
print(f"  Entity            : {_entity_label}")
print(f"  Target table      : {_target_table}")
print(f"  Rows extracted    : {rows_extracted:,}")
print(f"  Rows transformed  : {rows_transformed:,}")
print(f"  Load strategy     : {'SCD Type 2' if _is_scd2 else 'UPSERT MERGE'}")
print(f"  Elapsed           : {_elapsed}s")
print("=" * 65)
