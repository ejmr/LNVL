-- This example script demonstrates how to change scenes.

Voice = Character { dialogName="Mysterious Voice", textColor="#600" }

-- Uncomment one (and only one) of these to see the different results
-- of changing scenes at the end of the OUTSIDE_DOOR scene.
Player = Character { dialogName="Eric" }
-- Player = Character { dialogName="Lobby" }
-- Player = Character { dialogName="Mitch Xadrian" }

START = Scene {
   "There is a suspicious door before you.",
   ChangeToScene "OUTSIDE_DOOR",
}

OUTSIDE_DOOR = Scene {
   Voice "Who is it?",
   "You respond with your name.",
   ChangeToScene(function ()
	 if Player.dialogName == "Eric" then
	    return "GREET_ERIC"
	 elseif Player.dialogName == "Lobby" then
	    return "GREET_LOBBY"
	 else
	    return "GREET_EVERYONE_ELSE"
	 end
   end),
}

GREET_ERIC = Scene { Voice "Nice to see, come on in!" }

GREET_LOBBY = Scene { Voice "Get out of here you free-loading bum!" }

GREET_EVERYONE_ELSE = Scene { Voice "Don't know you.  Get Lost." }
