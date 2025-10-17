#!/bin/bash
# Delete all Gazebo sensors ending with _3

HA_URL="http://192.168.0.11:8123"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

echo "Fetching all entities..."
ENTITIES=$(curl -s -X GET "$HA_URL/api/states" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

# Extract gazebo sensor entity IDs ending with _3
SENSORS_TO_DELETE=$(echo "$ENTITIES" | python3 -c "
import json, sys
data = json.load(sys.stdin)
sensors = [e['entity_id'] for e in data if e['entity_id'].startswith('sensor.gazebo_') and e['entity_id'].endswith('_3')]
for s in sensors:
    print(s)
")

if [ -z "$SENSORS_TO_DELETE" ]; then
  echo "No gazebo sensors ending with _3 found."
  exit 0
fi

COUNT=$(echo "$SENSORS_TO_DELETE" | wc -l | tr -d ' ')
echo ""
echo "Found $COUNT gazebo sensors ending with _3:"
echo "$SENSORS_TO_DELETE"
echo ""

echo "Deleting sensors using Home Assistant service calls..."

# Use the homeassistant.remove_entity service to delete entities
for entity_id in $SENSORS_TO_DELETE; do
  echo "Deleting: $entity_id"
  curl -s -X POST "$HA_URL/api/services/homeassistant/remove_entity" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"entity_id\": \"$entity_id\"}" > /dev/null
done

echo ""
echo "============================================================"
echo "Deleted $COUNT sensors ending with _3"
echo "============================================================"