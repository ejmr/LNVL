-- This file tests all of the acceptable values for positions on
-- screen, moving a character image around to ensure it appears in the
-- proper place for each one.

Eric = LNVL.Character:new{
    name = "Eric",
    image = "examples/images/Eric-Normal.png",
}

START = LNVL.Scene:new{
    name = "Position Test",
    boxBackgroundColor = LNVL.Color.Transparent,
    Eric:isAt "Left",
    "",
    Eric:isAt "Center",
    "",
    Eric:isAt "Right",
    "",
    Eric:isAt "TopLeft",
    "",
    Eric:isAt "TopCenter",
    "",
    Eric:isAt "TopRight",
    "",
    Eric:isAt "BottomLeft",
    "",
    Eric:isAt "BottomCenter",
    "",
    Eric:isAt "BottomRight",
    "",
}
