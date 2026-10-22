// OpenBreeze - Part 8: Intake Collar (V4.2)
// License: GPL-3.0
// Material: PETG
// Print: flange DOWN on the bed. No supports.
//
// Glue the flange to the front face of Part 4, centered on the 60mm intake hole,
// with neutral-cure silicone (also seals it). A short flexible silicone hose runs
// from this collar through the bucket lid to the external MERV-13 filter box; it
// is under suction, so every joint on that run must be airtight.

$fn = 120;

// === PARAMETERS ===
collar_id = 60.0;              // Matches the 60mm intake hole in Part 4
collar_wall = 2.0;
collar_h = 18.0;               // Total height including the flange
flange_od = 88.0;
flange_t = 3.0;
rib_h = 1.2;                   // Hose-clamp retaining rib
rib_out = 1.2;                 // Rib protrusion (45 deg underside, no supports)

module intake_collar() {
    collar_od = collar_id + 2 * collar_wall;
    difference() {
        union() {
            cylinder(d = flange_od, h = flange_t);
            cylinder(d = collar_od, h = collar_h);
            // Retaining rib: 45 deg chamfer below, flat land above
            translate([0, 0, collar_h - 5.0])
                cylinder(d1 = collar_od, d2 = collar_od + 2 * rib_out, h = rib_out);
            translate([0, 0, collar_h - 5.0 + rib_out - 0.01])
                cylinder(d = collar_od + 2 * rib_out, h = rib_h);
        }
        translate([0, 0, -1])
            cylinder(d = collar_id, h = collar_h + 2);
    }
}

intake_collar();
