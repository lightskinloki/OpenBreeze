# Prior Art Reference: `keredson/OpenPAP`

This directory preserves key files from Derek Anderson's [`keredson/OpenPAP`](https://github.com/keredson/OpenPAP) repository (licensed under GPL-3.0):

- [`openpap.scad`](openpap.scad) — Original OpenSCAD enclosure, lid, filter slot, and motor mounts.
- [`openpap.ino`](openpap.ino) — Recovered original ESP32 CPAP firmware from commit `1383075536ed33385b386e781681d80cc8c2239d` (September 1, 2024), prior to its accidental deletion in commit `cf3f8bb` (July 15, 2025).

---

## What OpenBreeze Reuses from `openpap.scad`

1. **ISO 5356-1 $22\text{ mm}$ Tapered CPAP Hose Spigot (`lid()`, lines 118–128)**:
   - Outer cone tapering from $25\text{ mm}$ to $23\text{ mm}$ over $20\text{ mm}$ height with a $19\text{ mm}$ inner bore, providing a reliable friction fit for standard $22\text{ mm}$ silicone/rubber CPAP hose cuffs.
2. **Integrated Internal Static Pressure Sense Channel (`lid()`, lines 120–131)**:
   - A $3.2\text{ mm}$ ID (`r = 1.6`) horizontal passage printed inside the lid flange that taps static pressure right at the base of the $22\text{ mm}$ hose outlet. In OpenBreeze, this port connects directly to the zero-drift U-Tube Water Manometer.
3. **Standard ResMed AirSense 10 Filter Slot (`shell()`, lines 58–89)**:
   - $54\times 35\times 6\text{ mm}$ intake filter pocket compatible with commodity replacement CPAP filters.

---

## Why OpenBreeze Diverges from OpenPAP's Blower & Sensor Architecture

1. **Cost ($20 vs. $120)**: OpenPAP requires a $65 replacement ResMed 3-phase micro-blower, an $18 4S–6S drone ESC, a 24V 5A supply, an ESP32, and an HX711 sensor. OpenBreeze replaces the micro-turbine and active electronics with a 3D-printed $165\text{ mm}$ clean-path radial-tip impeller driven by an external $6 12V motor and $2.50 voltage regulator.
2. **Eliminating `MPS20N0040D` / `HX711` Sensor Drift**: OpenPAP's $40\text{ kPa}$ ($408\text{ cmH}_2\text{O}$) uncompensated bridge sensor operating at $10\text{ cmH}_2\text{O}$ ($2\%$ of full scale) suffered from severe thermal drift ($0.12\text{ cmH}_2\text{O}/\text{min} = 7.2\text{ cmH}_2\text{O}/\text{hr}$).
3. **Eliminating PID Full-Throttle Runaway & `HX711` Hang Bugs**: In `openpap.ino`, a disconnected sense tube (`input = 0`) causes the PID integral to wind up to `ESC_MAX` ($>45\text{ cmH}_2\text{O}$), and `scale.get_value(1)` blocks indefinitely without a watchdog if the sensor wire glitches.
