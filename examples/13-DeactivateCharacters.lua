-- This script tests the behavior of the leavesTheScene() method,
-- which tells LNVL that a character is no longer activate and that it
-- should stop drawing that character to the screen.

Eric = Character {
    name = "Eric",
    textColor = Color.NavyBlue,
    image = "examples/images/Eric-Normal.png",
    position = "Left",
}

Jeff = Character {
    name = "Jeff",
    textColor = Color.IndianRed4,
    image = "examples/images/Jeff-Normal.png",
    position = "Right",
}

START = Scene {
    name = "Character Deactivation Test",
    Eric "Why is our game not finished yet?",
    Jeff "Hey have you played the new Skyrim DLC?",
    Eric "Well no wonder our game isn't finished...",
    Jeff:leavesTheScene(),
    Eric "...Hey, what?  Stop playing Skyrim and come back and finish our game already!",
}
