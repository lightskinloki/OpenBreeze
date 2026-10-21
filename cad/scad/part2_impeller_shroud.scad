// OpenBreeze - Part 2: 165mm Impeller Snap-On Front Shroud Ring
// License: GPL-3.0
// Material: PETG (prints 100% flat on build plate with zero supports)

$fn = 100;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_d = 60.0;                  // Intake eye diameter (mm)
eye_r = eye_d / 2;             // 30.0 mm
shroud_t = 1.8;                // Shroud wall thickness (mm)

num_blades = 16;
groove_w = 1.6;                // Mating groove width (mm) - accepts 1.2mm blade tongue
groove_depth = 1.0;            // Mating groove depth (mm)

module single_groove() {
    for (step = [0:20]) {
        t0 = step / 20;
        t1 = (step + 1) / 20;
        
        r0 = eye_r + (impeller_r - eye_r) * t0;
        r1 = eye_r + (impeller_r - eye_r) * t1;
        
        theta0 = 36.0 * (1 - pow(1 - t0, 1.8));
        theta1 = 36.0 * (1 - pow(1 - t1, 1.8));
        
        hull() {
            rotate([0, 0, theta0])
                translate([r0, 0, shroud_t - groove_depth])
                    cylinder(r = groove_w/2, h = groove_depth + 1, $fn=10);
            rotate([0, 0, theta1])
                translate([r1, 0, shroud_t - groove_depth])
                    cylinder(r = groove_w/2, h = groove_depth + 1, $fn=10);
        }
    }
}

module impeller_shroud() {
    difference() {
        // Main flat ring
        cylinder(r = impeller_r, h = shroud_t, $fn=120);
        
        // Central intake eye cutout
        translate([0, 0, -1])
            cylinder(r = eye_r, h = shroud_t + 2, $fn=80);
            
        // 16 Mating grooves on the underside
        for (i = [0:num_blades-1]) {
            rotate([0, 0, i * (360 / num_blades)])
                single_groove();
        }
        
        // Slight bevel on the intake eye entry to reduce turbulence
        translate([0, 0, -0.1])
            cylinder(r1 = eye_r + 1.5, r2 = eye_r, h = 1.5, $fn=80);
    }
}

impeller_shroud();
