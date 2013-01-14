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
        return LNVL.Opcode:new("say", {content=content})
    end

    -- If the content is not a string then it must be a table.
    assert(contentType == "table", "Unknown content type in Scene")

    -- We now know our content is a table.  However, that can mean one
    -- of two things:
    --
    -- 1. If the metatable is LNVL.Opcode then the table represents an
    -- opcode that we possibly need to deal with in some specific way.
    --
    -- 2. If there is no metatable then we assume the table represents
    -- a collection on LNVL.Opcode objects.  We loop through these
    -- calling createOpcodeFromContent() recursively on each,
    -- collecting the results into a table.  We then return that back
    -- to the LNVL.Scene constructor which will flatten that table of
    -- opcodes out into individual entries in its list of opcodes for
    -- the scene.
    --
    -- This code deals with the second scenario.  Code in the rest of
    -- the function handles the first.
    if getmetatable(content) ~= LNVL.Opcode then
        local opcodes = {}
        for _,opcode in ipairs(content) do
            table.insert(opcodes, self:createOpcodeFromContent(opcode))
        end
        return opcodes
    end

    -- At this point we know that 'content' is an opcode so we create
    -- another variable for it.  This is to help readability, because
    -- we may be adding 'content' properties to this opcode, and
    -- seeing 'content' twice in a table lookup could be confusing.
    local opcode = content

    -- The metatable for 'opcode' must be LNVL.Opcode.
    assert(getmetatable(opcode) == LNVL.Opcode, "Unknown content type in Scene")

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

    -- If the opcode is 'draw-character' then we need to convert the
    -- 'position' data into the appropriate 'location' data expected
    -- by the 'draw-image' instruction which the opcode will become.
    if opcode.name == "draw-character" then
        if opcode.arguments.position == LNVL.Position.Center then
            opcode.arguments.location = LNVL.Settings.Screen.Center
        elseif opcode.arguments.position == LNVL.Position.Right then
            opcode.arguments.location = {
                LNVL.Settings.Screen.Width - 200,
                LNVL.Settings.Screen.Center[2],
            }
        elseif opcode.arguments.position == LNVL.Position.Left then
            opcode.arguments.location = {
                200,
                LNVL.Settings.Screen.Center[2],
            }
        end

        return opcode
    end

    -- We have no extra data to add to the following opcodes so we
    -- return them as-is.  Some of these opcodes may need a 'scene'
    -- property, but the drawCurrentContent() method ensures that
    -- property exists, so we do not need to add it here.

    if opcode.name == "say"
    or opcode.name == "set-character-image"
    then
        return opcode
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
    LNVL.Graphics.drawText(self.font, text)
end

-- This method draws the scene to the screen.
function LNVL.Scene:draw()
    self:drawContainer()
end

-- Renders the current content to screen.  This function returns no
-- value because instructions return no arguments.
function LNVL.Scene:drawCurrentContent()
    local opcode = self.opcodes[self.opcodeIndex]
    local instruction = LNVL.Instruction.getForOpcode(opcode.name)

    -- Make sure the opcode has access to the Scene so that it can
    -- draw dialog to screen.
    opcode.arguments.scene = self

    instruction(opcode.arguments)
end

-- Return the class as a module.
return LNVL.Scene
