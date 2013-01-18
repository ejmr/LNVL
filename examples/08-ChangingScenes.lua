-- This example script demonstrates how to change scenes.

START = LNVL.Scene:new{
    "This is the start of our story.",
    "Spoiler alert: it is extremely boring.",
    "But we do have...",
    LNVL.changeToScene("FIELD"),
}

FIELD = LNVL.Scene:new{
    "...a field background!",
}

FIELD:setBackground "examples/images/Sunny-Hill.jpg"
