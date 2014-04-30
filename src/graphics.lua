--[[
--
-- This module provides a namespace of functions for drawing things:
-- the LNVL.Graphics class.  All functions are static and there is no
-- reason to create instances of the class.
--
--]]

-- Create the Graphics class.
local Graphics = {}
Graphics.__index = Graphics

-- This function draws a 'container', a rectangle that presumably we
-- will use to contain dialog.  The function accepts two keyword
-- arguments:
--
-- 1. 'backgroundColor': The background color of the container.  This
--    must be a value acceptable to love.graphics.setColor() or the
--    value LNVL.Color.Transparent.
--
-- 2. 'borderColor': (Optional) the color of the container border.
--
-- The function returns no value.
function Graphics.DrawContainer(arguments)
    assert(arguments["backgroundColor"] ~= nil,
           "Cannot draw a container without a background color.")

    -- If the container is using a transparent background we can bail
    -- now and have full transparency by simply drawing nothing.
    if arguments.backgroundColor == LNVL.Color.Transparent then
        return
    end

    -- Do we need to draw a border?  If so make it a rectangle that is
    -- a little bigger than the normal sizes so that when we draw the
    -- container over it the result looks like a border.
    if arguments["borderColor"] ~= nil then
        love.graphics.setColor(arguments.borderColor)
        love.graphics.rectangle("fill",
                                LNVL.Settings.Scenes.X - LNVL.Settings.Scenes.BorderSize,
                                LNVL.Settings.Scenes.Y - LNVL.Settings.Scenes.BorderSize,
                                LNVL.Settings.Scenes.Width + LNVL.Settings.Scenes.BorderSize * 2,
                                LNVL.Settings.Scenes.Height + LNVL.Settings.Scenes.BorderSize * 2)
    end

    love.graphics.setColor(arguments.backgroundColor)
    love.graphics.rectangle("fill",
                            LNVL.Settings.Scenes.X,
                            LNVL.Settings.Scenes.Y,
                            LNVL.Settings.Scenes.Width,
                            LNVL.Settings.Scenes.Height)
end

-- This function draws text to the screen.  It accepts one argument, a
-- table of content.  The elements in that table can be any of these:
--
-- 1. A Font object.  LNVL will use this font for all of the content
-- that follows.
--
-- 2. A Color object.  Remaining content will use this foreground
-- color, particularly useful for text.
--
-- 3. A string of text to render.
--
-- That means each element in the content table must either be a
-- string or another table.  This function loops through the content
-- and performs the actions above for each element.  Usually we want
-- to call DrawContainer() first to clear the container on screen,
-- because that is where we commonly place text.  This function
-- returns no value.
function Graphics.DrawText(content)
    for _,element in ipairs(content) do
        if type(element) == "string" then
            love.graphics.printf(
                element,
                LNVL.Settings.Scenes.X + 10,
                LNVL.Settings.Scenes.Y + 10,
                LNVL.Settings.Scenes.Width - 15,
                "left")
        elseif getmetatable(element) == LNVL.Color then
            love.graphics.setColor(element)
        elseif element:typeOf("Font") == true then
            love.graphics.setFont(element)
        else
            error("Cannot draw text content " .. tostring(element))
        end
    end
end

-- Return the class as the module.
return Graphics
