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

-- Our constructor.  It requires a table with two properties, named
-- and defined in comments within the constructor.
function LNVL.Instruction:new(properties)
    local instruction = {}
    setmetatable(instruction, LNVL.Instruction)

    -- name: The name of the instruction as a string.
    instruction.name = properties.name

    -- action: A function representing the logic for the instruction.
    instruction.action = properties.action

    return instruction
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
LNVL.Instructions = {}

LNVL.Instructions["say"] = LNVL.Instruction:new{
    name = "say",
    action = function (arguments)
                 arguments.scene:drawText(arguments.content)
             end
}

-- Return our class as a module.
return LNVL.Instruction