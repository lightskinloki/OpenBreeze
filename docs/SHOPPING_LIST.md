# Required Materials & Shopping List (Prototype 1)

This shopping list covers **everything required to build and safely test OpenBreeze Prototype 1 from scratch**, assuming you only have an FDM 3D printer and a spool of **PETG filament** (~400g needed).

Every item is available without a prescription from local brick-and-mortar stores (Walmart, Home Depot, Dollar Tree, Goodwill) or standard online retailers (Amazon, eBay).

---

## 1. Core Electromechanical & Air-Path Parts

| # | Item | Exact Specification to Buy | Where to Buy | Est. Price | Why This Exact Spec Matters |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1** | **12V DC Motor (External Mount)** | **`775` 12V Dual-Ball-Bearing DC Motor ($4,500\text{–}6,000\text{ RPM}$ version)** <br>*(Shaft: $5.0\text{ mm}$ round or D-shaft; Front mount: 2x M4 holes at $29\text{ mm}$ spacing)* <br>**Alternative**: `Nidec 24H` 12V Brushless Motor ($5,000\text{ RPM}$, $5\text{ mm}$ shaft) | Amazon / eBay / AliExpress *(search: `"775 DC motor 12V 5000RPM ball bearing"` or `"775 12V 6000RPM"`)* | **$6.00 – $8.50** | ⚠️ **Do NOT buy the 15,000–20,000 RPM power-tool version.** You want the quiet, low-speed $4,500\text{–}6,000\text{ RPM}$ @ $12\text{V}$ ball-bearing winding. |
| **2** | **5mm Flange Shaft Coupler** *(Recommended)* | **Rigid $5.0\text{ mm}$ Inner Diameter Metal Flange Coupling** <br>*(Base OD: $22\text{ mm}$, 4x M3 mounting holes on $16\text{ mm}$ circle, includes M3 grub screws & Allen key)* | Amazon / eBay *(search: `"5mm rigid flange shaft coupling"`)* | **$2.00 – $3.50** | Locks the 3D-printed PETG impeller onto the $5\text{ mm}$ steel motor shaft with zero slip and perfect concentricity. *(A 100% 3D-printed collet is also included in CAD as a backup).* |
| **3** | **12V Variable DC Power & Speed Controller** | **Option A (Thrift/DIY — Cheapest):** <br>• Salvaged **12V DC Power Brick** ($\ge 2\text{A}$, from old Wi-Fi router/monitor) <br>• **LM2596 DC-DC Buck Converter with LED Voltmeter** <br>• **2A Inline Automotive Blade Fuse** <br><br>**Option B (Plug-and-Play — Zero Soldering):** <br>• **3V–12V 5A Adjustable DC Power Supply with LED Voltage Display Knob & Screw-Terminal Jack** | **Option A:** Goodwill ($1.50 brick) + Amazon/eBay ($2.50 LM2596) <br><br>**Option B:** Amazon / Walmart *(search: `"3V-12V 5A adjustable power supply LED display"`)* | **Option A:** **$4.25** <br><br>**Option B:** **$9.50** | The built-in red LED voltmeter lets you dial and record your exact therapeutic pressure setting to $0.1\text{V}$ (e.g., `8.6V = 10.0 cmH2O`) and never exceeds $12.0\text{V}$. |
| **4** | **High-Efficiency Intake Air Filter** | **Option A (Hardware Store):** <br>One **$12\times 12\times 1\text{"}$ MERV 13 / Filtrete MPR 1900 Pleated Filter** (cut with scissors into four $6\times 6\text{"}$ / $150\times 150\text{ mm}$ squares) <br><br>**Option B (Standard CPAP Filter Pads):** <br>Pack of **$53\times 35\text{ mm}$ ResMed AirSense 10 Disposable Filters** | **Option A:** Walmart / Home Depot ($4.88 for 1 filter = 4 squares) <br><br>**Option B:** Amazon / CVS ($5.99 for 60 filters) | **$1.22** per square *(or $0.10 per CPAP pad)* | Placed at the clean volute intake. CAD includes modular filter frames for both the $150\times 150\text{ mm}$ MERV-13 square and triple AirSense 10 pads. |

---

## 2. Patient Interface (Hose & Nasal-Only Mask)

*Because you are starting with zero existing CPAP supplies, buy these two standard non-prescription replacement items so your face seal and $\text{CO}_2$ washout vent are factory-molded skin-safe silicone:*

| # | Item | Exact Specification to Buy | Where to Buy | Est. Price | Why This Exact Spec Matters |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **5** | **Standard CPAP Hose ($6\text{ ft}$)** | **6-Foot Smooth-Bore $19\text{ mm}$ / $22\text{ mm}$ Universal CPAP Tubing** <br>*(Standard $22\text{ mm}$ rubber friction cuffs on both ends)* | Amazon / Walmart / CVS *(search: `"standard 6ft 22mm CPAP hose"`)* | **$5.50 – $7.99** | Fits directly onto OpenBreeze's ISO $22\text{ mm}$ tapered outlet spigot and the mask swivel elbow. Smooth inner bore prevents turbulent whistling. |
| **6** | **Nasal-Only CPAP Mask + Headgear** | **Replacement Silicone Nasal Mask Cushion, Frame, Elbow & Headgear Strap** <br>*(Covers **ONLY the nose** — e.g., N20 / Wisp / P10 nasal pillow style with built-in multi-hole $\text{CO}_2$ vent elbow)* | Amazon / eBay / Walmart *(search: `"nasal mask frame cushion headgear replacement"` — sold OTC without Rx as replacement parts)* | **$11.00 – $15.00** | 🛡️ **Safety Rule #1**: Covers *only* your nose, leaving your mouth 100% uncovered so you can always breathe room air through your mouth if power cuts out. |

---

## 3. Calibration, Safety Siren & Acoustic Enclosure (Local Store Run)

| # | Item | Exact Specification to Buy | Where to Buy | Est. Price | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **7** | **Clear Vinyl Tubing ($3\text{ ft}$)** | **$1/4\text{"}$ Inner Diameter ($3/8\text{"}$ OD) Clear Braided or Unbraided Vinyl Tubing** | Home Depot / Lowe's / Ace Hardware (Plumbing aisle, sold by the foot) | **$1.05** ($0.35/ft) | Forms the **U-Tube Water Manometer** ($1.0\text{ cm}$ water height difference $= 1.0\text{ cmH}_2\text{O}$) and connects to the printed pressure tap on the outlet spigot. |
| **8** | **Battery-Powered Magnetic Window Alarm** | **90 dB Standalone Magnetic Door/Window Reed-Switch Alarm** *(Includes LR44 coin-cell batteries)* | Dollar Tree / Harbor Freight / Walmart (Hardware/Security aisle) | **$1.25** | Mounts on the 3D-printed low-pressure flapper. Screams at $90\text{ dB}$ on its own battery power the instant blower pressure drops below $2.5\text{ cmH}_2\text{O}$ or house power fails. |
| **9** | **Steel Safety Pins** | **Assorted Standard Steel Safety Pins** (~$38\text{ mm} / 1.5\text{"}$ length) | Dollar Tree / Walmart / Sewing kit | **$1.00** *(or on hand)* | Provides the fatigue-proof, creep-free spring-steel coil torsion spring for the Anti-Asphyxia / Low-Pressure flapper door. |
| **10** | **5-Gallon Bucket + Lid** *(or Storage Tote)* | **Standard 5-Gallon HDPE Bucket + Snap-On Lid** | Home Depot / Lowe's / Walmart | **$4.48** *(or $0 if using a tote/cooler on hand)* | Heavy outer acoustic enclosure. |
| **11** | **Sound Absorption & Suspension** | • **2 Old Cotton Bath Towels** <br>• **Pack of Heavy #64 Rubber Bands** (or silicone bungee bands) | Home linen closet + Dollar Tree / Office aisle | **$1.25** | Towels line the bucket wall and wrap the straight-through $32\text{ mm}$ perforated silencer; rubber bands suspend the blower in mid-air so zero vibration reaches the floor. |

---

## 4. Fasteners, Adhesives & Print Filament

* **Filament**: ~400g of **1.75mm PETG Filament** (any brand; avoid ABS/ASA due to styrene VOCs, and avoid brittle matte PLA).Keep 1 meter of unprinted $1.75\text{ mm}$ PETG filament handy to snip into $3.05\text{ mg/mm}$ balance weights.
* **Screws**:
  * **2x `M4 x 10mm` machine screws + washers** (bolts the `775` motor face to the exterior of the printed PETG volute backplate).
  * **4x `M3 x 12mm` machine screws + nuts** (bolts the $5\text{ mm}$ metal flange coupler to the printed impeller hub).
  * **6x `M3 x 16mm` machine screws + nuts** *(or 6x small #6 $\times\ 5/8\text{"}$ pan-head sheet-metal screws)* (clamps the front volute cover to the backplate).
* **Adhesives**:
  * **Cyanoacrylate Superglue (CA Glue)**: For bonding the flat-printed impeller front shroud ring onto the 16 blade tips.
  * **100% Pure Silicone Caulk (Neutral Cure) or Hot Glue Gun**: For laying a $2\text{ mm}$ sealing bead in the volute flange gasket groove.

---

## Total Budget Summary

| Build Path | Total Out-of-Pocket Cost |
| :--- | :--- |
| **Machine Only** *(using salvaged 12V brick, home tote/towels, and existing mask/hose)* | **~$13.50 – $18.00** |
| **Complete Scratch Build** *(buying plug-and-play adjustable 12V supply, new 775 motor, 5mm coupler, bucket, alarm, tubing, AND new 6-ft CPAP hose + OTC silicone nasal mask)* | **~$36.00 – $44.00** |
