// OpenBreeze - Part 1: 165mm Radial-Tip Centrifugal Impeller Disk (V4.2)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill, random seam position)
// Print: rear balance rim down on the bed, blades UP. No supports.
//
// ROTATION: COUNTERCLOCKWISE seen from the intake (front) side, to match the
// volute scroll in Part 4. The blade inlets lean into that direction; the
// blade tips are radial (90 deg).
//
// Shaft mount: two opposed M3 grub screws in captive nuts, tightened from the
// front through the intake eye. Needs >= 16 mm of 5 mm shaft protruding past
// the motor's mounting face (see PRINT_AND_SLICING_GUIDE.md).

$fn = 60;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_r = 30.0;                  // Intake eye radius (mm)
base_h = 2.4;                  // Base plate thickness (mm)

num_blades = 16;
blade_t = 1.8;                 // Blade wall thickness (mm)
blade_h = 10.0;                // Constant blade height across entire span (mm)
blade_sink = 0.2;              // Blades start 0.2mm inside the base so they fuse into one solid
blade_sweep = -36.0;           // Inlet sweep (deg). Negative = inlet leads in the CCW rotation direction
tongue_h = 0.9;                // Sits in the 1.0mm shroud groove, so the shroud bears on the blade tops
tongue_t = 1.2;                // Shroud alignment tongue thickness (mm)

// Hub: grub-screw mount
hub_r = 11.0;                  // Hub radius (mm)
hub_h = 10.0;                  // Hub top height above the base bottom (mm)
shaft_d = 5.15;                // 5mm motor shaft bore (printed holes shrink slightly)
grub_z = 4.5;                  // M3 grub screw axis height above the base bottom (mm)
grub_hole_d = 3.2;             // M3 grub screw clearance (mm)
nut_af = 5.8;                  // Captive M3 nut slot width (5.5mm nut + clearance)
nut_t = 2.7;                   // Captive M3 nut slot thickness (2.4mm nut + clearance)
nut_r = 6.2;                   // Radial position of the nut slot center (mm)

// Rear Balance Rim (on the BACK of the disk: leaves blade passages open)
rear_rim_h = 5.0;              // Extends 5.0mm out the back of the disk
rear_rim_r_outer = 82.0;
rear_rim_r_inner = 74.0;
num_balance_holes = 24;
balance_hole_d = 1.85;         // Sized for 1.75mm PETG snippets (3.05 mg/mm)
balance_hole_depth = 4.2;      // Blind holes, opened from the rear face
balance_circle_r = 78.0;

function blade_center(t) =
    let(
        r = eye_r + (impeller_r - eye_r) * t,
        theta = blade_sweep * (1 - pow(max(0, 1 - t), 1.8))
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

// Counterclockwise arc arrow (3D cutter) from angle a0 to a1, with the head at a1
module ccw_arrow(r_mid, w, a0, a1, head_deg, h) {
    rotate([0, 0, a0])
        rotate_extrude(angle = a1 - a0, $fn = 96)
            translate([r_mid - w/2, 0])
                square([w, h]);
    linear_extrude(height = h)
        polygon([(r_mid - w * 1.3) * [cos(a1 - 1), sin(a1 - 1)],
                 (r_mid + w * 1.3) * [cos(a1 - 1), sin(a1 - 1)],
                 r_mid * [cos(a1 + head_deg), sin(a1 + head_deg)]]);
}

module single_blade() {
    // Constant-height blade, sunk 0.2mm into the base so it fuses with it
    translate([0, 0, base_h - blade_sink])
        linear_extrude(height = blade_h + blade_sink)
            polygon(points = blade_polygon(blade_t));

    // Alignment tongue for the shroud groove
    translate([0, 0, base_h + blade_h - 0.01])
        linear_extrude(height = tongue_h + 0.01)
            polygon(points = blade_polygon(tongue_t));
}

module impeller_disk() {
    difference() {
        union() {
            // Main Base Plate
            cylinder(r = impeller_r, h = base_h, $fn=120);

            // Central Hub (front side), chamfered top
            cylinder(r = hub_r, h = hub_h - 1.0, $fn=60);
            translate([0, 0, hub_h - 1.0])
                cylinder(r1 = hub_r, r2 = hub_r - 1.0, h = 1.0, $fn=60);

            // Rear Thickened Balance Rim (z = -rear_rim_h to 0)
            translate([0, 0, -rear_rim_h])
                difference() {
                    cylinder(r = rear_rim_r_outer, h = rear_rim_h + 0.01, $fn=120);
                    translate([0, 0, -0.1])
                        cylinder(r = rear_rim_r_inner, h = rear_rim_h + 0.3, $fn=100);
                }

            // 16 Constant-Height Radial-Tip Blades (front side)
            for (i = [0:num_blades-1])
                rotate([0, 0, i * (360 / num_blades)])
                    single_blade();
        }

        // 5mm shaft bore (through, so a longer shaft can pass)
        translate([0, 0, -1])
            cylinder(d = shaft_d, h = hub_h + 2, $fn=30);

        // 2x opposed M3 grub screws with captive nut slots (open at the hub top)
        for (a = [0, 180]) {
            rotate([0, 0, a]) {
                translate([0, 0, grub_z])
                    rotate([0, 90, 0])
                        cylinder(d = grub_hole_d, h = hub_r + 1, $fn=20);
                translate([nut_r - nut_t/2, -nut_af/2, grub_z - 3.3])
                    cube([nut_t, nut_af, hub_h]);
            }
        }

        // 24 Blind Perimeter Balance Holes (opened from the REAR face)
        for (i = [0:num_balance_holes-1]) {
            rotate([0, 0, i * (360 / num_balance_holes)])
                translate([balance_circle_r, 0, -rear_rim_h - 0.1])
                    cylinder(d = balance_hole_d, h = balance_hole_depth + 0.1, $fn=16);
        }

        // Recessed counterclockwise rotation arrow on the hub top (0.6mm deep)
        translate([0, 0, hub_h - 0.6])
            ccw_arrow(r_mid = 8.4, w = 1.0, a0 = 25, a1 = 130, head_deg = 20, h = 1.0);
    }
}

impeller_disk();
