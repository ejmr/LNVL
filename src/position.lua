--[[
--
-- This file provides the LNVL.Position table.  It defines constants
-- used in the engine to specify the position of various objects, for
-- example, character sprites.
--
--]]

-- Create the LNVL.Position table.
LNVL.Position = {}
LNVL.Position.__index = LNVL.Position

-- These positions specify the general area an object should appear
-- but do not give any exact location.  It is up to the object given
-- the position to determine just exactly what it means to be
-- positioned to the 'right', for example.  We assign strings to each
-- because that improves debugging output, but the values assigned to
-- these properties are arbitrary; all that truly matters is that they
-- are distinct from each other.
--
-- To make it easier to add positions in the future, i.e. to cut down
-- on code, we define of all the positions as a list of strings and
-- then dynamically create the LNVL.Position properties from that.

LNVL.Position.ValidPositions = {
    "Center",
    "Right",
    "Left",
}

for _,name in ipairs(LNVL.Position.ValidPositions) do
    LNVL.Position[name] = name
end

-- Return the table as the module.
return LNVL.Position
