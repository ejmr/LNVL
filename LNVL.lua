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

-- This property represents the current Scene in use.  We should
-- rarely change the value of this property directly.  Instead the
-- changeToScene() function is the preferred way to change this.
LNVL.currentScene = nil

-- Because all of the code in the 'src/' directory adds to the LNVL
-- table these require() statements must come after we declare the
-- LNVL table above.  We must require() each module in a specific
-- order, so insertions or changes to this list must be careful.

LNVL.Settings = require("src.settings")
LNVL.Debug = require("src.debug")
LNVL.Color = require("src.color")
LNVL.Position = require("src.position")
LNVL.Graphics = require("src.graphics")
LNVL.Opcode = require("src.opcode")
LNVL.Instruction = require("src.instruction")
LNVL.ClampedArray = require("src.clamped-array")
LNVL.Character = require("src.character")
LNVL.Scene = require("src.scene")

-- Return the LNVL module.
return LNVL
