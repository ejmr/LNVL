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

    -- name: The name of the scene as a string.  Currently we use this
    -- only to assist debugging since it allows us to assign a name
    -- that will appear for that scene in console output.  Therefore
    -- the name is optional and defaults to an empty string.
    scene.name = ""

    -- boxBackgroundColor: The color that fills the background
    -- container of the scene when we draw it.
    scene.boxBackgroundColor = {255, 255, 255}

    -- borderColor: The color of the border around the scene
    -- container.  If this is set to nil then there will be no border.
    scene.borderColor = {120, 120, 120}

    -- textColor: The color we use when drawing text.
    scene.textColor = LNVL.Settings.Scenes.TextColor

    -- font: The default font for the dialog.
    scene.font = LNVL.Settings.Scenes.DefaultFont

    -- fullscreen: This boolean controls whether or not the scene
    -- should take up the entire screen.  If it is false then the
    -- content of the scene is confined to a dialog box.
    scene.fullscreen = false

    -- background: This is a string that is a path to an image file
    -- that is the background for the scene.  It is optional and thus
    -- is an empty string by default.  The setBackground() method can
    -- later change this value and the 'backgroundImage' property
    -- described below.
    scene.background = ""

    -- backgroundImage: If the above 'background' property is not an
    -- empty string then this property will be a LÖVE Image object
    -- loaded from the path of the 'background' property.  Since
    -- 'background' is optional this property is nil by default, and
    -- since it is nil that means the constructor cannot change this
    -- property's value.  That means we can make sure only
    -- setBackground() modifies this, to help narrow state-changing
    -- code for the sake of debugging.
    scene.backgroundImage = nil

    -- Apply any properties passed in as arguments that replace any
    -- named defaults we have set above.  We only change values of
    -- properties we have created already, meaning we can only change
    -- existing defaults and not use the arguments to the constructor
    -- to create new properties specific to each object.
    for name,value in pairs(properties) do
        if rawget(scene, name) ~= nil then
            rawset(scene, name, value)
        end
    end

    -- If the for-loop above assign a string to 'background' then we
    -- assume it is a filepath to an image and try to load that image
    -- as the scene background.
    if #scene.background > 0 then
        scene:setBackground(scene.background)
    end

    -- The rest of the 'properties' we turn into opcodes.  We loop
    -- through each remaining property and call a method on it which
    -- will return either a single LNVL.Opcode object or an array of
    -- LNVL.Opcode objects.  In either case we insert the result
    -- directly into the 'opcodes' table.  Those arrays of opcodes
    -- represent opcodes that we will later execute simultaneously.

    local opcodes = {}

    for _,content in ipairs(properties) do
        local new_opcode = self:createOpcodeFromContent(content)
        -- The opcode above may be a single LNVL.Opcode object or it
        -- may be a table representing an array of them.  If it is the
        -- latter then we must check to see if the table has the
        -- '__flatten' property and if it is true.  The commentary for
        -- the LNVL.Opcode.Processor table explains the purpose of
        -- this property.
        if getmetatable(new_opcode) == LNVL.Opcode then
            table.insert(opcodes, new_opcode)
        elseif rawget(new_opcode, "__flatten") == true then
            for _,op in ipairs(new_opcode) do
                table.insert(opcodes, op)
            end
        else
            table.insert(opcodes, new_opcode)
        end
    end

    -- opcodes: The list of opcodes for the scene, created above.
    scene.opcodes = LNVL.ClampedArray:new(opcodes)

    -- opcodeIndex: An index for the 'opcodes' list indicating the
    -- current opcode we should process in the scene.
    scene.opcodeIndex = 1

    -- If LNVL is in debugging mode then display the opcodes for the
    -- scene so we can make sure everything looks right.
    if LNVL.Settings.DebugModeEnabled == true then
        print("-- New Scene --\n")
        print(tostring(scene), "\n")
        LNVL.Debug.printSceneOpcodes(scene)
    end

    return scene
end

-- This metatable function converts a Scene to a string.  This helps
-- us with debugging.  There is one situation where we can have an
-- empty table that has LNVL.Scene for its metatable: the processor
-- function for the 'set-scene-image' opcode.  It documents why.  But
-- because of that possibility we cannot assume the 'scene' parameter
-- in this function has a 'name' property or any other properties.
LNVL.Scene.__tostring = function (scene)
    if scene["name"] ~= nil and #scene.name > 0 then
        return string.format("<Scene: \"%s\">", scene.name)
    else
        return "<Scene: Unnamed>"
    end
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
    -- Normally we call the process() method of all opcodes first, but
    -- we only need to do this for 'say' opcodes when the optional
    -- 'character' data is present, which is never the case in this
    -- situation.  So we can safely skip the method call.
    if contentType == "string" then
        return LNVL.Opcode:new("say", {content=content})
    end

    -- If the content is not a string then it must be a table.
    assert(contentType == "table", "Unknown content type in Scene")

    -- If the content is not an LNVL.Opcode then it must be a table of
    -- them, so we process each opcode in the table and then return
    -- all of them as a group.
    if getmetatable(content) ~= LNVL.Opcode then
        for index,opcode in ipairs(content) do
            content[index] = opcode:process()
        end
        return content
    end

    -- Otherwise we process the individual opcode and return the
    -- results for the scene to save.
    return content:process()
end

-- This method sets the background image.  It accepts a path to the
-- file for the image.  It returns nothing.
function LNVL.Scene:setBackground(filename)
    self.background = filename
    self.backgroundImage = love.graphics.newImage(filename)
end

-- This function changes the background of the current scene.  Note
-- well that this is a function and not a method.  We intend to use
-- this function inside of scripts, i.e. as an argument to the
-- Scene:new() constructor, in order to change the background image of
-- a scene dynamically.  So we cannot define this as a method because
-- the scene with the background we want to change does not even exist
-- when we will call this.  That is why the opcode we return has no
-- reference to the current scene.  But since all opcodes get access
-- to their containing scene later, the opcode will have access to the
-- scene before we convert it into an instruction and execute it.
function LNVL.Scene.changeBackgroundTo(filename)
    return LNVL.Opcode:new("set-scene-image",
                           {image=love.graphics.newImage(filename)})
end

-- This method sets the font for the scene.  It requires a filename to
-- a font file (e.g. a TTF file) and a font size in pixels.  The
-- method returns no value.
function LNVL.Scene:setFont(filename, size)
    self.font = love.graphics.newFont(filename, size)
end

-- This method draws the container or border of the scene.
function LNVL.Scene:drawContainer()
    LNVL.Graphics.drawContainer{
        backgroundColor=self.boxBackgroundColor,
        borderColor=self.borderColor }
end

-- This method draws text within the scene's container.  It will clear
-- the container each time, erasing the current text on screen.  This
-- method returns no value.
function LNVL.Scene:drawText(text)
    LNVL.Graphics.drawText(self.font, self.textColor, text)
end

-- This method draws the parts of a scene that we want on screen
-- everytime we render a scene, such as its background color/image and
-- dialog container.
function LNVL.Scene:drawEssentialElements()
    if self.backgroundImage ~= nil then
        love.graphics.setColorMode("replace")
        love.graphics.draw(self.backgroundImage, 0, 0)
    end

    self:drawContainer()
end

-- Renders the current content to screen.  By 'current content' we
-- mean the current opcode, or list of opcodes; we convert these into
-- instructions and execute those to render the content.  This
-- function returns no value because instructions return no arguments.
-- We must take care to always call drawEssentialElements() before
-- this; the draw() method takes care of that for us.
function LNVL.Scene:drawCurrentContent()
    local opcode = self.opcodes[self.opcodeIndex]

    -- If the opcode is a no-op then we do not need to invoke any
    -- instruction because there is none for that opcode.
    if opcode.name == "no-op" then return end

    local function executeInstructionForOpcode(opcode)
        local instruction = LNVL.Instruction.getForOpcode(opcode.name)

        -- Make sure the opcode has access to the Scene so that the
        -- instruction we invoke next can draw things to Scene if
        -- necessary.
        opcode.arguments.scene = self
        instruction(opcode.arguments)
    end

    -- We have to check to see whether or not we have a single opcode
    -- or an array of opcodes.
    if getmetatable(opcode) == LNVL.Opcode then
        executeInstructionForOpcode(opcode)
    else
        for _,op in ipairs(opcode) do
            executeInstructionForOpcode(op)
        end
    end
end

-- This method draws the scene and is the method intended for use
-- outside of LNVL, e.g. inside of the love.draw() function.
function LNVL.Scene:draw()
    self:drawEssentialElements()
    self:drawCurrentContent()
end

-- This function takes the name of a scene as a string and returns a
-- 'change-scene' opcode that LNVL will use to change the value of
-- LNVL.currentScene later on.  This is not a method because we intend
-- to use it in the parameters for the constructor of an LNVL.Scene
-- object, and at that time we have no object to use.
function LNVL.Scene.changeTo(name)
    return LNVL.Opcode:new("change-scene", {name=name})
end

-- This method moves forward to the next content in the scene.
function LNVL.Scene:moveForward()
    if self.opcodeIndex < #self.opcodes then
        self.opcodeIndex = self.opcodeIndex + 1
    end
end

-- This method moves back to the previous content in the scene.
function LNVL.Scene:moveBack()
    if self.opcodeIndex > 1 then
        self.opcodeIndex = self.opcodeIndex - 1
    end
end

-- Return the class as a module.
return LNVL.Scene
