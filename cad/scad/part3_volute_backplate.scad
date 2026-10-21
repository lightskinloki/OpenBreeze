// OpenBreeze - Part 3: Volute Backplate with External Motor Mount (V4.1 Hardened)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)
// Outer dimensions: 205 x 205mm (fits on any 220x220mm bed)

$fn = 60;

// === PARAMETERS ===
plate_w = 205.0;               // Outer square width/length (mm)
corner_r = 15.0;               // Rounded corner radius (mm)
cavity_d = 171.0;              // Internal rotor cavity diameter (mm)
cavity_r = cavity_d / 2;       // 85.5 mm (3.0mm radial clearance to 165mm wheel)
cavity_depth = 8.0;            // Recess depth to accommodate rear balance rim (mm)
base_floor_t = 3.2;            // Solid rear wall thickness under cavity (mm)
total_plate_t = base_floor_t + cavity_depth; // 11.2 mm

// Motor Mount Specs (775 standard + Nidec 24H)
motor_boss_d = 17.8;           // 775 front bearing boss recess diameter (mm)
motor_boss_depth = 3.0;        // Boss recess depth on rear face (mm)
motor_m4_spacing = 29.0;       // 775 M4 screw center-to-center spacing (mm)
motor_m3_circle = 25.0;        // Nidec M3 screw bolt circle (mm)
shaft_pass_d = 5.8;            // Shaft pass-through hole (mm)
labyrinth_seal_d = 14.0;       // Raised positive-pressure labyrinth ring OD (mm)
labyrinth_h = 1.6;             // Labyrinth ring height (mm)

// Bolt Hole Layout (In 4 corners far outside the scroll: R = 123.7mm)
bolt_hole_d = 4.3;             // M4 clearance hole
bolt_offset = plate_w/2 - 15.0;// 87.5 mm from center

module plate_outline() {
    hull() {
        for (x = [-bolt_offset, bolt_offset])
            for (y = [-bolt_offset, bolt_offset])
                translate([x, y, 0])
                    cylinder(r = corner_r, h = total_plate_t, $fn=40);
    }
}

module volute_backplate() {
    difference() {
        union() {
            // Main 205x205mm rounded plate
            plate_outline();
            
            // External rear motor boss (protrudes 4.5mm out the back face)
            translate([0, 0, -4.5])
                cylinder(r = 25.0, h = 4.5, $fn=60);
                
            // Internal raised labyrinth seal ring around shaft hole
            translate([0, 0, base_floor_t])
                cylinder(r = labyrinth_seal_d/2, h = labyrinth_h, $fn=40);
                
            // 4x Bungee Suspension Ears (one on each corner)
            for (x = [-bolt_offset - 8, bolt_offset + 8]) {
                for (y = [-bolt_offset - 8, bolt_offset + 8]) {
                    translate([x, y, 0])
                        cylinder(r = 7.0, h = total_plate_t, $fn=24);
                }
            }
        }
        
        // Internal Rotor Cavity & Rear Balance Rim Pocket (R=85.5mm, Depth=8mm)
        translate([0, 0, base_floor_t])
            cylinder(r = cavity_r, h = cavity_depth + 1, $fn=120);
            
        // Shaft pass-through hole (5.8mm diameter)
        translate([0, 0, -10])
            cylinder(r = shaft_pass_d/2, h = 30, $fn=30);
            
        // 775 Motor front bearing boss recess on rear face (z = -4.5 to -1.5)
        translate([0, 0, -4.6])
            cylinder(r = motor_boss_d/2, h = motor_boss_depth + 0.1, $fn=40);
            
        // 775 Motor 2x M4 mounting slots (29mm spacing)
        for (x = [-motor_m4_spacing/2, motor_m4_spacing/2]) {
            translate([x, 0, -10])
                cylinder(r = 4.3/2, h = 30, $fn=20);
            // Screw head counterbore on rear face
            translate([x, 0, -4.6])
                cylinder(r = 8.5/2, h = 3.0, $fn=20);
        }
        
        // Alternative Nidec brushless 4x M3 mounting holes (25mm circle)
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([motor_m3_circle/2, 0, -10])
                    cylinder(r = 3.3/2, h = 30, $fn=16);
        }
        
        // Continuous Perimeter Gasket Groove (2.4mm wide, 1.6mm deep)
        // Positioned outside scroll (r = 97.8mm to 100.2mm, R_center = 99mm)
        translate([0, 0, total_plate_t - 1.6 + 0.01])
            difference() {
                cylinder(r = 100.2, h = 2.0, $fn=120);
                cylinder(r = 97.8, h = 2.0, $fn=120);
            }
            
        // 4x Corner Assembly Bolt Holes (M4, at x=±87.5, y=±87.5 -> R = 123.7mm)
        // ZERO interference with scroll (R <= 98mm)
        for (x = [-bolt_offset, bolt_offset]) {
            for (y = [-bolt_offset, bolt_offset]) {
                translate([x, y, -5])
                    cylinder(r = bolt_hole_d/2, h = total_plate_t + 10, $fn=20);
                // Hex nut pockets on rear face
                translate([x, y, -0.1])
                    cylinder(r = 4.1, h = 3.2, $fn=6);
            }
        }
        
        // 4x Bungee eyelet holes (6mm diameter)
        for (x = [-bolt_offset - 8, bolt_offset + 8]) {
            for (y = [-bolt_offset - 8, bolt_offset + 8]) {
                translate([x, y, -5])
                    cylinder(r = 3.0, h = total_plate_t + 10, $fn=24);
            }
        }
    }
}

volute_backplate();
