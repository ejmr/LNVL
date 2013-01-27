-- This example script tests the engine with regard to setting
-- character positions and then changing them within a scene.

Eric = LNVL.Character:new{
    name = "Eric",
    textColor = "#333",
    image = "examples/images/Eric-Normal.png",
    position = "Left",
}

START = LNVL.Scene:new{
    Eric "So I am starting out on the left.  Time to move.",
    Eric:isAt "Center",
    Eric "Halfway to the right side now.  Almost there!",
    Eric:isAt "Right",
    Eric:becomes("examples/images/Eric-Surprised.png"),
    Eric "At last!  At last!  To the right at last!",
    Eric "Wait---is that an inappropriate reference?",
}

START:setBackground "examples/images/Sunny-Hill.jpg"
