-- This example script demonstrates how to change scenes.

START = Scene{
    "This is the start of our story.",
    "Spoiler alert: it is extremely boring.",
    "But we do have...",
    changeToScene "FIELD",
}

FIELD = Scene{
    "...a field background!",
}

FIELD:setBackground "examples/images/Sunny-Hill.jpg"
