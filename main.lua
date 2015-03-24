--[[

 The main file required by LÖVE.  We do not use this for anything in
 LNVL except debugging, since we ship out LNVL as a library for
 other programs to use and not really an executable on its own.

 It reads an optional script filename from the command-line and
 loads that.  If none is given then it loads a simple example.

 The enter and backspace keys move back and forth through the text.

----]]

local LNVL = require("LNVL")
LNVL.Initialize()
print("LNVL Version " .. LNVL.GetVersion())

-- These globals exists to help test Context objects.
local keyword = [["Foo"]]
local password = [["LobbyWasHere"]]

function love.load(arguments)
    love.window.setMode(LNVL.Settings.Screen.Width, LNVL.Settings.Screen.Height)
    love.graphics.setBackgroundColor(LNVL.Color.Black)

    local extraData = LNVL.Context:new()
    extraData:add("password", password)

    -- This is for examples/20-StringInterpolation.lua
    extraData:add("ClosingRemark", "Have a wonderful day!")

    if #arguments > 1 then
        LNVL.LoadScript(arguments[2], extraData)
    else
        LNVL.LoadScript("examples/02-TwoCharacters.lua", extraData)
    end

    if LNVL.Settings.DebugModeEnabled == true then
        LNVL.Debug.DumpScriptEnvironment()
    end

    print("New password: " .. LNVL.ScriptEnvironment["password"])
end

function love.keypressed(key)
    if key == "return" then
        LNVL.Advance()
    elseif key == "backspace" then
        LNVL.CurrentScene:moveBack()
    end
end

function love.draw()
    LNVL.CurrentScene:draw()
end
