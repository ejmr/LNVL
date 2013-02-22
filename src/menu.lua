--[[
--
-- This file implements the LNVL.Menu class.  It provides dialog
-- scripts with a way of presenting a list of choices to the player,
-- mapping those choices to different effects such as changing scenes.
--
--]]

-- Create the LNVL.Menu class.
LNVL.Menu = {}
LNVL.Menu.__index = LNVL.Menu

-- Load the LNVL.MenuChoice class so that we can use it.
require("src.choice")

-- Our constructor for the LNVL.Menu class.  It accepts a table of
-- properties to set, assigns those to the new Menu object, and
-- returns it.
function LNVL.Menu:new(properties)
    local menu = {}
    setmetatable(menu, LNVL.Menu)
    return menu
end

-- Return the class as the module.
return LNVL.Menu
