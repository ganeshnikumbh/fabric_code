#!/usr/bin/env python3
"""
seed_control_tables.py
Loads ingestion_config_seed.csv into control.ingestion_config Delta table.
Validates data integrity before loading. Idempotent (mode="overwrite").

Usage:
    python scripts/seed_control_tables.py \\
        --environment dev \\
        --storage-account adlsequitrustdev \\
        --key-vault kv-equitrust-fabric-dev \\
        --csv fabric/config/ingestion_config_seed.csv

Requirements:
    pip install deltalake pyarrow azure-identity azure-keyvault-secrets pandas
"""

import argparse
import sys
import re
from pathlib import Path

import pandas as pd
import pyarrow as pa
from deltalake import DeltaTable, write_deltalake
from azure.identity import DefaultAzureCredential


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed control.ingestion_config from CSV")
    parser.add_argument("--environment",     required=True, choices=["dev", "qa", "tst", "prod"])
    parser.add_argument("--storage-account", required=True)
    parser.add_argument("--key-vault",       required=True)
    parser.add_argument("--csv",             required=True)
    return parser.parse_args()


def validate_dataframe(df: pd.DataFrame) -> list[str]:
    """Validate ingestion config data. Returns list of error messages."""
    errors = []

    # Required columns
    required_cols = [
        "table_id", "source_system", "source_schema", "source_table_name",
        "target_schema", "target_table_name", "load_type", "batch_group",
        "is_active", "quarantine_threshold_pct", "sensitivity", "domain",
    ]
    missing = [c for c in required_cols if c not in df.columns]
    if missing:
        errors.append(f"Missing required columns: {missing}")
        return errors  # Cannot continue validation without required cols

    # No duplicate table_ids
    dupes = df[df.duplicated("table_id", keep=False)]["table_id"].tolist()
    if dupes:
        errors.append(f"Duplicate table_ids: {sorted(set(dupes))}")

    # load_type values
    valid_load_types = {"FULL", "INCREMENTAL"}
    invalid_lt = df[~df["load_type"].isin(valid_load_types)]
    if not invalid_lt.empty:
        errors.append(
            f"Invalid load_type: {invalid_lt[['table_id', 'load_type']].to_dict('records')}"
        )

    # INCREMENTAL must have watermark_column
    inc_df = df[df["load_type"] == "INCREMENTAL"]
    no_wm = inc_df[inc_df["watermark_column"].isna() | (inc_df["watermark_column"] == "")]
    if not no_wm.empty:
        errors.append(
            f"INCREMENTAL tables missing watermark_column: {no_wm['table_id'].tolist()}"
        )

    # Quarantine threshold range [0.00, 100.00]
    df["quarantine_threshold_pct"] = pd.to_numeric(df["quarantine_threshold_pct"], errors="coerce")
    oor = df[(df["quarantine_threshold_pct"] < 0) | (df["quarantine_threshold_pct"] > 100)]
    if not oor.empty:
        errors.append(
            f"quarantine_threshold_pct out of range [0, 100]: {oor['table_id'].tolist()}"
        )

    # Sensitivity values
    valid_sensitivity = {"INTERNAL", "CONFIDENTIAL", "RESTRICTED"}
    invalid_sens = df[~df["sensitivity"].isin(valid_sensitivity)]
    if not invalid_sens.empty:
        errors.append(
            f"Invalid sensitivity values: {invalid_sens[['table_id', 'sensitivity']].to_dict('records')}"
        )

    # Domain values
    valid_domains = {"policy", "distribution", "finance", "investment", "risk", "client", "reference", "control"}
    invalid_dom = df[~df["domain"].isin(valid_domains)]
    if not invalid_dom.empty:
        errors.append(
            f"Invalid domain values: {invalid_dom[['table_id', 'domain']].to_dict('records')}"
        )

    # Batch group range [1, 5]
    df["batch_group"] = pd.to_numeric(df["batch_group"], errors="coerce")
    invalid_bg = df[(df["batch_group"] < 1) | (df["batch_group"] > 5)]
    if not invalid_bg.empty:
        errors.append(
            f"batch_group out of range [1, 5]: {invalid_bg['table_id'].tolist()}"
        )

    # Critical table 0% threshold check
    critical_table_patterns = [
        "client_base", "contract_base", "activity_base",
        "accounting_base", "account_value_base", "external_account_group_base",
        "vw_seg_client_base",
    ]
    for _, row in df.iterrows():
        is_critical = any(p in str(row.get("target_table_name", "")).lower() for p in critical_table_patterns)
        if is_critical and float(row["quarantine_threshold_pct"]) != 0.00:
            errors.append(
                f"Critical table {row['target_table_name']} (table_id={row['table_id']}) "
                f"must have quarantine_threshold_pct=0.00, got {row['quarantine_threshold_pct']}"
            )

    return errors


def coerce_types(df: pd.DataFrame) -> pd.DataFrame:
    """Coerce CSV types to correct Python/Arrow types for Delta write."""
    bool_cols = ["is_active", "is_temporal_table"]
    for col in bool_cols:
        if col in df.columns:
            df[col] = df[col].map(
                lambda x: True if str(x).lower() in ("true", "1", "yes") else False
                if str(x).lower() in ("false", "0", "no", "nan") else None
            )

    numeric_cols = ["table_id", "batch_group", "quarantine_threshold_pct"]
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")

    # String columns — replace NaN with None
    str_cols = [
        "watermark_column", "history_table_name", "dependency_table_ids",
        "notes",
    ]
    for col in str_cols:
        if col in df.columns:
            df[col] = df[col].where(df[col].notna(), None)
            df[col] = df[col].astype("string").where(df[col].notna(), None)

    return df


def main() -> None:
    args = parse_args()

    csv_path = Path(args.csv)
    if not csv_path.exists():
        print(f"ERROR: CSV file not found: {csv_path}", file=sys.stderr)
        sys.exit(1)

    print(f"Loading CSV: {csv_path}")
    df = pd.read_csv(csv_path, dtype=str)  # Read all as str first for validation
    print(f"Loaded {len(df)} rows from CSV")

    # Validate
    print("Validating ingestion config data...")
    errors = validate_dataframe(df)
    if errors:
        print("VALIDATION FAILURES:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)
    print(f"Validation passed — {len(df)} rows, no errors")

    # Coerce types
    df = coerce_types(df)

    # Build Delta table path
    control_path = (
        f"abfss://control@{args.storage_account}.dfs.core.windows.net/ingestion_config"
    )
    print(f"Target Delta path: {control_path}")

    # Authenticate via DefaultAzureCredential (OIDC in CI/CD; managed identity in Fabric)
    credential = DefaultAzureCredential()
    storage_options = {
        "bearer_token": credential.get_token("https://storage.azure.com/.default").token,
        "use_azure_cli": "false",
    }

    # Convert to PyArrow table
    arrow_table = pa.Table.from_pandas(df, preserve_index=False)

    print("Writing to control.ingestion_config (mode=overwrite)...")
    write_deltalake(
        table_or_uri=control_path,
        data=arrow_table,
        mode="overwrite",
        schema_mode="overwrite",
        storage_options=storage_options,
    )

    # Verify write
    dt = DeltaTable(control_path, storage_options=storage_options)
    written_count = dt.to_pandas().shape[0]
    print(f"Write complete — {written_count} rows in control.ingestion_config")

    if written_count != len(df):
        print(
            f"WARNING: Expected {len(df)} rows but found {written_count} — check Delta write",
            file=sys.stderr,
        )
        sys.exit(1)

    print("Seed complete.")


if __name__ == "__main__":
    main()
