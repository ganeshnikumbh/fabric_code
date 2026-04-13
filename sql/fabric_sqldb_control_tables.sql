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
    source_schema       NVARCHAR(100)   NULL,       -- schema in source system (e.g. 'dbo'); NULL for non-DB sources
    entity_name         NVARCHAR(200)   NOT NULL,
    target_lakehouse    NVARCHAR(100)   NOT NULL,
    target_schema       NVARCHAR(100)   NOT NULL,
    target_table        NVARCHAR(200)   NOT NULL,
    load_type           NVARCHAR(20)    NOT NULL,   -- full | incremental | cdc
    watermark_column    NVARCHAR(100)   NULL,
    watermark_type      NVARCHAR(20)    NULL,       -- datetime | integer | string
    batch_size          INT             NULL,
    partition_by_column_names NVARCHAR(500) NULL,   -- comma-separated column names to partition by (e.g. 'ingestion_date,data_date'); NULL = no partitioning
    is_scd2             BIT             NOT NULL    CONSTRAINT df_ingestion_config_scd2 DEFAULT (0),
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
    source_name         NVARCHAR(100)   NOT NULL,       -- FK to ingestion_config.source_name (e.g. 'EQ_Warehouse')
    source_table_name   NVARCHAR(200)   NOT NULL,
    target_table_name   NVARCHAR(200)   NOT NULL,       -- bronze target table name (e.g. 'client_base')
    source_column_name  NVARCHAR(200)   NOT NULL,
    target_column_name  NVARCHAR(200)   NOT NULL,
    target_data_type    NVARCHAR(100)   NOT NULL,
    ordinal_position    INT             NOT NULL,
    include_in_md5hash  BIT             NOT NULL    CONSTRAINT df_schema_config_hash DEFAULT (1),
    is_primary_key      BIT             NOT NULL    CONSTRAINT df_schema_config_pk DEFAULT (0),
    is_active           BIT             NOT NULL    CONSTRAINT df_schema_config_active DEFAULT (1),
    created_at          DATETIME2       NOT NULL    CONSTRAINT df_schema_config_created_at DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT pk_schema_config PRIMARY KEY (id)
);
GO

CREATE INDEX ix_schema_config_source_name
    ON dbo.schema_config (source_name);
GO

CREATE INDEX ix_schema_config_table_name
    ON dbo.schema_config (source_table_name);
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED DATA: ingestion_config  (62 rows — all EQ_Warehouse entities)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.ingestion_config
    (source_id, source_name, source_type, source_schema, entity_name, target_lakehouse, target_schema, target_table, load_type, watermark_column, watermark_type, batch_size, partition_by_column_names, is_scd2, active_flag)
VALUES
-- ── Reference / lookup tables (full load) ─────────────────────────────────
(1,  'EQ_Warehouse', 'sqlserver', 'dbo', 'Date',                         'lh_bronze', 'bronze_eqwarehouse', 'date_base',                              'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(2,  'EQ_Warehouse', 'sqlserver', 'dbo', 'State',                        'lh_bronze', 'bronze_eqwarehouse', 'state_base',                             'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(3,  'EQ_Warehouse', 'sqlserver', 'dbo', 'Company',                      'lh_bronze', 'bronze_eqwarehouse', 'company_base',                           'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(4,  'EQ_Warehouse', 'sqlserver', 'dbo', 'ActivityType',                 'lh_bronze', 'bronze_eqwarehouse', 'activity_type_base',                     'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(5,  'EQ_Warehouse', 'sqlserver', 'dbo', 'CommissionLevelRank',          'lh_bronze', 'bronze_eqwarehouse', 'commission_level_rank_base',             'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(6,  'EQ_Warehouse', 'sqlserver', 'dbo', 'InvestmentDetail',             'lh_bronze', 'bronze_eqwarehouse', 'investment_detail_base',                 'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(7,  'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingAccount',            'lh_bronze', 'bronze_eqwarehouse', 'accounting_account_base',                'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(8,  'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductVariationDetail',       'lh_bronze', 'bronze_eqwarehouse', 'product_variation_detail_base',          'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(9,  'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingReporting_Group',    'lh_bronze', 'bronze_eqwarehouse', 'accounting_reporting_group_base',        'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(10, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingCourse',               'lh_bronze', 'bronze_eqwarehouse', 'training_course_base',                   'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
-- ── Core entities ──────────────────────────────────────────────────────────
(11, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Product',                      'lh_bronze', 'bronze_eqwarehouse', 'product_base',                           'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(12, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Surrender',                    'lh_bronze', 'bronze_eqwarehouse', 'surrender_base',                         'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(13, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Territory',                    'lh_bronze', 'bronze_eqwarehouse', 'territory_base',                         'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(14, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Client',                       'lh_bronze', 'bronze_eqwarehouse', 'client_base',                            'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(15, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Agent',                        'lh_bronze', 'bronze_eqwarehouse', 'agent_base',                             'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(16, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Investment',                   'lh_bronze', 'bronze_eqwarehouse', 'investment_base',                        'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(17, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateApproval',         'lh_bronze', 'bronze_eqwarehouse', 'product_state_approval_base',            'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(18, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateVariation',        'lh_bronze', 'bronze_eqwarehouse', 'product_state_variation_base',           'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(19, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ProductStateApprovalDisclosure','lh_bronze','bronze_eqwarehouse', 'product_state_approval_disclosure_base', 'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(20, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Contract',                     'lh_bronze', 'bronze_eqwarehouse', 'contract_base',                          'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
-- ── Relationship tables ────────────────────────────────────────────────────
(21, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentContract',                'lh_bronze', 'bronze_eqwarehouse', 'agent_contract_base',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(22, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentLicense_Group',           'lh_bronze', 'bronze_eqwarehouse', 'agent_license_group_base',               'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(23, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentPrincipal_Group',         'lh_bronze', 'bronze_eqwarehouse', 'agent_principal_group_base',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(24, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentTraining',                'lh_bronze', 'bronze_eqwarehouse', 'agent_training_base',                    'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(25, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingProduct_Group',        'lh_bronze', 'bronze_eqwarehouse', 'training_product_group_base',            'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(26, 'EQ_Warehouse', 'sqlserver', 'dbo', 'TrainingState_Group',          'lh_bronze', 'bronze_eqwarehouse', 'training_state_group_base',              'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(27, 'EQ_Warehouse', 'sqlserver', 'dbo', 'HierarchyTerritory',           'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_territory_base',               'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(28, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy',                    'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_base',                         'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(29, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_SuperHierarchy',     'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_super_hierarchy_base',         'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(30, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_Bridge',             'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_bridge_base',                  'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(31, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Hierarchy_Option',             'lh_bronze', 'bronze_eqwarehouse', 'hierarchy_option_base',                  'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(32, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountValue',                 'lh_bronze', 'bronze_eqwarehouse', 'account_value_base',                     'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(33, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ExternalAccount_Group',        'lh_bronze', 'bronze_eqwarehouse', 'external_account_group_base',            'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(34, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AdditionalClient_Group',       'lh_bronze', 'bronze_eqwarehouse', 'additional_client_group_base',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(35, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AdditionalInfo_Group',         'lh_bronze', 'bronze_eqwarehouse', 'additional_info_group_base',             'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(36, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Reinsurance_Group',            'lh_bronze', 'bronze_eqwarehouse', 'reinsurance_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
-- ── Transaction / event tables ─────────────────────────────────────────────
(37, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Activity',                     'lh_bronze', 'bronze_eqwarehouse', 'activity_base',                          'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1),
(38, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ActivityFinancial',            'lh_bronze', 'bronze_eqwarehouse', 'activity_financial_base',                'incremental', 'ProcessDateFK',    'integer',  100000, NULL, 0, 1),
(39, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Accounting',                   'lh_bronze', 'bronze_eqwarehouse', 'accounting_base',                        'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1),
(40, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AccountingDetail',             'lh_bronze', 'bronze_eqwarehouse', 'accounting_detail_base',                 'incremental', 'EntryUpdateDate',  'datetime', 100000, NULL, 0, 1),
(41, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ContractValue_Group',          'lh_bronze', 'bronze_eqwarehouse', 'contract_value_group_base',              'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(42, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ContractDeposit_Group',        'lh_bronze', 'bronze_eqwarehouse', 'contract_deposit_group_base',            'incremental', 'DepositDate',      'datetime', 50000,  NULL, 0, 1),
(43, 'EQ_Warehouse', 'sqlserver', 'dbo', 'RecurringPayment_Group',       'lh_bronze', 'bronze_eqwarehouse', 'recurring_payment_group_base',           'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(44, 'EQ_Warehouse', 'sqlserver', 'dbo', 'AgentSummary_Group',           'lh_bronze', 'bronze_eqwarehouse', 'agent_summary_group_base',               'incremental', 'SummaryDate',      'datetime', 50000,  NULL, 0, 1),
(45, 'EQ_Warehouse', 'sqlserver', 'dbo', 'IndexValue_Group',             'lh_bronze', 'bronze_eqwarehouse', 'index_value_group_base',                 'incremental', 'IndexDate',        'datetime', 50000,  NULL, 0, 1),
(46, 'EQ_Warehouse', 'sqlserver', 'dbo', 'RenewalRate_Group',            'lh_bronze', 'bronze_eqwarehouse', 'renewal_rate_group_base',                'incremental', 'RateEffectiveDate','datetime', 50000,  NULL, 0, 1),
(47, 'EQ_Warehouse', 'sqlserver', 'dbo', 'CAPRepayment',                 'lh_bronze', 'bronze_eqwarehouse', 'cap_repayment_base',                     'incremental', 'RepaymentDate',    'datetime', 50000,  NULL, 0, 1),
(48, 'EQ_Warehouse', 'sqlserver', 'dbo', 'CAPStatusChange',              'lh_bronze', 'bronze_eqwarehouse', 'cap_status_change_base',                 'incremental', 'ChangeDate',       'datetime', 50000,  NULL, 0, 1),
(49, 'EQ_Warehouse', 'sqlserver', 'dbo', 'hedge.Ratios',                 'lh_bronze', 'bronze_eqwarehouse', 'hedge_ratios_base',                      'incremental', 'RatioDate',        'datetime', 50000,  NULL, 0, 1),
(50, 'EQ_Warehouse', 'sqlserver', 'dbo', 'hedge.Options',                'lh_bronze', 'bronze_eqwarehouse', 'hedge_options_base',                     'incremental', 'OptionDate',       'datetime', 50000,  NULL, 0, 1),
-- ── Remaining groups + views ───────────────────────────────────────────────
(51, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Rider_Group',                  'lh_bronze', 'bronze_eqwarehouse', 'rider_group_base',                       'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(52, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Requirement_Group',            'lh_bronze', 'bronze_eqwarehouse', 'requirement_group_base',                 'incremental', 'StartDate',        'datetime', 50000,  NULL, 0, 1),
(53, 'EQ_Warehouse', 'sqlserver', 'dbo', 'Note_Group',                   'lh_bronze', 'bronze_eqwarehouse', 'note_group_base',                        'incremental', 'NoteDate',         'datetime', 50000,  NULL, 0, 1),
(54, 'EQ_Warehouse', 'sqlserver', 'dbo', 'LastProcessing',               'lh_bronze', 'bronze_eqwarehouse', 'last_processing_base',                   'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(55, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_Client',                'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_client_base',                     'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(56, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_ContractClient',        'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_client_base',            'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(57, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_Agent',                 'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_agent_base',                      'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(58, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_ContractTreaty',        'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_treaty_base',            'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(59, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_ContractRider',         'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_rider_base',             'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(60, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_ContractTrx',           'lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_trx_base',               'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(61, 'EQ_Warehouse', 'sqlserver', 'dbo', 'vw_SEG_ContractPrimarySegment','lh_bronze', 'bronze_eqwarehouse', 'vw_seg_contract_primary_segment_base',   'full',        NULL,               NULL,       NULL,   NULL, 0, 1),
(62, 'EQ_Warehouse', 'sqlserver', 'dbo', 'ref_Product',                  'lh_bronze', 'bronze_eqwarehouse', 'ref_product_base',                       'full',        NULL,               NULL,       NULL,   NULL, 0, 1);
GO


-- ── TABLE 3: source_load_control ────────────────────────────────────────────

IF OBJECT_ID('dbo.source_load_control', 'U') IS NOT NULL
    DROP TABLE dbo.source_load_control;
GO

CREATE TABLE dbo.source_load_control (
    id                  INT             NOT NULL    IDENTITY(1,1),
    source_name         NVARCHAR(100)   NOT NULL,               -- e.g. 'EQ_Warehouse'
    entity_name         NVARCHAR(200)   NOT NULL,               -- e.g. 'Client' — matches ingestion_config.entity_name
    last_load_date      DATETIME2       NULL,                   -- UTC timestamp of last successful load
    bronze_run_status   NVARCHAR(20)    NOT NULL                -- success | failed | running | skipped
                            CONSTRAINT df_slc_bronze_status DEFAULT ('pending'),
    silver_run_status   NVARCHAR(20)    NOT NULL                -- success | failed | running | skipped | pending
                            CONSTRAINT df_slc_silver_status DEFAULT ('pending'),
    created_date        DATETIME2       NOT NULL    CONSTRAINT df_slc_created DEFAULT (SYSUTCDATETIME()),
    modified_date       DATETIME2       NULL,
    CONSTRAINT pk_source_load_control PRIMARY KEY (id),
    CONSTRAINT uq_source_load_control UNIQUE (source_name, entity_name)
);
GO

CREATE INDEX ix_slc_source_entity
    ON dbo.source_load_control (source_name, entity_name);
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED DATA: source_load_control  (52 rows — EQ_Warehouse entities)
-- Initial state: bronze loaded on 2026-04-13, silver pending.
-- id is omitted — IDENTITY(1,1) auto-assigns.
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO dbo.source_load_control
    (source_name, entity_name, last_load_date, bronze_run_status, silver_run_status)
VALUES
('EQ_Warehouse', 'Accounting',                        '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AccountingAccount',                 '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AccountingDetail',                  '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AccountingReporting_Group',         '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AccountValue',                      '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Activity',                          '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ActivityFinancial',                 '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ActivityType',                      '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AdditionalClient_Group',            '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AdditionalInfo_Group',              '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Agent',                             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AgentContract',                     '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AgentLicense_Group',                '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AgentPrincipal_Group',              '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AgentSummary_Group',                '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'AgentTraining',                     '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'CAPRepayment',                      '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'CAPStatusChange',                   '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Client',                            '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'CommissionLevelRank',               '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Company',                           '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Contract',                          '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ContractDeposit_Group',             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ContractValue_Group',               '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ExternalAccount_Group',             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Options',                           '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Ratios',                            '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Hierarchy',                         '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Hierarchy_Bridge',                  '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Hierarchy_Option',                  '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Hierarchy_SuperHierarchy',          '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'HierarchyTerritory',                '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'IndexValue_Group',                  '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Investment',                        '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'InvestmentDetail',                  '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Note_Group',                        '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Product',                           '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ProductStateApproval',              '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ProductStateApprovalDisclosure',    '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ProductStateVariation',             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'ProductVariationDetail',            '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'RecurringPayment_Group',            '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Reinsurance_Group',                 '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'RenewalRate_Group',                 '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Requirement_Group',                 '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Rider_Group',                       '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'State',                             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Surrender',                         '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'Territory',                         '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'TrainingCourse',                    '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'TrainingProduct_Group',             '2026-04-13 00:00:00', 'success', 'pending'),
('EQ_Warehouse', 'TrainingState_Group',               '2026-04-13 00:00:00', 'success', 'pending');
GO


-- ══════════════════════════════════════════════════════════════════════════════
-- SEED DATA: schema_config
-- Sample mappings for Contract and Agent — extend per actual source schemas.
-- Columns: id, source_name, source_table_name, target_table_name, source_column_name, target_column_name,
--          target_data_type, ordinal_position, include_in_md5hash, is_primary_key, is_active
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
