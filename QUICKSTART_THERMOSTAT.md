# Thermostat Quick Start Guide

## Prerequisites

✅ ESP32 development board  
✅ DS18B20 temperature sensor  
✅ Relay module (for propane stove)  
✅ Nextion display (with Page 3 configured)  
✅ Home Assistant installed and running  
✅ ESPHome add-on installed in Home Assistant

## 5-Step Quick Setup

### Step 1: Find Your DS18B20 Address

1. Connect the DS18B20 to GPIO13 with a 4.7kΩ pull-up resistor
2. Upload the configuration as-is (with the placeholder address)
3. Check the ESPHome logs, look for:
   ```
   Found dallas device at address 0x123456789ABC
   ```
4. Copy this address

### Step 2: Update Configuration

Edit `gazebo_page3_thermostat.yaml`:

```yaml
# Line ~58 - Replace the address
sensor:
  - platform: dallas
    id: ds18b20_temp
    name: "Gazebo Actual Temperature"
    address: 0x123456789ABC  # ← PASTE YOUR ADDRESS HERE
```

### Step 3: Verify Nextion Page 3

Your Nextion display must have **Page 3** with these components:

| Component | Type | Purpose |
|-----------|------|---------|
| `n0` | Number | Desired temperature display |
| `n1` | Number | Actual temperature display |
| `Slider0` | Slider | Temperature adjustment |

**Component ID Reference:**
- Check your Nextion editor for the exact component IDs
- Update `component_id` in the binary sensor if needed (currently set to 2)

### Step 4: Configure Secrets

Edit `secrets.yaml` to ensure these are set:

```yaml
wifi_ssid: "YourWiFiName"
wifi_password: "YourWiFiPassword"
api_encryption_key: "your_api_key_here"
ap_password: "FallbackAPPassword"
```

### Step 5: Upload and Test

1. **Upload** the configuration to your ESP32
2. **Wait** for it to boot and connect to WiFi
3. **Check** Home Assistant - you should see:
   - `climate.gazebo_thermostat`
   - Multiple sensors and switches
4. **Test** basic functionality:
   - Change desired temperature in HA
   - Verify Nextion updates
   - Move Nextion slider
   - Verify HA updates

## Initial Configuration via Home Assistant

Once connected, set your preferences:

### Basic Settings

1. **Go to:** Settings → Devices & Services → ESPHome → Your Device

2. **Set Desired Temperature:**
   - Entity: `number.desired_temperature`
   - Set to your comfort level (e.g., 21°C)

3. **Set Hysteresis:**
   - Entity: `number.hysteresis`
   - Recommended: 1.0°C to prevent short-cycling

4. **Calibrate Temperature (if needed):**
   - Compare reading with a trusted thermometer
   - Entity: `number.temperature_correction`
   - If sensor reads 20°C but actual is 21°C, set to +1.0

### Schedule Configuration

Set your heating schedule:

1. **Schedule Start Time:**
   - Entity: `number.schedule_start_time`
   - Convert your time: `Hours × 3600 + Minutes × 60`
   - Example: 8:00 AM = `28800` seconds

2. **Schedule End Time:**
   - Entity: `number.schedule_end_time`
   - Example: 10:00 PM = `79200` seconds

### Time Conversion Helper

| Time | Calculation | Seconds |
|------|-------------|---------|
| 06:00 | 6×3600 | 21600 |
| 07:00 | 7×3600 | 25200 |
| 08:00 | 8×3600 | 28800 |
| 09:00 | 9×3600 | 32400 |
| 18:00 | 18×3600 | 64800 |
| 20:00 | 20×3600 | 72000 |
| 22:00 | 22×3600 | 79200 |
| 23:00 | 23×3600 | 82800 |

## Testing Checklist

### Basic Function Test

- [ ] Temperature sensor shows reasonable value
- [ ] Nextion displays actual temperature
- [ ] Changing desired temp in HA updates Nextion
- [ ] Moving Nextion slider updates HA
- [ ] Timer shows "Active" during schedule window
- [ ] Timer shows "Inactive" outside schedule

### Manual Control Test

- [ ] Turn on Manual Run switch → Relay activates
- [ ] Turn off Manual Run switch → Returns to auto
- [ ] Turn on Manual Stop switch → Relay deactivates
- [ ] Manual Stop overrides Manual Run

### Automatic Operation Test

- [ ] Set desired temp 2°C above actual
- [ ] Verify stove activates (if Home + Timer active)
- [ ] Verify stove deactivates when temp reaches target + hysteresis
- [ ] Set to Away mode → Stove deactivates immediately

### Safety Test

- [ ] Manual Run timeout works (if configured)
- [ ] Minimum cycling times prevent rapid on/off
- [ ] System continues working when HA is offline

## Default Values Reference

```yaml
Desired Temperature:     21.0°C
Hysteresis:              1.0°C
Temperature Correction:  0.0°C
Schedule Start:          08:00 (28800s)
Schedule End:            22:00 (79200s)
Manual Run Timeout:      120 minutes
Temperature Averaging:   ENABLED
```

## Troubleshooting Quick Fixes

### "No temperature reading"

```bash
# Check logs for:
Found dallas device at address...

# If not found, check:
- Wiring (GPIO13, VCC, GND)
- 4.7kΩ pull-up resistor
- Sensor is not damaged
```

### "Stove won't turn on"

```yaml
# Check in this order:
1. Manual Stop switch = OFF
2. Home Status = "Home"  
3. Timer Active = "Active"
4. Temperature < Desired
```

### "Nextion not updating"

```bash
# Verify:
- UART connections (TX ↔ RX crossed)
- Baud rate = 9600
- Page 3 exists with n0, n1 components
- Check ESPHome logs for Nextion errors
```

### "Settings don't persist"

```yaml
# Verify restore_value: yes in:
- Global variables (lines 18-49)
- Number inputs (lines 178, 197, 218, 256, 270)
```

## Home Assistant Dashboard Card

Add this to your dashboard for quick access:

```yaml
type: thermostat
entity: climate.gazebo_thermostat
features:
  - type: climate-hvac-modes
    hvac_modes:
      - heat
      - 'off'

type: entities
entities:
  - entity: sensor.gazebo_actual_temperature
    name: Current Temperature
  - entity: number.desired_temperature
    name: Target Temperature
  - entity: number.hysteresis
    name: Hysteresis
  - entity: binary_sensor.timer_active
    name: Schedule Active
  - entity: binary_sensor.stove_active
    name: Stove Status
  - entity: switch.manual_run
    name: Manual Run
  - entity: switch.manual_stop
    name: Manual Stop
  - entity: binary_sensor.home_status
    name: Home/Away
  - entity: text_sensor.thermostat_status
    name: Status
title: Gazebo Thermostat Control
```

## Next Steps

1. ✅ Complete quick setup steps
2. ✅ Test all functionality
3. 📖 Read full documentation: `README_THERMOSTAT.md`
4. 🔧 Fine-tune settings for your comfort
5. 🏠 Create Home Assistant automations
6. 📊 Monitor system health regularly

## Getting Help

**Check logs:**
```
Settings → System → Logs
Filter by: esphome
Look for: thermostat, temperature, stove
```

**Enable debug logging:**
Edit `gazebo_base.yaml`:
```yaml
logger:
  level: DEBUG  # Change from INFO to DEBUG
```

**Common log messages:**
```
INFO  - STOVE ACTIVATED - Heat mode engaged
INFO  - Temperature reached 22.0°C - turning OFF
WARN  - Bad temperature read detected
ERROR - SENSOR FAILURE: 3 consecutive bad reads!
```

## Safety Reminders

⚠️ **Before leaving system unattended:**

- [ ] Verify all sensors working correctly
- [ ] Test manual override modes
- [ ] Confirm propane system is safe
- [ ] Install CO detectors
- [ ] Know how to manually control stove
- [ ] Have backup heating available

---

**Need more details?** See `README_THERMOSTAT.md`  
**Verify requirements?** See `REQUIREMENTS_TRACEABILITY.md`

**Version:** 1.0  
**Last Updated:** October 2025

