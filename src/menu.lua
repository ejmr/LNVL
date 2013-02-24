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

    -- currentChoiceIndex: An integer representing the currently
    -- selected choice, or nil if there is no selected choice.  In
    -- this context 'selected' does not mean that the player has
    -- confirmed that he wants to make the given choice.  'Selected'
    -- only tells us what choice is currently under consideration,
    -- e.g.  what choice the mouse cursor is hovering over at the
    -- current moment.
    menu.currentChoiceIndex = nil

    -- We treat the entries in 'properties' as an array of tables,
    -- which we turn into choices.  Each table must be an array with
    -- two elements:
    --
    -- 1. The label for the choice as a string.
    --
    -- 2. The action to perform for that choice, as a function.  But
    -- we also allow strings here.  If the value is a string then we
    -- treat that as the name of a scene and assign the action an
    -- anonymous function which returns an opcode to switch to that
    -- scene later.  See the documentation for the LNVL.MenuChoice
    -- constructor, specifically for the 'action' property, for more
    -- details about this function.
    --
    -- We raise an error for any table that does not meet these
    -- criteria, although the MenuChoice class performs some of this
    -- error-checking for us.

    local choices = {}

    for _,value in pairs(properties) do
        assert(type(value) == "table" and #value >= 2,
              "Invalid data for a menu choice.")

        local action

        if type(value[2]) == "string" then
            action = function (scene)
                return LNVL.Opcode:new("change-scene", value[2])
            end
        else
            action = value[2]
        end

        table.insert(choices,
                    LNVL.MenuChoice:new{ label=value[1], action=action })
    end

    -- Finally assign the collected array of 'choices' to the menu,
    -- but we make it a clamped array so that we cannot accidentally
    -- access any elements out of bounds.
    menu.choices = LNVL.ClampedArray(choices)

    return menu
end

-- These two methods move forward and backward through the available
-- menu choices.  They will return an integer, the index of the newly
-- selected choice.  That way callers can use that information to
-- update the display of a menu on screen, for example.

function LNVL.Menu:moveForward()
    if self.currentChoiceIndex == nil then
        self.currentChoiceIndex = 1
    elseif self.currentChoiceIndex < #self.choices then
        self.currentChoiceIndex = self.currentChoiceIndex + 1
    end

    return self.currentChoiceIndex
end

function LNVL.Menu:moveBack()
    if self.currentChoiceIndex == nil then
        self.currentChoiceIndex = #self.coiches
    elseif self.currentChoiceIndex > 1 then
        self.currentChoiceIndex = self.currentChoiceIndex - 1
    end

    return self.currentChoiceIndex
end

-- Return the class as the module.
return LNVL.Menu
