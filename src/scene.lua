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

    -- background: This is a string that is a path to an image file
    -- that is the background for the scene.  It is optional and thus
    -- is nil by default.
    scene.background = nil

    -- backgroundImage: If the above 'background' property is not nil
    -- then this property is a LÖVE Image object loaded from the path
    -- of the 'background' property.  Since it is optional it is also
    -- nil by default.
    if scene.background ~= nil then
        scene.backgroundImage = love.graphics.newImage(scene.background)
    else
        scene.backgroundImage = nil
    end

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
        return LNVL.Opcode:new("say", {content=content})
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

    -- If the opcode is 'monologue' then we expand it into an array of
    -- 'say' opcodes for each line of dialog in the monologue.
    if opcode.name == "monologue" then
        local say_opcodes = {}
        for _,content in ipairs(opcode.arguments.content) do
            table.insert(say_opcodes,
                         LNVL.Opcode:new("say",
                                         { content=content,
                                           character=opcode.arguments.character
                                         }))
        end
        return say_opcodes
    end

    -- We should never reach this point because it means we have some
    -- content that we do not understand how to handle.
    error("Unknown content type in Scene")
end

-- This method draws the container or border of the scene.
function LNVL.Scene:drawContainer()
    LNVL.Graphics.drawContainer{backgroundColor=self.backgroundColor}
end

-- This method draws text within the scene's container.  It will clear
-- the container each time, erasing the current text on screen.  This
-- method returns no value.
function LNVL.Scene:drawText(text)
    self:drawContainer()
    LNVL.Graphics.drawText(self.font, self.foregroundColor, text)
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
