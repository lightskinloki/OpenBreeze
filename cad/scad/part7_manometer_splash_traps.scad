// OpenBreeze - Part 7: U-Tube Water Manometer Anti-Blowout Splash Traps & Bracket (V4.2)
// License: GPL-3.0
// Material: PETG
// Purpose: Prevents coughing/sneezing from blowing water out of the manometer tube;
// holds the clear vinyl U-tube against the side of the 5-gallon bucket with 0-25 cm scale.
// Print: bulbs standing on their bottom barb (supports under the bulb overhang);
// bracket flat on its back, placed diagonally on the bed (260mm long).

$fn = 50;

tube_od = 9.5;                 // 3/8" (9.5mm) outer diameter of 1/4" ID vinyl tubing
tube_id = 6.35;                // 1/4" (6.35mm) inner diameter
bulb_od = 28.0;                // 28mm outer diameter of catch bulb
bulb_h = 36.0;                 // 36mm catch bulb height (~20 mL catch volume)
bulb_wall = 2.0;
barb_od = 7.2;                 // Hose barb for 1/4" ID tubing
barb_len = 12.0;               // Exposed barb length
barb_overlap = 2.0;            // Barbs sink this far into the bulb wall so they fuse
barb_bore_d = 4.8;
clip_spacing = 16.0;           // U-tube leg spacing on the bracket
clip_wall = 1.6;
clip_len = 8.0;

module splash_trap_bulb() {
    bottom_z = -bulb_od/2;                 // Bulb bottom pole
    top_z = bulb_h - bulb_od/2;            // Bulb top pole
    difference() {
        union() {
            // Main bulb body
            hull() {
                sphere(r = bulb_od/2);
                translate([0, 0, bulb_h - bulb_od])
                    sphere(r = bulb_od/2);
            }
            // Bottom tube barb (connects to U-tube), sunk into the wall
            translate([0, 0, bottom_z - barb_len])
                cylinder(r1 = barb_od/2 - 0.4, r2 = barb_od/2, h = barb_len + barb_overlap + bulb_wall, $fn=30);
            // Top atmospheric vent / line barb, sunk into the wall
            translate([0, 0, top_z - barb_overlap - bulb_wall])
                cylinder(r1 = barb_od/2, r2 = barb_od/2 - 0.4, h = barb_len + barb_overlap + bulb_wall, $fn=30);
        }

        // Internal hollow chamber
        hull() {
            sphere(r = bulb_od/2 - bulb_wall);
            translate([0, 0, bulb_h - bulb_od])
                sphere(r = bulb_od/2 - bulb_wall);
        }

        // Bottom barb bore, opening into the chamber
        translate([0, 0, bottom_z - barb_len - 1])
            cylinder(d = barb_bore_d, h = barb_len + bulb_wall + 4, $fn=20);

        // Top barb bore, opening into the chamber
        translate([0, 0, top_z - bulb_wall - 3])
            cylinder(d = barb_bore_d, h = barb_len + bulb_wall + 4, $fn=20);
    }
}

// C-clip that holds one tube lying along +Y on the bracket face, snapped in from above
module tube_clip() {
    cz = tube_od/2;                        // Tube centerline above the bracket face
    difference() {
        union() {
            translate([0, 0, cz])
                rotate([-90, 0, 0])
                    cylinder(r = tube_od/2 + clip_wall, h = clip_len, $fn=30);
            translate([-(tube_od/2 + clip_wall), 0, 0])
                cube([tube_od + 2 * clip_wall, clip_len, cz]);
        }
        translate([0, -1, cz])
            rotate([-90, 0, 0])
                cylinder(r = tube_od/2, h = clip_len + 2, $fn=30);
        // Snap opening on top (80% of the tube diameter)
        translate([-tube_od * 0.4, -1, cz + 1.5])
            cube([tube_od * 0.8, clip_len + 2, tube_od]);
    }
}

module manometer_centimeter_scale_bracket() {
    // 25 cm ruler backing bracket that clips to the side of the 5-gallon bucket
    translate([45.0, -15.0, 0]) {
        difference() {
            union() {
                // Backing plate
                cube([30.0, 260.0, 3.0]);
                // Dual tube clips (U-tube legs run along the ruler, 16mm apart)
                for (y = [30, 80, 130, 180, 230]) {
                    translate([7.0, y, 3.0 - 0.01]) tube_clip();
                    translate([7.0 + clip_spacing, y, 3.0 - 0.01]) tube_clip();
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
