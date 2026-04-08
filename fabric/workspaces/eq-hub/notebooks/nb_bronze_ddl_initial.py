# Notebook: nb_bronze_ddl_initial
# Layer: BRONZE
# Purpose: Creates initial Bronze external Delta tables for core EquiTrust domains.
#          Run ONCE during initial environment provisioning.
#          All tables are EXTERNAL — data ownership remains in OneLake ZRS storage.
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

import sys
%run nb_logging_library

ENVIRONMENT = "__ENVIRONMENT__"
STORAGE_ACCOUNT = "__STORAGE_ACCOUNT__"
BRONZE_BASE_PATH = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"

run_id = generate_run_id()
logger = FabricLogger(run_id=run_id, layer="bronze", object_name="ddl_initial", environment=ENVIRONMENT)

logger.info("Starting Bronze DDL — initial tables")


def create_bronze_table(table_name: str, ddl_sql: str) -> None:
    try:
        spark.sql(ddl_sql)
        logger.info(f"Created external table: bronze_eqwarehouse.{table_name}")
    except Exception as e:
        logger.error(f"Failed to create table {table_name}: {e}")
        raise


# ─── Territory ───────────────────────────────────────────────────────────────
create_bronze_table("territory_base", f"""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze_eqwarehouse.territory_base (
    territory_id        INT           NOT NULL COMMENT 'Source: TerritoryPK',
    territory_name      STRING        COMMENT 'Source: TerritoryName',
    region_code         STRING        COMMENT 'Source: RegionCode',
    district_code       STRING        COMMENT 'Source: DistrictCode',
    is_active           BOOLEAN       COMMENT 'Source: TerritoryActive — renamed per naming conventions',
    ingestion_date      DATE          NOT NULL COMMENT 'Partition key — date this row was ingested',
    data_date           DATE          NOT NULL COMMENT 'Business date of the source extract',
    source_system       STRING        NOT NULL COMMENT 'Always: eqwarehouse',
    ingestion_run_id    STRING        NOT NULL COMMENT 'UUID linking all tables in same pipeline run',
    is_deleted          BOOLEAN       NOT NULL DEFAULT false COMMENT 'Soft-delete flag for incremental loads'
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION '{BRONZE_BASE_PATH}/territory_base'
TBLPROPERTIES (
    'equitrust.layer'           = 'bronze',
    'equitrust.source_system'   = 'eqwarehouse',
    'equitrust.source_table'    = 'Territory',
    'equitrust.load_type'       = 'FULL',
    'equitrust.domain'          = 'distribution',
    'equitrust.sensitivity'     = 'INTERNAL',
    'equitrust.managed_by'      = 'fabric-cicd',
    'equitrust.environment'     = '{ENVIRONMENT}',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true'
)
""")

# ─── Contract ─────────────────────────────────────────────────────────────────
create_bronze_table("contract_base", f"""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze_eqwarehouse.contract_base (
    contract_id                         INT           NOT NULL COMMENT 'Source: ContractPK',
    contract_number                     STRING        COMMENT 'Source: ContractNumber',
    hierarchy_group_key                 STRING        COMMENT 'Source: HierarchyGroupKey',
    contract_value_group_key            STRING        COMMENT 'Source: ContractValueGroupKey',
    surrender_id                        INT           COMMENT 'Source: SurrenderFK',
    product_id                          INT           COMMENT 'Source: ProductFK',
    owner_client_id                     INT           COMMENT 'Source: OwnerClientFK',
    owner2_client_id                    INT           COMMENT 'Source: Owner2ClientFK',
    annuitant_insured_client_id         INT           COMMENT 'Source: AnnuitantInsuredClientFK',
    annuitant_insured2_client_id        INT           COMMENT 'Source: AnnuitantInsured2ClientFK',
    application_received_date           DATE          COMMENT 'Source: ApplicationReceivedDate',
    application_signed_date             DATE          COMMENT 'Source: ApplicationSignedDate',
    effective_date_policy               DATE          COMMENT 'Source: EffectiveDate — renamed to avoid SCD2 collision',
    issue_date                          DATE          COMMENT 'Source: IssueDate',
    issue_state_code                    STRING        COMMENT 'Source: IssueState',
    issue_age                           INT           COMMENT 'Source: IssueAge',
    attained_age                        INT           COMMENT 'Source: AttainedAge',
    status_code                         STRING        COMMENT 'Source: Status',
    cost_basis_amount                   DECIMAL(18,4) COMMENT 'Source: CostBasis',
    recovered_cost_basis_amount         DECIMAL(18,4) COMMENT 'Source: RecoveredCostBasis',
    is_qualified                        BOOLEAN       COMMENT 'Source: QualInd',
    qualification_type_code             STRING        COMMENT 'Source: QualificationType',
    option_code                         STRING        COMMENT 'Source: Option',
    certain_period                      INT           COMMENT 'Source: CertainPeriod',
    mec_status_code                     STRING        COMMENT 'Source: MECStatus',
    has_spousal_continuation            BOOLEAN       COMMENT 'Source: SpousalContinuationInd',
    is_supplemental_contract            BOOLEAN       COMMENT 'Source: SupplementalContractInd',
    is_qdro                             BOOLEAN       COMMENT 'Source: QDROInd',
    has_rider_claim                     BOOLEAN       COMMENT 'Source: RiderClaimInd',
    is_roth_conversion                  BOOLEAN       COMMENT 'Source: RothConversionInd',
    is_internal_replacement             BOOLEAN       COMMENT 'Source: InternalReplacementInd',
    is_partial_tax_conversion           BOOLEAN       COMMENT 'Source: PartialTaxConversionInd',
    has_waiver_in_effect                BOOLEAN       COMMENT 'Source: WaiverInEffectInd',
    is_edelivery                        BOOLEAN       COMMENT 'Source: EDeliveryInd',
    class_code                          STRING        COMMENT 'Source: Class',
    underwriting_class_code             STRING        COMMENT 'Source: UnderwritingClass',
    underwriting_date                   DATE          COMMENT 'Source: UnderwritingDate',
    coverage_ratio                      DECIMAL(10,6) COMMENT 'Source: CoverageRatio',
    contract_end_date                   DATE          COMMENT 'Source: ContractEndDate',
    funding_company_id                  INT           COMMENT 'Source: FundingCompanyFK',
    ingestion_date                      DATE          NOT NULL,
    data_date                           DATE          NOT NULL,
    source_system                       STRING        NOT NULL,
    ingestion_run_id                    STRING        NOT NULL,
    is_deleted                          BOOLEAN       NOT NULL DEFAULT false
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION '{BRONZE_BASE_PATH}/contract_base'
TBLPROPERTIES (
    'equitrust.layer'           = 'bronze',
    'equitrust.source_system'   = 'eqwarehouse',
    'equitrust.source_table'    = 'Contract',
    'equitrust.load_type'       = 'INCREMENTAL',
    'equitrust.domain'          = 'policy',
    'equitrust.sensitivity'     = 'CONFIDENTIAL',
    'equitrust.managed_by'      = 'fabric-cicd',
    'equitrust.environment'     = '{ENVIRONMENT}',
    'equitrust.quarantine_threshold_pct' = '0.00',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true'
)
""")

# ─── Client ───────────────────────────────────────────────────────────────────
create_bronze_table("client_base", f"""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze_eqwarehouse.client_base (
    client_id               INT           NOT NULL COMMENT 'Source: ClientPK',
    first_name              STRING        COMMENT 'Source: FirstName — PII',
    last_name               STRING        COMMENT 'Source: LastName — PII',
    middle_name             STRING        COMMENT 'Source: MiddleName — PII',
    date_of_birth           DATE          COMMENT 'Source: DateOfBirth — PII',
    gender_code             STRING        COMMENT 'Source: Gender',
    marital_status_code     STRING        COMMENT 'Source: MaritalStatus',
    tax_id_hash             BINARY        COMMENT 'Source: TaxIDHash — varbinary; DO NOT decode; CLS in semantic model',
    last4_hash              BINARY        COMMENT 'Source: Last4Hash — varbinary; DO NOT decode',
    email_address           STRING        COMMENT 'Source: EmailAddress — PII; RESTRICTED',
    phone_number            STRING        COMMENT 'Source: PhoneNumber — PII; RESTRICTED',
    address_line1           STRING        COMMENT 'Source: AddressLine1 — PII',
    address_line2           STRING        COMMENT 'Source: AddressLine2 — PII',
    city                    STRING        COMMENT 'Source: City',
    state_code              STRING        COMMENT 'Source: StateCode',
    zip_code                STRING        COMMENT 'Source: ZipCode',
    country_code            STRING        COMMENT 'Source: CountryCode',
    client_type_code        STRING        COMMENT 'Source: ClientType',
    is_entity               BOOLEAN       COMMENT 'Source: EntityInd',
    entity_name             STRING        COMMENT 'Source: EntityName',
    citizenship_country     STRING        COMMENT 'Source: CitizenshipCountry',
    ingestion_date          DATE          NOT NULL,
    data_date               DATE          NOT NULL,
    source_system           STRING        NOT NULL,
    ingestion_run_id        STRING        NOT NULL,
    is_deleted              BOOLEAN       NOT NULL DEFAULT false
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION '{BRONZE_BASE_PATH}/client_base'
TBLPROPERTIES (
    'equitrust.layer'           = 'bronze',
    'equitrust.source_system'   = 'eqwarehouse',
    'equitrust.source_table'    = 'Client',
    'equitrust.load_type'       = 'INCREMENTAL',
    'equitrust.domain'          = 'client',
    'equitrust.sensitivity'     = 'RESTRICTED',
    'equitrust.managed_by'      = 'fabric-cicd',
    'equitrust.environment'     = '{ENVIRONMENT}',
    'equitrust.quarantine_threshold_pct' = '0.00',
    'equitrust.pii'             = 'true',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true'
)
""")

# ─── Activity ─────────────────────────────────────────────────────────────────
create_bronze_table("activity_base", f"""
CREATE EXTERNAL TABLE IF NOT EXISTS bronze_eqwarehouse.activity_base (
    activity_id             BIGINT        NOT NULL COMMENT 'Source: ActivityPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    activity_type_id        INT           COMMENT 'Source: ActivityTypeFK',
    process_date_key        INT           COMMENT 'Source: ProcessDateFK — integer date key (YYYYMMDD)',
    effective_date_activity DATE          COMMENT 'Source: EffectiveDate — renamed to avoid SCD2 collision',
    transaction_date        DATE          COMMENT 'Source: TransactionDate',
    amount                  DECIMAL(18,4) COMMENT 'Source: Amount',
    units                   DECIMAL(18,6) COMMENT 'Source: Units',
    text_value              STRING        COMMENT 'Source: TextValue',
    distribution_type_code  STRING        COMMENT 'Source: DistributionType',
    is_reversal             BOOLEAN       COMMENT 'Source: ReversalInd',
    reversal_activity_id    BIGINT        COMMENT 'Source: ReversalActivityFK',
    is_processed            BOOLEAN       COMMENT 'Source: ProcessedInd',
    ingestion_date          DATE          NOT NULL,
    data_date               DATE          NOT NULL,
    source_system           STRING        NOT NULL,
    ingestion_run_id        STRING        NOT NULL,
    is_deleted              BOOLEAN       NOT NULL DEFAULT false
)
USING DELTA
PARTITIONED BY (data_date)
LOCATION '{BRONZE_BASE_PATH}/activity_base'
TBLPROPERTIES (
    'equitrust.layer'           = 'bronze',
    'equitrust.source_system'   = 'eqwarehouse',
    'equitrust.source_table'    = 'Activity',
    'equitrust.load_type'       = 'INCREMENTAL',
    'equitrust.domain'          = 'policy',
    'equitrust.sensitivity'     = 'CONFIDENTIAL',
    'equitrust.managed_by'      = 'fabric-cicd',
    'equitrust.environment'     = '{ENVIRONMENT}',
    'equitrust.quarantine_threshold_pct' = '0.00',
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true'
)
""")

logger.info("Bronze DDL initial — all 4 tables created successfully")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
