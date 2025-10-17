#!/bin/bash
# Delete all Home Assistant sensors ending with _2

HA_URL="http://192.168.0.11:8123"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

echo "Fetching all entities..."
ENTITIES=$(curl -s -X GET "$HA_URL/api/states" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

# Extract entity IDs ending with _2
SENSORS_TO_DELETE=$(echo "$ENTITIES" | grep -o '"entity_id":"[^"]*_2"' | sed 's/"entity_id":"//g' | sed 's/"//g')

if [ -z "$SENSORS_TO_DELETE" ]; then
  echo "No sensors ending with _2 found."
  exit 0
fi

COUNT=$(echo "$SENSORS_TO_DELETE" | wc -l | tr -d ' ')
echo ""
echo "Found $COUNT sensors ending with _2:"
echo "$SENSORS_TO_DELETE"
echo ""
echo "Deleting sensors..."

DELETED=0
FAILED=0

while IFS= read -r entity_id; do
  RESPONSE=$(curl -s -w "\n%{http_code}" -X DELETE "$HA_URL/api/config/entity_registry/$entity_id" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json")

  HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
    echo "✓ Deleted: $entity_id"
    ((DELETED++))
  else
    echo "✗ Failed to delete $entity_id: HTTP $HTTP_CODE"
    ((FAILED++))
  fi
done <<< "$SENSORS_TO_DELETE"

echo ""
echo "============================================================"
echo "Summary: $DELETED deleted, $FAILED failed"
echo "============================================================"