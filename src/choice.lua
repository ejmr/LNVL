--[[
--
-- This file implements the LNVL.MenuChoice class, which represents
-- the various choices presented to players via LNVL.Menu objects.
-- This class exists primarily to provide some convenience in the
-- LNVL.Menu code by providing us ways to access the different parts
-- of a 'choice' data structure by name, and to be able to
-- differentiate them from other tables via a metatable.
--
--]]

-- Create the MenuChoice class.
local MenuChoice = {}
MenuChoice.__index = MenuChoice

-- Our constructor for the class.
function MenuChoice:new(properties)
    local choice = {}
    setmetatable(choice, MenuChoice)

    -- label: A string representing the label for this choice, i.e.
    -- the text a user would see when presented with this choice.
    choice.label = properties["label"]

    -- action: The action to execute when the user selects this
    -- choice.  This must be a function that accepts one argument, the
    -- LNVL.Scene object representing the scene containing the menu
    -- where this choice appears.  If the function returns any values
    -- then it must return either an individual LNVL.Opcode object or
    -- an array of those objects.  LNVL will process those opcodes
    -- immediately, per the LNVL.Opcode:process() method.  If the
    -- function returns no values then LNVL assumes we only execute
    -- the action for its side-effects.
    choice.action = properties["action"]

    -- Make sure the choice has the required properties.
    LNVL.Debug.Log.check(choice.label ~= nil,
                         "MenuChoice must have a label.")
    LNVL.Debug.Log.check(type(choice.action) == "function",
                         "MenuChoice action must be a function.")

    return choice
end

-- Convert a MenuChoice object to a string for debugging purposes.
MenuChoice.__tostring = function (choice)
    return string.format("<MenuChoice: %q>", choice.label)
end

-- Return the class as the module.
return MenuChoice
