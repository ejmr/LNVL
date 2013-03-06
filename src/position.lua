--[[
--
-- This file provides the LNVL.Position table.  It defines constants
-- used in the engine to specify the position of various objects, for
-- example, character sprites.
--
--]]

-- Create the Position table.
local Position = {}
Position.__index = Position

-- These positions specify the general area an object should appear
-- but do not give any exact location.  It is up to the object given
-- the position to determine just exactly what it means to be
-- positioned to the 'right', for example.  We assign strings to each
-- because that improves debugging output, but the values assigned to
-- these properties are arbitrary; all that truly matters is that they
-- are distinct from each other.
--
-- The position values are relative to the screen in this way:
--
--     +----------------------------------------------------------+
--     | TopLeft               TopCenter                 TopRight |
--     |                                                          |
--     |                                                          |
--     |                                                          |
--     |                                                          |
--     | Left                   Center                      Right |
--     |                                                          |
--     |                                                          |
--     |                                                          |
--     |                                                          |
--     | BottomLeft          BottomCenter             BottomRight |
--     +----------------------------------------------------------+
--
-- To make it easier to add positions in the future, i.e. to cut down
-- on code, we define of all the positions as a list of strings and
-- then dynamically create the LNVL.Position properties from that.

Position.ValidPositions = {
    "BottomCenter",
    "Center",
    "TopCenter",

    "BottomRight",
    "Right",
    "TopRight",

    "BottomLeft",
    "Left",
    "TopLeft",
}

for _,name in ipairs(Position.ValidPositions) do
    Position[name] = name
end

-- Return the table as the module.
return Position
