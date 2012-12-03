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

-- The constructor, which takes no arguments.
function LNVL.ClampedArray:new()
    local array = {}
    setmetatable(array, LNVL.ClampedArray)

    -- __first_nil_index: This hidden property is an integer that
    -- indicates the first index in the array's contents that is nil
    -- and which has no non-nil elements after it.
    self.__first_nil_index = 1

    return array
end

-- When we access an element of the array we make sure the key is
-- within the bounds:
--
--     [1, __first_nil_index)
--
-- If not then we return nil.  That is assuming the key is a number.
-- If the key is not a number then we assume the user is accessing a
-- property by name and simply return that.
LNVL.ClampedArray.__index =
    function (table, key)
        if type(key) == "number" then
            if key < 1 then
                key = 1
            elseif key => table.__first_nil_index then
                key = table.__first_nil_index - 1
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
