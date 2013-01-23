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

-- These three positions specify the general area an object should
-- appear but do not give any exact location.  It is up to the object
-- given the position to determine just exactly what it means to be
-- positioned to the 'right', for example.  We assign strings to each
-- because that improves debugging output, but the values assigned to
-- these properties are arbitrary; all that truly matters is that they
-- are distinct from each other.
LNVL.Position.Center = "Center"
LNVL.Position.Right = "Right"
LNVL.Position.Left = "Left"

-- Return the table as the module.
return LNVL.Position
