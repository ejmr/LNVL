--[[
    --
    -- This file implements the instruction engine portion of LNVL.  See
    -- the document
    --
    --     docs/Instructions.md
    --
    -- for details about this system and its design.
    --
--]]

-- Create our LNVL.Instruction class.
LNVL.Instruction = {}
LNVL.Instruction.__index = LNVL.Instruction

-- This is a list of all the valid instructions.
LNVL.Instruction.ValidInstructions = {
    ["say"] = true,
    ["set-image"] = true,
    ["draw-image"] = true,
    ["set-scene"] = true,
}

-- Our constructor.  It requires a table with two properties, named
-- and defined in comments within the constructor.
function LNVL.Instruction:new(properties)
    local instruction = {}
    setmetatable(instruction, LNVL.Instruction)
    assert(LNVL.Instruction.ValidInstructions[properties.name] ~= nil,
           string.format("Unknown instruction %s", properties.name))

    -- name: The name of the instruction as a string.
    instruction.name = properties.name

    -- action: A function representing the logic for the instruction.
    instruction.action = properties.action

    return instruction
end

-- This function takes the name of an LNVL.Opcode as a string and
-- returns the LNVL.Instruction to execute for that opcode.  We need
-- this function because there is not a one-to-one mapping between
-- opcodes and instructions.
function LNVL.Instruction.getForOpcode(name)
    local map = {
        ["monologue"] = "say",
        ["say"] = "say",
        ["set-character-image"] = "set-image",
        ["draw-character"] = "draw-image",
        ["change-scene"] = "set-scene",
    }

    return LNVL.Instructions[map[name]]
end

-- A simple tostring() method for debugging purposes, which does
-- nothing but returns the name of the instruction.
LNVL.Instruction.__tostring = function (instruction)
    return string.format("<Instruction %s>", instruction.name)
end

-- We define a __call() metatable method as a shortcut for executing
-- the 'action' function of an instruction.
LNVL.Instruction.__call = function (f, ...)
    if type(f) == "function" then
        return f(...)
    else
        return f.action(...)
    end
end

-- This table contains all of the instructions in the LNVL engine.
-- The keys for the table are strings, the names of the instructions.
-- The values are the LNVL.Instruction objects themselves.
--
-- All of the individual instructions defined below are described in
-- detail by the HTML document referenced at the top of this file.
-- None of the instruction action functions return values.
LNVL.Instructions = {}

LNVL.Instructions["say"] = LNVL.Instruction:new{
    name = "say",
    action = function (arguments)
        local text = arguments.content

        -- If the text is spoken by a character then we can
        -- add additional formatting to the output, such as
        -- the character's name.
        if arguments["character"] ~= nil then
            text = {
                arguments.character.color,
                string.format("%s: %s",
                              arguments.character.name,
                              arguments.content)
            }
        end

        arguments.scene:drawText(text)
    end }


LNVL.Instructions["set-image"] = LNVL.Instruction:new{
    name = "set-image",
    action = function (arguments)
        local targetType = getmetatable(arguments.target)

        -- If the target is a Character then we change their
        -- 'currentImage' to the new one in the instruction.
        if targetType == LNVL.Character then
            arguments.target.currentImage = arguments.image
        else
            -- If we reach this point then it is an error.
            error(string.format("Cannot set-image for %s", targetType))
        end
    end }

LNVL.Instructions["draw-image"] = LNVL.Instruction:new{
    name = "draw-image",
    action = function (arguments)
        love.graphics.setColorMode("replace")
        love.graphics.draw(arguments.image,
                           arguments.location[1],
                           arguments.location[2])
    end }

LNVL.Instructions["set-scene"] = LNVL.Instruction:new{
    name = "set-scene",
    action = function (arguments)
        local scene = _G[arguments.name]
        assert(scene ~= nil and getmetatable(scene) == LNVL.Scene,
               "Cannot load scene " .. arguments.name)
        LNVL.currentScene = scene
    end }

-- If LNVL is running in debugging mode then make sure that every
-- instruction we list as valid has a match LNVL.Instruction object
-- that implements it.
if LNVL.Settings.DebugModeEnabled == true then
    for name,_ in pairs(LNVL.Instruction.ValidInstructions) do
        if LNVL.Instructions[name] == nil then
            error("No implementation for the instruction " .. name)
        end
    end
end

-- Return our class as a module.
return LNVL.Instruction
