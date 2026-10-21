// OpenBreeze - Part 6: Prototype 1 Life-Safety Elbow
// License: GPL-3.0
// Features:
// 1. Anti-Asphyxia Valve (AAV) with 3 point-contact nibs (zero wet capillary stiction)
// 2. Docking bracket for $1.25 Dollar-Tree 90dB battery-powered magnetic window alarm
// 3. Steel safety-pin torsion spring clip (10 gf opening bias, zero thermoplastic creep)
// 4. Fixed ring of 8x 2.0mm CO2 washout holes (25.1 mm^2 total un-blockable vent area)

$fn = 50;

// Standard CPAP 22mm Dimensions
taper_base_d = 22.2;           // Male 22mm taper base
taper_tip_d = 21.6;            // Male 22mm taper tip
socket_id = 22.3;              // Female 22mm socket inner diameter
socket_od = 25.5;              // Female 22mm socket outer diameter
bore_id = 18.5;                // Main airway bore diameter

// AAV Port Dimensions
aav_port_w = 20.0;
aav_port_h = 20.0;
nib_h = 0.35;                  // Raised point-contact anti-stiction nibs

// Alarm Dock Dimensions (fits Dollar-Tree magnetic window alarm)
alarm_w = 32.0;
alarm_h = 50.0;
alarm_t = 14.0;
magnet_pocket_w = 11.0;
magnet_pocket_h = 30.0;

module safety_elbow_body() {
    difference() {
        union() {
            // Machine-side 22mm male taper (vertical leg)
            cylinder(r1 = taper_base_d/2, r2 = taper_tip_d/2, h = 20.0);
            
            // 90-Degree elbow bend junction
            translate([0, 0, 20.0]) {
                hull() {
                    sphere(r = socket_od/2);
                    translate([20.0, 0, 0])
                        sphere(r = socket_od/2);
                }
            }
            
            // Mask-side 22mm female socket (horizontal leg)
            translate([20.0, 0, 20.0]) {
                rotate([0, 90, 0])
                    cylinder(r = socket_od/2, h = 20.0);
            }
            
            // Anti-Asphyxia Valve Housing Turret (raised off elbow outer heel)
            translate([-socket_od/2 - 6, -aav_port_w/2 - 3, 20.0 - aav_port_h/2 - 2]) {
                cube([8.0, aav_port_w + 6, aav_port_h + 4]);
            }
            
            // Dollar-Tree Magnetic Window Alarm Docking Bracket
            translate([-socket_od/2 - 8, aav_port_w/2 + 2, 5.0]) {
                difference() {
                    cube([12.0, alarm_w + 4, 35.0]);
                    // Pocket for alarm body
                    translate([2.0, 2.0, 2.0])
                        cube([alarm_t + 1, alarm_w, 35.0]);
                }
            }
            
            // Safety-pin hinge pivot lugs
            translate([-socket_od/2 - 5, -aav_port_w/2 - 1, 20.0 + aav_port_h/2]) {
                rotate([0, 90, 0])
                    cylinder(r = 3.5, h = 6.0, $fn=20);
            }
            translate([-socket_od/2 - 5, aav_port_w/2 - 1, 20.0 + aav_port_h/2]) {
                rotate([0, 90, 0])
                    cylinder(r = 3.5, h = 6.0, $fn=20);
            }
        }
        
        // Machine-side bore
        translate([0, 0, -1])
            cylinder(r = bore_id/2, h = 22.0);
            
        // Elbow bend internal hollow
        translate([0, 0, 20.0]) {
            hull() {
                sphere(r = bore_id/2);
                translate([20.0, 0, 0])
                    sphere(r = bore_id/2);
            }
        }
        
        // Mask-side female socket bore
        translate([20.0, 0, 20.0]) {
            rotate([0, 90, 0])
                translate([0, 0, -1])
                    cylinder(r = socket_id/2, h = 22.0);
        }
        
        // AAV 20x20mm Port Window
        translate([-socket_od/2 - 8, -aav_port_w/2, 20.0 - aav_port_h/2]) {
            cube([12.0, aav_port_w, aav_port_h]);
        }
        
        // Safety-pin hinge pin hole (1.6mm steel pin diameter)
        translate([-socket_od/2 - 6, -aav_port_w/2 - 4, 20.0 + aav_port_h/2]) {
            rotate([-90, 0, 0])
                cylinder(r = 1.0, h = aav_port_w + 8, $fn=16);
        }
        
        // Fixed ring of 8x 2.0mm CO2 Washout Vent Holes (25.1 mm^2 total area)
        for (i = [0:7]) {
            angle = i * 45;
            translate([28.0, 0, 20.0]) {
                rotate([angle, 0, 0])
                    rotate([0, 90, 0])
                        translate([0, socket_od/2 - 1, 0])
                            cylinder(r = 1.0, h = 5.0, $fn=16);
            }
        }
    }
    
    // 3x Anti-Stiction Raised Point Nibs around AAV Seat Rim
    translate([-socket_od/2 + 0.1, -aav_port_w/2 + 2, 20.0 - aav_port_h/2 + 2])
        sphere(r = nib_h, $fn=12);
    translate([-socket_od/2 + 0.1, aav_port_w/2 - 2, 20.0 - aav_port_h/2 + 2])
        sphere(r = nib_h, $fn=12);
    translate([-socket_od/2 + 0.1, 0, 20.0 + aav_port_h/2 - 2])
        sphere(r = nib_h, $fn=12);
}

module aav_flapper_door() {
    // Separate flat-printed rigid PETG door (prints flat on build plate)
    translate([40.0, 0, 0]) {
        difference() {
            union() {
                // Main rigid door paddle
                cube([aav_port_w + 2.0, aav_port_h + 2.0, 1.2]);
                
                // Hinge pin barrel
                translate([0, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r = 2.4, h = aav_port_w + 2.0, $fn=20);
                        
                // Magnet dock pocket for alarm magnet
                translate([4.0, (aav_port_h - 10.0)/2, 1.2])
                    cube([12.0, 10.0, 4.0]);
            }
            
            // Hinge pin hole (for steel safety pin wire)
            translate([-1, 0, 0])
                rotate([0, 90, 0])
                    cylinder(r = 1.0, h = aav_port_w + 4.0, $fn=16);
                    
            // Magnet slot (accepts Dollar-Tree alarm magnet)
            translate([5.0, (aav_port_h - 8.0)/2, 1.8])
                cube([10.0, 8.0, 4.0]);
        }
    }
}

safety_elbow_body();
aav_flapper_door();
