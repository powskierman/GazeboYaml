#!/bin/bash

# Home Assistant API Configuration
HA_URL="http://localhost:8123"
HA_TOKEN="YOUR_TOKEN_HERE"  # Replace with your actual token

echo "Deleting all gazebo entities with _2 suffixes..."

# Get all entities from the registry
echo "Fetching entity registry..."
entities=$(curl -s -H "Authorization: Bearer $HA_TOKEN" -H "Content-Type: application/json" "$HA_URL/api/config/entity_registry")

# Extract all gazebo entities ending with _2
echo "Finding gazebo entities with _2 suffixes..."
gazebo_entities=$(echo "$entities" | jq -r '.[] | select(.entity_id | contains("gazebo") and endswith("_2")) | .entity_id')

if [ -z "$gazebo_entities" ]; then
    echo "No gazebo entities with _2 suffixes found."
    exit 0
fi

echo "Found the following entities to delete:"
echo "$gazebo_entities"
echo ""

# Delete each entity
count=0
for entity in $gazebo_entities; do
    echo "Deleting: $entity"
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
echo "Done! Deleted $count gazebo entities with _2 suffixes."
echo "Now restart Home Assistant to recreate the entities without _2 suffixes."
