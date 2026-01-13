---
title: "Syringe-Pump"
excerpt: "DIY Syringe-pump capable of 1 uL/min to 10 mL/min flow rate."
header:
  image: /assets/img/Cyber-Scooter-Banner.jpg
  teaser: /assets/img/Cyber-Scooter-TH.jpg
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
