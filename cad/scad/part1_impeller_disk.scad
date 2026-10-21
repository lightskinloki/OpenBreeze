// OpenBreeze - Part 1: 165mm Radial-Tip Centrifugal Impeller Disk (V4.1 Hardened)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill, random seam position)

$fn = 60;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_d = 60.0;                  // Intake eye diameter (mm)
eye_r = eye_d / 2;             // 30.0 mm
base_h = 2.4;                  // Main base plate floor thickness (mm)

num_blades = 16;
blade_t = 1.8;                 // Blade wall thickness (mm)
blade_h = 10.0;                // Constant blade height across entire span (mm)
tongue_h = 1.2;                // Shroud alignment tongue height (mm)
tongue_t = 1.2;                // Shroud alignment tongue thickness (mm)

hub_d = 28.0;                  // Central hub boss diameter (mm)
hub_h = 14.0;                  // Total hub height from front face (mm)
shaft_d = 5.05;                // Motor shaft bore (mm)
flange_circle_d = 16.0;        // 5mm metal flange coupler M3 bolt circle
flange_hole_d = 3.2;           // M3 clearance hole (mm)

// Rear Balance Rim (On the BACK of the disk: leaves blade passages 100% open)
rear_rim_h = 5.0;              // Extends 5.0mm out the back of the disk
rear_rim_r_outer = 82.0;
rear_rim_r_inner = 74.0;
num_balance_holes = 24;
balance_hole_d = 1.85;         // Sized for 1.75mm PETG snippets (3.05 mg/mm)
balance_hole_depth = 4.2;      // Blind holes with 1.5mm solid floor to front
balance_circle_r = 78.0;

function blade_center(t) = 
    let(
        r = eye_r + (impeller_r - eye_r) * t,
        theta = 36.0 * (1 - pow(max(0, 1 - t), 1.8))
    )
    [r * cos(theta), r * sin(theta)];

function blade_polygon(thickness) = 
    let(
        N = 20,
        spine = [for (i = [0:N]) blade_center(i / N)],
        left = [for (i = [0:N])
            let(
                p = spine[i],
                next_p = (i < N) ? spine[i+1] : spine[i],
                prev_p = (i > 0) ? spine[i-1] : spine[i],
                d = next_p - prev_p,
                tangent_ang = atan2(d[1], d[0]),
                norm_ang = tangent_ang + 90
            )
            p + [thickness/2 * cos(norm_ang), thickness/2 * sin(norm_ang)]
        ],
        right = [for (i = [N:-1:0])
            let(
                p = spine[i],
                next_p = (i < N) ? spine[i+1] : spine[i],
                prev_p = (i > 0) ? spine[i-1] : spine[i],
                d = next_p - prev_p,
                tangent_ang = atan2(d[1], d[0]),
                norm_ang = tangent_ang - 90
            )
            p + [thickness/2 * cos(norm_ang), thickness/2 * sin(norm_ang)]
        ]
    )
    concat(left, right);

module single_blade() {
    // 2D polygon extruded vertically with constant height = 10.0mm
    linear_extrude(height = blade_h)
        polygon(points = blade_polygon(blade_t));
        
    // Alignment tongue for snap-on shroud ring
    translate([0, 0, blade_h])
        linear_extrude(height = tongue_h)
            polygon(points = blade_polygon(tongue_t));
}

module impeller_disk() {
    difference() {
        union() {
            // Main Base Plate
            cylinder(r = impeller_r, h = base_h, $fn=120);
            
            // Central Hub Boss (Front side)
            cylinder(r = hub_d/2, h = hub_h + base_h, $fn=60);
            
            // Rear Thickened Balance Rim (On the BACK side: z = -rear_rim_h to 0)
            translate([0, 0, -rear_rim_h])
                difference() {
                    cylinder(r = rear_rim_r_outer, h = rear_rim_h, $fn=120);
                    translate([0, 0, -0.1])
                        cylinder(r = rear_rim_r_inner, h = rear_rim_h + 0.2, $fn=100);
                }
            
            // 16 Constant-Height Radial-Tip Blades (Front side)
            translate([0, 0, base_h]) {
                for (i = [0:num_blades-1]) {
                    rotate([0, 0, i * (360 / num_blades)])
                        single_blade();
                }
            }
        }
        
        // Central 5.05mm shaft pass-through bore
        translate([0, 0, -rear_rim_h - 1])
            cylinder(r = shaft_d/2, h = hub_h + base_h + rear_rim_h + 2, $fn=30);
            
        // 4x M3 mounting holes for 5mm metal flange coupler (16mm bolt circle)
        for (a = [45, 135, 225, 315]) {
            rotate([0, 0, a])
                translate([flange_circle_d/2, 0, -rear_rim_h - 1])
                    cylinder(r = flange_hole_d/2, h = hub_h + base_h + rear_rim_h + 2, $fn=20);
            // Hex nut pockets on rear face
            rotate([0, 0, a])
                translate([flange_circle_d/2, 0, -rear_rim_h - 0.1])
                    cylinder(r = 3.3, h = 2.4, $fn=6);
        }
        
        // 4x Clamping slits for hub collet (if no metal coupler is used)
        for (a = [0, 90]) {
            rotate([0, 0, a])
                translate([-1.2/2, -hub_d/2 - 1, base_h])
                    cube([1.2, hub_d + 2, hub_h + 1]);
        }
        
        // 24 Blind Perimeter Balance Holes (Accessed from the REAR face)
        // Solid 1.5mm floor remains between bottom of hole and front face
        for (i = [0:num_balance_holes-1]) {
            rotate([0, 0, i * (360 / num_balance_holes)])
                translate([balance_circle_r, 0, -rear_rim_h - 0.1])
                    cylinder(r = balance_hole_d/2, h = balance_hole_depth, $fn=16);
        }
        
        // Recessed Rotation Direction Arrow (Engraved 0.6mm into top of hub boss)
        translate([0, 0, hub_h + base_h - 0.6])
            rotate([0, 0, 45])
                difference() {
                    cylinder(r = 10.0, h = 1.0, $fn=30);
                    cylinder(r = 8.0, h = 1.1, $fn=30);
                    translate([-15, -15, -0.1]) cube([15, 30, 2]);
                }
    }
}

impeller_disk();
