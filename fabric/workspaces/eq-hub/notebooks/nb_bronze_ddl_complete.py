# Notebook: nb_bronze_ddl_complete
# Layer: BRONZE
# Purpose: Creates remaining Bronze external Delta tables for all domains.
#          Organized by domain: distribution, policy, finance, investment, risk, client, reference.
#          Run ONCE after nb_bronze_ddl_initial during initial environment provisioning.
# Environment: __ENVIRONMENT__
# Storage:     __STORAGE_ACCOUNT__

%run /fabric/workspaces/eq-hub/notebooks/nb_logging_library

ENVIRONMENT = "__ENVIRONMENT__"
STORAGE_ACCOUNT = "__STORAGE_ACCOUNT__"
BRONZE_BASE_PATH = f"abfss://bronze@{STORAGE_ACCOUNT}.dfs.core.windows.net/eqwarehouse"
AUDIT_TABLE_PATH = f"abfss://audit@{STORAGE_ACCOUNT}.dfs.core.windows.net/pipeline_run_log"

run_id = generate_run_id()
logger = FabricLogger(run_id=run_id, layer="bronze", object_name="ddl_complete", environment=ENVIRONMENT)

STANDARD_AUDIT_COLS = """
    ingestion_date   DATE    NOT NULL,
    data_date        DATE    NOT NULL,
    source_system    STRING  NOT NULL,
    ingestion_run_id STRING  NOT NULL,
    is_deleted       BOOLEAN NOT NULL DEFAULT false
"""

STANDARD_TBLPROPS_BASE = """
    'delta.autoOptimize.optimizeWrite' = 'true',
    'delta.autoOptimize.autoCompact'   = 'true'
"""


def external_table(
    table_name: str,
    columns_ddl: str,
    source_table: str,
    load_type: str,
    domain: str,
    sensitivity: str = "INTERNAL",
    quarantine_pct: str = "10.00",
    extra_props: str = "",
) -> None:
    full_ddl = f"""
    CREATE EXTERNAL TABLE IF NOT EXISTS bronze_eqwarehouse.{table_name} (
        {columns_ddl},
        {STANDARD_AUDIT_COLS}
    )
    USING DELTA
    PARTITIONED BY (data_date)
    LOCATION '{BRONZE_BASE_PATH}/{table_name}'
    TBLPROPERTIES (
        'equitrust.layer'                    = 'bronze',
        'equitrust.source_system'            = 'eqwarehouse',
        'equitrust.source_table'             = '{source_table}',
        'equitrust.load_type'                = '{load_type}',
        'equitrust.domain'                   = '{domain}',
        'equitrust.sensitivity'              = '{sensitivity}',
        'equitrust.managed_by'               = 'fabric-cicd',
        'equitrust.environment'              = '{ENVIRONMENT}',
        'equitrust.quarantine_threshold_pct' = '{quarantine_pct}',
        {extra_props}
        {STANDARD_TBLPROPS_BASE}
    )
    """
    try:
        spark.sql(full_ddl)
        logger.info(f"Created: bronze_eqwarehouse.{table_name}")
    except Exception as e:
        logger.error(f"Failed to create {table_name}: {e}")
        raise


logger.info("=== BRONZE DDL COMPLETE — Starting domain table creation ===")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: DISTRIBUTION
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: distribution ---")

external_table("agent_base", """
    agent_id                    INT           NOT NULL COMMENT 'Source: AgentPK',
    client_id                   INT           COMMENT 'Source: ClientFK',
    agent_number                STRING        COMMENT 'Source: AgentNumber',
    display_name                STRING        COMMENT 'Source: DisplayName',
    national_producer_number    STRING        COMMENT 'Source: NationalProducerNumber',
    nasd_finra_number           STRING        COMMENT 'Source: NASDFINRANumber',
    agent_type_code             STRING        COMMENT 'Source: AgentType',
    hire_date                   DATE          COMMENT 'Source: HireDate',
    termination_date            DATE          COMMENT 'Source: TerminationDate',
    status_code                 STRING        COMMENT 'Source: Status'
""", "Agent", "INCREMENTAL", "distribution", "CONFIDENTIAL")

external_table("agent_contract_base", """
    agent_contract_id       INT     NOT NULL COMMENT 'Source: AgentContractPK',
    agent_id                INT     NOT NULL COMMENT 'Source: AgentFK',
    contract_id             INT     NOT NULL COMMENT 'Source: ContractFK',
    role_type_code          STRING  COMMENT 'Source: RoleType',
    commission_level_id     INT     COMMENT 'Source: CommissionLevelFK',
    effective_date_ac       DATE    COMMENT 'Source: EffectiveDate — renamed',
    termination_date        DATE    COMMENT 'Source: TerminationDate',
    is_primary              BOOLEAN COMMENT 'Source: PrimaryInd',
    split_percentage        DECIMAL(10,6) COMMENT 'Source: SplitPercentage'
""", "AgentContract", "INCREMENTAL", "distribution", "CONFIDENTIAL")

external_table("agent_license_base", """
    agent_license_id        INT     NOT NULL COMMENT 'Source: AgentLicensePK',
    agent_id                INT     NOT NULL COMMENT 'Source: AgentFK',
    state_code              STRING  COMMENT 'Source: StateCode',
    license_number          STRING  COMMENT 'Source: LicenseNumber',
    license_type_code       STRING  COMMENT 'Source: LicenseType',
    issue_date_license      DATE    COMMENT 'Source: IssueDate — renamed',
    expiration_date_license DATE    COMMENT 'Source: ExpirationDate — renamed',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "AgentLicense", "INCREMENTAL", "distribution", "CONFIDENTIAL")

external_table("agent_principal_base", """
    agent_principal_id      INT     NOT NULL COMMENT 'Source: AgentPrincipalPK',
    agent_id                INT     NOT NULL COMMENT 'Source: AgentFK',
    principal_agent_id      INT     COMMENT 'Source: PrincipalAgentFK',
    relationship_type_code  STRING  COMMENT 'Source: RelationshipType',
    effective_date_ap       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "AgentPrincipal", "INCREMENTAL", "distribution", "CONFIDENTIAL")

external_table("agent_training_base", """
    agent_training_id       INT     NOT NULL COMMENT 'Source: AgentTrainingPK',
    agent_id                INT     NOT NULL COMMENT 'Source: AgentFK',
    course_id               INT     COMMENT 'Source: CourseFK',
    completion_date         DATE    COMMENT 'Source: CompletionDate',
    expiration_date_at      DATE    COMMENT 'Source: ExpirationDate — renamed',
    score                   DECIMAL(5,2) COMMENT 'Source: Score',
    is_passed               BOOLEAN COMMENT 'Source: PassedInd'
""", "AgentTraining", "INCREMENTAL", "distribution", "INTERNAL")

external_table("training_product_base", """
    training_product_id     INT     NOT NULL COMMENT 'Source: TrainingProductPK',
    course_id               INT     NOT NULL COMMENT 'Source: CourseFK',
    product_id              INT     NOT NULL COMMENT 'Source: ProductFK',
    is_required             BOOLEAN COMMENT 'Source: RequiredInd'
""", "TrainingProduct", "FULL", "distribution", "INTERNAL")

external_table("training_state_base", """
    training_state_id       INT     NOT NULL COMMENT 'Source: TrainingStatePK',
    course_id               INT     NOT NULL COMMENT 'Source: CourseFK',
    state_code              STRING  NOT NULL COMMENT 'Source: StateCode',
    is_required             BOOLEAN COMMENT 'Source: RequiredInd',
    renewal_years           INT     COMMENT 'Source: RenewalYears'
""", "TrainingState", "FULL", "distribution", "INTERNAL")

external_table("hierarchy_territory_base", """
    hierarchy_territory_id  INT     NOT NULL COMMENT 'Source: HierarchyTerritoryPK',
    hierarchy_id            INT     NOT NULL COMMENT 'Source: HierarchyFK',
    territory_id            INT     NOT NULL COMMENT 'Source: TerritoryFK',
    effective_date_ht       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "HierarchyTerritory", "FULL", "distribution", "INTERNAL")

external_table("hierarchy_base", """
    hierarchy_id            INT     NOT NULL COMMENT 'Source: HierarchyPK',
    agent_id                INT     NOT NULL COMMENT 'Source: AgentFK',
    hierarchy_type_code     STRING  COMMENT 'Source: HierarchyType',
    hierarchy_level         INT     COMMENT 'Source: HierarchyLevel',
    parent_hierarchy_id     INT     COMMENT 'Source: ParentHierarchyFK',
    effective_date_h        DATE    COMMENT 'Source: EffectiveDate — renamed',
    termination_date        DATE    COMMENT 'Source: TerminationDate',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "Hierarchy", "INCREMENTAL", "distribution", "INTERNAL")

external_table("hierarchy_super_hierarchy_base", """
    super_hierarchy_id      INT     NOT NULL COMMENT 'Source: SuperHierarchyPK',
    hierarchy_id            INT     NOT NULL COMMENT 'Source: HierarchyFK',
    super_group_code        STRING  COMMENT 'Source: SuperGroupCode',
    effective_date_sh       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "Hierarchy_SuperHierarchy", "INCREMENTAL", "distribution", "INTERNAL")

external_table("hierarchy_bridge_base", """
    hierarchy_bridge_id     INT     NOT NULL COMMENT 'Source: HierarchyBridgePK',
    hierarchy_id            INT     NOT NULL COMMENT 'Source: HierarchyFK',
    ancestor_hierarchy_id   INT     NOT NULL COMMENT 'Source: AncestorHierarchyFK',
    depth_level             INT     COMMENT 'Source: DepthLevel',
    effective_date_hb       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "Hierarchy_Bridge", "INCREMENTAL", "distribution", "INTERNAL")

external_table("hierarchy_option_base", """
    hierarchy_option_id     INT     NOT NULL COMMENT 'Source: HierarchyOptionPK',
    hierarchy_id            INT     NOT NULL COMMENT 'Source: HierarchyFK',
    option_key              STRING  COMMENT 'Source: OptionKey',
    option_value            STRING  COMMENT 'Source: OptionValue'
""", "Hierarchy_Option", "FULL", "distribution", "INTERNAL")

external_table("agent_summary_base", """
    agent_summary_id        INT           NOT NULL COMMENT 'Source: AgentSummaryPK',
    agent_id                INT           NOT NULL COMMENT 'Source: AgentFK',
    summary_date            DATE          NOT NULL COMMENT 'Source: SummaryDate',
    summary_type_code       STRING        COMMENT 'Source: SummaryType',
    ytd_premium_amount      DECIMAL(18,4) COMMENT 'Source: YTDPremium',
    ytd_commission_amount   DECIMAL(18,4) COMMENT 'Source: YTDCommission',
    mtd_premium_amount      DECIMAL(18,4) COMMENT 'Source: MTDPremium',
    mtd_commission_amount   DECIMAL(18,4) COMMENT 'Source: MTDCommission',
    total_contracts_count   INT           COMMENT 'Source: TotalContracts',
    active_contracts_count  INT           COMMENT 'Source: ActiveContracts'
""", "AgentSummary", "INCREMENTAL", "distribution", "CONFIDENTIAL")

external_table("commission_level_rank_base", """
    commission_level_rank_id INT    NOT NULL COMMENT 'Source: CommissionLevelRankPK',
    commission_level_code    STRING COMMENT 'Source: CommissionLevelCode',
    rank_order               INT    COMMENT 'Source: RankOrder',
    description              STRING COMMENT 'Source: Description'
""", "CommissionLevelRank", "FULL", "distribution", "INTERNAL")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: POLICY
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: policy ---")

external_table("account_value_base", """
    account_value_id        INT           NOT NULL COMMENT 'Source: AccountValuePK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    investment_id           INT           COMMENT 'Source: InvestmentFK',
    valuation_date          DATE          NOT NULL COMMENT 'Source: ValuationDate',
    account_value_amount    DECIMAL(18,4) COMMENT 'Source: AccountValueAmount',
    surrender_value_amount  DECIMAL(18,4) COMMENT 'Source: SurrenderValueAmount',
    units                   DECIMAL(18,6) COMMENT 'Source: Units',
    unit_value              DECIMAL(18,6) COMMENT 'Source: UnitValue',
    interest_rate           DECIMAL(10,6) COMMENT 'Source: InterestRate',
    value_type_code         STRING        COMMENT 'Source: ValueType'
""", "AccountValue", "INCREMENTAL", "policy", "CONFIDENTIAL", "0.00")

external_table("contract_deposit_base", """
    contract_deposit_id     INT           NOT NULL COMMENT 'Source: ContractDepositPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    deposit_date            DATE          NOT NULL COMMENT 'Source: DepositDate',
    deposit_amount          DECIMAL(18,4) COMMENT 'Source: DepositAmount',
    deposit_type_code       STRING        COMMENT 'Source: DepositType',
    check_number            STRING        COMMENT 'Source: CheckNumber',
    is_applied              BOOLEAN       COMMENT 'Source: AppliedInd'
""", "ContractDeposit", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("contract_value_group_base", """
    contract_value_group_id INT           NOT NULL COMMENT 'Source: ContractValueGroupPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    value_type_code         STRING        COMMENT 'Source: ValueType',
    value_date              DATE          COMMENT 'Source: ValueDate',
    value_amount            DECIMAL(18,4) COMMENT 'Source: ValueAmount',
    value_units             DECIMAL(18,6) COMMENT 'Source: ValueUnits'
""", "ContractValue_Group", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("recurring_payment_base", """
    recurring_payment_id    INT           NOT NULL COMMENT 'Source: RecurringPaymentPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    payment_amount          DECIMAL(18,4) COMMENT 'Source: PaymentAmount',
    payment_frequency_code  STRING        COMMENT 'Source: PaymentFrequency',
    payment_method_code     STRING        COMMENT 'Source: PaymentMethod',
    effective_date_rp       DATE          COMMENT 'Source: EffectiveDate — renamed',
    termination_date        DATE          COMMENT 'Source: TerminationDate',
    is_active               BOOLEAN       COMMENT 'Source: ActiveInd',
    bank_routing_number     STRING        COMMENT 'Source: BankRoutingNumber — masked in semantic model',
    bank_account_last4      STRING        COMMENT 'Source: BankAccountLast4'
""", "RecurringPayment", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("rider_group_base", """
    rider_group_id          INT           NOT NULL COMMENT 'Source: RiderGroupPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    rider_type_code         STRING        COMMENT 'Source: RiderType',
    effective_date_rg       DATE          COMMENT 'Source: EffectiveDate — renamed',
    expiration_date_rg      DATE          COMMENT 'Source: ExpirationDate — renamed',
    rider_benefit_amount    DECIMAL(18,4) COMMENT 'Source: RiderBenefitAmount',
    is_active               BOOLEAN       COMMENT 'Source: ActiveInd'
""", "Rider_Group", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("requirement_group_base", """
    requirement_group_id    INT     NOT NULL COMMENT 'Source: RequirementGroupPK',
    contract_id             INT     NOT NULL COMMENT 'Source: ContractFK',
    requirement_type_code   STRING  COMMENT 'Source: RequirementType',
    requirement_status_code STRING  COMMENT 'Source: RequirementStatus',
    due_date                DATE    COMMENT 'Source: DueDate',
    received_date           DATE    COMMENT 'Source: ReceivedDate',
    waived_date             DATE    COMMENT 'Source: WaivedDate'
""", "Requirement_Group", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("note_group_base", """
    note_group_id           INT     NOT NULL COMMENT 'Source: NoteGroupPK',
    contract_id             INT     COMMENT 'Source: ContractFK',
    note_date               DATE    COMMENT 'Source: NoteDate',
    note_type_code          STRING  COMMENT 'Source: NoteType',
    note_text               STRING  COMMENT 'Source: NoteText',
    created_by_user_id      STRING  COMMENT 'Source: CreatedByUserID',
    is_private              BOOLEAN COMMENT 'Source: PrivateInd'
""", "Note_Group", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("cap_repayment_base", """
    cap_repayment_id        INT           NOT NULL COMMENT 'Source: CAPRepaymentPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    repayment_date          DATE          NOT NULL COMMENT 'Source: RepaymentDate',
    repayment_amount        DECIMAL(18,4) COMMENT 'Source: RepaymentAmount',
    remaining_cap_amount    DECIMAL(18,4) COMMENT 'Source: RemainingCAPAmount',
    cap_type_code           STRING        COMMENT 'Source: CAPType'
""", "CAPRepayment", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("cap_status_change_base", """
    cap_status_change_id    INT     NOT NULL COMMENT 'Source: CAPStatusChangePK',
    contract_id             INT     NOT NULL COMMENT 'Source: ContractFK',
    change_date             DATE    NOT NULL COMMENT 'Source: ChangeDate',
    prior_status_code       STRING  COMMENT 'Source: PriorStatus',
    new_status_code         STRING  COMMENT 'Source: NewStatus',
    change_reason_code      STRING  COMMENT 'Source: ChangeReason',
    changed_by_user_id      STRING  COMMENT 'Source: ChangedByUserID'
""", "CAPStatusChange", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("additional_info_group_base", """
    additional_info_id      INT     NOT NULL COMMENT 'Source: AdditionalInfoGroupPK',
    contract_id             INT     NOT NULL COMMENT 'Source: ContractFK',
    info_key                STRING  COMMENT 'Source: InfoKey',
    info_value              STRING  COMMENT 'Source: InfoValue',
    effective_date_ai       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "AdditionalInfo_Group", "INCREMENTAL", "policy", "CONFIDENTIAL")

external_table("product_state_approval_base", """
    product_state_approval_id  INT     NOT NULL COMMENT 'Source: ProductStateApprovalPK',
    product_id                 INT     NOT NULL COMMENT 'Source: ProductFK',
    state_code                 STRING  NOT NULL COMMENT 'Source: StateCode',
    approval_date              DATE    COMMENT 'Source: ApprovalDate',
    withdrawal_date            DATE    COMMENT 'Source: WithdrawalDate',
    is_approved                BOOLEAN COMMENT 'Source: ApprovedInd'
""", "ProductStateApproval", "FULL", "policy", "INTERNAL")

external_table("product_state_variation_base", """
    product_state_variation_id INT     NOT NULL COMMENT 'Source: ProductStateVariationPK',
    product_id                 INT     NOT NULL COMMENT 'Source: ProductFK',
    state_code                 STRING  NOT NULL COMMENT 'Source: StateCode',
    variation_type_code        STRING  COMMENT 'Source: VariationType',
    variation_value            STRING  COMMENT 'Source: VariationValue',
    effective_date_psv         DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "ProductStateVariation", "FULL", "policy", "INTERNAL")

external_table("product_state_approval_disclosure_base", """
    disclosure_id           INT     NOT NULL COMMENT 'Source: ProductStateApprovalDisclosurePK',
    product_state_approval_id INT  NOT NULL COMMENT 'Source: ProductStateApprovalFK',
    disclosure_type_code    STRING  COMMENT 'Source: DisclosureType',
    disclosure_text         STRING  COMMENT 'Source: DisclosureText',
    effective_date_psd      DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "ProductStateApprovalDisclosure", "FULL", "policy", "INTERNAL")

external_table("renewal_rate_base", """
    renewal_rate_id         INT           NOT NULL COMMENT 'Source: RenewalRatePK',
    product_id              INT           NOT NULL COMMENT 'Source: ProductFK',
    rate_effective_date     DATE          NOT NULL COMMENT 'Source: RateEffectiveDate',
    rate_expiration_date    DATE          COMMENT 'Source: RateExpirationDate',
    interest_rate           DECIMAL(10,6) COMMENT 'Source: InterestRate',
    rate_type_code          STRING        COMMENT 'Source: RateType',
    state_code              STRING        COMMENT 'Source: StateCode'
""", "RenewalRate", "INCREMENTAL", "policy", "INTERNAL")

external_table("surrender_base", """
    surrender_id            INT           NOT NULL COMMENT 'Source: SurrenderPK',
    surrender_type_code     STRING        COMMENT 'Source: SurrenderType',
    surrender_charge_years  INT           COMMENT 'Source: SurrenderChargeYears',
    year1_rate              DECIMAL(10,6) COMMENT 'Source: Year1Rate',
    year2_rate              DECIMAL(10,6) COMMENT 'Source: Year2Rate',
    year3_rate              DECIMAL(10,6) COMMENT 'Source: Year3Rate',
    year4_rate              DECIMAL(10,6) COMMENT 'Source: Year4Rate',
    year5_rate              DECIMAL(10,6) COMMENT 'Source: Year5Rate',
    year6_rate              DECIMAL(10,6) COMMENT 'Source: Year6Rate',
    year7_rate              DECIMAL(10,6) COMMENT 'Source: Year7Rate',
    year8_rate              DECIMAL(10,6) COMMENT 'Source: Year8Rate',
    free_withdrawal_pct     DECIMAL(10,6) COMMENT 'Source: FreeWithdrawalPercentage'
""", "Surrender", "FULL", "policy", "INTERNAL")

external_table("product_base", """
    product_id              INT     NOT NULL COMMENT 'Source: ProductPK',
    product_code            STRING  COMMENT 'Source: ProductCode',
    product_name            STRING  COMMENT 'Source: ProductName',
    product_type_code       STRING  COMMENT 'Source: ProductType',
    company_id              INT     COMMENT 'Source: CompanyFK',
    surrender_id            INT     COMMENT 'Source: SurrenderFK',
    effective_date_product  DATE    COMMENT 'Source: EffectiveDate — renamed',
    discontinuation_date    DATE    COMMENT 'Source: DiscontinuationDate',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd',
    min_issue_age           INT     COMMENT 'Source: MinIssueAge',
    max_issue_age           INT     COMMENT 'Source: MaxIssueAge',
    min_premium_amount      DECIMAL(18,4) COMMENT 'Source: MinPremium',
    max_premium_amount      DECIMAL(18,4) COMMENT 'Source: MaxPremium'
""", "Product", "FULL", "policy", "INTERNAL")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: FINANCE
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: finance ---")

external_table("accounting_base", """
    accounting_id           BIGINT        NOT NULL COMMENT 'Source: AccountingPK',
    contract_id             INT           COMMENT 'Source: ContractFK',
    accounting_account_id   INT           COMMENT 'Source: AccountingAccountFK',
    company_id              INT           COMMENT 'Source: CompanyFK',
    entry_date              DATE          COMMENT 'Source: EntryDate',
    entry_update_date       DATE          COMMENT 'Source: EntryUpdateDate — watermark column',
    posting_date            DATE          COMMENT 'Source: PostingDate',
    period_year             INT           COMMENT 'Source: PeriodYear',
    period_month            INT           COMMENT 'Source: PeriodMonth',
    debit_amount            DECIMAL(18,4) COMMENT 'Source: DebitAmount',
    credit_amount           DECIMAL(18,4) COMMENT 'Source: CreditAmount',
    net_amount              DECIMAL(18,4) COMMENT 'Source: NetAmount',
    journal_reference       STRING        COMMENT 'Source: JournalReference',
    reporting_group_id      INT           COMMENT 'Source: AccountingReportingGroupFK',
    is_reversed             BOOLEAN       COMMENT 'Source: ReversedInd'
""", "Accounting", "INCREMENTAL", "finance", "CONFIDENTIAL", "0.00")

external_table("accounting_detail_base", """
    accounting_detail_id    BIGINT        NOT NULL COMMENT 'Source: AccountingDetailPK',
    accounting_id           BIGINT        NOT NULL COMMENT 'Source: AccountingFK',
    detail_type_code        STRING        COMMENT 'Source: DetailType',
    detail_amount           DECIMAL(18,4) COMMENT 'Source: DetailAmount',
    detail_description      STRING        COMMENT 'Source: DetailDescription',
    entry_update_date       DATE          COMMENT 'Source: EntryUpdateDate — watermark column'
""", "AccountingDetail", "INCREMENTAL", "finance", "CONFIDENTIAL")

external_table("activity_financial_base", """
    activity_financial_id       BIGINT        NOT NULL COMMENT 'Source: ActivityFinancialPK',
    activity_id                 BIGINT        NOT NULL COMMENT 'Source: ActivityFK',
    gross_amount                DECIMAL(18,4) COMMENT 'Source: GrossAmount',
    federal_withholding_amount  DECIMAL(18,4) COMMENT 'Source: FederalWithholdingAmount',
    state_withholding_amount    DECIMAL(18,4) COMMENT 'Source: StateWithholdingAmount',
    net_amount                  DECIMAL(18,4) COMMENT 'Source: NetAmount',
    penalty_amount              DECIMAL(18,4) COMMENT 'Source: PenaltyAmount',
    surrender_charge_amount     DECIMAL(18,4) COMMENT 'Source: SurrenderChargeAmount',
    market_value_adjustment     DECIMAL(18,4) COMMENT 'Source: MarketValueAdjustment',
    process_date_key            INT           COMMENT 'Source: ProcessDateFK — watermark'
""", "ActivityFinancial", "INCREMENTAL", "finance", "CONFIDENTIAL")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: INVESTMENT
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: investment ---")

external_table("investment_base", """
    investment_id           INT     NOT NULL COMMENT 'Source: InvestmentPK',
    investment_code         STRING  COMMENT 'Source: InvestmentCode',
    investment_name         STRING  COMMENT 'Source: InvestmentName',
    investment_type_code    STRING  COMMENT 'Source: InvestmentType',
    fund_family             STRING  COMMENT 'Source: FundFamily',
    ticker_symbol           STRING  COMMENT 'Source: TickerSymbol',
    inception_date          DATE    COMMENT 'Source: InceptionDate',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "Investment", "FULL", "investment", "INTERNAL")

external_table("investment_detail_base", """
    investment_detail_id    INT           NOT NULL COMMENT 'Source: InvestmentDetailPK',
    investment_id           INT           NOT NULL COMMENT 'Source: InvestmentFK',
    detail_type_code        STRING        COMMENT 'Source: DetailType',
    detail_date             DATE          COMMENT 'Source: DetailDate',
    detail_value            DECIMAL(18,6) COMMENT 'Source: DetailValue',
    detail_description      STRING        COMMENT 'Source: DetailDescription'
""", "InvestmentDetail", "FULL", "investment", "INTERNAL")

external_table("index_value_base", """
    index_value_id          INT           NOT NULL COMMENT 'Source: IndexValuePK',
    investment_id           INT           NOT NULL COMMENT 'Source: InvestmentFK',
    index_date              DATE          NOT NULL COMMENT 'Source: IndexDate — watermark',
    index_value_amount      DECIMAL(18,6) COMMENT 'Source: IndexValue',
    index_type_code         STRING        COMMENT 'Source: IndexType',
    source_code             STRING        COMMENT 'Source: SourceCode'
""", "IndexValue", "INCREMENTAL", "investment", "INTERNAL")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: RISK
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: risk ---")

external_table("reinsurance_group_base", """
    reinsurance_group_id    INT           NOT NULL COMMENT 'Source: ReinsuranceGroupPK',
    contract_id             INT           NOT NULL COMMENT 'Source: ContractFK',
    reinsurer_code          STRING        COMMENT 'Source: ReinsurerCode',
    treaty_code             STRING        COMMENT 'Source: TreatyCode',
    effective_date_ri       DATE          COMMENT 'Source: EffectiveDate — renamed',
    termination_date        DATE          COMMENT 'Source: TerminationDate',
    ceded_amount            DECIMAL(18,4) COMMENT 'Source: CededAmount',
    retained_amount         DECIMAL(18,4) COMMENT 'Source: RetainedAmount',
    is_active               BOOLEAN       COMMENT 'Source: ActiveInd'
""", "Reinsurance_Group", "INCREMENTAL", "risk", "CONFIDENTIAL")

external_table("hedge_ratios_base", """
    hedge_ratio_id          INT           NOT NULL COMMENT 'Source: RatiosPK — schema: hedge',
    contract_id             INT           COMMENT 'Source: ContractFK',
    ratio_date              DATE          NOT NULL COMMENT 'Source: RatioDate — watermark',
    delta_ratio             DECIMAL(18,6) COMMENT 'Source: DeltaRatio',
    gamma_ratio             DECIMAL(18,6) COMMENT 'Source: GammaRatio',
    vega_ratio              DECIMAL(18,6) COMMENT 'Source: VegaRatio',
    rho_ratio               DECIMAL(18,6) COMMENT 'Source: RhoRatio',
    hedge_program_code      STRING        COMMENT 'Source: HedgeProgramCode'
""", "hedge.Ratios", "INCREMENTAL", "risk", "CONFIDENTIAL")

external_table("hedge_options_base", """
    hedge_option_id         INT           NOT NULL COMMENT 'Source: OptionsPK — schema: hedge',
    contract_id             INT           COMMENT 'Source: ContractFK',
    option_date             DATE          NOT NULL COMMENT 'Source: OptionDate — watermark',
    option_type_code        STRING        COMMENT 'Source: OptionType',
    strike_price            DECIMAL(18,4) COMMENT 'Source: StrikePrice',
    market_value            DECIMAL(18,4) COMMENT 'Source: MarketValue',
    notional_amount         DECIMAL(18,4) COMMENT 'Source: NotionalAmount',
    instrument_code         STRING        COMMENT 'Source: InstrumentCode',
    expiration_date_ho      DATE          COMMENT 'Source: ExpirationDate — renamed'
""", "hedge.Options", "INCREMENTAL", "risk", "CONFIDENTIAL")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: CLIENT
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: client ---")

external_table("external_account_group_base", """
    external_account_id     INT     NOT NULL COMMENT 'Source: ExternalAccountGroupPK',
    client_id               INT     NOT NULL COMMENT 'Source: ClientFK',
    contract_id             INT     COMMENT 'Source: ContractFK',
    bank_name               STRING  COMMENT 'Source: BankName',
    account_type_code       STRING  COMMENT 'Source: AccountType',
    routing_number          STRING  COMMENT 'Source: RoutingNumber — masked in semantic model',
    account_last4           STRING  COMMENT 'Source: AccountLast4',
    effective_date_ea       DATE    COMMENT 'Source: EffectiveDate — renamed',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "ExternalAccount_Group", "INCREMENTAL", "client", "RESTRICTED", "0.00",
    extra_props="'equitrust.pii' = 'true',")

external_table("additional_client_group_base", """
    additional_client_id    INT     NOT NULL COMMENT 'Source: AdditionalClientGroupPK',
    contract_id             INT     NOT NULL COMMENT 'Source: ContractFK',
    client_id               INT     NOT NULL COMMENT 'Source: ClientFK',
    relationship_type_code  STRING  COMMENT 'Source: RelationshipType',
    effective_date_acg      DATE    COMMENT 'Source: EffectiveDate — renamed',
    termination_date        DATE    COMMENT 'Source: TerminationDate',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "AdditionalClient_Group", "INCREMENTAL", "client", "RESTRICTED",
    extra_props="'equitrust.pii' = 'true',")

# ═══════════════════════════════════════════════════════════════════════════════
# DOMAIN: REFERENCE
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- Domain: reference ---")

external_table("date_base", """
    date_id                 INT     NOT NULL COMMENT 'Source: DatePK — YYYYMMDD integer',
    full_date               DATE    NOT NULL COMMENT 'Source: FullDate',
    year                    INT     COMMENT 'Source: Year',
    quarter                 INT     COMMENT 'Source: Quarter',
    month                   INT     COMMENT 'Source: Month',
    month_name              STRING  COMMENT 'Source: MonthName',
    week_of_year            INT     COMMENT 'Source: WeekOfYear',
    day_of_week             INT     COMMENT 'Source: DayOfWeek',
    day_name                STRING  COMMENT 'Source: DayName',
    is_weekend              BOOLEAN COMMENT 'Source: WeekendInd',
    is_holiday              BOOLEAN COMMENT 'Source: HolidayInd',
    fiscal_year             INT     COMMENT 'Source: FiscalYear',
    fiscal_quarter          INT     COMMENT 'Source: FiscalQuarter',
    fiscal_month            INT     COMMENT 'Source: FiscalMonth'
""", "Date", "FULL", "reference", "INTERNAL")

external_table("state_base", """
    state_id                INT     NOT NULL COMMENT 'Source: StatePK',
    state_code              STRING  NOT NULL COMMENT 'Source: StateCode',
    state_name              STRING  COMMENT 'Source: StateName',
    state_abbrev            STRING  COMMENT 'Source: StateAbbrev',
    country_code            STRING  COMMENT 'Source: CountryCode',
    region_name             STRING  COMMENT 'Source: RegionName',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "State", "FULL", "reference", "INTERNAL")

external_table("company_base", """
    company_id              INT     NOT NULL COMMENT 'Source: CompanyPK',
    company_code            STRING  COMMENT 'Source: CompanyCode',
    company_name            STRING  COMMENT 'Source: CompanyName',
    company_type_code       STRING  COMMENT 'Source: CompanyType',
    ein                     STRING  COMMENT 'Source: EIN — masked in semantic model',
    naic_code               STRING  COMMENT 'Source: NAICCode',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd',
    domicile_state_code     STRING  COMMENT 'Source: DomicileState'
""", "Company", "FULL", "reference", "INTERNAL")

external_table("activity_type_base", """
    activity_type_id        INT     NOT NULL COMMENT 'Source: ActivityTypePK',
    activity_type_code      STRING  COMMENT 'Source: ActivityTypeCode',
    activity_type_name      STRING  COMMENT 'Source: ActivityTypeName',
    activity_category_code  STRING  COMMENT 'Source: ActivityCategory',
    is_financial            BOOLEAN COMMENT 'Source: FinancialInd',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "ActivityType", "FULL", "reference", "INTERNAL")

external_table("accounting_account_base", """
    accounting_account_id   INT     NOT NULL COMMENT 'Source: AccountingAccountPK',
    account_number          STRING  COMMENT 'Source: AccountNumber',
    account_name            STRING  COMMENT 'Source: AccountName',
    account_type_code       STRING  COMMENT 'Source: AccountType',
    account_category_code   STRING  COMMENT 'Source: AccountCategory',
    normal_balance_code     STRING  COMMENT 'Source: NormalBalance',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "AccountingAccount", "FULL", "reference", "INTERNAL")

external_table("accounting_reporting_group_base", """
    reporting_group_id      INT     NOT NULL COMMENT 'Source: AccountingReportingGroupPK',
    reporting_group_code    STRING  COMMENT 'Source: ReportingGroupCode',
    reporting_group_name    STRING  COMMENT 'Source: ReportingGroupName',
    sort_order              INT     COMMENT 'Source: SortOrder',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "AccountingReporting_Group", "FULL", "reference", "INTERNAL")

external_table("product_variation_detail_base", """
    product_variation_detail_id INT    NOT NULL COMMENT 'Source: ProductVariationDetailPK',
    product_id                  INT    NOT NULL COMMENT 'Source: ProductFK',
    variation_code              STRING COMMENT 'Source: VariationCode',
    variation_description       STRING COMMENT 'Source: VariationDescription',
    effective_date_pvd          DATE   COMMENT 'Source: EffectiveDate — renamed',
    is_active                   BOOLEAN COMMENT 'Source: ActiveInd'
""", "ProductVariationDetail", "FULL", "reference", "INTERNAL")

external_table("training_course_base", """
    course_id               INT     NOT NULL COMMENT 'Source: TrainingCoursePK',
    course_code             STRING  COMMENT 'Source: CourseCode',
    course_name             STRING  COMMENT 'Source: CourseName',
    course_type_code        STRING  COMMENT 'Source: CourseType',
    credit_hours            DECIMAL(5,2) COMMENT 'Source: CreditHours',
    provider_name           STRING  COMMENT 'Source: ProviderName',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd'
""", "TrainingCourse", "FULL", "reference", "INTERNAL")

external_table("last_processing_base", """
    last_processing_id      INT     NOT NULL COMMENT 'Source: LastProcessingPK',
    process_type_code       STRING  NOT NULL COMMENT 'Source: ProcessType',
    last_process_date       DATE    COMMENT 'Source: LastProcessDate',
    last_process_datetime   TIMESTAMP COMMENT 'Source: LastProcessDateTime',
    status_code             STRING  COMMENT 'Source: Status'
""", "LastProcessing", "FULL", "control", "INTERNAL")

# ═══════════════════════════════════════════════════════════════════════════════
# VIEW-SOURCED BRONZE TARGETS
# ═══════════════════════════════════════════════════════════════════════════════
logger.info("--- View-sourced Bronze targets ---")

external_table("ref_product_base", """
    product_id              INT     NOT NULL COMMENT 'Source: ref_Product.ProductPK',
    product_code            STRING  COMMENT 'Source: ProductCode',
    product_name            STRING  COMMENT 'Source: ProductName',
    product_type_code       STRING  COMMENT 'Source: ProductType',
    company_id              INT     COMMENT 'Source: CompanyFK',
    company_name            STRING  COMMENT 'Source: CompanyName — denormalized in view',
    is_active               BOOLEAN COMMENT 'Source: ActiveInd',
    effective_date_rp       DATE    COMMENT 'Source: EffectiveDate — renamed'
""", "ref_Product", "FULL", "policy", "INTERNAL")

external_table("vw_seg_client_base", """
    client_id               INT     NOT NULL COMMENT 'Source: vw_SEG_Client.ClientPK',
    full_name               STRING  COMMENT 'Source: FullName — PII',
    date_of_birth           DATE    COMMENT 'Source: DateOfBirth — PII',
    state_code              STRING  COMMENT 'Source: StateCode',
    client_type_code        STRING  COMMENT 'Source: ClientType',
    contract_count          INT     COMMENT 'Source: ContractCount',
    total_account_value     DECIMAL(18,4) COMMENT 'Source: TotalAccountValue'
""", "vw_SEG_Client", "FULL", "client", "RESTRICTED", "0.00",
    extra_props="'equitrust.pii' = 'true',")

logger.info("=== Bronze DDL Complete — ALL domain tables created successfully ===")
logger.flush_to_delta(spark, AUDIT_TABLE_PATH)
