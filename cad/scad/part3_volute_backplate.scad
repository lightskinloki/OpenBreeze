// OpenBreeze - Part 3: Volute Backplate with External Motor Mount
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)

$fn = 60;

// === PARAMETERS ===
housing_w = 196.0;             // Outer square width/length (mm)
cavity_d = 171.0;              // Internal rotor cavity diameter (mm)
cavity_r = cavity_d / 2;       // 85.5 mm (3.0mm radial clearance to 165mm impeller)
base_wall = 2.8;               // Backplate floor thickness (mm)
rim_h = 10.0;                  // Perimeter rim height (mm)
flange_w = 12.0;               // Sealing flange width (mm)

// Motor Mount Specs (775 standard + Nidec 24H)
motor_boss_d = 17.8;           // 775 front bearing boss diameter (mm)
motor_boss_depth = 3.0;        // Boss recess depth (mm)
motor_m4_spacing = 29.0;       // 775 M4 screw spacing (mm)
motor_m3_circle = 25.0;        // Nidec M3 screw bolt circle (mm)
shaft_pass_d = 5.8;            // Shaft pass-through hole (mm)
labyrinth_seal_d = 14.0;       // Raised positive-pressure labyrinth ring OD (mm)
labyrinth_h = 1.6;             // Labyrinth ring height (mm)

module volute_backplate() {
    difference() {
        union() {
            // Main rounded square plate
            hull() {
                for (x = [-housing_w/2 + 15, housing_w/2 - 15])
                    for (y = [-housing_w/2 + 15, housing_w/2 - 15])
                        translate([x, y, 0])
                            cylinder(r = 15, h = base_wall + rim_h, $fn=40);
            }
            
            // External rear motor boss
            translate([0, 0, -4.5])
                cylinder(r = 24, h = 4.5, $fn=60);
                
            // Internal raised labyrinth seal ring (positive pressure bleeds OUT)
            translate([0, 0, base_wall])
                cylinder(r = labyrinth_seal_d/2, h = labyrinth_h, $fn=40);
                
            // 4x Corner Bungee Suspension Loops
            for (x = [-housing_w/2 - 4, housing_w/2 + 4]) {
                for (y = [-housing_w/2 + 35, housing_w/2 - 35]) {
                    translate([x, y, 0])
                        cylinder(r = 6, h = base_wall + rim_h, $fn=24);
                }
            }
        }
        
        // Internal rotor cavity
        translate([0, 0, base_wall])
            cylinder(r = cavity_r, h = rim_h + 1, $fn=100);
            
        // Shaft pass-through hole
        translate([0, 0, -10])
            cylinder(r = shaft_pass_d/2, h = 25, $fn=30);
            
        // 775 Motor front bearing boss recess (on rear face)
        translate([0, 0, -4.6])
            cylinder(r = motor_boss_d/2, h = motor_boss_depth + 0.1, $fn=40);
            
        // 775 Motor 2x M4 mounting slots (29mm spacing)
        for (x = [-motor_m4_spacing/2, motor_m4_spacing/2]) {
            translate([x, 0, -10])
                cylinder(r = 4.3/2, h = 25, $fn=20);
            // M4 screw head counterbore
            translate([x, 0, -4.6])
                cylinder(r = 8.0/2, h = 2.0, $fn=20);
        }
        
        // Alternative Nidec brushless 4x M3 mounting holes (25mm circle)
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([motor_m3_circle/2, 0, -10])
                    cylinder(r = 3.3/2, h = 25, $fn=16);
        }
        
        // Perimeter Gasket Groove for 100% airtight seal (2.5mm wide, 1.5mm deep)
        translate([0, 0, base_wall + rim_h - 1.5 + 0.01])
            difference() {
                cylinder(r = cavity_r + 5.0, h = 2.0, $fn=100);
                cylinder(r = cavity_r + 2.5, h = 2.0, $fn=100);
            }
            
        // 8x M3 Perimeter Flange Screws
        for (a = [0, 45, 90, 135, 180, 225, 270, 315]) {
            rotate([0, 0, a])
                translate([cavity_r + 9.0, 0, -1])
                    cylinder(r = 3.4/2, h = base_wall + rim_h + 3, $fn=16);
            // Hex nut pockets on rear
            rotate([0, 0, a])
                translate([cavity_r + 9.0, 0, -0.1])
                    cylinder(r = 3.3, h = 2.4, $fn=6);
        }
        
        // 4x Bungee eyelet holes (6mm diameter)
        for (x = [-housing_w/2 - 4, housing_w/2 + 4]) {
            for (y = [-housing_w/2 + 35, housing_w/2 - 35]) {
                translate([x, y, -1])
                    cylinder(r = 3.0, h = base_wall + rim_h + 3, $fn=20);
            }
        }
    }
}

volute_backplate();
