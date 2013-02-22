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
-- Scene:changeTo() method is the preferred way to change this.
LNVL.currentScene = nil

-- Because all of the code in the 'src/' directory adds to the LNVL
-- table these require() statements must come after we declare the
-- LNVL table above.  We must require() each module in a specific
-- order, so insertions or changes to this list must be careful.

-- First we must load any modules that define global values we may use
-- in the Settings module.
LNVL.Color = require("src.color")
LNVL.Position = require("src.position")

-- Next we need to load Settings as soon as possible so that other
-- modules can draw default values from there.
LNVL.Settings = require("src.settings")

-- We want to load Debug after Settings and before other modules so
-- that they can have special behavior if debug mode is enabled, which
-- the Settings module controls.
LNVL.Debug = require("src.debug")

-- Then we should load the Graphics module so that the rest have
-- access to primitive rendering functions.
LNVL.Graphics = require("src.graphics")

-- Then we load the ClampedArray module to make it accesible to
-- classes which define properties using that type.
LNVL.ClampedArray = require("src.clamped-array")

-- Next come the Opcode and Instruction modules, in that order, since
-- the remaining modules may generate opcodes.  And since opcodes
-- create instructions we load them in that sequence.
LNVL.Opcode = require("src.opcode")
LNVL.Instruction = require("src.instruction")

-- Next comes the Drawable module, which classes below may use for
-- certain properties.
LNVL.Drawable = require("src.drawable")

-- The order of the remaining modules can come in any order as they do
-- not depend on each other.
LNVL.Character = require("src.character")
LNVL.Scene = require("src.scene")
LNVL.Menu = require("src.menu")

-- This function loads an external LNVL script, i.e. one defining
-- scenes and story content.  The argument is the path to the file;
-- the function assumes the caller has already ensured the file exists
-- and will crash with an error if the file is not found.  The script
-- must define the 'START' scene.  The function returns no value.
function LNVL.loadScript(filename)
    love.filesystem.load(filename)()
    LNVL.currentScene = START
end

-- Return the LNVL module.
return LNVL
