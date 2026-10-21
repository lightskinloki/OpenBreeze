# Design Review Notes — 2026-10-21

> **What this document is:** Notes from an AI-assisted design review (Claude, Anthropic) of the Phase 1–3 documents in this repository, held on 2026-10-21. It records a re-check of the math, safety findings, open design decisions, and the project's scope decision on central and mixed sleep apnea.
>
> **Timing:** This review covers the repository as of commit `d410c1c`, before the Phase 4 CAD suite (`e47c339`) was added. The CAD files have not yet been checked against these findings, so Section 4 may already be partly addressed in `cad/`.
>
> **What this document is not:** Test data, validation, or medical advice. Every number below is a calculated estimate, not a measurement. Nothing here has been confirmed on hardware. Findings marked *open* are decisions for the project owner and have not been made yet.

---

## 1. Scope Decision: Obstructive Sleep Apnea Only (For Now)

- **Prototype 1 targets obstructive sleep apnea (OSA) only.**
- Central and mixed apnea support is a later phase. The likely path is ASV (adaptive servo-ventilation) or BiPAP with a backup rate. Both need breath-by-breath sensing and fast active control, which the current open-loop voltage-knob design deliberately does not have. That later phase is closer to an electronics-and-firmware project like OpenPAP.
- A future at-home **screening** tool is planned (see Section 6). It would tell a user whether they need to see a doctor. It would not be a diagnostic tool.

---

## 2. Math Re-Check

All values were recomputed independently from the formulas in [`ENGINEERING_AND_FMEA.md`](ENGINEERING_AND_FMEA.md).

| Item | Repo Value | Recomputed | Result |
| :--- | :--- | :--- | :--- |
| Tip speed / RPM table ($\Delta P = 0.64\,\rho u_2^2$, $D = 165\text{ mm}$) | e.g. $4,130\text{ RPM}$ @ $10\text{ cmH}_2\text{O}$ | $4,136\text{ RPM}$ | ✅ Matches |
| PETG hoop stress $\rho_{\text{PETG}} u_2^2$ | $0.65$–$3.24\text{ MPa}$ | $0.65$–$3.24\text{ MPa}$ | ✅ Matches |
| Imbalance force, $0.5\text{ g}$ / $0.02\text{ g}$ @ $4,130\text{ RPM}$ | $7.7\text{ N}$ / $<0.3\text{ N}$ | $7.72\text{ N}$ / $0.31\text{ N}$ | ✅ Matches |
| $1.75\text{ mm}$ PETG linear density | $3.05\text{ mg/mm}$ | $3.05\text{ mg/mm}$ | ✅ Matches |
| FMEA-03 bucket temperature rise ($18\text{ W}$, $25\text{ L/min}$) | $\approx +30^\circ\text{C}$ | $+35.8^\circ\text{C}$ | ✅ Conclusion holds (repo slightly low) |
| FMEA-06 affinity-law collapse | $49\%$ | $49\%$ | ✅ Matches |
| FMEA-09 sensor range / drift | $408\text{ cmH}_2\text{O}$, $7.2\text{ cmH}_2\text{O/hr}$ | Same | ✅ Matches |
| CO₂ washout, $8\times 2.0\text{ mm}$ holes ($C_d = 0.6$) | $20$–$35\text{ L/min}$ | $23\text{ L/min}$ @ $4\text{ cmH}_2\text{O}$, $37\text{ L/min}$ @ $10\text{ cmH}_2\text{O}$ | ✅ Matches |
| Shaft-hole back-disk pressure | $\approx +\tfrac{1}{2}\Delta P$ | $\approx +0.3\,\rho u_2^2$ (positive) | ✅ Conclusion holds |

### 2.1 Optimistic Assumption: Pressure Coefficient 0.64

The factor $0.64$ (static pressure as a fraction of $\rho u_2^2$) assumes good volute pressure recovery. A rough FDM-printed blower running near shutoff may land closer to $0.5$. If so, required speed rises about $13\%$:

| Target ($\text{cmH}_2\text{O}$) | RPM @ $0.64$ | RPM @ $0.50$ |
| :--- | :--- | :--- |
| $4$ | $2,616$ | $2,960$ |
| $8$ | $3,700$ | $4,186$ |
| $10$ | $4,136$ | $4,680$ |
| $12$ | $4,531$ | $5,126$ |
| $16$ | $5,232$ | $5,919$ |
| $20$ | $5,850$ | $6,618$ |

A "6,000 RPM" 775 motor will likely not reach $20\text{ cmH}_2\text{O}$ under load. $4$–$14\text{ cmH}_2\text{O}$ looks achievable. Bench testing (Phase 5) settles the real coefficient.

### 2.2 Expected Pressure Swing at the Mask

The U-tube tap is at the machine outlet, so it does not see hose losses. Estimated drop through a $1.83\text{ m}$ smooth-bore $19\text{ mm}$ ID hose (Blasius friction):

| Patient Flow | Hose Pressure Drop |
| :--- | :--- |
| $30\text{ L/min}$ | $0.08\text{ cmH}_2\text{O}$ |
| $60\text{ L/min}$ | $0.28\text{ cmH}_2\text{O}$ |
| $90\text{ L/min}$ | $0.58\text{ cmH}_2\text{O}$ |

Adding brushed-motor speed droop (Euler torque swing $\approx 0.003\text{ N·m}$) and blower curve droop, the estimated swing at the mask is **about $1\text{ cmH}_2\text{O}$**, comparable to commercial fixed-pressure CPAP. The README's $<0.7\text{ cmH}_2\text{O}$ claim may be slightly tight and needs measurement. Ribbed (non-smooth) hoses will lose more.

---

## 3. Safety Findings

### F-1: Intake Can Draw Motor Contamination *(open — highest priority)*
The positive-pressure shaft bleed (Section 1.3 of the FMEA doc) holds up on paper. However, the docs do not specify where the intake filter draws air from. If the brushed 775 motor sits inside the towel-lined bucket and the intake draws bucket air, carbon brush dust and commutator ozone enter the volute eye directly. As FMEA-04 already notes, HEPA/MERV filters do not stop vapors, and they do not stop ozone. The intake needs a defined air path from the room that does not pass the motor.

### F-2: Shaft Work Heats the Breathing Air
All $4$–$5.5\text{ W}$ of shaft work (including disk windage) ends up as heat in the air path. At the real average throughput (the vent flow, $25$–$35\text{ L/min}$), that is a **$+6$ to $+11^\circ\text{C}$** rise, and the towel insulation keeps the volute from shedding it. Not dangerous, but delivered air will be warm and dry. The "motor heat stays outside" statement should account for this.

### F-3: The 2A Fuse Does Not Protect Against a Motor Stall
If the impeller rubs or jams (warp, creep, debris), the LM2596 current-limits at roughly $3\text{ A}$ and the stalled motor becomes a $10$–$15\text{ W}$ heater, while the $12\text{ V}$ input current stays around $1\text{ A}$, under the fuse rating. The low-pressure alarm (Rule 3) would still wake the user, so this case is covered. The docs should not imply the fuse covers it. Wrapping the motor and LM2596 in cotton towels makes this worse. *(Minor correction: the LM2596 uses an internal bipolar switch, not a MOSFET.)*

### F-4: Low-Pressure Alarm Needs a Real Mechanical Spec *(open)*
- Cheap magnetic window alarms have no low-battery warning. The battery needs a check every night (for example, a quick press-test before bed).
- Their reed switches typically need about $15$–$25\text{ mm}$ of magnet separation. The flapper must be a sealed diaphragm or piston that moves that far at its trip pressure, without leaking, and must stay silent at the lowest therapy pressure in use.

### F-5: Breathing With the Blower Off and Mouth Closed
Breathing through the $8$ vent holes alone costs about $6.7\text{ cmH}_2\text{O}$ of effort at $30\text{ L/min}$. The hose holds about $0.52\text{ L}$, more than a normal breath, so with the blower stopped the user would re-breathe from the hose. This is why the AAV and the uncovered mouth (Rule 1) matter. Commercial nasal masks share this weakness and usually have no AAV, so the design is at least as good. The existing power-cut drill tests this case.

### F-6: Minor Items
- Neutral-cure silicone often cures by releasing oxime (MEKO). Let it cure and air out for several days before breathing through the device.
- The voltage-to-pressure calibration will drift with brush wear, filter loading, and winding temperature. The manometer remains the reference.
- The $<0.02\text{ g}$ balance target is finer than typical coupler runout: $\approx 0.05\text{ mm}$ runout on a $150\text{ g}$ rotor is worth $\approx 0.09\text{ g}$ at the rim.

### F-7: Documentation Gaps
- The README links to a "self-titration protocol" that [`SAFETY_AND_TESTING_PROTOCOL.md`](SAFETY_AND_TESTING_PROTOCOL.md) does not contain.
- Manometer tubing is listed as $2\text{ ft}$ / $\$0.70$ in the README and $3\text{ ft}$ / $\$1.05$ in the shopping list.
- The README labels the bill of materials "Verified," but no parts have been bought and tested yet.

---

## 4. Open Design Decisions for CAD (Phase 4)

These are undecided. They belong to the project owner.

1. **Intake air source** (F-1): duct from the filter to outside the bucket, a sealed compartment separating the motor from the intake, moving the motor outside the bucket entirely, or another approach.
2. **Motor and LM2596 placement** (F-3): whether they stay inside the towel-lined bucket.
3. **Second pressure tap at the mask end** for bench testing (Section 2.2).
4. **Low-pressure flapper design** (F-4): diaphragm, piston, or other, and its trip pressure.

---

## 5. Central and Mixed Sleep Apnea: Background

- **Obstructive apnea:** the airway closes; the brain keeps trying to breathe. Chest and belly keep working against the blockage, often with snoring or gasping when it ends.
- **Central apnea:** the brain stops sending the signal to breathe. There is no effort at all: silent, no movement, then breathing restarts.
- **Mixed apnea:** both, in the same person.

### 5.1 How Central Apnea Is Treated
1. **Treat the underlying cause:** heart failure, opioid use, high altitude, stroke, and some neurological conditions.
2. **Plain CPAP:** works for some people. Central apnea that appears only after starting CPAP often fades within weeks to months.
3. **ASV (adaptive servo-ventilation):** tracks each breath, adds pressure support when breathing weakens, and has a backup rate. **The SERVE-HF trial found ASV increased cardiovascular death in people with heart failure and ejection fraction $\le 45\%$.** Only an echocardiogram shows this.
4. **BiPAP with a backup rate (ST mode):** often used when ASV is not allowed.
5. **Supplemental oxygen at night.**
6. **Phrenic nerve stimulation** (implant, e.g. remedē).
7. **Medications:** mainly acetazolamide; theophylline less often.

### 5.2 Side Sleeping Is Not a Test for Central vs. Obstructive
If side sleeping helps, that suggests an obstructive component. **It does not rule out central apnea:**
- Central apnea (notably Cheyne-Stokes breathing in heart failure) can also improve when lying on the side.
- In mixed apnea, side sleeping can fix the obstructive part while central events continue, often silently.

What actually separates the two is **breathing effort during the pause**. Sleep labs and good home sleep tests measure airflow plus chest and belly effort (respiratory inductance belts). This sensor combination is a possible open-source path for the future screening tool. The hard part is the scoring software and its validation.

---

## 6. Planned: At-Home Screening and Stop-Use Policy

**Goal:** a future screening feature that tells the user whether they need to see a doctor. It is not a diagnostic tool. Example wording: *"OpenBreeze believes you may have central or mixed sleep apnea. Please see a doctor as soon as possible for an official diagnosis."*

**Policy when central or mixed apnea is suspected: stop using OpenBreeze until a doctor has made an official diagnosis, even if the machine has been helping you feel better.** The explanation shown to the user must cover:

1. **Feeling better is not evidence that it is safe.** CPAP can fix the obstructive part of mixed apnea, which brings back a lot of sleep quality. Meanwhile central events can continue or get worse, and you cannot feel them happen.
2. **CPAP can create central apnea.** Some people develop central events only after starting positive pressure (treatment-emergent central apnea). The machine could be making it worse with no visible sign.
3. **Central apnea is often a symptom of something serious.** Heart failure, stroke, opioid effects, and some neurological conditions all cause it. The apnea may be the first visible sign of a condition that needs its own treatment.
4. **The usual central apnea treatment can be fatal for some people.** ASV raises the risk of death in people with weakened hearts, and only a heart test (echocardiogram) can show who they are. Choosing a safe treatment needs tests only a doctor can order. This is why central apnea cannot be self-managed with an experimental device.

Without an official diagnosis, using a sleep apnea device incorrectly for central or mixed apnea can be extremely dangerous or fatal.

### 6.1 Other Reasons to See a Doctor Before Any CPAP Use
CPAP is generally avoided or needs medical supervision with: a history of collapsed lung (pneumothorax), bullous lung disease, a cerebrospinal fluid (CSF) leak, or recent sinus or skull-base surgery.

### 6.2 Checking Whether Therapy Works
Without a sleep study, an overnight recording pulse oximeter is the only practical way to tell whether a chosen pressure is actually treating the apnea.
