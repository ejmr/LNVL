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

-- Here we're initializing the variables used to display text.
-- First, the length of the initial display.
Graphics.displayLength = 2
-- The text we currently want to display.
Graphics.currentConversationText = ""
-- The speed of the display.
Graphics.displaySpeed = 55
-- The number of characters being drawn to the screen after the first
-- displayLength characters.
Graphics.dialogProgress = 0

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
            Graphics.currentConversationText = element
			Graphics.displayLength = 2
			if displaySpeedLocal ~= nil then
				Graphics.displaySpeed = displaySpeedLocal
			end
			Graphics.DrawAndUpdate(0)
        elseif getmetatable(element) == LNVL.Color then
            love.graphics.setColor(element)
        elseif element:typeOf("Font") == true then
            love.graphics.setFont(element)
        else
            error("Cannot draw text content " .. tostring(element))
        end
    end
end

-- This function is meant to be called within love.update(dt). dt should
-- first be initialized to 0 by a call in Graphics.DrawText. Basically,
-- this function just calls the necessary functions to display text
-- gradually on the screen.
function Graphics.DrawAndUpdate(dt)
	if Graphics.currentConversationText ~= "" then
		updateDisplay(dt)
		drawDialogGradually()
	end
end

-- This function is used to update the message to display on the screen by
-- a speed that should be equal to displaySpeed characters per second.
function love.update(dt)
	Graphics.DrawAndUpdate(dt)
end

-- This function updates the amount of text displayed on the screen.
-- It ensures that the display advances and lets us display text gradually.
function updateDisplay(dt)
	if Graphics.displayLength <= #(Graphics.currentConversationText) then
		Graphics.dialogProgress = Graphics.dialogProgress + Graphics.displaySpeed*dt
		Graphics.textToDraw = Graphics.currentConversationText:sub(1, math.floor(Graphics.displayLength + Graphics.dialogProgress))
	end
end

-- This function simply draws text to the screen.
function drawDialogGradually()
	love.graphics.printf(
		Graphics.textToDraw,
		LNVL.Settings.Scenes.X + 10,
		LNVL.Settings.Scenes.Y + 10,
		LNVL.Settings.Scenes.Width - 15,
		"left")
end

-- Return the class as the module.
return Graphics
