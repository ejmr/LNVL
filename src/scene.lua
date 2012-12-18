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
        local new_opcode = self:createOpcodeFromContent(content)

        -- The new opcode will always be a table.  But if its
        -- metatable is not LNVL.Opcode then that means we have an
        -- array of opcodes we need to insert individually.
        if getmetatable(new_opcode) == LNVL.Opcode then
            table.insert(opcodes, new_opcode)
        else
            for _,op in ipairs(new_opcode) do
                table.insert(opcodes, op)
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

-- We use this method to process the contents given to Scene objects
-- and turn them into the appropriate opcodes.  The method accepts one
-- argument, which may be anything that can be a valid element of the
-- 'properties' argument to Scene:new().  The method returns an
-- appropriate LNVL.Opcode object based on the argument.  It may also
-- return an array of LNVL.Opcode objects.
function LNVL.Scene:createOpcodeFromContent(content)
    local contentType = type(content)

    -- If the content is a string then all we only need to create a
    -- simple 'say' opcode, because that means the content is a line
    -- of dialog being spoken without any character involved.
    if contentType == "string" then
        return LNVL.Opcode:new("say", {scene=self, content=content})
    end

    -- If the content is not a string then it must be a table, and
    -- furthermore must be an LNVL.Opcode.
    assert(contentType == "table" and getmetatable(content) == LNVL.Opcode,
           "Unknown content type in Scene")

    -- At this point we know that 'content' is an opcode so we create
    -- another variable for it.  This is to help readability, because
    -- we may be adding 'content' properties to this opcode, and
    -- seeing 'content' twice in a table lookup could be confusing.
    local opcode = content

    -- If our opcode is already a 'say' then we have nothing to do.
    -- We do need to add a 'scene' property to the 'arguments' table
    -- of the opcode but this happens later, just before we render the
    -- dialog to screen.  So we can return the opcode right away.
    if opcode.name == "say" then
        return opcode
    end

    -- We should never reach this point because it means we have some
    -- content that we do not understand how to handle.
    error("Unknown content type in Scene")
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

-- Renders the current content to screen.  This function returns no
-- value because instructions return no arguments.
function LNVL.Scene:drawCurrentContent()
    local opcode = self.opcodes[self.opcodeIndex]
    local instruction = LNVL.Instructions[opcode.name]

    -- Make sure the opcode has access to the Scene so that it can
    -- draw dialog to screen.
    opcode.arguments.scene = self

    instruction(opcode.arguments)
end

-- Return the class as a module.
return LNVL.Scene
