#!/bin/bash

# Home Assistant API Configuration
HA_URL="http://localhost:8123"
HA_TOKEN="YOUR_TOKEN_HERE"  # Replace with your actual token

echo "Deleting orphaned ESPHome gazebo entities with _2 suffixes..."

# Get all entities from the registry
echo "Fetching entity registry..."
entities=$(curl -s -H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json" "$HA_URL/api/config/entity_registry")

# Extract all gazebo entities ending with _2 that are unassigned (no device_id)
echo "Finding orphaned gazebo entities with _2 suffixes..."
orphaned_entities=$(echo "$entities" | jq -r '.[] | select(.entity_id | contains("gazebo") and contains("_2") and (.device_id == null or .device_id == "")) | .entity_id')

if [ -z "$orphaned_entities" ]; then
    echo "No orphaned gazebo entities with _2 suffixes found."
    exit 0
fi

echo "Found the following orphaned entities to delete:"
echo "$orphaned_entities"
echo ""

# Delete each orphaned entity
count=0
for entity in $orphaned_entities; do
    echo "Deleting orphaned entity: $entity"
    response=$(curl -s -X DELETE \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        "$HA_URL/api/config/entity_registry/$entity")
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully deleted: $entity"
        ((count++))
    else
        echo "✗ Failed to delete: $entity"
    fi
    
    # Small delay to avoid overwhelming the API
    sleep 0.1
done

echo ""
echo "Done! Deleted $count orphaned gazebo entities with _2 suffixes."
echo "Now upload the updated ESPHome firmware to create entities without _2 suffixes."
