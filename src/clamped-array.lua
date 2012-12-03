--[[
--
-- This file implements an array class which is 'clamped' at its end
-- by the first nil value.  For example:
--
--     foo = LNVL.ClampedArray:new()
--     foo[1] = 10
--     foo[0] = 2
--     foo[2] = 4
--     foo[3] = nil
--
-- So the values of 'foo' are {10, 4}' now.  ClampedArrays do not
-- allow indexes less than one; so the index zero is discarded.  Their
-- length also stops at the first nil value *if and only if* there are
-- no more nil values after that.  So here the length of the
-- ClampedArray is two, but if we added
--
--     foo[4] = 40
--
-- the length would become four, i.e. {10, 4, nil, 40}.
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
