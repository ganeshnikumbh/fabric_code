# Notebook: nb_silver_s1_ddl
# Layer: SILVER S1
# Purpose: Creates Silver S1 external Delta tables — cleansed, SCD Type 2, MD5-hashed.
#          All tables include SCD2 tracking columns and md5_hash for change detection.
#          IMPORTANT: Source fields named 'effective_date' are renamed to avoid
#          collision with the SCD2 tracking column (e.g., effective_date_policy).
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

ENVIRONMENT = "__ENVIRONMENT__"
STORAGE_ACCOUNT = "__STORAGE_ACCOUNT__"
SILVER_S1_BASE_PATH = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s1"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"

run_id = generate_run_id()
logger = FabricLogger(run_id=run_id, layer="silver_s1", object_name="ddl", environment=ENVIRONMENT)

# SCD2 columns appended to every Silver S1 table
SCD2_COLS = """
    effective_date      DATE      NOT NULL COMMENT 'SCD2: date this version became active',
    expiration_date     DATE               COMMENT 'SCD2: date this version expired (NULL = current)',
    is_current          BOOLEAN   NOT NULL COMMENT 'SCD2: true = current active record',
    md5_hash            STRING    NOT NULL COMMENT 'MD5 of business columns — drives change detection',
    ingestion_date      DATE      NOT NULL COMMENT 'Date this record was ingested to Silver S1',
    data_date           DATE      NOT NULL COMMENT 'Business date of the source extract',
    source_system       STRING    NOT NULL COMMENT 'Always: eqwarehouse',
    ingestion_run_id    STRING    NOT NULL COMMENT 'UUID linking all tables in same pipeline run'
"""


def create_silver_s1_table(
    table_name: str,
    columns_ddl: str,
    source_table: str,
    domain: str,
    sensitivity: str = "CONFIDENTIAL",
    zorder_cols: str = None,
) -> None:
    full_path = f"{SILVER_S1_BASE_PATH}/{table_name}"
    try:
        spark.sql(f"""
        CREATE EXTERNAL TABLE IF NOT EXISTS silver_s1.{table_name} (
            {columns_ddl},
            {SCD2_COLS}
        )
        USING DELTA
        PARTITIONED BY (data_date)
        LOCATION '{full_path}'
        TBLPROPERTIES (
            'equitrust.layer'           = 'silver_s1',
            'equitrust.source_system'   = 'eqwarehouse',
            'equitrust.source_table'    = '{source_table}',
            'equitrust.domain'          = '{domain}',
            'equitrust.sensitivity'     = '{sensitivity}',
            'equitrust.scd_type'        = '2',
            'equitrust.managed_by'      = 'fabric-cicd',
            'equitrust.environment'     = '{ENVIRONMENT}',
            'delta.autoOptimize.optimizeWrite' = 'true',
            'delta.autoOptimize.autoCompact'   = 'true'
        )
        """)
        logger.info(f"Created: silver_s1.{table_name}")

        if zorder_cols:
            spark.sql(f"OPTIMIZE silver_s1.{table_name} ZORDER BY ({zorder_cols})")
            logger.info(f"Z-ordered: silver_s1.{table_name} on ({zorder_cols})")
    except Exception as e:
        logger.error(f"Failed to create silver_s1.{table_name}: {e}")
        raise


logger.info("Starting Silver S1 DDL")

# ─── Contract ─────────────────────────────────────────────────────────────────
create_silver_s1_table("contract", """
    contract_id                         INT           NOT NULL,
    contract_number                     STRING,
    hierarchy_group_key                 STRING,
    contract_value_group_key            STRING,
    surrender_id                        INT,
    product_id                          INT,
    owner_client_id                     INT,
    owner2_client_id                    INT,
    annuitant_insured_client_id         INT,
    annuitant_insured2_client_id        INT,
    application_received_date           DATE,
    application_signed_date             DATE,
    effective_date_policy               DATE          COMMENT 'Source effective_date — renamed to avoid SCD2 column collision',
    issue_date                          DATE,
    issue_state_code                    STRING,
    issue_age                           INT,
    attained_age                        INT,
    status_code                         STRING,
    cost_basis_amount                   DECIMAL(18,4),
    recovered_cost_basis_amount         DECIMAL(18,4),
    is_qualified                        BOOLEAN,
    qualification_type_code             STRING,
    option_code                         STRING,
    certain_period                      INT,
    mec_status_code                     STRING,
    has_spousal_continuation            BOOLEAN,
    is_supplemental_contract            BOOLEAN,
    is_qdro                             BOOLEAN,
    has_rider_claim                     BOOLEAN,
    is_roth_conversion                  BOOLEAN,
    is_internal_replacement             BOOLEAN,
    is_partial_tax_conversion           BOOLEAN,
    has_waiver_in_effect                BOOLEAN,
    is_edelivery                        BOOLEAN,
    class_code                          STRING,
    underwriting_class_code             STRING,
    underwriting_date                   DATE,
    coverage_ratio                      DECIMAL(10,6),
    contract_end_date                   DATE,
    funding_company_id                  INT
""",
    source_table="Contract",
    domain="policy",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, issue_state_code, status_code"
)

# ─── Client ───────────────────────────────────────────────────────────────────
create_silver_s1_table("client", """
    client_id               INT     NOT NULL,
    first_name              STRING  COMMENT 'PII',
    last_name               STRING  COMMENT 'PII',
    middle_name             STRING  COMMENT 'PII',
    date_of_birth           DATE    COMMENT 'PII',
    gender_code             STRING,
    marital_status_code     STRING,
    tax_id_hash             BINARY  COMMENT 'Hashed — DO NOT decode; CLS in semantic model',
    last4_hash              BINARY  COMMENT 'Hashed — DO NOT decode',
    email_address           STRING  COMMENT 'PII — RESTRICTED',
    phone_number            STRING  COMMENT 'PII — RESTRICTED',
    address_line1           STRING  COMMENT 'PII',
    address_line2           STRING  COMMENT 'PII',
    city                    STRING,
    state_code              STRING,
    zip_code                STRING,
    country_code            STRING,
    client_type_code        STRING,
    is_entity               BOOLEAN,
    entity_name             STRING,
    citizenship_country     STRING
""",
    source_table="Client",
    domain="client",
    sensitivity="RESTRICTED",
    zorder_cols="client_id, state_code, client_type_code"
)

# ─── Agent ────────────────────────────────────────────────────────────────────
create_silver_s1_table("agent", """
    agent_id                    INT     NOT NULL,
    client_id                   INT,
    agent_number                STRING,
    display_name                STRING,
    national_producer_number    STRING,
    nasd_finra_number           STRING,
    agent_type_code             STRING,
    hire_date                   DATE,
    termination_date            DATE,
    status_code                 STRING
""",
    source_table="Agent",
    domain="distribution",
    sensitivity="CONFIDENTIAL",
    zorder_cols="agent_id, agent_number, status_code"
)

# ─── Activity ─────────────────────────────────────────────────────────────────
create_silver_s1_table("activity", """
    activity_id             BIGINT  NOT NULL,
    contract_id             INT     NOT NULL,
    activity_type_id        INT,
    process_date_key        INT,
    effective_date_activity DATE    COMMENT 'Source effective_date — renamed to avoid SCD2 column collision',
    transaction_date        DATE,
    amount                  DECIMAL(18,4),
    units                   DECIMAL(18,6),
    text_value              STRING,
    distribution_type_code  STRING,
    is_reversal             BOOLEAN,
    reversal_activity_id    BIGINT,
    is_processed            BOOLEAN
""",
    source_table="Activity",
    domain="policy",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, process_date_key, activity_type_id"
)

# ─── Account Value ────────────────────────────────────────────────────────────
create_silver_s1_table("account_value", """
    account_value_id        INT           NOT NULL,
    contract_id             INT           NOT NULL,
    investment_id           INT,
    valuation_date          DATE          NOT NULL,
    account_value_amount    DECIMAL(18,4),
    surrender_value_amount  DECIMAL(18,4),
    units                   DECIMAL(18,6),
    unit_value              DECIMAL(18,6),
    interest_rate           DECIMAL(10,6),
    value_type_code         STRING
""",
    source_table="AccountValue",
    domain="policy",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, valuation_date, value_type_code"
)

# ─── Accounting ───────────────────────────────────────────────────────────────
create_silver_s1_table("accounting", """
    accounting_id           BIGINT        NOT NULL,
    contract_id             INT,
    accounting_account_id   INT,
    company_id              INT,
    entry_date              DATE,
    entry_update_date       DATE,
    posting_date            DATE,
    period_year             INT,
    period_month            INT,
    debit_amount            DECIMAL(18,4),
    credit_amount           DECIMAL(18,4),
    net_amount              DECIMAL(18,4),
    journal_reference       STRING,
    reporting_group_id      INT,
    is_reversed             BOOLEAN
""",
    source_table="Accounting",
    domain="finance",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, period_year, period_month, accounting_account_id"
)

# ─── Product ──────────────────────────────────────────────────────────────────
create_silver_s1_table("product", """
    product_id              INT     NOT NULL,
    product_code            STRING,
    product_name            STRING,
    product_type_code       STRING,
    company_id              INT,
    surrender_id            INT,
    effective_date_product  DATE    COMMENT 'Source effective_date — renamed',
    discontinuation_date    DATE,
    is_active               BOOLEAN,
    min_issue_age           INT,
    max_issue_age           INT,
    min_premium_amount      DECIMAL(18,4),
    max_premium_amount      DECIMAL(18,4)
""",
    source_table="Product",
    domain="policy",
    sensitivity="INTERNAL",
    zorder_cols="product_id, product_type_code, company_id"
)

# ─── Investment ───────────────────────────────────────────────────────────────
create_silver_s1_table("investment", """
    investment_id           INT     NOT NULL,
    investment_code         STRING,
    investment_name         STRING,
    investment_type_code    STRING,
    fund_family             STRING,
    ticker_symbol           STRING,
    inception_date          DATE,
    is_active               BOOLEAN
""",
    source_table="Investment",
    domain="investment",
    sensitivity="INTERNAL",
    zorder_cols="investment_id, investment_type_code"
)

logger.info("Silver S1 DDL complete — 8 tables created")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
