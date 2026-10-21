# Engineering Analysis & Adversarial FMEA (V1 → V4)

This document records the complete physics derivations and the three rounds of adversarial red-teaming (Failure Mode and Effects Analysis) that evolved OpenBreeze from an initial concept (V1) into the hardened **V4 Clean-Path Radial Architecture**.

---

## 1. Core Physics & Turbomachinery Derivations

### 1.1 Why Large Impeller Diameter Eliminates High RPM
For a centrifugal impeller of outer diameter $D = 2R$ rotating at angular velocity $\omega = \frac{2\pi \cdot \text{RPM}}{60}$, blade tip speed is:
$$u_2 = \omega R = \frac{\pi D \cdot \text{RPM}}{60}$$

By Euler's turbomachinery equation, theoretical energy transfer per unit volume is:
$$\Delta P_{\text{Euler}} = \rho_{\text{air}} u_2 \left(u_2 - c_{m2} \cot \beta_2\right)$$
where $c_{m2} = \frac{Q}{\pi D b_2}$ is the radial meridian through-flow velocity at the blade tip and $\beta_2$ is the blade exit angle.

By choosing **radial-exit blades ($\beta_2 = 90^\circ \implies \cot 90^\circ = 0$)** with a curved $30^\circ$ inducer entry at the eye:
1. **Mathematically Flat Head Curve**: The flow-dependent term $c_{m2} \cot \beta_2$ vanishes identically. Unlike forward-curved squirrel-cage blowers ($\beta_2 > 90^\circ$), which suffer from a positive-slope surge region at low flow, a radial-tip wheel has **zero aerodynamic surge** all the way down to $Q = 0$.
2. **Pure Radial Tension in 3D-Printed Blades**: At $\beta_2 = 90^\circ$, blades at the outer rim experience pure radial tension rather than centrifugal bending moments.
3. **Static Pressure vs. RPM for $D = 165\text{ mm}$ ($0.165\text{ m}$)**:
   Accounting for Stodola slip factor ($\sigma \approx 0.82$ for $Z = 16$ blades) and volute pressure recovery ($\eta_v \approx 0.78$), actual static pressure rise is:
   $$\Delta P_{\text{static}} \approx 0.64 \, \rho_{\text{air}} \, u_2^2 \approx 0.77 \, u_2^2 \quad (\text{Pa})$$

| Target Pressure ($\text{cmH}_2\text{O}$) | Target Pressure ($\text{Pa}$) | Required Tip Speed $u_2$ ($\text{m/s}$) | Required Speed for $D=165\text{ mm}$ ($\text{RPM}$) | PETG Hoop Stress $\sigma = \rho_{\text{PETG}} u_2^2$ ($\text{MPa}$) |
| :--- | :--- | :--- | :--- | :--- |
| **$4.0\text{ cmH}_2\text{O}$** | $392\text{ Pa}$ | $22.6\text{ m/s}$ | **$2,615\text{ RPM}$** | $0.65\text{ MPa}$ ($1.3\%$ of yield) |
| **$8.0\text{ cmH}_2\text{O}$** | $785\text{ Pa}$ | $31.9\text{ m/s}$ | **$3,695\text{ RPM}$** | $1.29\text{ MPa}$ ($2.6\%$ of yield) |
| **$10.0\text{ cmH}_2\text{O}$** | $981\text{ Pa}$ | $35.7\text{ m/s}$ | **$4,130\text{ RPM}$** | $1.62\text{ MPa}$ ($3.2\%$ of yield) |
| **$12.0\text{ cmH}_2\text{O}$** | $1,177\text{ Pa}$ | $39.1\text{ m/s}$ | **$4,525\text{ RPM}$** | $1.94\text{ MPa}$ ($3.9\%$ of yield) |
| **$16.0\text{ cmH}_2\text{O}$** | $1,570\text{ Pa}$ | $45.1\text{ m/s}$ | **$5,220\text{ RPM}$** | $2.58\text{ MPa}$ ($5.2\%$ of yield) |
| **$20.0\text{ cmH}_2\text{O}$** | $1,961\text{ Pa}$ | $50.5\text{ m/s}$ | **$5,840\text{ RPM}$** | $3.24\text{ MPa}$ ($6.5\%$ of yield) |

### 1.2 Shaft Power & Disk Friction Windage Loss
Useful pneumatic power at $12\text{ cmH}_2\text{O}$ ($1,177\text{ Pa}$) and $35\text{ L/min}$ average flow ($0.000583\text{ m}^3/\text{s}$) is only $0.69\text{ W}$ ($2.65\text{ W}$ at $90\text{ L/min}$ peak inhalation).
By Daily & Nece's turbulent rotating disk skin-friction law, exterior shroud windage loss scales as:
$$P_{\text{disk}} = C_m \cdot \frac{1}{2} \rho_{\text{air}} \omega^3 R^5 = C_m \cdot \frac{1}{2} \rho_{\text{air}} u_2^3 R^2$$
At $D = 165\text{ mm}$ ($R = 0.0825\text{ m}$) and $u_2 = 39\text{ m/s}$, $P_{\text{disk}} \approx 1.45\text{ W}$. Including internal hydraulic losses, total mechanical shaft power required from the motor is only **$3.5\text{ to }5.5\text{ Watts}$** ($\sim 0.5\text{–}0.7\text{ A}$ at $8\text{–}10\text{ V}$).

### 1.3 Positive-Pressure Back-Disk Shaft Seal (Why Motor Air Cannot Enter)
In a shrouded impeller, fluid in the rear axial gap between the back of the rotor disk and the stationary rear wall rotates at approximately $\omega_{\text{fluid}} \approx 0.5 \omega$. Integrating radial equilibrium $\frac{dP}{dr} = \rho r \omega_{\text{fluid}}^2$ from the outer rim ($r = R_2$) to the central shaft hole ($r = 0$) gives the static pressure right at the motor shaft penetration:
$$P_{\text{shaft}} \approx P_{\text{static},2} - \frac{1}{2}\rho \left(\frac{\omega}{2}\right)^2 R_2^2 \approx +\frac{1}{2}\Delta P_{\text{total}} > P_{\text{ambient}}$$
Because static pressure at the shaft hole is **always positive ($+2\text{ to }+10\text{ cmH}_2\text{O}$ above room pressure)**, clean filtered air continuously trickles **outward** from the PETG chamber toward the external motor. Dust, brush particles, bearing grease vapor, or heat from the external motor can physically never flow upstream into the breathing air.

### 1.4 Precision Rotor Balancing Using $1.75\text{ mm}$ PETG Filament Snippets
At $4,130\text{ RPM}$ ($\omega = 432\text{ rad/s}$) and $R = 82.5\text{ mm}$, $0.5\text{ g}$ of print unbalance generates $F = m\omega^2 R = 7.7\text{ N}$ of shaking force.
Standard $1.75\text{ mm}$ PETG filament ($\rho = 1.27\text{ g/cm}^3$, $A = 2.405\text{ mm}^2$) has a linear mass density of exactly:
$$\lambda = 3.05\text{ mg/mm} \quad (10\text{ mm snippet} = 0.030\text{ g})$$
By resting the impeller shaft on the rims of two drinking glasses (a knife-edge static balancer) and inserting short snippets of raw $1.75\text{ mm}$ filament into 24 vertical $1.85\text{ mm}$ perimeter holes on the light side ($12\text{ o'clock}$), any builder can balance the rotor to $<0.02\text{ g}$ ($<0.3\text{ N}$ vibration force) in 3 minutes with zero special tools.

---

## 2. Adversarial Red-Team Log (How V1, V2, V3, and OpenPAP Failed)

| Flaw ID | Vulnerability Discovered During Red-Teaming | Physical Mechanism of Failure | V4 Hardened Engineering Fix |
| :--- | :--- | :--- | :--- |
| **FMEA-01** | **Wet Capillary Stiction & Side-Sleeping in Gravity AAV** (V1) | A floppy nitrile flapper weighs $0.05\text{ g}$ ($0.0005\text{ N}$), while condensation water surface tension exerts $0.1\text{–}0.5\text{ N}$ ($500\times$ stronger), gluing the valve shut during a power outage. Side-sleeping also reverses gravity. | **Rigid Flat-Printed PETG Door on 3 Point-Contact Nibs + Steel Safety-Pin Spring**: Point contact eliminates capillary film suction; steel safety-pin torsion spring opens with $10\text{ gf}$ in any $360^\circ$ orientation. |
| **FMEA-02** | **Thermoplastic Creep in 3D-Printed Leaf Springs** (V2) | A printed PETG cantilever beam held bent for 8 hours/night at $34^\circ\text{C}$ and $100\%$ humidity undergoes viscoelastic stress relaxation, taking a permanent closed set after ~2 weeks. | **Metal Safety-Pin Spring or Silicone O-Ring**: Never rely on bent thermoplastic under continuous warm load; use a $0.01 spring-steel safety pin coil. |
| **FMEA-03** | **Thermal Runaway Inside Insulated Bucket** (V1) | Trapping $18\text{ W}$ of blower power inside a towel-lined bucket with only $25\text{ L/min}$ outflow raises air temperature by $\Delta T = \dot{Q}/(\dot{m} c_p) \approx +30^\circ\text{C}$ ($>55^\circ\text{C}$ total). | **External Motor + Once-Through Airflow**: Mounting the motor outside the clean volute keeps motor copper losses in room air; shaft work is only $\sim 4\text{ W}$. |
| **FMEA-04** | **Toxic Off-Gassing from Internal Fan Hubs** (V1–V3) | Blowing breathing air through cheap 9733 BBQ fans passes warm air directly over FR4 PCBs, solder flux, PVC insulation, and petroleum bearing grease. HEPA filters do not block chemical vapors. | **100% Isolated Clean-Path PETG Impeller**: Air touches only the intake filter and pure PETG; motor is external with an outward positive-pressure shaft bleed. |
| **FMEA-05** | **Deadweight Valve Aeroelastic Honking/Chatter** (V1) | A weighted disk on a flexible diaphragm oscillates via Bernoulli suction ($20\text{–}60\text{ Hz}$ reed-valve instability), acting like a foghorn. | **Flat-Curve Radial Impeller + Direct DC Voltage Control**: Eliminates active relief-valve regulation during normal breathing. |
| **FMEA-06** | **Fan Affinity Law Pressure Collapse** (V1) | Running $4\text{ cmH}_2\text{O}$ fans at $70\%$ speed cuts pressure to $(0.7)^2 = 49\%$ ($1.96\text{ cmH}_2\text{O}$), failing to reach therapeutic pressure. | **Single $165\text{ mm}$ Radial Wheel**: Generates up to $20\text{ cmH}_2\text{O}$ at $5,800\text{ RPM}$ on a single stage. |
| **FMEA-07** | **2-Wire Brushless PWM Commutation Glitch & Overvolt Smoke** (V2) | Chopping power to a 2-wire brushless fan with a low-frequency PWM dimmer resets its Hall IC and pops its internal cap; powering from $19\text{V}$ via a buck converter that fails short burns motor windings. | **Strict $\le 12.0\text{V}$ Supply + Smooth DC Buck Regulator (LM2596) + 2A Fuse**: Prevents overvoltage even on MOSFET short-circuit failure. |
| **FMEA-08** | **Humidifier Tilt & Water Aspiration** (V2) | Tipping a pressurized water jar sends liquid water up the hose into the sleeping user's airway. | **Dry Prototype 1 / Centroid Snorkel Geometry ($\le 30\%$ fill + sponge)**: Tubes terminating at the 3D centroid of a $\le 30\%$ filled jar cannot submerge in any $360^\circ$ orientation. |
| **FMEA-09** | **OpenPAP `HX711` + `MPS20N0040D` Drift & PID Runaway** | Operating a $408\text{ cmH}_2\text{O}$ uncompensated sensor at $10\text{ cmH}_2\text{O}$ ($2\%$ FS) caused $7.2\text{ cmH}_2\text{O}/\text{hr}$ thermal drift; disconnected sense tube winds PID to $100\%$ throttle ($50\text{ cmH}_2\text{O}$); `scale.get_value(1)` has an infinite blocking loop. | **Zero-Drift U-Tube Water Manometer + Flat-Curve Open-Loop Voltage Control**: Gravity and water density never drift, hang, or runaway. |
