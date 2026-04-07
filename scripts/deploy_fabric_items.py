#!/usr/bin/env python3
"""
deploy_fabric_items.py
fabric-cicd wrapper for EquiTrust Fabric workspace deployments.

Validates source path before deployment:
  - No managed tables (CREATE TABLE without LOCATION)
  - No hardcoded environment literals (__ENVIRONMENT__ must be present as token, not resolved value)
  - All find_replace tokens present in deployment.yml

Loads environment-specific token replacements from environment variables
(populated from Key Vault by CI/CD pipeline).

Usage:
    python scripts/deploy_fabric_items.py \\
        --environment dev \\
        --workspace-id <GUID> \\
        --token <FABRIC_TOKEN> \\
        --source-path fabric/workspaces/eq-hub \\
        --deployment-config deployment.yml

Requirements:
    pip install fabric-cicd==0.2.0 azure-identity pyyaml
"""

import argparse
import os
import re
import sys
from pathlib import Path

import yaml


# Hardcoded environment literals that must NOT appear in source files
FORBIDDEN_ENV_LITERALS = {"dev", "qa", "tst", "prod"}

# Tokens that must be present in deployment.yml find_replace section
REQUIRED_TOKENS = {
    "__ENVIRONMENT__",
    "__STORAGE_ACCOUNT__",
    "__HUB_WORKSPACE_ID__",
    "__KEY_VAULT_NAME__",
    "__SQL_SERVER_CONNECTION_ID__",
    "__LOG_ANALYTICS_WORKSPACE_ID__",
    "__TEAMS_WEBHOOK_URL__",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Deploy Fabric workspace items via fabric-cicd")
    parser.add_argument("--environment",       required=True, choices=["dev", "qa", "tst", "prod"])
    parser.add_argument("--workspace-id",      required=True)
    parser.add_argument("--token",             required=True, help="Fabric API bearer token")
    parser.add_argument("--source-path",       required=True)
    parser.add_argument("--deployment-config", required=True)
    return parser.parse_args()


def load_deployment_config(config_path: str) -> dict:
    with open(config_path, "r") as f:
        return yaml.safe_load(f)


def validate_no_managed_tables(source_path: Path) -> list[str]:
    """Scan source files for CREATE TABLE without LOCATION clause."""
    errors = []
    pattern = re.compile(
        r'CREATE\s+(?:OR\s+REPLACE\s+)?(?!EXTERNAL)TABLE\s+\S+',
        re.IGNORECASE
    )
    location_pattern = re.compile(r'LOCATION\s+[\'"]abfss://', re.IGNORECASE)

    for fpath in source_path.rglob("*.py"):
        content = fpath.read_text(encoding="utf-8")
        for match in pattern.finditer(content):
            start = max(0, match.start() - 50)
            end = min(len(content), match.end() + 500)
            block = content[start:end]
            if not location_pattern.search(block):
                line = content[:match.start()].count("\n") + 1
                errors.append(f"{fpath}:{line} — Possible managed table: {match.group().strip()}")

    return errors


def validate_no_hardcoded_env_literals(source_path: Path, environment: str) -> list[str]:
    """
    Check source files do not contain hardcoded environment-specific strings.
    Tokens like __ENVIRONMENT__ are allowed; resolved values like 'dev' in paths are not.
    """
    errors = []
    # Pattern: environment literal appears in a storage path context
    for literal in FORBIDDEN_ENV_LITERALS:
        if literal == environment:
            # Flag hardcoded occurrences of the current environment name in abfss paths
            path_pattern = re.compile(
                rf'abfss://[^@]*@[^.]*{re.escape(literal)}[^.]*\.dfs',
                re.IGNORECASE
            )
            for fpath in source_path.rglob("*.py"):
                content = fpath.read_text(encoding="utf-8")
                for match in path_pattern.finditer(content):
                    line = content[:match.start()].count("\n") + 1
                    errors.append(
                        f"{fpath}:{line} — Hardcoded environment '{literal}' in storage path. "
                        f"Use __STORAGE_ACCOUNT__ token instead."
                    )
    return errors


def validate_deployment_config(config: dict) -> list[str]:
    """Verify all required tokens are present in deployment.yml find_replace section."""
    errors = []
    find_replace = config.get("find_replace", [])
    declared_tokens = {item["find"] for item in find_replace if "find" in item}

    missing = REQUIRED_TOKENS - declared_tokens
    if missing:
        errors.append(f"deployment.yml is missing required find_replace tokens: {missing}")

    return errors


def build_token_replacements(config: dict, environment: str) -> dict[str, str]:
    """Build replacement map from environment variables."""
    # Environment variable names (set by CI/CD from Key Vault)
    env_var_map = {
        "__ENVIRONMENT__":              environment,
        "__STORAGE_ACCOUNT__":          os.environ.get("STORAGE_ACCOUNT", ""),
        "__HUB_WORKSPACE_ID__":         os.environ.get("HUB_WORKSPACE_ID", ""),
        "__KEY_VAULT_NAME__":            os.environ.get("KEY_VAULT_NAME", ""),
        "__SQL_SERVER_CONNECTION_ID__":  os.environ.get("SQL_SERVER_CONNECTION_ID", ""),
        "__LOG_ANALYTICS_WORKSPACE_ID__": os.environ.get("LOG_ANALYTICS_WORKSPACE_ID", ""),
        "__TEAMS_WEBHOOK_URL__":         os.environ.get("TEAMS_WEBHOOK_URL", ""),
        "__ONPREM_GATEWAY_ID__":         os.environ.get("ONPREM_GATEWAY_ID", ""),
        "__SQL_SERVER_HOST__":           os.environ.get("SQL_SERVER_HOST", ""),
        "__SQL_SERVER_DATABASE__":       os.environ.get("SQL_SERVER_DATABASE", ""),
    }

    # Validate no empty required values
    errors = []
    for token, value in env_var_map.items():
        if not value and token in REQUIRED_TOKENS:
            errors.append(f"Environment variable for token {token} is not set")

    if errors:
        print("TOKEN RESOLUTION ERRORS:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)

    return env_var_map


def main() -> None:
    args = parse_args()

    source_path = Path(args.source_path)
    if not source_path.exists():
        print(f"ERROR: Source path not found: {source_path}", file=sys.stderr)
        sys.exit(1)

    # Load deployment config
    config = load_deployment_config(args.deployment_config)
    print(f"Loaded deployment config: {args.deployment_config}")

    all_errors: list[str] = []

    # Pre-deployment validations
    print("Running pre-deployment validations...")

    managed_table_errors = validate_no_managed_tables(source_path)
    if managed_table_errors:
        print(f"  FAIL: {len(managed_table_errors)} managed table(s) detected")
        all_errors.extend(managed_table_errors)
    else:
        print("  OK: No managed tables detected")

    hardcoded_env_errors = validate_no_hardcoded_env_literals(source_path, args.environment)
    if hardcoded_env_errors:
        print(f"  FAIL: {len(hardcoded_env_errors)} hardcoded environment literal(s) detected")
        all_errors.extend(hardcoded_env_errors)
    else:
        print("  OK: No hardcoded environment literals in storage paths")

    config_errors = validate_deployment_config(config)
    if config_errors:
        print(f"  FAIL: deployment.yml validation errors")
        all_errors.extend(config_errors)
    else:
        print("  OK: deployment.yml tokens validated")

    if all_errors:
        print("\nPRE-DEPLOYMENT VALIDATION FAILED:")
        for e in all_errors:
            print(f"  {e}")
        sys.exit(1)

    print("Pre-deployment validation PASSED\n")

    # Build token replacements
    replacements = build_token_replacements(config, args.environment)
    print(f"Resolved {len(replacements)} token replacements for environment={args.environment}")

    # Execute fabric-cicd deployment
    try:
        from fabric_cicd import FabricWorkspace, publish_all_items

        item_types = config.get("item_type_in_scope", [
            "Lakehouse", "DataPipeline", "Dataflow", "Notebook", "SemanticModel"
        ])

        print(f"Deploying to workspace: {args.workspace_id}")
        print(f"Item types in scope: {item_types}")

        workspace = FabricWorkspace(
            workspace_id=args.workspace_id,
            repository_directory=str(source_path),
            item_type_in_scope=item_types,
            token=args.token,
            parameter_file_name="deployment.yml",
        )

        publish_all_items(workspace)

        print(f"\nDeployment COMPLETE — environment={args.environment}")

    except ImportError:
        print("ERROR: fabric-cicd not installed. Run: pip install fabric-cicd==0.2.0", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: Deployment failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
