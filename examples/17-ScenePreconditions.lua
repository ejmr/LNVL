--[[

This example tests preconditions for scenes.  It should not be
possible to entire a scene until the user has viewed all pre-requisite
scenes.

--]]

Eric = Character { dialogName = "Eric", textColor = "Black" }

START = Scene {
    Eric "Testing switching scenes with preconditions.",
    Eric "Since we always must begin with START it is always a valid precondition.",
    -- Changing "ROOM" below to "BATHROOM" should always fail.
    ChangeToScene "ROOM"
}

ROOM = Scene {
    Eric "Now I am in a room, about to enter the bathroom.",
    ChangeToScene "BATHROOM"
}

BATHROOM = Scene {
   preconditions = {
      "ROOM",
      -- This function has the same effect as if we simply entered the
      -- string "START" as a precondition, but we use this convoluted
      -- approach to test using functions for preconditions.
      function (scene) return LNVL.VisitedScenes["START"] == true end,
   },
   Eric "And now I enter the bathroom."
}
