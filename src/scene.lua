--[[

This file implements scenes in LNVL.  Developers do all work with
scenes through Scene objects, a class that this file defines.

--]]

-- Create the Scene class.
local Scene = {}
Scene.__index = Scene

-- Our constructor.
function Scene:new(properties)
    local scene = {}
    setmetatable(scene, Scene)

    -- id: A string which uniquely identifies this scene.  The value
    -- of this property is for debugging purposes only and no script
    -- or code outside of LNVL should rely on its value.
    scene.id = nil

    -- preconditions: This array can contain strings and functions.
    -- 
    -- If an element is a string then it must name a scene; the player
    -- must have already visited that scene in order to view the scene
    -- we're constructing here.
    --
    -- If an element is a function then LNVL will call it with one
    -- argument: the Scene object containing these preconditions.  The
    -- function must return a boolean.  If the boolean is false then
    -- the scene does not satisfy the preconditions and the player
    -- will not see it.  If the function returns boolean true then the
    -- preconditions are satisfied.  These functions allow the complex
    -- and dynamic creation of pre-requisites that cannot be simply
    -- expressed as scene names, and if fact may have nothing to do
    -- with pre-visited scenes with regard to satisfying the
    -- precondition.
    --
    -- Cf. sceneSatisfiesPreconditions()
    scene.preconditions = {}

    -- boxBackgroundColor: The color that fills the background
    -- container of the scene when we draw it.
    scene.boxBackgroundColor = LNVL.Color.White
    
    -- borderColor: The color of the border around the scene
    -- container.  If this is set to nil then there will be no border.
    scene.borderColor = LNVL.Color.Gray47

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

    -- speedTable: for each character in the current scene, if we want
    -- the character's text's display speed to be different than his
    -- default one, scene.speedTable[character.dialogName] contains
    -- the new speed. If it's nil, the default speed is used.
    scene.speedTable = {}
	
    -- Apply any properties passed in as arguments that replace any
    -- named defaults we have set above.  We only change values of
    -- properties we have created already, meaning we can only change
    -- existing defaults and not use the arguments to the constructor
    -- to create new properties specific to each object.
    for name,value in pairs(properties) do
        if rawget(scene, name) ~= nil then
            rawset(scene, name, value)
        else
            rawset(scene.speedTable, name, value)
        end
    end
		
    -- activeCharacters: This is a table of all of the active
    -- characters in the scene.  Each time we render the contents of
    -- the scene we also render all active characters.  An individual
    -- Character object has all of the data to know where it should
    -- appear on screen, so all the scene must do is tell each
    -- character to draw itself.
    --
    -- Each key in this table is the name of a character, as a string.
    -- The corresponding value is the Character object that represents
    -- the character named by the key.
    --
    -- This table has weak values.  If the only reference to a
    -- specific Character object is the one which remains in this
    -- table then Lua will garbage-collect it.  Because we create each
    -- Character outside of scenes the only time this table will have
    -- the only remaining reference is when we actively start
    -- destroying those external references to completely get rid of
    -- that character.
    self.activeCharacters = {}
    setmetatable(self.activeCharacters, { __mode = "v" })

    -- If the for-loop above assign a string to 'background' then we
    -- assume it is a filepath to an image and try to load that image
    -- as the scene background.
    if #scene.background > 0 then
        scene:setBackground(scene.background)
    end

    -- menus: Some scenes may contain menus that present choices to
    -- the player.  This table contains a list of all menus in the
    -- scene.  The keys are the names of the menus as strings
    -- (i.e. their 'name' property) and the values are the Menu
    -- objects themselves.  The loop below which converts scene
    -- content into opcodes is responsible for populating this table.
    scene.menus = {}

    -- The rest of the 'properties' we turn into opcodes.  We loop
    -- through each remaining property and call a method on it which
    -- will return either a single LNVL.Opcode object or an array of
    -- LNVL.Opcode objects.  In either case we insert the result
    -- directly into the 'opcodes' table.  Those arrays of opcodes
    -- represent opcodes that we will later execute simultaneously.

    local opcodes = {}

    for _,content in ipairs(properties) do
        local new_opcode = self.createOpcodeFromContent(content)
        -- The opcode above may be a single LNVL.Opcode object or it
        -- may be a table representing an array of them.  If it is the
        -- latter then we must check to see if the table has the
        -- '__flatten' property and if it is true.  The commentary for
        -- the Processors in 'src/opcode.lua' table explains the
        -- purpose of this property.
        if rawget(new_opcode, "__flatten") == true then
            for _,op in ipairs(new_opcode) do
                table.insert(opcodes, op)
            end
        else
            table.insert(opcodes, new_opcode)

            -- If the opcode relates to the creation of a menu then we
            -- want to store a reference to that menu in the scene for
            -- future use.
            if new_opcode.name == "add-menu" then
                scene.menus[new_opcode.arguments.menu.name] = new_opcode.arguments.menu
            end
        end
    end

    -- opcodes: The list of opcodes for the scene, created above.
    scene.opcodes = opcodes

    -- Log a warning if the scene has no opcodes, because it's rare
    -- for this to happen, although LNVL does allow it.
    if #scene.opcodes < 1 then
        LNVL.Debug.Log.warn("Creating a Scene with zero opcodes.")
    end

    -- opcodeIndex: An index for the 'opcodes' list indicating the
    -- current opcode we should process in the scene.
    scene.opcodeIndex = 1

    -- definitionInfo: A table of information about where this scene
    -- was created.  See the Lua documentation of lua_getinfo() for
    -- details on what key-value pairs will be in this table.
    scene.definitionInfo = debug.getinfo(2, "Sl")

    -- If LNVL is in debugging mode then display the opcodes for the
    -- scene so we can make sure everything looks right.
    if LNVL.Settings.DebugModeEnabled == true then
        LNVL.Debug.Log.debug(tostring(scene))
        LNVL.Debug.PrintSceneOpcodes(scene)
    end

    return scene
end

-- Create an alias for the constructor for use in dialog scripts.
LNVL.CreateConstructorAlias("Scene", Scene)

-- This metatable function converts a Scene to a string.  In order to
-- help with debugging the string version lists the number of opcodes
-- in the scene.
Scene.__tostring = function (scene)
    local formatString = "<Scene: %s:%i: %i Opcodes>"

    return string.format(formatString,
                         scene.definitionInfo["source"],
                         scene.definitionInfo["currentline"],
                         #scene.opcodes)
end

-- We use this method to process the contents given to Scene objects
-- and turn them into the appropriate opcodes.  The method accepts one
-- argument, which may be anything that can be a valid element of the
-- 'properties' argument to Scene:new().  The method returns an
-- appropriate LNVL.Opcode object based on the argument.  It may also
-- return an array of LNVL.Opcode objects.
function Scene.createOpcodeFromContent(content)
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

    -- If the content is a function then we execute it.  The function
    -- must return an opcode or a string.  If it returns a string then
    -- we treat it the same way we treat strings-as-content above, by
    -- creating 'say' opcodes from them.
    if contentType == "function" then
        setfenv(content, LNVL.ScriptEnvironment)
        local contentValue = content()
        if type(contentValue) == "string" then
            return LNVL.Opcode:new("say", {content=contentValue})
        end
        LNVL.Debug.Log.check(type(contentValue) == "table"
                   and getmetatable(contentValue) == LNVL.Opcode,
               "Functions as scene content must return a string or opcode",
               "error")
        return contentValue
    end

    -- By now the content must be a table.
    LNVL.Debug.Log.check(contentType == "table",
                         "Unknown content type in Scene",
                         "error")

    -- If the content is an LNVL.Menu then we must create an opcode
    -- for it.  Normally functions we call as part of arguments to the
    -- Scene constructor return opcodes, but the constructor for the
    -- Menu class does not.  So we must create the appropriate opcode
    -- manually here.
    if getmetatable(content) == LNVL.Menu then
        return LNVL.Opcode:new("add-menu", {menu=content})
    end

    -- By now if, the content is not an LNVL.Opcode then it must be a
    -- table of opcodes, so we process each in the table and then
    -- return all of them as a group.
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
function Scene:setBackground(filename)
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
function Scene.changeBackgroundTo(filename)
    return LNVL.Opcode:new("set-scene-image",
                           {image=love.graphics.newImage(filename)})
end

-- Create a ChangeSceneBackgroundTo() alias for scripts to use in
-- place of the Scene.changeBackgroundTo() function above.
LNVL.CreateFunctionAlias("ChangeSceneBackgroundTo", Scene.changeBackgroundTo)

-- This method sets the font for the scene.  It requires a filename to
-- a font file (e.g. a TTF file) and a font size in pixels.  The
-- method returns no value.
function Scene:setFont(filename, size)
    self.font = love.graphics.newFont(filename, size)
end

-- This method draws the container or border of the scene.
function Scene:drawContainer()
    LNVL.Graphics.DrawContainer{
        backgroundColor=self.boxBackgroundColor,
        borderColor=self.borderColor }
end

-- This method draws the parts of a scene that we want on screen
-- everytime we render a scene, such as its background color or image,
-- dialog container, active characters, and so on.
function Scene:drawEssentialElements()
    if self.backgroundImage ~= nil then
        love.graphics.setColor(LNVL.Color.White)
        love.graphics.draw(self.backgroundImage, 0, 0)
    end

    for _,character in pairs(self.activeCharacters) do
        character:draw()
    end

    self:drawContainer()
end

-- This method takes a function of two arguments:
--
-- 1. The current Scene.
--
-- 2. The current Opcode.
--
-- The method will call that function with those arguments.  This is
-- useful because our table of opcodes can itself contain tables of
-- opcodes.  We use this method to recursively map functions to our
-- table of opcodes, which is convenient in multiple situations.
--
-- The method returns no values and throws away any return values from
-- its function argument.
function Scene:mapOpcodeFunction(f)
    local opcode = self.opcodes[self.opcodeIndex]

    if getmetatable(opcode) == LNVL.Opcode then
        f(self, opcode)
    else
        for _,op in opcode do
            f(self, op)
        end
    end
end

-- This table contains a list of opcodes that trigger an addition to
-- the scene's list of active characters.
local characterActivatingOpcodes = {
    ["say"] = true,
    ["set-character-image"] = true,
    ["move-character"] = true,
    ["think"] = true,
}

-- This method updates the list of active characters based on
-- the current opcode.
function Scene:refreshActiveCharacters()
    local function refresh(scene, opcode)
        if opcode["arguments"] == nil then return end
        
        local character = opcode.arguments["character"]

        if character == nil then return end

        if opcode.name == "deactivate-character" then
            self.activeCharacters[character.dialogName] = nil
        elseif characterActivatingOpcodes[opcode.name] == true then
            self.activeCharacters[character.dialogName] = character
        end
    end

    self:mapOpcodeFunction(refresh)
end

-- This method returns the instruction(s) for the current opcode.  It
-- will always return a table of Instruction objects, even if the
-- opcode generates only one instruction.
function Scene:getCurrentInstructions()
    local instructions = {}
    local noops = {
        ["no-op"] = true,
        ["deactive-character"] = true,
    }
    
    local function collectInstructions(scene, opcode)
        if noops[opcode.name] ~= true then
            table.insert(instructions, LNVL.Instruction.ForOpcode[opcode.name])
        end
    end
    
    self:mapOpcodeFunction(collectInstructions)
    
    return instructions
end

-- This function draws a scene's current content to screen.  By
-- 'current content' we mean the current opcode, or list of opcodes.
-- We convert these into instructions and execute those to render the
-- content.  This function returns no value because instructions
-- return no arguments.  We take care to always call
-- drawEssentialElements() first since that renders all of the active
-- characters and handles other visual we consider essential to render
-- each tick.
--
-- Because this function renders the results of the current opcode, it
-- will do nothing and return immediately if the scene has no opcodes.
--
-- This function is the default implementation for the hook
-- Settings.Handlers.Scene().  See the Settings module for more
-- documentation on the handler.
function Scene.DefaultHandler(self)
    if #self.opcodes < 1 then return end

    self:refreshActiveCharacters()
    self:drawEssentialElements()

    local executeInstruction = function ()
        local opcode = self.opcodes[self.opcodeIndex]

        -- Make sure the opcode has access to the Scene so that the
        -- instruction we invoke next can draw things to Scene if
        -- necessary.
        for _,instruction in ipairs(self:getCurrentInstructions()) do
            opcode.arguments.scene = self
            instruction(opcode.arguments)
        end

        -- We return a boolean indicating whether the opcode we just
        -- processed was 'immediate' or not.  If it was immediate then
        -- we also increment the opcode index, otherwise we get stuck
        -- in an infinite loop in the repeat-until block below.
        if opcode.immediate == true then
            self:moveForward()
            return true
        else
            return false
        end
    end

    -- We keep processing opcodes and executing instructions until we
    -- reach an opcode that is not to be treated immediately.
    repeat
        local keepExecuting = executeInstruction()
    until
        keepExecuting == false
end

-- Assign our default handler implementation.
LNVL.Settings.Handlers.Scene = Scene.DefaultHandler

-- This utility function ensures that a Scene (the required argument)
-- satisfies all of its preconditions.  It returns two values.  The
-- first is a boolean indicating whether or not all preconditions are
-- satisfied; if they are the function returns 'true' and 'nil'.  If
-- any preconditions are not met, however, the function returns
-- 'false' and an integer, an index in 'scene.preconditions' for the
-- first precondition that failed.
local function sceneSatisfiesPreconditions(scene)
   for index,requisite in pairs(scene.preconditions) do
      if type(requisite) == "string" then
	 LNVL.Debug.Log.check(LNVL.ScriptEnvironment[requisite] ~= nil,
                              "Cannot find prerequisite scene " .. requisite)
	 LNVL.Debug.Log.check(getmetatable(LNVL.ScriptEnvironment[requisite]) == LNVL.Scene,
                              "Prerequsite scene " .. requisite .. " is not a valid Scene")
         if not LNVL.VisitedScenes[requisite] then
             return false, index
         end
      elseif type(requisite) == "function" then
          if requisite(scene) == false then
              return false, index
          end
      else
	 LNVL.Debug.Log.error("Unknown type of precondition.  Must be a string or function.")
      end
   end

   return true, nil
end

-- This function changes the current scene to the one given, which
-- must be a string that names a scene in the script environment.
-- I.e. the function looks for
--
--     LNVL.ScriptEnvironment[name]
--
-- which must have an LNVL.Scene object as its value.
--
-- This function will properly update the scene history and mark the
-- scene as 'visited'.  Use this function to change scenes in code
-- outside of dialogue scripts (cf. ChangeToScene() defined in the
-- src/scene.lua file).  Always use this function instead of directly
-- modifying the value of LNVL.CurrentScene.
--
-- This function returns no value.
local function changeToScene(name)
    local scene = LNVL.ScriptEnvironment[name]

    LNVL.Debug.Log.trace("Changing to scene " .. name)
    LNVL.Debug.Log.check(scene ~= nil,
                         "Cannot find scene with variable name " .. name)
    LNVL.Debug.Log.check(getmetatable(scene) == LNVL.Scene,
                         name .. " is a variable but not a Scene")

    -- Ensure that we've satisfied any preconditions for the scene.
    if scene["preconditions"] ~= nil then
	if sceneSatisfiesPreconditions(scene) ~= true then
	    LNVL.Debug.Log.error("Scene " .. name .. " fails to satisfy preconditions.")
	end
    end

    -- Before we switch scenes we record that we have seen, or
    -- more specifically *about* to see, the new scene.  And
    -- furthermore we record the name of the most recent scene.
    LNVL.VisitedScenes[name] = true
    table.insert(LNVL.SceneHistory, name)

    LNVL.CurrentScene = scene
end

-- Set the handler for changing scenes.
LNVL.ChangeToScene = LNVL.Settings.Handlers.ChangeScene or changeToScene

-- This method draws the scene and is the method intended for use
-- outside of LNVL, e.g. inside of the love.draw() function.
function Scene:draw()
    LNVL.Settings.Handlers.Scene(self)
end

-- This function changes to a different scene based on the given
-- target, which can one of two types of values.  It is meant strictly
-- for use within dialogue scripts.
--
-- If the target is a string then it must be the name of a scene,
-- i.e. a key for the LNVL.ScriptEnvironment table which has a Scene
-- object for its value.  The function will cause the story to jump to
-- that scene unconditionally.
--
-- If the target is a function then LNVL will execute it when the
-- story reaches the instruction ultimtely created by ChangeToScene().
-- The function will receive one argument: the scene which contains
-- it.  The function must return a string, which must be the name of a
-- scene with the same requirements described in the previous
-- paragraph.  Using a function instead of simply a string allows
-- script authors to branch out to different scenes based on arbitrary
-- criteria.
--
-- N.B. The ChangeToScene() function available for use in dialogue
-- scripts **IS NOT** an alias for LNVL.ChangeToScene().  They serve
-- different purposes despite the similarity in names.
LNVL.CreateFunctionAlias(
   "ChangeToScene",
   function (target)
       return LNVL.Opcode:new("change-scene", {target=target})
   end
)

-- This method moves forward to the next content in the scene.
function Scene:moveForward()
   if self.opcodeIndex < #self.opcodes then
      self.opcodeIndex = self.opcodeIndex + 1
   end
end

-- This method moves back to the previous content in the scene.
function Scene:moveBack()
   if self.opcodeIndex > 1 then
      self.opcodeIndex = self.opcodeIndex - 1
   end
end

-- This method takes a table with two values.  The first is the name
-- of a variable as a string.  The second is its new value.  The
-- method generates an opcode and then an instruction that will update
-- the history game with the new value given in the dialogue script.
function Scene.export(data)
   return LNVL.Opcode:new("export-variable", {name=data[1], value=data[2]})
end

-- Create the Set() alias for Scene.export().
LNVL.CreateFunctionAlias("Set", Scene.export)

-- This function fetches a variable from the script environment and so
-- that we can inject its value into dialogue scripts.
function Scene.getEnvironmentVariable(name)
   return LNVL.Opcode:new("import-variable", {name=name})
end

-- Create an alias for fetching environment variables.
LNVL.CreateFunctionAlias("Get", Scene.getEnvironmentVariable)

-- This constant is an alias for the 'no-op' opcode.  We can use it in
-- scripts to represent pauses in scenes, places where there is no
-- dialog but the player must press a key to continue.  We could
-- accomplish the same thing by using empty strings, but this constant
-- improves readability.
LNVL.ScriptEnvironment["Pause"] = LNVL.Opcode:new("no-op")

-- Return the class as a module.
return Scene
