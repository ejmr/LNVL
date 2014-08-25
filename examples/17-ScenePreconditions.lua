--[[

This example tests preconditions for scenes.  It should not be
possible to entire a scene until the user has viewed all pre-requisite
scenes.

--]]

Eric = Character { dialogName = "Eric", textColor = "Black" }

START = {
    Eric "Testing switching scenes with preconditions.",
    Eric "Since we always must begin with START it is always a valid precondition.",
    ChangeToScene "ROOM"
}

ROOM = {
    Eric "Now I am in a room, about to enter the bathroom."
}

BATHROOM = {
    preconditions = { "ROOM "},
    Eric "And now I enter the room from the bathroom."
}
