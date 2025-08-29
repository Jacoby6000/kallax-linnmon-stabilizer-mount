use <Round-Anything/polyround.scad>
use <../lib/pin.scad>

include <../lib/const.scad>

function rectProfile(length, width, cornerRadius = 0) =
    [
        [0     , width, cornerRadius],
        [length, width, cornerRadius],
        [length, 0    , cornerRadius],
        [0     , 0    , cornerRadius],
    ];

module screwFlange() {
    linear_extrude(5) 
        polygon(polyRound([
            [0                  , BRACKET_DEPTH/2   , 0],
            [0                  , BRACKET_DEPTH/2   , 0],
            [BRACKET_THICKNESS  , BRACKET_DEPTH/2   , 1],
            [BRACKET_THICKNESS  , SCREW_FLANGE_DEPTH, 5],
            [SCREW_FLANGE_HEIGHT, SCREW_FLANGE_DEPTH, 5],
            [SCREW_FLANGE_HEIGHT, 0                 , 5],
            [BRACKET_THICKNESS  , 0                 , 1],
            [0,                   0                 , 1]
        ]));
}

union() {
    color("red") 
        translate([-BRACKET_THICKNESS, BRACKET_DEPTH-MOUNTING_DEPTH, 5])
            rotate([180, 0, 0])
                screwFlange();
    translate([-BRACKET_THICKNESS, -MOUNTING_DEPTH, 0]) 
        linear_extrude(BRACKET_HEIGHT) 
            polygon(polyRound(rectProfile(BRACKET_THICKNESS, BRACKET_DEPTH, 1)));
    union() {
        createPinPair(SNAP_PIN_GAP, SNAP_PIN_HEIGHT);
        translate([0, 0, BRACKET_HEIGHT - SNAP_PIN_HEIGHT]) createPinPair(SNAP_PIN_GAP, SNAP_PIN_HEIGHT);
    }
}
