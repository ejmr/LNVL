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

    -- The rest of the 'properties' we turn into opcodes by first
    -- looping through them and creating the appropriate LNVL.Opcode
    -- objects for each.

    local opcodes = {}

    for _,content in ipairs(properties) do
        local contentType = type(content)

        -- Plain strings become "say" opcodes.
        if contentType == "string" then
            table.insert(opcodes,
                         LNVL.Opcode:new("say", {scene=scene, content=content}))
        elseif contentType == "table" then
            -- If the content is a table then we need to look at the
            -- metatable of the content, because most likely what we
            -- have here is the result of calling the method of
            -- another object in the arguments list to the Scene
            -- constructor.
            --
            -- Most likely the content is already an opcode created by
            -- another function.  If that is the case then we may need
            -- to add some additional information before storing it in
            -- the opcodes array.  For example, we need to add the
            -- 'scene' data to opcodes for the 'say' instruction.
            if getmetatable(content) == LNVL.Opcode then
                if content.name == "say" then
                    content.arguments.scene = scene
                end
                table.insert(opcodes, content)
            end
        end
    end

    -- opcodes: The list of opcodes for the scene, created above.
    scene.opcodes = LNVL.ClampedArray:new(opcodes)

    -- opcodeIndex: An index for the 'opcodes' list indicating the
    -- current opcode we should process in the scene.
    scene.opcodeIndex = 1

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

-- Renders the current content to screen.
function LNVL.Scene:drawCurrentContent()
    local opcode = self.opcodes[self.opcodeIndex]
    local instruction = LNVL.Instructions[opcode.name]
    instruction(opcode.arguments)
end

-- Return the class as a module.
return LNVL.Scene
