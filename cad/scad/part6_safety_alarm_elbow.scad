// OpenBreeze - Part 6: Prototype 1 Life-Safety Elbow (V4.2)
// License: GPL-3.0
// Material: PETG
//
// This file holds four separate prints, laid out side by side:
//   1. Elbow body       - print machine-side leg DOWN; supports under the horizontal leg and alarm shelf.
//   2. AAV seat plate   - print top face DOWN (knife-edge rim and hinge lugs up). No supports.
//   3. AAV door         - print sealing face DOWN. No supports.
//   4. Tap cap + tether - print flat. No supports.
//
// Air path: machine hose -> 22mm male leg -> valve chamber -> vent collar -> 22mm socket -> mask.
// The 8 CO2 vents sit on the collar BETWEEN the chamber and the socket stop (x = 36), so a fully
// inserted mask stem cannot cover them. They angle back, away from the face.
//
// AAV: the door hangs INSIDE the chamber from the seat plate. Blower pressure pushes it UP against
// the 0.4mm knife-edge rim around the 16x16mm window (shut). A steel safety-pin torsion spring pushes
// it open when pressure drops, opening the window to room air. Window area = 2.56 cm^2, so the
// closing force is 2.6 gf per cmH2O, minus the weight of the door and the glued-on alarm magnet.

$fn = 50;

// === PARAMETERS ===
// Standard CPAP 22mm connections
taper_base_d = 22.2;           // Machine-side male taper base
taper_tip_d = 21.6;            // Machine-side male taper tip
leg_h = 22.0;
socket_id = 22.3;              // Mask-side female socket inner diameter
tube_od = 25.5;                // Collar/socket outer diameter
bore_id = 18.5;                // Main airway bore diameter

// Valve chamber
chamber_od = 32.0;
chamber_id = 27.0;
chamber_z = 22.0;              // Chamber / horizontal leg centerline height
chamber_x2 = 12.0;             // Second chamber sphere center

// Horizontal leg: vent collar, then the mask socket
collar_x0 = 20.0;
socket_x0 = 36.0;              // Socket stop: mask stem cannot go past here
socket_x1 = 58.0;              // Socket mouth (22mm deep socket)

// CO2 washout vents (on the collar, upstream of the socket stop)
vent_x = 27.0;
vent_d = 2.0;
vent_count = 8;
vent_back_angle = 45;          // Angled back toward the machine, away from the face

// Mask-end static pressure tap (on the collar)
tap_x = 32.5;
tap_barb_od = 7.2;             // For 1/4" (6.35mm) ID vinyl tubing
tap_barb_tip_od = 6.8;
tap_barb_len = 9.0;
tap_bore_d = 2.8;

// AAV mounting pad and install opening (top of the chamber)
pad_w = 30.0;
pad_z0 = 34.0;
pad_top = 39.0;
opening_w = 22.0;              // Door drops in through here before the seat plate is glued on
opening_z0 = chamber_z + 7.0;
shelf_len = 17.0;              // Alarm shelf beside the pad (+Y side)

// AAV seat plate and door
plate_t = 2.5;
window_w = 16.0;               // 16x16mm breathing window (256 mm^2)
rim_w = 0.4;                   // Knife-edge rim width
rim_h = 0.45;                  // Knife-edge rim height
door_w = 18.0;                 // Door width (Y)
door_len = 17.5;               // Door length from the hinge axis (X)
door_t = 1.2;
barrel_r = 2.0;                // Door hinge barrel radius
barrel_c = 2.0;                // Hinge axis height above the door sealing face
pin_hole_d = 1.4;              // For a ~1.0mm steel safety-pin wire
pin_x = -8.5;                  // Hinge axis X (window center = 0)
pin_z = -(rim_h + barrel_c);   // Hinge axis below the plate underside
lug_t = 1.5;
magnet_recess = 8.5;           // Locating recess for the alarm magnet (sealing face center)

module elbow_body() {
    difference() {
        union() {
            // Machine-side 22mm male taper (vertical leg)
            cylinder(d1 = taper_base_d, d2 = taper_tip_d, h = leg_h);

            // Valve chamber
            translate([0, 0, chamber_z]) {
                sphere(d = chamber_od);
                translate([chamber_x2, 0, 0])
                    sphere(d = chamber_od);
            }

            // Horizontal leg: vent collar + mask socket
            translate([collar_x0, 0, chamber_z])
                rotate([0, 90, 0])
                    cylinder(d = tube_od, h = socket_x1 - collar_x0);

            // AAV mounting pad, flared down onto the chamber at 45 deg (prints without supports)
            hull() {
                translate([0, 0, pad_z0 - 8.0])
                    cylinder(r = 13.0, h = 0.1);
                translate([-pad_w/2, -pad_w/2, pad_z0])
                    cube([pad_w, pad_w, pad_top - pad_z0]);
            }

            // Alarm shelf beside the pad (zip-tie or tape the window alarm here)
            translate([-pad_w/2, pad_w/2 - 0.01, pad_z0])
                cube([pad_w, shelf_len, pad_top - pad_z0]);

            // Mask-end pressure tap barb (points +Y)
            translate([tap_x, tube_od/2 - 1.0, chamber_z])
                rotate([-90, 0, 0])
                    cylinder(d1 = tap_barb_od, d2 = tap_barb_tip_od, h = tap_barb_len + 1.0, $fn=24);
        }

        // Machine-side through-bore
        translate([0, 0, -1])
            cylinder(d = bore_id, h = chamber_z + 1);

        // Valve chamber interior
        translate([0, 0, chamber_z]) {
            sphere(d = chamber_id);
            translate([chamber_x2, 0, 0])
                sphere(d = chamber_id);
        }

        // Collar airway up to the socket stop
        translate([chamber_x2, 0, chamber_z])
            rotate([0, 90, 0])
                cylinder(d = bore_id, h = socket_x0 - chamber_x2 + 0.01);

        // Mask-side female socket (22mm deep)
        translate([socket_x0, 0, chamber_z])
            rotate([0, 90, 0])
                cylinder(d = socket_id, h = socket_x1 - socket_x0 + 1);

        // AAV install opening through the pad into the chamber
        translate([-opening_w/2, -opening_w/2, opening_z0])
            cube([opening_w, opening_w, pad_top - opening_z0 + 1]);

        // 8x CO2 washout vents: from inside the bore, out through the collar wall,
        // angled back toward the machine
        for (i = [0:vent_count-1]) {
            a = i * 360 / vent_count;
            u = [0, cos(a), sin(a)];
            d = [-sin(vent_back_angle), cos(vent_back_angle) * cos(a), cos(vent_back_angle) * sin(a)];
            p0 = [vent_x + 3.0, 0, chamber_z] + 6.0 * u;
            hull() {
                translate(p0) sphere(d = vent_d, $fn=16);
                translate(p0 + 12.0 * d) sphere(d = vent_d, $fn=16);
            }
        }

        // Pressure tap bore (into the collar airway)
        translate([tap_x, 4.0, chamber_z])
            rotate([-90, 0, 0])
                cylinder(d = tap_bore_d, h = tube_od/2 + tap_barb_len + 2, $fn=16);

        // 2x zip-tie slots through the alarm shelf
        for (x = [-9.0, 9.0])
            translate([x - 1.5, pad_w/2 + shelf_len/2 - 2.0, pad_z0 - 1])
                cube([3.0, 4.0, pad_top - pad_z0 + 2]);
    }
}

// Seat plate in its ASSEMBLED orientation: underside at z = 0, top at z = plate_t
module aav_seat_plate_assembled() {
    difference() {
        translate([-pad_w/2, -pad_w/2, 0])
            cube([pad_w, pad_w, plate_t]);
        translate([-window_w/2, -window_w/2, -1])
            cube([window_w, window_w, plate_t + 2]);
    }
    // Continuous knife-edge sealing rim around the window (underside)
    translate([0, 0, -rim_h])
        difference() {
            translate([-window_w/2 - rim_w, -window_w/2 - rim_w, 0])
                cube([window_w + 2*rim_w, window_w + 2*rim_w, rim_h + 0.01]);
            translate([-window_w/2, -window_w/2, -1])
                cube([window_w, window_w, rim_h + 2]);
        }
    // Hinge lugs (underside), either side of the door
    for (s = [-1, 1]) {
        y0 = (s > 0) ? door_w/2 + 0.3 : -door_w/2 - 0.3 - lug_t;
        difference() {
            translate([pin_x - barrel_r, y0, pin_z - barrel_r])
                cube([2 * barrel_r, lug_t, -pin_z + barrel_r + 0.01]);
            translate([pin_x, y0 - 1, pin_z])
                rotate([-90, 0, 0])
                    cylinder(d = pin_hole_d, h = lug_t + 2, $fn=16);
        }
    }
}

// Door in its PRINT orientation: sealing face on the bed (z = 0), hinge barrel on top at x = 0
module aav_door_print() {
    difference() {
        union() {
            cube([door_len, door_w, door_t]);
            translate([0, 0, barrel_c])
                rotate([-90, 0, 0])
                    cylinder(r = barrel_r, h = door_w, $fn=32);
        }
        // Hinge wire bore
        translate([0, -1, barrel_c])
            rotate([-90, 0, 0])
                cylinder(d = pin_hole_d, h = door_w + 2, $fn=16);
        // Shallow locating recess for the alarm magnet (glue it here; it sits in the window)
        // (window center is -pin_x from the hinge axis)
        translate([-pin_x - magnet_recess/2, door_w/2 - magnet_recess/2, -0.1])
            cube([magnet_recess, magnet_recess, 0.7]);
    }
}

module pressure_tap_cap() {
    // Friction-fit cap for the 7.2mm tap barb, tethered by a ring that slides over the socket
    cap_id = tap_barb_tip_od - 0.2;
    difference() {
        union() {
            cylinder(d = cap_id + 2.4, h = 8.0, $fn=30);
            translate([0, -1.0, 0])
                cube([25.0, 2.0, 1.0]);
            translate([25.0 + tube_od/2 + 1.0, 0, 0])
                difference() {
                    cylinder(d = tube_od + 4.0, h = 4.0, $fn=60);
                    translate([0, 0, -0.1])
                        cylinder(d = tube_od + 0.4, h = 4.2, $fn=60);
                }
        }
        translate([0, 0, 1.0])
            cylinder(d = cap_id, h = 8.0, $fn=30);
    }
}

// === PRINT LAYOUT ===
elbow_body();
// Seat plate flipped: top face on the bed, rim and lugs up
translate([-60.0, 0, plate_t])
    rotate([180, 0, 0])
        aav_seat_plate_assembled();
translate([-40.0, 25.0, 0])
    aav_door_print();
translate([-70.0, -45.0, 0])
    pressure_tap_cap();
