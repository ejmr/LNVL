--[[

Story Progress

This module helps track the progress of the player through the story.
It provides an API that we can use throughout the game to poll the
player’s progress and to mark achievements.  It also lets us keep
running tabs on various statistics, such as if we need to track how
many times the player has died or how often they have used certain
items and abilities.  In this regard the module is a cornerstone for
future implementations of anything like an achievements system.

--]]

-- Create the Progress class.
local Progress = {}
Progress.__index = Progress

-- Our constructor, which takes no arguments.
function Progress:new()

    -- This table contains all of the progress information.  The keys
    -- are strings; we always convert these to lower-case before any
    -- lookup so that code outside this module does not have to worry
    -- about bugs caused by simple case discrepancies.
    --
    -- The values may be a variety of value types.
    --
    -- We use booleans for story flags which are a binary on-or-off,
    -- e.g. has the player do some arbitrary action?  This is a
    -- yes-or-no progress question for which we use a boolean.
    --
    -- The value may be a string.  In that case we **do not** convert
    -- it to lower-case because the case may matter to other parts of
    -- the game.
    --
    -- The value may be a number.  If it is a floating-point number
    -- then we assume it represents a percentage.  E.g. a value of
    -- 0.37 represent thirty-seven percent.
    --
    -- Finally, the value may be a table.  This can be useful to
    -- provide a link to other objects in code that better represent
    -- data relevant for this piece of progress.  The table has weak
    -- values since we use tables; if the sole reference to a table is
    -- in the Progress module then we can garbage-collect it.
    self.dataFor = setmetatable({}, { __mode = "v" })

end

-- The methods below can accept a string or table of strings for a
-- name.  This utility takes those parameters and normalizes them into
-- a single string, which it returns.
--
-- Example:
--     normalizeName({"Lobby", "Jones"}) => "lobby/jones"
--
-- It is an error to give the function anything else.
local function normalizeName(name)
    if type(name) == "table" then
        return string.lower(table.concat(name, "/"))
    else
        return string.lower(name)
    end
end

-- This method takes a name describing the progress and sets it to the
-- given value.  The name should be as descriptive as possible.  The
-- 'name' parameter may be a single string.  Or it may be a table of
-- strings where each element represents a 'group' containing the
-- strings that following.  This makes it easier to group progress
-- values for such things as missions, e.g.
--
--     setDataFor({"Mission One", "Met the Witch"}, true)
--     setDataFor({"Mission One", "Completion"}, 100.0)
--
-- See the documentation on the constructor for details about what the
-- values can mean based on their data type.
--
-- This method returns nothing.
function Progress:setDataFor(name, value)
    self.dataFor[normalizeName(name)] = value
end

-- This method returns the data for a given name.  If there is no data
-- associated with that name then it returns nil so that code can rely
-- on this in order to set default values elsewhere, e.g.
--
--     beatFoo = Progress:getDataFor("Defeated Boss Foo") or false
--
-- This method may return anything acceptable as a value for the
-- 'dataFor' property of the Progress class.
function Progress:getDataFor(name)
    return self.dataFor[normalizeName(name)]
end

return Progress
