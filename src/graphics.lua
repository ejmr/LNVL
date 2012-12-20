--[[
--
-- This module provides a namespace of functions for drawing things:
-- the LNVL.Graphics class.  All functions are static and there is no
-- reason to create instances of the class.
--
--]]

-- Create the LNVL.Graphics class.
LNVL.Graphics = {}
LNVL.Graphics.__index = LNVL.Graphics

-- This function draws a 'container', a rectangle that presumably we
-- will use to contain dialog.  The function accepts two keyword
-- arguments:
--
-- 1. 'backgroundColor': The background color of the container.  This
--    must be a value acceptable to love.graphics.setColor().
--
-- 2. 'borderColor': (Optional) the color of the container border.
--
-- The function returns no value.
function LNVL.Graphics.drawContainer(arguments)
    assert(arguments["backgroundColor"] ~= nil,
           "Cannot draw a container without a background color.")

    -- Do we need to draw a border?  If so make it a rectangle that is
    -- a little bigger than the normal sizes so that when we draw the
    -- container over it the result looks like a border.
    if arguments["borderColor"] ~= nil then
        love.graphics.setColor(arguments.borderColor)
        love.graphics.rectangle("fill",
                                LNVL.Settings.Scenes.X,
                                LNVL.Settings.Scenes.Y,
                                LNVL.Settings.Scenes.Width + 10,
                                LNVL.Settings.Scenes.Heigh + 10)
    end

    love.graphics.setColor(arguments.backgroundColor)
    love.graphics.rectangle("fill",
                            LNVL.Settings.Scenes.X,
                            LNVL.Settings.Scenes.Y,
                            LNVL.Settings.Scenes.Width,
                            LNVL.Settings.Scenes.Height)
end

-- Return the class as the module.
return LNVL.Graphics
