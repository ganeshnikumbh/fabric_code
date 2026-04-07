#!/usr/bin/env python3
"""
verify_prior_deployment.py
GitHub Deployments API check — verifies a release tag was successfully
deployed to a prior environment before allowing promotion.

Called by deploy-prod.yml to verify TST deployment succeeded before
promoting to PROD. Also called by deploy-qa.yml to verify DEV succeeded.

Exits with code 1 if the required prior deployment is not found or failed.

Usage:
    python scripts/verify_prior_deployment.py \\
        --repo "equitrust/fabric-platform" \\
        --release-tag "v1.2.3" \\
        --required-environment tst \\
        --github-token "$GITHUB_TOKEN"

Requirements:
    pip install requests
"""

import argparse
import sys
from datetime import datetime, timezone
from typing import Optional

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify release tag was successfully deployed to required environment"
    )
    parser.add_argument("--repo",                 required=True,
                        help="GitHub repo in owner/repo format")
    parser.add_argument("--release-tag",          required=True,
                        help="Release tag to check (e.g. v1.2.3)")
    parser.add_argument("--required-environment", required=True,
                        help="Environment that must show success (e.g. tst)")
    parser.add_argument("--github-token",         required=True,
                        help="GitHub API token with deployments:read scope")
    parser.add_argument("--max-age-hours",        type=int, default=72,
                        help="Max age of successful deployment in hours (default: 72)")
    return parser.parse_args()


def get_deployments(
    repo: str,
    ref: str,
    environment: str,
    token: str,
) -> list[dict]:
    """Fetch deployments for a given ref and environment from GitHub API."""
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    url = f"https://api.github.com/repos/{repo}/deployments"
    params = {"ref": ref, "environment": environment, "per_page": 10}

    response = requests.get(url, headers=headers, params=params, timeout=30)

    if response.status_code == 404:
        print(f"Repository not found: {repo}", file=sys.stderr)
        sys.exit(1)
    elif response.status_code == 401:
        print("GitHub authentication failed — check GITHUB_TOKEN", file=sys.stderr)
        sys.exit(1)
    elif response.status_code != 200:
        print(f"GitHub API error: {response.status_code} — {response.text}", file=sys.stderr)
        sys.exit(1)

    return response.json()


def get_deployment_statuses(
    repo: str,
    deployment_id: int,
    token: str,
) -> list[dict]:
    """Fetch statuses for a specific deployment."""
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    url = f"https://api.github.com/repos/{repo}/deployments/{deployment_id}/statuses"

    response = requests.get(url, headers=headers, timeout=30)
    if response.status_code != 200:
        return []
    return response.json()


def find_successful_deployment(
    deployments: list[dict],
    repo: str,
    token: str,
    max_age_hours: int,
) -> Optional[dict]:
    """
    Find the most recent deployment with a 'success' status
    within the max_age_hours window.
    """
    now = datetime.now(timezone.utc)

    for deployment in deployments:
        created_at = datetime.fromisoformat(
            deployment["created_at"].replace("Z", "+00:00")
        )
        age_hours = (now - created_at).total_seconds() / 3600

        if age_hours > max_age_hours:
            continue

        statuses = get_deployment_statuses(repo, deployment["id"], token)
        for status in statuses:
            if status.get("state") == "success":
                return {
                    "deployment_id":    deployment["id"],
                    "created_at":       deployment["created_at"],
                    "age_hours":        round(age_hours, 1),
                    "status_created_at": status.get("created_at"),
                    "creator":          deployment.get("creator", {}).get("login", "unknown"),
                }

    return None


def main() -> None:
    args = parse_args()

    print(f"Verifying deployment of {args.release_tag} to {args.required_environment}...")
    print(f"Repository: {args.repo}")
    print(f"Maximum deployment age: {args.max_age_hours} hours")

    # Fetch deployments for this release tag + environment
    deployments = get_deployments(
        repo=args.repo,
        ref=args.release_tag,
        environment=args.required_environment,
        token=args.github_token,
    )

    if not deployments:
        print(
            f"\nFAILURE: No deployments found for tag '{args.release_tag}' "
            f"in environment '{args.required_environment}'.",
            file=sys.stderr,
        )
        print(
            f"The release tag must be successfully deployed to "
            f"'{args.required_environment}' before promoting.",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"Found {len(deployments)} deployment(s) — checking for success status...")

    successful = find_successful_deployment(
        deployments=deployments,
        repo=args.repo,
        token=args.github_token,
        max_age_hours=args.max_age_hours,
    )

    if not successful:
        print(
            f"\nFAILURE: No successful deployment found for tag '{args.release_tag}' "
            f"in environment '{args.required_environment}' "
            f"within the last {args.max_age_hours} hours.",
            file=sys.stderr,
        )
        print(
            f"Deployment statuses found: "
            f"{[d.get('state', 'unknown') for d in deployments[:3]]}",
            file=sys.stderr,
        )
        sys.exit(1)

    print(
        f"\nVERIFICATION PASSED:"
        f"\n  Release:     {args.release_tag}"
        f"\n  Environment: {args.required_environment}"
        f"\n  Deployment:  #{successful['deployment_id']}"
        f"\n  Deployed at: {successful['created_at']} ({successful['age_hours']}h ago)"
        f"\n  Deployed by: {successful['creator']}"
    )
    print(f"\nProceeding with promotion to next environment.")


if __name__ == "__main__":
    main()
