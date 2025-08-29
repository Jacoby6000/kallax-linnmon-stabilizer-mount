use <Round-Anything/polyround.scad>
include <./const.scad>
include <./math.scad>

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


