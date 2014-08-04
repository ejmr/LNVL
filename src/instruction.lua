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

-- Create our Instruction class.
local Instruction = {}
Instruction.__index = Instruction

-- This is a list of all the valid instructions.
Instruction.ValidInstructions = {
    ["say"] = true,
    ["set-image"] = true,
    ["draw-image"] = true,
    ["set-scene"] = true,
    ["no-op"] = true,
    ["show-menu"] = true,
    ["set-position"] = true,
    ["set-name"] = true,
    ["set-color"] = true,
    ["set-font"] = true,
}

-- Our constructor.  It requires a table with two properties, named
-- and defined in comments within the constructor.
function Instruction:new(properties)
    local instruction = {}
    setmetatable(instruction, Instruction)
    assert(Instruction.ValidInstructions[properties.name] ~= nil,
           string.format("Unknown instruction %s", properties.name))

    -- name: The name of the instruction as a string.
    instruction.name = properties.name

    -- action: A function representing the logic for the instruction.
    instruction.action = properties.action

    return instruction
end

-- A simple tostring() method for debugging purposes, which does
-- nothing but returns the name of the instruction.
Instruction.__tostring = function (instruction)
    return string.format("<Instruction %s>", instruction.name)
end

-- We define a __call() metatable method as a shortcut for executing
-- the 'action' function of an instruction.
Instruction.__call = function (f, ...)
    if type(f) == "function" then
        return f(...)
    else
        return f.action(...)
    end
end

-- This table contains all of the instructions in the LNVL engine.
-- The keys for the table are strings, the names of the instructions.
-- The values are the Instruction objects themselves.
--
-- All of the individual instructions defined below are described in
-- detail by the document referenced at the top of this file.  None of
-- the instruction action functions return values.
LNVL.Instructions = {}

LNVL.Instructions["say"] = Instruction:new {
    name = "say",
    action = function (arguments)
        local font = arguments.scene.font
        local textColor = arguments.scene.textColor or LNVL.Settings.Characters.TextColor

        if arguments["character"] ~= nil then
            -- If the text is spoken by a character then we can add
            -- additional formatting to the output, such as the
            -- character's name and font if present.
            LNVL.Graphics.DrawText {
                font,
                arguments.character.textColor,
                string.format("%s: %s",
                              arguments.character.dialogName,
                              arguments.content) }
        else
            LNVL.Graphics.DrawText{font, textColor, arguments.content}
        end
    end }

LNVL.Instructions["set-name"] = Instruction:new {
    name = "set-name",
    action = function (arguments)
        local character, name = arguments.target, arguments.name
        assert(getmetatable(character) == LNVL.Character)
        
        if name == "default" then
            character.dialogName = character.firstName
        elseif name == "fullName" then
            character.dialogName = ("%s %s"):format(character.firstName, character.lastName)
        else
            character.dialogName = character[name]
        end
    end
}

LNVL.Instructions["set-color"] = Instruction:new {
    name = "set-color",
    action = function (arguments)
        assert(getmetatable(arguments.target) == LNVL.Character)
        arguments.target.textColor = arguments.color
    end
}

LNVL.Instructions["set-font"] = Instruction:new {
    name = "set-font",
    action = function (arguments)
        assert(getmetatable(arguments.target) == LNVL.Character)
        arguments.target.font =
            love.graphics.newFont(arguments.font .. ".ttf", arguments.size)
    end
}

LNVL.Instructions["set-image"] = Instruction:new {
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

LNVL.Instructions["draw-image"] = Instruction:new {
    name = "draw-image",
    action = function (arguments)
        love.graphics.setColor(LNVL.Color.White)

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

LNVL.Instructions["set-scene"] = Instruction:new {
    name = "set-scene",
    action = function (arguments)
        local scene = LNVL.ScriptEnvironment[arguments.name]
        assert(scene ~= nil and getmetatable(scene) == LNVL.Scene,
               "Cannot load scene " .. arguments.name)
        LNVL.CurrentScene = scene
    end }

LNVL.Instructions["no-op"] = Instruction:new {
    name = "no-op",
    action = function (arguments) end
}

LNVL.Instructions["show-menu"] = Instruction:new {
		name = "show-menu",
		action = function (arguments)
		if LNVL.Settings.Handlers.Menu == nil or
		coroutine.status(LNVL.Settings.Handlers.Menu) == "dead" then
			LNVL.Settings.Handlers.Menu = coroutine.create(
				function (menu)
					return next(menu)
				end
			)
		end
		local executed, choice = coroutine.resume(
			LNVL.Settings.Handlers.Menu,
			arguments.menu
		)
        if executed == true then
            arguments.menu.currentChoiceIndex = choice
        end
    end
}

LNVL.Instructions["set-position"] = Instruction:new {
    name = "set-position",
    action = function (arguments)
        arguments.target.position = arguments.position
    end
}

-- This table has the names of opcodes for strings and maps them to
-- the names of the instructions we execute for each opcode.  Note
-- that there is not a one-to-one mapping between opcodes and
-- instructions; different opcodes may become the same instruction.
Instruction.ForOpcode = {
    ["say"] = LNVL.Instructions["say"],
    ["set-character-image"] = LNVL.Instructions["set-image"],
    ["set-character-name"] = LNVL.Instructions["set-name"],
    ["set-character-text-color"] = LNVL.Instructions["set-color"],
    ["set-character-text-font"] = LNVL.Instructions["set-font"],
    ["change-scene"] = LNVL.Instructions["set-scene"],
    ["set-scene-image"] = LNVL.Instructions["set-image"],
    ["no-op"] = LNVL.Instructions["no-op"],
    ["deactivate-character"] = LNVL.Instructions["no-op"],
    ["move-character"] = LNVL.Instructions["set-position"],
    ["add-menu"] = LNVL.Instructions["show-menu"],
}

-- If LNVL is running in debugging mode then make sure that every
-- instruction we list as valid has a match Instruction object
-- that implements it.
--
-- We also make sure that every opcode has a matching instruction.
if LNVL.Settings.DebugModeEnabled == true then
    for name,_ in pairs(Instruction.ValidInstructions) do
        if LNVL.Instructions[name] == nil then
            error("No implementation for the instruction " .. name)
        end
    end

    for name,_ in pairs(LNVL.Opcode.ValidOpcodes) do
        if Instruction.ForOpcode[name] == nil
            or getmetatable(Instruction.ForOpcode[name]) ~= Instruction
        then
            error("No instruction implementation for the opcode " .. name)
        end
    end
end

-- Return our class as a module.
return Instruction
