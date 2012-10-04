--[[
--
-- The main file required by LÖVE.  We do not use this for anything in
-- LNVL except debugging, since we ship out LNVL as a library for
-- other programs to use and not really an executable on its own.
--
-- The program tests if we can create and draw an LNVL.Scene object
-- with a little dialog.  The enter and backspace keys move back and
-- forth through the text, respectively.  Although it will currently
-- crash if we go too far forward or backward.
--
--]]

require("LNVL")

scene = nil

function love.load(arguments)
    love.graphics.setMode(800, 600)
    love.graphics.setBackgroundColor(0, 0, 0)
    scene = LNVL.Scene:new{
        "Hello world,",
        "This is our first test script.",
        "\n\n\n",
        "...",
        "\n\n",
        "Hey look at my dramatic RPG ellipses!  I am so emo!"
    }
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