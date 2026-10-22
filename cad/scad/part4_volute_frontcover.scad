// OpenBreeze - Part 4: Volute Front Cover with Scroll, Outlet Duct & ISO 22mm Spigot (V4.2)
// License: GPL-3.0
// Material: PETG (4 perimeters, 25% infill)
// Footprint: 208.9 x 219.5 mm including the spigot (fits a 220x220mm bed;
// on a 250x210mm bed, point the spigot along the 250mm axis).
// Print: FRONT FACE DOWN on the bed (parting face and cavities facing up).
// Only the spigot underside needs a little support. The intake collar is
// Part 8, glued on afterwards.
//
// Air path: wheel -> scroll (counterclockwise seen from the front) -> outlet duct
// -> round 19mm bore -> ISO 22mm spigot. The scroll and duct have their own
// 3.5mm floor, so the backplate gasket (r = 92mm) seals under solid plastic.
//
// Assembled reference: z = 0 is the parting plane (backplate top face);
// z = cover_t is the front face.

$fn = 60;

// === PARAMETERS ===
plate_w = 205.0;               // Outer square width/length (mm)
corner_r = 15.0;               // Rounded corner radius (mm)
bolt_offset = plate_w/2 - 15.0;// 87.5 mm from center
bolt_hole_d = 4.3;             // M4 clearance hole
bolt_head_d = 8.5;             // M4 head counterbore (front face)
bolt_head_depth = 4.0;
// Assembly bolts: three in the corners, the fourth moved off the +X+Y corner
// because the outlet duct runs through it. Must match Part 3.
bolt_positions = [[-bolt_offset, -bolt_offset], [bolt_offset, -bolt_offset],
                  [-bolt_offset, bolt_offset], [72.0, 84.0]];
cover_t = 25.2;                // Total cover thickness (mm)

// Rotor chamber (open to the backplate)
rotor_r = 86.0;                // 3.5mm radial clearance to the 82.5mm wheel
rotor_ceiling = 18.8;          // 1.5mm axial clearance above the shroud eye lip

// Scroll + outlet duct (floored inside the cover)
floor_t = 3.5;                 // Scroll/duct floor thickness at the parting face
scroll_ceiling = 22.2;         // Leaves a 3.0mm front wall over the scroll
scroll_inner_r = 84.0;         // Scroll inner edge (overlaps the rotor chamber)
r_cutwater = 89.0;             // Tongue tip radius: 6.5mm gap to the 82.5mm wheel tip
duct_x0 = 88.5;                // Outlet duct inner wall
duct_x1 = 99.5;                // Outlet duct outer wall = scroll radius at 360 deg
tip_ang = acos(duct_x0 / r_cutwater);  // Where the r_cutwater arc crosses the duct wall (~6.1 deg)
tongue_root = 1.6;             // Tongue thickness where the scroll starts (mm)
cut_ang = acos((duct_x0 - tongue_root) / r_cutwater);  // Scroll start angle (~12.5 deg)
duct_end_y = 70.0;             // Rectangular duct ends here
round_start_y = 88.0;          // Duct-to-round transition is complete here

// Outlet
outlet_x = (duct_x0 + duct_x1) / 2;   // 94.0 mm
outlet_z = cover_t / 2;                // 12.6 mm
bore_d = 19.0;                 // 19mm round bore
body_x0 = outlet_x - 12.4;     // Nozzle body: 2.9mm walls around the bore
body_x1 = outlet_x + 12.4;
body_y0 = 55.0;
body_y1 = 95.0;
spigot_y0 = 95.0;
spigot_h = 22.0;               // ISO 22mm friction taper length
spigot_base_d = 25.0;
spigot_tip_d = 23.0;
cuff_clear_r = 16.0;           // Room for the hose cuff to slide fully over the spigot
cuff_clear_y0 = 97.0;

// Static pressure tap (manometer), points +Y beside the spigot
tap_x = 68.0;
tap_base_y = 100.0;            // Embedded in the plate corner
tap_barb_len = 11.5;           // Exposed length ~9mm past the plate edge
tap_barb_od = 7.2;             // For 1/4" (6.35mm) ID vinyl tubing
tap_barb_tip_od = 6.8;
tap_bore_d = 2.8;
tap_turn_y = 92.0;             // L-shaped tunnel: down -Y to here, then +X into the round bore
tap_end_x = 86.0;              // Tunnel ends inside the round bore

// Central intake (Part 8 collar glues on over this hole)
intake_r = 30.0;

module plate_outline(h) {
    hull() {
        for (x = [-bolt_offset, bolt_offset])
            for (y = [-bolt_offset, bolt_offset])
                translate([x, y, 0])
                    cylinder(r = corner_r, h = h, $fn=40);
    }
}

// Counterclockwise arc arrow (3D cutter) from angle a0 to a1, with the head at a1
module ccw_arrow(r_mid, w, a0, a1, head_deg, h) {
    rotate([0, 0, a0])
        rotate_extrude(angle = a1 - a0, $fn = 180)
            translate([r_mid - w/2, 0])
                square([w, h]);
    linear_extrude(height = h)
        polygon([(r_mid - w * 1.3) * [cos(a1 - 1), sin(a1 - 1)],
                 (r_mid + w * 1.3) * [cos(a1 - 1), sin(a1 - 1)],
                 r_mid * [cos(a1 + head_deg), sin(a1 + head_deg)]]);
}

// Expanding spiral: r_cutwater at the tongue tip -> duct_x1 at 360 deg (simple polygon)
function scroll_2d_pts() =
    let(
        N = 72,
        outer = [for (i = [0:N])
            let(
                t = i / N,
                ang = cut_ang + t * (360.0 - cut_ang),
                r = r_cutwater + (duct_x1 - r_cutwater) * t
            )
            [r * cos(ang), r * sin(ang)]
        ],
        inner = [for (i = [N:-1:0])
            let(
                t = i / N,
                ang = cut_ang + t * (360.0 - cut_ang)
            )
            [scroll_inner_r * cos(ang), scroll_inner_r * sin(ang)]
        ]
    )
    concat(outer, inner);

// Annular sector that keeps the tongue at r_cutwater (not at the rotor wall).
// It overlaps the duct below tip_ang and the scroll start above cut_ang, so no
// three cut surfaces meet at a single edge.
module tongue_sector_2d() {
    n = 16;
    a0 = -12.0;
    a1 = cut_ang + 0.5;
    polygon(concat(
        [for (i = [0:n]) let(a = a0 + (a1 - a0) * i / n) r_cutwater * [cos(a), sin(a)]],
        [for (i = [n:-1:0]) let(a = a0 + (a1 - a0) * i / n) (scroll_inner_r - 1) * [cos(a), sin(a)]]
    ));
}

module air_path() {
    // 1. Rotor chamber, open to the backplate
    translate([0, 0, -0.1])
        cylinder(r = rotor_r, h = rotor_ceiling + 0.1, $fn=180);

    // 2. Expanding scroll (floored)
    translate([0, 0, floor_t])
        linear_extrude(height = scroll_ceiling - floor_t)
            polygon(points = scroll_2d_pts());
    translate([0, 0, floor_t])
        linear_extrude(height = scroll_ceiling - floor_t)
            tongue_sector_2d();

    // 3. Rectangular outlet duct along +Y (floored)
    translate([duct_x0, -2.0, floor_t])
        cube([duct_x1 - duct_x0, duct_end_y + 2.0 + 0.01, scroll_ceiling - floor_t]);

    // 4. Rectangle-to-round transition
    hull() {
        translate([duct_x0, duct_end_y, floor_t])
            cube([duct_x1 - duct_x0, 0.01, scroll_ceiling - floor_t]);
        translate([outlet_x, round_start_y, outlet_z])
            rotate([-90, 0, 0])
                cylinder(d = bore_d, h = 0.01, $fn=48);
    }

    // 5. Round bore through the spigot
    translate([outlet_x, round_start_y - 0.01, outlet_z])
        rotate([-90, 0, 0])
            cylinder(d = bore_d, h = spigot_y0 + spigot_h - round_start_y + 2, $fn=48);

    // 6. Central intake hole through the front wall
    translate([0, 0, rotor_ceiling - 1])
        cylinder(r = intake_r, h = cover_t, $fn=120);
}

module volute_frontcover() {
    difference() {
        union() {
            difference() {
                union() {
                    // Main 205x205mm rounded plate
                    plate_outline(cover_t);

                    // Nozzle body around the duct transition (extends past the plate edge)
                    translate([body_x0, body_y0, 0])
                        cube([body_x1 - body_x0, body_y1 - body_y0, cover_t]);
                }
                // Clearance so the hose cuff can slide fully over the spigot
                translate([outlet_x, cuff_clear_y0, outlet_z])
                    rotate([-90, 0, 0])
                        cylinder(r = cuff_clear_r, h = 40, $fn=64);
            }

            // Standard ISO 22mm Tapered Spigot
            translate([outlet_x, spigot_y0 - 0.5, outlet_z])
                rotate([-90, 0, 0])
                    cylinder(d1 = spigot_base_d, d2 = spigot_tip_d, h = spigot_h + 0.5, $fn=64);

            // Static pressure tap barb (points +Y, beside the spigot)
            translate([tap_x, tap_base_y, outlet_z])
                rotate([-90, 0, 0])
                    cylinder(d1 = tap_barb_od, d2 = tap_barb_tip_od, h = tap_barb_len, $fn=24);
        }

        // Unified air path: rotor chamber + scroll + duct + bore + intake
        air_path();

        // Pressure tap tunnel: barb tip -> down -Y -> across +X into the round bore
        translate([tap_x, tap_base_y - 0.5, outlet_z])
            rotate([-90, 0, 0])
                cylinder(d = tap_bore_d, h = tap_barb_len + 1, $fn=16);
        hull() {
            translate([tap_x, tap_base_y, outlet_z]) sphere(d = tap_bore_d, $fn=16);
            translate([tap_x, tap_turn_y, outlet_z]) sphere(d = tap_bore_d, $fn=16);
        }
        hull() {
            translate([tap_x, tap_turn_y, outlet_z]) sphere(d = tap_bore_d, $fn=16);
            translate([tap_end_x, tap_turn_y, outlet_z]) sphere(d = tap_bore_d, $fn=16);
        }

        // 4x Assembly Bolt Holes (M4) with head counterbores on the front face
        for (p = bolt_positions) {
            translate([p[0], p[1], -1])
                cylinder(d = bolt_hole_d, h = cover_t + 2, $fn=20);
            translate([p[0], p[1], cover_t - bolt_head_depth])
                cylinder(d = bolt_head_d, h = bolt_head_depth + 1, $fn=24);
        }

        // Recessed counterclockwise rotation arrow on the front face (0.6mm deep)
        translate([0, 0, cover_t - 0.6])
            ccw_arrow(r_mid = 60.0, w = 2.4, a0 = 200, a1 = 320, head_deg = 8, h = 1.0);
    }
}

volute_frontcover();
