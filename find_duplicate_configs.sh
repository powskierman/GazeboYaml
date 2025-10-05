#!/bin/bash
# Find duplicate gazebo sensor definitions on Home Assistant RPi

HA_URL="http://192.168.0.11:8123"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI1YWFhMjg3YWFmNWI0ZTMzYTc1ZmI3OGJlMGI4YjE2MCIsImlhdCI6MTc1OTI0NjIyOCwiZXhwIjoyMDc0NjA2MjI4fQ.irMS7jMwHnps_Ce2S5PclZGzREmgXjyeWrfzYUjGn0g"

echo "Checking configuration.yaml for included template files..."
CONFIG=$(curl -s -X GET "$HA_URL/api/config/core/check_config" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json")

echo ""
echo "Response:"
echo "$CONFIG" | python3 -m json.tool

echo ""
echo "=================================="
echo "SOLUTION TO DUPLICATE ENTITIES:"
echo "=================================="
echo ""
echo "The duplicate entities (_2 suffix) exist because you likely have"
echo "OLD template sensor definitions in another file that don't have"
echo "unique_id fields."
echo ""
echo "To fix this:"
echo "1. Upload complete_gazebo_sensors.yaml to /config/ on your RPi"
echo "2. Check your configuration.yaml - it says:"
echo "   template: !include complete_gazebo_sensors.yaml"
echo ""
echo "3. Look for OTHER files that might define gazebo sensors:"
echo "   - homeassistant_weather_sensors.yaml"
echo "   - final_gazebo_sensors.yaml"
echo "   - working_gazebo_sensors.yaml"
echo ""
echo "4. Either DELETE these old files OR rename them (add .bak extension)"
echo ""
echo "5. Restart Home Assistant"
echo ""
echo "6. Go to Settings > Devices & Services > Entities"
echo "   Filter for 'gazebo' and DELETE all entities ending in _2"
echo "   (they should now be deletable after removing the duplicate definitions)"
echo ""