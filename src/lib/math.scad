function translateVector3s(vectors, translation) =
    [for (v = vectors) [v.x + translation.x, v.y + translation.y, v.z + translation.z]];

function translateVector2s(vectors, translation) =
    translateVector3s(vectors, [translation.x, translation.y, 0]);

function multiplyVector3s(vectors, factor) =
    [for (v = vectors) [v.x * factor.x, v.y * factor.y, v.z * factor.z]];

function multiplyVector2s(vectors, factor) =
    multiplyVector3s(vectors, [factor.x, factor.y, 1]);

