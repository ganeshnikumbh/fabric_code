# Notebook: nb_ingest_hubspot_landing
# Layer:    Landing
# Purpose:  Fetches data from all accessible HubSpot API routes through the APIM
#           gateway, flattens each response using schema definitions loaded from
#           JSON schema files, and writes to Delta tables in lh_landing (hubspot schema).
#
# Schema files : fabric/workspaces/eq-hub/schemas/hubspot/  (source control)
#                Files/hubspot/schemas/  (lakehouse Files — copy here before first run)
# Error log    : Files/hubspot/hubspot_log_<p_ingestion_date>.json
#
# Accessible routes handled:
#   GET /marketing/marketing-events/{period}                      → hubspot.marketing_events
#   GET /marketing/v3/emails/                                     → hubspot.marketing_emails
#   GET /marketing/v3/emails/{emailId}                            → hubspot.marketing_email_details
#   GET /marketing/v3/emails/{emailId}/draft                      → hubspot.marketing_email_drafts
#   GET /marketing/v3/emails/{emailId}/revisions                  → hubspot.marketing_email_revisions
#   GET /marketing/v3/emails/{emailId}/revisions/{revisionId}     → hubspot.marketing_email_revision_details
#   GET /events/v3/events/event-types                             → hubspot.events_event_types
#   GET /crm/objects/2025-09/{objectType}                         → hubspot.crm_{objectType}
#   GET /crm/objects/2025-09/{objectType}/{objectId}              → hubspot.crm_{objectType}_details
#
# Parameters:
#   p_base_url                    — APIM base URL (no trailing slash)
#   p_Ocp_Apim_Subscription_Key   — subscription key, passed as Ocp-Apim-Subscription-Key header
#   p_ingestion_date              — yyyy-mm-dd
#   p_marketing_events_period     — yyyy-MM period for marketing events route (default: derived from p_ingestion_date)
#   p_crm_object_types            — comma-separated CRM object types to fetch
#   p_fetch_child_routes          — "true" to fetch email/CRM child routes
#
# Pre-requisites:
#   - Attach lh_landing as the default lakehouse before running.
#   - Copy schema JSON files from repo schemas/hubspot/ to lakehouse Files/hubspot/schemas/.

import json
import requests
from datetime import datetime, timezone

from pyspark.sql import SparkSession
from pyspark.sql.types import BooleanType, IntegerType, StringType, StructField, StructType

%run nb_utils.py

spark = SparkSession.builder.appName("nb_ingest_hubspot_landing").getOrCreate()

# ── Parameters ─────────────────────────────────────────────────────────────────
p_base_url                   = ""
p_Ocp_Apim_Subscription_Key  = ""
p_ingestion_date             = ""
p_marketing_events_period    = ""   # yyyy-MM; defaults to year-month of p_ingestion_date if blank
p_crm_object_types           = "contacts,companies,deals,tickets,products,line_items,quotes,calls,meetings,notes,tasks"
p_fetch_child_routes         = "true"

# ── Validation ─────────────────────────────────────────────────────────────────
validate_required_params({  # noqa: F821  # type: ignore[name-defined]  — injected by %run nb_utils
    "p_base_url":                  p_base_url,
    "p_Ocp_Apim_Subscription_Key": p_Ocp_Apim_Subscription_Key,
    "p_ingestion_date":            p_ingestion_date,
})

_fetch_children     = str(p_fetch_child_routes).strip().lower() == "true"
_crm_object_types   = [t.strip() for t in p_crm_object_types.split(",") if t.strip()]
_events_period      = p_marketing_events_period.strip() or p_ingestion_date[:7]
_BASE               = p_base_url.rstrip("/")
_TARGET_SCHEMA      = "hubspot"
_LOG_PATH           = f"Files/hubspot/hubspot_log_{p_ingestion_date}.json"
_SCHEMA_DIR         = "/lakehouse/default/Files/hubspot/schemas"

print("=" * 70)
print("  nb_ingest_hubspot_landing — START")
print("=" * 70)
print(f"  ingestion_date          : {p_ingestion_date}")
print(f"  base_url                : {_BASE}")
print(f"  marketing_events_period : {_events_period}")
print(f"  fetch_child_routes      : {_fetch_children}")
print(f"  crm_object_types        : {_crm_object_types}")
print("=" * 70)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Helpers
# ══════════════════════════════════════════════════════════════════════════════

# ── Schema loader ──────────────────────────────────────────────────────────────
def _load_schema(schema_name):
    """Read a schema JSON file from the lakehouse Files/hubspot/schemas/ directory."""
    with open(f"{_SCHEMA_DIR}/{schema_name}.json", "r") as f:
        return json.load(f)


# ── Error logging ──────────────────────────────────────────────────────────────
_errors = []


def _log_error(route, error, context=None):
    entry = {
        "route":     route,
        "error":     str(error),
        "context":   context or {},
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
    _errors.append(entry)
    print(f"  [ERROR] {route} — {error}")


def _flush_log():
    if not _errors:
        return
    payload = json.dumps({"ingestion_date": p_ingestion_date, "errors": _errors}, indent=2)
    mssparkutils.fs.put(_LOG_PATH, payload, True)  # noqa: F821  # type: ignore[name-defined]  — injected by Fabric runtime
    print(f"\n  Error log written → {_LOG_PATH}  ({len(_errors)} entries)")


# ── Record flattening ──────────────────────────────────────────────────────────
def _get(record, dot_path):
    """Resolve a dot-notation path against a nested dict. Returns None if any key is missing."""
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


# ── Spark schema builder ───────────────────────────────────────────────────────
def _build_spark_schema(fields, context_fields=None):
    """Build a Spark StructType from schema field definitions plus optional context field names."""
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
    for cf in (context_fields or []):
        sf_list.append(StructField(cf, StringType(), nullable=True))
    return StructType(sf_list)


# ── HTTP helpers ───────────────────────────────────────────────────────────────
_session = requests.Session()
_session.headers.update({
    "Ocp-Apim-Subscription-Key": p_Ocp_Apim_Subscription_Key,
    "Accept": "application/json",
})


def _http_get(url, params=None):
    """Execute a single GET request. Raises HTTPError on non-2xx."""
    resp = _session.get(url, params=params, timeout=30)
    resp.raise_for_status()
    return resp.json()


def _fetch_pages(route, params=None):
    """Fetch all pages for a standard HubSpot paginated endpoint (results + paging.next.after)."""
    url = f"{_BASE}{route}"
    all_records, after, page = [], None, 0
    while True:
        req_params = dict(params or {})
        if after:
            req_params["after"] = after
        data = _http_get(url, params=req_params)
        all_records.extend(data.get("results", []))
        page += 1
        after = ((data.get("paging") or {}).get("next") or {}).get("after")
        if not after:
            break
    print(f"  Fetched {len(all_records):,} records  ({page} page(s))  ← {route}")
    return all_records


# ── Delta write helper ─────────────────────────────────────────────────────────
def _write_table(rows, fields, table_name, context_fields=None):
    """Create a Spark DataFrame from rows and write to a Delta table (overwrite)."""
    spark_schema = _build_spark_schema(fields, context_fields)
    df = spark.createDataFrame(rows, schema=spark_schema)
    spark.sql(f"CREATE SCHEMA IF NOT EXISTS {_TARGET_SCHEMA}")
    (
        df.write
        .format("delta")
        .mode("overwrite")
        .option("overwriteSchema", "true")
        .saveAsTable(f"{_TARGET_SCHEMA}.{table_name}")
    )
    count = df.count()
    print(f"  [WRITE] {_TARGET_SCHEMA}.{table_name} — {count:,} rows")
    return count


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Load Schemas from Files
# ══════════════════════════════════════════════════════════════════════════════
# Schema files live in lh_landing Files/hubspot/schemas/ (deployed from repo
# fabric/workspaces/eq-hub/schemas/hubspot/).  Each schema defines the flat
# column list (fields) and any URL-context columns (context_fields).

_SCHEMA_NAMES = [
    "marketing_events",
    "marketing_emails",
    "marketing_email_details",
    "marketing_email_drafts",
    "marketing_email_revisions",
    "marketing_email_revision_details",
    "events_event_types",
    "crm_objects",
    "crm_object_details",
]

_schemas = {}
print(f"\n{'─' * 70}")
print("  SECTION 2 — Loading schemas")
print(f"{'─' * 70}")
for _sname in _SCHEMA_NAMES:
    try:
        _schemas[_sname] = _load_schema(_sname)
        print(f"  Loaded : {_sname}  ({len(_schemas[_sname]['fields'])} fields)")
    except Exception as _exc:
        print(f"  [ERROR] Could not load schema '{_sname}': {_exc}")
        raise


# ── Schema field shortcuts ─────────────────────────────────────────────────────
_ME_FIELDS    = _schemas["marketing_events"]["fields"]        # marketing events
_EMAIL_FIELDS = _schemas["marketing_emails"]["fields"]        # shared by emails/details/drafts
_REV_FIELDS   = _schemas["marketing_email_revisions"]["fields"]
_CRM_FIELDS   = _schemas["crm_objects"]["fields"]             # shared by list and details


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Marketing Events
# ══════════════════════════════════════════════════════════════════════════════
print(f"\n{'─' * 70}")
print(f"  SECTION 3 — Marketing Events  (period: {_events_period})")
print(f"{'─' * 70}")

try:
    me_records = _fetch_pages(f"/marketing/marketing-events/{_events_period}")
    rows = [_flatten(r, _ME_FIELDS, context={"period": _events_period}) for r in me_records]
    _write_table(rows, _ME_FIELDS, "marketing_events",
                 context_fields=_schemas["marketing_events"]["context_fields"])
except Exception as exc:
    _log_error(f"/marketing/marketing-events/{_events_period}", exc)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — Marketing Emails
# ══════════════════════════════════════════════════════════════════════════════
print(f"\n{'─' * 70}")
print("  SECTION 4 — Marketing Emails")
print(f"{'─' * 70}")

email_ids = []

# 4a: Email list
try:
    email_records = _fetch_pages("/marketing/v3/emails/")
    rows = [_flatten(r, _EMAIL_FIELDS) for r in email_records]
    _write_table(rows, _EMAIL_FIELDS, "marketing_emails")
    email_ids = [r.get("id") for r in email_records if r.get("id")]
    print(f"  {len(email_ids)} email IDs queued for child routes")
except Exception as exc:
    _log_error("/marketing/v3/emails/", exc)

# 4b–4e: Child routes per email  (NOTE: makes 3+ API calls per email — may be slow for large accounts)
if _fetch_children and email_ids:
    detail_rows, draft_rows, revision_rows, rev_detail_rows = [], [], [], []

    for email_id in email_ids:

        # 4b: Email detail
        try:
            data = _http_get(f"{_BASE}/marketing/v3/emails/{email_id}")
            detail_rows.append(_flatten(data, _EMAIL_FIELDS, context={"email_id": email_id}))
        except Exception as exc:
            _log_error("/marketing/v3/emails/{emailId}", exc, {"email_id": email_id})

        # 4c: Email draft
        try:
            data = _http_get(f"{_BASE}/marketing/v3/emails/{email_id}/draft")
            draft_rows.append(_flatten(data, _EMAIL_FIELDS, context={"email_id": email_id}))
        except Exception as exc:
            _log_error("/marketing/v3/emails/{emailId}/draft", exc, {"email_id": email_id})

        # 4d: Revisions list
        rev_ids = []
        try:
            rev_records = _fetch_pages(f"/marketing/v3/emails/{email_id}/revisions")
            for r in rev_records:
                revision_rows.append(_flatten(r, _REV_FIELDS, context={"email_id": email_id}))
                if r.get("id"):
                    rev_ids.append(r["id"])
        except Exception as exc:
            _log_error("/marketing/v3/emails/{emailId}/revisions", exc, {"email_id": email_id})

        # 4e: Revision detail
        for rev_id in rev_ids:
            try:
                data = _http_get(f"{_BASE}/marketing/v3/emails/{email_id}/revisions/{rev_id}")
                rev_detail_rows.append(_flatten(data, _REV_FIELDS, context={"email_id": email_id}))
            except Exception as exc:
                _log_error("/marketing/v3/emails/{emailId}/revisions/{revisionId}", exc,
                           {"email_id": email_id, "revision_id": rev_id})

    _write_table(detail_rows,     _EMAIL_FIELDS, "marketing_email_details",
                 context_fields=_schemas["marketing_email_details"]["context_fields"])
    _write_table(draft_rows,      _EMAIL_FIELDS, "marketing_email_drafts",
                 context_fields=_schemas["marketing_email_drafts"]["context_fields"])
    _write_table(revision_rows,   _REV_FIELDS,   "marketing_email_revisions",
                 context_fields=_schemas["marketing_email_revisions"]["context_fields"])
    _write_table(rev_detail_rows, _REV_FIELDS,   "marketing_email_revision_details",
                 context_fields=_schemas["marketing_email_revision_details"]["context_fields"])


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — Events
# ══════════════════════════════════════════════════════════════════════════════
print(f"\n{'─' * 70}")
print("  SECTION 5 — Events")
print(f"{'─' * 70}")

try:
    data        = _http_get(f"{_BASE}/events/v3/events/event-types")
    event_types = data.get("eventTypes", [])
    rows        = [{"event_type": str(et)} for et in event_types if et]
    print(f"  Fetched {len(rows)} event types  ← /events/v3/events/event-types")
    _write_table(rows, _schemas["events_event_types"]["fields"], "events_event_types")
except Exception as exc:
    _log_error("/events/v3/events/event-types", exc)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — CRM Objects
# ══════════════════════════════════════════════════════════════════════════════
print(f"\n{'─' * 70}")
print("  SECTION 6 — CRM Objects")
print(f"{'─' * 70}")

for obj_type in _crm_object_types:
    print(f"\n  [{obj_type.upper()}]")
    list_table   = f"crm_{obj_type}"
    detail_table = f"crm_{obj_type}_details"
    object_ids   = []

    # 6a: Object list
    try:
        records    = _fetch_pages(f"/crm/objects/2025-09/{obj_type}")
        rows       = [_flatten(r, _CRM_FIELDS, context={"object_type": obj_type}) for r in records]
        _write_table(rows, _CRM_FIELDS, list_table,
                     context_fields=_schemas["crm_objects"]["context_fields"])
        object_ids = [r.get("id") for r in records if r.get("id")]
    except Exception as exc:
        _log_error(f"/crm/objects/2025-09/{obj_type}", exc, {"object_type": obj_type})

    # 6b: Object details  (NOTE: one API call per record — may be slow for large object types)
    if _fetch_children and object_ids:
        print(f"  Fetching details for {len(object_ids):,} {obj_type} records...")
        detail_rows = []
        for obj_id in object_ids:
            try:
                data = _http_get(f"{_BASE}/crm/objects/2025-09/{obj_type}/{obj_id}")
                detail_rows.append(_flatten(data, _CRM_FIELDS, context={"object_type": obj_type}))
            except Exception as exc:
                _log_error("/crm/objects/2025-09/{objectType}/{objectId}", exc,
                           {"object_type": obj_type, "object_id": obj_id})
        _write_table(detail_rows, _CRM_FIELDS, detail_table,
                     context_fields=_schemas["crm_object_details"]["context_fields"])


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — Flush Error Log & Summary
# ══════════════════════════════════════════════════════════════════════════════
_flush_log()

print(f"\n{'=' * 70}")
print("  nb_ingest_hubspot_landing — COMPLETE")
if _errors:
    print(f"  Total errors : {len(_errors)}  →  {_LOG_PATH}")
else:
    print("  No errors.")
print(f"{'=' * 70}")
