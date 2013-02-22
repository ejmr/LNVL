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

    -- choices: An array of all of the choices available in this menu.
    -- Each element is an LNVL.MenuChoice object.
    menu.choices = {}

    -- Overwrite any default property values above with ones given to
    -- the constructor.
    for name,value in pairs(properties) do
        if rawget(menu, name) ~= nil then
            rawset(menu, name, value)
        end
    end

    -- We treat the remaining entries in 'properties' as an array of
    -- tables, which we turn into choices.  Each table must be an
    -- array with two elements:
    --
    -- 1. The label for the choice as a string.
    --
    -- 2. The action to perform for that choice, as a function.  See
    -- the documentation for the LNVL.MenuChoice:new() method,
    -- specifically for the 'action' property, for more details about
    -- this function.
    --
    -- We raise an error for any table that does not meet these
    -- criteria, although the MenuChoice class performs some of this
    -- error-checking for us.
    for _,value in pairs(properties) do
        assert(type(value) == "table" and #value >= 2,
              "Invalid data for a menu choice.")
        table.insert(menu.choices,
                    LNVL.MenuChoice:new{ label=value[1], action=value[2] })
    end

    return menu
end

-- Return the class as the module.
return LNVL.Menu
