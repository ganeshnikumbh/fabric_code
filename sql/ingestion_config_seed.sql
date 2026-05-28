-- ============================================================
-- ingestion_config — DDL + Seed Data
-- Database : eq_control
-- Tables   : ingestion_config, source_load_control
-- ============================================================
-- Deployment order:
--   1. Run this file  (creates tables, loads ingestion_config seed)
--   2. Run schema_config_seed.sql  (creates schema_config, loads mappings)
-- ============================================================


-- ── TABLE: ingestion_config ──────────────────────────────────────────────────

IF OBJECT_ID('dbo.ingestion_config', 'U') IS NOT NULL
    DROP TABLE dbo.ingestion_config;
GO

CREATE TABLE dbo.ingestion_config (
    source_id           INT             NOT NULL    IDENTITY(1,1),
    source_name         NVARCHAR(100)   NOT NULL,
    source_type         NVARCHAR(50)    NOT NULL,   -- sqlserver | oracle | api | sftp | blob
    source_schema       NVARCHAR(100)   NULL,       -- schema in source system; NULL for non-DB sources
    entity_name         NVARCHAR(200)   NOT NULL,
    target_lakehouse    NVARCHAR(100)   NOT NULL,
    target_schema       NVARCHAR(100)   NOT NULL,
    target_table        NVARCHAR(200)   NOT NULL,
    load_type           NVARCHAR(20)    NOT NULL,   -- full | incremental | cdc
    watermark_column    NVARCHAR(100)   NULL,
    watermark_type      NVARCHAR(20)    NULL,       -- datetime | integer | string
    batch_size          INT             NULL,
    partition_by_column_names NVARCHAR(500) NULL,
    is_scd2             BIT             NOT NULL    CONSTRAINT df_ingestion_config_scd2    DEFAULT (0),
    src_busn_asst       NVARCHAR(50)    NULL,
    extraction_query    NVARCHAR(MAX)   NULL,
    api_endpoint        NVARCHAR(500)   NULL,
    api_method          NVARCHAR(10)    NULL,
    api_headers         NVARCHAR(MAX)   NULL,
    source_path         NVARCHAR(200)   NULL,       -- path within API JSON to the records array (e.g. 'results', 'result.data'); empty string = single-record response
    active_flag         BIT             NOT NULL    CONSTRAINT df_ingestion_config_active  DEFAULT (1),
    created_by          NVARCHAR(100)   NOT NULL    CONSTRAINT df_ingestion_config_created_by   DEFAULT ('fabric-pipeline-svc'),
    created_date        DATETIME2       NOT NULL    CONSTRAINT df_ingestion_config_created_date DEFAULT (SYSUTCDATETIME()),
    modified_by         NVARCHAR(100)   NULL,
    modified_date       DATETIME2       NULL,
    CONSTRAINT pk_ingestion_config PRIMARY KEY (source_id)
);
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED: ingestion_config — EQ_Warehouse + EQ_ODS
-- SET IDENTITY_INSERT preserves original source_ids so pipeline references
-- remain stable across redeployments.
-- ══════════════════════════════════════════════════════════════════════════════

SET IDENTITY_INSERT dbo.ingestion_config ON;
GO

INSERT INTO dbo.ingestion_config
    (source_id, source_name, source_type, source_schema, entity_name,
     target_lakehouse, target_schema, target_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, active_flag, src_busn_asst)
VALUES
-- ── Reference / lookup tables ─────────────────────────────────────────────
(1,  'EQ_Warehouse', 'sqlserver', 'dbo', 'Date',                          'lh_bronze', 'bronze_eqwarehouse', 'date_base',                              'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(2,  'EQ_Warehouse', 'sqlserver', 'dbo', 'State',                         'lh_bronze', 'bronze_eqwarehouse', 'state_base',                             'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(3,  'EQ_Warehouse', 'sqlserver', 'dbo', 'Company',                       'lh_bronze', 'bronze_eqwarehouse', 'company_base',                           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(4,  'EQ_Warehouse', 'sqlserver', 'dbo', 'ActivityType',                  'lh_bronze', 'bronze_eqwarehouse', 'activity_type_base',                     'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(5,  'EQ_Warehouse', 'sqlserver', 'dbo', 'CommissionLevelRank',           'lh_bronze', 'bronze_eqwarehouse', 'commission_level_rank_base',             'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(6,  'EQ_Warehouse', 'sqlserver', 'dbo', 'InvestmentDetail',              'lh_bronze', 'bronze_eqwarehouse', 'investment_detail_base',                 'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(7,  'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingAccount',             'lh_bronze', 'bronze_eqwarehouse', 'accounting_account_base',                'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(8,  'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductVariationDetail',        'lh_bronze', 'bronze_eqwarehouse', 'product_variation_detail_base',          'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(9,  'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingReporting_Group',     'lh_bronze', 'bronze_eqwarehouse', 'accounting_reporting_group_base',        'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(10, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingCourse',                'lh_bronze', 'bronze_eqwarehouse', 'training_course_base',                   'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
-- ── Core entities ─────────────────────────────────────────────────────────
(11, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Product',                       'lh_bronze', 'bronze_eqwarehouse', 'product_base',                           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(12, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Surrender',                     'lh_bronze', 'bronze_eqwarehouse', 'surrender_base',                         'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(13, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Territory',                     'lh_bronze', 'bronze_eqwarehouse', 'territory_base',                         'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(14, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Client',                        'lh_bronze', 'bronze_eqwarehouse', 'client_base',                            'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(15, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Agent',                         'lh_bronze', 'bronze_eqwarehouse', 'agent_base',                             'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(16, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Investment',                    'lh_bronze', 'bronze_eqwarehouse', 'investment_base',                        'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(17, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateApproval',          'lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_base',            'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(18, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateVariation',         'lh_bronze', 'bronze_eqwarehouse', 'product_state_variation_base',           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(19, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateApprovalDisclosure','lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_disclosure_base', 'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(20, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Contract',                      'lh_bronze', 'bronze_eqwarehouse', 'contract_base',                          'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
-- ── Relationship tables ────────────────────────────────────────────────────
(21, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentContract',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_contract_base',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(22, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentLicense_Group',            'lh_bronze', 'bronze_eqwarehouse', 'agent_license_group_base',               'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(23, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentPrincipal_Group',          'lh_bronze', 'bronze_eqwarehouse', 'agent_principal_group_base',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(24, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentTraining',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_training_base',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(25, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingProduct_Group',         'lh_bronze', 'bronze_eqwarehouse', 'training_product_group_base',            'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(26, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingState_Group',           'lh_bronze', 'bronze_eqwarehouse', 'training_state_group_base',              'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(27, 'EQ_Warehouse', 'sqlserver', 'dbo', 'HierarchyTerritory',            'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_territory_base',               'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(28, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy',                     'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_base',                         'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(29, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_SuperHierarchy',      'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_super_hierarchy_base',         'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(30, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_Bridge',              'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_bridge_base',                  'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(31, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_Option',              'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_option_base',                  'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(32, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountValue',                  'lh_bronze', 'bronze_eqwarehouse', 'account_value_base',                     'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(33, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ExternalAccount_Group',         'lh_bronze', 'bronze_eqwarehouse', 'external_account_group_base',            'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(34, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AdditionalClient_Group',        'lh_bronze', 'bronze_eqwarehouse', 'additional_client_group_base',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(35, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AdditionalInfo_Group',          'lh_bronze', 'bronze_eqwarehouse', 'additional_info_group_base',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(36, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Reinsurance_Group',             'lh_bronze', 'bronze_eqwarehouse', 'reinsurance_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
-- ── Transaction / event tables ─────────────────────────────────────────────
(37, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Activity',                      'lh_bronze', 'bronze_eqwarehouse', 'activity_base',                          'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1, 'elic'),
(38, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ActivityFinancial',             'lh_bronze', 'bronze_eqwarehouse', 'activity_financial_base',                'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1, 'elic'),
(39, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Accounting',                    'lh_bronze', 'bronze_eqwarehouse', 'accounting_base',                        'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1, 'elic'),
(40, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingDetail',              'lh_bronze', 'bronze_eqwarehouse', 'accounting_detail_base',                 'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1, 'elic'),
(41, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ContractValue_Group',           'lh_bronze', 'bronze_eqwarehouse', 'contract_value_group_base',              'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(42, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ContractDeposit_Group',         'lh_bronze', 'bronze_eqwarehouse', 'contract_deposit_group_base',            'incremental', 'DepositDate',      'datetime', 50000,  NULL, 0, 1, 'elic'),
(43, 'EQ_Warehouse', 'sqlserver', 'dbo', 'RecurringPayment_Group',        'lh_bronze', 'bronze_eqwarehouse', 'recurring_payment_group_base',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(44, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentSummary_Group',            'lh_bronze', 'bronze_eqwarehouse', 'agent_summary_group_base',               'incremental', 'SummaryDate',      'datetime', 50000,  NULL, 0, 1, 'elic'),
(45, 'EQ_Warehouse', 'sqlserver', 'dbo', 'IndexValue_Group',              'lh_bronze', 'bronze_eqwarehouse', 'index_value_group_base',                 'incremental', 'IndexDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(46, 'EQ_Warehouse', 'sqlserver', 'dbo', 'RenewalRate_Group',             'lh_bronze', 'bronze_eqwarehouse', 'renewal_rate_group_base',                'incremental', 'RateEffectiveDate','datetime', 50000,  NULL, 0, 1, 'elic'),
(47, 'EQ_Warehouse', 'sqlserver', 'dbo', 'CAPRepayment',                  'lh_bronze', 'bronze_eqwarehouse', 'cap_repayment_base',                     'incremental', 'RepaymentDate',    'datetime', 50000,  NULL, 1, 1, 'elic'),
(48, 'EQ_Warehouse', 'sqlserver', 'dbo', 'CAPStatusChange',               'lh_bronze', 'bronze_eqwarehouse', 'cap_status_change_base',                 'incremental', 'ChangeDate',       'datetime', 50000,  NULL, 1, 1, 'elic'),
(49, 'EQ_Warehouse', 'sqlserver', 'hedge', 'Ratios',                      'lh_bronze', 'bronze_eqwarehouse', 'hedge_ratios_base',                      'incremental', 'RatioDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(50, 'EQ_Warehouse', 'sqlserver', 'hedge', 'Options',                     'lh_bronze', 'bronze_eqwarehouse', 'hedge_options_base',                     'incremental', 'OptionDate',       'datetime', 50000,  NULL, 0, 1, 'elic'),
-- ── Remaining groups ──────────────────────────────────────────────────────
(51, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Rider_Group',                   'lh_bronze', 'bronze_eqwarehouse', 'rider_group_base',                       'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(52, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Requirement_Group',             'lh_bronze', 'bronze_eqwarehouse', 'requirement_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(53, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Note_Group',                    'lh_bronze', 'bronze_eqwarehouse', 'note_group_base',                        'incremental', 'NoteDate',         'datetime', 50000,  NULL, 0, 1, 'elic'),
(54, 'EQ_Warehouse', 'sqlserver', 'dbo', 'LastProcessing',                'lh_bronze', 'bronze_eqwarehouse', 'last_processing_base',                   'full',        NULL,               NULL,       NULL,   NULL, 0, 0, 'elic'),
-- ── EQ_ODS ────────────────────────────────────────────────────────────────
(55, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ContractClient',            'lh_landing', 'seg_editsolutions', 'contract_client_base',            'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(56, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ClientRole',                'lh_landing', 'seg_editsolutions', 'client_role_base',                'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(57, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ClientDetail',              'lh_landing', 'seg_editsolutions', 'client_detail_base',              'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(58, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ContractClientAllocation',  'lh_landing', 'seg_editsolutions', 'contract_client_allocation_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(59, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'Segment',                   'lh_landing', 'seg_editsolutions', 'segment_base',                    'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(60, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'Agent',                     'lh_landing', 'seg_editsolutions', 'agent_ods_base',                  'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(61, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ContractTreaty',            'lh_landing', 'seg_editsolutions', 'contract_treaty_base',            'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(62, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ref_Product',               'lh_landing', 'seg_editsolutions', 'ref_product_base',                'full', NULL, NULL, NULL, NULL, 0, 0, 'elic'),
(63, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'Treaty',                    'lh_landing', 'seg_editsolutions', 'treaty_base',                     'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(64, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'TreatyGroup',               'lh_landing', 'seg_editsolutions', 'treaty_group_base',               'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(65, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'EDITTrx',                   'lh_landing', 'seg_editsolutions', 'edit_trx_base',                   'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(66, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'ClientSetup',               'lh_landing', 'seg_editsolutions', 'client_setup_base',               'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(67, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'EDITTrxHistory',            'lh_landing', 'seg_editsolutions', 'edit_trx_history_base',           'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(68, 'EQ_ODS', 'sqlserver', 'seg_editsolutions', 'FinancialHistory',          'lh_landing', 'seg_editsolutions', 'financial_history_base',          'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(69, 'EQ_ODS', 'sqlserver', 'seg_engine',        'ProductStructure',          'lh_landing', 'seg_editsolutions', 'product_structure_base',          'full', NULL, NULL, NULL, NULL, 0, 1, 'elic');
GO

SET IDENTITY_INSERT dbo.ingestion_config OFF;
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED: ingestion_config — HubSpot API sources
-- source_path included in INSERT; no separate UPDATE needed.
-- ══════════════════════════════════════════════════════════════════════════════

SET IDENTITY_INSERT dbo.ingestion_config ON;
GO

INSERT INTO dbo.ingestion_config
    (source_id, source_name, source_type, source_schema, entity_name,
     target_lakehouse, target_schema, target_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, api_endpoint, api_method, active_flag, src_busn_asst, source_path)
VALUES
(70, 'HubSpot', 'api', 'hubspot', 'marketing_events',
     'lh_landing', 'bronze_hubspot', 'marketing_events_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/marketing-events/{period}',            'GET', 1, 'elic', 'results'),

(71, 'HubSpot', 'api', 'hubspot', 'marketing_emails',
     'lh_landing', 'bronze_hubspot', 'marketing_emails_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/v3/emails/',                           'GET', 1, 'elic', 'results'),

(72, 'HubSpot', 'api', 'hubspot', 'events_event_types',
     'lh_landing', 'bronze_hubspot', 'events_event_types_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/events/v3/events/event-types',                   'GET', 1, 'elic', 'results'),

(73, 'HubSpot', 'api', 'hubspot', 'crm_contacts',
     'lh_landing', 'bronze_hubspot', 'crm_contacts_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/crm/objects/2025-09/contacts',                   'GET', 1, 'elic', 'results'),

(74, 'HubSpot', 'api', 'hubspot', 'crm_companies',
     'lh_landing', 'bronze_hubspot', 'crm_companies_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/crm/objects/2025-09/companies',                  'GET', 1, 'elic', 'results'),

(75, 'HubSpot', 'api', 'hubspot', 'marketing_email_statistics',
     'lh_landing', 'bronze_hubspot', 'marketing_email_statistics_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/v3/emails/{emailId}/statistics/list',  'GET', 1, 'elic', ''),

(76, 'HubSpot', 'api', 'hubspot', 'event_details',
     'lh_landing', 'bronze_hubspot', 'event_details_base',
     'full', NULL, NULL, NULL, NULL,
     0, '/events/v3/events',                               'GET', 1, 'elic', 'results');
GO

SET IDENTITY_INSERT dbo.ingestion_config OFF;
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED: ingestion_config — Webex API sources
-- No explicit source_id — IDENTITY assigns the next available value.
-- Add new API sources here the same way going forward.
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.ingestion_config
    (source_name, source_type, source_schema, entity_name,
     target_lakehouse, target_schema, target_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, active_flag, src_busn_asst, source_path)
VALUES
('Webex', 'api', 'webex', 'aar', 'lh_landing', 'bronze_webex', 'aar_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'webex', 'asr', 'lh_landing', 'bronze_webex', 'asr_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'webex', 'csr', 'lh_landing', 'bronze_webex', 'csr_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'webex', 'clr', 'lh_landing', 'bronze_webex', 'clr_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'webex', 'car', 'lh_landing', 'bronze_webex', 'car_base', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data');
GO
