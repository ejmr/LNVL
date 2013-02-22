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

-- Create the LNVL.MenuChoice class.
LNVL.MenuChoice = {}
LNVL.MenuChoice.__index = LNVL.MenuChoice

-- Our constructor for the class.
function LNVL.MenuChoice:new(properties)
    local choice = {}
    setmetatable(choice, LNVL.MenuChoice)

    -- label: A string representing the label for this choice, i.e.
    -- the text a user would see when presented with this choice.
    choice.label = properties["label"]

    -- action: The action to execute when the user selects this
    -- choice.  This must be a function that accepts one argument, the
    -- LNVL.Scene object representing the scene containing the menu
    -- where this choice appears.  LNVL expects no return value from
    -- this function.
    choice.action = properties["action"]

    return choice
end

-- Return the class as the module.
return LNVL.MenuChoice
