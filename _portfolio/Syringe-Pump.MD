---
title: "Syringe-Pump"
excerpt: "DIY Syringe-pump capable of 1 uL/min to 10 mL/min flow rate."
header:
  image:     assets/img/Linear_Actuator_Assembly_2024-Oct-03_11-23-52AM-000_CustomizedView10586363028_png (1).png
  teaser:     assets/img/Linear_Actuator_Assembly_2024-Oct-03_11-23-52AM-000_CustomizedView10586363028_png (1).png
gallery:
  - url: /assets/img/Cyber-Scooter-1.jpg
    image_path: assets/img/Cyber-Scooter-1.jpg
    alt: "placeholder image 1"
  - url: /assets/img/Cyber-Scooter-2.jpg
    image_path: assets/img/Cyber-Scooter-2.jpg
    alt: "placeholder image 2"
  - url: /assets/img/Cyber-Scooter-3.jpg
    image_path: assets/img/Cyber-Scooter-3.jpg
    alt: "placeholder image 3"
---


# Features
* **Stepper Motor-Driven Lead Screw Mechanism:** Precise fluid delivery through motor-controlled lead screw and nut assembly that advances the syringe plunger at programmable rates.
* **Programmable Flow Rate Control:** Easy-to-set flow rates (mL/min) via Arduino code with single global variables for flow rate and syringe diameter. Supports decimal flow rates for fine control.
* **Multi-Syringe Compatibility:** Tool-free swapping between 10 mL and 20 mL syringes. No special tools required - fingers only. Syringe fully supported on both ends to prevent sagging during operation.
* **RGB LED Status Indicator:** Real-time visual feedback with color-coded operation states - Green (running), Yellow (paused), Red (out of liquid/empty).
* **Intuitive Control Interface:** Single latching push button for start/pause operation with automatic limit switch that stops motion when syringe is empty.
* **Professional Wiring & Safety:** Clean electrical assembly with proper terminations (Dupont pins, fork connectors, ferrules) and heat shrink protection on all solder joints. Electronics fully enclosed and protected from user contact and liquid exposure.
* **Integrated Single-Unit Design:** All core components (electronics enclosure, motor, lead screw assembly) assembled as one cohesive unit - not separate modules.
* **Non-Pulsatile Flow:** Consistent, smooth fluid delivery ideal for microfluidic applications and medical administration where flow consistency is critical.
* **High Accuracy Dispensing:** Stepper motor control enables precise volumetric delivery with minimal error for applications requiring exact dosing.
* **Serviceable & Modular:** Assembled entirely with fasteners (no glue or permanent adhesion) for easy maintenance, repairs, and component replacement.

# Bonus Features
* **Manual Plunger Positioning:** Two momentary buttons enable clockwise/counterclockwise motor control for precise plunger positioning during syringe loading without manual lead screw manipulation.
* **Real-Time Flow Rate Adjustment:** Potentiometer control allows on-the-fly flow rate changes with live display in Arduino serial monitor.
* **LCD Display Dashboard:** Shows current flow rate and calculated time remaining until syringe is empty for better operation monitoring.
* **Wireless capabilities:** A remote can be used to remotely operate the Syringe-Pump

## Operating Instructions

**Setup and Loading:**
1. Ensure the syringe pump is unplugged before setup
2. Select appropriate syringe size (10 mL or 20 mL) and fill with desired fluid
3. Adjust syringe holder to accommodate syringe diameter (tool-free adjustment)
4. Insert syringe into holder, ensuring both ends are fully supported
5. Use manual positioning buttons (forward/reverse) to move plunger holder into position against syringe plunger
6. Press and hold forward button to advance plunger holder or reverse button to retract
7. Release button when plunger holder is properly positioned
8. Verify limit switch is properly positioned to detect end of stroke

**Setting Flow Rate:**
1. Turn potentiometer knob to desired flow rate setting (0.1 to 5.0 mL/min)
2. Current flow rate will be displayed on LCD screen
3. LCD also displays estimated time remaining until syringe is empty
4. Flow rate can be adjusted at any time during operation

**Power-Up and Operation:**
1. Plug power supply into wall outlet (110V AC)
2. Verify LED illuminates (should be yellow indicating paused state)
3. LCD will display current flow rate setting and time remaining
4. Press latching start/stop button on control panel or wireless remote to begin pumping
5. LED will turn green, indicating pump is running
6. Monitor fluid delivery, LCD display, and LED status during operation

**Pausing Operation:**
1. Press latching start/stop button on control panel or wireless remote to pause
2. LED will turn yellow, indicating paused state
3. LCD continues to display flow rate and remaining time
4. Press button again to resume operation

**Manual Positioning (When Paused):**
1. Ensure pump is in paused state (yellow LED)
2. Press and hold forward button to advance plunger/carriage
3. Press and hold reverse button to retract plunger/carriage
4. Use for fine positioning adjustments or resetting carriage position
5. Release button to stop manual movement

**Adjusting Flow Rate During Operation:**
1. Turn potentiometer knob while pump is running or paused
2. LCD will update in real-time to show new flow rate
3. Time remaining calculation automatically adjusts based on new flow rate
4. No need to stop pump to change flow rate

**End of Operation:**
1. When syringe is depleted, limit switch will automatically stop motor
2. LED will turn red, indicating syringe is empty
3. LCD displays final status
4. Press latching start/stop button to reset system to paused state (yellow LED)
5. Use reverse button to retract carriage for syringe removal
6. Unplug power supply from wall outlet

**Changing Syringes:**
1. Ensure pump is stopped and unplugged
2. Use reverse button to retract plunger holder if needed
3. Remove empty syringe from holder
4. Load new filled syringe following setup instructions above
5. Use forward/reverse buttons to position plunger holder
6. Adjust flow rate using potentiometer as needed
7. Resume operation following power-up instructions

**Shutdown:**
1. Press latching start/stop button to stop pumping
2. Unplug power supply from wall outlet
3. Remove syringe if not planning immediate reuse
4. Store pump in clean, dry location

**Safety Reminders:**
- Always unplug before making any adjustments to wiring or electronics
- Keep work area clean and free from liquids
- Do not touch motor during operation (can reach 80°C)
- If you smell smoke or feel wires heating, immediately unplug and diagnose issue
- Never bypass limit switch or safety features
- Do not hold forward/reverse buttons when at travel limits

---

# Parts Used

Component                                          | Quantity | Notes
--------------------------------------------------|----------|--------------------------------------------------------
250 mm lead screw with 2 mm pitch and 2 mm lead   | 1        |
250 mm lead screw with 2 mm pitch and 8 mm lead   | 1        |
1/4" x 8mm Flexible Coupling                      | 1        | 
200 mm linear rod with 8 mm diameter              | 2        |
LM8UU Linear bearing for 8 mm diameter rod        | 2        | 
2040 Aluminum Extrusion 1' Length                 | 1        |
Nema 17 Stepper Motor                             | 1        | 
MEAN WELL RQ-65D AC-DC Power Supply               | 1        | Quad Output: 5V, 12V, 24V, 12V @ 4 Amp
Arduino Uno                                       | 1        | 
A4988 Stepper Driver                              | 1        |
Small Breadboard                                  | 1        | 
Panel Mount Latching Push Button (On/Off)         | 1        | For start/pause function
Panel Mount Momentary Push Button                 | 1        | Bonus feature only
Limit Switch                                      | 1        | Stops motion when plunger reaches limit
RGB Common Cathode LED                            | 1        | Green (running), Yellow (paused), Red (out of liquid)
ESP32                                             | 2        | Used for Wireless Remote
Wires, fasteners, resistors, etc.                 | As needed| 
Heat shrink tubing                                | As needed| 
Proper wire terminations                          | As needed| Dupont pins, fork connectors, ferrule required
3D Printing Filament                              | As needed| 

# Arduino Code
The code for the project can be found [here](https://github.com/Xaviero8623/Syringe-Pump/tree/main).
# Interactive Fusion Model
<iframe src="https://vanderbilt643.autodesk360.com/shares/public/SH90d2dQT28d5b6028117f6087986883a59c?mode=embed" width="640" height="480" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"  frameborder="0"></iframe>
