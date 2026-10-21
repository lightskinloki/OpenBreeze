// OpenBreeze - Part 7: U-Tube Water Manometer Anti-Blowout Splash Traps & Bracket
// License: GPL-3.0
// Material: PETG
// Purpose: Prevents coughing/sneezing from blowing water out of the manometer tube;
// holds the clear vinyl U-tube against the side of the 5-gallon bucket with 0-25 cm scale.

$fn = 50;

tube_od = 9.5;                 // 3/8" (9.5mm) outer diameter of 1/4" ID vinyl tubing
tube_id = 6.35;                // 1/4" (6.35mm) inner diameter
bulb_od = 28.0;                // 28mm outer diameter of catch bulb
bulb_h = 36.0;                 // 36mm catch bulb height (~20 mL catch volume)
barb_od = 7.2;                 // Hose barb for 1/4" ID tubing

module splash_trap_bulb() {
    difference() {
        union() {
            // Main bulb body
            hull() {
                sphere(r = bulb_od/2);
                translate([0, 0, bulb_h - bulb_od])
                    sphere(r = bulb_od/2);
            }
            // Bottom tube barb (connects to U-tube)
            translate([0, 0, -bulb_od/2 - 12.0])
                cylinder(r1 = barb_od/2, r2 = barb_od/2 - 0.4, h = 12.0, $fn=30);
            // Top atmospheric vent / line barb
            translate([0, 0, bulb_h - bulb_od/2])
                cylinder(r1 = barb_od/2, r2 = barb_od/2 - 0.4, h = 12.0, $fn=30);
        }
        
        // Internal hollow chamber
        hull() {
            sphere(r = bulb_od/2 - 2.0);
            translate([0, 0, bulb_h - bulb_od])
                sphere(r = bulb_od/2 - 2.0);
        }
        
        // Bottom barb through-bore
        translate([0, 0, -bulb_od/2 - 13.0])
            cylinder(r = 2.5, h = 15.0, $fn=20);
            
        // Top barb through-bore
        translate([0, 0, bulb_h - bulb_od/2 - 1.0])
            cylinder(r = 2.5, h = 15.0, $fn=20);
    }
    
    // Internal Baffle Umbrella (catches sudden airborne water droplets)
    translate([0, 0, bulb_h/2 - bulb_od/4]) {
        difference() {
            cylinder(r1 = 3.0, r2 = bulb_od/2 - 3.5, h = 4.0, $fn=30);
            // 4x bypass slots for air to pass around baffle
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    translate([bulb_od/4, -2.0, -1])
                        cube([bulb_od/2, 4.0, 6.0]);
            }
        }
    }
}

module manometer_centimeter_scale_bracket() {
    // 25 cm ruler backing bracket that clips to the side of the 5-gallon bucket
    translate([45.0, -15.0, 0]) {
        difference() {
            union() {
                // Backing plate
                cube([30.0, 260.0, 3.0]);
                // Dual tube clips (holds U-tube legs spaced 16mm apart)
                for (z = [30, 80, 130, 180, 230]) {
                    translate([7.0, z, 3.0]) {
                        // Left tube clamp
                        difference() {
                            cylinder(r = tube_od/2 + 1.6, h = 8.0, $fn=30);
                            translate([0, 0, -1])
                                cylinder(r = tube_od/2, h = 10.0, $fn=30);
                            translate([-tube_od/2 - 2, tube_od/4, -1])
                                cube([tube_od + 4, tube_od, 10.0]); // Snap opening
                        }
                        // Right tube clamp
                        translate([16.0, 0, 0]) {
                            difference() {
                                cylinder(r = tube_od/2 + 1.6, h = 8.0, $fn=30);
                                translate([0, 0, -1])
                                    cylinder(r = tube_od/2, h = 10.0, $fn=30);
                                translate([-tube_od/2 - 2, tube_od/4, -1])
                                    cube([tube_od + 4, tube_od, 10.0]); // Snap opening
                            }
                        }
                    }
                }
            }
            
            // Centimeter tick marks (0 to 25 cm engraved into face)
            for (cm = [0:25]) {
                y_pos = 10.0 + cm * 10.0;
                mark_len = (cm % 5 == 0) ? 10.0 : 5.0;
                translate([1.0, y_pos, 2.2])
                    cube([mark_len, 0.8, 1.0]);
            }
            
            // 2x Bucket rim clip holes / zip-tie slots
            translate([10.0, 5.0, -1])
                cube([10.0, 3.0, 5.0]);
            translate([10.0, 252.0, -1])
                cube([10.0, 3.0, 5.0]);
        }
    }
}

splash_trap_bulb();
translate([0, 45.0, 0]) splash_trap_bulb(); // Second catch bulb for return leg
manometer_centimeter_scale_bracket();
