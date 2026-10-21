// OpenBreeze - Part 1: 165mm Radial-Tip Centrifugal Impeller Disk
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill, random seam position)

$fn = 60;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_d = 60.0;                  // Intake eye diameter (mm)
eye_r = eye_d / 2;             // 30.0 mm
base_h = 2.4;                  // Base plate thickness (mm)

num_blades = 16;
blade_t = 1.8;                 // Blade wall thickness (mm)
blade_h_eye = 12.0;            // Blade height at intake eye (mm)
blade_h_tip = 8.0;             // Blade height at outer tip (mm)
tongue_h = 1.0;                // Shroud alignment tongue height (mm)
tongue_w = 1.2;                // Shroud alignment tongue width (mm)

hub_d = 28.0;                  // Central hub boss diameter (mm)
hub_h = 14.0;                  // Total hub height from base (mm)
shaft_d = 5.05;                // Motor shaft bore (mm)
flange_circle_d = 16.0;        // 5mm metal flange coupler M3 bolt circle
flange_hole_d = 3.2;           // M3 clearance hole (mm)

num_balance_holes = 24;
balance_hole_d = 1.85;         // Sized for 1.75mm PETG filament snippets
balance_hole_depth = 8.0;
balance_circle_r = 78.0;       // Near outer rim

module single_blade() {
    // 2D curved blade section extruded with height slope
    // Curvature: 30 deg inducer at eye (r=30) smoothly transitioning to radial (90 deg) at r=82.5
    for (step = [0:20]) {
        t0 = step / 20;
        t1 = (step + 1) / 20;
        
        r0 = eye_r + (impeller_r - eye_r) * t0;
        r1 = eye_r + (impeller_r - eye_r) * t1;
        
        // Logarithmic/parabolic angle curve: theta = A * (1 - (1-t)^1.8)
        theta0 = 36.0 * (1 - pow(1 - t0, 1.8));
        theta1 = 36.0 * (1 - pow(1 - t1, 1.8));
        
        h0 = blade_h_eye - (blade_h_eye - blade_h_tip) * t0;
        h1 = blade_h_eye - (blade_h_eye - blade_h_tip) * t1;
        
        hull() {
            rotate([0, 0, theta0])
                translate([r0, 0, 0])
                    cylinder(r = blade_t/2, h = h0, $fn=12);
            rotate([0, 0, theta1])
                translate([r1, 0, 0])
                    cylinder(r = blade_t/2, h = h1, $fn=12);
        }
        
        // Alignment tongue for snap-on shroud ring
        hull() {
            rotate([0, 0, theta0])
                translate([r0, 0, h0])
                    cylinder(r = tongue_w/2, h = tongue_h, $fn=8);
            rotate([0, 0, theta1])
                translate([r1, 0, h1])
                    cylinder(r = tongue_w/2, h = tongue_h, $fn=8);
        }
    }
}

module impeller_disk() {
    difference() {
        union() {
            // Base plate
            cylinder(r = impeller_r, h = base_h, $fn=120);
            
            // Central hub boss
            cylinder(r = hub_d/2, h = hub_h, $fn=60);
            
            // 16 Curved Radial-Tip Blades
            translate([0, 0, base_h]) {
                for (i = [0:num_blades-1]) {
                    rotate([0, 0, i * (360 / num_blades)])
                        single_blade();
                }
            }
        }
        
        // Central 5mm shaft pass-through hole
        translate([0, 0, -1])
            cylinder(r = shaft_d/2, h = hub_h + 3, $fn=30);
            
        // 4x M3 mounting holes for standard 5mm metal flange coupler
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([flange_circle_d/2, 0, -1])
                    cylinder(r = flange_hole_d/2, h = hub_h + 3, $fn=20);
            // Hex nut pockets on underside
            rotate([0, 0, a])
                translate([flange_circle_d/2, 0, -0.1])
                    cylinder(r = 3.3, h = 2.2, $fn=6);
        }
        
        // 4x Clamping slits for hub collet (if no metal coupler is used)
        for (a = [0, 90]) {
            rotate([0, 0, a])
                translate([-1.2/2, -hub_d/2 - 1, base_h])
                    cube([1.2, hub_d + 2, hub_h]);
        }
        
        // 24 Perimeter Balance Holes (sized for 1.75mm PETG snippets = 3.05 mg/mm)
        for (i = [0:num_balance_holes-1]) {
            rotate([0, 0, i * (360 / num_balance_holes)])
                translate([balance_circle_r, 0, base_h - balance_hole_depth + 0.1])
                    cylinder(r = balance_hole_d/2, h = balance_hole_depth + 1, $fn=16);
        }
    }
}

impeller_disk();
