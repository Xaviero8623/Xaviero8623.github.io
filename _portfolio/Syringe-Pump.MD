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
