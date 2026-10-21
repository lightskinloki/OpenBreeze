// OpenBreeze - Part 2: 165mm Impeller Snap-On Front Shroud Ring (V4.1 Hardened)
// License: GPL-3.0
// Material: PETG (prints 100% flat on build plate with zero supports)
// Mates 100% flat against the constant-height (10mm) blades of Part 1

$fn = 100;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_d = 60.0;                  // Intake eye diameter (mm)
eye_r = eye_d / 2;             // 30.0 mm
shroud_t = 1.8;                // Main flat shroud plate thickness (mm)
labyrinth_lip_h = 2.0;         // Raised running labyrinth lip around eye (mm)
labyrinth_lip_w = 1.6;         // Labyrinth lip wall thickness (mm)

num_blades = 16;
groove_w = 1.6;                // Mating groove width (accepts 1.2mm blade tongue)
groove_depth = 1.0;            // Mating groove depth (mm)

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

module impeller_shroud() {
    difference() {
        union() {
            // Main flat ring (Dead flat for 100% surface bonding across all 16 blades)
            cylinder(r = impeller_r, h = shroud_t, $fn=120);
            
            // Raised Labyrinth Running Lip around intake eye (Front face)
            // Provides 1.2mm radial running clearance with stationary cover lip
            translate([0, 0, -labyrinth_lip_h])
                difference() {
                    cylinder(r = eye_r + labyrinth_lip_w, h = labyrinth_lip_h, $fn=100);
                    translate([0, 0, -0.1])
                        cylinder(r = eye_r, h = labyrinth_lip_h + 0.2, $fn=100);
                }
        }
        
        // Central intake eye cutout
        translate([0, 0, -labyrinth_lip_h - 1])
            cylinder(r = eye_r, h = shroud_t + labyrinth_lip_h + 2, $fn=100);
            
        // 16 Mating grooves on the rear face (cuts 1.0mm into the 1.8mm plate)
        translate([0, 0, shroud_t - groove_depth]) {
            for (i = [0:num_blades-1]) {
                rotate([0, 0, i * (360 / num_blades)])
                    linear_extrude(height = groove_depth + 0.1)
                        polygon(points = blade_polygon(groove_w));
            }
        }
        
        // Smooth aerodynamic entry chamfer
        translate([0, 0, -labyrinth_lip_h - 0.1])
            cylinder(r1 = eye_r + 1.2, r2 = eye_r, h = 1.2, $fn=100);
    }
}

impeller_shroud();
