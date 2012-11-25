--[[
--
-- The main file required by LÖVE.  We do not use this for anything in
-- LNVL except debugging, since we ship out LNVL as a library for
-- other programs to use and not really an executable on its own.
--
-- The program tests if we can create and draw an LNVL.Scene object
-- with a little dialog.  It reads a script filename from the
-- command-line and loads that.  The enter and backspace keys move
-- back and forth through the text, respectively.  Although it will
-- currently crash if we go too far forward or backward.
--
--]]

require("LNVL")

local scene = nil

function love.load(arguments)
    love.graphics.setMode(800, 600)
    love.graphics.setBackgroundColor(0, 0, 0)

    if #arguments > 1 then
        assert(loadfile(arguments[2]))()
        scene = START
    end
end

function love.keypressed(key)
    if key == "return" then
        scene.contentIndex = scene.contentIndex + 1
    elseif key == "backspace" then
        scene.contentIndex = scene.contentIndex - 1
    end
end

function love.draw()
    scene:drawCurrentContent()
end