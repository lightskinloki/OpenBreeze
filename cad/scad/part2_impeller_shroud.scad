// OpenBreeze - Part 2: 165mm Impeller Front Shroud Ring (V4.2)
// License: GPL-3.0
// Material: PETG. Modeled in its ASSEMBLED orientation:
// grooves on the underside (they face the blades), eye lip on top (faces the cover).
// Print exactly as modeled: groove face DOWN on the bed, lip UP. No supports.
// Do not flip it before gluing; flipping would mirror the grooves.

$fn = 100;

// === PARAMETERS ===
impeller_d = 165.0;            // Outer diameter (mm)
impeller_r = impeller_d / 2;   // 82.5 mm
eye_r = 30.0;                  // Intake eye radius (mm)
shroud_t = 1.8;                // Flat shroud plate thickness (mm)
labyrinth_lip_h = 2.0;         // Running lip around the eye, faces the cover (mm)
labyrinth_lip_w = 1.6;         // Lip wall thickness (mm)

num_blades = 16;
blade_sweep = -36.0;           // Must match Part 1
groove_w = 1.6;                // Mating groove width (accepts the 1.2mm blade tongue)
groove_depth = 1.0;            // Mating groove depth (mm)

function blade_center(t) =
    let(
        r = eye_r + (impeller_d / 2 - eye_r) * t,
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

module impeller_shroud() {
    difference() {
        union() {
            // Main flat ring (bears on all 16 blade tops)
            cylinder(r = impeller_r, h = shroud_t, $fn=120);

            // Raised running lip around the intake eye (top face)
            translate([0, 0, shroud_t - 0.01])
                difference() {
                    cylinder(r = eye_r + labyrinth_lip_w, h = labyrinth_lip_h + 0.01, $fn=100);
                    translate([0, 0, -0.1])
                        cylinder(r = eye_r, h = labyrinth_lip_h + 0.3, $fn=100);
                }
        }

        // Central intake eye cutout
        translate([0, 0, -1])
            cylinder(r = eye_r, h = shroud_t + labyrinth_lip_h + 2, $fn=100);

        // 16 Mating grooves on the underside (cut 1.0mm into the 1.8mm plate)
        translate([0, 0, -0.1]) {
            for (i = [0:num_blades-1]) {
                rotate([0, 0, i * (360 / num_blades)])
                    linear_extrude(height = groove_depth + 0.1)
                        polygon(points = blade_polygon(groove_w));
            }
        }

        // Entry chamfer on the inside top edge of the lip
        translate([0, 0, shroud_t + labyrinth_lip_h - 0.8])
            cylinder(r1 = eye_r, r2 = eye_r + 0.8, h = 0.81, $fn=100);
    }
}

impeller_shroud();
