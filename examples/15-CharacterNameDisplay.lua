--[[

This file tests the engine’s ability to change the visual properties
of character names in scenes.  We test changing the color of the name
and its font.
    
--]]

Ben = Character {
    dialogName = "SIben",
    textColor = Color.SlateBlue
}

-- Quotes taken from a humorous conversation with Ben.
START = Scene {
    Ben "Let me be a tsundere man.",
    Ben:changeTextColor(Color.Black),
    Ben:changeFont("examples/fonts/bloodcrow", 16),
    Ben "Cocaine is really awesome.  I should do cocaine."
}
