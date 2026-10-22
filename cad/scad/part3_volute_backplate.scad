// OpenBreeze - Part 3: Volute Backplate with External Motor Mount (V4.2)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)
// Outer dimensions: 205 x 205mm (fits on any 220x220mm bed)
// Print: flat rear face DOWN on the bed (cavity facing up). No supports.
//
// Assembled reference: the rear face (z = 0) is the motor mounting face.
// The top face (z = plate_t) is the parting plane with the front cover.

$fn = 60;

// === PARAMETERS ===
plate_w = 205.0;               // Outer square width/length (mm)
corner_r = 15.0;               // Rounded corner radius (mm)
bolt_offset = plate_w/2 - 15.0;// 87.5 mm from center
plate_t = 8.4;                 // Total thickness = parting plane height (mm)

// Rotor cavity
cavity_r = 86.0;               // 3.5mm radial clearance to the 82.5mm wheel
floor_t = 3.0;                 // Floor under the balance rim (rim bottom sits 1.5mm above it)
plateau_r = 22.0;              // Raised central motor plateau
plateau_top = 6.5;             // Plateau top (hub bottom sits 3.0mm above it)

// Motor Mount Specs (775 standard + Nidec 24H)
motor_boss_d = 17.8;           // 775 front bearing boss recess diameter (mm)
motor_recess_depth = 4.5;      // Boss recess depth from the rear face (mm)
motor_m4_spacing = 29.0;       // 775 M4 screw center-to-center spacing (mm)
m4_head_d = 8.5;               // M4 screw head counterbore (from the cavity side)
m4_head_depth = 3.0;
motor_m3_circle = 25.0;        // Nidec M3 screw bolt circle (mm)
shaft_pass_d = 6.0;            // Shaft pass-through (5mm shaft; clean air bleeds OUT here)

// Gasket: sits under the front cover's solid scroll floor
gasket_r = 92.0;               // Groove centerline radius (mm)
gasket_w = 2.4;                // Groove width (mm)
gasket_depth = 1.6;            // Groove depth (mm)

// Assembly bolts (M4): three in the corners, the fourth moved off the +X+Y
// corner because the cover's outlet duct runs through it. Must match Part 4.
bolt_positions = [[-bolt_offset, -bolt_offset], [bolt_offset, -bolt_offset],
                  [-bolt_offset, bolt_offset], [72.0, 84.0]];
bolt_hole_d = 4.3;
nut_pocket_r = 4.2;            // M4 hex nut pocket (7mm across flats)
nut_pocket_depth = 3.4;

module plate_outline(h) {
    hull() {
        for (x = [-bolt_offset, bolt_offset])
            for (y = [-bolt_offset, bolt_offset])
                translate([x, y, 0])
                    cylinder(r = corner_r, h = h, $fn=40);
    }
}

module volute_backplate() {
    difference() {
        union() {
            // Main 205x205mm rounded plate (flat rear face)
            plate_outline(plate_t);

            // 4x Bungee Suspension Ears (one on each corner)
            for (x = [-bolt_offset - 8, bolt_offset + 8]) {
                for (y = [-bolt_offset - 8, bolt_offset + 8]) {
                    translate([x, y, 0])
                        cylinder(r = 7.0, h = plate_t, $fn=24);
                }
            }
        }

        // Rotor cavity above the floor, leaving the central motor plateau
        difference() {
            translate([0, 0, floor_t])
                cylinder(r = cavity_r, h = plate_t, $fn=160);
            translate([0, 0, floor_t - 1])
                cylinder(r = plateau_r, h = plateau_top - floor_t + 1, $fn=80);
        }

        // 775 Motor front bearing boss recess on the rear face
        translate([0, 0, -0.1])
            cylinder(d = motor_boss_d, h = motor_recess_depth + 0.1, $fn=48);

        // Shaft pass-through hole
        translate([0, 0, -1])
            cylinder(d = shaft_pass_d, h = plate_t + 2, $fn=30);

        // 775 Motor 2x M4 holes, heads countersunk into the plateau (cavity side)
        for (x = [-motor_m4_spacing/2, motor_m4_spacing/2]) {
            translate([x, 0, -1])
                cylinder(d = 4.3, h = plate_t + 2, $fn=20);
            translate([x, 0, plateau_top - m4_head_depth])
                cylinder(d = m4_head_d, h = plate_t, $fn=24);
        }

        // Alternative Nidec brushless 4x M3 mounting holes (25mm circle)
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([motor_m3_circle/2, 0, -1])
                    cylinder(d = 3.3, h = plate_t + 2, $fn=16);
        }

        // Continuous circular gasket groove in the top (parting) face
        translate([0, 0, plate_t - gasket_depth])
            difference() {
                cylinder(r = gasket_r + gasket_w/2, h = gasket_depth + 1, $fn=180);
                translate([0, 0, -1])
                    cylinder(r = gasket_r - gasket_w/2, h = gasket_depth + 3, $fn=180);
            }

        // 4x Assembly Bolt Holes (M4) with hex nut pockets on the rear face
        for (p = bolt_positions) {
            translate([p[0], p[1], -1])
                cylinder(d = bolt_hole_d, h = plate_t + 2, $fn=20);
            translate([p[0], p[1], -0.1])
                cylinder(r = nut_pocket_r, h = nut_pocket_depth + 0.1, $fn=6);
        }

        // 4x Bungee eyelet holes (6mm diameter)
        for (x = [-bolt_offset - 8, bolt_offset + 8]) {
            for (y = [-bolt_offset - 8, bolt_offset + 8]) {
                translate([x, y, -1])
                    cylinder(r = 3.0, h = plate_t + 2, $fn=24);
            }
        }
    }
}

volute_backplate();
