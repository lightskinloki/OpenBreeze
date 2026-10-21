// OpenBreeze - Prototype 1 Assembly Preview
// License: GPL-3.0

use <part1_impeller_disk.scad>;
use <part2_impeller_shroud.scad>;
use <part3_volute_backplate.scad>;
use <part4_volute_frontcover.scad>;
use <part5_silencer_perforated_core.scad>;
use <part6_safety_alarm_elbow.scad>;

// Set exploded view offset (0 for fully assembled, 50 for exploded view)
explode = 40.0;

module full_assembly() {
    // Volute Backplate
    color([0.3, 0.3, 0.35, 1.0])
        volute_backplate();
        
    // Impeller Disk (inside volute)
    color([0.1, 0.6, 0.8, 1.0])
        translate([0, 0, 2.8 + 1.0 + explode * 0.5])
            impeller_disk();
            
    // Impeller Shroud Ring (bonded to blade tips)
    color([0.2, 0.7, 0.9, 0.9])
        translate([0, 0, 2.8 + 1.0 + 12.0 + explode * 0.8])
            impeller_shroud();
            
    // Volute Front Cover
    color([0.85, 0.85, 0.9, 0.8])
        translate([0, 0, 2.8 + 10.0 + explode * 1.2])
            volute_frontcover();
            
    // 32mm Silencer Core
    color([0.9, 0.5, 0.2, 0.9])
        translate([160.0, 60.0, 10.0 + explode * 1.5])
            rotate([0, 90, 0])
                silencer_core();
                
    // Safety Elbow Module
    color([0.2, 0.8, 0.4, 0.9])
        translate([340.0, 60.0, 10.0 + explode * 1.8])
            safety_elbow_body();
}

full_assembly();
