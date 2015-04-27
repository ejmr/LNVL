--[[

-- This file tests using functions to create scene content.

--]]

Lobby = Character { dialogName="Lobby", textColor="#a66" }
Lobby.lazy = true

START = Scene {
    "What to do today...",
    function ()
        if Lobby.lazy == true then
            return Lobby:says("Eh, nothing.  Too lazy!")
        else
            return Lobby:says("Maybe some actual work?")
        end
    end,
    function () return "And thus the lobster made his decision." end
}
