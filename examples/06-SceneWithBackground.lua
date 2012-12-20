-- This example script tests the support for background images in
-- scenes and drawing them to screen.  It will also provide a way to
-- test how we control the color of the container for dialog so that
-- it fits well with the background.

START = LNVL.Scene:new{
    "What a nice day!",
}

START.background = "images/Sunny-Hill.jpg"
