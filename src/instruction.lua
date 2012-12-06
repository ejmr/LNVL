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

    -- value: The value associated with the instruction, which may be
    -- of any type.
    instruction.value = properties.value

    -- actor: The actor for the instructor, i.e. the object which
    -- executes the instruction.  Not every instruction has an actor,
    -- and those which do not have a nil value for this property.
    if properties["actor"] ~= nil then
        instruction.actor = properties.actor
    else
        instruction.actor = nil
    end

    return instruction
end

-- Return our class as a module.
return LNVL.Instruction