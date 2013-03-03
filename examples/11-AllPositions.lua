-- This file tests all of the acceptable values for positions on
-- screen, moving a character image around to ensure it appears in the
-- proper place for each one.

Eric = Character {
    name = "Eric",
    image = "examples/images/Eric-Normal.png",
}

START = Scene {
    name = "Position Test",
    boxBackgroundColor = Color.Transparent,
    Eric:isAt "Left",
    Pause,
    Eric:isAt "Center",
    Pause,
    Eric:isAt "Right",
    Pause,
    Eric:isAt "TopLeft",
    Pause,
    Eric:isAt "TopCenter",
    Pause,
    Eric:isAt "TopRight",
    Pause,
    Eric:isAt "BottomLeft",
    Pause,
    Eric:isAt "BottomCenter",
    Pause,
    Eric:isAt "BottomRight",
    Pause,
}
