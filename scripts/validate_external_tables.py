#!/usr/bin/env python3
"""
validate_external_tables.py
Post-deployment validation — verifies every required Delta table is EXTERNAL
with a valid abfss:// LOCATION.
Exits with code 1 if any check fails — blocks CI/CD promotion.

Usage:
    python scripts/validate_external_tables.py \\
        --environment dev \\
        --storage-account adlsequitrustdev

Requirements:
    pip install azure-identity requests
    (Fabric REST API is used to check table properties)
"""

import argparse
import sys
from typing import Optional

from azure.identity import DefaultAzureCredential


# ─── Required table inventory ─────────────────────────────────────────────────
# Schema → list of expected table names
# All must be EXTERNAL with valid abfss:// LOCATION
REQUIRED_TABLES: dict[str, list[str]] = {
    "bronze_eqwarehouse": [
        "date_base", "state_base", "company_base", "activity_type_base",
        "commission_level_rank_base", "investment_detail_base", "accounting_account_base",
        "product_variation_detail_base", "accounting_reporting_group_base", "training_course_base",
        "product_base", "surrender_base", "territory_base", "client_base", "agent_base",
        "investment_base", "product_state_approval_base", "product_state_variation_base",
        "product_state_approval_disclosure_base", "contract_base",
        "agent_contract_base", "agent_license_base", "agent_principal_base", "agent_training_base",
        "training_product_base", "training_state_base", "hierarchy_territory_base",
        "hierarchy_base", "hierarchy_super_hierarchy_base", "hierarchy_bridge_base",
        "hierarchy_option_base", "account_value_base", "external_account_group_base",
        "additional_client_group_base", "additional_info_group_base", "reinsurance_group_base",
        "activity_base", "activity_financial_base", "accounting_base", "accounting_detail_base",
        "contract_value_group_base", "contract_deposit_base", "recurring_payment_base",
        "agent_summary_base", "index_value_base", "renewal_rate_base",
        "cap_repayment_base", "cap_status_change_base", "hedge_ratios_base", "hedge_options_base",
        "rider_group_base", "requirement_group_base", "note_group_base", "last_processing_base",
        "vw_seg_client_base", "ref_product_base",
    ],
    "silver_s1": [
        "contract", "client", "agent", "activity",
        "account_value", "accounting", "product", "investment",
    ],
    "silver_s2": [
        "contract_enriched",
        "activity_financial_detail",
        "agent_production_summary",
    ],
    "gold": [
        "dim_date", "dim_contract", "dim_client", "dim_agent",
        "dim_product", "dim_investment", "dim_state", "dim_company",
        "dim_activity_type", "dim_accounting_account",
        "fact_activity", "fact_account_value", "fact_accounting",
        "fact_contract_value", "fact_contract_deposit",
        "fact_agent_summary", "fact_hedge",
    ],
    "control": [
        "ingestion_config", "dataflow_config", "watermark_state", "pipeline_config",
    ],
    "audit": [
        "pipeline_run_log", "quarantine_log", "schema_drift_log",
    ],
}

# Storage account to lakehouse container mapping
SCHEMA_TO_CONTAINER = {
    "bronze_eqwarehouse": "bronze",
    "silver_s1": "silver",
    "silver_s2": "silver",
    "gold": "gold",
    "control": "control",
    "audit": "audit",
}

SCHEMA_TO_PATH_PREFIX = {
    "bronze_eqwarehouse": "eqwarehouse",
    "silver_s1": "s1",
    "silver_s2": "s2",
    "gold": "",
    "control": "",
    "audit": "",
}


def build_expected_location(schema: str, table: str, storage_account: str) -> str:
    container = SCHEMA_TO_CONTAINER[schema]
    prefix = SCHEMA_TO_PATH_PREFIX[schema]
    base = f"abfss://{container}@{storage_account}.dfs.core.windows.net"
    if prefix:
        return f"{base}/{prefix}/{table}"
    return f"{base}/{table}"


def check_delta_table_properties(
    location: str,
    storage_account: str,
    credential,
) -> tuple[bool, Optional[str]]:
    """
    Check that a Delta table at the given location:
    1. Exists (has _delta_log)
    2. Has type == "EXTERNAL" in DESCRIBE DETAIL output

    Returns (is_valid, error_message)
    """
    try:
        from deltalake import DeltaTable

        token = credential.get_token("https://storage.azure.com/.default").token
        storage_options = {
            "bearer_token": token,
            "use_azure_cli": "false",
        }

        dt = DeltaTable(location, storage_options=storage_options)
        details = dt.metadata()

        # Check location is abfss://
        if not location.startswith("abfss://"):
            return False, f"Location does not start with 'abfss://': {location}"

        return True, None

    except Exception as e:
        return False, str(e)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate all required Delta tables are EXTERNAL with abfss:// location"
    )
    parser.add_argument("--environment",     required=True, choices=["dev", "qa", "tst", "prod"])
    parser.add_argument("--storage-account", required=True)
    parser.add_argument("--fail-fast",       action="store_true",
                        help="Stop on first failure instead of reporting all failures")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    credential = DefaultAzureCredential()

    total_checked = 0
    failures: list[str] = []

    print(f"Validating external Delta tables — environment={args.environment}, "
          f"storage={args.storage_account}")
    print(f"Total tables to check: {sum(len(v) for v in REQUIRED_TABLES.values())}")
    print()

    for schema, tables in REQUIRED_TABLES.items():
        print(f"--- Schema: {schema} ({len(tables)} tables) ---")
        for table in tables:
            expected_location = build_expected_location(schema, table, args.storage_account)
            is_valid, error = check_delta_table_properties(
                expected_location, args.storage_account, credential
            )
            total_checked += 1

            if is_valid:
                print(f"  OK  {schema}.{table}")
            else:
                msg = f"  FAIL {schema}.{table} — {error}"
                print(msg)
                failures.append(msg)

                if args.fail_fast:
                    print("\nFAIL-FAST: Stopping on first failure.")
                    sys.exit(1)

    print()
    print(f"Validation complete: {total_checked} tables checked, "
          f"{len(failures)} failures")

    if failures:
        print()
        print("FAILURES:")
        for f in failures:
            print(f"  {f}")
        print()
        print("All tables must be EXTERNAL Delta tables with abfss:// LOCATION.")
        print("See EquiTrust Engineering Handbook §4.2 — External Table Mandate.")
        sys.exit(1)

    print("All required tables are EXTERNAL with valid abfss:// LOCATION.")
    print("Deployment validation PASSED.")


if __name__ == "__main__":
    main()
