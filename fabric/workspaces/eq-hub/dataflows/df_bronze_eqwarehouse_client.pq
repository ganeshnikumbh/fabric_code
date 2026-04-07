// ══════════════════════════════════════════════════════════════════════════════
// Dataflow Gen2 — Power Query M
// Dataflow:    df_bronze_eqwarehouse_client
// Target:      bronze_eqwarehouse.client_base
// Load type:   INCREMENTAL (temporal — StartDate watermark)
// Sensitivity: RESTRICTED — PII; tax_id_hash/last4_hash stored as binary
//
// HOW TO USE IN DATAFLOW GEN2:
//   1. Open Dataflow Gen2 in Fabric
//   2. Create these parameters via Home > Manage Parameters > New Parameter:
//        Name                  | Type | Default value
//        ----------------------|------|------------------
//        p_source_schema       | Text | dbo
//        p_source_table_name   | Text | Client
//        p_target_table_name   | Text | client_base
//        p_load_type           | Text | INCREMENTAL
//        p_watermark_column    | Text | StartDate
//        p_watermark_start     | Text | 2024-01-14
//        p_watermark_end       | Text | 2024-01-15
//        p_data_date           | Text | 2024-01-15
//        p_ingestion_run_id    | Text | 00000000-0000-0000-0000-000000000000
//        p_source_system       | Text | eqwarehouse
//
//   3. Create a new blank query, open Advanced Editor (Home > Advanced Editor)
//   4. Replace ALL content with the let...in block below (everything after this comment block)
//   5. Rename the query to: client_base
//   6. Set destination: lh_bronze_eqwarehouse > client_base
//      Write mode: Append  |  Partition column: data_date
//
// NOTE: Replace __SQL_SERVER_HOST__ and __SQL_SERVER_DATABASE__ with actual
//       values for your environment, or set them as parameters too.
// ══════════════════════════════════════════════════════════════════════════════

let
    // ── Source: SQL Server via On-Premises Data Gateway ───────────────────────
    // Incremental filter: rows where StartDate falls in the watermark window
    // tax_id_hash and last4_hash are varbinary — loaded as binary, DO NOT cast to text
    Source = Sql.Database(
        "__SQL_SERVER_HOST__",
        "__SQL_SERVER_DATABASE__",
        [
            Query =
                "SELECT "
                & "  ClientPK, FirstName, LastName, MiddleName, DateOfBirth, "
                & "  Gender, MaritalStatus, "
                & "  TaxIDHash, Last4Hash, "
                & "  EmailAddress, PhoneNumber, "
                & "  AddressLine1, AddressLine2, City, StateCode, ZipCode, CountryCode, "
                & "  ClientType, EntityInd, EntityName, CitizenshipCountry "
                & "FROM [" & p_source_schema & "].[" & p_source_table_name & "] "
                & "WHERE [" & p_watermark_column & "] > '" & p_watermark_start & "' "
                & "  AND [" & p_watermark_column & "] <= '" & p_watermark_end & "'"
        ]
    ),

    // ── Step 1: Rename columns ─────────────────────────────────────────────────
    // Rules: _PK → _id, Ind suffix → is_ prefix, type → _code suffix
    RenameColumns = Table.RenameColumns(Source, {
        {"ClientPK",           "client_id"},
        {"FirstName",          "first_name"},
        {"LastName",           "last_name"},
        {"MiddleName",         "middle_name"},
        {"DateOfBirth",        "date_of_birth"},
        {"Gender",             "gender_code"},
        {"MaritalStatus",      "marital_status_code"},
        {"TaxIDHash",          "tax_id_hash"},
        {"Last4Hash",          "last4_hash"},
        {"EmailAddress",       "email_address"},
        {"PhoneNumber",        "phone_number"},
        {"AddressLine1",       "address_line1"},
        {"AddressLine2",       "address_line2"},
        {"City",               "city"},
        {"StateCode",          "state_code"},
        {"ZipCode",            "zip_code"},
        {"CountryCode",        "country_code"},
        {"ClientType",         "client_type_code"},
        {"EntityInd",          "is_entity"},
        {"EntityName",         "entity_name"},
        {"CitizenshipCountry", "citizenship_country"}
    }),

    // ── Step 2: Type casting ───────────────────────────────────────────────────
    // tax_id_hash and last4_hash stay as type binary — DO NOT cast to text
    TypeCast = Table.TransformColumnTypes(RenameColumns, {
        {"client_id",           Int32.Type},
        {"first_name",          type text},
        {"last_name",           type text},
        {"middle_name",         type text},
        {"date_of_birth",       type date},
        {"gender_code",         type text},
        {"marital_status_code", type text},
        {"tax_id_hash",         type binary},
        {"last4_hash",          type binary},
        {"email_address",       type text},
        {"phone_number",        type text},
        {"address_line1",       type text},
        {"address_line2",       type text},
        {"city",                type text},
        {"state_code",          type text},
        {"zip_code",            type text},
        {"country_code",        type text},
        {"client_type_code",    type text},
        {"is_entity",           type logical},
        {"entity_name",         type text},
        {"citizenship_country", type text}
    }),

    // ── Step 3: Null handling — Bronze rule: booleans only ────────────────────
    NullHandle = Table.TransformColumns(TypeCast, {
        {"is_entity", each if _ = null then false else _}
    }),

    // ── Step 4: Add 5 mandatory metadata columns ───────────────────────────────
    AddIngestionDate = Table.AddColumn(NullHandle,       "ingestion_date",   each Date.From(DateTime.LocalNow()),          type date),
    AddDataDate      = Table.AddColumn(AddIngestionDate, "data_date",        each Date.From(DateTime.FromText(p_data_date)), type date),
    AddSourceSystem  = Table.AddColumn(AddDataDate,      "source_system",    each p_source_system,                         type text),
    AddRunId         = Table.AddColumn(AddSourceSystem,  "ingestion_run_id", each p_ingestion_run_id,                      type text),
    AddIsDeleted     = Table.AddColumn(AddRunId,         "is_deleted",       each false,                                   type logical),

    // ── Step 5: Reorder — business columns first, metadata last ───────────────
    Result = Table.ReorderColumns(AddIsDeleted, {
        "client_id",
        "first_name", "last_name", "middle_name", "date_of_birth",
        "gender_code", "marital_status_code",
        "tax_id_hash", "last4_hash",
        "email_address", "phone_number",
        "address_line1", "address_line2", "city", "state_code", "zip_code", "country_code",
        "client_type_code", "is_entity", "entity_name", "citizenship_country",
        "ingestion_date", "data_date", "source_system", "ingestion_run_id", "is_deleted"
    })

in
    Result
