-- This script tests the use of borders around character images.  And
-- it muses about the possible greatness of LNVL and my own amazing,
-- sordid ego.

Eric = Character{
    name = "Eric",
    textColor = LNVL.Color.SlateBlue,
    borderColor = LNVL.Color.NavyBlue,
    borderSize = 5,
    image = "examples/images/Eric-Normal.png",
}

START = Scene{
    Eric "I wonder if someone will use this engine for any eroge.",
    Eric "I would take that as a compliment.",
    Eric "\"I don't see your code powering erotic adult visual novels!\"",
    Eric "Yes, huge bragging potential there.",
}

START:setBackground "examples/images/Celestial-Background.jpg"
