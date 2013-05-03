--[[
--
-- This file implements the LNVL.Opcode class.  See the document
--
--     docs/Instructions.md
--
-- for detailed information on opcodes and how we use them in LNVL.
--
--]]

-- Create the Opcode class.
local Opcode = {}
Opcode.__index = Opcode

-- This contains all of the valid opcodes LNVL recognizes.
Opcode.ValidOpcodes = {
    ["monologue"] = true,
    ["say"] = true,
    ["set-character-image"] = true,
    ["move-character"] = true,
    ["change-scene"] = true,
    ["no-op"] = true,
    ["set-scene-image"] = true,
    ["deactivate-character"] = true,
    ["add-menu"] = true,
}

-- The opcode constructor, which requires two arguments: the name of
-- an instruction as a string, and a table (which may be nil) of
-- arguments to give to that instruction later.
function Opcode:new(name, arguments)
    local opcode = {}
    setmetatable(opcode, Opcode)
    assert(Opcode.ValidOpcodes[name] ~= nil,
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
local function formatOpcode(opcode)
    output = string.format("Opcode %q = {", opcode.name)

    if opcode.arguments ~= nil then
        output = output .. "\n"

        for key,value in pairs(opcode.arguments) do
            -- Show the XY-coordinations for the 'location' property.
            if key == "location" then
                output = output .. string.format("\tlocation: X = %d, Y = %d\n",
                                                 value[1], value[2])
                -- Show the color and width of the 'border' property.
            elseif key == "border" then
                output = output .. string.format("\tborder: %s, Size = %d\n",
                                                 tostring(value[1]),
                                                 value[2])
            else
                output = output .. string.format("\t%s: %s\n", key, value)
            end
        end
    end

    output = output .. "}"
    return output
end

-- Convert an Opcode object to a string.
Opcode.__tostring = function (opcode)
    return formatOpcode(opcode)
end

-- The following table contains all of the 'processor functions' for
-- opcodes.  Each key in the table is the name of an opcode as a
-- string; these are the same keys which appear in the table of valid
-- opcodes defined above.  The value for each entry is function which
-- accepts one argument: an LNVL.Opcode object.  The processor
-- function will add any extra data or modify any existing data for
-- that particular instance of LNVL.Opcode and then return either the
-- modified object, or a new array of opcodes.
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
Opcode.Processor = {}

-- Processor for opcode 'monologue'
--
-- We expand the opcode into an array of 'say' opcodes for each line
-- of dialog in the monologue.
Opcode.Processor["monologue"] = function (opcode)
    local say_opcodes = {}
    for _,content in ipairs(opcode.arguments.content) do
        local opcode = Opcode:new("say",
                                       { content=content,
                                         character=opcode.arguments.character
                                       })
        table.insert(say_opcodes, opcode:process())
    end
    rawset(say_opcodes, "__flatten", true)
    return say_opcodes
end

-- Processor for opcode 'move-character'
--
-- For this opcode we expect a 'character' argument with an
-- LNVL.Character object.  We need to set the 'position' property of
-- the Character object to value of the 'position' property in the
-- opcode arguments.
Opcode.Processor["move-character"] = function (opcode)
    opcode.arguments.character.position = opcode.arguments.position
    return opcode
end

-- Processor for opcode 'set-character-image'
--
-- For this opcode we must set the 'target' property to point to the
-- associated Character object so that the resulting 'set-image'
-- instruction knows what to update.
Opcode.Processor["set-character-image"] = function (opcode)
    opcode.arguments.target = opcode.arguments.character
    return opcode
end

-- Processor for opcode 'set-scene-image'
--
-- For this opcode we need to set the 'target' property to the scene
-- containing the opcode so that the 'set-image' instruction later
-- knows what scene to affect.  However, this is not so simple.
-- Here is the problem:
--
-- We create and process all opcodes in a scene *before* the
-- constructor for that Scene object finishes execution.  So here we
-- cannot give the opcode access to the scene because at this point we
-- have not even finished creating the scene.  All opcodes get access
-- to the Scene object containing them later, after the Scene:new()
-- constructor finishes.  But in this specific situation we need the
-- scene *now*, and we have no way to get it.
--
-- To deal with this problem we defer the assignment of the 'target'
-- in the opcode.  The 'set-image' instruction will look at the
-- metatable for 'target' to figure out what image to affect.  What we
-- will do here is assign a temporary, empty table to 'target' that
-- has LNVL.Scene for its metatable.  That way the 'set-image'
-- instruction can later determine that it is dealing with a scene,
-- and by then we will have access to the Scene object to actually
-- modify it.
Opcode.Processor["set-scene-image"] = function (opcode)
    opcode.arguments.target = {}
    setmetatable(opcode.arguments.target, LNVL.Scene)
    return opcode
end

-- The following opcodes require no additional processing after their
-- creation and so they have no-op's for their processor functions.
local returnOpcode = function (opcode) return opcode end
Opcode.Processor["change-scene"] = returnOpcode
Opcode.Processor["no-op"] = returnOpcode
Opcode.Processor["deactivate-character"] = returnOpcode
Opcode.Processor["say"] = returnOpcode
Opcode.Processor["add-menu"] = returnOpcode

-- This method processes an opcode by running it through the
-- appropriate function above, returning the modified version.
function Opcode:process()
    return Opcode.Processor[self.name](self)
end

-- If LNVL is running in debugging mode then make sure that every
-- valid opcode has an associated processor function, because without
-- one we will not be able to include those opcodes in scenes.  That
-- can lead to some tricky bugs.
if LNVL.Settings.DebugModeEnabled == true then
    for name,_ in pairs(Opcode.ValidOpcodes) do
        if Opcode.Processor[name] == nil then
            error("No opcode processor for " .. name)
        end
    end
end

-- Return the class as a module.
return Opcode
