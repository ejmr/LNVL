-- This script tests LNVL's ability to share state with another
-- program, since it's intended to be embedded in other games.

-- The file 'main.lua' defines a global 'password' variable which has
-- a definition provided outside of this script via the creation of a
-- Context object that is applied to the environment before executing
-- this script.
--
-- See the files
--
--     main.lua
--     LNVL.lua
--     src/context.lua
--
-- for more technical information.
local keyword = [["Bar"]]

START = Scene {
    "The secret keyword was " .. keyword,
    "And the full password is " .. password,
    Set { "password", "LobbyIsLongGone" },
    ChangeToScene "NEXT",
} 

NEXT = Scene {
    "The password has changed to...", Get "password"
}
