--[[
--
-- This file implements an array class which is 'clamped' at its end.
-- That means if the array has a clamed end of six then the only valid
-- indexes for the array are one through six, inclusive.  Trying to
-- access an index less than one is the same as using the index one,
-- and trying to access an index higher than the clamped maximum is
-- the same as accessing the index assigned to the maximum index.
--
-- Here is an usage example:
--
--     foo = LNVL.ClampedArray:new{3}
--     foo[1] = 10
--     foo[0] = 2      -- Same as foo[1] = 2
--     foo[9] = 8      -- Same as foo[3] = 8
--
-- So the values of 'foo' are {10, nil, 8}' now.
--
--]]

LNVL.ClampedArray = {}

-- The constructor takes one argument, which is the maximum index
-- value the array allows (inclusive).  We store this in the
-- 'maxmimum_index' property.
function LNVL.ClampedArray:new(max)
    local array = {}
    setmetatable(array, LNVL.ClampedArray)
    array.maximum_index = max
    return array
end

-- The __index() metamethod ensures that we do not exceed the bounds
-- of the array's indexes.  If 'key' is not a number then we return
-- immediately because we do not perform the check because that means
-- we could be looking up a property name.
LNVL.ClampedArray.__index =
    function (table, key)
        if type(key) == "number" then
            if key < 1 then
                key = 1
            elseif key > table.maximum_index then
                key = table.maximum_index
            end
        end

        return rawget(table, key)
    end

-- The __newindex() metamethod works similarly to __index(), ensuring
-- that we cannot set numeric indexes above the maximum assigned when
-- we constructed the array.
LNVL.ClampedArray.__newindex =
    function (table, key, value)
        if type(key) == "number" then
            if key < 1 then
                key = 1
            elseif key > table.maximum_index then
                key = table.maximum_index
            end
        end

        rawset(table, key, value)
    end
