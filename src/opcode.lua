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
    output = string.format("Opcode %q = {", opcode.name)

    if opcode.arguments ~= nil then
        output = output .. "\n"

        for key,value in pairs(opcode.arguments) do
            -- Show the XY-coordinations for the 'location' property.
            if key == "location" then
                output = output .. string.format("\tlocation: X = %d, Y = %d\n",
                                                 value[1], value[2])
            else
                output = output .. string.format("\t%s: %s\n", key, value)
            end
        end
    end

    output = output .. "}"
    return output
end

-- The following table contains all of the 'processor functions' for
-- opcodes.  Each key in the table the name of an opcode as a string;
-- these are the same keys which appear in the table of valid opcodes
-- defined above.  The value for each entry is function which accepts
-- one argument: an LNVL.Opcode object.  The processor function will
-- add any extra data or modify any existing data for that particular
-- instance of LNVL.Opcode and then return either the modified object,
-- or a new array of opcodes.
--
-- If the processor functions returns a table of opcodes then that
-- table may have the '__flatten' property.  If it exists it must have
-- a boolean value.  If true that tells the engine to flatten that
-- list of opcodes, treating them as individual opcodes for conversion
-- instead of keeping them together as a group.  This is meant to be
-- the exception and not the rule; therefore every processor that
-- needs the engine to flatten its list of opcodes must explicitly
-- request it by setting this property on the table of opcodes it
-- creates and returns.
--
-- It is a fatal error for any processor function to *not* return an
-- opcode or a table of opcodes.
LNVL.Opcode.Processor = {}

-- Processor for opcode 'monologue'
--
-- We expand the opcode into an array of 'say' opcodes for each line
-- of dialog in the monologue.
LNVL.Opcode.Processor["monologue"] = function (opcode)
    local say_opcodes = {}
    for _,content in ipairs(opcode.arguments.content) do
        local opcode = LNVL.Opcode:new("say",
                                       { content=content,
                                         character=opcode.arguments.character
                                       })
        table.insert(say_opcodes, opcode:process())
    end
    rawset(say_opcodes, "__flatten", true)
    return say_opcodes
end

-- Processor for opcode 'draw-character'
--
-- For this opcode we need to convert the 'position' data into the
-- appropriate 'location' data expected by the 'draw-image'
-- instruction which the opcode will become.  The 'position' property
-- is optional.  If it does not exist then we will use the default
-- position of the 'character' property that the opcode requires.
--
-- We also need to add the 'image' property to the opcode so that the
-- instruction will know what to draw later.  In this case we want it
-- to draw the current character image.
LNVL.Opcode.Processor["draw-character"] = function (opcode)
    local vertical_position = LNVL.Settings.Scenes.Y - 80

    -- If the opcode was given no position we use the character's
    -- current position.  But if the opcode is given a position then
    -- we assign that new one to the character, otherwise the new
    -- position will only be in effect for this one opcode which is
    -- not what we want, e.g. calling Character:isAt() would move a
    -- character for one render and then reset their position instead
    -- of moving them permanently until the next isAt() or movement.
    if opcode.arguments["position"] == nil then
        opcode.arguments.position = opcode.arguments.character.position
    else
        opcode.arguments.character.position = opcode.arguments.position
    end

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

    return opcode
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

-- Processor for opcode 'say'
--
-- For this opcode we need to see if the optional 'character' argument
-- is present.  If so then we need to also return a 'draw-character'
-- opcode so that the engine renders the character avatar along with
-- their dialog.  If there is no character we can return the opcode
-- as-is without any further processing.
LNVL.Opcode.Processor["say"] = function (opcode)
    if opcode.arguments["character"] ~= nil then
        local character = opcode.arguments.character
        -- If the character has no current image then we should not
        -- create a 'draw-character' opcode because there is nothing
        -- to draw.  So in that case we fall back on simply returning
        -- the original opcode at the end of the function.
        if character.images[character.currentImage] ~= nil then
            local draw_opcode =
                LNVL.Opcode:new("draw-character", { character=character })
            return { draw_opcode:process(), opcode }
        end
    end

    return opcode
end

-- The following opcodes require no additional processing after their
-- creation and so they have no-op's for their processor functions.
local returnOpcode = function (opcode) return opcode end
LNVL.Opcode.Processor["change-scene"] = returnOpcode
LNVL.Opcode.Processor["no-op"] = returnOpcode

-- This method processes an opcode by running it through the
-- appropriate function above, returning the modified version.
function LNVL.Opcode:process()
    return LNVL.Opcode.Processor[self.name](self)
end

-- If LNVL is running in debugging mode then make sure that every
-- valid opcode has an associated processor function, because without
-- one we will not be able to include those opcodes in scenes.  That
-- can lead to some tricky bugs.
if LNVL.Settings.DebugModeEnabled == true then
    for name,_ in pairs(LNVL.Opcode.ValidOpcodes) do
        if LNVL.Opcode.Processor[name] == nil then
            error("No opcode processor for " .. name)
        end
    end
end

-- Return the class as a module.
return LNVL.Opcode
