--[[
--
-- This file implements scenes in LNVL.  Developers do all work with
-- scenes through Scene objects, a class that this file defines.
--
--]]

-- Create the LNVL.Scene class.
LNVL.Scene = {}
LNVL.Scene.__index = LNVL.Scene

-- Our constructor.
function LNVL.Scene:new(properties)
    local scene = {}
    setmetatable(scene, LNVL.Scene)

    -- backgroundColor: The color that fills the background container
    -- of the scene when we draw it.
    scene.backgroundColor = {255, 255, 255}

    -- foregroundColor: The color we use when drawing text.
    scene.foregroundColor = {0, 0, 0}

    -- font: The default font for the dialog.
    scene.font = love.graphics.newFont(20)

    -- fullscreen: This boolean controls whether or not the scene
    -- should take up the entire screen.  If it is false then the
    -- content of the scene is confined to a dialog box.
    scene.fullscreen = false

    -- Apply any properties passed in as arguments that replace any
    -- named defaults we have set above.  We only change values of
    -- properties we have created already, meaning we can only change
    -- existing defaults and not use the arguments to the constructor
    -- to create new properties specific to each object.
    for name,value in pairs(properties) do
        if rawget(scene, name) ~= nil then
            rawset(scene, name, value)
            table.remove(properties, name)
        end
    end

    -- contents: The rest of the 'properties' table becomes the
    -- contents of the scene, which could be an array of anything from
    -- strings to other objects.
    scene.contents = LNVL.ClampedArray:new(properties)

    -- contentIndex: An integer indicating where we are currently in
    -- the scene contents.  This is useful for keeping track of what
    -- to display or do since we can step back and forth in a scene.
    scene.contentIndex = 1

    return scene
end

-- These are the default dimensions for a Scene.  These values will be
-- given as the values to arguments of the same name for functions
-- like love.graphics.rectangle().
LNVL.Scene.Dimensions = {
    Width = 600,
    Height = 240,
    X = 100,
    Y = 300,
}

-- This method draws the container or border of the scene.
function LNVL.Scene:drawContainer()
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill",
                            self.Dimensions.X,
                            self.Dimensions.Y,
                            self.Dimensions.Width,
                            self.Dimensions.Height)
end

-- This method takes a string of text and draws it to the scene.  It
-- will clear the scene first, so sequential calls will not append the
-- text.
function LNVL.Scene:drawText(text)
    self:drawContainer()
    love.graphics.setColor(self.foregroundColor)
    love.graphics.setFont(self.font)
    love.graphics.printf(text,
                         self.Dimensions.X + 10,
                         self.Dimensions.Y + 10,
                         self.Dimensions.Width - 10,
                         "left")
end

-- This method draws the scene to the screen.
function LNVL.Scene:draw()
    self:drawContainer()
end

-- Renders the current content to screen.  That is, whatever is it
-- 'self.content[self.contentIndex]', which could be many things based
-- on its type.  This function returns no value.
function LNVL.Scene:drawCurrentContent()
    local content = self.contents[self.contentIndex]
    local contentType = type(content)

    -- Right now all we know how to handle are strings.
    if contentType == "string" then
        self:drawText(content)
    else
        error("LNVL.Scene cannot render " .. contentType .. " content")
    end
end

-- Return the class as a module.
return LNVL.Scene
