--[[
--
-- This file implements the instruction engine portion of LNVL.  See
-- the document
--
--     docs/html/Instructions.html
--
-- for details about this system and its design.
--
--]]

-- Create our LNVL.Instruction class.
LNVL.Instruction = {}
LNVL.Instruction.__index = LNVL.Instruction

-- This is a list of all the valid instructions.
LNVL.Instruction.ValidInstructions = {
    say = true
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
LNVL.Instruction.__tostring =
    function (instruction)
        return string.format("<Instruction %s>", instruction.name)
    end

-- We define a __call() metatable method as a shortcut for executing
-- the 'action' function of an instruction.
LNVL.Instruction.__call =
    function (f, ...)
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

                 arguments.scene:draw()
                 arguments.scene:drawText(text)
             end
}

-- Return our class as a module.
return LNVL.Instruction