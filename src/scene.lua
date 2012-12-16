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
                    table.insert(opcodes, content)
                elseif content.name == "monologue" then
                    -- For the 'monologue' opcode
                    -- content.arguments.content will be a table of
                    -- strings.  We need to create a 'say' opcode for
                    -- each of them.
                    for _,line in ipairs(content.arguments.content) do
                        local say =
                            LNVL.Opcode:new("say",
                                            { scene=scene,
                                              content=line,
                                              character=content.arguments.character
                                            })
                        table.insert(opcodes, say)
                    end
                end
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

-- This method draws text within the scene's container.  The argument
-- can be either a string or a table.  If it is a string then we
-- render the text using the current foreground color of the Scene
-- object.  If it is a table then we iterate through its contents like
-- an array; if the element is a string then we print that text, and
-- if it is a table then we set the foreground color to that, under
-- the assumption the table has three numeric values, i.e. RGB values.
--
-- Each call to this method clears the container, so sequential calls
-- will not append text.  This method returns no value.
function LNVL.Scene:drawText(text)
    self:drawContainer()
    love.graphics.setFont(self.font)

    local process =
        function(element)
            if type(element) == "string" then
                love.graphics.printf(element,
                                     self.Dimensions.X + 10,
                                     self.Dimensions.Y + 10,
                                     self.Dimensions.Width - 10,
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
        text = { self.foregroundColor, text }
    end

    for _,element in ipairs(text) do process(element) end
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
