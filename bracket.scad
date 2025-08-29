use <Round-Anything/polyround.scad>

BRACKET_INNER_CHANNEL_NARROW = 6.75;
CUBBY_WIDTH = 336;
BRACKET_DEPTH  = 50;
MOUNTING_DEPTH = 14;
BRACKET_HEIGHT = 17;
BRACKET_WIDTH = 10;
BRACKET_LIP_WIDTH = 3;
BRACKET_THICKNESS = 3;

SCREW_FLANGE_HEIGHT = 10;
SCREW_FLANGE_DEPTH = 10;

SNAP_PIN_GAP = 1.5;
SNAP_PIN_TOOTH_WIDTH = 3;
SNAP_PIN_THICKNESS = 1.5;
SNAP_PIN_LENGTH = 5;
SNAP_PIN_LIP_DEPTH = 1.75;
SNAP_PIN_HEIGHT = 5;

function translateVector3s(vectors, translation) =
    [for (v = vectors) [v.x + translation.x, v.y + translation.y, v.z + translation.z]];

function translateVector2s(vectors, translation) =
    translateVector3s(vectors, [translation.x, translation.y, 0]);

function multiplyVector3s(vectors, factor) =
    [for (v = vectors) [v.x * factor.x, v.y * factor.y, v.z * factor.z]];

function multiplyVector2s(vectors, factor) =
    multiplyVector3s(vectors, [factor.x, factor.y, 1]);


function pinProfile(pinLength, pinWidth, toothLength, toothDepth, pinEnterRadius = undef, pinExitRadius = undef) =
    let(
        actualPinEnterRadius = pinEnterRadius == undef ? pinWidth / 2 : pinEnterRadius,
        actualPinExitRadius = pinExitRadius == undef ? pinWidth / 2 : pinExitRadius,
        toothTipRadius = toothDepth / toothLength,
        centerOffset = pinWidth / 2,
        leftFlangePoint = [0, -actualPinEnterRadius, 0],
        rightFlangePoint = [0, actualPinEnterRadius + pinWidth, 0],
        toothX = pinLength - toothLength,
        toothY = pinWidth + toothDepth,


        points = [
            leftFlangePoint,
            [0        , 0       , actualPinEnterRadius],
            [pinLength, 0       , toothTipRadius      ],
            [toothX   , toothY  , 0                   ],
            [toothX   , pinWidth, toothTipRadius      ],
            [0        , pinWidth, actualPinExitRadius ],
            rightFlangePoint
        ],
        horizontallyCentered = translateVector2s(points, [0, -centerOffset])
    ) horizontallyCentered;

function rectProfile(length, width, cornerRadius = 0) =
    [
        [0     , width, cornerRadius],
        [length, width, cornerRadius],
        [length, 0    , cornerRadius],
        [0     , 0    , cornerRadius],
    ];


module createPin(extrudeHeight = 10, flip = false) {
    transformVector = flip ? [1,-1,1] : [1,1,1];
    points = multiplyVector2s(
        pinProfile(SNAP_PIN_LENGTH, SNAP_PIN_THICKNESS, SNAP_PIN_LIP_DEPTH, SNAP_PIN_TOOTH_WIDTH), 
        transformVector
    );
    linear_extrude(extrudeHeight) polygon(
        polyRound(points)
    );
}

module createPinPair(spacing, extrudeHeight) {
    union() {
        translate([0, SNAP_PIN_THICKNESS/2 + spacing/2, 0]) createPin(extrudeHeight);
        translate([0, -SNAP_PIN_THICKNESS/2 - spacing/2, 0]) createPin(extrudeHeight, true);
    }
}

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
