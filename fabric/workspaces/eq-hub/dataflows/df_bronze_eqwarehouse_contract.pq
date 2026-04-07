// ══════════════════════════════════════════════════════════════════════════════
// Dataflow Gen2 — Power Query M
// Dataflow:    df_bronze_eqwarehouse_contract
// Target:      bronze_eqwarehouse.contract_base
// Load type:   INCREMENTAL (temporal — StartDate watermark)
// Sensitivity: CONFIDENTIAL
//
// HOW TO USE IN DATAFLOW GEN2:
//   1. Open Dataflow Gen2 in Fabric
//   2. Create these parameters via Home > Manage Parameters > New Parameter:
//        Name                  | Type | Default value
//        ----------------------|------|------------------
//        p_source_schema       | Text | dbo
//        p_source_table_name   | Text | Contract
//        p_target_table_name   | Text | contract_base
//        p_load_type           | Text | INCREMENTAL
//        p_watermark_column    | Text | StartDate
//        p_watermark_start     | Text | 2024-01-14
//        p_watermark_end       | Text | 2024-01-15
//        p_data_date           | Text | 2024-01-15
//        p_ingestion_run_id    | Text | 00000000-0000-0000-0000-000000000000
//        p_source_system       | Text | eqwarehouse
//
//   3. Create a new blank query > Advanced Editor > replace all with the let...in block below
//   4. Rename the query to: contract_base
//   5. Set destination: lh_bronze_eqwarehouse > contract_base
//      Write mode: Append  |  Partition column: data_date
//
// NOTE: effective_date renamed to effective_date_policy to avoid SCD2 column
//       name collision in Silver S1.
// ══════════════════════════════════════════════════════════════════════════════

let
    // ── Source: SQL Server via On-Premises Data Gateway ───────────────────────
    Source = Sql.Database(
        "__SQL_SERVER_HOST__",
        "__SQL_SERVER_DATABASE__",
        [
            Query =
                "SELECT "
                & "  ContractPK, ContractNumber, HierarchyGroupKey, ContractValueGroupKey, "
                & "  SurrenderFK, ProductFK, OwnerClientFK, Owner2ClientFK, "
                & "  AnnuitantInsuredClientFK, AnnuitantInsured2ClientFK, "
                & "  ApplicationReceivedDate, ApplicationSignedDate, EffectiveDate, "
                & "  IssueDate, IssueState, IssueAge, AttainedAge, Status, "
                & "  CostBasis, RecoveredCostBasis, "
                & "  QualInd, QualificationType, [Option], CertainPeriod, MECStatus, "
                & "  SpousalContinuationInd, SupplementalContractInd, QDROInd, "
                & "  RiderClaimInd, RothConversionInd, InternalReplacementInd, "
                & "  PartialTaxConversionInd, WaiverInEffectInd, EDeliveryInd, "
                & "  Class, UnderwritingClass, UnderwritingDate, CoverageRatio, "
                & "  ContractEndDate, FundingCompanyFK "
                & "FROM [" & p_source_schema & "].[" & p_source_table_name & "] "
                & "WHERE [" & p_watermark_column & "] > '" & p_watermark_start & "' "
                & "  AND [" & p_watermark_column & "] <= '" & p_watermark_end & "'"
        ]
    ),

    // ── Step 1: Rename columns ─────────────────────────────────────────────────
    // EffectiveDate → effective_date_policy (avoids SCD2 column collision in Silver S1)
    RenameColumns = Table.RenameColumns(Source, {
        {"ContractPK",               "contract_id"},
        {"ContractNumber",           "contract_number"},
        {"HierarchyGroupKey",        "hierarchy_group_key"},
        {"ContractValueGroupKey",    "contract_value_group_key"},
        {"SurrenderFK",              "surrender_id"},
        {"ProductFK",                "product_id"},
        {"OwnerClientFK",            "owner_client_id"},
        {"Owner2ClientFK",           "owner2_client_id"},
        {"AnnuitantInsuredClientFK", "annuitant_insured_client_id"},
        {"AnnuitantInsured2ClientFK","annuitant_insured2_client_id"},
        {"ApplicationReceivedDate",  "application_received_date"},
        {"ApplicationSignedDate",    "application_signed_date"},
        {"EffectiveDate",            "effective_date_policy"},
        {"IssueDate",                "issue_date"},
        {"IssueState",               "issue_state_code"},
        {"IssueAge",                 "issue_age"},
        {"AttainedAge",              "attained_age"},
        {"Status",                   "status_code"},
        {"CostBasis",                "cost_basis_amount"},
        {"RecoveredCostBasis",       "recovered_cost_basis_amount"},
        {"QualInd",                  "is_qualified"},
        {"QualificationType",        "qualification_type_code"},
        {"Option",                   "option_code"},
        {"CertainPeriod",            "certain_period"},
        {"MECStatus",                "mec_status_code"},
        {"SpousalContinuationInd",   "has_spousal_continuation"},
        {"SupplementalContractInd",  "is_supplemental_contract"},
        {"QDROInd",                  "is_qdro"},
        {"RiderClaimInd",            "has_rider_claim"},
        {"RothConversionInd",        "is_roth_conversion"},
        {"InternalReplacementInd",   "is_internal_replacement"},
        {"PartialTaxConversionInd",  "is_partial_tax_conversion"},
        {"WaiverInEffectInd",        "has_waiver_in_effect"},
        {"EDeliveryInd",             "is_edelivery"},
        {"Class",                    "class_code"},
        {"UnderwritingClass",        "underwriting_class_code"},
        {"UnderwritingDate",         "underwriting_date"},
        {"CoverageRatio",            "coverage_ratio"},
        {"ContractEndDate",          "contract_end_date"},
        {"FundingCompanyFK",         "funding_company_id"}
    }),

    // ── Step 2: Type casting ───────────────────────────────────────────────────
    TypeCast = Table.TransformColumnTypes(RenameColumns, {
        {"contract_id",                      Int32.Type},
        {"contract_number",                  type text},
        {"hierarchy_group_key",              type text},
        {"contract_value_group_key",         type text},
        {"surrender_id",                     Int32.Type},
        {"product_id",                       Int32.Type},
        {"owner_client_id",                  Int32.Type},
        {"owner2_client_id",                 Int32.Type},
        {"annuitant_insured_client_id",      Int32.Type},
        {"annuitant_insured2_client_id",     Int32.Type},
        {"application_received_date",        type date},
        {"application_signed_date",          type date},
        {"effective_date_policy",            type date},
        {"issue_date",                       type date},
        {"issue_state_code",                 type text},
        {"issue_age",                        Int32.Type},
        {"attained_age",                     Int32.Type},
        {"status_code",                      type text},
        {"cost_basis_amount",                type number},
        {"recovered_cost_basis_amount",      type number},
        {"is_qualified",                     type logical},
        {"qualification_type_code",          type text},
        {"option_code",                      type text},
        {"certain_period",                   Int32.Type},
        {"mec_status_code",                  type text},
        {"has_spousal_continuation",         type logical},
        {"is_supplemental_contract",         type logical},
        {"is_qdro",                          type logical},
        {"has_rider_claim",                  type logical},
        {"is_roth_conversion",               type logical},
        {"is_internal_replacement",          type logical},
        {"is_partial_tax_conversion",        type logical},
        {"has_waiver_in_effect",             type logical},
        {"is_edelivery",                     type logical},
        {"class_code",                       type text},
        {"underwriting_class_code",          type text},
        {"underwriting_date",                type date},
        {"coverage_ratio",                   type number},
        {"contract_end_date",                type date},
        {"funding_company_id",               Int32.Type}
    }),

    // ── Step 3: Null handling — Bronze rule: booleans only ────────────────────
    NullHandle = Table.TransformColumns(TypeCast, {
        {"is_qualified",              each if _ = null then false else _},
        {"has_spousal_continuation",  each if _ = null then false else _},
        {"is_supplemental_contract",  each if _ = null then false else _},
        {"is_qdro",                   each if _ = null then false else _},
        {"has_rider_claim",           each if _ = null then false else _},
        {"is_roth_conversion",        each if _ = null then false else _},
        {"is_internal_replacement",   each if _ = null then false else _},
        {"is_partial_tax_conversion", each if _ = null then false else _},
        {"has_waiver_in_effect",      each if _ = null then false else _},
        {"is_edelivery",              each if _ = null then false else _}
    }),

    // ── Step 4: Add 5 mandatory metadata columns ───────────────────────────────
    AddIngestionDate = Table.AddColumn(NullHandle,       "ingestion_date",   each Date.From(DateTime.LocalNow()),           type date),
    AddDataDate      = Table.AddColumn(AddIngestionDate, "data_date",        each Date.From(DateTime.FromText(p_data_date)), type date),
    AddSourceSystem  = Table.AddColumn(AddDataDate,      "source_system",    each p_source_system,                          type text),
    AddRunId         = Table.AddColumn(AddSourceSystem,  "ingestion_run_id", each p_ingestion_run_id,                       type text),
    AddIsDeleted     = Table.AddColumn(AddRunId,         "is_deleted",       each false,                                    type logical),

    // ── Step 5: Reorder — business columns first, metadata last ───────────────
    Result = Table.ReorderColumns(AddIsDeleted, {
        "contract_id", "contract_number", "hierarchy_group_key", "contract_value_group_key",
        "surrender_id", "product_id", "owner_client_id", "owner2_client_id",
        "annuitant_insured_client_id", "annuitant_insured2_client_id",
        "application_received_date", "application_signed_date", "effective_date_policy",
        "issue_date", "issue_state_code", "issue_age", "attained_age", "status_code",
        "cost_basis_amount", "recovered_cost_basis_amount",
        "is_qualified", "qualification_type_code", "option_code", "certain_period",
        "mec_status_code", "has_spousal_continuation", "is_supplemental_contract",
        "is_qdro", "has_rider_claim", "is_roth_conversion", "is_internal_replacement",
        "is_partial_tax_conversion", "has_waiver_in_effect", "is_edelivery",
        "class_code", "underwriting_class_code", "underwriting_date",
        "coverage_ratio", "contract_end_date", "funding_company_id",
        "ingestion_date", "data_date", "source_system", "ingestion_run_id", "is_deleted"
    })

in
    Result
