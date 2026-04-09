-- ============================================================
-- Fabric SQL Database — Control Tables DDL + Seed Data
-- Database : eq_control  (or the SQL DB you provision in Fabric)
-- Tables   : ingestion_config, schema_config
-- Generated: 2026-04-09
-- ============================================================


-- ── TABLE 1: ingestion_config ────────────────────────────────────────────────

IF OBJECT_ID('dbo.ingestion_config', 'U') IS NOT NULL
    DROP TABLE dbo.ingestion_config;
GO

CREATE TABLE dbo.ingestion_config (
    source_id           INT             NOT NULL,
    source_name         NVARCHAR(100)   NOT NULL,
    source_type         NVARCHAR(50)    NOT NULL,   -- sqlserver | oracle | api | sftp | blob
    entity_name         NVARCHAR(200)   NOT NULL,
    target_lakehouse    NVARCHAR(100)   NOT NULL,
    target_schema       NVARCHAR(100)   NOT NULL,
    target_table        NVARCHAR(200)   NOT NULL,
    load_type           NVARCHAR(20)    NOT NULL,   -- full | incremental | cdc
    watermark_column    NVARCHAR(100)   NULL,
    watermark_type      NVARCHAR(20)    NULL,       -- datetime | integer | string
    batch_size          INT             NULL,
    extraction_query    NVARCHAR(MAX)   NULL,
    api_endpoint        NVARCHAR(500)   NULL,
    api_method          NVARCHAR(10)    NULL,
    api_headers         NVARCHAR(MAX)   NULL,
    active_flag         BIT             NOT NULL    CONSTRAINT df_ingestion_config_active DEFAULT (1),
    created_by          NVARCHAR(100)   NOT NULL    CONSTRAINT df_ingestion_config_created_by DEFAULT ('fabric-pipeline-svc'),
    created_date        DATETIME2       NOT NULL    CONSTRAINT df_ingestion_config_created_date DEFAULT (SYSUTCDATETIME()),
    modified_by         NVARCHAR(100)   NULL,
    modified_date       DATETIME2       NULL,
    CONSTRAINT pk_ingestion_config PRIMARY KEY (source_id)
);
GO


-- ── TABLE 2: schema_config ───────────────────────────────────────────────────

IF OBJECT_ID('dbo.schema_config', 'U') IS NOT NULL
    DROP TABLE dbo.schema_config;
GO

CREATE TABLE dbo.schema_config (
    id                  INT             NOT NULL,
    source_table_name   NVARCHAR(200)   NOT NULL,
    source_column_name  NVARCHAR(200)   NOT NULL,
    target_column_name  NVARCHAR(200)   NOT NULL,
    target_data_type    NVARCHAR(100)   NOT NULL,
    ordinal_position    INT             NOT NULL,
    include_in_md5hash  BIT             NOT NULL    CONSTRAINT df_schema_config_hash DEFAULT (1),
    is_active           BIT             NOT NULL    CONSTRAINT df_schema_config_active DEFAULT (1),
    created_at          DATETIME2       NOT NULL    CONSTRAINT df_schema_config_created_at DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT pk_schema_config PRIMARY KEY (id)
);
GO

CREATE INDEX ix_schema_config_table_name
    ON dbo.schema_config (source_table_name);
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED DATA: ingestion_config  (62 rows — all EQ_Warehouse entities)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.ingestion_config
    (source_id, source_name, source_type, entity_name, target_lakehouse, target_schema, target_table, load_type, watermark_column, watermark_type, batch_size, active_flag)
VALUES
-- ── Reference / lookup tables (full load) ─────────────────────────────────
(1,  'EQ_Warehouse', 'sqlserver', 'Date',                         'lh_bronze', 'bronze_eqwarehouse', 'date_base',                              'full',        NULL,               NULL,       NULL,   1),
(2,  'EQ_Warehouse', 'sqlserver', 'State',                        'lh_bronze', 'bronze_eqwarehouse', 'state_base',                             'full',        NULL,               NULL,       NULL,   1),
(3,  'EQ_Warehouse', 'sqlserver', 'Company',                      'lh_bronze', 'bronze_eqwarehouse', 'company_base',                           'full',        NULL,               NULL,       NULL,   1),
(4,  'EQ_Warehouse', 'sqlserver', 'ActivityType',                 'lh_bronze', 'bronze_eqwarehouse', 'activity_type_base',                     'full',        NULL,               NULL,       NULL,   1),
(5,  'EQ_Warehouse', 'sqlserver', 'CommissionLevelRank',          'lh_bronze', 'bronze_eqwarehouse', 'commission_level_rank_base',             'full',        NULL,               NULL,       NULL,   1),
(6,  'EQ_Warehouse', 'sqlserver', 'InvestmentDetail',             'lh_bronze', 'bronze_eqwarehouse', 'investment_detail_base',                 'full',        NULL,               NULL,       NULL,   1),
(7,  'EQ_Warehouse', 'sqlserver', 'AccountingAccount',            'lh_bronze', 'bronze_eqwarehouse', 'accounting_account_base',                'full',        NULL,               NULL,       NULL,   1),
(8,  'EQ_Warehouse', 'sqlserver', 'ProductVariationDetail',       'lh_bronze', 'bronze_eqwarehouse', 'product_variation_detail_base',          'full',        NULL,               NULL,       NULL,   1),
(9,  'EQ_Warehouse', 'sqlserver', 'AccountingReporting_Group',    'lh_bronze', 'bronze_eqwarehouse', 'accounting_reporting_group_base',        'full',        NULL,               NULL,       NULL,   1),
(10, 'EQ_Warehouse', 'sqlserver', 'TrainingCourse',               'lh_bronze', 'bronze_eqwarehouse', 'training_course_base',                   'full',        NULL,               NULL,       NULL,   1),
-- ── Core entities ──────────────────────────────────────────────────────────
(11, 'EQ_Warehouse', 'sqlserver', 'Product',                      'lh_bronze', 'bronze_eqwarehouse', 'product_base',                           'full',        NULL,               NULL,       NULL,   1),
(12, 'EQ_Warehouse', 'sqlserver', 'Surrender',                    'lh_bronze', 'bronze_eqwarehouse', 'surrender_base',                         'full',        NULL,               NULL,       NULL,   1),
(13, 'EQ_Warehouse', 'sqlserver', 'Territory',                    'lh_bronze', 'bronze_eqwarehouse', 'territory_base',                         'full',        NULL,               NULL,       NULL,   1),
(14, 'EQ_Warehouse', 'sqlserver', 'Client',                       'lh_bronze', 'bronze_eqwarehouse', 'client_base',                            'incremental', 'StartDate',        'datetime', 50000,  1),
(15, 'EQ_Warehouse', 'sqlserver', 'Agent',                        'lh_bronze', 'bronze_eqwarehouse', 'agent_base',                             'incremental', 'StartDate',        'datetime', 50000,  1),
(16, 'EQ_Warehouse', 'sqlserver', 'Investment',                   'lh_bronze', 'bronze_eqwarehouse', 'investment_base',                        'full',        NULL,               NULL,       NULL,   1),
(17, 'EQ_Warehouse', 'sqlserver', 'ProductStateApproval',         'lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_base',            'full',        NULL,               NULL,       NULL,   1),
(18, 'EQ_Warehouse', 'sqlserver', 'ProductStateVariation',        'lh_bronze', 'bronze_eqwarehouse', 'product_state_variation_base',           'full',        NULL,               NULL,       NULL,   1),
(19, 'EQ_Warehouse', 'sqlserver', 'ProductStateApprovalDisclosure','lh_bronze','bronze_eqwarehouse', 'product_state_approval_disclosure_base', 'full',        NULL,               NULL,       NULL,   1),
(20, 'EQ_Warehouse', 'sqlserver', 'Contract',                     'lh_bronze', 'bronze_eqwarehouse', 'contract_base',                          'incremental', 'StartDate',        'datetime', 50000,  1),
-- ── Relationship tables ────────────────────────────────────────────────────
(21, 'EQ_Warehouse', 'sqlserver', 'AgentContract',                'lh_bronze', 'bronze_eqwarehouse', 'agent_contract_base',                    'incremental', 'StartDate',        'datetime', 50000,  1),
(22, 'EQ_Warehouse', 'sqlserver', 'AgentLicense',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_license_base',                     'incremental', 'StartDate',        'datetime', 50000,  1),
(23, 'EQ_Warehouse', 'sqlserver', 'AgentPrincipal',               'lh_bronze', 'bronze_eqwarehouse', 'agent_principal_base',                   'incremental', 'StartDate',        'datetime', 50000,  1),
(24, 'EQ_Warehouse', 'sqlserver', 'AgentTraining',                'lh_bronze', 'bronze_eqwarehouse', 'agent_training_base',                    'incremental', 'StartDate',        'datetime', 50000,  1),
(25, 'EQ_Warehouse', 'sqlserver', 'TrainingProduct',              'lh_bronze', 'bronze_eqwarehouse', 'training_product_base',                  'full',        NULL,               NULL,       NULL,   1),
(26, 'EQ_Warehouse', 'sqlserver', 'TrainingState',                'lh_bronze', 'bronze_eqwarehouse', 'training_state_base',                    'full',        NULL,               NULL,       NULL,   1),
(27, 'EQ_Warehouse', 'sqlserver', 'HierarchyTerritory',           'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_territory_base',               'full',        NULL,               NULL,       NULL,   1),
(28, 'EQ_Warehouse', 'sqlserver', 'Hierarchy',                    'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_base',                         'incremental', 'StartDate',        'datetime', 50000,  1),
(29, 'EQ_Warehouse', 'sqlserver', 'Hierarchy_SuperHierarchy',     'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_super_hierarchy_base',         'incremental', 'StartDate',        'datetime', 50000,  1),
(30, 'EQ_Warehouse', 'sqlserver', 'Hierarchy_Bridge',             'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_bridge_base',                  'incremental', 'StartDate',        'datetime', 50000,  1),
(31, 'EQ_Warehouse', 'sqlserver', 'Hierarchy_Option',             'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_option_base',                  'full',        NULL,               NULL,       NULL,   1),
(32, 'EQ_Warehouse', 'sqlserver', 'AccountValue',                 'lh_bronze', 'bronze_eqwarehouse', 'account_value_base',                     'incremental', 'StartDate',        'datetime', 50000,  1),
(33, 'EQ_Warehouse', 'sqlserver', 'ExternalAccount_Group',        'lh_bronze', 'bronze_eqwarehouse', 'external_account_group_base',            'incremental', 'StartDate',        'datetime', 50000,  1),
(34, 'EQ_Warehouse', 'sqlserver', 'AdditionalClient_Group',       'lh_bronze', 'bronze_eqwarehouse', 'additional_client_group_base',           'incremental', 'StartDate',        'datetime', 50000,  1),
(35, 'EQ_Warehouse', 'sqlserver', 'AdditionalInfo_Group',         'lh_bronze', 'bronze_eqwarehouse', 'additional_info_group_base',             'incremental', 'StartDate',        'datetime', 50000,  1),
(36, 'EQ_Warehouse', 'sqlserver', 'Reinsurance_Group',            'lh_bronze', 'bronze_eqwarehouse', 'reinsurance_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  1),
-- ── Transaction / event tables ─────────────────────────────────────────────
(37, 'EQ_Warehouse', 'sqlserver', 'Activity',                     'lh_bronze', 'bronze_eqwarehouse', 'activity_base',                          'incremental', 'ProcessDateFK',    'integer',  100000, 1),
(38, 'EQ_Warehouse', 'sqlserver', 'ActivityFinancial',            'lh_bronze', 'bronze_eqwarehouse', 'activity_financial_base',                'incremental', 'ProcessDateFK',    'integer',  100000, 1),
(39, 'EQ_Warehouse', 'sqlserver', 'Accounting',                   'lh_bronze', 'bronze_eqwarehouse', 'accounting_base',                        'incremental', 'EntryUpdateDate',  'datetime', 100000, 1),
(40, 'EQ_Warehouse', 'sqlserver', 'AccountingDetail',             'lh_bronze', 'bronze_eqwarehouse', 'accounting_detail_base',                 'incremental', 'EntryUpdateDate',  'datetime', 100000, 1),
(41, 'EQ_Warehouse', 'sqlserver', 'ContractValue_Group',          'lh_bronze', 'bronze_eqwarehouse', 'contract_value_group_base',              'incremental', 'StartDate',        'datetime', 50000,  1),
(42, 'EQ_Warehouse', 'sqlserver', 'ContractDeposit',              'lh_bronze', 'bronze_eqwarehouse', 'contract_deposit_base',                  'incremental', 'DepositDate',      'datetime', 50000,  1),
(43, 'EQ_Warehouse', 'sqlserver', 'RecurringPayment',             'lh_bronze', 'bronze_eqwarehouse', 'recurring_payment_base',                 'incremental', 'StartDate',        'datetime', 50000,  1),
(44, 'EQ_Warehouse', 'sqlserver', 'AgentSummary',                 'lh_bronze', 'bronze_eqwarehouse', 'agent_summary_base',                     'incremental', 'SummaryDate',      'datetime', 50000,  1),
(45, 'EQ_Warehouse', 'sqlserver', 'IndexValue',                   'lh_bronze', 'bronze_eqwarehouse', 'index_value_base',                       'incremental', 'IndexDate',        'datetime', 50000,  1),
(46, 'EQ_Warehouse', 'sqlserver', 'RenewalRate',                  'lh_bronze', 'bronze_eqwarehouse', 'renewal_rate_base',                      'incremental', 'RateEffectiveDate','datetime', 50000,  1),
(47, 'EQ_Warehouse', 'sqlserver', 'CAPRepayment',                 'lh_bronze', 'bronze_eqwarehouse', 'cap_repayment_base',                     'incremental', 'RepaymentDate',    'datetime', 50000,  1),
(48, 'EQ_Warehouse', 'sqlserver', 'CAPStatusChange',              'lh_bronze', 'bronze_eqwarehouse', 'cap_status_change_base',                 'incremental', 'ChangeDate',       'datetime', 50000,  1),
(49, 'EQ_Warehouse', 'sqlserver', 'hedge.Ratios',                 'lh_bronze', 'bronze_eqwarehouse', 'hedge_ratios_base',                      'incremental', 'RatioDate',        'datetime', 50000,  1),
(50, 'EQ_Warehouse', 'sqlserver', 'hedge.Options',                'lh_bronze', 'bronze_eqwarehouse', 'hedge_options_base',                     'incremental', 'OptionDate',       'datetime', 50000,  1),
-- ── Remaining groups + views ───────────────────────────────────────────────
(51, 'EQ_Warehouse', 'sqlserver', 'Rider_Group',                  'lh_bronze', 'bronze_eqwarehouse', 'rider_group_base',                       'incremental', 'StartDate',        'datetime', 50000,  1),
(52, 'EQ_Warehouse', 'sqlserver', 'Requirement_Group',            'lh_bronze', 'bronze_eqwarehouse', 'requirement_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  1),
(53, 'EQ_Warehouse', 'sqlserver', 'Note_Group',                   'lh_bronze', 'bronze_eqwarehouse', 'note_group_base',                        'incremental', 'NoteDate',         'datetime', 50000,  1),
(54, 'EQ_Warehouse', 'sqlserver', 'LastProcessing',               'lh_bronze', 'bronze_eqwarehouse', 'last_processing_base',                   'full',        NULL,               NULL,       NULL,   1),
(55, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_Client',                'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_client_base',                     'full',        NULL,               NULL,       NULL,   1),
(56, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_Contract',              'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_base',                   'full',        NULL,               NULL,       NULL,   1),
(57, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_Agent',                 'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_agent_base',                      'full',        NULL,               NULL,       NULL,   1),
(58, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_Activity',              'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_activity_base',                   'full',        NULL,               NULL,       NULL,   1),
(59, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_Accounting',            'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_accounting_base',                 'full',        NULL,               NULL,       NULL,   1),
(60, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_AccountValue',          'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_account_value_base',              'full',        NULL,               NULL,       NULL,   1),
(61, 'EQ_Warehouse', 'sqlserver', 'vw_SEG_AgentSummary',          'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_agent_summary_base',              'full',        NULL,               NULL,       NULL,   1),
(62, 'EQ_Warehouse', 'sqlserver', 'ref_Product',                  'lh_bronze', 'bronze_eqwarehouse', 'ref_product_base',                       'full',        NULL,               NULL,       NULL,   1);
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED DATA: schema_config
-- Sample mappings for Contract and Agent — extend per actual source schemas.
-- Columns: id, source_table_name, source_column_name, target_column_name,
--          target_data_type, ordinal_position, include_in_md5hash, is_active
-- ══════════════════════════════════════════════════════════════════════════════

-- Full schema_config seed data (915 rows covering all 62 EQ_Warehouse entities) is
-- maintained in a separate file for readability:
--
--   sql/schema_config_seed.sql
--
-- Run that file after this one to populate dbo.schema_config.
-- The INSERT statements in schema_config_seed.sql use unqualified table name
-- (schema_config, not dbo.schema_config). If your Fabric SQL DB default schema
-- is not dbo, either prefix the table name or set the default schema first:
--
--   ALTER USER <your_user> WITH DEFAULT_SCHEMA = dbo;
--
-- Column order in schema_config_seed.sql:
--   id, source_table_name, source_column_name, target_column_name,
--   target_data_type, ordinal_position, include_in_md5hash, is_active, created_at
--
-- include_in_md5hash rules applied:
--   source_column_name = 'N/A'  (pipeline audit cols)  → 0  (305 rows)
--   all mapped source columns                           → 1   (610 rows)
GO
