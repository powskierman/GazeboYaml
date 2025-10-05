#!/usr/bin/env python3
"""
Delete all Home Assistant sensors ending with _2
"""
import requests
import json

# Configuration
HA_URL = "http://192.168.0.11:8123"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json",
}

# Get all entities
print("Fetching all entities...")
response = requests.get(f"{HA_URL}/api/states", headers=headers)

if response.status_code != 200:
    print(f"Error fetching entities: {response.status_code}")
    print(response.text)
    exit(1)

entities = response.json()

# Filter sensors ending with _2
sensors_to_delete = [
    entity["entity_id"]
    for entity in entities
    if entity["entity_id"].endswith("_2")
]

if not sensors_to_delete:
    print("No sensors ending with _2 found.")
    exit(0)

print(f"\nFound {len(sensors_to_delete)} sensors ending with _2:")
for sensor in sensors_to_delete:
    print(f"  - {sensor}")

# Confirm deletion
confirm = input(f"\nDelete these {len(sensors_to_delete)} sensors? (yes/no): ")
if confirm.lower() != "yes":
    print("Cancelled.")
    exit(0)

# Delete entities using entity registry API
print("\nDeleting entities...")
deleted_count = 0
failed_count = 0

for entity_id in sensors_to_delete:
    # Use the entity registry delete endpoint
    response = requests.delete(
        f"{HA_URL}/api/config/entity_registry/{entity_id}",
        headers=headers
    )

    if response.status_code in [200, 204]:
        print(f"✓ Deleted: {entity_id}")
        deleted_count += 1
    else:
        print(f"✗ Failed to delete {entity_id}: {response.status_code} - {response.text}")
        failed_count += 1

print(f"\n{'='*60}")
print(f"Summary: {deleted_count} deleted, {failed_count} failed")
print(f"{'='*60}")