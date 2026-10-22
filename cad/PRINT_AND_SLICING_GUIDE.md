# OpenBreeze 3D Print & Slicing Guide (Prototype 1 - V4.2)

All parts are designed to be printed on any standard FDM 3D printer ($220\times 220\text{ mm}$ bed or larger) using **1.75mm PETG filament**. The largest part (Part 4) is $209\times 219.5\text{ mm}$; on a $250\times 210\text{ mm}$ bed (Prusa MK3/MK4), point its spigot along the $250\text{ mm}$ axis.

The `.scad` files in `cad/scad/` are the source of truth. Every STL in `cad/stl/` is compiled from them with OpenSCAD:

```
openscad -o cad/stl/<part>.stl cad/scad/<part>.scad
```

![OpenBreeze Prototype 1 Assembly Preview](../docs/images/prototype1_assembly_render.png)

---

## 1. Universal Slicer Settings for Airtight, Low-Noise PETG Parts

| Setting | Recommended Value | Reason |
| :--- | :--- | :--- |
| **Material** | **PETG** | High impact strength, good flexural fatigue resistance, zero toxic styrene/VOCs (unlike ABS), food/skin contact safe. |
| **Nozzle Diameter** | **$0.4\text{ mm}$** *(or $0.6\text{ mm}$)* | Standard $0.4\text{ mm}$ nozzle gives sharp blade edges and clean balance holes. |
| **Layer Height** | **$0.20\text{ mm}$** | Balances vertical resolution with interlayer tensile bond strength. |
| **Perimeter Walls** | **4 Walls** (minimum $1.6\text{ mm}$) | ⚠️ **Critical for Airtightness**: 2-wall prints leak air through layer seams. 4 walls make the volute airtight at $20\text{ cmH}_2\text{O}$. |
| **Top & Bottom Layers** | **5 Top / 5 Bottom** | Guarantees pinhole-free top and bottom skins. |
| **Infill Density & Pattern** | **25% Gyroid** | Isotropic strength; gyroid infill does not vibrate or resonate like grid infill. |
| **Extrusion Multiplier (Flow)** | **$103\%\text{ to }105\%$** | Slight over-extrusion fuses inter-layer micro-voids for pneumatic sealing. |
| **Seam Position (Impeller)** | **Random** | ⚠️ **Critical for Rotor Balance**: Never use "Aligned" or "Rear" seam on the impeller. Aligned seams deposit a ridge of extra plastic on one side of the wheel, creating rotational unbalance. |

---

## 2. Rotation Direction

The wheel must spin **counterclockwise as seen from the intake (front) side**. This matches the volute scroll in Part 4, and the blade inlets lean into this direction. Engraved arrows on the hub top (Part 1) and the front face (Part 4) show it.

Looking at the motor's shaft end, the shaft must also turn counterclockwise. Check this before assembly by running the bare motor at low voltage; if it turns the wrong way, swap the two motor leads.

---

## 3. Part-by-Part Printing Orientation & Notes

### Part 1: Impeller Blade Disk (`part1_impeller_disk.stl`)
* **Orientation**: Rear balance rim down on the bed, blades pointing UP (as modeled).
* **Supports**: ⚠️ **Needed under the disk inside the rim.** The $5\text{ mm}$ rear rim lifts the base disk off the bed for $r < 74\text{ mm}$. Use tree or normal supports touching the build plate only, inside the rim. The underside is not in the air path, but re-balance after removing the supports.
* **Seam**: Set to **"Random"**.
* **Hub**: Two opposed M3 grub screws in captive M3 nuts. Drop an M3 nut into each slot from the hub top, then thread an **M3 × 8 mm grub screw** in from the outside of the hub. The two screws balance each other; always fit both.
* **Post-Processing**: Inspect blade tips for any stringing; use flush cutters to snip any stray hairs.

### Part 2: Impeller Shroud Ring (`part2_impeller_shroud.stl`)
* **Orientation**: Print exactly as modeled: **groove face DOWN on the bed, eye lip UP**. Do not flip it in the slicer.
* **Supports**: **NONE**.
* **Assembly**: Place a tiny dab of cyanoacrylate superglue (CA glue) on the tongue of each of the 16 blades on Part 1. Lower Part 2 onto Part 1 **without flipping it** (lip facing up, away from the blades) so the 16 tongues seat in the 16 grooves; the shroud bears on the flat blade tops. Let cure for 15 minutes.

### Part 3: Volute Backplate (`part3_volute_backplate.stl`)
* **Orientation**: Flat rear face (motor side) down on the bed, cavity facing UP.
* **Supports**: **NONE**. The rear face is completely flat; the motor boss recess and nut pockets print as pockets in the first layers.
* **Motor**: The 775's front bearing boss sits in the $17.8\text{ mm}$ × $4.5\text{ mm}$ deep recess, so the boss must be no taller than $4.5\text{ mm}$. Bolt the motor on with **2x `M4 x 8mm` screws** inserted from the cavity side; their heads sink into counterbores in the central plateau.
* **Shaft length**: The wheel's grub screws sit $14\text{ mm}$ above the motor's mounting face, so the **5 mm shaft must protrude at least $16\text{ mm}$ past the motor's mounting face**. Measure before printing; a shorter shaft will not reach the grub screws.

### Part 4: Volute Front Cover (`part4_volute_frontcover.stl`)
* **Dimensions**: $205\times 205\text{ mm}$ plate; $209\times 219.5\text{ mm}$ including the outlet nozzle, spigot and pressure-tap barb; $25.2\text{ mm}$ thick.
* **Orientation**: ⚠️ **Front face DOWN on the bed** (flip it in the slicer so the parting face and the open cavities face up). In this orientation nothing has to bridge across the $172\text{ mm}$ rotor chamber; the scroll and duct floors bridge at most $16\text{ mm}$.
* **Supports**: Under the horizontal $22\text{ mm}$ outlet spigot and the pressure-tap barb only (touching build plate).
* **Air path**: The rotor chamber is open to the backplate. The spiral scroll and the outlet duct have their own $3.5\text{ mm}$ floor, so the backplate gasket at $R = 92\text{ mm}$ seals under solid plastic all the way round.
* **Pressure tap**: The $7.2\text{ mm}$ barb beside the spigot fits $1/4\text{"}$ ID vinyl tubing and connects to the round outlet bore.
* **Assembly**: Lay a continuous $2\text{ mm}$ bead of neutral-cure silicone sealant (or silicone O-ring cord) in the circular gasket groove of Part 3 at $R = 92\text{ mm}$. Clamp Part 4 to Part 3 with **4x `M4 x 30mm` screws and nuts**: heads in the counterbores on the cover's front face, nuts in the hex pockets on the backplate's rear face. Three bolts sit in the corners; the fourth sits at $(72, 84)$ because the outlet duct runs through that corner. Let neutral-cure silicone cure and air out for several days before breathing through the device.

### Part 5: 32mm Silencer Perforated Core (`part5_silencer_perforated_core.stl`)
* **Orientation**: Print standing vertically on one of its solid $18\text{ mm}$ end cuffs.
* **Brim**: Recommended $5\text{ mm}$ outer brim for bed adhesion.
* **Supports**: **NONE**. The $3\text{ mm}$ round acoustic holes bridge cleanly without supports.
* **Assembly**: Wrap the central perforated section with 2 layers of breathable cotton cloth / old bath towel. Slide one end over the $22\text{ mm}$ outlet spigot of Part 4 using a $1\text{-}1/4\text{"}$ to $22\text{ mm}$ flexible coupler.

### Part 6: Prototype 1 Life-Safety Elbow (`part6_safety_alarm_elbow.stl`)
This file holds **four separate prints**: the elbow body, the AAV seat plate, the AAV door, and the tap cap.
* **Elbow body**: Print with the machine-side $22\text{ mm}$ male taper on the bed. Tree supports under the horizontal leg and the alarm shelf.
* **Seat plate**: Print top face down (knife-edge rim and hinge lugs facing up). No supports.
* **Door**: Print sealing face down (hinge barrel up). No supports. The sealing face comes out smooth from the bed.
* **Tap cap**: Print flat. No supports.
* **$\text{CO}_2$ vents**: 8x $2.0\text{ mm}$ holes ($25.1\text{ mm}^2$) on the collar between the valve chamber and the socket stop. They exit at $x \approx 23\text{ mm}$, well before the socket stop at $x = 36\text{ mm}$, so a fully inserted mask stem cannot cover them. They angle back toward the machine, away from the face. **Never cover the collar** with tape, the tether ring, or your hand.
* **Mask-end pressure tap**: $7.2\text{ mm}$ barb on the collar for the U-tube manometer during bench testing. Fit the tethered cap whenever the manometer is not connected; slide the tether ring over the socket (not the collar).
* **AAV door assembly**:
  1. Glue the small magnet from the Dollar-Tree window alarm into the shallow recess in the center of the door's sealing face.
  2. Thread a straightened steel safety-pin wire (~$1.0\text{ mm}$) through one seat-plate lug, the door barrel, and the other lug. Form a small torsion loop in the wire so it pushes the door **open** (away from the plate) with ~$5\text{ gf}$.
  3. Lower the door through the $22\times 22\text{ mm}$ install opening on top of the chamber and glue the seat plate onto the flat pad with neutral-cure silicone, window centered, door hanging inside the chamber.
  4. Tape or zip-tie the alarm sensor body on the shelf beside the plate, then test (step 6) and adjust its position until it is silent with the door shut and sounds with the door open.
  5. When the blower runs, pressure pushes the door **up** against the continuous $0.4\text{ mm}$ knife-edge rim (shut, magnet beside the sensor, silent). When pressure drops, the spring swings the door down into the chamber, opening the $16\times 16\text{ mm}$ ($256\text{ mm}^2$) window to room air and moving the magnet away from the sensor (siren).
  6. **Check the closing margin.** The window is $2.56\text{ cm}^2$, so pressure closes the door with about $2.6\text{ gf}$ per $\text{cmH}_2\text{O}$. The spring, the door (~$0.7\text{ g}$) and the magnet all pull it open. Weigh your magnet. With a $5\text{ gf}$ spring and a $2\text{ g}$ magnet the door needs about $3\text{ cmH}_2\text{O}$ to stay shut when the elbow points down, and less when it is sideways. Your lowest therapy pressure, minus the inhale dip, must stay above that. If the door flutters or the alarm chirps during breathing, weaken the spring or use a lighter magnet.

### Part 7: U-Tube Manometer Splash Traps & Bracket (`part7_manometer_splash_traps.stl`)
* **Orientation**: Print bulbs vertically on their bottom hose barb; print the 25 cm scale bracket flat on its back.
* **Bed Fit**: The $260\text{ mm}$ scale bracket fits when placed at a **$45^\circ$ diagonal** on a standard $220 \times 220\text{ mm}$ bed (diagonal is $311\text{ mm}$).
* **Supports**: Tree supports under bulb overhangs.
* **Assembly**: Each bulb is open top and bottom. Connect one splash-trap bulb to the static pressure tap barb on Part 4 (or on the Part 6 elbow for mask-end readings) via $1/4\text{"}$ vinyl tubing. Fill the U-tube halfway with water (+ 1 drop of food coloring). Snap both legs into the C-clips on the printed centimeter bracket; the legs run along the ruler. Mount the bracket on the outside of the bucket.

### Part 8: Intake Collar (`part8_intake_collar.stl`)
* **Orientation**: Flange down on the bed. No supports.
* **Assembly**: Glue the flange to the front face of Part 4 with neutral-cure silicone, centered on the $60\text{ mm}$ intake hole. Run a short flexible silicone hose from the collar through the bucket lid to the external MERV-13 filter box, so the blower breathes room air and never the motor air inside the bucket. This hose is under suction: every joint on it must be airtight, or it will pull in bucket air.

---

## 4. 3-Minute Precision Static Balancing Procedure

Before mounting the wheel (Part 1 + Part 2 glued together) on the motor:
1. Push a $5\text{ mm}$ steel rod or drill bit through the hub bore and lightly tighten both grub screws on it.
2. Rest the two ends of the rod horizontally across the rims of **two identical drinking glasses** on a level table.
3. Gently roll the wheel. The heavy side will roll to the bottom ($6\text{ o'clock}$).
4. Take a short snippet of raw $1.75\text{ mm}$ PETG filament (up to $4\text{ mm}$ long, $\approx 0.012\text{ g}$; the holes are $4.2\text{ mm}$ deep) and press it into one of the 24 balance holes on the **rear face** of the rim at $12\text{ o'clock}$ (the light side). Use the neighboring holes for more weight.
5. Repeat until the wheel remains completely stationary in **any rotational position** (neutral equilibrium). Secure the filament snippets with a tiny drop of superglue.

---

## 5. Blower Assembly Order

1. Bolt the motor to Part 3 (Section 3, Part 3).
2. Slide the balanced wheel onto the shaft, hub first. Set its height with a $1.5\text{ mm}$ shim (e.g. a stack of cards) between the rim and the backplate floor, then tighten both grub screws through the open front.
3. Spin the wheel by hand: nothing may touch. Design clearances are $1.5\text{ mm}$ under the rim, $3.0\text{ mm}$ under the hub, $1.5\text{ mm}$ above the shroud eye lip, $3.5\text{ mm}$ radially to the housing, and $6.3\text{ mm}$ to the scroll tongue.
4. Seal and bolt on Part 4 (Section 3, Part 4). Spin the wheel through the intake hole again; it must still turn freely.
5. Glue on Part 8.
