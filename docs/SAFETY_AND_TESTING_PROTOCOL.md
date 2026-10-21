# Safety & Personal Testing Protocol (Prototype 1)

Because sleep apnea occurs while you are unconscious, **every Prototype 1 build must obey 4 non-negotiable physical safety rules** that guarantee a mechanical, electrical, or software failure at 3:00 AM cannot suffocate or injure the user.

---

## Rule 1: Nasal-Only Mask Interface (Keep Your Mouth 100% Uncovered)

- **NEVER test Prototype 1 overnight with a strapped-on Full-Face (oronasal) respirator or mask that covers both your nose and your mouth.** If airflow stops in a full-face mask and a valve fails, both breathing passages are trapped inside a sealed cup.
- **Always use a Nasal Mask or Nasal Pillows that cover ONLY the nose**, leaving your mouth 100% uncovered and open to room air.
- If machine airflow stops or restricts during sleep, your brainstem reflex automatically opens your mouth to breathe room air.
- A nasal cushion also has tiny internal dead space ($\sim 20\text{ mL}$), preventing $\text{CO}_2$ accumulation when paired with fixed vent holes right at the nostrils.

---

## Rule 2: Fixed, Un-Blockable $\text{CO}_2$ Washout Holes Right at the Nose

- Never rely solely on a moving flapper valve to flush exhaled carbon dioxide ($\text{CO}_2$).
- If you are using a commercial CPAP nasal mask, verify that its built-in multi-hole **exhalation diffuser port** right on the front of the nasal cushion/elbow is clean and unobstructed.
- If you are using the 3D-printed OpenBreeze safety elbow, ensure the **eight fixed $2.0\text{ mm}$ ($5/64\text{"}$) $\text{CO}_2$ washout holes** ($25\text{ mm}^2$ total orifice area) right at the nose piece are drilled clean through. These holes have no moving parts and continuously flush $20\text{–}35\text{ L/min}$ of fresh air past your nostrils.

---

## Rule 3: Independent $1.25 Battery-Powered 90 dB Low-Pressure Siren

To ensure you wake up immediately if the power goes out, a wire disconnects, or blower pressure drops during the night:

1. Purchase a **$1.25 Magnetic Window/Door Alarm** (Dollar Tree / Walmart / Harbor Freight), which runs on its own internal LR44 coin-cell batteries and emits a $90\text{ dB}$ siren whenever the magnet moves away from the reed switch.
2. Mount the alarm unit on the outside of the 3D-printed Low-Pressure Flapper housing on the blower outlet, and attach the small magnet to the flapper door:
   - **When Blower is ON ($\ge 3\text{ cmH}_2\text{O}$)**: Air pressure holds the flapper (and magnet) up against the sensor $\rightarrow$ **Silent**.
   - **When Power Cuts or Pressure Drops ($< 2.5\text{ cmH}_2\text{O}$)**: The safety-pin spring pulls the flapper down away from the sensor $\rightarrow$ **90 dB Siren sounds immediately**, waking you up even if house AC power is completely dead.

---

## Rule 4: Native 12V Fused Power + Dry Air Path for Prototype 1

1. **Power Supply**: Use only a **native $12.0\text{V}$ DC UL-listed power supply** with a **$2\text{A}$ inline fast-blow fuse** feeding the LM2596 DC voltage regulator. Even if the regulator MOSFET fails short-circuit, the motor can never receive more than $12.0\text{V}$.
2. **No Liquid Water in Prototype 1**: Do not place liquid water inside the blower bucket during initial Prototype 1 testing so there is zero risk of spilling water into the hose. Use saline nasal spray before bed or a dry inline Heat-and-Moisture Exchanger (HME) sponge if needed.
3. **U-Tube Water Manometer Verification**:
   - Fill the clear $1/4\text{"}$ vinyl U-tube halfway with water (add 1 drop of food coloring for visibility) and clip it against a centimeter ruler.
   - Because $1\text{ cmH}_2\text{O}$ is literally $1\text{ centimeter}$ of vertical water column difference, measure the vertical distance $\Delta h$ between the two water meniscuses while wearing the mask and breathing:
     $$\text{Pressure in cmH}_2\text{O} = h_{\text{high}} - h_{\text{low}} \ (\text{in cm})$$

---

## Mandatory Daytime Awake Test (Before First Overnight Use)

Before sleeping with Prototype 1 overnight:

1. **4-Hour Unattended Bench Burn-In**: Run the machine on the floor for 4 hours at $12\text{ cmH}_2\text{O}$ while awake in the room. Check that motor temperature stays below $45^\circ\text{C}$, vibration stays minimal, and the air coming out of the hose smells 100% clean and odor-free.
2. **Power-Cut Drill**: While wearing the nasal mask and breathing normally, unplug the 12V power brick:
   - Confirm that the **$90\text{ dB}$ magnetic window alarm triggers immediately**.
   - Confirm that the **Anti-Asphyxia Valve snaps open** and that you can breathe comfortably through the open valve and fixed vent holes for 5 minutes with the blower completely off.
3. **60-Minute Awake Lying-Down Trial**: Wear the mask in bed while reading or watching TV for 60 minutes (ideally with a fingertip pulse oximeter confirming $\text{SpO}_2 = 96\text{–}99\%$). Verify that inhalation feels effortless and pressure on the water manometer swings by less than $1.0\text{ cm}$ between inhale and exhale.
