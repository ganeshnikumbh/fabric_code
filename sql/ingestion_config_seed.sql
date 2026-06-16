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
    source_id                 INT             NOT NULL    IDENTITY(1,1),
    source_name               NVARCHAR(100)   NOT NULL,
    source_type               NVARCHAR(50)    NOT NULL,   -- sqlserver | oracle | api | sftp | blob
    landing_lakehouse         NVARCHAR(100)   NULL,       -- lakehouse where raw data lands (e.g. lh_landing)
    landing_schema            NVARCHAR(100)   NULL,       -- schema in landing / source system; NULL for non-DB sources
    landing_table_name        NVARCHAR(200)   NOT NULL,
    bronze_lakehouse          NVARCHAR(100)   NOT NULL,
    bronze_schema             NVARCHAR(100)   NOT NULL,
    bronze_table              NVARCHAR(200)   NOT NULL,
    silver_lakehouse          NVARCHAR(100)   NULL,
    silver_schema             NVARCHAR(100)   NULL,
    silver_table              NVARCHAR(200)   NULL,
    load_type                 NVARCHAR(20)    NOT NULL,   -- full | incremental | cdc
    watermark_column          NVARCHAR(100)   NULL,
    watermark_type            NVARCHAR(20)    NULL,       -- datetime | integer | string
    batch_size                INT             NULL,
    partition_by_column_names NVARCHAR(500)   NULL,
    is_scd2                   BIT             NOT NULL    CONSTRAINT df_ingestion_config_scd2    DEFAULT (0),
    src_busn_asst             NVARCHAR(50)    NULL,
    extraction_query          NVARCHAR(MAX)   NULL,
    api_endpoint              NVARCHAR(500)   NULL,
    api_method                NVARCHAR(10)    NULL,
    api_headers               NVARCHAR(MAX)   NULL,
    source_path               NVARCHAR(200)   NULL,       -- path within API JSON to the records array (e.g. 'results', 'result.data'); empty string = single-record response
    active_flag               BIT             NOT NULL    CONSTRAINT df_ingestion_config_active  DEFAULT (1),
    created_by                NVARCHAR(100)   NOT NULL    CONSTRAINT df_ingestion_config_created_by   DEFAULT ('fabric-pipeline-svc'),
    created_date              DATETIME2       NOT NULL    CONSTRAINT df_ingestion_config_created_date DEFAULT (SYSUTCDATETIME()),
    modified_by               NVARCHAR(100)   NULL,
    modified_date             DATETIME2       NULL,
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
    (source_id, source_name, source_type,
     landing_lakehouse, landing_schema, landing_table_name,
     bronze_lakehouse, bronze_schema, bronze_table,
     silver_lakehouse, silver_schema, silver_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, active_flag, src_busn_asst)
VALUES
-- ── Reference / lookup tables ─────────────────────────────────────────────
(1,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Date',                          'lh_bronze', 'bronze_eqwarehouse', 'date_base',                              'lh_silver', 'silver_s1', 'date',                              'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(2,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'State',                         'lh_bronze', 'bronze_eqwarehouse', 'state_base',                             'lh_silver', 'silver_s1', 'state',                             'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(3,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Company',                       'lh_bronze', 'bronze_eqwarehouse', 'company_base',                           'lh_silver', 'silver_s1', 'company',                           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(4,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ActivityType',                  'lh_bronze', 'bronze_eqwarehouse', 'activity_type_base',                     'lh_silver', 'silver_s1', 'activity_type',                     'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(5,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'CommissionLevelRank',           'lh_bronze', 'bronze_eqwarehouse', 'commission_level_rank_base',             'lh_silver', 'silver_s1', 'commission_level_rank',             'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(6,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'InvestmentDetail',              'lh_bronze', 'bronze_eqwarehouse', 'investment_detail_base',                 'lh_silver', 'silver_s1', 'investment_detail',                 'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(7,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AccountingAccount',             'lh_bronze', 'bronze_eqwarehouse', 'accounting_account_base',                'lh_silver', 'silver_s1', 'accounting_account',                'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(8,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ProductVariationDetail',        'lh_bronze', 'bronze_eqwarehouse', 'product_variation_detail_base',          'lh_silver', 'silver_s1', 'product_variation_detail',          'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(9,  'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AccountingReporting_Group',     'lh_bronze', 'bronze_eqwarehouse', 'accounting_reporting_group_base',        'lh_silver', 'silver_s1', 'accounting_reporting_group',        'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(10, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'TrainingCourse',                'lh_bronze', 'bronze_eqwarehouse', 'training_course_base',                   'lh_silver', 'silver_s1', 'training_course',                   'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
-- ── Core entities ─────────────────────────────────────────────────────────
(11, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Product',                       'lh_bronze', 'bronze_eqwarehouse', 'product_base',                           'lh_silver', 'silver_s1', 'product',                           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(12, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Surrender',                     'lh_bronze', 'bronze_eqwarehouse', 'surrender_base',                         'lh_silver', 'silver_s1', 'surrender',                         'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(13, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Territory',                     'lh_bronze', 'bronze_eqwarehouse', 'territory_base',                         'lh_silver', 'silver_s1', 'territory',                         'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(14, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Client',                        'lh_bronze', 'bronze_eqwarehouse', 'client_base',                            'lh_silver', 'silver_s1', 'client',                            'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(15, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Agent',                         'lh_bronze', 'bronze_eqwarehouse', 'agent_base',                             'lh_silver', 'silver_s1', 'agent',                             'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(16, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Investment',                    'lh_bronze', 'bronze_eqwarehouse', 'investment_base',                        'lh_silver', 'silver_s1', 'investment',                        'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(17, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ProductStateApproval',          'lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_base',            'lh_silver', 'silver_s1', 'product_state_approval',            'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(18, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ProductStateVariation',         'lh_bronze', 'bronze_eqwarehouse', 'product_state_variation_base',           'lh_silver', 'silver_s1', 'product_state_variation',           'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(19, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ProductStateApprovalDisclosure','lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_disclosure_base', 'lh_silver', 'silver_s1', 'product_state_approval_disclosure', 'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(20, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Contract',                      'lh_bronze', 'bronze_eqwarehouse', 'contract_base',                          'lh_silver', 'silver_s1', 'contract',                          'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
-- ── Relationship tables ────────────────────────────────────────────────────
(21, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AgentContract',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_contract_base',                    'lh_silver', 'silver_s1', 'agent_contract',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(22, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AgentLicense_Group',            'lh_bronze', 'bronze_eqwarehouse', 'agent_license_group_base',               'lh_silver', 'silver_s1', 'agent_license_group',               'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(23, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AgentPrincipal_Group',          'lh_bronze', 'bronze_eqwarehouse', 'agent_principal_group_base',             'lh_silver', 'silver_s1', 'agent_principal_group',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(24, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AgentTraining',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_training_base',                    'lh_silver', 'silver_s1', 'agent_training',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(25, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'TrainingProduct_Group',         'lh_bronze', 'bronze_eqwarehouse', 'training_product_group_base',            'lh_silver', 'silver_s1', 'training_product_group',            'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(26, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'TrainingState_Group',           'lh_bronze', 'bronze_eqwarehouse', 'training_state_group_base',              'lh_silver', 'silver_s1', 'training_state_group',              'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(27, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'HierarchyTerritory',            'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_territory_base',               'lh_silver', 'silver_s1', 'hierarchy_territory',               'full',        NULL,               NULL,       NULL,   NULL, 0, 1, 'elic'),
(28, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Hierarchy',                     'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_base',                         'lh_silver', 'silver_s1', 'hierarchy',                         'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(29, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Hierarchy_SuperHierarchy',      'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_super_hierarchy_base',         'lh_silver', 'silver_s1', 'hierarchy_super_hierarchy',         'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(30, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Hierarchy_Bridge',              'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_bridge_base',                  'lh_silver', 'silver_s1', 'hierarchy_bridge',                  'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(31, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Hierarchy_Option',              'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_option_base',                  'lh_silver', 'silver_s1', 'hierarchy_option',                  'full',        NULL,               NULL,       NULL,   NULL, 1, 1, 'elic'),
(32, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AccountValue',                  'lh_bronze', 'bronze_eqwarehouse', 'account_value_base',                     'lh_silver', 'silver_s1', 'account_value',                     'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(33, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ExternalAccount_Group',         'lh_bronze', 'bronze_eqwarehouse', 'external_account_group_base',            'lh_silver', 'silver_s1', 'external_account_group',            'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(34, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AdditionalClient_Group',        'lh_bronze', 'bronze_eqwarehouse', 'additional_client_group_base',           'lh_silver', 'silver_s1', 'additional_client_group',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(35, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AdditionalInfo_Group',          'lh_bronze', 'bronze_eqwarehouse', 'additional_info_group_base',             'lh_silver', 'silver_s1', 'additional_info_group',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(36, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Reinsurance_Group',             'lh_bronze', 'bronze_eqwarehouse', 'reinsurance_group_base',                 'lh_silver', 'silver_s1', 'reinsurance_group',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
-- ── Transaction / event tables ─────────────────────────────────────────────
(37, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Activity',                      'lh_bronze', 'bronze_eqwarehouse', 'activity_base',                          'lh_silver', 'silver_s1', 'activity',                          'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1, 'elic'),
(38, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ActivityFinancial',             'lh_bronze', 'bronze_eqwarehouse', 'activity_financial_base',                'lh_silver', 'silver_s1', 'activity_financial',                'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1, 'elic'),
(39, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Accounting',                    'lh_bronze', 'bronze_eqwarehouse', 'accounting_base',                        'lh_silver', 'silver_s1', 'accounting',                        'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1, 'elic'),
(40, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AccountingDetail',              'lh_bronze', 'bronze_eqwarehouse', 'accounting_detail_base',                 'lh_silver', 'silver_s1', 'accounting_detail',                 'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1, 'elic'),
(41, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ContractValue_Group',           'lh_bronze', 'bronze_eqwarehouse', 'contract_value_group_base',              'lh_silver', 'silver_s1', 'contract_value_group',              'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(42, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'ContractDeposit_Group',         'lh_bronze', 'bronze_eqwarehouse', 'contract_deposit_group_base',            'lh_silver', 'silver_s1', 'contract_deposit_group',            'incremental', 'DepositDate',      'datetime', 50000,  NULL, 0, 1, 'elic'),
(43, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'RecurringPayment_Group',        'lh_bronze', 'bronze_eqwarehouse', 'recurring_payment_group_base',           'lh_silver', 'silver_s1', 'recurring_payment_group',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(44, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'AgentSummary_Group',            'lh_bronze', 'bronze_eqwarehouse', 'agent_summary_group_base',               'lh_silver', 'silver_s1', 'agent_summary_group',               'incremental', 'SummaryDate',      'datetime', 50000,  NULL, 0, 1, 'elic'),
(45, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'IndexValue_Group',              'lh_bronze', 'bronze_eqwarehouse', 'index_value_group_base',                 'lh_silver', 'silver_s1', 'index_value_group',                 'incremental', 'IndexDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(46, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'RenewalRate_Group',             'lh_bronze', 'bronze_eqwarehouse', 'renewal_rate_group_base',                'lh_silver', 'silver_s1', 'renewal_rate_group',                'incremental', 'RateEffectiveDate','datetime', 50000,  NULL, 0, 1, 'elic'),
(47, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'CAPRepayment',                  'lh_bronze', 'bronze_eqwarehouse', 'cap_repayment_base',                     'lh_silver', 'silver_s1', 'cap_repayment',                     'incremental', 'RepaymentDate',    'datetime', 50000,  NULL, 1, 1, 'elic'),
(48, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'CAPStatusChange',               'lh_bronze', 'bronze_eqwarehouse', 'cap_status_change_base',                 'lh_silver', 'silver_s1', 'cap_status_change',                 'incremental', 'ChangeDate',       'datetime', 50000,  NULL, 1, 1, 'elic'),
(49, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'hedge', 'Ratios',                      'lh_bronze', 'bronze_eqwarehouse', 'hedge_ratios_base',                      'lh_silver', 'silver_s1', 'hedge_ratios',                      'incremental', 'RatioDate',        'datetime', 50000,  NULL, 0, 1, 'elic'),
(50, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'hedge', 'Options',                     'lh_bronze', 'bronze_eqwarehouse', 'hedge_options_base',                     'lh_silver', 'silver_s1', 'hedge_options',                     'incremental', 'OptionDate',       'datetime', 50000,  NULL, 0, 1, 'elic'),
-- ── Remaining groups ──────────────────────────────────────────────────────
(51, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Rider_Group',                   'lh_bronze', 'bronze_eqwarehouse', 'rider_group_base',                       'lh_silver', 'silver_s1', 'rider_group',                       'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(52, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Requirement_Group',             'lh_bronze', 'bronze_eqwarehouse', 'requirement_group_base',                 'lh_silver', 'silver_s1', 'requirement_group',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 1, 1, 'elic'),
(53, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'Note_Group',                    'lh_bronze', 'bronze_eqwarehouse', 'note_group_base',                        'lh_silver', 'silver_s1', 'note_group',                        'incremental', 'NoteDate',         'datetime', 50000,  NULL, 0, 1, 'elic'),
(54, 'EQ_Warehouse', 'sqlserver', 'lh_landing', 'dbo', 'LastProcessing',                'lh_bronze', 'bronze_eqwarehouse', 'last_processing_base',                   'lh_silver', 'silver_s1', 'last_processing',                   'full',        NULL,               NULL,       NULL,   NULL, 0, 0, 'elic'),
-- ── EQ_ODS ────────────────────────────────────────────────────────────────
(55, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ContractClient',            'lh_bronze', 'seg_editsolutions', 'contract_client_base',            'lh_silver', 'silver_s1', 'contract_client',            'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(56, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ClientRole',                'lh_bronze', 'seg_editsolutions', 'client_role_base',                'lh_silver', 'silver_s1', 'client_role',                'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(57, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ClientDetail',              'lh_bronze', 'seg_editsolutions', 'client_detail_base',              'lh_silver', 'silver_s1', 'client_detail',              'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(58, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ContractClientAllocation',  'lh_bronze', 'seg_editsolutions', 'contract_client_allocation_base', 'lh_silver', 'silver_s1', 'contract_client_allocation', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(59, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'Segment',                   'lh_bronze', 'seg_editsolutions', 'segment_base',                    'lh_silver', 'silver_s1', 'segment',                    'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(60, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'Agent',                     'lh_bronze', 'seg_editsolutions', 'agent_ods_base',                  'lh_silver', 'silver_s1', 'agent_ods',                  'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(61, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ContractTreaty',            'lh_bronze', 'seg_editsolutions', 'contract_treaty_base',            'lh_silver', 'silver_s1', 'contract_treaty',            'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(62, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ref_Product',               'lh_bronze', 'seg_editsolutions', 'ref_product_base',                'lh_silver', 'silver_s1', 'ref_product',                'full', NULL, NULL, NULL, NULL, 0, 0, 'elic'),
(63, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'Treaty',                    'lh_bronze', 'seg_editsolutions', 'treaty_base',                     'lh_silver', 'silver_s1', 'treaty',                     'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(64, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'TreatyGroup',               'lh_bronze', 'seg_editsolutions', 'treaty_group_base',               'lh_silver', 'silver_s1', 'treaty_group',               'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(65, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'EDITTrx',                   'lh_bronze', 'seg_editsolutions', 'edit_trx_base',                   'lh_silver', 'silver_s1', 'edit_trx',                   'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(66, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'ClientSetup',               'lh_bronze', 'seg_editsolutions', 'client_setup_base',               'lh_silver', 'silver_s1', 'client_setup',               'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(67, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'EDITTrxHistory',            'lh_bronze', 'seg_editsolutions', 'edit_trx_history_base',           'lh_silver', 'silver_s1', 'edit_trx_history',           'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(68, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_editsolutions', 'FinancialHistory',          'lh_bronze', 'seg_editsolutions', 'financial_history_base',          'lh_silver', 'silver_s1', 'financial_history',          'full', NULL, NULL, NULL, NULL, 0, 1, 'elic'),
(69, 'EQ_ODS', 'sqlserver', 'lh_landing', 'seg_engine',        'ProductStructure',          'lh_bronze', 'seg_editsolutions', 'product_structure_base',          'lh_silver', 'silver_s1', 'product_structure',          'full', NULL, NULL, NULL, NULL, 0, 1, 'elic');
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
    (source_id, source_name, source_type,
     landing_lakehouse, landing_schema, landing_table_name,
     bronze_lakehouse, bronze_schema, bronze_table,
     silver_lakehouse, silver_schema, silver_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, api_endpoint, api_method, active_flag, src_busn_asst, source_path)
VALUES
(70, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'marketing_events',
     'lh_bronze', 'bronze_hubspot', 'marketing_events_base',
     'lh_silver', 'silver_s1', 'marketing_events',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/marketing-events/{period}',            'GET', 1, 'elic', 'results'),

(71, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'marketing_emails',
     'lh_bronze', 'bronze_hubspot', 'marketing_emails_base',
     'lh_silver', 'silver_s1', 'marketing_emails',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/v3/emails/',                           'GET', 1, 'elic', 'results'),

(72, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'events_event_types',
     'lh_bronze', 'bronze_hubspot', 'events_event_types_base',
     'lh_silver', 'silver_s1', 'events_event_types',
     'full', NULL, NULL, NULL, NULL,
     0, '/events/v3/events/event-types',                   'GET', 1, 'elic', 'results'),

(73, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'crm_contacts',
     'lh_bronze', 'bronze_hubspot', 'crm_contacts_base',
     'lh_silver', 'silver_s1', 'crm_contacts',
     'full', NULL, NULL, NULL, NULL,
     0, '/crm/objects/2025-09/contacts',                   'GET', 1, 'elic', 'results'),

(74, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'crm_companies',
     'lh_bronze', 'bronze_hubspot', 'crm_companies_base',
     'lh_silver', 'silver_s1', 'crm_companies',
     'full', NULL, NULL, NULL, NULL,
     0, '/crm/objects/2025-09/companies',                  'GET', 1, 'elic', 'results'),

(75, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'marketing_email_statistics',
     'lh_bronze', 'bronze_hubspot', 'marketing_email_statistics_base',
     'lh_silver', 'silver_s1', 'marketing_email_statistics',
     'full', NULL, NULL, NULL, NULL,
     0, '/marketing/v3/emails/{emailId}/statistics/list',  'GET', 1, 'elic', ''),

(76, 'HubSpot', 'api', 'lh_landing', 'hubspot', 'event_details',
     'lh_bronze', 'bronze_hubspot', 'event_details_base',
     'lh_silver', 'silver_s1', 'event_details',
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
    (source_name, source_type,
     landing_lakehouse, landing_schema, landing_table_name,
     bronze_lakehouse, bronze_schema, bronze_table,
     silver_lakehouse, silver_schema, silver_table,
     load_type, watermark_column, watermark_type, batch_size, partition_by_column_names,
     is_scd2, active_flag, src_busn_asst, source_path)
VALUES
('Webex', 'api', 'lh_landing', 'webex', 'agent_activity', 'lh_bronze', 'bronze_webex', 'agent_activity_base', 'lh_silver', 'silver_s1', 'agent_activity', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'lh_landing', 'webex', 'agent_session', 'lh_bronze', 'bronze_webex', 'agent_session_base', 'lh_silver', 'silver_s1', 'agent_session', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'lh_landing', 'webex', 'customer_session', 'lh_bronze', 'bronze_webex', 'customer_session_base', 'lh_silver', 'silver_s1', 'customer_session', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'lh_landing', 'webex', 'call_leg', 'lh_bronze', 'bronze_webex', 'call_leg_base', 'lh_silver', 'silver_s1', 'call_leg', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data'),
('Webex', 'api', 'lh_landing', 'webex', 'customer_activity', 'lh_bronze', 'bronze_webex', 'customer_activity_base', 'lh_silver', 'silver_s1', 'customer_activity', 'full', NULL, NULL, NULL, NULL, 0, 1, 'elic', 'result.data');
GO
