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
    ["no-op"] = true,
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
-- detail by the document referenced at the top of this file.  None of
-- the instruction action functions return values.
LNVL.Instructions = {}

LNVL.Instructions["say"] = LNVL.Instruction:new{
    name = "say",
    action = function (arguments)
        if arguments["character"] ~= nil then
            -- If the text is spoken by a character then we can add
            -- additional formatting to the output, such as the
            -- character's name and font if present.
            local text = {
                arguments.character.textColor,
                string.format("%s: %s",
                              arguments.character.name,
                              arguments.content)
            }

            -- The font may be a nil value but that is ok since the
            -- second argument to Scene:drawText() is optional.
            arguments.scene:drawText(text, arguments.character.font)
        else
            -- Plain narration without a Character.
            arguments.scene:drawText(arguments.content)
        end
    end }


LNVL.Instructions["set-image"] = LNVL.Instruction:new{
    name = "set-image",
    action = function (arguments)
        local targetType = getmetatable(arguments.target)

        if targetType == LNVL.Character then
            -- If the target is a Character then we change their
            -- 'currentImage' to the new one in the instruction.
            arguments.target.currentImage = arguments.image
        elseif targetType == LNVL.Scene then
            -- If the target is a Scene we change its background
            -- image.  However, first we need to assign the 'scene'
            -- parameter of the argument to the 'target'.  The
            -- commentary for LNVL.Opcode.Processor["set-scene-image"]
            -- explains why we must do this here.
            arguments.target = arguments.scene
            arguments.target.backgroundImage = arguments.image
        else
            -- If we reach this point then it is an error.
            error(string.format("Cannot set-image for %s", targetType))
        end
    end }

LNVL.Instructions["draw-image"] = LNVL.Instruction:new{
    name = "draw-image",
    action = function (arguments)
        love.graphics.setColorMode("replace")

        -- If we have arguments for a border then we assign those to
        -- the relevant properties of the image, assuming it is a
        -- Drawable object.  That way the call to image:draw() will
        -- include the border.
        if arguments["border"] ~= nil then
            if getmetatable(arguments.image) == LNVL.Drawable then
                arguments.image.borderColor = arguments.border[1]
                arguments.image.borderSize = arguments.border[2]
            end
        end

        if getmetatable(arguments.image) == LNVL.Drawable then
            if arguments["position"] ~= nil then
                arguments.image:setPosition(arguments.position)
            end

            arguments.image:draw()
        else
            love.graphics.draw(arguments.image,
                               arguments.location[1],
                               arguments.location[2])
        end
    end }

LNVL.Instructions["set-scene"] = LNVL.Instruction:new{
    name = "set-scene",
    action = function (arguments)
        local scene = LNVL.ScriptEnvironment[arguments.name]
        assert(scene ~= nil and getmetatable(scene) == LNVL.Scene,
               "Cannot load scene " .. arguments.name)
        LNVL.CurrentScene = scene
    end }

LNVL.Instructions["no-op"] = LNVL.Instruction:new{
    name = "no-op",
    action = function (arguments) end
}

-- This table has the names of opcodes for strings and maps them to
-- the names of the instructions we execute for each opcode.  Note
-- that there is not a one-to-one mapping between opcodes and
-- instructions; different opcodes may become the same instruction.
LNVL.Instruction.ForOpcode = {
    ["monologue"] = LNVL.Instructions["say"],
    ["say"] = LNVL.Instructions["say"],
    ["set-character-image"] = LNVL.Instructions["set-image"],
    ["draw-character"] = LNVL.Instructions["draw-image"],
    ["change-scene"] = LNVL.Instructions["set-scene"],
    ["set-scene-image"] = LNVL.Instructions["set-image"],
    ["no-op"] = LNVL.Instructions["no-op"],
    ["deactivate-character"] = LNVL.Instructions["no-op"],
}

-- If LNVL is running in debugging mode then make sure that every
-- instruction we list as valid has a match LNVL.Instruction object
-- that implements it.
--
-- We also make sure that every opcode has a matching instruction.
if LNVL.Settings.DebugModeEnabled == true then
    for name,_ in pairs(LNVL.Instruction.ValidInstructions) do
        if LNVL.Instructions[name] == nil then
            error("No implementation for the instruction " .. name)
        end
    end

    for name,_ in pairs(LNVL.Opcode.ValidOpcodes) do
        if LNVL.Instruction.ForOpcode[name] == nil
            or getmetatable(LNVL.Instruction.ForOpcode[name]) ~= LNVL.Instruction
        then
            error("No instruction implementation for the opcode " .. name)
        end
    end
end

-- Return our class as a module.
return LNVL.Instruction
