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
                                LNVL.Settings.Scenes.X - 10,
                                LNVL.Settings.Scenes.Y - 10,
                                LNVL.Settings.Scenes.Width + 20,
                                LNVL.Settings.Scenes.Height + 20)
    end

    love.graphics.setColor(arguments.backgroundColor)
    love.graphics.rectangle("fill",
                            LNVL.Settings.Scenes.X,
                            LNVL.Settings.Scenes.Y,
                            LNVL.Settings.Scenes.Width,
                            LNVL.Settings.Scenes.Height)
end

-- This function draws text to the screen.  The first argument must be
-- a Font object from LÖVE.  The second argument is the default color
-- for the text, i.e. a table of RGB values.  The third argument can
-- be either a string or a table.  If it is a string then we render
-- the text using the current foreground color, which must be set
-- before calling this function.  If it is a table then we iterate
-- through its contents like an array; if the element is a string then
-- we print that text, and if it is a table then we set the foreground
-- color to that, under the assumption the table has three numeric
-- values, i.e. RGB values.  Users should use drawContainer() above to
-- clear it before drawing text.  The function returns no value.
function LNVL.Graphics.drawText(font, color, text)
    love.graphics.setColorMode("modulate")
    love.graphics.setFont(font)

    -- We use this function to iterate through the 'text' argument if
    -- it happens to be a table, handling the string and table
    -- elements appropriately.
    local process =
        function(element)
            if type(element) == "string" then
                love.graphics.printf(element,
                                     LNVL.Settings.Scenes.X + 10,
                                     LNVL.Settings.Scenes.Y + 10,
                                     LNVL.Settings.Scenes.Width - 10,
                                     "left")
            elseif type(element) == "table" then
                love.graphics.setColor(element)
            end
        end

    -- If the 'text' argument is just a string then make a simple
    -- array with the Scene foreground color as the first element and
    -- the string as the second.  That way we can assume 'text' is
    -- always an array and process it using one loop below.
    if type(text) == "string" then
        text = { color, text }
    end

    for _,element in ipairs(text) do process(element) end
end

-- Return the class as the module.
return LNVL.Graphics
