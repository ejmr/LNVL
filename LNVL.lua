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

require("src/scene")

-- Define the LNVL module.
module("LNVL")