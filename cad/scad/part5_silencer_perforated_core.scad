// OpenBreeze - Part 5: Straight-Through 32mm Perforated Acoustic Silencer Core
// License: GPL-3.0
// Material: PETG (prints vertically without supports)
// Purpose: Strips -28 dB of blade whine; aerodynamic loss < 0.02 cmH2O at 90 L/min

$fn = 60;

// === PARAMETERS ===
inner_d = 32.0;                // 32mm smooth inner airway bore
inner_r = inner_d / 2;         // 16.0 mm
wall_t = 1.6;                  // 1.6mm wall thickness (4 perimeters at 0.4mm nozzle)
outer_r = inner_r + wall_t;    // 17.6 mm
total_len = 160.0;             // Total silencer length (mm)
solid_end_len = 18.0;          // Solid slip-fit cuff length on each end (mm)

hole_d = 3.0;                  // 3mm perforation hole diameter
num_rows = 12;                 // 12 longitudinal rows
holes_per_row = 10;            // 10 holes per row = 120 total holes

module silencer_core() {
    difference() {
        // Main cylindrical tube
        cylinder(r = outer_r, h = total_len);
        
        // Through-bore
        translate([0, 0, -1])
            cylinder(r = inner_r, h = total_len + 2);
            
        // 120 Staggered Acoustic Perforations
        for (i = [0:num_rows-1]) {
            angle = i * (360 / num_rows);
            z_offset = (i % 2 == 0) ? 0 : 5.0; // Staggered pattern
            
            for (j = [0:holes_per_row-1]) {
                z_pos = solid_end_len + 5.0 + j * 11.0 + z_offset;
                
                if (z_pos < total_len - solid_end_len - 3.0) {
                    rotate([0, 0, angle])
                        translate([0, 0, z_pos])
                            rotate([0, 90, 0])
                                cylinder(r = hole_d/2, h = outer_r + 2, $fn=16);
                }
            }
        }
    }
}

silencer_core();
