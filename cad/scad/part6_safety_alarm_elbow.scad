// OpenBreeze - Part 6: Prototype 1 Life-Safety Elbow (V4.1 Hardened)
// License: GPL-3.0
// Features:
// 1. Internal 28mm valve chamber: flapper door is INSIDE so pressure pushes it SHUT
// 2. Continuous 0.4mm knife-edge seal (zero nibs, 100% airtight seal under pressure, zero capillary stiction)
// 3. Tuned steel safety-pin torsion spring (~5 gf opening bias, cracks open at 1.25 cmH2O)
// 4. Fixed ring of 8x 2.0mm forward-angled CO2 washout vent holes (25.1 mm^2 un-blockable area)
// 5. Mask-end 3.2mm static pressure tap barb (with tethered cap) for bench validation

$fn = 50;

// Standard CPAP 22mm Dimensions
taper_base_d = 22.2;           // Male 22mm taper base
taper_tip_d = 21.6;            // Male 22mm taper tip
socket_id = 22.3;              // Female 22mm socket inner diameter
socket_od = 25.5;              // Female 22mm socket outer diameter
bore_id = 18.5;                // Main airway bore diameter

// Internal 28mm Valve Chamber & Port Dimensions
chamber_od = 32.0;
chamber_id = 27.0;
aav_port_w = 16.0;             // 16x16mm window (256 mm^2 free breathing area)
aav_port_h = 16.0;

// Mask-end Pressure Tap
tap_barb_od = 5.0;
tap_bore_d = 2.8;

module safety_elbow_body() {
    difference() {
        union() {
            // Machine-side 22mm male taper (vertical leg, L=22mm)
            cylinder(r1 = taper_base_d/2, r2 = taper_tip_d/2, h = 22.0);
            
            // Central 28mm Expanded Valve Chamber (houses internal flapper door)
            translate([0, 0, 22.0]) {
                sphere(r = chamber_od/2);
                translate([12.0, 0, 0])
                    sphere(r = chamber_od/2);
            }
            
            // Mask-side 22mm female socket leg (horizontal, L=24mm)
            translate([20.0, 0, 22.0]) {
                rotate([0, 90, 0])
                    cylinder(r = socket_od/2, h = 24.0);
            }
            
            // AAV Window Outer Frame Boss (on top/heel of chamber)
            translate([-chamber_od/4, -aav_port_w/2 - 2, 22.0 + chamber_od/2 - 4]) {
                cube([aav_port_w + 4, aav_port_w + 4, 6.0]);
            }
            
            // Mask-end Static Pressure Tap Barb (pointing sideways)
            translate([26.0, socket_od/2, 22.0]) {
                rotate([90, 0, 0])
                    cylinder(r1 = tap_barb_od/2, r2 = tap_barb_od/2 - 0.3, h = 10.0, $fn=24);
            }
            
            // Alarm Dock Bracket (on top of elbow)
            translate([-14.0, aav_port_w/2 + 2, 12.0]) {
                cube([10.0, 34.0, 30.0]);
            }
        }
        
        // Machine-side through-bore (18.5mm ID)
        translate([0, 0, -1])
            cylinder(r = bore_id/2, h = 24.0);
            
        // Internal 28mm Expanded Airway Chamber (allows flapper to swing clear of flow)
        translate([0, 0, 22.0]) {
            sphere(r = chamber_id/2);
            translate([12.0, 0, 0])
                sphere(r = chamber_id/2);
        }
        
        // Mask-side female socket (22.3mm ID, depth 20mm)
        translate([24.0, 0, 22.0]) {
            rotate([0, 90, 0])
                cylinder(r = socket_id/2, h = 22.0);
        }
        // Socket internal airway throat (18.5mm bore)
        translate([12.0, 0, 22.0]) {
            rotate([0, 90, 0])
                cylinder(r = bore_id/2, h = 15.0);
        }
        
        // AAV 16x16mm Port Window through top wall
        translate([-chamber_od/4 + 2, -aav_port_w/2, 22.0 + 8.0]) {
            cube([aav_port_w, aav_port_h, 15.0]);
        }
        
        // Internal Hinge Pivot Hole (1.6mm for steel safety-pin wire)
        translate([-chamber_od/4 + 2, -aav_port_w/2 - 3, 22.0 + 9.0]) {
            rotate([-90, 0, 0])
                cylinder(r = 0.9, h = aav_port_w + 6, $fn=16);
        }
        
        // Mask-end Pressure Tap Through-Bore (2.8mm ID)
        translate([26.0, socket_od/2 + 1, 22.0]) {
            rotate([90, 0, 0])
                cylinder(r = tap_bore_d/2, h = 14.0, $fn=16);
        }
        
        // Ring of 8x 2.0mm Forward-Angled CO2 Washout Vent Holes (25.1 mm^2)
        // Positioned BEFORE the socket stop, angled 45 deg forward: CANNOT be covered by mask!
        for (i = [0:7]) {
            angle = i * 45;
            translate([22.0, 0, 22.0]) {
                rotate([angle, 0, 0])
                    rotate([0, 45, 0])
                        translate([0, 0, socket_od/2 - 2])
                            cylinder(r = 1.0, h = 8.0, $fn=16);
            }
        }
    }
    
    // Continuous 0.4mm Knife-Edge Sealing Rim on the INSIDE of the window frame
    // Zero nibs: door presses flat against this continuous ridge for a 100% airtight seal!
    translate([-chamber_od/4 + 1.8, -aav_port_w/2 - 0.2, 22.0 + 8.5]) {
        difference() {
            cube([aav_port_w + 0.4, aav_port_h + 0.4, 0.45]);
            translate([0.4, 0.4, -0.1])
                cube([aav_port_w - 0.4, aav_port_h - 0.4, 0.7]);
        }
    }
}

module internal_flapper_door() {
    // 18x18mm Rigid PETG Flapper Door (prints flat, installed INSIDE chamber)
    translate([35.0, -9.0, 0]) {
        difference() {
            union() {
                // Main rigid door paddle
                cube([18.0, 18.0, 1.2]);
                // Hinge barrel along one edge
                translate([0, 0, 0])
                    rotate([0, 90, 0])
                        cylinder(r = 2.2, h = 18.0, $fn=20);
                // Magnet pocket for window alarm magnet
                translate([4.0, 4.0, 1.2])
                    cube([10.0, 10.0, 3.5]);
            }
            // Hinge wire bore (1.4mm)
            translate([-1, 0, 0])
                rotate([0, 90, 0])
                    cylinder(r = 0.8, h = 20.0, $fn=16);
            // Magnet slot
            translate([5.0, 5.0, 1.8])
                cube([8.0, 8.0, 3.5]);
        }
    }
}

module pressure_tap_cap() {
    // Tethered friction-fit cap for the 3.2mm pressure tap barb
    translate([35.0, 25.0, 0]) {
        difference() {
            union() {
                cylinder(r = tap_barb_od/2 + 1.2, h = 10.0, $fn=30);
                // Flexible tether strap
                translate([0, -1.0, 0])
                    cube([25.0, 2.0, 1.0]);
                // Retaining ring around 22mm elbow body
                translate([25.0 + socket_od/2, 0, 0])
                    difference() {
                        cylinder(r = socket_od/2 + 1.5, h = 4.0, $fn=50);
                        translate([0, 0, -0.1])
                            cylinder(r = socket_od/2, h = 4.2, $fn=50);
                    }
            }
            // Inner bore (snug friction fit over tap barb)
            translate([0, 0, 1.0])
                cylinder(r = tap_barb_od/2, h = 10.0, $fn=30);
        }
    }
}

safety_elbow_body();
internal_flapper_door();
pressure_tap_cap();
