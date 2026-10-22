// OpenBreeze - Prototype 1 Blower Assembly Preview (V4.2)
// License: GPL-3.0
// Assembled heights (backplate rear face = motor mounting face = z 0):
//   backplate top / parting plane 8.4, wheel base bottom 9.5, shroud 21.9, cover front face 33.6

use <part1_impeller_disk.scad>;
use <part2_impeller_shroud.scad>;
use <part3_volute_backplate.scad>;
use <part4_volute_frontcover.scad>;
use <part8_intake_collar.scad>;

// Exploded view offset (0 for fully assembled)
explode = 40.0;

module full_assembly() {
    // Volute Backplate
    color([0.3, 0.3, 0.35, 1.0])
        volute_backplate();

    // Impeller Disk
    color([0.1, 0.6, 0.8, 1.0])
        translate([0, 0, 9.5 + explode * 0.5])
            impeller_disk();

    // Impeller Shroud Ring (glued on the blade tops, not flipped)
    color([0.2, 0.7, 0.9, 1.0])
        translate([0, 0, 9.5 + 12.4 + explode * 1.0])
            impeller_shroud();

    // Volute Front Cover
    color([0.85, 0.85, 0.9, 0.85])
        translate([0, 0, 8.4 + explode * 1.6])
            volute_frontcover();

    // Intake Collar (glued on the front face)
    color([0.9, 0.5, 0.2, 1.0])
        translate([0, 0, 8.4 + 25.2 + explode * 2.2])
            intake_collar();
}

full_assembly();
