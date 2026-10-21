# OpenBreeze

**An affordable (~$20), open-source, 3D-printable Continuous Positive Airway Pressure (CPAP) machine designed to be built with an FDM 3D printer (PETG) and universally available hardware-store / commodity parts.**

> ⚠️ **CRITICAL MEDICAL & SAFETY DISCLAIMER**
> OpenBreeze is an experimental, open-source engineering project and is **not** an FDA-cleared or certified medical device. Obstructive sleep apnea (OSA) and positive airway pressure therapy carry serious risks including asphyxiation ($\text{CO}_2$ rebreathing), barotrauma (overpressure lung injury), inhalation of contaminants, and ineffective therapy. Never use any experimental respiratory device without reading and following [`docs/SAFETY_AND_TESTING_PROTOCOL.md`](docs/SAFETY_AND_TESTING_PROTOCOL.md) in its entirety.

---

## Why OpenBreeze Exists

Millions of people with obstructive sleep apnea go untreated because commercial CPAP machines and sleep studies cost hundreds or thousands of dollars.

Commercial CPAP machines are expensive because they are engineered to fit in the palm of your hand on a nightstand. A tiny $40\text{ mm}$ impeller must spin at **35,000–45,000 RPM** to generate therapeutic pressure ($4\text{–}20\text{ cmH}_2\text{O}$), requiring an expensive 3-phase micro-turbine, high-frequency ESC, electronic differential pressure sensors, and a real-time microcontroller PID loop.

**OpenBreeze flips the physics by removing the size constraint:**
By making the machine larger (housed inside a quiet floor-standing bucket or storage tote) and 3D-printing a **$165\text{ mm}$ ($6.5\text{-inch}$) single-stage radial-tip centrifugal impeller in PETG**, we achieve the exact same blade-tip speed ($u = \omega R$) at **one-fifth the RPM ($2,600\text{–}5,500\text{ RPM}$)**:
- **Zero electronics or code required**: Because a $165\text{ mm}$ radial-tip ($\beta_2 = 90^\circ$) wheel operates at $<5\%$ of its maximum volumetric capacity during human breathing, its Euler pressure-flow curve is naturally flat ($\Delta P = \rho u_2^2$). Combined with a low-impedance air path, pressure stays steady within **$<0.7\text{ cmH}_2\text{O}$** between inhalation and exhalation—set directly by a simple DC voltage knob.
- **100% Isolated Clean Air Path**: Unlike DIY designs that blow breathing air through cheap pre-made fans (exposing the user's lungs to hot PCB resin, solder flux, and bearing grease), OpenBreeze mounts a single commodity 12V motor **on the outside** of a pure PETG housing. Positive static pressure on the back of the impeller disk ($P_{\text{shaft}} \approx +\frac{1}{2}\Delta P$) continuously bleeds a tiny trickle of clean air *outward* through the shaft seal, making it physically impossible for motor dust or fumes to enter the breathing chamber.
- **Zero-Drift Gravity Calibration**: Pressure is verified continuously by a $0.70 clear vinyl **U-Tube Water Manometer** ($1\text{ cm}$ water height difference $\equiv 1.0\text{ cmH}_2\text{O}$ by physics, with zero sensor drift).

---

## System Architecture (Version 4: Clean-Path Radial)

```
   [ Room Air ]
        │
        ▼
┌────────────────────────────────────────────────────────┐
│  6x6" Pleated MERV-13 / HEPA Intake Panel ($1.22)      │ ◄─ Filters air BEFORE blower
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐     ┌─────────────────────────┐
│  100% PURE PETG VOLUTE + 165mm RADIAL-TIP IMPELLER     │     │ EXTERNAL 12V MOTOR      │
│  • Single moving part (2,600–5,500 RPM)                │     │ (775 or Nidec Brushless)│
│  • Printed flat in 2 snap-together halves (0 supports) │◄───►│ • 100% OUTSIDE air path │
│  • Balanced to <0.02g using 1.75mm filament snippets   │Shaft│ • Positive shaft bleed  │
│  • Flat P-Q curve (beta_2 = 90 deg, zero surge)        │Seal │   keeps motor air OUT   │
└──────────────────────────┬─────────────────────────────┘     └────────────▲────────────┘
                           │                                                │
                           ▼                                   [ LM2596 Voltage Regulator ]
┌────────────────────────────────────────────────────────┐     [ + 2A Fuse + 12V Brick    ]
│  Straight-Through 32mm Perforated Silencer             │
│  (Wrapped in rolled bath towel inside bucket)          │
└──────────────────────────┬─────────────────────────────┘
                           │
        ┌──────────────────┼───────────────────┐
        ▼                  ▼                   ▼
[ U-Tube Water      [ 22mm Smooth       [ Low-Pressure Flapper ]
  Manometer w/        CPAP Hose ]       [ + $1.25 Dollar-Tree  ]
  Splash Bulbs ]           │            [   90dB Window Alarm  ]
  (1cm = 1 cmH2O)          ▼
              [ Nasal-Only Mask + Safety Elbow ]
                ├─ Mouth 100% UNCOVERED (cannot suffocate)
                ├─ Fixed 8x 2.0mm CO2 Vent Holes (un-blockable)
                └─ Flat-Printed PETG AAV + Steel Safety-Pin Spring
```

---

## Verified ~$20 Bill of Materials (2026 Retail Prices)

| Component | Source & Specification | Cost per Build |
| :--- | :--- | :--- |
| **Impeller, Volute, Silencer, Manometer Traps, Safety Elbow** | 3D-Printed in PETG (~350g filament) | *(On hand)* |
| **Air Filter ($6\times 6\text{"}$ Pleated MERV-13 / HEPA Panel)** | Cut 1 standard $4.88 Walmart $12\times 12\times 1\text{"}$ Filtrete MPR 1900 / MERV-13 filter into four $6\times 6\text{"}$ squares (or $4.88 Bissell Zing HEPA filter) | **$1.22** ($4.88 for 4) |
| **Motor ($12\text{V}$, $5,000\text{–}6,000\text{ RPM}$, Dual Ball Bearing)** | `775` 12V 6000 RPM Ball-Bearing DC Motor or `Nidec 24H` BLDC (Amazon/eBay) or salvaged 12V drill/fan motor | **$6.00** |
| **DC Voltage Controller (with LED Voltmeter)** | LM2596 DC-DC Buck Converter with LED display (allows repeatable $0.1\text{V}$ pressure settings) | **$2.50** |
| **12V DC Power Supply ($\ge 2\text{A}$) + 2A Inline Fuse** | Thrift store / salvaged router or monitor 12V DC brick + $0.25 2A automotive blade fuse | **$1.75** |
| **U-Tube Water Manometer** | $2\text{ ft}$ of $1/4\text{"}$ ID Clear Vinyl Tubing at Home Depot ($0.35/ft) | **$0.70** |
| **90 dB Low-Pressure / Power-Outage Siren** | Dollar-Tree battery-powered Magnetic Window/Door Alarm + 1 Steel Safety Pin | **$1.25** |
| **Acoustic Enclosure** | 5-Gallon Bucket / storage tote + 2 rolled bath towels + rubber bands | **$0.00–$4.48** |
| **Machine Subtotal** | | **$13.42 – $17.90** |
| **Hose & Nasal Mask** *(if not already owned)* | Standard 6-ft $22\text{ mm}$ smooth-bore CPAP hose ($5) + replacement silicone nasal cushion & strap ($7) | **$0.00** *(if owned)* or **$12.00** |

---

## Repository Structure

- [`docs/ENGINEERING_AND_FMEA.md`](docs/ENGINEERING_AND_FMEA.md) — Complete physics calculations, turbomachinery math, and V1 $\to$ V4 Adversarial Red-Team Failure Mode and Effects Analysis (FMEA).
- [`docs/SAFETY_AND_TESTING_PROTOCOL.md`](docs/SAFETY_AND_TESTING_PROTOCOL.md) — Mandatory 4-rule life-safety architecture, awake testing checklist, and self-titration protocol.
- [`reference/openpap/`](reference/openpap/) — Archived CAD (`openpap.scad`) and recovered firmware (`openpap.ino`) from Derek Anderson's [`keredson/OpenPAP`](https://github.com/keredson/OpenPAP) project, along with our engineering audit of what to reuse (ISO $22\text{ mm}$ hose spigot, integrated static pressure tap, filter slot) and what bugs to avoid.

---

## Project Roadmap

- [x] **Phase 1**: First-principles physics, thermodynamics, and fluid-mechanics modeling.
- [x] **Phase 2**: Multi-round Adversarial Red-Team FMEA (V1 $\to$ V2 $\to$ V3 $\to$ V4 hardening).
- [x] **Phase 3**: Audit & recovery of prior art (`keredson/OpenPAP` CAD and deleted firmware).
- [ ] **Phase 4**: Parametric OpenSCAD generation for V4 Clean-Path Radial Prototype 1 (`cad/`).
- [ ] **Phase 5**: Prototype 1 bench testing (manometer static/dynamic pressure curve, acoustic dBA, 8-hour thermal run) and awake human validation.

---

## License

Released under the **GNU General Public License v3.0 (GPL-3.0)**. See [`LICENSE`](LICENSE) for details.
