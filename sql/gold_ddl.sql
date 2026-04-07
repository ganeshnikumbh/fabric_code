-- Gold Layer DDL — EquiTrust Financial Microsoft Fabric Migration
-- All tables EXTERNAL with abfss:// LOCATION (Engineering Handbook §4.2 — External Table Mandate)
-- Dimensions: no partition, full replace each run
-- Facts: partitioned by data_date
-- ALL tables: OPTIMIZE ZORDER immediately after creation
-- Star schema: facts one join from dimensions; no snowflaking
-- Unknown members: surrogate key -1 inserted at dim build time
-- Environment: __ENVIRONMENT__
-- Storage:     __STORAGE_ACCOUNT__

-- ─────────────────────────────────────────────────────────────────────────────
-- DIMENSION TABLES
-- ─────────────────────────────────────────────────────────────────────────────

-- dim_date
-- Source: bronze_eqwarehouse.date_base (FULL load)
-- date_key = date_id (YYYYMMDD integer) — natural key serves as surrogate
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_date (
    date_key            INT           NOT NULL COMMENT 'YYYYMMDD integer — natural key from Date.DatePK',
    full_date           DATE          COMMENT 'Calendar date',
    year                INT,
    quarter             INT,
    month               INT,
    month_name          STRING,
    week_of_year        INT,
    day_of_week         INT,
    day_name            STRING,
    is_weekend          BOOLEAN,
    is_holiday          BOOLEAN,
    fiscal_year         INT,
    fiscal_quarter      INT,
    fiscal_month        INT,
    dw_created_date     DATE,
    dw_source_system    STRING,
    dw_run_id           STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_date'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'bronze_eqwarehouse.date_base',
    'equitrust.domain'      = 'reference',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_date ZORDER BY (date_key, year, month);


-- dim_contract
-- Source: silver_s1.contract (is_current=true)
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_contract (
    contract_key                    BIGINT        NOT NULL COMMENT 'Surrogate key — row_number() over contract_id',
    contract_id                     INT           NOT NULL COMMENT 'Natural key from source',
    contract_number                 STRING,
    issue_state_code                STRING,
    issue_date                      DATE,
    effective_date_policy           DATE,
    contract_end_date               DATE,
    status_code                     STRING,
    is_qualified                    BOOLEAN,
    qualification_type_code         STRING,
    option_code                     STRING,
    mec_status_code                 STRING,
    class_code                      STRING,
    coverage_ratio                  DECIMAL(10,6),
    has_waiver_in_effect            BOOLEAN,
    is_supplemental_contract        BOOLEAN,
    is_qdro                         BOOLEAN,
    has_rider_claim                 BOOLEAN,
    is_roth_conversion              BOOLEAN,
    is_internal_replacement         BOOLEAN,
    product_id                      INT,
    owner_client_id                 INT,
    funding_company_id              INT,
    scd2_effective_date             DATE          COMMENT 'Silver S1 SCD2 effective date for this version',
    dw_created_date                 DATE,
    dw_source_system                STRING,
    dw_run_id                       STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_contract'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'silver_s1.contract',
    'equitrust.domain'      = 'policy',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_contract ZORDER BY (contract_id, issue_state_code, status_code);


-- dim_client
-- Source: silver_s1.client (is_current=true)
-- RESTRICTED: tax_id_hash, last4_hash, email_address, phone_number present
-- CLS (Column-Level Security) applied in enterprise semantic model — these columns
-- are NOT accessible to standard analyst roles.
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_client (
    client_key              BIGINT    NOT NULL COMMENT 'Surrogate key',
    client_id               INT       NOT NULL COMMENT 'Natural key',
    first_name              STRING    COMMENT 'PII — RESTRICTED; CLS in semantic model',
    last_name               STRING    COMMENT 'PII — RESTRICTED; CLS in semantic model',
    middle_name             STRING    COMMENT 'PII — RESTRICTED',
    date_of_birth           DATE      COMMENT 'PII — RESTRICTED; CLS in semantic model',
    gender_code             STRING,
    marital_status_code     STRING,
    tax_id_hash             BINARY    COMMENT 'RESTRICTED — hashed; DO NOT decode; CLS applied',
    last4_hash              BINARY    COMMENT 'RESTRICTED — hashed; DO NOT decode; CLS applied',
    email_address           STRING    COMMENT 'PII — RESTRICTED; CLS in semantic model',
    phone_number            STRING    COMMENT 'PII — RESTRICTED; CLS in semantic model',
    address_line1           STRING    COMMENT 'PII — RESTRICTED',
    city                    STRING,
    state_code              STRING,
    zip_code                STRING,
    country_code            STRING,
    client_type_code        STRING,
    is_entity               BOOLEAN,
    entity_name             STRING,
    citizenship_country     STRING,
    scd2_effective_date     DATE,
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_client'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'silver_s1.client',
    'equitrust.domain'      = 'client',
    'equitrust.sensitivity' = 'RESTRICTED',
    'equitrust.pii'         = 'true',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_client ZORDER BY (client_id, state_code, client_type_code);


-- dim_agent
-- Source: silver_s1.agent (is_current=true)
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_agent (
    agent_key                   BIGINT  NOT NULL COMMENT 'Surrogate key',
    agent_id                    INT     NOT NULL COMMENT 'Natural key',
    agent_number                STRING,
    client_id                   INT     COMMENT 'Link to dim_client for agent personal info',
    display_name                STRING,
    national_producer_number    STRING,
    nasd_finra_number           STRING,
    agent_type_code             STRING,
    hire_date                   DATE,
    termination_date            DATE,
    status_code                 STRING,
    scd2_effective_date         DATE,
    dw_created_date             DATE,
    dw_source_system            STRING,
    dw_run_id                   STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_agent'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'silver_s1.agent',
    'equitrust.domain'      = 'distribution',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_agent ZORDER BY (agent_id, agent_number, status_code);


-- dim_product
-- Source: silver_s1.product (is_current=true)
-- Per Table Index: InvestmentDetail merged into product dim
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_product (
    product_key                 BIGINT        NOT NULL COMMENT 'Surrogate key',
    product_id                  INT           NOT NULL COMMENT 'Natural key',
    product_code                STRING,
    product_name                STRING,
    product_type_code           STRING,
    company_id                  INT,
    surrender_id                INT,
    effective_date_product      DATE,
    discontinuation_date        DATE,
    is_active                   BOOLEAN,
    min_issue_age               INT,
    max_issue_age               INT,
    min_premium_amount          DECIMAL(18,4),
    max_premium_amount          DECIMAL(18,4),
    dw_created_date             DATE,
    dw_source_system            STRING,
    dw_run_id                   STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_product'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'silver_s1.product',
    'equitrust.domain'      = 'policy',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_product ZORDER BY (product_id, product_type_code, company_id);


-- dim_investment
-- Source: silver_s1.investment (is_current=true)
-- Per Table Index: InvestmentDetail merged into this dim
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_investment (
    investment_key              BIGINT  NOT NULL COMMENT 'Surrogate key',
    investment_id               INT     NOT NULL COMMENT 'Natural key',
    investment_code             STRING,
    investment_name             STRING,
    investment_type_code        STRING,
    fund_family                 STRING,
    ticker_symbol               STRING,
    inception_date              DATE,
    is_active                   BOOLEAN,
    dw_created_date             DATE,
    dw_source_system            STRING,
    dw_run_id                   STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_investment'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'silver_s1.investment',
    'equitrust.domain'      = 'investment',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_investment ZORDER BY (investment_id, investment_type_code);


-- dim_state
-- Source: bronze_eqwarehouse.state_base
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_state (
    state_key       INT     NOT NULL COMMENT 'Surrogate key (= state_id from source)',
    state_id        INT     NOT NULL COMMENT 'Natural key',
    state_code      STRING,
    state_name      STRING,
    state_abbrev    STRING,
    country_code    STRING,
    region_name     STRING,
    is_active       BOOLEAN,
    dw_created_date DATE,
    dw_source_system STRING,
    dw_run_id       STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_state'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'bronze_eqwarehouse.state_base',
    'equitrust.domain'      = 'reference',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_state ZORDER BY (state_code, country_code);


-- dim_company
-- Source: bronze_eqwarehouse.company_base
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_company (
    company_key         INT     NOT NULL COMMENT 'Surrogate key (= company_id from source)',
    company_id          INT     NOT NULL COMMENT 'Natural key',
    company_code        STRING,
    company_name        STRING,
    company_type_code   STRING,
    naic_code           STRING,
    is_active           BOOLEAN,
    domicile_state_code STRING,
    dw_created_date     DATE,
    dw_source_system    STRING,
    dw_run_id           STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_company'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'bronze_eqwarehouse.company_base',
    'equitrust.domain'      = 'reference',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_company ZORDER BY (company_id, company_code);


-- dim_activity_type
-- Source: bronze_eqwarehouse.activity_type_base
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_activity_type (
    activity_type_key       INT     NOT NULL COMMENT 'Surrogate key (= activity_type_id from source)',
    activity_type_id        INT     NOT NULL COMMENT 'Natural key',
    activity_type_code      STRING,
    activity_type_name      STRING,
    activity_category_code  STRING,
    is_financial            BOOLEAN,
    is_active               BOOLEAN,
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_activity_type'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'bronze_eqwarehouse.activity_type_base',
    'equitrust.domain'      = 'reference',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_activity_type ZORDER BY (activity_type_id, activity_category_code);


-- dim_accounting_account
-- Source: bronze_eqwarehouse.accounting_account_base
CREATE EXTERNAL TABLE IF NOT EXISTS gold.dim_accounting_account (
    accounting_account_key  INT     NOT NULL COMMENT 'Surrogate key (= accounting_account_id)',
    accounting_account_id   INT     NOT NULL COMMENT 'Natural key',
    account_number          STRING,
    account_name            STRING,
    account_type_code       STRING,
    account_category_code   STRING,
    normal_balance_code     STRING,
    is_active               BOOLEAN,
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/dim_accounting_account'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'dimension',
    'equitrust.source'      = 'bronze_eqwarehouse.accounting_account_base',
    'equitrust.domain'      = 'finance',
    'equitrust.sensitivity' = 'INTERNAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.dim_accounting_account ZORDER BY (account_number, account_type_code);


-- ─────────────────────────────────────────────────────────────────────────────
-- FACT TABLES (partitioned by data_date)
-- ─────────────────────────────────────────────────────────────────────────────

-- fact_activity
-- Source: silver_s2.activity_financial_detail
-- Grain: one row per activity event
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_activity (
    activity_id                     BIGINT        NOT NULL COMMENT 'Degenerate dimension — source natural key',
    contract_key                    BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    activity_type_key               INT           NOT NULL COMMENT 'FK to dim_activity_type; -1 for unknown',
    effective_date_key              INT           NOT NULL COMMENT 'FK to dim_date (date_key); -1 for unknown',
    agent_key                       BIGINT        NOT NULL COMMENT 'FK to dim_agent (primary agent on contract); -1 for unknown',
    amount                          DECIMAL(18,4) COMMENT 'Activity amount (0 for informational)',
    units                           DECIMAL(18,6),
    gross_amount                    DECIMAL(18,4) COMMENT '0.0 if no financial detail',
    federal_withholding_amount      DECIMAL(18,4),
    state_withholding_amount        DECIMAL(18,4),
    net_amount                      DECIMAL(18,4),
    penalty_amount                  DECIMAL(18,4),
    surrender_charge_amount         DECIMAL(18,4),
    market_value_adjustment         DECIMAL(18,4),
    distribution_type_code          STRING,
    is_reversal                     BOOLEAN,
    reversal_activity_id            BIGINT,
    is_processed                    BOOLEAN,
    transaction_date                DATE,
    effective_date_activity         DATE,
    data_date                       DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date                 DATE,
    dw_source_system                STRING,
    dw_run_id                       STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_activity'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'fact',
    'equitrust.grain'       = 'one row per activity event',
    'equitrust.source'      = 'silver_s2.activity_financial_detail',
    'equitrust.domain'      = 'policy',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_activity ZORDER BY (contract_key, effective_date_key, activity_type_key);


-- fact_account_value
-- Source: silver_s1.account_value (is_current=true)
-- Grain: contract + investment + valuation date
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_account_value (
    account_value_id        INT           NOT NULL COMMENT 'Degenerate dimension',
    contract_key            BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    investment_key          BIGINT        NOT NULL COMMENT 'FK to dim_investment; -1 for unknown',
    valuation_date_key      INT           NOT NULL COMMENT 'FK to dim_date; -1 for unknown',
    account_value_amount    DECIMAL(18,4),
    surrender_value_amount  DECIMAL(18,4),
    units                   DECIMAL(18,6),
    unit_value              DECIMAL(18,6),
    interest_rate           DECIMAL(10,6),
    value_type_code         STRING,
    data_date               DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_account_value'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'fact',
    'equitrust.grain'       = 'contract + investment + valuation_date',
    'equitrust.source'      = 'silver_s1.account_value',
    'equitrust.domain'      = 'policy',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_account_value ZORDER BY (contract_key, valuation_date_key, investment_key);


-- fact_accounting
-- Source: silver_s1.accounting (is_current=true)
-- Grain: one GL entry — do NOT flatten per Table Index
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_accounting (
    accounting_id               BIGINT        NOT NULL COMMENT 'Degenerate dimension',
    contract_key                BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    accounting_account_key      INT           NOT NULL COMMENT 'FK to dim_accounting_account; -1 for unknown',
    company_key                 INT           NOT NULL COMMENT 'FK to dim_company; -1 for unknown',
    entry_date_key              INT           NOT NULL COMMENT 'FK to dim_date (entry_date); -1 for unknown',
    posting_date_key            INT           NOT NULL COMMENT 'FK to dim_date (posting_date); -1 for unknown',
    period_year                 INT,
    period_month                INT,
    debit_amount                DECIMAL(18,4),
    credit_amount               DECIMAL(18,4),
    net_amount                  DECIMAL(18,4),
    journal_reference           STRING,
    reporting_group_id          INT,
    is_reversed                 BOOLEAN,
    data_date                   DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date             DATE,
    dw_source_system            STRING,
    dw_run_id                   STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_accounting'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'fact',
    'equitrust.grain'       = 'one GL entry (do not flatten)',
    'equitrust.source'      = 'silver_s1.accounting',
    'equitrust.domain'      = 'finance',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_accounting ZORDER BY (contract_key, entry_date_key, accounting_account_key);


-- fact_contract_value
-- Source: bronze_eqwarehouse.contract_value_group_base
-- Grain: contract + value_type + value_date — keep LONG not WIDE per Table Index
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_contract_value (
    contract_value_group_id INT           NOT NULL COMMENT 'Degenerate dimension',
    contract_key            BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    value_date_key          INT           NOT NULL COMMENT 'FK to dim_date; -1 for unknown',
    value_type_code         STRING        COMMENT 'Keep as type column — do NOT pivot to wide format',
    value_amount            DECIMAL(18,4),
    value_units             DECIMAL(18,6),
    data_date               DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_contract_value'
TBLPROPERTIES (
    'equitrust.layer'           = 'gold',
    'equitrust.table_type'      = 'fact',
    'equitrust.grain'           = 'contract + value_type + value_date (long format)',
    'equitrust.table_index_note' = 'DO NOT pivot to wide format — keep long per intake template',
    'equitrust.source'          = 'bronze_eqwarehouse.contract_value_group_base',
    'equitrust.domain'          = 'policy',
    'equitrust.sensitivity'     = 'CONFIDENTIAL',
    'equitrust.environment'     = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_contract_value ZORDER BY (contract_key, value_date_key, value_type_code);


-- fact_contract_deposit
-- Source: bronze_eqwarehouse.contract_deposit_base
-- Grain: one deposit transaction
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_contract_deposit (
    contract_deposit_id     INT           NOT NULL COMMENT 'Degenerate dimension',
    contract_key            BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    deposit_date_key        INT           NOT NULL COMMENT 'FK to dim_date; -1 for unknown',
    deposit_amount          DECIMAL(18,4),
    deposit_type_code       STRING,
    check_number            STRING,
    is_applied              BOOLEAN,
    data_date               DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_contract_deposit'
TBLPROPERTIES (
    'equitrust.layer'       = 'gold',
    'equitrust.table_type'  = 'fact',
    'equitrust.grain'       = 'one deposit transaction',
    'equitrust.source'      = 'bronze_eqwarehouse.contract_deposit_base',
    'equitrust.domain'      = 'policy',
    'equitrust.sensitivity' = 'CONFIDENTIAL',
    'equitrust.environment' = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_contract_deposit ZORDER BY (contract_key, deposit_date_key, deposit_type_code);


-- fact_agent_summary
-- Source: silver_s2.agent_production_summary
-- Grain: agent + summary_type + summary_date
-- Per Table Index: do NOT merge into agent dim
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_agent_summary (
    agent_key                   BIGINT        NOT NULL COMMENT 'FK to dim_agent; -1 for unknown',
    summary_date_key            INT           NOT NULL COMMENT 'FK to dim_date; -1 for unknown',
    summary_type_code           STRING,
    ytd_premium_amount          DECIMAL(18,4),
    ytd_commission_amount       DECIMAL(18,4),
    mtd_premium_amount          DECIMAL(18,4),
    mtd_commission_amount       DECIMAL(18,4),
    total_contracts_count       INT,
    active_contracts_count      INT,
    data_date                   DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date             DATE,
    dw_source_system            STRING,
    dw_run_id                   STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_agent_summary'
TBLPROPERTIES (
    'equitrust.layer'           = 'gold',
    'equitrust.table_type'      = 'fact',
    'equitrust.grain'           = 'agent + summary_type + summary_date',
    'equitrust.table_index_note' = 'Separate fact table — do NOT merge into dim_agent',
    'equitrust.source'          = 'silver_s2.agent_production_summary',
    'equitrust.domain'          = 'distribution',
    'equitrust.sensitivity'     = 'CONFIDENTIAL',
    'equitrust.environment'     = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_agent_summary ZORDER BY (agent_key, summary_date_key, summary_type_code);


-- fact_hedge
-- Source: bronze_eqwarehouse.hedge_ratios_base + hedge_options_base (schema: hedge)
-- Grain: contract + instrument + date
-- Per Table Index: separate table (not merged with other facts)
CREATE EXTERNAL TABLE IF NOT EXISTS gold.fact_hedge (
    contract_key            BIGINT        NOT NULL COMMENT 'FK to dim_contract; -1 for unknown',
    instrument_code         STRING        NOT NULL COMMENT 'Hedge instrument identifier',
    hedge_date_key          INT           NOT NULL COMMENT 'FK to dim_date; -1 for unknown',
    hedge_type_code         STRING        COMMENT 'RATIO or OPTION',
    delta_ratio             DECIMAL(18,6),
    gamma_ratio             DECIMAL(18,6),
    vega_ratio              DECIMAL(18,6),
    rho_ratio               DECIMAL(18,6),
    option_type_code        STRING,
    strike_price            DECIMAL(18,4),
    market_value            DECIMAL(18,4),
    notional_amount         DECIMAL(18,4),
    expiration_date_ho      DATE,
    hedge_program_code      STRING,
    data_date               DATE          NOT NULL COMMENT 'Partition key',
    dw_created_date         DATE,
    dw_source_system        STRING,
    dw_run_id               STRING
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION 'abfss://gold@__STORAGE_ACCOUNT__.dfs.core.windows.net/fact_hedge'
TBLPROPERTIES (
    'equitrust.layer'           = 'gold',
    'equitrust.table_type'      = 'fact',
    'equitrust.grain'           = 'contract + instrument + date',
    'equitrust.table_index_note' = 'Separate hedge fact — do NOT merge with fact_activity',
    'equitrust.source'          = 'bronze_eqwarehouse.hedge_ratios_base + hedge_options_base',
    'equitrust.domain'          = 'risk',
    'equitrust.sensitivity'     = 'CONFIDENTIAL',
    'equitrust.environment'     = '__ENVIRONMENT__',
    'delta.autoOptimize.optimizeWrite' = 'true'
);

OPTIMIZE gold.fact_hedge ZORDER BY (contract_key, hedge_date_key, instrument_code);
