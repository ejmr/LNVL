-- This file tests all of the acceptable values for positions on
-- screen, moving a character image around to ensure it appears in the
-- proper place for each one.

Eric = Character{
    name = "Eric",
    image = "examples/images/Eric-Normal.png",
}

START = Scene{
    name = "Position Test",
    boxBackgroundColor = Color.Transparent,
    Eric:isAt "Left",
    LNVL.Scene.Pause,
    Eric:isAt "Center",
    LNVL.Scene.Pause,
    Eric:isAt "Right",
    LNVL.Scene.Pause,
    Eric:isAt "TopLeft",
    LNVL.Scene.Pause,
    Eric:isAt "TopCenter",
    LNVL.Scene.Pause,
    Eric:isAt "TopRight",
    LNVL.Scene.Pause,
    Eric:isAt "BottomLeft",
    LNVL.Scene.Pause,
    Eric:isAt "BottomCenter",
    LNVL.Scene.Pause,
    Eric:isAt "BottomRight",
    LNVL.Scene.Pause,
}
