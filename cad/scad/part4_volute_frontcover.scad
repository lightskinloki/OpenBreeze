// OpenBreeze - Part 4: Volute Front Cover with Logarithmic Scroll & ISO 22mm Outlet
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)

$fn = 60;

// === PARAMETERS ===
housing_w = 196.0;             // Outer square width/length (mm)
cavity_d = 171.0;              // Internal rotor cavity diameter (mm)
cavity_r = cavity_d / 2;       // 85.5 mm
flange_h = 4.0;                // Flange thickness (mm)

// Scroll Profile (Logarithmic expansion from r=86mm at cutwater to r=104mm at outlet)
r_cutwater = 86.0;
r_outlet = 104.0;
scroll_depth = 16.0;

// Central Intake
intake_d = 60.0;
intake_r = intake_d / 2;
filter_frame_w = 72.0;         // Intake adapter collar outer width (mm)
filter_frame_h = 10.0;

// ISO 22mm CPAP Spigot (from Derek Anderson openpap.scad)
spigot_base_d = 25.0;          // 25mm outer diameter at base
spigot_tip_d = 23.0;           // 23mm outer diameter at tip (standard 22mm friction taper)
spigot_h = 22.0;               // 22mm total spigot length
spigot_bore_d = 19.0;          // 19mm inner bore
pressure_tap_d = 3.2;          // 3.2mm ID static pressure tap bore (1/8" ID tube)
pressure_barb_od = 5.2;        // 5.2mm OD barb for vinyl tubing

module volute_scroll_chamber() {
    // 360-degree expanding scroll
    for (step = [0:35]) {
        a0 = step * 10;
        a1 = (step + 1) * 10;
        t0 = step / 36;
        t1 = (step + 1) / 36;
        
        r0 = r_cutwater + (r_outlet - r_cutwater) * t0;
        r1 = r_cutwater + (r_outlet - r_cutwater) * t1;
        
        hull() {
            rotate([0, 0, a0])
                translate([r0 - 8, 0, 0])
                    cylinder(r = 8, h = scroll_depth, $fn=16);
            rotate([0, 0, a1])
                translate([r1 - 8, 0, 0])
                    cylinder(r = 8, h = scroll_depth, $fn=16);
        }
    }
}

module volute_frontcover() {
    difference() {
        union() {
            // Main rounded square plate matching backplate
            hull() {
                for (x = [-housing_w/2 + 15, housing_w/2 - 15])
                    for (y = [-housing_w/2 + 15, housing_w/2 - 15])
                        translate([x, y, 0])
                            cylinder(r = 15, h = flange_h + scroll_depth, $fn=40);
            }
            
            // Central intake collar for filter attachment
            translate([0, 0, flange_h + scroll_depth]) {
                cylinder(r = intake_r + 4, h = filter_frame_h, $fn=80);
                // Rectangular filter dock tabs
                translate([-filter_frame_w/2, -filter_frame_w/2, 0])
                    cube([filter_frame_w, filter_frame_w, 3]);
            }
            
            // Tangential Outlet Spout extending off top-right
            translate([r_outlet - 2, 60, flange_h]) {
                rotate([0, 90, 0]) {
                    // Outlet nozzle body
                    cylinder(r1 = 15, r2 = spigot_base_d/2, h = 18, $fn=40);
                    // Standard ISO 22mm conical CPAP taper
                    translate([0, 0, 18])
                        cylinder(r1 = spigot_base_d/2, r2 = spigot_tip_d/2, h = spigot_h, $fn=40);
                }
            }
            
            // Integrated Static Pressure Tap Barb on outlet base
            translate([r_outlet + 6, 60 - spigot_base_d/2 - 2, flange_h + 8]) {
                rotate([-90, 0, 0])
                    cylinder(r1 = pressure_barb_od/2, r2 = pressure_barb_od/2 - 0.4, h = 12, $fn=20);
            }
        }
        
        // Internal Expanding Scroll Cavity
        translate([0, 0, flange_h])
            volute_scroll_chamber();
            
        // Central Intake Bellmouth (Smooth curved entry)
        translate([0, 0, -1])
            cylinder(r = intake_r, h = flange_h + scroll_depth + filter_frame_h + 3, $fn=80);
        translate([0, 0, flange_h - 0.1])
            cylinder(r1 = intake_r + 4, r2 = intake_r, h = 3, $fn=80);
            
        // Tangential Outlet Nozzle Bore
        translate([r_outlet - 2, 60, flange_h]) {
            rotate([0, 90, 0])
                translate([0, 0, -5])
                    cylinder(r = spigot_bore_d/2, h = 18 + spigot_h + 10, $fn=40);
        }
        
        // Internal Static Pressure Tap Tunnel (feeds manometer)
        translate([r_outlet + 6, 60 - 2, flange_h + 8]) {
            rotate([-90, 0, 0])
                cylinder(r = pressure_tap_d/2, h = 20, $fn=16);
            // Tunnel through wall into spigot bore
            rotate([0, 0, 0])
                translate([0, -10, 0])
                    cylinder(r = pressure_tap_d/2, h = 12, $fn=16);
        }
        
        // Raised Gasket Ridge mating with backplate groove
        // (Leaves room for silicone seal)
        
        // 8x M3 Perimeter Flange Screws (matching backplate)
        for (a = [0, 45, 90, 135, 180, 225, 270, 315]) {
            rotate([0, 0, a])
                translate([cavity_r + 9.0, 0, -1])
                    cylinder(r = 3.4/2, h = flange_h + scroll_depth + 3, $fn=16);
            // Screw head counterbore on front
            rotate([0, 0, a])
                translate([cavity_r + 9.0, 0, flange_h + scroll_depth - 3])
                    cylinder(r = 6.0/2, h = 4, $fn=20);
        }
    }
}

volute_frontcover();
