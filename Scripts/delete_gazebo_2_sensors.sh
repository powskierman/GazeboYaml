#!/bin/bash
# Delete all Gazebo sensors ending with _2

HA_URL="http://192.168.0.11:8123"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

echo "Fetching all entities..."
ENTITIES=$(curl -s -X GET "$HA_URL/api/states" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

# Extract gazebo sensor entity IDs ending with _2
SENSORS_TO_DELETE=$(echo "$ENTITIES" | python3 -c "
import json, sys
data = json.load(sys.stdin)
sensors = [e['entity_id'] for e in data if e['entity_id'].startswith('sensor.gazebo_') and e['entity_id'].endswith('_2')]
for s in sensors:
    print(s)
")

if [ -z "$SENSORS_TO_DELETE" ]; then
  echo "No gazebo sensors ending with _2 found."
  exit 0
fi

COUNT=$(echo "$SENSORS_TO_DELETE" | wc -l | tr -d ' ')
echo ""
echo "Found $COUNT gazebo sensors ending with _2:"
echo "$SENSORS_TO_DELETE"
echo ""
echo "These sensors will be removed from Home Assistant."
echo "The REST sensors with unique_id will then be able to register properly."
echo ""
read -p "Delete these $COUNT sensors? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

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
echo "Deleted $COUNT sensors"
echo "============================================================"
echo ""
echo "Next steps:"
echo "1. Restart Home Assistant"
echo "2. The REST sensors with unique_id should now load properly"
echo "3. Verify sensors work in Developer Tools -> States"
echo "============================================================"