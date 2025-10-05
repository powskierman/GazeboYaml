#!/bin/bash

# Home Assistant API Configuration
HA_URL="http://192.168.0.11:8123"
HA_TOKEN="YOUR_TOKEN_HERE"  # Replace with your actual token

# List of entities to delete (all entities ending with _2)
ENTITIES=(
    "sensor.gazebo_thermostat_openmeteo_feels_like_2"
    "sensor.gazebo_thermostat_openmeteo_humidity_2"
    "sensor.gazebo_thermostat_hour_0_feels_like_2"
    "sensor.gazebo_thermostat_hour_1_feels_like_2"
    "sensor.gazebo_thermostat_hour_2_feels_like_2"
    "sensor.gazebo_thermostat_hour_3_feels_like_2"
    "sensor.gazebo_thermostat_hour_4_feels_like_2"
    "sensor.gazebo_thermostat_hour_5_feels_like_2"
    "sensor.gazebo_thermostat_hour_6_feels_like_2"
    "sensor.gazebo_thermostat_hour_0_precipitation_2"
    "sensor.gazebo_thermostat_hour_1_precipitation_2"
    "sensor.gazebo_thermostat_hour_2_precipitation_2"
    "sensor.gazebo_thermostat_hour_3_precipitation_2"
    "sensor.gazebo_thermostat_hour_4_precipitation_2"
    "sensor.gazebo_thermostat_hour_5_precipitation_2"
    "sensor.gazebo_thermostat_hour_6_precipitation_2"
    "sensor.gazebo_thermostat_hour_0_temperature_2"
    "sensor.gazebo_thermostat_hour_1_temperature_2"
    "sensor.gazebo_thermostat_hour_2_temperature_2"
    "sensor.gazebo_thermostat_hour_3_temperature_2"
    "sensor.gazebo_thermostat_hour_4_temperature_2"
    "sensor.gazebo_thermostat_hour_5_temperature_2"
    "sensor.gazebo_thermostat_hour_6_temperature_2"
    "sensor.gazebo_thermostat_hour_0_humidity_2"
    "sensor.gazebo_thermostat_hour_1_humidity_2"
    "sensor.gazebo_thermostat_hour_2_humidity_2"
    "sensor.gazebo_thermostat_hour_3_humidity_2"
    "sensor.gazebo_thermostat_hour_4_humidity_2"
    "sensor.gazebo_thermostat_hour_5_humidity_2"
    "sensor.gazebo_thermostat_hour_6_humidity_2"
    "sensor.gazebo_thermostat_gazebo_thermostat_ip_2"
    "binary_sensor.gazebo_thermostat_test_time_button_2"
    "binary_sensor.gazebo_thermostat_page_0_next_2"
    "binary_sensor.gazebo_thermostat_page_1_back_2"
    "binary_sensor.gazebo_thermostat_page_1_next_2"
    "binary_sensor.gazebo_thermostat_page_2_back_2"
    "binary_sensor.gazebo_thermostat_page_2_next_2"
    "sensor.gazebo_current_temperature_2"
    "sensor.gazebo_current_apparent_temperature_2"
    "sensor.gazebo_current_humidity_2"
    "sensor.gazebo_hour_0_feels_like_2"
    "sensor.gazebo_hour_1_feels_like_2"
    "sensor.gazebo_hour_3_feels_like_2"
    "sensor.gazebo_hour_4_feels_like_2"
    "sensor.gazebo_hour_5_feels_like_2"
    "sensor.gazebo_hour_6_feels_like_2"
    "sensor.gazebo_hour_0_precipitation_2"
    "sensor.gazebo_hour_1_precipitation_2"
    "sensor.gazebo_hour_3_precipitation_2"
    "sensor.gazebo_hour_4_precipitation_2"
    "sensor.gazebo_hour_5_precipitation_2"
    "sensor.gazebo_hour_6_precipitation_2"
    "sensor.gazebo_hour_0_humidity_2"
    "sensor.gazebo_hour_1_humidity_2"
    "sensor.gazebo_hour_3_humidity_2"
    "sensor.gazebo_hour_4_humidity_2"
    "sensor.gazebo_hour_5_humidity_2"
    "sensor.gazebo_hour_6_humidity_2"
    "sensor.gazebo_hour_2_temperature_2"
)

echo "Deleting gazebo entities with _2 suffixes..."
echo "Total entities to delete: ${#ENTITIES[@]}"

for entity in "${ENTITIES[@]}"; do
    echo "Deleting: $entity"
    response=$(curl -s -X DELETE \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        "$HA_URL/api/config/entity_registry/$entity")
    
    if [ $? -eq 0 ]; then
        echo "✓ Successfully deleted: $entity"
    else
        echo "✗ Failed to delete: $entity"
    fi
    
    # Small delay to avoid overwhelming the API
    sleep 0.1
done

echo "Done! All gazebo entities with _2 suffixes have been deleted."
echo "Now restart Home Assistant to recreate the entities without _2 suffixes."
