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

-- Our constructor.
function LNVL.Instruction:new(properties)
    local instruction = {}
    setmetatable(instruction, LNVL.Instruction)

    -- name: The name of the instruction as a string.
    instruction.name = properties.name

    -- action: A function representing the logic for the instruction.
    instruction.action = properties.action

    return instruction
end

-- This table contains all of the functions that process instructions.
-- The keys for the table are strings, the names of the instructions.
-- The values are functions which accept at least two arguments:
--
-- 1. A value.
-- 2. An actor.
--
-- See the documentation referenced at the top of this file for more
-- information about the design of these 'action functions'.
LNVL.Instruction.Actions = {}

-- Return our class as a module.
return LNVL.Instruction