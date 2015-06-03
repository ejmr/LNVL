--[[
--
-- This module provides functions to help debug LNVL.
--
--]]

-- Create the Debug class.
local Debug = {}
Debug.__index = Debug

-- The 'Log' property is an instance of the 'log.lua' library
-- available from:
--
--     https://github.com/ejmr/log.lua
--
-- See the documentation in 'src/settings.lua.example' for details on
-- the flags which affect logging.
Debug.Log = require("libs.log.log")
Debug.Log.outfile = LNVL.Settings.DebugLog
Debug.Log.usecolor = LNVL.Settings.DebugLogColorEnabled
Debug.Log.level = LNVL.Settings.DebugLogLevel

-- This function takes a table and returns a string representing that
-- table in a pretty-printed format.  The string is also valid Lua
-- code, meaning the function can also serialize (most) tables.
--
-- Two optional arguments are also accepted:
--
-- 1. The name of the table as a string.
--
-- 2. A string to use as initial indentation for every line of output.
--
-- Julio Manuel Fernandez-Diaz is the original author of this code,
-- which we borrowed from here:
--
--     http://lua-users.org/wiki/TableSerialization
--
-- We have modified it only slightly to conform to the style of the
-- LNVL codebase.
function Debug.TableToString(table, name, indent)
    local cart
    local autoref

    local function isemptytable(t) return next(t) == nil end

    local function basicSerialize(o)
        local so = tostring(o)
        if type(o) == "function" then
            local info = debug.getinfo(o, "S")
            -- info.name is nil because o is not a calling level
            if info.what == "C" then
                return string.format("%q", so .. ", C function")
            else
                -- the information is defined through lines
                return string.format("%q", so .. ", defined in (" ..
                                     info.linedefined .. "-" .. info.lastlinedefined ..
                                         ")" .. info.source)
            end
        elseif type(o) == "number" or type(o) == "boolean" then
            return so
        else
            return string.format("%q", so)
        end
    end

    local function addtocart(value, cname, cindent, saved, field)
        indent = indent or ""
        saved = saved or {}
        field = field or cname

        cart = cart .. indent .. field

        if type(value) ~= "table" then
            cart = cart .. " = " .. basicSerialize(value) .. ";\n"
        else
            if saved[value] then
                cart = cart .. " = {}; -- " .. saved[value]
                    .. " (self reference)\n"
                autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
            else
                saved[value] = cname
                --if tablecount(value) == 0 then
                if isemptytable(value) then
                    cart = cart .. " = {};\n"
                else
                    cart = cart .. " = {\n"
                    for k, v in pairs(value) do
                        k = basicSerialize(k)
                        local fname = string.format("%s[%s]", cname, k)
                        field = string.format("[%s]", k)
                        -- three spaces between levels
                        addtocart(v, fname, indent .. "   ", saved, field)
                    end
                    cart = cart .. indent .. "};\n"
                end
            end
        end
    end

    name = name or "__unnamed__"

    if type(table) ~= "table" then
        return name .. " = " .. basicSerialize(table)
    end

    cart, autoref = "", ""
    addtocart(table, name, indent)
    return cart .. autoref
end

-- This function takes an LNVL.Scene object and prints every opcode of
-- that scene to the console.  This is useful for ensuring that the
-- opcodes we expect to exist are there and in the correct order.
function Debug.PrintSceneOpcodes(scene)
    local function printOpcodeTable(opcodes)
        for index,opcode in ipairs(opcodes) do
            if getmetatable(opcode) == nil then
                print(string.format("[%i] Group = {\n", index))
                printOpcodeTable(opcode)
                print(string.format("} (Closing Group %i)\n", index))
            else
                print(string.format("[%i] %s\n", index, tostring(opcode)))
            end
        end
    end

    printOpcodeTable(scene.opcodes)
end

-- This function displays every variable in the LNVL script
-- environment and its type.
function Debug.DumpScriptEnvironment()
    print("--- Script Environment ---\n")
    for name,value in pairs(LNVL.ScriptEnvironment) do
        print(string.format("%q = %q", name, type(value)))
    end
    print("\n--- End of Script Environment ---\n")
end

-- Return the class as the module.
return Debug
