#!/bin/bash
# Delete ALL gazebo sensors with _2 or _3 suffix

HA_URL="http://192.168.0.11:8123"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

echo "Fetching all entities..."
ENTITIES=$(curl -s -X GET "$HA_URL/api/states" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

# Extract gazebo sensor entity IDs ending with _2 or _3
SENSORS_TO_DELETE=$(echo "$ENTITIES" | python3 -c "
import json, sys
data = json.load(sys.stdin)
sensors = [e['entity_id'] for e in data if e['entity_id'].startswith('sensor.gazebo_') and (e['entity_id'].endswith('_2') or e['entity_id'].endswith('_3'))]
for s in sensors:
    print(s)
")

if [ -z "$SENSORS_TO_DELETE" ]; then
  echo "No duplicate gazebo sensors found."
  exit 0
fi

COUNT=$(echo "$SENSORS_TO_DELETE" | wc -l | tr -d ' ')
echo ""
echo "Found $COUNT duplicate gazebo sensors:"
echo "$SENSORS_TO_DELETE"
echo ""
echo "Deleting ALL duplicate sensors..."

# Delete each sensor
for entity_id in $SENSORS_TO_DELETE; do
  echo "Deleting: $entity_id"
  curl -s -X POST "$HA_URL/api/services/homeassistant/remove_entity" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"entity_id\": \"$entity_id\"}" > /dev/null
done

echo ""
echo "============================================================"
echo "Deleted $COUNT duplicate sensors"
echo "============================================================"
echo ""
echo "IMPORTANT: The duplicates keep coming back because there is"
echo "a configuration source still creating them. Check:"
echo ""
echo "1. /config/complete_gazebo_sensors.yaml - does it exist?"
echo "2. Search configuration.yaml for 'template:' keyword"
echo "3. Check for any files in /config/ with 'weather' or 'gazebo' in name"
echo "============================================================"