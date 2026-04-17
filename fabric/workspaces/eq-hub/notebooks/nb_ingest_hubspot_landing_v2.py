# Notebook: nb_ingest_hubspot_landing_v2
# Layer:    Landing
# Purpose:  Receives a single-page HubSpot API response from a pipeline Web
#           activity, flattens it using the appropriate schema, and appends
#           the rows to the target Delta table in lh_landing (hubspot schema).
#           Creates the table on the first page if it does not yet exist.
#
# Pipeline pattern:
#   For each route → Web activity fetches one page → calls this notebook per page
#   The pipeline handles pagination (passing after-cursor to successive Web calls).
#
# p_table_name values and their targets:
#   marketing_events            → hubspot.marketing_events      (schema: marketing_events.json)
#   marketing_emails            → hubspot.marketing_emails      (schema: marketing_emails.json)
#   events_event_types          → hubspot.events_event_types    (schema: events_event_types.json)
#   crm_object_type_contacts    → hubspot.crm_contacts          (schema: crm_objects.json)
#   crm_object_type_companies   → hubspot.crm_companies         (schema: crm_objects.json)
#   crm_object_type_deals       → hubspot.crm_deals             (schema: crm_objects.json)
#   crm_object_type_<any>       → hubspot.crm_<any>             (schema: crm_objects.json)
#
# Parameters:
#   p_api_response   — JSON string of the API response (one page), from Web activity
#   p_table_name     — identifies target table and schema (see values above)
#   p_ingestion_date — yyyy-mm-dd
#   p_context_json   — optional JSON with extra context columns
#                      e.g. {"period":"2026-03"} for marketing_events
#                           {"object_type":"contacts"} auto-derived for crm_object_type_*
#
# Pre-requisites:
#   - Attach lh_landing as the default lakehouse before running.
#   - Schema JSON files must be present at lh_landing Files/hubspot/schemas/.

import json

from pyspark.sql import SparkSession
from pyspark.sql.types import BooleanType, IntegerType, StringType, StructField, StructType

%run nb_utils.py

spark = SparkSession.builder.appName("nb_ingest_hubspot_landing_v2").getOrCreate()

# ── Parameters ─────────────────────────────────────────────────────────────────
p_api_response   = "{}"
p_table_name     = ""
p_ingestion_date = ""
p_context_json   = "{}"

# ── Validation ─────────────────────────────────────────────────────────────────
validate_required_params({  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
    "p_table_name":     p_table_name,
    "p_ingestion_date": p_ingestion_date,
})

_TARGET_SCHEMA = "hubspot"
_SCHEMA_DIR    = "/lakehouse/default/Files/hubspot/schemas"

print("=" * 65)
print("  nb_ingest_hubspot_landing_v2 — START")
print("=" * 65)
print(f"  ingestion_date : {p_ingestion_date}")
print(f"  table_name     : {p_table_name}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Helpers
# ══════════════════════════════════════════════════════════════════════════════

def _load_schema(schema_name):
    with open(f"{_SCHEMA_DIR}/{schema_name}.json", "r") as f:
        return json.load(f)


def _get(record, dot_path):
    """Resolve a dot-notation path against a nested dict."""
    if dot_path == "__item__":
        return record
    val = record
    for key in dot_path.split("."):
        if not isinstance(val, dict):
            return None
        val = val.get(key)
    return val


def _flatten(record, fields, context=None):
    """Flatten one API record dict to a flat row dict using schema field definitions."""
    row = {}
    for f in fields:
        val = _get(record, f["source"])
        t   = f["type"]
        if t == "json":
            row[f["column"]] = json.dumps(val) if val is not None else None
        elif t == "boolean":
            row[f["column"]] = bool(val) if val is not None else None
        elif t == "integer":
            row[f["column"]] = int(val) if val is not None else None
        else:
            row[f["column"]] = str(val) if val is not None else None
    if context:
        row.update(context)
    return row


def _build_spark_schema(fields, context_keys=None):
    """Build a Spark StructType from field definitions plus optional context column names."""
    _type_map = {
        "string":  StringType(),
        "boolean": BooleanType(),
        "integer": IntegerType(),
        "json":    StringType(),
    }
    sf_list = [
        StructField(f["column"], _type_map.get(f["type"], StringType()), nullable=True)
        for f in fields
    ]
    for ck in (context_keys or []):
        sf_list.append(StructField(ck, StringType(), nullable=True))
    return StructType(sf_list)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Resolve Table Config from p_table_name
# ══════════════════════════════════════════════════════════════════════════════

# Static table map for non-CRM routes
_TABLE_MAP = {
    "marketing_events": {
        "schema_name":     "marketing_events",
        "target_table":    "marketing_events",
        "results_path":    "results",
        "is_string_array": False,
    },
    "marketing_emails": {
        "schema_name":     "marketing_emails",
        "target_table":    "marketing_emails",
        "results_path":    "results",
        "is_string_array": False,
    },
    "events_event_types": {
        "schema_name":     "events_event_types",
        "target_table":    "events_event_types",
        "results_path":    "eventTypes",
        "is_string_array": True,
    },
}

# Parse context JSON (may be empty)
_context = {}
if p_context_json and p_context_json.strip() not in ("", "{}"):
    _context = json.loads(p_context_json)

# Resolve config
if p_table_name.startswith("crm_object_type_"):
    _obj_type     = p_table_name[len("crm_object_type_"):]
    _schema_name  = "crm_objects"
    _target_table = f"crm_{_obj_type}"
    _results_path = "results"
    _is_str_array = False
    _context.setdefault("object_type", _obj_type)   # auto-inject if not in p_context_json
elif p_table_name in _TABLE_MAP:
    _cfg          = _TABLE_MAP[p_table_name]
    _schema_name  = _cfg["schema_name"]
    _target_table = _cfg["target_table"]
    _results_path = _cfg["results_path"]
    _is_str_array = _cfg["is_string_array"]
else:
    raise ValueError(
        f"Unknown p_table_name '{p_table_name}'. "
        "Expected: marketing_events | marketing_emails | events_event_types | crm_object_type_<objectType>"
    )

_qualified = f"{_TARGET_SCHEMA}.{_target_table}"
print(f"\n  schema   : {_schema_name}")
print(f"  target   : {_qualified}")
print(f"  context  : {_context}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Load Schema
# ══════════════════════════════════════════════════════════════════════════════

_schema_def     = _load_schema(_schema_name)
_fields         = _schema_def["fields"]
_context_fields = list(_context.keys())   # only include keys we actually have values for

print(f"\n  Schema loaded : {_schema_name}  ({len(_fields)} fields, context: {_context_fields})")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Parse API Response and Flatten
# ══════════════════════════════════════════════════════════════════════════════

_response = json.loads(p_api_response) if isinstance(p_api_response, str) else p_api_response

if _is_str_array:
    # events_event_types: response is {"eventTypes": ["type1", "type2", ...]}
    items = _response.get(_results_path, [])
    rows  = [{"event_type": str(item)} for item in items if item]
else:
    records = _response.get(_results_path, [])
    rows    = [_flatten(r, _fields, context=_context or None) for r in records]

print(f"\n  Records in response : {len(rows)}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Write to Delta Table (append or create)
# ══════════════════════════════════════════════════════════════════════════════

if not rows:
    print("  No rows to write — skipping.")
else:
    _spark_schema = _build_spark_schema(_fields, _context_fields)
    _df           = spark.createDataFrame(rows, schema=_spark_schema)

    spark.sql(f"CREATE SCHEMA IF NOT EXISTS {_TARGET_SCHEMA}")

    _write_mode = "append" if spark.catalog.tableExists(_qualified) else "overwrite"

    (
        _df.write
        .format("delta")
        .mode(_write_mode)
        .option("mergeSchema", "true")
        .saveAsTable(_qualified)
    )

    _count = _df.count()
    print(f"\n  [{_write_mode.upper()}] {_qualified} — {_count:,} rows written")

print("\n" + "=" * 65)
print("  nb_ingest_hubspot_landing_v2 — COMPLETE")
print("=" * 65)
