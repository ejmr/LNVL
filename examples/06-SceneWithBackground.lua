-- This example script tests the support for background images in
-- scenes and drawing them to screen.  It will also provide a way to
-- test how we control the color of the container for dialog so that
-- it fits well with the background.

START = Scene{
    "What a nice day!",
    ChangeToScene "SPACE",
}

START:setBackground "examples/images/Sunny-Hill.jpg"

-- This scene shows how we can also define the background image as the
-- first part of the Scene data, before any content.

SPACE = Scene{
    background = "examples/images/Celestial-Background.jpg",
    "A nice day in space?",
}
