// ══════════════════════════════════════════════════════════════════════════════
// Dataflow Gen2 — Power Query M
// Dataflow:    df_bronze_eqwarehouse_territory
// Target:      bronze_eqwarehouse.territory_base
// Load type:   FULL (entire table replaced each run)
// Sensitivity: INTERNAL
//
// HOW TO USE IN DATAFLOW GEN2:
//   1. Open Dataflow Gen2 in Fabric
//   2. Create these parameters via Home > Manage Parameters > New Parameter:
//        Name                  | Type | Default value
//        ----------------------|------|------------------
//        p_source_schema       | Text | dbo
//        p_source_table_name   | Text | Territory
//        p_target_table_name   | Text | territory_base
//        p_load_type           | Text | FULL
//        p_data_date           | Text | 2024-01-15
//        p_ingestion_run_id    | Text | 00000000-0000-0000-0000-000000000000
//        p_source_system       | Text | eqwarehouse
//
//   3. Create a new blank query > Advanced Editor > replace all with the let...in block below
//   4. Rename the query to: territory_base
//   5. Set destination: lh_bronze_eqwarehouse > territory_base
//      Write mode: Replace  |  Partition column: data_date
// ══════════════════════════════════════════════════════════════════════════════

let
    // ── Source: SQL Server via On-Premises Data Gateway ───────────────────────
    // FULL load — no watermark filter; all rows fetched every run
    Source = Sql.Database(
        "__SQL_SERVER_HOST__",
        "__SQL_SERVER_DATABASE__",
        [
            Query =
                "SELECT TerritoryPK, TerritoryName, RegionCode, DistrictCode, TerritoryActive "
                & "FROM [" & p_source_schema & "].[" & p_source_table_name & "]"
        ]
    ),

    // ── Step 1: Rename columns ─────────────────────────────────────────────────
    RenameColumns = Table.RenameColumns(Source, {
        {"TerritoryPK",     "territory_id"},
        {"TerritoryName",   "territory_name"},
        {"RegionCode",      "region_code"},
        {"DistrictCode",    "district_code"},
        {"TerritoryActive", "is_active"}
    }),

    // ── Step 2: Type casting ───────────────────────────────────────────────────
    TypeCast = Table.TransformColumnTypes(RenameColumns, {
        {"territory_id",   Int32.Type},
        {"territory_name", type text},
        {"region_code",    type text},
        {"district_code",  type text},
        {"is_active",      type logical}
    }),

    // ── Step 3: Null handling — Bronze rule: booleans only ────────────────────
    NullHandle = Table.TransformColumns(TypeCast, {
        {"is_active", each if _ = null then false else _}
    }),

    // ── Step 4: Add 5 mandatory metadata columns ───────────────────────────────
    AddIngestionDate = Table.AddColumn(NullHandle,       "ingestion_date",   each Date.From(DateTime.LocalNow()),           type date),
    AddDataDate      = Table.AddColumn(AddIngestionDate, "data_date",        each Date.From(DateTime.FromText(p_data_date)), type date),
    AddSourceSystem  = Table.AddColumn(AddDataDate,      "source_system",    each p_source_system,                          type text),
    AddRunId         = Table.AddColumn(AddSourceSystem,  "ingestion_run_id", each p_ingestion_run_id,                       type text),
    AddIsDeleted     = Table.AddColumn(AddRunId,         "is_deleted",       each false,                                    type logical),

    // ── Step 5: Reorder — business columns first, metadata last ───────────────
    Result = Table.ReorderColumns(AddIsDeleted, {
        "territory_id", "territory_name", "region_code", "district_code", "is_active",
        "ingestion_date", "data_date", "source_system", "ingestion_run_id", "is_deleted"
    })

in
    Result
