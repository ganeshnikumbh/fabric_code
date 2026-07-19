# schema_config regeneration — HubSpot & Webex (review notes)

Generated files (full INSERT statements, ready to review/replace the current sections):
- `sql/schema_config_hubspot.sql`
- `sql/schema_config_webex.sql`

## Transformation rules applied
- **landing_column_name** = the JSON `source` path, `.` → `_`, original case preserved.
  Navigation tokens are stripped: `$0` / `$first` / `$first_key` (array/dynamic-key
  navigation) and `__parent__` / `__top__` / `__item__` (Webex parent/context refs).
  e.g. `properties.hs_query_params` → `properties_hs_query_params`;
       `__parent__.channelInfo.$0.channelId` → `channelInfo_channelId`.
- **bronze_column_name** = last real path segment, lowercased + snake_cased.
  When that would collide with another field in the same table, parent segments are
  prepended (leftward) until unique. e.g. `queue.id`/`idleCode.id`/`wrapupCode.id`
  → `queue_id` / `idle_code_id` / `wrapup_code_id`.
- **silver_column_name** and every other field (types, ordinal, flags, default, active)
  are UNCHANGED from the current statements.
- Only rows whose `silver_column_name` matches a JSON `column` (i.e. rows mechanically
  derived from the API schema) are transformed. All other rows are left exactly as-is.

## GAPS — need manual attention

### 1. Tables with NO JSON schema file (rows left unchanged)
event_types*, crm_deals, crm_tickets, crm_products, crm_line_items, crm_quotes,
crm_calls, crm_meetings, crm_notes, crm_tasks
  → landing/bronze could not be derived. `event_types` may be a naming mismatch with
    the existing `events_event_types.json` — confirm and rename if they're the same entity.

### 2. Hand-curated tables (silver renamed, rows not 1:1 with JSON) — left unchanged
- `crm_companies` (0/20 rows linkable) — schema_config columns are semantic and do not
  align with the JSON at all (curated subset + audit columns inline).
- `marketing_events` (9/27), `marketing_emails` (28/76) — only the matching rows were
  transformed; the rest are custom and left as-is.
- Webex `agent_session` (17/124), `customer_activity` (42/71) etc. — matched rows
  transformed, custom/context rows left as-is.

### 3. Residual bronze collisions — ALL from PRE-EXISTING duplicate silver names
(These already exist as duplicates in the current statements; the transform did not
create them. They should be de-duplicated in schema_config regardless.)
- crm_companies: `company_id` ×2, `created_timestamp` ×2, `updated_timestamp` ×2
- agent_session: `outdial_consult_to_ep_requested_duration` ×2
- call_leg: `call_leg_sla` ×2
- customer_session: `outdial_consult_to_entrypoint_duration` ×2
- customer_activity: `id` (a transformable top-level `id` collides with a kept row's bronze)

## Fully-clean tables (100% mechanically transformed)
crm_contacts (24), crm_owners (11), event_details (51), marketing_email_statistics (64).

## Regenerated schema JSON files (new folder, not overwriting)
`fabric/workspaces/eq-hub/schema2/hubspot/*.json` and `.../schema2/webex/*.json`
- Each transformed field's `column` is set to its new `bronze_column_name`
  (JSON `column` is what names the BRONZE table columns for API sources).
- `source` and `type` are UNCHANGED. Fields not transformed keep their `column`.
- 9 of 21 JSONs changed columns; the rest were already last-segment names.
- ACTION: swap in these JSONs when rebuilding bronze so column names match schema_config.

### JSON column collision to fix manually
- Webex `customer_activity`: two fields collapse to `id` —
  `__parent__.id` (parent record id) and `id` (record's own id). Stripping the
  `__parent__` nav token leaves only `id` for both. Rename one (e.g. the parent
  ref to `parent_id`) in both the JSON and schema_config.
