-- schema_config INSERTs for source_name = 'HubSpot'  (REGENERATED for review)
-- landing_column_name = full JSON source path (nav tokens $/__parent__ stripped), '.'->'_' , case preserved
-- bronze_column_name  = last real path segment, lowercased+snake; parent prepended only on collision
-- silver_column_name and all other fields = UNCHANGED from current statements
-- Rows for tables without a JSON file, and rows whose silver has no JSON source, are LEFT AS-IS.

-- [marketing_events]  (9 transformed / 18 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'marketing_events', 'object_id', 'STRING', 'marketing_events_base', 'object_id', 'STRING', 'marketing_events', 'marketing_event_id', 'STRING', 1, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'externalEventId', 'STRING', 'marketing_events_base', 'external_event_id', 'STRING', 'marketing_events', 'external_event_id', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventName', 'STRING', 'marketing_events_base', 'event_name', 'STRING', 'marketing_events', 'event_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventType', 'STRING', 'marketing_events_base', 'event_type', 'STRING', 'marketing_events', 'event_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventStatus', 'STRING', 'marketing_events_base', 'event_status', 'STRING', 'marketing_events', 'event_status', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventStatusV2', 'STRING', 'marketing_events_base', 'event_status_v2', 'STRING', 'marketing_events', 'event_status_v2', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'start_date_time', 'STRING', 'marketing_events_base', 'start_date_time', 'STRING', 'marketing_events', 'start_timestamp', 'TIMESTAMP', 7, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'end_date_time', 'STRING', 'marketing_events_base', 'end_date_time', 'STRING', 'marketing_events', 'end_timestamp', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'event_organizer', 'STRING', 'marketing_events_base', 'event_organizer', 'STRING', 'marketing_events', 'event_organizer_email', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventDescription', 'STRING', 'marketing_events_base', 'event_description', 'STRING', 'marketing_events', 'event_description', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'eventUrl', 'STRING', 'marketing_events_base', 'event_url', 'STRING', 'marketing_events', 'event_url', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'event_cancelled', 'BOOLEAN', 'marketing_events_base', 'event_cancelled', 'BOOLEAN', 'marketing_events', 'is_cancelled', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'event_completed', 'BOOLEAN', 'marketing_events_base', 'event_completed', 'BOOLEAN', 'marketing_events', 'is_completed', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'registrants', 'BIGINT', 'marketing_events_base', 'registrants', 'BIGINT', 'marketing_events', 'registrants_count', 'BIGINT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'attendees', 'BIGINT', 'marketing_events_base', 'attendees', 'BIGINT', 'marketing_events', 'attendees_count', 'BIGINT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'cancellations', 'BIGINT', 'marketing_events_base', 'cancellations', 'BIGINT', 'marketing_events', 'cancellations_count', 'BIGINT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'no_shows', 'BIGINT', 'marketing_events_base', 'no_shows', 'BIGINT', 'marketing_events', 'no_shows_count', 'BIGINT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'appInfo_id', 'STRING', 'marketing_events_base', 'id', 'STRING', 'marketing_events', 'app_info_id', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'appInfo_name', 'STRING', 'marketing_events_base', 'name', 'STRING', 'marketing_events', 'app_info_name', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'created_at', 'STRING', 'marketing_events_base', 'created_at', 'STRING', 'marketing_events', 'created_timestamp', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_events', 'updated_at', 'STRING', 'marketing_events_base', 'updated_at', 'STRING', 'marketing_events', 'updated_timestamp', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE());

-- [marketing_emails]  (28 transformed / 48 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'marketing_emails', 'id', 'STRING', 'marketing_emails_base', 'id', 'STRING', 'marketing_emails', 'marketing_email_id', 'STRING', 1, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'name', 'STRING', 'marketing_emails_base', 'name', 'STRING', 'marketing_emails', 'marketing_email_name', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subject', 'STRING', 'marketing_emails_base', 'subject', 'STRING', 'marketing_emails', 'email_subject', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'state', 'STRING', 'marketing_emails_base', 'state', 'STRING', 'marketing_emails', 'email_state', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'type', 'STRING', 'marketing_emails_base', 'type', 'STRING', 'marketing_emails', 'email_type', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subcategory', 'STRING', 'marketing_emails_base', 'subcategory', 'STRING', 'marketing_emails', 'email_subcategory', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'language', 'STRING', 'marketing_emails_base', 'language', 'STRING', 'marketing_emails', 'email_language', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'archived', 'BOOLEAN', 'marketing_emails_base', 'archived', 'BOOLEAN', 'marketing_emails', 'is_archived', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'is_ab', 'BOOLEAN', 'marketing_emails_base', 'is_ab', 'BOOLEAN', 'marketing_emails', 'is_ab_test', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'isPublished', 'BOOLEAN', 'marketing_emails_base', 'is_published', 'BOOLEAN', 'marketing_emails', 'is_published', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'isTransactional', 'BOOLEAN', 'marketing_emails_base', 'is_transactional', 'BOOLEAN', 'marketing_emails', 'is_transactional', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'send_on_publish', 'BOOLEAN', 'marketing_emails_base', 'send_on_publish', 'BOOLEAN', 'marketing_emails', 'is_send_on_publish', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'jitter_send_time', 'BOOLEAN', 'marketing_emails_base', 'jitter_send_time', 'BOOLEAN', 'marketing_emails', 'is_jitter_send_time', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'activeDomain', 'STRING', 'marketing_emails_base', 'active_domain', 'STRING', 'marketing_emails', 'active_domain', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'campaign', 'STRING', 'marketing_emails_base', 'campaign', 'STRING', 'marketing_emails', 'campaign_id', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'campaignName', 'STRING', 'marketing_emails_base', 'campaign_name', 'STRING', 'marketing_emails', 'campaign_name', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'campaignUtm', 'STRING', 'marketing_emails_base', 'campaign_utm', 'STRING', 'marketing_emails', 'campaign_utm', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'emailCampaignGroupId', 'STRING', 'marketing_emails_base', 'email_campaign_group_id', 'STRING', 'marketing_emails', 'email_campaign_group_id', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'primaryEmailCampaignId', 'STRING', 'marketing_emails_base', 'primary_email_campaign_id', 'STRING', 'marketing_emails', 'primary_email_campaign_id', 'STRING', 19, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'emailTemplateMode', 'STRING', 'marketing_emails_base', 'email_template_mode', 'STRING', 'marketing_emails', 'email_template_mode', 'STRING', 20, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'feedbackSurveyId', 'STRING', 'marketing_emails_base', 'feedback_survey_id', 'STRING', 'marketing_emails', 'feedback_survey_id', 'STRING', 21, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'folderId', 'STRING', 'marketing_emails_base', 'folder_id', 'STRING', 'marketing_emails', 'folder_id', 'STRING', 22, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'businessUnitId', 'STRING', 'marketing_emails_base', 'business_unit_id', 'STRING', 'marketing_emails', 'business_unit_id', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'cloned_from', 'STRING', 'marketing_emails_base', 'cloned_from', 'STRING', 'marketing_emails', 'cloned_from_email_id', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'previewKey', 'STRING', 'marketing_emails_base', 'preview_key', 'STRING', 'marketing_emails', 'preview_key', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'publish_date', 'STRING', 'marketing_emails_base', 'publish_date', 'STRING', 'marketing_emails', 'publish_timestamp', 'TIMESTAMP', 26, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'published_at', 'STRING', 'marketing_emails_base', 'published_at', 'STRING', 'marketing_emails', 'published_timestamp', 'TIMESTAMP', 27, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'unpublished_at', 'STRING', 'marketing_emails_base', 'unpublished_at', 'STRING', 'marketing_emails', 'unpublished_timestamp', 'TIMESTAMP', 28, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'publishedByEmail', 'STRING', 'marketing_emails_base', 'published_by_email', 'STRING', 'marketing_emails', 'published_by_email', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'published_by_id', 'STRING', 'marketing_emails_base', 'published_by_id', 'STRING', 'marketing_emails', 'published_by_user_id', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'publishedByName', 'STRING', 'marketing_emails_base', 'published_by_name', 'STRING', 'marketing_emails', 'published_by_name', 'STRING', 31, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'created_at', 'STRING', 'marketing_emails_base', 'created_at', 'STRING', 'marketing_emails', 'created_timestamp', 'TIMESTAMP', 32, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'created_by_id', 'STRING', 'marketing_emails_base', 'created_by_id', 'STRING', 'marketing_emails', 'created_by_user_id', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'deleted_at', 'STRING', 'marketing_emails_base', 'deleted_at', 'STRING', 'marketing_emails', 'deleted_timestamp', 'TIMESTAMP', 34, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'updated_at', 'STRING', 'marketing_emails_base', 'updated_at', 'STRING', 'marketing_emails', 'updated_timestamp', 'TIMESTAMP', 35, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'updated_by_id', 'STRING', 'marketing_emails_base', 'updated_by_id', 'STRING', 'marketing_emails', 'updated_by_user_id', 'STRING', 36, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'from_fromName', 'STRING', 'marketing_emails_base', 'from_name', 'STRING', 'marketing_emails', 'from_name', 'STRING', 37, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'from_reply_to', 'STRING', 'marketing_emails_base', 'from_reply_to', 'STRING', 'marketing_emails', 'from_reply_to_email', 'STRING', 38, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'from_custom_reply_to', 'STRING', 'marketing_emails_base', 'from_custom_reply_to', 'STRING', 'marketing_emails', 'from_custom_reply_to_email', 'STRING', 39, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subscriptionDetails_subscriptionId', 'STRING', 'marketing_emails_base', 'subscription_id', 'STRING', 'marketing_emails', 'subscription_id', 'STRING', 40, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subscriptionDetails_subscriptionName', 'STRING', 'marketing_emails_base', 'subscription_name', 'STRING', 'marketing_emails', 'subscription_name', 'STRING', 41, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subscriptionDetails_officeLocationId', 'STRING', 'marketing_emails_base', 'subscription_office_location_id', 'STRING', 'marketing_emails', 'subscription_office_location_id', 'STRING', 42, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'subscriptionDetails_preferencesGroupId', 'STRING', 'marketing_emails_base', 'subscription_preferences_group_id', 'STRING', 'marketing_emails', 'subscription_preferences_group_id', 'STRING', 43, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'webversion_url', 'STRING', 'marketing_emails_base', 'webversion_url', 'STRING', 'marketing_emails', 'webversion_url', 'STRING', 44, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'webversion_enabled', 'BOOLEAN', 'marketing_emails_base', 'webversion_enabled', 'BOOLEAN', 'marketing_emails', 'is_webversion_enabled', 'INT', 45, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'content', 'STRING', 'marketing_emails_base', 'content_json', 'STRING', 'marketing_emails', 'content_json', 'STRING', 46, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'stats', 'STRING', 'marketing_emails_base', 'stats_json', 'STRING', 'marketing_emails', 'stats_json', 'STRING', 47, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'testing', 'STRING', 'marketing_emails_base', 'testing_json', 'STRING', 'marketing_emails', 'testing_json', 'STRING', 48, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'rssData', 'STRING', 'marketing_emails_base', 'rss_data_json', 'STRING', 'marketing_emails', 'rss_data_json', 'STRING', 49, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'to', 'STRING', 'marketing_emails_base', 'to_json', 'STRING', 'marketing_emails', 'to_json', 'STRING', 50, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'allEmailCampaignIds', 'STRING', 'marketing_emails_base', 'all_email_campaign_ids_json', 'STRING', 'marketing_emails', 'all_email_campaign_ids_json', 'STRING', 51, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'teamsWithAccess', 'STRING', 'marketing_emails_base', 'teams_with_access_json', 'STRING', 'marketing_emails', 'teams_with_access_json', 'STRING', 52, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_emails', 'workflowNames', 'STRING', 'marketing_emails_base', 'workflow_names_json', 'STRING', 'marketing_emails', 'workflow_names_json', 'STRING', 53, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [event_types]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'event_types', 'event_type', 'STRING', 'event_types_base', 'event_type_code', 'STRING', 'event_types', 'event_type_code', 'STRING', 1, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_contacts]  (24 transformed / 0 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_contacts', 'id', 'STRING', 'crm_contacts_base', 'id', 'STRING', 'crm_contacts', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'createdAt', 'STRING', 'crm_contacts_base', 'created_at', 'STRING', 'crm_contacts', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'updatedAt', 'STRING', 'crm_contacts_base', 'updated_at', 'STRING', 'crm_contacts', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'archived', 'BOOLEAN', 'crm_contacts_base', 'archived', 'BOOLEAN', 'crm_contacts', 'archived', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'url', 'STRING', 'crm_contacts_base', 'url', 'STRING', 'crm_contacts', 'url', 'STRING', 5, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_agent_id__c', 'STRING', 'crm_contacts_base', 'agent_id__c', 'STRING', 'crm_contacts', 'agent_id_c', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_agent_number', 'STRING', 'crm_contacts_base', 'agent_number', 'STRING', 'crm_contacts', 'agent_number', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_associatedcompanyid', 'STRING', 'crm_contacts_base', 'associatedcompanyid', 'STRING', 'crm_contacts', 'associatedcompanyid', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_associatedcompanylastupdated', 'STRING', 'crm_contacts_base', 'associatedcompanylastupdated', 'STRING', 'crm_contacts', 'associatedcompanylastupdated', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_company', 'STRING', 'crm_contacts_base', 'company', 'STRING', 'crm_contacts', 'company', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_createdate', 'STRING', 'crm_contacts_base', 'createdate', 'STRING', 'crm_contacts', 'createdate', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_email', 'STRING', 'crm_contacts_base', 'email', 'STRING', 'crm_contacts', 'email', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_click', 'STRING', 'crm_contacts_base', 'hs_email_click', 'STRING', 'crm_contacts', 'hs_email_click', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_first_click_date', 'STRING', 'crm_contacts_base', 'hs_email_first_click_date', 'STRING', 'crm_contacts', 'hs_email_first_click_date', 'TIMESTAMP', 14, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_first_open_date', 'STRING', 'crm_contacts_base', 'hs_email_first_open_date', 'STRING', 'crm_contacts', 'hs_email_first_open_date', 'TIMESTAMP', 15, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_first_reply_date', 'STRING', 'crm_contacts_base', 'hs_email_first_reply_date', 'STRING', 'crm_contacts', 'hs_email_first_reply_date', 'TIMESTAMP', 16, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_first_send_date', 'STRING', 'crm_contacts_base', 'hs_email_first_send_date', 'STRING', 'crm_contacts', 'hs_email_first_send_date', 'TIMESTAMP', 17, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_last_click_date', 'STRING', 'crm_contacts_base', 'hs_email_last_click_date', 'STRING', 'crm_contacts', 'hs_email_last_click_date', 'TIMESTAMP', 18, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_last_email_name', 'STRING', 'crm_contacts_base', 'hs_email_last_email_name', 'STRING', 'crm_contacts', 'hs_email_last_email_name', 'TIMESTAMP', 19, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_last_open_date', 'STRING', 'crm_contacts_base', 'hs_email_last_open_date', 'STRING', 'crm_contacts', 'hs_email_last_open_date', 'TIMESTAMP', 20, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_last_reply_date', 'STRING', 'crm_contacts_base', 'hs_email_last_reply_date', 'STRING', 'crm_contacts', 'hs_email_last_reply_date', 'TIMESTAMP', 21, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_email_last_send_date', 'STRING', 'crm_contacts_base', 'hs_email_last_send_date', 'STRING', 'crm_contacts', 'hs_email_last_send_date', 'TIMESTAMP', 22, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_hs_object_id', 'STRING', 'crm_contacts_base', 'hs_object_id', 'STRING', 'crm_contacts', 'hs_object_id', 'STRING', 23, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_contacts', 'properties_lastmodifieddate', 'STRING', 'crm_contacts_base', 'lastmodifieddate', 'STRING', 'crm_contacts', 'lastmodifieddate', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_companies]  (0 transformed / 20 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_companies', 'id', 'STRING', 'crm_companies_base', 'id', 'STRING', 'crm_companies', 'company_id', 'STRING', 1, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'created_at', 'STRING', 'crm_companies_base', 'created_at', 'STRING', 'crm_companies', 'created_timestamp', 'TIMESTAMP', 2, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'updated_at', 'STRING', 'crm_companies_base', 'updated_at', 'STRING', 'crm_companies', 'updated_timestamp', 'TIMESTAMP', 3, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'archived', 'BOOLEAN', 'crm_companies_base', 'archived', 'BOOLEAN', 'crm_companies', 'is_archived', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'archived_at', 'STRING', 'crm_companies_base', 'archived_at', 'STRING', 'crm_companies', 'archived_timestamp', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'object_write_trace_id', 'STRING', 'crm_companies_base', 'object_write_trace_id', 'STRING', 'crm_companies', 'write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'url', 'STRING', 'crm_companies_base', 'url', 'STRING', 'crm_companies', 'record_url', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'properties_json', 'STRING', 'crm_companies_base', 'properties_json', 'STRING', 'crm_companies', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'properties_json_domain', 'STRING', 'crm_companies_base', 'domain', 'STRING', 'crm_companies', 'company_domain', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'properties_json_name', 'STRING', 'crm_companies_base', 'name', 'STRING', 'crm_companies', 'company_name', 'STRING', 13, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_companies', 'object_type', 'STRING', 'crm_companies_base', 'object_type', 'STRING', 'crm_companies', 'object_type', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());
-- [crm_owners]  (11 transformed / 0 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_owners', 'id', 'STRING', 'crm_owners_base', 'id', 'STRING', 'crm_owners', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'email', 'STRING', 'crm_owners_base', 'email', 'STRING', 'crm_owners', 'email', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'firstName', 'STRING', 'crm_owners_base', 'first_name', 'STRING', 'crm_owners', 'first_name', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'lastName', 'STRING', 'crm_owners_base', 'last_name', 'STRING', 'crm_owners', 'last_name', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'type', 'STRING', 'crm_owners_base', 'type', 'STRING', 'crm_owners', 'type', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'userId', 'BIGINT', 'crm_owners_base', 'user_id', 'BIGINT', 'crm_owners', 'user_id', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'userIdIncludingInactive', 'BIGINT', 'crm_owners_base', 'user_id_including_inactive', 'BIGINT', 'crm_owners', 'user_id_including_inactive', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'createdAt', 'STRING', 'crm_owners_base', 'created_at', 'STRING', 'crm_owners', 'created_at', 'TIMESTAMP', 8, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'updatedAt', 'STRING', 'crm_owners_base', 'updated_at', 'STRING', 'crm_owners', 'updated_at', 'TIMESTAMP', 9, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'archived', 'BOOLEAN', 'crm_owners_base', 'archived', 'BOOLEAN', 'crm_owners', 'archived', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_owners', 'teams', 'STRING', 'crm_owners_base', 'teams', 'STRING', 'crm_owners', 'teams_json', 'STRING', 11, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [marketing_email_statistics]  (64 transformed / 0 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'marketing_email_statistics', 'emails', 'STRING', 'marketing_email_statistics_base', 'emails', 'STRING', 'marketing_email_statistics', 'email_id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_sent', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_sent', 'BIGINT', 'marketing_email_statistics', 'cnt_sent', 'INT', 2, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_open', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_open', 'BIGINT', 'marketing_email_statistics', 'cnt_open', 'INT', 3, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_delivered', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_delivered', 'BIGINT', 'marketing_email_statistics', 'cnt_delivered', 'INT', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_bounce', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_bounce', 'BIGINT', 'marketing_email_statistics', 'cnt_bounce', 'INT', 5, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_unsubscribed', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_unsubscribed', 'BIGINT', 'marketing_email_statistics', 'cnt_unsubscribed', 'INT', 6, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_click', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_click', 'BIGINT', 'marketing_email_statistics', 'cnt_click', 'INT', 7, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_reply', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_reply', 'BIGINT', 'marketing_email_statistics', 'cnt_reply', 'INT', 8, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_dropped', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_dropped', 'BIGINT', 'marketing_email_statistics', 'cnt_dropped', 'INT', 9, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_selected', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_selected', 'BIGINT', 'marketing_email_statistics', 'cnt_selected', 'INT', 10, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_spamreport', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_spamreport', 'BIGINT', 'marketing_email_statistics', 'cnt_spamreport', 'INT', 11, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_suppressed', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_suppressed', 'BIGINT', 'marketing_email_statistics', 'cnt_suppressed', 'INT', 12, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_hardbounced', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_hardbounced', 'BIGINT', 'marketing_email_statistics', 'cnt_hardbounced', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_softbounced', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_softbounced', 'BIGINT', 'marketing_email_statistics', 'cnt_softbounced', 'INT', 14, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_pending', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_pending', 'BIGINT', 'marketing_email_statistics', 'cnt_pending', 'INT', 15, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_contactslost', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_contactslost', 'BIGINT', 'marketing_email_statistics', 'cnt_contactslost', 'INT', 16, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_counters_notsent', 'BIGINT', 'marketing_email_statistics_base', 'aggregate_counters_notsent', 'BIGINT', 'marketing_email_statistics', 'cnt_notsent', 'INT', 17, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_clickratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_clickratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_click', 'FLOAT', 18, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_clickthroughratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_clickthroughratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_clickthrough', 'FLOAT', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_deliveredratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_deliveredratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_delivered', 'FLOAT', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_openratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_openratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_open', 'FLOAT', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_replyratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_replyratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_reply', 'FLOAT', 22, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_unsubscribedratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_unsubscribedratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_unsubscribed', 'FLOAT', 23, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_spamreportratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_spamreportratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_spamreport', 'FLOAT', 24, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_bounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_bounceratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_bounce', 'FLOAT', 25, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_hardbounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_hardbounceratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_hardbounce', 'FLOAT', 26, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_softbounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_softbounceratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_softbounce', 'FLOAT', 27, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_contactslostratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_contactslostratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_contactslost', 'FLOAT', 28, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_pendingratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_pendingratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_pending', 'FLOAT', 29, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_ratios_notsentratio', 'DOUBLE', 'marketing_email_statistics_base', 'aggregate_ratios_notsentratio', 'DOUBLE', 'marketing_email_statistics', 'ratio_notsent', 'FLOAT', 30, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_deviceBreakdown', 'STRING', 'marketing_email_statistics_base', 'aggregate_device_breakdown', 'STRING', 'marketing_email_statistics', 'device_breakdown_json', 'STRING', 31, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'aggregate_qualifierStats', 'STRING', 'marketing_email_statistics_base', 'aggregate_qualifier_stats', 'STRING', 'marketing_email_statistics', 'qualifier_stats_json', 'STRING', 32, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations', 'STRING', 'marketing_email_statistics_base', 'campaign_aggregations', 'STRING', 'marketing_email_statistics', 'campaign_id', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_sent', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_sent', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_sent', 'INT', 34, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_open', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_open', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_open', 'INT', 35, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_delivered', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_delivered', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_delivered', 'INT', 36, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_bounce', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_bounce', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_bounce', 'INT', 37, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_unsubscribed', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_unsubscribed', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_unsubscribed', 'INT', 38, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_click', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_click', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_click', 'INT', 39, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_reply', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_reply', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_reply', 'INT', 40, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_dropped', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_dropped', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_dropped', 'INT', 41, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_selected', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_selected', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_selected', 'INT', 42, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_spamreport', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_spamreport', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_spamreport', 'INT', 43, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_suppressed', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_suppressed', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_suppressed', 'INT', 44, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_hardbounced', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_hardbounced', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_hardbounced', 'INT', 45, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_softbounced', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_softbounced', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_softbounced', 'INT', 46, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_pending', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_pending', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_pending', 'INT', 47, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_contactslost', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_contactslost', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_contactslost', 'INT', 48, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_counters_notsent', 'BIGINT', 'marketing_email_statistics_base', 'campaign_aggregations_counters_notsent', 'BIGINT', 'marketing_email_statistics', 'campaign_cnt_notsent', 'INT', 49, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_clickratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_clickratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_click', 'FLOAT', 50, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_clickthroughratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_clickthroughratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_clickthrough', 'FLOAT', 51, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_deliveredratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_deliveredratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_delivered', 'FLOAT', 52, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_openratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_openratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_open', 'FLOAT', 53, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_replyratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_replyratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_reply', 'FLOAT', 54, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_unsubscribedratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_unsubscribedratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_unsubscribed', 'FLOAT', 55, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_spamreportratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_spamreportratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_spamreport', 'FLOAT', 56, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_bounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_bounceratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_bounce', 'FLOAT', 57, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_hardbounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_hardbounceratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_hardbounce', 'FLOAT', 58, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_softbounceratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_softbounceratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_softbounce', 'FLOAT', 59, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_contactslostratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_contactslostratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_contactslost', 'FLOAT', 60, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_pendingratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_pendingratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_pending', 'FLOAT', 61, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_ratios_notsentratio', 'DOUBLE', 'marketing_email_statistics_base', 'campaign_aggregations_ratios_notsentratio', 'DOUBLE', 'marketing_email_statistics', 'campaign_ratio_notsent', 'FLOAT', 62, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_deviceBreakdown', 'STRING', 'marketing_email_statistics_base', 'campaign_aggregations_device_breakdown', 'STRING', 'marketing_email_statistics', 'campaign_device_breakdown_json', 'STRING', 63, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'marketing_email_statistics', 'campaignAggregations_qualifierStats', 'STRING', 'marketing_email_statistics_base', 'campaign_aggregations_qualifier_stats', 'STRING', 'marketing_email_statistics', 'campaign_qualifier_stats_json', 'STRING', 64, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [event_details]  (51 transformed / 0 kept)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'event_details', 'id', 'STRING', 'event_details_base', 'id', 'STRING', 'event_details', 'id', 'STRING', 1, 0, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'objectType', 'STRING', 'event_details_base', 'object_type', 'STRING', 'event_details', 'object_type', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'objectId', 'STRING', 'event_details_base', 'object_id', 'STRING', 'event_details', 'object_id', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'eventType', 'STRING', 'event_details_base', 'event_type', 'STRING', 'event_details', 'event_type', 'STRING', 4, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'occurredAt', 'STRING', 'event_details_base', 'occurred_at', 'STRING', 'event_details', 'occurred_at', 'TIMESTAMP', 5, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_base_url', 'STRING', 'event_details_base', 'hs_base_url', 'STRING', 'event_details', 'hs_base_url', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_url', 'STRING', 'event_details_base', 'hs_url', 'STRING', 'event_details', 'hs_url', 'STRING', 7, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_query_params', 'STRING', 'event_details_base', 'hs_query_params', 'STRING', 'event_details', 'hs_query_params', 'STRING', 8, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_canonical_url', 'STRING', 'event_details_base', 'hs_canonical_url', 'STRING', 'event_details', 'hs_canonical_url', 'STRING', 9, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_url_domain', 'STRING', 'event_details_base', 'hs_url_domain', 'STRING', 'event_details', 'hs_url_domain', 'STRING', 10, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_url_path', 'STRING', 'event_details_base', 'hs_url_path', 'STRING', 'event_details', 'hs_url_path', 'STRING', 11, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_analytics_normalized_page_url', 'STRING', 'event_details_base', 'hs_analytics_normalized_page_url', 'STRING', 'event_details', 'hs_analytics_normalized_page_url', 'STRING', 12, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_virtual_url', 'BOOLEAN', 'event_details_base', 'hs_is_virtual_url', 'BOOLEAN', 'event_details', 'hs_is_virtual_url', 'INT', 13, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_page_id', 'STRING', 'event_details_base', 'hs_page_id', 'STRING', 'event_details', 'hs_page_id', 'STRING', 14, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_page_title', 'STRING', 'event_details_base', 'hs_page_title', 'STRING', 'event_details', 'hs_page_title', 'STRING', 15, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_title', 'STRING', 'event_details_base', 'hs_title', 'STRING', 'event_details', 'hs_title', 'STRING', 16, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_targeted_content_aggregation', 'STRING', 'event_details_base', 'hs_targeted_content_aggregation', 'STRING', 'event_details', 'hs_targeted_content_aggregation', 'STRING', 17, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_virtual_referrer', 'STRING', 'event_details_base', 'hs_is_virtual_referrer', 'BOOLEAN', 'event_details', 'hs_is_virtual_referrer', 'STRING', 18, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_external', 'STRING', 'event_details_base', 'hs_is_external', 'BOOLEAN', 'event_details', 'hs_is_external', 'INT', 19, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_amp', 'STRING', 'event_details_base', 'hs_is_amp', 'BOOLEAN', 'event_details', 'hs_is_amp', 'INT', 20, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_in_chat_view', 'STRING', 'event_details_base', 'hs_is_in_chat_view', 'BOOLEAN', 'event_details', 'hs_is_in_chat_view', 'INT', 21, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_new_cookie', 'STRING', 'event_details_base', 'hs_is_new_cookie', 'BOOLEAN', 'event_details', 'hs_is_new_cookie', 'INT', 22, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_is_contact', 'STRING', 'event_details_base', 'hs_is_contact', 'BOOLEAN', 'event_details', 'hs_is_contact', 'INT', 23, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_referrer', 'STRING', 'event_details_base', 'hs_referrer', 'STRING', 'event_details', 'hs_referrer', 'STRING', 24, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_device_type', 'STRING', 'event_details_base', 'hs_device_type', 'STRING', 'event_details', 'hs_device_type', 'STRING', 25, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_device_name', 'STRING', 'event_details_base', 'hs_device_name', 'STRING', 'event_details', 'hs_device_name', 'STRING', 26, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_browser', 'STRING', 'event_details_base', 'hs_browser', 'STRING', 'event_details', 'hs_browser', 'STRING', 27, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_browser_type', 'STRING', 'event_details_base', 'hs_browser_type', 'STRING', 'event_details', 'hs_browser_type', 'STRING', 28, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_browser_version_major', 'STRING', 'event_details_base', 'hs_browser_version_major', 'STRING', 'event_details', 'hs_browser_version_major', 'STRING', 29, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_browser_fingerprint', 'STRING', 'event_details_base', 'hs_browser_fingerprint', 'STRING', 'event_details', 'hs_browser_fingerprint', 'STRING', 30, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_operating_system', 'STRING', 'event_details_base', 'hs_operating_system', 'STRING', 'event_details', 'hs_operating_system', 'STRING', 31, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_vendor', 'STRING', 'event_details_base', 'hs_vendor', 'STRING', 'event_details', 'hs_vendor', 'STRING', 32, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_user_agent', 'STRING', 'event_details_base', 'hs_user_agent', 'STRING', 'event_details', 'hs_user_agent', 'STRING', 33, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_country', 'STRING', 'event_details_base', 'hs_country', 'STRING', 'event_details', 'hs_country', 'STRING', 34, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_region', 'STRING', 'event_details_base', 'hs_region', 'STRING', 'event_details', 'hs_region', 'STRING', 35, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_qualified_region', 'STRING', 'event_details_base', 'hs_qualified_region', 'STRING', 'event_details', 'hs_qualified_region', 'STRING', 36, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_city', 'STRING', 'event_details_base', 'hs_city', 'STRING', 'event_details', 'hs_city', 'STRING', 37, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_cf_bot_score', 'STRING', 'event_details_base', 'hs_cf_bot_score', 'STRING', 'event_details', 'hs_cf_bot_score', 'STRING', 38, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_hash_id', 'STRING', 'event_details_base', 'hs_hash_id', 'STRING', 'event_details', 'hs_hash_id', 'STRING', 39, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_log_line_timestamp', 'STRING', 'event_details_base', 'hs_log_line_timestamp', 'STRING', 'event_details', 'hs_log_line_timestamp', 'TIMESTAMP', 40, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_processed_timestamp', 'STRING', 'event_details_base', 'hs_processed_timestamp', 'STRING', 'event_details', 'hs_processed_timestamp', 'TIMESTAMP', 41, 1, 0, 0, '3000-01-01', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_visit_source', 'STRING', 'event_details_base', 'hs_visit_source', 'STRING', 'event_details', 'hs_visit_source', 'STRING', 42, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_visit_source_details_1', 'STRING', 'event_details_base', 'hs_visit_source_details_1', 'STRING', 'event_details', 'hs_visit_source_details_1', 'STRING', 43, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_visit_source_details_2', 'STRING', 'event_details_base', 'hs_visit_source_details_2', 'STRING', 'event_details', 'hs_visit_source_details_2', 'STRING', 44, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_utm_campaign', 'STRING', 'event_details_base', 'hs_utm_campaign', 'STRING', 'event_details', 'hs_utm_campaign', 'STRING', 45, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_leviathan_linked_vids', 'STRING', 'event_details_base', 'hs_leviathan_linked_vids', 'STRING', 'event_details', 'hs_leviathan_linked_vids', 'STRING', 46, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_company_id', 'STRING', 'event_details_base', 'hs_company_id', 'STRING', 'event_details', 'hs_company_id', 'STRING', 47, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_company_domain', 'STRING', 'event_details_base', 'hs_company_domain', 'STRING', 'event_details', 'hs_company_domain', 'STRING', 48, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_company_domain_by_association', 'STRING', 'event_details_base', 'hs_company_domain_by_association', 'STRING', 'event_details', 'hs_company_domain_by_association', 'STRING', 49, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_historical_contact_associatedcompanyid', 'STRING', 'event_details_base', 'hs_historical_contact_associatedcompanyid', 'STRING', 'event_details', 'hs_historical_contact_associatedcompanyid', 'STRING', 50, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'event_details', 'properties_hs_historical_contact_lifecyclestage', 'STRING', 'event_details_base', 'hs_historical_contact_lifecyclestage', 'STRING', 'event_details', 'hs_historical_contact_lifecyclestage', 'STRING', 51, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_deals]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_deals', 'id', 'STRING', 'crm_deals_base', 'id', 'STRING', 'crm_deals', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'createdAt', 'STRING', 'crm_deals_base', 'created_at', 'STRING', 'crm_deals', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'updatedAt', 'STRING', 'crm_deals_base', 'updated_at', 'STRING', 'crm_deals', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'archived', 'STRING', 'crm_deals_base', 'archived', 'STRING', 'crm_deals', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'archivedAt', 'STRING', 'crm_deals_base', 'archived_at', 'STRING', 'crm_deals', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'objectWriteTraceId', 'STRING', 'crm_deals_base', 'object_write_trace_id', 'STRING', 'crm_deals', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'url', 'STRING', 'crm_deals_base', 'url', 'STRING', 'crm_deals', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'properties', 'STRING', 'crm_deals_base', 'properties', 'STRING', 'crm_deals', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_deals', 'N/A', 'STRING', 'crm_deals_base', 'N/A', 'STRING', 'crm_deals', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_tickets]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_tickets', 'id', 'STRING', 'crm_tickets_base', 'id', 'STRING', 'crm_tickets', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'createdAt', 'STRING', 'crm_tickets_base', 'created_at', 'STRING', 'crm_tickets', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'updatedAt', 'STRING', 'crm_tickets_base', 'updated_at', 'STRING', 'crm_tickets', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'archived', 'STRING', 'crm_tickets_base', 'archived', 'STRING', 'crm_tickets', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'archivedAt', 'STRING', 'crm_tickets_base', 'archived_at', 'STRING', 'crm_tickets', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'objectWriteTraceId', 'STRING', 'crm_tickets_base', 'object_write_trace_id', 'STRING', 'crm_tickets', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'url', 'STRING', 'crm_tickets_base', 'url', 'STRING', 'crm_tickets', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'properties', 'STRING', 'crm_tickets_base', 'properties', 'STRING', 'crm_tickets', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tickets', 'N/A', 'STRING', 'crm_tickets_base', 'N/A', 'STRING', 'crm_tickets', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_products]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_products', 'id', 'STRING', 'crm_products_base', 'id', 'STRING', 'crm_products', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'createdAt', 'STRING', 'crm_products_base', 'created_at', 'STRING', 'crm_products', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'updatedAt', 'STRING', 'crm_products_base', 'updated_at', 'STRING', 'crm_products', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'archived', 'STRING', 'crm_products_base', 'archived', 'STRING', 'crm_products', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'archivedAt', 'STRING', 'crm_products_base', 'archived_at', 'STRING', 'crm_products', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'objectWriteTraceId', 'STRING', 'crm_products_base', 'object_write_trace_id', 'STRING', 'crm_products', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'url', 'STRING', 'crm_products_base', 'url', 'STRING', 'crm_products', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'properties', 'STRING', 'crm_products_base', 'properties', 'STRING', 'crm_products', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_products', 'N/A', 'STRING', 'crm_products_base', 'N/A', 'STRING', 'crm_products', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_line_items]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_line_items', 'id', 'STRING', 'crm_line_items_base', 'id', 'STRING', 'crm_line_items', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'createdAt', 'STRING', 'crm_line_items_base', 'created_at', 'STRING', 'crm_line_items', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'updatedAt', 'STRING', 'crm_line_items_base', 'updated_at', 'STRING', 'crm_line_items', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'archived', 'STRING', 'crm_line_items_base', 'archived', 'STRING', 'crm_line_items', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'archivedAt', 'STRING', 'crm_line_items_base', 'archived_at', 'STRING', 'crm_line_items', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'objectWriteTraceId', 'STRING', 'crm_line_items_base', 'object_write_trace_id', 'STRING', 'crm_line_items', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'url', 'STRING', 'crm_line_items_base', 'url', 'STRING', 'crm_line_items', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'properties', 'STRING', 'crm_line_items_base', 'properties', 'STRING', 'crm_line_items', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_line_items', 'N/A', 'STRING', 'crm_line_items_base', 'N/A', 'STRING', 'crm_line_items', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_quotes]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_quotes', 'id', 'STRING', 'crm_quotes_base', 'id', 'STRING', 'crm_quotes', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'createdAt', 'STRING', 'crm_quotes_base', 'created_at', 'STRING', 'crm_quotes', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'updatedAt', 'STRING', 'crm_quotes_base', 'updated_at', 'STRING', 'crm_quotes', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'archived', 'STRING', 'crm_quotes_base', 'archived', 'STRING', 'crm_quotes', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'archivedAt', 'STRING', 'crm_quotes_base', 'archived_at', 'STRING', 'crm_quotes', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'objectWriteTraceId', 'STRING', 'crm_quotes_base', 'object_write_trace_id', 'STRING', 'crm_quotes', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'url', 'STRING', 'crm_quotes_base', 'url', 'STRING', 'crm_quotes', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'properties', 'STRING', 'crm_quotes_base', 'properties', 'STRING', 'crm_quotes', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_quotes', 'N/A', 'STRING', 'crm_quotes_base', 'N/A', 'STRING', 'crm_quotes', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_calls]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_calls', 'id', 'STRING', 'crm_calls_base', 'id', 'STRING', 'crm_calls', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'createdAt', 'STRING', 'crm_calls_base', 'created_at', 'STRING', 'crm_calls', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'updatedAt', 'STRING', 'crm_calls_base', 'updated_at', 'STRING', 'crm_calls', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'archived', 'STRING', 'crm_calls_base', 'archived', 'STRING', 'crm_calls', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'archivedAt', 'STRING', 'crm_calls_base', 'archived_at', 'STRING', 'crm_calls', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'objectWriteTraceId', 'STRING', 'crm_calls_base', 'object_write_trace_id', 'STRING', 'crm_calls', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'url', 'STRING', 'crm_calls_base', 'url', 'STRING', 'crm_calls', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'properties', 'STRING', 'crm_calls_base', 'properties', 'STRING', 'crm_calls', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_calls', 'N/A', 'STRING', 'crm_calls_base', 'N/A', 'STRING', 'crm_calls', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_meetings]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_meetings', 'id', 'STRING', 'crm_meetings_base', 'id', 'STRING', 'crm_meetings', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'createdAt', 'STRING', 'crm_meetings_base', 'created_at', 'STRING', 'crm_meetings', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'updatedAt', 'STRING', 'crm_meetings_base', 'updated_at', 'STRING', 'crm_meetings', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'archived', 'STRING', 'crm_meetings_base', 'archived', 'STRING', 'crm_meetings', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'archivedAt', 'STRING', 'crm_meetings_base', 'archived_at', 'STRING', 'crm_meetings', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'objectWriteTraceId', 'STRING', 'crm_meetings_base', 'object_write_trace_id', 'STRING', 'crm_meetings', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'url', 'STRING', 'crm_meetings_base', 'url', 'STRING', 'crm_meetings', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'properties', 'STRING', 'crm_meetings_base', 'properties', 'STRING', 'crm_meetings', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_meetings', 'N/A', 'STRING', 'crm_meetings_base', 'N/A', 'STRING', 'crm_meetings', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_notes]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_notes', 'id', 'STRING', 'crm_notes_base', 'id', 'STRING', 'crm_notes', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'createdAt', 'STRING', 'crm_notes_base', 'created_at', 'STRING', 'crm_notes', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'updatedAt', 'STRING', 'crm_notes_base', 'updated_at', 'STRING', 'crm_notes', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'archived', 'STRING', 'crm_notes_base', 'archived', 'STRING', 'crm_notes', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'archivedAt', 'STRING', 'crm_notes_base', 'archived_at', 'STRING', 'crm_notes', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'objectWriteTraceId', 'STRING', 'crm_notes_base', 'object_write_trace_id', 'STRING', 'crm_notes', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'url', 'STRING', 'crm_notes_base', 'url', 'STRING', 'crm_notes', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'properties', 'STRING', 'crm_notes_base', 'properties', 'STRING', 'crm_notes', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_notes', 'N/A', 'STRING', 'crm_notes_base', 'N/A', 'STRING', 'crm_notes', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());

-- [crm_tasks]  (no JSON file)
INSERT INTO schema_config (source_name, landing_table_name, landing_column_name, landing_data_type, bronze_table_name, bronze_column_name, bronze_data_type, silver_table_name, silver_column_name, silver_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_nullable, default_value, is_active, created_at)
VALUES
  ('HubSpot', 'crm_tasks', 'id', 'STRING', 'crm_tasks_base', 'id', 'STRING', 'crm_tasks', 'id', 'STRING', 1, 1, 1, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'createdAt', 'STRING', 'crm_tasks_base', 'created_at', 'STRING', 'crm_tasks', 'created_at', 'STRING', 2, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'updatedAt', 'STRING', 'crm_tasks_base', 'updated_at', 'STRING', 'crm_tasks', 'updated_at', 'STRING', 3, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'archived', 'STRING', 'crm_tasks_base', 'archived', 'STRING', 'crm_tasks', 'archived', 'BOOLEAN', 4, 1, 0, 0, '0', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'archivedAt', 'STRING', 'crm_tasks_base', 'archived_at', 'STRING', 'crm_tasks', 'archived_at', 'STRING', 5, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'objectWriteTraceId', 'STRING', 'crm_tasks_base', 'object_write_trace_id', 'STRING', 'crm_tasks', 'object_write_trace_id', 'STRING', 6, 1, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'url', 'STRING', 'crm_tasks_base', 'url', 'STRING', 'crm_tasks', 'url', 'STRING', 7, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'properties', 'STRING', 'crm_tasks_base', 'properties', 'STRING', 'crm_tasks', 'properties_json', 'STRING', 8, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE()),
  ('HubSpot', 'crm_tasks', 'N/A', 'STRING', 'crm_tasks_base', 'N/A', 'STRING', 'crm_tasks', 'object_type', 'STRING', 9, 0, 0, 0, 'NOT_PROVIDED', 1, GETUTCDATE());
