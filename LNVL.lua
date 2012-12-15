--[[
--
-- LNVL: The LÖVE Visual Novel Engine
--
-- This is the only module your game must import in order to use LNVL.
-- See the file README.md for more information and links to the
-- official website with documentation.  See the file LICENSE for
-- information on the license for LNVL.
--
--]]

-- This table is the global namespace for all LNVL classes, functions,
-- and data.
LNVL = {}

-- Because all of the code in the 'src/' directory adds to the LNVL
-- table these require() statements must come after we declare the
-- LNVL table above.

LNVL.Color = require("src.color")
LNVL.Opcode = require("src.opcode")
LNVL.Instruction = require("src.instruction")
LNVL.ClampedArray = require("src.clamped-array")
LNVL.Character = require("src.character")
LNVL.Scene = require("src.scene")

-- Return the LNVL module.
return LNVL