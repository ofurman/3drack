// AI TOP ATOM mini-rack: 2x GIGABYTE AI TOP ATOM + Raspberry Pi 5 + external SSD
// Units: mm. x = width (left -> right seen from the FRONT), y = depth (0 = front), z = up.
//
// Stack (bottom -> top), clamped by 4x M4 threaded rods through the corner pillars:
//   tray  x2  one Delta ADP-240KB BA 240 W USB-C brick each + hidden spool for its 1.8 m cable
//   bay   x2  one AI TOP ATOM each
//   deck  x1  Raspberry Pi 5 + ICY BOX IB-1917M-C32a SSD side by side
//   lid   x1  honeycomb top cover; open sides keep the Pi cooler and SSD fins breathing
//
// Thermal concept
//   * Atoms breathe front -> back (front grille + bottom-front vent in, rear-top vent out).
//     Fronts are fully open; rears are fully open between the raceways.
//   * Bay floors are solid: each Atom sits on a "desk" and draws cool air from the front,
//     never the warm air pooled above the unit below.
//   * Hex-lattice side walls cross-ventilate the 20 mm slot above each Atom and the brick trays.
//   * The rear 60 mm of every side wall is solid: it stops exhaust from wrapping around to the
//     side lattice / front intakes.
//   * The deck plate runs the full depth as an exhaust hood, with a rear plume fence: the rising
//     Atom exhaust is pushed out behind the rack instead of onto the Pi cooler and the SSD.
//   * Bricks ride on ribs with 10 mm of air above, a hex front grille and floor vents.
//
// Export one part:  openscad -D 'part="bay"' -o bay.stl atom_rack.scad
//                   (part="lid" is exported upside down, ready to print)
// Airflow diagram:  openscad -D 'part="airflow"' -o airflow.png atom_rack.scad

part = "assembly"; // [assembly, exploded, airflow, tray, bay, deck, lid]

/* [Devices] */
atom  = [150, 150, 51.2];    // GIGABYTE spec W150 x D150 x H50.5 (STH measured 51); 51.2 adds margin
brick = [72.1, 162.2, 23.3]; // Delta ADP-240KB BA (x = width, y = length): datasheet 162 x 72 x 23, ChargerLAB 162.16 x 72.04 x 23.28
pi_board = [85, 56];         // Raspberry Pi 5 board, long axis along y, USB/Ethernet end at the rear
pi_hole_inset = 3.5;         // Pi 5 mounting holes: 58 x 49 mm pattern, 3.5 mm from edges
pi_hole_dx = 58;
pi_hole_dy = 49;
pi_height = 18;              // board underside -> top of the USB/Ethernet stack (Active Cooler tops out at ~15.3)
ssd = [50, 110, 16];         // ICY BOX IB-1917M-C32a (x, y, z), 145 g, USB-C 20 Gbit/s at the rear end

/* [Rack] */
clr = 2;            // clearance around each Atom
wall = 10;          // side wall thickness (houses the M4 rods)
floor_t = 4;
headroom = 20;      // ventilated slot above each Atom
gutter = 54;        // rear cable / exhaust zone behind the floors
front_frame = 6;    // floor ahead of the Atom (front corner stops live here)
stop_h = 8;         // corner stop height: must reach the Atom body, which its stand lifts off the floor
stop_w = 20;        // corner stop width, measured from the side wall
rod_d = 4.5;        // M4 clearance
nut_af = 7.4;       // M4 nut across flats + clearance
nut_h = 4;          // nut recess depth
m4_nut_h = 3.2;     // M4 hex nut height (DIN 934)
washer_t = 0.8;     // M4 flat washer under each top nut
wave_t = 0.5;       // M4 wave spring washer, flattened: keeps the clamp as the ASA creeps
acorn_grip = 4.5;   // rod engagement in the acorn nut; DIN 1587 M4 thread depth is only 5.26
deck_h = 32;        // deck pillars + rear plume fence
lip_h = 10;         // deck front lip (carries the label)
rib_h = 2;          // brick stands on ribs so air flows underneath
brick_air = 10;     // air gap above each brick (case reaches ~58 C at full load)
ssd_rib_h = 3;      // SSD stands on ribs: deck plate is warm from the Atom below
label = "PWr genwro.ai property"; // engraved on the deck lip; "" for none
lid_clear = 14;     // air gap between the Pi's tallest part and the lid
lid_t = 3;          // lid top plate
lid_frame = 8;      // lid perimeter beam depth

/* [Style] */
hex_a = 14;         // honeycomb cell pitch
hex_t = 2.4;        // honeycomb strut width
pillar_d = 18;      // solid front pillar depth (carries the front rod)
chamfer = 2.5;      // vertical corner chamfers

$fn = 48;
eps = 0.01;

pocket_w = atom.x + 2 * clr;                       // 154
W        = pocket_w + 2 * wall;                    // 174
atom_y1  = front_frame + atom.y;                   // Atom rear face
floor_d  = atom_y1 + clr + 6;                      // 164: floor ends behind the rear corner stops
D        = floor_d + gutter;                       // 218
bay_h    = floor_t + atom.z + headroom;            // 75.2
tray_h   = floor_t + rib_h + brick.z + brick_air;  // 39.3
lid_h    = floor_t + 6 + pi_height + lid_clear + lid_t - deck_h;  // 13: lid sits on the deck pillars
total_h  = 2 * tray_h + 2 * bay_h + deck_h + lid_h;
rod_z0   = nut_h - m4_nut_h;                      // rod end flush with the seated bottom nut
rod_len  = round(total_h - rod_z0 + washer_t + wave_t + acorn_grip);
baffle_y = floor_d - 6;                            // side walls are solid behind this line

rod_xy = [for (x = [wall / 2, W - wall / 2]) for (y = [8, D - 8]) [x, y]];
raceway_w = 24;     // usable raceway width between wall and hook lip

hex_rho = (hex_a - hex_t) / 2;                     // cell inradius
hex_r   = hex_rho * 2 / sqrt(3);                   // cell circumradius

// brick placement inside a tray: against the left wall, AC (C6) inlet facing the rear,
// captive USB-C cable leaving the front end
bx0 = wall + 1;
by0 = D - 7 - brick.y;
lane_x0 = bx0 + brick.x + 3;                       // service lane right of the brick
lane_xc = (lane_x0 + W - wall) / 2;
spool_y = [36, 140];
spool_d = 36;                                      // drum diameter: 18 mm bend radius for the 240 W cable
spool_wall = 2.4;                                  // drums are hollow
spool_h = tray_h - floor_t - 6;                    // drum height below the cap

// deck placement: SSD left, Pi right. The Pi's USB-C power edge faces the right wall, set back
// far enough that the plug and the cable bend stay inside the rack; the cable then runs back
// to the power raceway and down to a USB-C port on the upper Atom.
pi_plug_clear = 32;
pi_x1 = W - wall - pi_plug_clear;      // power edge
pi_x0 = pi_x1 - pi_board.y;
pi_y1 = floor_d - 2;                   // USB/Ethernet end
pi_y0 = pi_y1 - pi_board.x;
ssd_x0 = (wall + pi_x0 - ssd.x) / 2;   // centred between the left wall and the Pi
ssd_y1 = floor_d - 3;                  // USB-C end; keeps the rear fences on the plate
ssd_y0 = ssd_y1 - ssd.y;
ssd_cx = ssd_x0 + ssd.x / 2;
// SSD cable pass-through: behind the straight USB-C plug, clear of the data raceway hook
ssd_slot = [24, D - 10 - (ssd_y1 + 22)];
ssd_slot_x0 = max(ssd_cx - ssd_slot.x / 2, wall + raceway_w + 6);
ssd_slot_y0 = ssd_y1 + 22;

echo(str("Footprint W x D x H = ", W, " x ", D, " x ", total_h, " mm"));
echo(str("Module heights: tray ", tray_h, ", bay ", bay_h, ", deck ", deck_h, ", lid ", lid_h));
echo(str("M4 threaded rod length = ", rod_len, " mm (x4), tolerance +0.5 / -1"));

// 2D (u, v) -> 3D maps for extruding 2D patterns through walls
M_YZ = [[0, 0, 1, 0], [1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1]];  // u -> y, v -> z, extrude -> x
M_XZ = [[1, 0, 0, 0], [0, 0, 1, 0], [0, 1, 0, 0], [0, 0, 0, 1]];  // u -> x, v -> z, extrude -> y

// ---------------------------------------------------------------- shared features

// Flat-topped hexagons (printable upright without supports), only whole cells, centred in `size`.
module honeycomb(size) {
    dx = hex_a * sqrt(3) / 2;
    nu = floor((size.x - 2 * hex_r) / dx) + 1;
    ne = floor((size.y - 2 * hex_rho) / hex_a) + 1;
    no = nu > 1 ? floor((size.y - 2 * hex_rho - hex_a / 2) / hex_a) + 1 : 0;
    top = max(2 * hex_rho + (ne - 1) * hex_a, no > 0 ? hex_a / 2 + (no - 1) * hex_a + 2 * hex_rho : 0);
    u0 = (size.x - ((nu - 1) * dx + 2 * hex_r)) / 2 + hex_r;
    v0 = (size.y - top) / 2 + hex_rho;
    if (nu > 0 && ne > 0)
        for (i = [0 : nu - 1]) let(n = i % 2 ? no : ne) if (n > 0)
            for (j = [0 : n - 1])
                translate([u0 + i * dx, v0 + j * hex_a + (i % 2) * hex_a / 2]) circle(r = hex_r, $fn = 6);
}

module rod_holes(h) {
    for (p = rod_xy) translate([p.x, p.y, -1]) cylinder(d = rod_d, h = h + 2);
}

module nut_recesses() {
    for (p = rod_xy) translate([p.x, p.y, -eps]) rotate(30) cylinder(d = nut_af / cos(30), h = nut_h, $fn = 6);
}

module corner_chamfers(h) {
    for (x = [0, W]) for (y = [0, D])
        translate([x, y, h / 2]) rotate(45) cube([chamfer * sqrt(2), chamfer * sqrt(2), h + 2], center = true);
}

// hook-and-loop strap slits through the side walls in the rear cable zone (0 = left, 1 = right)
module strap_slits(h, sides = [0, 1]) {
    sh = min(22, h - 8);
    for (m = sides) for (y = [floor_d + 10, floor_d + 30])
        translate([m ? W - wall - 1 : -1, y, (h - sh) / 2]) cube([wall + 2, 3, sh]);
}

// Solid front pillar + honeycomb panel + solid rear exhaust baffle
module side_walls(h) {
    z0 = floor_t + 3;
    z1 = h - 5;
    for (x = [0, W - wall]) translate([x, 0, 0]) difference() {
        cube([wall, D, h]);
        translate([-1, pillar_d, z0]) multmatrix(M_YZ) linear_extrude(wall + 2) honeycomb([baffle_y - pillar_d, z1 - z0]);
    }
}

// J-shaped hooks forming the vertical raceways at the rear corners (0 = left/data, 1 = right/power)
module rear_hooks(h, sides = [0, 1]) {
    for (m = sides) translate([m ? W : 0, 0, 0]) mirror([m, 0, 0]) {
        translate([wall - eps, D - 4, 0]) cube([raceway_w + 4, 4, h]);
        translate([wall + raceway_w, D - 16, 0]) cube([4, 12, h]);
    }
}

module raceway_cutouts() {
    for (m = [0, 1]) translate([m ? W : 0, 0, 0]) mirror([m, 0, 0])
        translate([wall - eps, floor_d, -1]) cube([raceway_w + eps, D - 4 - floor_d, floor_t + 2]);
}

module tie_bar() {
    translate([wall - eps, D - 6, 0]) cube([W - 2 * wall + 2 * eps, 6, floor_t]);
}

module floor_plate() {
    cube([W, floor_d, floor_t]);
}

// ---------------------------------------------------------------- printable parts

// The brick runs almost the full depth, so the tray floor does too. Only the power raceway
// passes through it; the data raceway ends on top of the trays and leaves the rack at the rear.
module tray() {
    difference() {
        union() {
            cube([W, D, floor_t]);
            side_walls(tray_h);
            rear_hooks(tray_h, [1]);
            // hex front grille hides the cable spool and feeds cool air to the brick
            translate([wall - eps, 0, 0]) cube([pocket_w + 2 * eps, 3, tray_h]);
            // ribs under the brick
            for (x = [bx0 + 4, bx0 + brick.x / 2 - 1, bx0 + brick.x - 6])
                translate([x, by0, floor_t - eps]) cube([2, brick.y, rib_h + eps]);
            // divider between brick and service lane
            translate([bx0 + brick.x + 1, by0, floor_t - eps]) cube([2, brick.y, rib_h + 10]);
            // front and rear corner stops; the DC cable and the AC plug pass between them
            for (x = [bx0, bx0 + brick.x - 12]) {
                translate([x, by0 - 3, floor_t - eps]) cube([12, 3, rib_h + 8]);
                translate([x, by0 + brick.y, floor_t - eps]) cube([12, 3, rib_h + 8]);
            }
            // hollow spool drums with chamfered caps (print without supports)
            for (y = spool_y) translate([lane_xc, y, floor_t - eps]) difference() {
                union() {
                    cylinder(d = spool_d, h = spool_h);
                    translate([0, 0, spool_h - eps]) cylinder(d1 = spool_d, d2 = spool_d + 8, h = 4);
                }
                translate([0, 0, eps]) cylinder(d = spool_d - 2 * spool_wall, h = spool_h + 5);
            }
        }
        rod_holes(tray_h);
        nut_recesses();
        strap_slits(tray_h, [1]);  // the brick covers the left wall
        corner_chamfers(tray_h);
        // power raceway passes through the floor
        translate([W - wall - raceway_w, floor_d, -1]) cube([raceway_w + eps, D - 4 - floor_d, floor_t + 2]);
        // floor vents under the brick, between the ribs
        for (i = [0 : 3]) translate([bx0 + 9 + i * 15, by0 + 8, -1]) cube([6, brick.y - 16, floor_t + 2]);
        // grille
        translate([wall + 6, -1, floor_t + 3]) multmatrix(M_XZ) linear_extrude(5) honeycomb([pocket_w - 12, tray_h - floor_t - 8]);
    }
}

module bay() {
    difference() {
        union() {
            floor_plate();
            side_walls(bay_h);
            rear_hooks(bay_h);
            tie_bar();
            // corner stops locate the Atom body; the centre stays clear for its front/bottom intake
            for (m = [0, 1]) translate([m ? W : 0, 0, 0]) mirror([m, 0, 0]) {
                translate([wall - eps, 0, floor_t - eps]) cube([stop_w, front_frame, stop_h]);
                translate([wall - eps, atom_y1 + clr, floor_t - eps]) cube([stop_w, 6, stop_h]);
            }
        }
        rod_holes(bay_h);
        strap_slits(bay_h);
        corner_chamfers(bay_h);
    }
}

module deck() {
    fence_x0 = wall + raceway_w + 4;
    difference() {
        union() {
            // full-depth plate: heat shield over the upper Atom + exhaust hood over the rear zone
            cube([W, D, floor_t]);
            // pillars carry the rods; the middle edges stay open for air and plug access
            for (x = [0, W - wall]) {
                translate([x, 0, 0]) cube([wall, 22, deck_h]);
                translate([x, baffle_y, 0]) cube([wall, D - baffle_y, deck_h]);
            }
            rear_hooks(deck_h);
            // plume fence closes the rear between the raceway hooks
            translate([fence_x0 - eps, D - 4, 0]) cube([W - 2 * fence_x0 + 2 * eps, 4, deck_h]);
            // front lip
            translate([wall - eps, 0, 0]) cube([pocket_w + 2 * eps, 4, lip_h]);
            // Pi 5 standoffs (M2.5 thread-forming screws); 6 mm matches the board's keep-out pads
            for (p = pi_holes()) translate([p.x, p.y, floor_t - eps]) cylinder(d = 6, h = 6);
            // SSD ribs + corner fences
            for (x = [ssd_x0 + 5, ssd_cx - 1, ssd_x0 + ssd.x - 7])
                translate([x, ssd_y0 + 5, floor_t - eps]) cube([2, ssd.y - 10, ssd_rib_h + eps]);
            ssd_fences();
        }
        rod_holes(deck_h);
        strap_slits(deck_h);
        corner_chamfers(deck_h);
        raceway_cutouts();
        for (p = pi_holes()) translate([p.x, p.y, 1.5]) cylinder(d = 2.3, h = 10);
        // strap slots straddling the SSD
        for (x = [ssd_x0 - 6, ssd_x0 + ssd.x + 3])
            translate([x, ssd_y0 + ssd.y / 2 - 11, -1]) cube([3, 22, floor_t + 2]);
        // pass-through for the SSD cable down to an Atom
        translate([ssd_slot_x0, ssd_slot_y0, -1]) cube([ssd_slot.x, ssd_slot.y, floor_t + 2]);
        if (label != "")
            translate([W / 2, 0.8, lip_h / 2]) rotate([90, 0, 0]) linear_extrude(2)
                text(label, size = 5, font = "Liberation Sans:style=Bold", halign = "center", valign = "center");
    }
}

// Sits on the deck pillars, clamped by the same rods (acorn nuts on top). Open front and sides,
// honeycomb top (~70 % open) for the Pi fan intake; the solid rear skirt extends the plume fence.
module lid() {
    difference() {
        union() {
            for (x = [0, W - wall]) {
                translate([x, 0, 0]) cube([wall, 22, lid_h]);
                translate([x, baffle_y, 0]) cube([wall, D - baffle_y, lid_h]);
            }
            translate([0, D - 4, 0]) cube([W, 4, lid_h]);
            // perimeter beams + top plate
            translate([0, 0, lid_h - lid_frame]) difference() {
                cube([W, D, lid_frame]);
                translate([wall, 8, -1]) cube([W - 2 * wall, D - 12, lid_frame - lid_t + 1]);
            }
        }
        rod_holes(lid_h);
        corner_chamfers(lid_h);
        translate([wall + 3, 11, lid_h - lid_t - 1]) linear_extrude(lid_t + 2) honeycomb([W - 2 * wall - 6, D - 18]);
    }
}

function pi_holes() = [
    for (px = [pi_hole_inset, pi_hole_inset + pi_hole_dx])
        for (py = [pi_hole_inset, pi_hole_inset + pi_hole_dy])
            [pi_x1 - py, pi_y0 + px]
];

module ssd_fences() {
    g = 0.6; t = 2; l = 14; h = ssd_rib_h + 6;
    x0 = ssd_x0 - g - t; y0 = ssd_y0 - g - t;
    x1 = ssd_x0 + ssd.x + g; y1 = ssd_y0 + ssd.y + g;
    for (c = [[x0, y0, 1, 1], [x1, y0, -1, 1], [x0, y1, 1, -1], [x1, y1, -1, -1]])
        translate([c[0], c[1], floor_t - eps]) {
            translate([c[2] > 0 ? 0 : t - l, 0, 0]) cube([l, t, h]);
            translate([0, c[3] > 0 ? 0 : t - l, 0]) cube([t, l, h]);
        }
}

// ---------------------------------------------------------------- reference models (not printed)

atom_ports = [ // [local x from Atom's left seen from front, width, height, colour] (illustrative)
    [ 22, 18, 11, "silver"],    // QSFP112 #2
    [ 44, 18, 11, "silver"],    // QSFP112 #1
    [ 66, 16, 13, "silver"],    // 10GbE RJ45
    [ 84, 15,  6, "silver"],    // HDMI
    [ 98,  9,  3.5, "silver"],  // USB-C
    [108,  9,  3.5, "silver"],  // USB-C
    [118,  9,  3.5, "silver"],  // USB-C
    [128,  9,  3.5, "orange"],  // USB-C PD-in (power)
    [140,  6,  6, "green"],     // power button
];
port_z = 16;

module atom_model() {
    color([0.12, 0.12, 0.13]) difference() {
        translate([0, 0, 4]) cube([atom.x, atom.y, atom.z - 4]);
        for (x = [12 : 6 : atom.x - 12]) translate([x, -1, 12]) cube([3, 2, atom.z - 20]);
    }
    color([0.2, 0.2, 0.2]) translate([8, 8, 0]) cube([atom.x - 16, atom.y - 16, 4.01]);
    for (p = atom_ports) color(p[3]) translate([p[0] - p[1] / 2, atom.y - 0.5, port_z - p[2] / 2]) cube([p[1], 1.5, p[2]]);
}

module brick_model() {
    color([0.08, 0.08, 0.08]) cube(brick);
}

module pi_model() {
    color("green") translate([pi_x0, pi_y0, 0]) cube([pi_board.y, pi_board.x, 1.6]);
    color([0.25, 0.25, 0.28]) translate([pi_x0 + 8, pi_y0 + 8, 1.6]) cube([40, 45, 13.7]);  // Active Cooler
    color("silver") {
        translate([pi_x1 - 19, pi_y1 - 17, 1.6]) cube([16, 19, 14]);      // Ethernet (power-edge side on the Pi 5)
        translate([pi_x1 - 36, pi_y1 - 17, 1.6]) cube([14, 19, 16]);      // USB
        translate([pi_x1 - 54, pi_y1 - 17, 1.6]) cube([14, 19, 16]);      // USB
        translate([pi_x1 - 7, pi_y0 + 7, 1.6]) cube([8, 9, 3.5]);         // USB-C power
    }
}

module ssd_model() {
    color([0.3, 0.31, 0.33]) translate([ssd_x0, ssd_y0, 0]) cube(ssd);
}

module cable(pts, d = 5, c = "orange") {
    color(c) for (i = [0 : len(pts) - 2]) hull() {
        translate(pts[i]) sphere(d = d, $fn = 12);
        translate(pts[i + 1]) sphere(d = d, $fn = 12);
    }
}

// polyline with an arrow head on the last segment
module arrow(pts, c, d = 4) {
    a = pts[len(pts) - 2];
    v = pts[len(pts) - 1] - a;
    L = norm(v);
    color(c) {
        if (len(pts) > 2) cable([for (i = [0 : len(pts) - 2]) pts[i]], d, c);
        translate(a) rotate([0, acos(v.z / L), atan2(v.y, v.x)]) {
            cylinder(d = d, h = L - 3 * d, $fn = 12);
            translate([0, 0, L - 3 * d]) cylinder(d1 = 2.6 * d, d2 = 0, h = 3 * d, $fn = 16);
        }
    }
}

function spool_loop(z, r) = [
    for (a = [180 : 30 : 360]) [lane_xc + r * cos(a), spool_y[0] + r * sin(a), z],
    for (a = [0 : 30 : 180]) [lane_xc + r * cos(a), spool_y[1] + r * sin(a), z],
];

function stack_z(gap = 0) = [0, tray_h + gap, 2 * (tray_h + gap), 2 * (tray_h + gap) + bay_h + gap,
                             2 * (tray_h + gap) + 2 * (bay_h + gap), 2 * (tray_h + gap) + 2 * (bay_h + gap) + deck_h + gap];

// ---------------------------------------------------------------- assembly

module stack(gap = 0, cables = true, with_lid = true) {
    z = stack_z(gap);
    pc = [0.88, 0.88, 0.9];

    color(pc) translate([0, 0, z[0]]) tray();
    color(pc) translate([0, 0, z[1]]) tray();
    color(pc) translate([0, 0, z[2]]) bay();
    color(pc) translate([0, 0, z[3]]) bay();
    color(pc) translate([0, 0, z[4]]) deck();
    if (with_lid) color(pc) translate([0, 0, z[5]]) lid();

    for (t = [0, 1]) translate([bx0, by0, z[t] + floor_t + rib_h]) brick_model();
    for (b = [2, 3]) translate([wall + clr, front_frame, z[b] + floor_t]) atom_model();
    translate([0, 0, z[4] + floor_t + 6]) pi_model();
    translate([0, 0, z[4] + floor_t + ssd_rib_h]) ssd_model();

    if (gap == 0) color("silver") for (p = rod_xy) translate([p.x, p.y, rod_z0]) cylinder(d = 4, h = rod_len);

    if (gap == 0 && cables) {
        rx_p = W - wall - raceway_w / 2;   // power raceway centre
        rx_d = wall + raceway_w / 2;       // data raceway centre
        ry = D - 22;
        ax = wall + clr;
        rs = spool_d / 2 + 3;              // cable centreline radius on the spool drums

        for (k = [0, 1]) {
            zb = z[k] + floor_t + rib_h + brick.z / 2;
            zp = z[2 + k] + floor_t + port_z;
            // USB-C 240 W: brick front -> spool (2.5 turns shown) -> lane -> power raceway -> PD-in
            cable(concat(
                [[bx0 + brick.x / 2, by0, zb], [bx0 + brick.x / 2, by0 - 14, zb], [lane_xc - rs, spool_y[0], zb]],
                spool_loop(zb - 3, rs), spool_loop(zb + 3, rs),
                [for (a = [180 : 30 : 360]) [lane_xc + rs * cos(a), spool_y[0] + rs * sin(a), zb + 3]],
                [[lane_xc + rs, spool_y[1] + 10, zb], [rx_p, ry, zb], [rx_p, ry, zp],
                 [ax + 128, atom_y1 + 30, zp], [ax + 128, atom_y1, zp]]), 5, "orange");
            // AC (C5 -> C6) out the back
            cable([[bx0 + brick.x / 2, by0 + brick.y, zb], [bx0 + brick.x / 2, D + 20, zb], [bx0 + brick.x / 2, D + 40, 0]], 6, [0.05, 0.05, 0.05]);
            // 10GbE: RJ45 -> data raceway -> down to the top of the trays -> out past the hook
            cable([[ax + 66, atom_y1, zp], [ax + 66, atom_y1 + 30, zp], [rx_d, ry, zp - 6], [rx_d, ry, z[2] + 8 + 5 * k],
                   [wall + raceway_w + 12, ry, z[2] + 8 + 5 * k], [wall + raceway_w + 12, D + 40, z[2] + 4 + 5 * k]], 5, "gold");
        }

        // QSFP112 DAC between the Atoms: U-loop in the open centre
        z1 = z[2] + floor_t + port_z; z2 = z[3] + floor_t + port_z; zm = (z1 + z2) / 2; rr = (z2 - z1) / 2;
        cable(concat([[ax + 44, atom_y1, z1], [ax + 44, atom_y1 + 45, z1]],
                     [for (a = [-90 : 30 : 90]) [ax + 44, atom_y1 + 45 + rr * cos(a), zm + rr * sin(a)]],
                     [[ax + 44, atom_y1, z2]]), 7, "royalblue");

        zd = z[4] + floor_t;
        // Pi 5 USB-C power: fed from a USB-C port on the upper Atom. Plug and bend stay inside the
        // wall line; the cable runs back to the power raceway and down.
        cable([[pi_x1, pi_y0 + 11, zd + 9], [pi_x1 + 24, pi_y0 + 11, zd + 9], [W - wall - 4, pi_y0 + 26, zd + 7],
               [W - wall - 4, floor_d - 4, zd + 6], [rx_p + 6, ry + 5, zd + 2], [rx_p + 6, ry + 5, z2 + 12],
               [ax + 118, atom_y1 + 22, z2], [ax + 118, atom_y1, z2]], 4, "red");
        // Pi Ethernet: the jack sits next to the power raceway, so it goes down that one and
        // leaves the rack above the trays
        cable([[pi_x1 - 11, pi_y1, zd + 14], [pi_x1 - 11, pi_y1 + 24, zd + 12], [rx_p - 7, ry + 3, zd + 2],
               [rx_p - 7, ry + 3, z[2] + 8], [W - wall - raceway_w - 12, ry + 3, z[2] + 8],
               [W - wall - raceway_w - 12, D + 40, z[2] + 4]], 5, "gold");
        // SSD -> upper Atom USB-C (20 Gbit/s Gen 2x2 on both ends) with the bundled 30 cm C-C cable,
        // through the pass-through slot in the deck hood
        sx = ssd_slot_x0 + ssd_slot.x / 2; sy = ssd_slot_y0 + ssd_slot.y / 2;
        cable([[ssd_cx, ssd_y1, zd + ssd_rib_h + 8], [ssd_cx, ssd_y1 + 20, zd + ssd_rib_h + 8], [sx, sy, zd + 2], [sx, sy, zd - 10],
               [ax + 98, floor_d + 16, z2 + 12], [ax + 98, atom_y1 + 18, z2], [ax + 98, atom_y1, z2]], 4, "purple");
    }
}

// Side section through the Pi with the intended airflow
module airflow() {
    z = stack_z();
    xs = W - wall - 0.5; // remove the right-hand wall to look inside
    xa = xs + 3;
    cool = "deepskyblue"; hot = "orangered"; warm = "orange";
    difference() {
        stack(cables = false);
        translate([xs, -100, -10]) cube([300, 500, 500]);
    }
    for (k = [0, 1]) {
        zA = z[2 + k] + floor_t;
        top = zA + atom.z;
        arrow([[xa, -60, zA + 30], [xa, 2, zA + 30]], cool);                       // front grille
        arrow([[xa, -60, zA + 2.5], [xa, 24, zA + 2.5]], cool, 3);                // bottom-front vent
        arrow([[xa, -40, top + 10], [xa, 60, top + 10], [xa, 130, top + 10]], warm, 3); // ventilated slot
        t2 = z[3] + floor_t + atom.z;
        if (k == 0)  // rises in the open gutter, then leaves behind the rack
            arrow([[xa, atom_y1 + 2, top - 12], [xa, 190, top - 12], [xa, 200, top + 10], [xa, 200, t2 - 20],
                   [xa, 250, t2 - 5], [xa, 272, t2 + 60]], hot);
        else         // deflected rearward by the deck hood and plume fence
            arrow([[xa, atom_y1 + 2, top - 12], [xa, 205, top - 12], [xa, 232, top + 10], [xa, 250, top + 60]], hot);
    }
    for (t = [0, 1]) {
        zt = z[t] + floor_t + rib_h + brick.z + brick_air / 2;
        arrow([[xa, -60, zt], [xa, 40, zt]], cool, 3);
        arrow([[xa, 170, zt], [xa, D + 10, zt], [xa, D + 34, zt + 22]], warm, 3);
    }
    zd = z[4] + floor_t;
    arrow([[xa, pi_y0 + 32, zd + 95], [xa, pi_y0 + 32, zd + 6 + pi_height + 4]], cool);   // Pi cooler intake
    arrow([[xa, pi_y0 + 10, zd + 16], [xa, pi_y0 - 22, zd + 16]], warm, 3);              // Pi cooler outlet
}

if (part == "assembly") stack();
else if (part == "exploded") stack(40);
else if (part == "airflow") airflow();
else if (part == "tray") tray();
else if (part == "bay") bay();
else if (part == "deck") deck();
else if (part == "lid") translate([0, D, lid_h]) rotate([180, 0, 0]) lid();
