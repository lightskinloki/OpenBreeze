// OpenBreeze - Part 4: Volute Front Cover with Corner-Exiting Scroll & ISO 22mm Outlet (V4.1 Hardened)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)
// Outer dimensions: 205 x 205mm (fits on any 220x220mm bed)

$fn = 60;

// === PARAMETERS ===
plate_w = 205.0;               // Outer square width/length (mm)
corner_r = 15.0;               // Rounded corner radius (mm)
bolt_offset = plate_w/2 - 15.0;// 87.5 mm from center
bolt_hole_d = 4.3;             // M4 clearance hole

// Rotor Cavity & Scroll Geometry (Unified open chamber, zero dividing wall)
cavity_d = 171.0;              // 171mm inner rotor chamber diameter
cavity_r = cavity_d / 2;       // 85.5 mm
cavity_depth = 13.0;           // Rotor chamber depth (mm) (accommodates 10mm blades + 1.8mm shroud + clearances)
front_wall_t = 3.2;            // Solid front face wall thickness (mm)
total_cover_t = front_wall_t + cavity_depth; // 16.2 mm

r_cutwater = 90.0;             // Cutwater radius (gives 6.6mm acoustic gap to 83.4mm blade tip)
r_outlet = 96.0;               // Maximum scroll radius at outlet tangent (x=96mm)

// Central Intake Port
intake_id = 60.0;              // 60mm clear inner intake diameter
intake_r = intake_id / 2;      // 30.0 mm
intake_collar_od = 64.0;       // Beaded collar OD for flexible silicone decoupling hose
intake_collar_h = 16.0;        // Collar height above front face (mm)

// ISO 22mm CPAP Spigot (standard 22mm friction taper)
spigot_base_d = 25.0;          // 25mm outer diameter at base
spigot_tip_d = 23.0;           // 23mm outer diameter at tip
spigot_h = 22.0;               // 22mm spigot length
spigot_bore_d = 19.0;          // 19mm inner bore
nozzle_z = 10.0;               // Vertical centerline of nozzle
pressure_tap_d = 3.2;          // 3.2mm ID static pressure tap bore
pressure_barb_od = 5.2;        // 5.2mm OD barb for vinyl tubing

module plate_outline() {
    hull() {
        for (x = [-bolt_offset, bolt_offset])
            for (y = [-bolt_offset, bolt_offset])
                translate([x, y, 0])
                    cylinder(r = corner_r, h = total_cover_t, $fn=40);
    }
}

// 2D Profile of the expanding logarithmic scroll channel (simple, non-self-intersecting)
function scroll_2d_pts() = 
    let(
        N = 36,
        ang0 = 35.0,
        // Outer spiral boundary from ang0 to 360 deg
        outer = [for (i = [0:N])
            let(
                t = i / N,
                ang = ang0 + t * (360.0 - ang0),
                r = r_cutwater + (r_outlet - r_cutwater) * t
            )
            [r * cos(ang), r * sin(ang)]
        ],
        // Straight extension along +Y for tangential nozzle entrance
        tangent_ext = [
            [r_outlet, 45.0],
            [r_outlet - spigot_bore_d, 45.0]
        ],
        // Inner circle return
        inner = [for (i = [N:-1:0])
            let(
                t = i / N,
                ang = ang0 + t * (360.0 - ang0)
            )
            [cavity_r * cos(ang), cavity_r * sin(ang)]
        ]
    )
    concat(outer, tangent_ext, inner);

module unified_scroll_chamber() {
    // 1. Central Rotor Cavity (R=85.5mm, Depth=13mm)
    cylinder(r = cavity_r, h = cavity_depth + 1, $fn=80);
    
    // 2. Expanding Spiral Scroll Channel (extruded 2D polygon: 100% manifold)
    linear_extrude(height = cavity_depth + 1)
        polygon(points = scroll_2d_pts());
}

module volute_frontcover() {
    difference() {
        union() {
            // Main 205x205mm rounded plate
            plate_outline();
            
            // Central Flexible Intake Collar (overlaps 0.2mm into plate for perfect boolean union)
            translate([0, 0, total_cover_t - 0.2]) {
                cylinder(r = intake_collar_od/2, h = intake_collar_h + 0.2, $fn=80);
                // Retaining barb rib for hose clamp
                translate([0, 0, intake_collar_h - 4.0])
                    cylinder(r = intake_collar_od/2 + 1.2, h = 2.5, $fn=80);
            }
            
            // Tangential Outlet Nozzle Body extending toward top corner (+Y at x=96mm)
            translate([r_outlet - spigot_bore_d/2, 45.0, 0]) {
                hull() {
                    cube([spigot_bore_d + 6, 25.0, total_cover_t]);
                    translate([spigot_bore_d/2, 40.0, nozzle_z])
                        rotate([-90, 0, 0])
                            cylinder(r = spigot_base_d/2, h = 1.0, $fn=40);
                }
            }
            // Standard ISO 22mm Tapered Spigot (overlaps 0.5mm into nozzle body)
            translate([r_outlet - spigot_bore_d/2 + spigot_bore_d/2, 84.5, nozzle_z]) {
                rotate([-90, 0, 0])
                    cylinder(r1 = spigot_base_d/2, r2 = spigot_tip_d/2, h = spigot_h + 0.5, $fn=40);
            }
            
            // Integrated Static Pressure Tap Barb (3.2mm ID, 5.2mm OD)
            translate([r_outlet - spigot_base_d - 1.0, 80.0, nozzle_z]) {
                rotate([0, -90, 0])
                    cylinder(r1 = pressure_barb_od/2, r2 = pressure_barb_od/2 - 0.4, h = 12.0, $fn=24);
            }
        }
        
        // UNIFIED INTERNAL ROTOR CAVITY & EXPANDING SCROLL (One open chamber!)
        translate([0, 0, -0.1])
            unified_scroll_chamber();
            
        // Central Intake Bellmouth (Smooth 60mm through-bore)
        translate([0, 0, -1])
            cylinder(r = intake_r, h = total_cover_t + intake_collar_h + 5, $fn=80);
            
        // Intake Labyrinth Gap (1.2mm radial clearance for spinning shroud lip)
        translate([0, 0, -0.1])
            cylinder(r = intake_r + 2.8, h = 3.0, $fn=80);
            
        // Tangential Outlet Nozzle Through-Bore (19mm smooth airway)
        translate([r_outlet - spigot_bore_d/2 + spigot_bore_d/2, 35.0, nozzle_z]) {
            rotate([-90, 0, 0])
                cylinder(r = spigot_bore_d/2, h = 80.0, $fn=40);
        }
        
        // Internal Static Pressure Tap Tunnel (feeds vinyl manometer tube)
        translate([r_outlet - spigot_base_d - 2.0, 80.0, nozzle_z]) {
            rotate([0, 90, 0])
                cylinder(r = pressure_tap_d/2, h = 20.0, $fn=16);
        }
        
        // Perimeter Gasket Mating Groove (matches backplate at R = 99mm)
        translate([0, 0, -0.1])
            difference() {
                cylinder(r = 100.2, h = 1.6, $fn=120);
                cylinder(r = 97.8, h = 1.7, $fn=120);
            }
            
        // 4x Corner Assembly Bolt Holes (M4, at x=±87.5, y=±87.5 -> R = 123.7mm)
        for (x = [-bolt_offset, bolt_offset]) {
            for (y = [-bolt_offset, bolt_offset]) {
                translate([x, y, -5])
                    cylinder(r = bolt_hole_d/2, h = total_cover_t + 10, $fn=20);
                // Counterbore for M4 screw heads on front face
                translate([x, y, total_cover_t - 3.5])
                    cylinder(r = 8.5/2, h = 4.0, $fn=20);
            }
        }
        
        // Recessed Rotation Direction Arrow (Engraved 0.6mm into front face)
        translate([0, 0, total_cover_t - 0.6])
            rotate([0, 0, 90])
                difference() {
                    cylinder(r = 45.0, h = 1.0, $fn=60);
                    cylinder(r = 42.0, h = 1.1, $fn=60);
                    translate([-60, -60, -0.1]) cube([60, 120, 2]);
                }
    }
}

volute_frontcover();
