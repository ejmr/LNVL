--[[
--
-- The main file required by LÖVE.  We do not use this for anything in
-- LNVL except debugging, since we ship out LNVL as a library for
-- other programs to use and not really an executable on its own.
--
-- The program tests if we can create and draw an LNVL.Scene object.
--
--]]

require("LNVL")

scene = nil

function love.load(arguments)
    love.graphics.setMode(800, 600)
    love.graphics.setBackgroundColor(0, 0, 0)
    scene = LNVL.Scene:new{}
end

function love.draw()
    scene:draw()
end