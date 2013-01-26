--[[
--
-- The main file required by LÖVE.  We do not use this for anything in
-- LNVL except debugging, since we ship out LNVL as a library for
-- other programs to use and not really an executable on its own.
--
-- It reads a script filename from the command-line and loads that.
-- The enter and backspace keys move back and forth through the text.
--
--]]

local LNVL = require("LNVL")

function love.load(arguments)
    love.graphics.setMode(LNVL.Settings.Screen.Width, LNVL.Settings.Screen.Height)
    love.graphics.setBackgroundColor(0, 0, 0)

    if #arguments > 1 then
        LNVL.loadScript(arguments[2])
    end
end

function love.keypressed(key)
    if key == "return" then
        LNVL.currentScene:moveForward()
    elseif key == "backspace" then
        LNVL.currentScene:moveBack()
    end
end

function love.draw()
    LNVL.currentScene:draw()
end
