# Notebook: nb_ingest_hubspot_landing
# Layer:    Landing
# Purpose:  Receives a HubSpot marketing events API response, flattens the
#           results array, and writes it to a Delta table in lh_landing.
#
# Target table : hubspot.marketing_events  (lh_landing default lakehouse)
# Write mode   : overwrite — creates table on first run, replaces data on re-run
#
# Flattening rules:
#   appInfo  (nested object)  →  app_info_id, app_info_name
#   customProperties (array)  →  excluded (always empty in this feed)
#   all other scalar fields   →  snake_case column names
#
# Parameters:
#   p_api_response   — JSON string from HubSpot API (passed by ADF / pipeline)
#   p_ingestion_date — ingestion date yyyy-mm-dd (used for audit / lineage)
#
# Pre-requisites:
#   - Attach lh_landing as the default lakehouse before running.

import json

from pyspark.sql import SparkSession
from pyspark.sql.types import (
    BooleanType,
    IntegerType,
    StringType,
    StructField,
    StructType,
)

spark = SparkSession.builder.appName("nb_ingest_hubspot_landing").getOrCreate()

# ── Parameters (pipeline will override these defaults) ────────────────────────
p_api_response   = "{}"
p_ingestion_date = ""   # yyyy-mm-dd; always pass from pipeline

# ── Validate ─────────────────────────────────────────────────────────────────
if not p_ingestion_date or not p_ingestion_date.strip():
    raise ValueError("Parameter 'p_ingestion_date' is required (yyyy-mm-dd).")

_TARGET_SCHEMA = "hubspot"
_TARGET_TABLE  = "marketing_events"
_QUALIFIED     = f"{_TARGET_SCHEMA}.{_TARGET_TABLE}"

print("=" * 65)
print("  nb_ingest_hubspot_landing — START")
print("=" * 65)
print(f"  ingestion_date : {p_ingestion_date}")
print(f"  target table   : {_QUALIFIED}")
print("=" * 65)


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — Parse and flatten API response
# ══════════════════════════════════════════════════════════════════════════════

response_data = json.loads(p_api_response) if isinstance(p_api_response, str) else p_api_response
results       = response_data.get("results", [])

print(f"\n[1/3] Parsed API response — records : {len(results)}")


def _flatten_record(rec):
    app_info = rec.get("appInfo") or {}
    return {
        "object_id"         : rec.get("objectId"),
        "external_event_id" : rec.get("externalEventId"),
        "event_name"        : rec.get("eventName"),
        "event_type"        : rec.get("eventType"),
        "event_status"      : rec.get("eventStatus"),
        "event_status_v2"   : rec.get("eventStatusV2"),
        "start_date_time"   : rec.get("startDateTime"),
        "end_date_time"     : rec.get("endDateTime"),
        "event_organizer"   : rec.get("eventOrganizer"),
        "event_description" : rec.get("eventDescription"),
        "event_url"         : rec.get("eventUrl"),
        "event_cancelled"   : rec.get("eventCancelled"),
        "event_completed"   : rec.get("eventCompleted"),
        "registrants"       : rec.get("registrants"),
        "attendees"         : rec.get("attendees"),
        "cancellations"     : rec.get("cancellations"),
        "no_shows"          : rec.get("noShows"),
        "app_info_id"       : app_info.get("id"),
        "app_info_name"     : app_info.get("name"),
        "created_at"        : rec.get("createdAt"),
        "updated_at"        : rec.get("updatedAt"),
    }


flat_records = [_flatten_record(r) for r in results]


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — Build Spark DataFrame
# ══════════════════════════════════════════════════════════════════════════════

_schema = StructType([
    StructField("object_id",          StringType(),  nullable=True),
    StructField("external_event_id",  StringType(),  nullable=True),
    StructField("event_name",         StringType(),  nullable=True),
    StructField("event_type",         StringType(),  nullable=True),
    StructField("event_status",       StringType(),  nullable=True),
    StructField("event_status_v2",    StringType(),  nullable=True),
    StructField("start_date_time",    StringType(),  nullable=True),
    StructField("end_date_time",      StringType(),  nullable=True),
    StructField("event_organizer",    StringType(),  nullable=True),
    StructField("event_description",  StringType(),  nullable=True),
    StructField("event_url",          StringType(),  nullable=True),
    StructField("event_cancelled",    BooleanType(), nullable=True),
    StructField("event_completed",    BooleanType(), nullable=True),
    StructField("registrants",        IntegerType(), nullable=True),
    StructField("attendees",          IntegerType(), nullable=True),
    StructField("cancellations",      IntegerType(), nullable=True),
    StructField("no_shows",           IntegerType(), nullable=True),
    StructField("app_info_id",        StringType(),  nullable=True),
    StructField("app_info_name",      StringType(),  nullable=True),
    StructField("created_at",         StringType(),  nullable=True),
    StructField("updated_at",         StringType(),  nullable=True),
])

events_df = spark.createDataFrame(flat_records, schema=_schema)

print(f"\n[2/3] DataFrame created — rows : {events_df.count()}")


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — Write to Delta table (create or overwrite)
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n[3/3] Writing to {_QUALIFIED}")

spark.sql(f"CREATE SCHEMA IF NOT EXISTS {_TARGET_SCHEMA}")

(
    events_df.write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .saveAsTable(_QUALIFIED)
)

row_count = spark.table(_QUALIFIED).count()
print(f"  Table {_QUALIFIED} — rows after write : {row_count}")

print("=" * 65)
print("  nb_ingest_hubspot_landing — COMPLETE")
print("=" * 65)
