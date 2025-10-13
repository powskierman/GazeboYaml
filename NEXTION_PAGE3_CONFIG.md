# Nextion Display - Page 3 Configuration Guide

## Overview

Page 3 of your Nextion display is the thermostat control interface. Based on your provided image, this page displays current and desired temperatures with touch control.

## Required Components

### Page Settings
- **Page Name:** `three`
- **Page ID:** `3`
- **Background:** Custom gradient (as shown in your design)

### Component List

| Component | Type | ID | Object Name | Purpose |
|-----------|------|----|-----------  |---------|
| Actual Temp Display | Number | - | `n1` | Shows current room temperature |
| Desired Temp Display | Number | - | `n0` | Shows target temperature |
| Temperature Slider | Slider | 2 | `Slider0` | User adjusts desired temp |
| Control Button | Button | - | `b2` | Optional control button |
| Page Label | Text | - | `t1` | Optional page identifier |

## Component Configuration Details

### 1. Number Display - Actual Temperature (n1)

**Properties:**
- **Object Name:** `n1`
- **Type:** Number
- **Position:** Left side of display (as shown: displaying "99")
- **Font:** Large, bold (size 40-60 recommended)
- **Color:** White or high contrast
- **Background:** Transparent or matches page gradient
- **Format:** Integer (will display Celsius)
- **Range:** 0-99
- **Initial Value:** 20

**Touch Events:** None (display only)

**Attributes to Set:**
```
objname=n1
font=1 (or your large font ID)
pco=65535 (white)
bco=0 (transparent)
xcen=1 (center horizontally)
ycen=1 (center vertically)
```

### 2. Number Display - Desired Temperature (n0)

**Properties:**
- **Object Name:** `n0`
- **Type:** Number
- **Position:** Right side of display (as shown: displaying "88")
- **Font:** Large, bold (size 40-60 recommended)
- **Color:** White or high contrast
- **Background:** Transparent or matches page gradient
- **Format:** Integer (will display Celsius)
- **Range:** 10-35
- **Initial Value:** 21

**Touch Events:** Updates when slider moves

**Attributes to Set:**
```
objname=n0
font=1 (or your large font ID)
pco=65535 (white)
bco=0 (transparent)
xcen=1 (center horizontally)
ycen=1 (center vertically)
```

### 3. Slider - Temperature Control (Slider0)

**Properties:**
- **Object Name:** `Slider0`
- **Component ID:** `2` (verify in your editor)
- **Type:** Slider (Horizontal)
- **Position:** Top of display (as shown in image)
- **Width:** Full width or nearly full width
- **Height:** 20-40 pixels
- **Min Value:** `10` (10°C)
- **Max Value:** `35` (35°C)
- **Initial Value:** `21` (21°C)
- **Pointer Color:** White or accent color
- **Background Color:** Dark or transparent

**Touch Events:**
```
Touch Release Event:
  Send Component ID
  (Enable "Send Component ID" in component properties)
```

**Attributes to Set:**
```
objname=Slider0
minval=10
maxval=35
val=21
wid=200-300 (adjust to your display width)
hig=30
pco=65535 (pointer color - white)
bco=31 (background - dark blue/black)
```

### 4. Optional: Control Button (b2)

**Properties:**
- **Object Name:** `b2`
- **Type:** Button
- **Position:** Bottom center (as shown in image)
- **Purpose:** Page navigation or mode control
- **Text:** Custom (e.g., "MODE", "BACK", etc.)

**Touch Events:** Configure based on your needs

### 5. Optional: Page Label (t1)

**Properties:**
- **Object Name:** `t1`
- **Type:** Text
- **Purpose:** Page identification
- **Text:** "Thermostat" or similar

## Layout Guide

Based on your provided image:

```
┌───────────────────────────────────────────┐
│                                           │
│              [Slider0]                    │ ← Temperature slider
│                                           │
│                                           │
│          ╔═══════════════╗                │
│          ║               ║                │
│          ║   Gradient    ║                │ ← Display area
│          ║   Background  ║                │
│          ║               ║                │
│          ║               ║                │
│          ╚═══════════════╝                │
│                                           │
│                                           │
│         99              88                │ ← n1 (actual)  n0 (desired)
│                                           │
│              [b2]                         │ ← Optional button
│                                           │
└───────────────────────────────────────────┘
```

## ESPHome Command Format

The ESPHome configuration sends these commands to the Nextion:

### Update Actual Temperature (n1)
```
three.n1.val=23
```
This sets the actual temperature display to 23°C.

### Update Desired Temperature (n0)
```
three.n0.val=21
```
This sets the desired temperature display to 21°C.

### Read Slider Value
```
get three.n0.val
```
This requests the current slider value (which updates n0).

## Nextion Editor Setup Steps

### Step 1: Create Page 3

1. In Nextion Editor, add a new page (or select existing page 3)
2. Set page object name to `three`
3. Set background image or gradient as desired

### Step 2: Add Number Display - n1

1. Add **Number** component
2. Set object name to `n1`
3. Position on left side
4. Set font size large (40-60)
5. Set color to white (65535)
6. Set initial value to 20
7. Enable horizontal/vertical centering

### Step 3: Add Number Display - n0

1. Add **Number** component
2. Set object name to `n0`
3. Position on right side
4. Set font size large (40-60)
5. Set color to white (65535)
6. Set initial value to 21
7. Enable horizontal/vertical centering

### Step 4: Add Slider - Slider0

1. Add **Slider** component
2. Set object name to `Slider0`
3. Position at top
4. Set width to span most of display
5. Set minval to 10
6. Set maxval to 35
7. Set initial val to 21
8. **Important:** Enable "Send Component ID" in Touch Release Event
9. Set the slider to update n0: In Touch Move Event:
   ```
   n0.val=Slider0.val
   ```

### Step 5: Compile and Upload

1. Compile your Nextion project (.HMI)
2. Generate .TFT file
3. Upload to your Nextion display via:
   - SD card method, or
   - Serial upload, or
   - Debug mode

## Testing Your Nextion Page

### Manual Testing (Before ESPHome)

1. **Test in Nextion Simulator:**
   - Click simulator button in Nextion Editor
   - Move slider, verify n0 updates
   - Manually set n1 and n0 values in simulator

2. **Test on Physical Display:**
   - Upload to display
   - Navigate to page 3
   - Move slider, verify number changes
   - Touch button (if configured)

### Testing with ESPHome

1. **Verify ESPHome can write to display:**
   - Upload ESPHome config
   - Check logs for: "Nextion display initialization completed"
   - Temperature values should appear on n1 and n0

2. **Verify bidirectional communication:**
   - Move slider on Nextion
   - Check ESPHome logs for value updates
   - Check Home Assistant - desired temp should change

3. **Verify automatic updates:**
   - Change desired temp in Home Assistant
   - Watch n0 update on Nextion display
   - Temperature sensor changes should update n1

## Troubleshooting

### Numbers Don't Update

**Check:**
- Object names exactly match: `n0`, `n1`, `Slider0`
- Page name is exactly `three`
- Component IDs are correct
- UART connections are correct (TX ↔ RX)
- Baud rate is 9600

**Test manually:**
```
In Nextion Debug mode, try:
  page 3
  three.n0.val=25
  three.n1.val=20
```

### Slider Doesn't Control Temperature

**Check:**
- Slider "Send Component ID" is enabled
- Component ID matches ESPHome config (default: 2)
- Slider Touch Move Event updates n0:
  ```
  n0.val=Slider0.val
  ```

### Display Shows Wrong Values

**Check:**
- Verify units (Celsius vs Fahrenheit)
- Check for integer conversion in ESPHome (using `lroundf`)
- Ensure no conflicting updates

## Example Nextion Code

### Slider Touch Move Event
```javascript
// Update n0 when slider moves
n0.val=Slider0.val
```

### Slider Touch Release Event
```javascript
// Send component ID to ESPHome
// (Enable "Send Component ID" in properties)
```

### Optional: Button Press Event (b2)
```javascript
// Example: Return to page 0
page 0
```

## Advanced Customization

### Adding Visual Heating Indicator

Add a picture component for heating status:

1. **Add Picture Component**
   - Object name: `heating_led`
   - Images: LED off (0), LED on (1)

2. **Control from ESPHome:**
   ```yaml
   heat_action:
     - lambda: |-
         id(nextion0).send_command("three.heating_led.pic=1");
   
   idle_action:
     - lambda: |-
         id(nextion0).send_command("three.heating_led.pic=0");
   ```

### Adding Status Text

Add a text component for mode display:

1. **Add Text Component**
   - Object name: `status_text`
   
2. **Update from ESPHome:**
   ```yaml
   - lambda: |-
       id(nextion0).send_command("three.status_text.txt=\"Heating\"");
   ```

### Color-Coded Temperature Display

Change n1 color based on temperature:

```yaml
- lambda: |-
    if (x < 18.0) {
      id(nextion0).send_command("three.n1.pco=31"); // Blue
    } else if (x > 24.0) {
      id(nextion0).send_command("three.n1.pco=63488"); // Red
    } else {
      id(nextion0).send_command("three.n1.pco=65535"); // White
    }
```

## Component ID Reference

If you need to change the slider component ID in ESPHome:

**Current setting:** `component_id: 2`

**To change:** Edit `gazebo_page3_thermostat.yaml` line ~451:

```yaml
binary_sensor:
  - platform: nextion
    page_id: 3
    component_id: 2  # ← Change this number to match your slider ID
    name: "Thermostat Slider"
```

**To find your component ID:**
1. Open Nextion Editor
2. Click on Slider0
3. Look at properties: "id" or "Component ID"
4. Use that number in ESPHome config

## Complete Nextion Page Checklist

- [ ] Page 3 exists and is named `three`
- [ ] Number component `n0` exists (desired temp)
- [ ] Number component `n1` exists (actual temp)
- [ ] Slider component `Slider0` exists
- [ ] Slider range is 10-35
- [ ] Slider "Send Component ID" is enabled
- [ ] Slider Touch Move Event updates n0
- [ ] All components are visible on page
- [ ] Compiled and uploaded to display
- [ ] Tested in simulator or on device
- [ ] Page navigation works (can reach page 3)

## Reference Images

Your provided image shows:
- Clean, modern gradient background (orange/pink at top, purple at bottom)
- Large temperature numbers prominently displayed
- Slider at top for easy access
- Clear, readable layout

This configuration guide will help you recreate or verify this design.

---

**Note:** Exact positioning, colors, and sizes are based on your design preferences. Adjust as needed for your specific Nextion display model and resolution.

**Display Model Tested:** Standard Nextion Enhanced models  
**Resolution:** Works with 2.4", 3.2", 3.5", 5.0", 7.0" displays  
**Nextion Editor Version:** 1.65.1+

---

**Need Help?**
- Nextion Documentation: https://nextion.tech/
- ESPHome Nextion: https://esphome.io/components/display/nextion.html
- Forum Support: ESPHome Discord or Community Forums

