--[[
    --
    -- This file implements the LNVL.Opcode class.  See the document
    --
    --     docs/Instructions.md
    --
    -- for detailed information on opcodes and how we use them in LNVL.
    --
--]]

-- Create the LNVL.Opcode class.
LNVL.Opcode = {}
LNVL.Opcode.__index = LNVL.Opcode

-- This contains all of the valid opcodes LNVL recognizes.
LNVL.Opcode.ValidOpcodes = {
    ["monologue"] = true,
    ["say"] = true,
    ["set-character-image"] = true,
    ["draw-character"] = true,
    ["change-scene"] = true,
    ["no-op"] = true,
}

-- The opcode constructor, which requires two arguments: the name of
-- an instruction as a string, and a table (which may be nil) of
-- arguments to give to that instruction later.
function LNVL.Opcode:new(name, arguments)
    local opcode = {}
    setmetatable(opcode, LNVL.Opcode)
    assert(LNVL.Opcode.ValidOpcodes[name] ~= nil,
           string.format("Unknown opcode %s", name))

    -- name: The name of the instruction this opcode will execute.
    opcode.name = name

    -- arguments: A table of additional arguments we will give to the
    -- instruction when executing it.
    opcode.arguments = arguments

    return opcode
end

-- This function converts Opcode objects to strings intended for
-- debugging purposes.
LNVL.Opcode.__tostring = function (opcode)
    output = string.format("Opcode %q = {\n", opcode.name)
    for key,value in pairs(opcode.arguments) do
        output = output .. string.format("\n\t%s: %s", key, value)
    end
    output = output .. "\n}"
    return output
end

-- The following table contains all of the 'processor functions' for
-- opcodes.  Each key in the table the name of an opcode as a string;
-- these are the same keys which appear in the
-- LNVL.Opcode.ValidOpcodes table.  The value for each entry is
-- function which accepts one argument: an LNVL.Opcode object.  The
-- processor function will add any extra data or modify any existing
-- data for that particular instance of LNVL.Opcode and then return
-- either the modified object, or a new array of opcodes.
LNVL.Opcode.Processor = {}

-- Processor for opcode 'monologue'
--
-- We expand the opcode into an array of 'say' opcodes for each line
-- of dialog in the monologue.
LNVL.Opcode.Processor["monologue"] = function (opcode)
    local say_opcodes = {}
    for _,content in ipairs(opcode.arguments.content) do
        table.insert(say_opcodes,
                     LNVL.Opcode:new(
                         "say",
                         { content=content,
                           character=opcode.arguments.character
                         }))
    end
    return say_opcodes
end

-- Processor for opcode 'draw-character'
--
-- For this opcode we need to convert the 'position' data into the
-- appropriate 'location' data expected by the 'draw-image'
-- instruction which the opcode will become.
--
-- We also need to add the 'image' property to the opcode so that the
-- instruction will know what to draw later.  In this case we want it
-- to draw the current character image.
LNVL.Opcode.Processor["draw-character"] = function (opcode)
    local vertical_position = LNVL.Settings.Scenes.Y + 80

    if opcode.arguments.position == LNVL.Position.Center then
        opcode.arguments.location = {
            LNVL.Settings.Screen.Center[1],
            vertical_position,
        }
    elseif opcode.arguments.position == LNVL.Position.Right then
        opcode.arguments.location = {
            LNVL.Settings.Screen.Width - 200,
            vertical_position,
        }
    elseif opcode.arguments.position == LNVL.Position.Left then
        opcode.arguments.location = {
            200,
            vertical_position,
        }
    end

    opcode.arguments.image =
        opcode.arguments.character.images[opcode.arguments.character.currentImage]
end

-- Processor for opcode 'set-character-image'
--
-- For this opcode we must set the 'target' property to point to the
-- associated Character object so that the resulting 'set-image'
-- instruction knows what to update.
LNVL.Opcode.Processor["set-character-image"] = function (opcode)
    opcode.arguments.target = opcode.arguments.character
    return opcode
end

-- The following opcodes require no additional processing after their
-- creation and so they have no-op's for their processor functions.
local returnOpcode = function (opcode) return opcode end
LNVL.Opcode.Processor["say"] = returnOpcode
LNVL.Opcode.Processor["change-scene"] = returnOpcode
LNVL.Opcode.Processor["no-op"] = returnOpcode

-- Return the class as a module.
return LNVL.Opcode
