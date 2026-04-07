#!/usr/bin/env python3
"""
seed_control_tables.py
Seeds the control framework tables in lh_control (OneLake) from CSV and
computed defaults. Writes to three tables:
  - ingestion_config   : loaded from ingestion_config_seed.csv (62 EQ_Warehouse entities)
  - watermark_control  : initial rows (NULL watermark) for all incremental entities
  - sla_config         : initial SLA definitions for critical entities

Uses OneLake workspace-name-based paths — no storage account GUID required.
Idempotent: mode="overwrite" replaces all rows on each run.

Usage:
    python scripts/seed_control_tables.py \\
        --workspace-name eq-hub-dev \\
        --environment dev \\
        --csv fabric/config/ingestion_config_seed.csv

Requirements:
    pip install deltalake pyarrow azure-identity pandas
"""

import argparse
import sys
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pyarrow as pa
from deltalake import DeltaTable, write_deltalake
from azure.identity import DefaultAzureCredential


# ── Constants ─────────────────────────────────────────────────────────────────
ONELAKE_HOST   = "onelake.dfs.fabric.microsoft.com"
LAKEHOUSE_NAME = "lh_control"
CONTROL_TABLE  = "control_tables"   # Files/ sub-directory in lh_control

VALID_LOAD_TYPES   = {"full", "incremental", "cdc"}
VALID_SOURCE_TYPES = {"sqlserver", "oracle", "api", "sftp", "blob"}
VALID_WM_TYPES     = {"datetime", "integer", "string"}

# Critical entities — get SLA criticality = 'critical' and alert_on_breach = true
CRITICAL_ENTITIES = {
    "Client", "Contract", "Activity", "Accounting",
    "AccountValue", "ExternalAccount_Group", "vw_SEG_Client",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Seed lh_control ingestion_config, watermark_control, and sla_config"
    )
    parser.add_argument("--workspace-name", required=True,
                        help="Fabric workspace name (e.g. eq-hub-dev)")
    parser.add_argument("--environment",    required=True,
                        choices=["dev", "qa", "tst", "prod"])
    parser.add_argument("--csv",            required=True,
                        help="Path to ingestion_config_seed.csv")
    parser.add_argument("--dry-run",        action="store_true",
                        help="Validate only — do not write to OneLake")
    return parser.parse_args()


def onelake_path(workspace_name: str, table_name: str) -> str:
    """Build OneLake abfss:// path for a control table."""
    return (
        f"abfss://{workspace_name}@{ONELAKE_HOST}"
        f"/{LAKEHOUSE_NAME}.Lakehouse/Files/{CONTROL_TABLE}/{table_name}"
    )


def get_storage_options(credential: DefaultAzureCredential) -> dict:
    """Return storage options for delta-rs OneLake authentication."""
    token = credential.get_token("https://storage.azure.com/.default").token
    return {
        "bearer_token": token,
        "use_azure_cli": "false",
    }


# ── Validation ────────────────────────────────────────────────────────────────

def validate_ingestion_config(df: pd.DataFrame) -> list[str]:
    """Validate ingestion_config CSV against the new DDL schema."""
    errors = []

    required_cols = [
        "source_id", "source_name", "source_type", "entity_name",
        "target_lakehouse", "target_schema", "target_table",
        "load_type", "active_flag", "created_by",
    ]
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        errors.append(f"Missing required columns: {missing}")
        return errors

    # No duplicate source_ids
    dupes = df[df.duplicated("source_id", keep=False)]["source_id"].tolist()
    if dupes:
        errors.append(f"Duplicate source_ids: {sorted(set(dupes))}")

    # load_type values
    invalid_lt = df[~df["load_type"].str.strip().str.lower().isin(VALID_LOAD_TYPES)]
    if not invalid_lt.empty:
        errors.append(
            f"Invalid load_type values (must be full|incremental|cdc): "
            f"{invalid_lt[['source_id', 'load_type']].to_dict('records')}"
        )

    # source_type values
    invalid_st = df[~df["source_type"].str.strip().str.lower().isin(VALID_SOURCE_TYPES)]
    if not invalid_st.empty:
        errors.append(
            f"Invalid source_type values (must be sqlserver|oracle|api|sftp|blob): "
            f"{invalid_st[['source_id', 'source_type']].to_dict('records')}"
        )

    # Incremental/CDC must have watermark_column
    inc = df[df["load_type"].str.lower().isin({"incremental", "cdc"})]
    no_wm = inc[inc["watermark_column"].isna() | (inc["watermark_column"].str.strip() == "")]
    if not no_wm.empty:
        errors.append(
            f"incremental/cdc entities missing watermark_column: "
            f"{no_wm['source_id'].tolist()}"
        )

    # watermark_type must be valid when watermark_column is set
    has_wm = df[df["watermark_column"].notna() & (df["watermark_column"].str.strip() != "")]
    if "watermark_type" in df.columns:
        invalid_wt = has_wm[
            ~has_wm["watermark_type"].str.strip().str.lower().isin(VALID_WM_TYPES)
        ]
        if not invalid_wt.empty:
            errors.append(
                f"Invalid watermark_type (must be datetime|integer|string): "
                f"{invalid_wt[['source_id', 'watermark_type']].to_dict('records')}"
            )

    # API entities must have api_endpoint
    api_rows = df[df["source_type"].str.lower() == "api"]
    if "api_endpoint" in df.columns:
        no_endpoint = api_rows[
            api_rows["api_endpoint"].isna() | (api_rows["api_endpoint"].str.strip() == "")
        ]
        if not no_endpoint.empty:
            errors.append(
                f"API source_type entities missing api_endpoint: "
                f"{no_endpoint['source_id'].tolist()}"
            )

    return errors


# ── Type coercion ─────────────────────────────────────────────────────────────

def coerce_ingestion_config(df: pd.DataFrame, now: datetime) -> pd.DataFrame:
    """Coerce CSV string types to correct Python types for PyArrow/Delta write."""
    df = df.copy()

    # Normalise whitespace
    for col in df.select_dtypes("object").columns:
        df[col] = df[col].str.strip()

    # source_id, batch_size → int (nullable)
    df["source_id"] = pd.to_numeric(df["source_id"], errors="coerce").astype("Int32")
    if "batch_size" in df.columns:
        df["batch_size"] = pd.to_numeric(df["batch_size"], errors="coerce").astype("Int32")

    # active_flag → bool
    df["active_flag"] = df["active_flag"].map(
        lambda x: True if str(x).strip().lower() in ("true", "1", "yes") else False
    )

    # Nullable string columns — empty string → None
    nullable_str_cols = [
        "watermark_column", "watermark_type", "extraction_query",
        "api_endpoint", "api_method", "api_headers", "modified_by",
    ]
    for col in nullable_str_cols:
        if col in df.columns:
            df[col] = df[col].replace("", None).where(df[col].notna(), None)

    # Timestamps
    df["created_date"]  = now
    df["modified_date"] = pd.NaT

    return df


# ── Watermark control seed ────────────────────────────────────────────────────

def build_watermark_control(ingestion_df: pd.DataFrame, now: datetime) -> pd.DataFrame:
    """
    Build initial watermark_control rows for all incremental/cdc entities.
    last_watermark_value = None (pipeline will set it after first successful run).
    """
    inc = ingestion_df[
        ingestion_df["load_type"].str.lower().isin({"incremental", "cdc"})
    ].copy()

    wm_rows = []
    for i, row in enumerate(inc.itertuples(), start=1):
        wm_rows.append({
            "watermark_id":             i,
            "source_id":                int(row.source_id),
            "entity_name":              row.entity_name,
            "last_watermark_value":     None,
            "last_watermark_type":      row.watermark_type if pd.notna(row.watermark_type) else None,
            "last_run_datetime":        None,
            "last_successful_datetime": None,
            "last_run_status":          "pending",
            "created_date":             now,
            "modified_date":            None,
        })

    return pd.DataFrame(wm_rows)


# ── SLA config seed ───────────────────────────────────────────────────────────

def build_sla_config(ingestion_df: pd.DataFrame, now: datetime) -> pd.DataFrame:
    """
    Build initial sla_config rows.
    Critical entities: expected window 01:00–05:00 UTC, criticality=critical.
    Standard entities: expected window 01:00–07:00 UTC, criticality=medium.
    """
    sla_rows = []
    sla_id = 1

    for row in ingestion_df.itertuples():
        entity = row.entity_name
        is_critical = any(c in entity for c in CRITICAL_ENTITIES)

        sla_rows.append({
            "sla_id":               sla_id,
            "source_id":            int(row.source_id),
            "entity_name":          entity,
            "layer":                "bronze",
            "expected_start_time":  "01:00",
            "expected_end_time":    "05:00" if is_critical else "07:00",
            "max_duration_minutes": 240 if is_critical else 360,
            "criticality":          "critical" if is_critical else "medium",
            "alert_on_breach":      True if is_critical else False,
            "alert_email":          "data-engineering@equitrust.com",
            "alert_teams_webhook":  None,
            "active_flag":          True,
            "created_date":         now,
            "modified_date":        None,
        })
        sla_id += 1

    return pd.DataFrame(sla_rows)


# ── Delta write ───────────────────────────────────────────────────────────────

def write_table(
    df: pd.DataFrame,
    path: str,
    table_name: str,
    storage_options: dict,
    dry_run: bool,
) -> None:
    arrow_table = pa.Table.from_pandas(df, preserve_index=False)
    print(f"  Rows to write : {len(df)}")
    print(f"  Target path   : {path}")

    if dry_run:
        print(f"  [DRY RUN] Skipping write for {table_name}")
        return

    write_deltalake(
        table_or_uri=path,
        data=arrow_table,
        mode="overwrite",
        schema_mode="overwrite",
        storage_options=storage_options,
    )

    written = DeltaTable(path, storage_options=storage_options).to_pandas().shape[0]
    if written != len(df):
        print(f"  WARNING: wrote {len(df)} rows but found {written} on verify", file=sys.stderr)
        sys.exit(1)

    print(f"  Write OK — {written} rows verified in {table_name}")


# ── Main ──────────────────────────────────────────────────────────────────────

def main() -> None:
    args = parse_args()
    now  = datetime.now(timezone.utc)

    csv_path = Path(args.csv)
    if not csv_path.exists():
        print(f"ERROR: CSV not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    # ── Load CSV ──────────────────────────────────────────────────────────────
    print(f"Loading: {csv_path}")
    raw_df = pd.read_csv(csv_path, dtype=str)
    print(f"Loaded {len(raw_df)} rows")

    # ── Validate ──────────────────────────────────────────────────────────────
    print("Validating ingestion_config data...")
    errors = validate_ingestion_config(raw_df)
    if errors:
        print("VALIDATION FAILURES:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    print(f"Validation passed — {len(raw_df)} rows, no errors")

    # ── Coerce types ──────────────────────────────────────────────────────────
    ingestion_df  = coerce_ingestion_config(raw_df, now)
    watermark_df  = build_watermark_control(ingestion_df, now)
    sla_df        = build_sla_config(ingestion_df, now)

    print(f"  ingestion_config rows  : {len(ingestion_df)}")
    print(f"  watermark_control rows : {len(watermark_df)}")
    print(f"  sla_config rows        : {len(sla_df)}")

    # ── Authenticate ──────────────────────────────────────────────────────────
    if not args.dry_run:
        credential      = DefaultAzureCredential()
        storage_options = get_storage_options(credential)
    else:
        storage_options = {}

    # ── Write tables ──────────────────────────────────────────────────────────
    tables = [
        ("ingestion_config",  ingestion_df),
        ("watermark_control", watermark_df),
        ("sla_config",        sla_df),
    ]

    for table_name, df in tables:
        path = onelake_path(args.workspace_name, table_name)
        print(f"\n── {table_name} ──")
        write_table(df, path, table_name, storage_options, args.dry_run)

    print("\nSeed complete." if not args.dry_run else "\nDry run complete — no data written.")


if __name__ == "__main__":
    main()
