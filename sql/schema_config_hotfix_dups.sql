-- ─────────────────────────────────────────────────────────────────────────────
-- Hotfix: remove duplicate silver_column_name mappings from dbo.schema_config
--
-- Two schema_config rows targeting the SAME silver_column_name cause the later
-- (higher ordinal_position) row to overwrite the earlier one in
-- cast_and_default_silver_columns. When the two rows have different silver
-- types, the silver load fails validation, e.g.:
--   "Data type check — call_leg_sla(expected=int, got=string)"
--
-- These statements bring the LIVE table in line with the corrected seed files
-- (schema_config_webex.sql / schema_config_hubspot.sql). Run against the SQL
-- database that backs nb_get_ingestion_entities, then re-run the pipeline so the
-- v_schema_config_json variable is regenerated. Idempotent — safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────────

-- 1) Webex call_leg — 'transferEpDN' was mislabeled silver 'call_leg_sla' (STRING),
--    overwriting the correct INT 'call_leg_sla' from 'slaValue'.  <-- the failure.
UPDATE dbo.schema_config
SET    silver_column_name = 'transfer_ep_dn'
WHERE  source_name        = 'Webex'
  AND  silver_table_name  = 'call_leg'
  AND  landing_column_name = 'transferEpDN'
  AND  silver_column_name  = 'call_leg_sla';

-- 2) Webex customer_session — 'outdialConsultToQueueDuration' was mislabeled silver
--    'outdial_consult_to_entrypoint_duration', overwriting the EP-duration column.
UPDATE dbo.schema_config
SET    silver_column_name = 'outdial_consult_to_queue_duration'
WHERE  source_name        = 'Webex'
  AND  silver_table_name  = 'customer_session'
  AND  landing_column_name = 'outdialConsultToQueueDuration'
  AND  silver_column_name  = 'outdial_consult_to_entrypoint_duration';

-- 3) HubSpot crm_companies — drop 3 properties_json_* rows that duplicate the
--    canonical top-level id / created_at / updated_at (same value, higher ordinal).
DELETE FROM dbo.schema_config
WHERE  source_name        = 'HubSpot'
  AND  silver_table_name  = 'crm_companies'
  AND  landing_column_name IN (
         'properties_json_createdate',
         'properties_json_hs_lastmodifieddate',
         'properties_json_hs_object_id'
       );

-- 4) HubSpot crm_companies — 'object_type' is a derived category, NOT a bronze
--    column (crm_companies_base has no object_type). Every sibling crm_* table
--    marks it landing/bronze = 'N/A' with include_in_md5hash = 0 so the silver
--    notebook excludes it. Make crm_companies consistent.  <-- the failure.
UPDATE dbo.schema_config
SET    landing_column_name = 'N/A',
       bronze_column_name  = 'N/A',
       include_in_md5hash   = 0
WHERE  source_name        = 'HubSpot'
  AND  silver_table_name  = 'crm_companies'
  AND  silver_column_name = 'object_type';

-- Verify no duplicate silver names remain per (source, silver_table):
-- SELECT source_name, silver_table_name, silver_column_name, COUNT(*) AS n
-- FROM   dbo.schema_config
-- GROUP  BY source_name, silver_table_name, silver_column_name
-- HAVING COUNT(*) > 1;
