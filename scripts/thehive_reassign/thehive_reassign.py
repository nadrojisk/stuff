#!/usr/bin/env python3
"""
Script to query TheHive cases and update assignee to unassigned@pnnl.gov
"""

import requests

from typing import List

# Configuration
THEHIVE_URL = "https://thehive.pnl.gov"
API_KEY = ""  # Replace with your actual API key
DRY_RUN = False  # Set to False to actually update cases
USER = ""
# Headers for API requests
HEADERS = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}


def get_case_ids() -> List[str]:
    """
    Query TheHive API to get all case IDs for specific user in New stage
    Returns a list of case IDs
    """
    url = f"{THEHIVE_URL}/api/v1/query?name=get-all-cases"

    # Query to get cases assigned to USER with stage=New, not tagged with "hold"
    query = {
        "query": [
            {"_name": "listCase"},
            {
                "_and": [
                    {
                        "_and": [
                            {"_field": "assignee", "_value": USER},
                            {"_field": "stage", "_value": "New"},
                            {},
                            {},
                        ]
                    }
                ],
                "_name": "filter",
            },
            {"_fields": [{"number": "desc"}], "_name": "sort"},
            {
                "_name": "page",
                "extraData": [
                    "alerts",
                    "owningOrganisation",
                    "observableStats",
                    "taskStats",
                    "procedureCount",
                    "isOwner",
                    "shareCount",
                    "permissions",
                    "actionRequired",
                    "contributors",
                    "status",
                ],
                "from": 0,
                "to": 300,
            },
        ]
    }

    try:
        response = requests.post(url, headers=HEADERS, json=query)
        response.raise_for_status()

        cases = response.json()
        case_ids = [case.get("_id") for case in cases if "_id" in case]

        print(f"Found {len(case_ids)} cases assigned to {USER} in New stage (not on hold)")
        return case_ids

    except requests.exceptions.RequestException as e:
        print(f"Error querying cases: {e}")
        if hasattr(e.response, "text"):
            print(f"Response: {e.response.text}")
        return []


def update_case_assignee(case_id: str) -> bool:
    """
    Update the assignee of a specific case
    """
    if DRY_RUN:
        print(f"[DRY RUN] Would update case {case_id}")
        return True

    url = f"{THEHIVE_URL}/api/v1/case/{case_id}"

    payload = {"assignee": "unassigned@pnnl.gov"}

    try:
        response = requests.patch(url, headers=HEADERS, json=payload)
        response.raise_for_status()

        print(f"✓ Updated case {case_id}")
        return True

    except requests.exceptions.RequestException as e:
        print(f"✗ Error updating case {case_id}: {e}")
        return False


def main():
    """
    Main function to orchestrate the case update process
    """
    print("Starting TheHive case assignee update...")
    if DRY_RUN:
        print("*** DRY RUN MODE - No changes will be made ***")
    print("-" * 50)

    # Get all case IDs
    case_ids = get_case_ids()

    if not case_ids:
        print("No cases found or error occurred")
        return

    # Update each case
    print(f"\nUpdating {len(case_ids)} cases...")
    print("-" * 50)

    success_count = 0
    for case_id in case_ids:
        if update_case_assignee(case_id):
            success_count += 1

    # Summary
    print("-" * 50)
    print("\nSummary:")
    print(f"Total cases: {len(case_ids)}")
    if DRY_RUN:
        print(f"Would update: {success_count} cases")
        print("\n*** Set DRY_RUN = False to actually update cases ***")
    else:
        print(f"Successfully updated: {success_count}")
        print(f"Failed: {len(case_ids) - success_count}")


if __name__ == "__main__":
    main()
