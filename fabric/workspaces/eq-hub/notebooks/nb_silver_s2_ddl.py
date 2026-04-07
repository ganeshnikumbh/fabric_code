# Notebook: nb_silver_s2_ddl
# Layer: SILVER S2
# Purpose: Creates Silver S2 external Delta tables — integrated, contracted, Z-ordered.
#          Silver S2 joins Silver S1 current records with additional Bronze detail.
#          These are write-once-replace-by-partition tables (replaceWhere on data_date).
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

ENVIRONMENT = "__ENVIRONMENT__"
STORAGE_ACCOUNT = "__STORAGE_ACCOUNT__"
SILVER_S2_BASE_PATH = f"abfss://silver@{STORAGE_ACCOUNT}.dfs.core.windows.net/s2"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"

run_id = generate_run_id()
logger = FabricLogger(run_id=run_id, layer="silver_s2", object_name="ddl", environment=ENVIRONMENT)


def create_silver_s2_table(
    table_name: str,
    columns_ddl: str,
    source_description: str,
    domain: str,
    sensitivity: str,
    zorder_cols: str,
) -> None:
    full_path = f"{SILVER_S2_BASE_PATH}/{table_name}"
    try:
        spark.sql(f"""
        CREATE EXTERNAL TABLE IF NOT EXISTS silver_s2.{table_name} (
            {columns_ddl},
            data_date           DATE      NOT NULL COMMENT 'Partition key — business date of source extract',
            ingestion_date      DATE      NOT NULL COMMENT 'Date this record was written to Silver S2',
            source_system       STRING    NOT NULL COMMENT 'Always: eqwarehouse',
            ingestion_run_id    STRING    NOT NULL COMMENT 'UUID linking all tables in same pipeline run'
        )
        USING DELTA
        PARTITIONED BY (data_date)
        LOCATION '{full_path}'
        TBLPROPERTIES (
            'equitrust.layer'           = 'silver_s2',
            'equitrust.source_system'   = 'eqwarehouse',
            'equitrust.source_description' = '{source_description}',
            'equitrust.domain'          = '{domain}',
            'equitrust.sensitivity'     = '{sensitivity}',
            'equitrust.managed_by'      = 'fabric-cicd',
            'equitrust.environment'     = '{ENVIRONMENT}',
            'delta.autoOptimize.optimizeWrite' = 'true',
            'delta.autoOptimize.autoCompact'   = 'true'
        )
        """)
        logger.info(f"Created: silver_s2.{table_name}")

        spark.sql(f"OPTIMIZE silver_s2.{table_name} ZORDER BY ({zorder_cols})")
        logger.info(f"Z-ordered: silver_s2.{table_name} on ({zorder_cols})")
    except Exception as e:
        logger.error(f"Failed to create silver_s2.{table_name}: {e}")
        raise


logger.info("Starting Silver S2 DDL")

# ─── Contract Enriched ────────────────────────────────────────────────────────
# Joins: silver_s1.contract (is_current) + silver_s1.product (is_current) + silver_s1.client (is_current)
create_silver_s2_table(
    table_name="contract_enriched",
    columns_ddl="""
    contract_id                     INT           NOT NULL COMMENT 'From silver_s1.contract',
    contract_number                 STRING,
    status_code                     STRING,
    issue_state_code                STRING,
    issue_date                      DATE,
    effective_date_policy           DATE,
    contract_end_date               DATE,
    is_qualified                    BOOLEAN,
    qualification_type_code         STRING,
    option_code                     STRING,
    mec_status_code                 STRING,
    cost_basis_amount               DECIMAL(18,4),
    recovered_cost_basis_amount     DECIMAL(18,4),
    class_code                      STRING,
    coverage_ratio                  DECIMAL(10,6),
    has_waiver_in_effect            BOOLEAN,
    is_supplemental_contract        BOOLEAN,
    is_qdro                         BOOLEAN,
    has_rider_claim                 BOOLEAN,
    product_id                      INT           COMMENT 'From silver_s1.product',
    product_code                    STRING,
    product_name                    STRING,
    product_type_code               STRING,
    company_id                      INT,
    effective_date_product          DATE,
    owner_client_id                 INT           COMMENT 'From silver_s1.client',
    owner_first_name                STRING        COMMENT 'PII — client first name',
    owner_last_name                 STRING        COMMENT 'PII — client last name',
    owner_state_code                STRING,
    owner_client_type_code          STRING,
    owner_date_of_birth             DATE          COMMENT 'PII'
    """,
    source_description="silver_s1.contract JOIN silver_s1.product JOIN silver_s1.client (is_current)",
    domain="policy",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, issue_state_code, status_code"
)

# ─── Activity Financial Detail ────────────────────────────────────────────────
# Joins: silver_s1.activity (is_current) LEFT JOIN bronze_eqwarehouse.activity_financial_base
create_silver_s2_table(
    table_name="activity_financial_detail",
    columns_ddl="""
    activity_id                     BIGINT        NOT NULL COMMENT 'From silver_s1.activity',
    contract_id                     INT           NOT NULL,
    activity_type_id                INT,
    process_date_key                INT,
    effective_date_activity         DATE,
    transaction_date                DATE,
    amount                          DECIMAL(18,4),
    units                           DECIMAL(18,6),
    text_value                      STRING,
    distribution_type_code          STRING,
    is_reversal                     BOOLEAN,
    reversal_activity_id            BIGINT,
    activity_financial_id           BIGINT        COMMENT 'NULL if no financial detail exists',
    gross_amount                    DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    federal_withholding_amount      DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    state_withholding_amount        DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    net_amount                      DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    penalty_amount                  DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    surrender_charge_amount         DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)',
    market_value_adjustment         DECIMAL(18,4) COMMENT '0.0 if NULL (coalesced)'
    """,
    source_description="silver_s1.activity LEFT JOIN bronze_eqwarehouse.activity_financial_base",
    domain="policy",
    sensitivity="CONFIDENTIAL",
    zorder_cols="contract_id, process_date_key, activity_type_id"
)

# ─── Agent Production Summary ─────────────────────────────────────────────────
# Joins: silver_s1.agent (is_current) JOIN bronze_eqwarehouse.agent_summary_base
create_silver_s2_table(
    table_name="agent_production_summary",
    columns_ddl="""
    agent_id                        INT           NOT NULL COMMENT 'From silver_s1.agent',
    agent_number                    STRING,
    display_name                    STRING,
    agent_type_code                 STRING,
    status_code                     STRING,
    hire_date                       DATE,
    termination_date                DATE,
    national_producer_number        STRING,
    summary_date                    DATE          NOT NULL COMMENT 'From agent_summary_base',
    summary_type_code               STRING,
    ytd_premium_amount              DECIMAL(18,4),
    ytd_commission_amount           DECIMAL(18,4),
    mtd_premium_amount              DECIMAL(18,4),
    mtd_commission_amount           DECIMAL(18,4),
    total_contracts_count           INT,
    active_contracts_count          INT
    """,
    source_description="silver_s1.agent JOIN bronze_eqwarehouse.agent_summary_base",
    domain="distribution",
    sensitivity="CONFIDENTIAL",
    zorder_cols="agent_id, summary_date, summary_type_code"
)

logger.info("Silver S2 DDL complete — 3 tables created")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
