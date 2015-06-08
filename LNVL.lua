--[[

LNVL: The LÖVE Visual Novel Engine

This is the only module your game must import in order to use LNVL.
Since the intent of LNVL is to act as a sub-module for a larger game
it cannot make assumptions about the paths to use in require()
statements below.  Often a prefix will need to appear in each of those
statements.  For that reason it is a two-step process to use LNVL, for
example:

    local LNVL = require "LNVL"
    LNVL.Initialize("prefix.to.LNVL.src")

Note well that the argument to Initialize does not end with a period.
It is acceptable for the argument to be an empty string or nil as
well, if no path prefix is necessary.

See the file README.md for more information and links to the official
website with documentation.  See the file LICENSE for information on
the license for LNVL.

--]]

-- This table is the global namespace for all LNVL classes, functions,
-- and data.  Some of the modules, i.e. the source code files we load
-- during LNVL.Initialize(), rely on access to this global table.
-- Therefore we cannot declare this table as 'local', even though that
-- would be a cleaner approach overall.
LNVL = {}

-- Version information.
LNVL.Version = setmetatable(
    {
        ["Major"] = 0,
        ["Minor"] = 1,
        ["Patch"] = 0,
        ["Label"] = "-unstable",
    },
    {
        __tostring = function()
            return string.format("%d.%d.%d%s",
                                 LNVL.Version.Major,
                                 LNVL.Version.Minor,
                                 LNVL.Version.Patch,
                                 LNVL.Version.Label)
        end
    }
)

-- We sandbox all dialog scripts we load via LNVL.LoadScript() in
-- their own environment so that global variables in those scripts
-- cannot clobber existing global variables in any game using LNVL or
-- in LNVL itself.  This table represents the blueprint for that
-- environment.  Because of the ability to use Context objects with
-- LoadScript(), it is possibly that we will load a script with an
-- environment that is different from what is in this table by
-- default.
--
-- We explicitly define the 'LNVL' key so that scripts can access the
-- LNVL table.  Without that key the scripts could not call any LNVL
-- functions and that would make it impossible to define scripts,
-- characters, or do anything meaningful.
LNVL.ScriptEnvironment = { ["LNVL"] = LNVL }

-- For debugging purposes we allow the use of Lua's print(), assert(),
-- error(), and tostring() functions within dialogue scripts.
--
-- The definitions for assert() and error() are deferred until we load
-- the LNVL.Debug module so that we can use the special versions of
-- those functions defined by that module.
LNVL.ScriptEnvironment["print"] = print
LNVL.ScriptEnvironment["tostring"] = tostring

-- This is a lookup table of functions which are essential to LNVL and
-- which we do not let the user overwrite, otherwise they may be able
-- to do something like rewrite the Character constructor accidentally
local ReservedKeywords = {}

-- This metatable changes the __newindex() of the script environment
-- so that we cannot add anything that conflicts with the names
-- listed in the ReservedKeywords table.
setmetatable(LNVL.ScriptEnvironment, {
                 __newindex = function (table, key, value)
                     if ReservedKeywords[key] == true then
                         error(key .. " is a reserved word.")
                     else
                         rawset(table, key, value)
                     end
                 end
})

-- This function creates a constructor alias in the script
-- environment.  These aliases allow us to write more terse, readable
-- code in dialog scripts by providing shortcuts for common LNVL
-- constructors we use.  For example, by calling
--
--     LNVL.CreateConstructorAlias("Scene", LNVL.Scene)
--
-- we can define scenes in our scripts by simply writing 'FOO =
-- Scene{...}' instead of 'FOO = LNVL.Scene:new{...}'.
--
-- This function expects the name of the alias to create as the first
-- argument, a string, and a reference to the class to instantiate as
-- the second argument.  The function expects the class to have a
-- new() method for a constructor.
--
-- The constructor created by this function becomes a reserved
-- keyword in all LNVL dialogue scripts.
--
-- The function returns nothing.
function LNVL.CreateConstructorAlias(name, class)
    LNVL.ScriptEnvironment[name] = function (...)
        return class:new(...)
    end
    ReservedKeywords[name] = true
end

-- This function creates a function alias, i.e. a function we can use
-- in scripts as a short-cut for a more verbose function defined
-- within LNVL.  The first argument must be the alias we want to
-- create, as a string, and the second argument a reference to the
-- actual function to call.  This function returns no value.
--
-- Like the above, function aliases created this way become reserved
-- words in all LNVL dialogue scripts.
function LNVL.CreateFunctionAlias(name, implementation)
    LNVL.ScriptEnvironment[name] = function (...)
        return implementation(...)
    end
    ReservedKeywords[name] = true
end

-- This property represents the current Scene in use.  We should
-- rarely change the value of this property directly.  Instead we
-- should use the LNVL.ChangeToScene() function.  LNVL.LoadScript()
-- will also change this value whenever we load a script that defines
-- a scene named 'START'.
LNVL.CurrentScene = nil

-- This table is a map of all scenes we have visited.  That is, scenes
-- for which the user has progressed through their content.  The keys
-- are the names of the scenes that we've shown, and the value for
-- each key is always 'true', allowing us to perform a simple look-up
-- to determine if we have already shown a scene or not.
--
-- N.B. This table does not represent the order in which we displayed
-- each scene.
LNVL.VisitedScenes = {}

-- This table is a stack respresenting the exact order in which the
-- player has traversed through the scenes.  Using various gameplay
-- mechanics it may be possible to back up through old scenes, and see
-- the implementation of the 'set-scene' instruction for details.
--
-- The keys are numeric indicates and the values are LNVL.Scene's.
-- Developers may write code like
--
--     for index,scene in ipairs(LNVL.SceneHistory) do
--         ...
--     end
--
-- to access each LNVL.Scene (as 'scene' above) in the order in which
-- the player encountered those scenes (indicated by 'index' above).
LNVL.SceneHistory = {}

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
	 assert(LNVL.ScriptEnvironment[requisite] ~= nil,
		"Cannot find prerequisite scene " .. requisite)
	 assert(getmetatable(LNVL.ScriptEnvironment[requisite]) == LNVL.Scene,
		"Prerequsite scene " .. requisite .. " is not a valid Scene")
         if not LNVL.VisitedScenes[requisite] then
             return false, index
         end
      elseif type(requisite) == "function" then
          if requisite(scene) == false then
              return false, index
          end
      else
	 error("Unknown type of precondition.  Must be a string or function.")
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
function LNVL.ChangeToScene(name)
    local scene = LNVL.ScriptEnvironment[name]

    assert(scene ~= nil,
	   "Cannot find scene with variable name " .. name)
    assert(getmetatable(scene) == LNVL.Scene,
	   name .. " is a variable but not a Scene")

    -- Ensure that we've satisfied any preconditions for the scene.
    if scene["preconditions"] ~= nil then
	if sceneSatisfiesPreconditions(scene) ~= true then
	    error("Scene " .. name .. " fails to satisfy preconditions.")
	end
    end

    -- Before we switch scenes we record that we have seen, or
    -- more specifically *about* to see, the new scene.  And
    -- furthermore we record the name of the most recent scene.
    LNVL.VisitedScenes[name] = true
    table.insert(LNVL.SceneHistory, name)

    LNVL.CurrentScene = scene
end

-- This function loads all of the LNVL sub-modules, initializing the
-- engine.  The argument, if given, must be a string that will be
-- treated a prefix to the paths for all require() statements we use
-- to load those sub-modules.  The function also assigns the argument
-- value to 'LNVL.PathPrefix' so that sub-modules may use it for any
-- path operations.
--
-- The 'prefix' argument must not end in a period.
function LNVL.Initialize(prefix)
    LNVL.PathPrefix = prefix or ""

    local loadModule = function (name, path)
        LNVL[name] = require(string.format("%s.%s", LNVL.PathPrefix, path))
    end

    -- Because all of the code in the 'src/' directory adds to the LNVL
    -- table these require() statements must come after we declare the
    -- LNVL table above.  We must require() each module in a specific
    -- order, so insertions or changes to this list must be careful.

    -- First we must load any modules that define global values we may use
    -- in the Settings module.
    loadModule("Color", "src.color")
    loadModule("Position", "src.position")

    -- Next we need to load Settings as soon as possible so that other
    -- modules can draw default values from there.
    loadModule("Settings", "src.settings")

    -- We want to load Debug after Settings and before other modules so
    -- that they can have special behavior if debug mode is enabled, which
    -- the Settings module controls.
    loadModule("Debug", "src.debug")

    -- Then we should load the Graphics module so that the rest have
    -- access to primitive rendering functions.
    loadModule("Graphics", "src.graphics")

    -- Next come the Opcode and Instruction modules, in that order, since
    -- the remaining modules may generate opcodes.  And since opcodes
    -- create instructions we load them in that sequence.
    loadModule("Opcode", "src.opcode")
    loadModule("Instruction", "src.instruction")

    -- Next comes the Drawable module, which classes below may use for
    -- certain properties.
    loadModule("Drawable", "src.drawable")

    -- The order of the remaining modules can come in any order as they do
    -- not depend on each other.
    --
    -- Note that we load the LNVL.MenuChoice class inside of the LNVL.Menu
    -- code, so it does not appear in the list below.
    loadModule("Character", "src.character")
    loadModule("Scene", "src.scene")
    loadModule("Menu", "src.menu")
    loadModule("Progress", "src.progress")
    loadModule("Context", "src.context")
end

-- This function lets us advance through a dialog by pressing the 
-- appropriate key declared in love.keypressed(). If the current dialog 
-- has been fully displayed, it will move on to the next scene.
-- Otherwise, it will fully display the current dialog.
function LNVL.Advance()
	if LNVL.Graphics.dialogProgress >= (#LNVL.Graphics.currentConversationText - LNVL.Graphics.displayLength)
		and LNVL.CurrentScene.opcodeIndex < #LNVL.CurrentScene.opcodes then
			LNVL.Graphics.dialogProgress = 0
			LNVL.Graphics.displayLength = LNVL.Graphics.displaySpeedDefault
			LNVL.CurrentScene:moveForward()
	else
		LNVL.Graphics.dialogProgress = #LNVL.Graphics.currentConversationText
	end
end

-- The purpose of this function is to merge the data of Context
-- objects with LNVL.ScriptEnvironment whenever we call LoadScript().
-- It is not intended to be a general-purpose table merging function
-- and will break on such things as tables with circular values.
--
-- The function returns no value.  It directly modifies the key-value
-- pairs of the LNVL.ScriptEnvironment table itself.
local function mergeContexts(...)
    local contexts = {...}

    if #contexts == 0 then return end

    for _,context in ipairs(contexts) do
        for key,value in pairs(context.data) do
            LNVL.ScriptEnvironment[key] = value
        end
    end
end

-- This function loads an external LNVL script, i.e. one defining
-- scenes and story content.  The argument is the path to the file;
-- the function assumes the caller has already ensured the file exists
-- and will crash with an error if the file is not found.
--
-- After the filename can come any number of LNVL.Context objects,
-- which will modify the script environment for the script we're
-- loading *AND* all future scripts we load.
--
-- The function returns no value.
function LNVL.LoadScript(filename, ...)
    local script = love.filesystem.load(filename)

    mergeContexts(...)
    assert(script, "Could not load script " .. filename)
    setfenv(script, LNVL.ScriptEnvironment)

    -- The variable 'script' is a chunk reperesenting the code from
    -- the file we loaded.  In other words, 'script' is a function we
    -- can execute to run the code from that file.  If we are using
    -- debug mode then we call script() like a regular function.  This
    -- will cause LNVL to crash if the code in that chunk causes any
    -- errors.  If we are running in debug mode that is what we want.
    -- But if we are not using debug mode then we execute the chunck
    -- in a protected mode and silently ignore any errors.
    if LNVL.Settings.DebugModeEnabled == true then
        script()
    else
        pcall(script)
    end

    -- We always treat 'START' as the initial scene in any story so we
    -- update the current scene if 'START' exists.
    if LNVL.ScriptEnvironment["START"] ~= nil then
	LNVL.ChangeToScene("START")
    end

    -- Once we have finished loading a script we loop through the
    -- script environment looking for every Scene object.  We then
    -- take the key for that Scene from the environment table,
    -- representing the variable name used when defining the scene,
    -- and assign it to the Scene.id property for future debugging
    -- output.  There is some redundancy here in that we will perform
    -- this action for scenes which we have already tagged earlier.
    for key,value in pairs(LNVL.ScriptEnvironment) do
        if getmetatable(value) == LNVL.Scene
        or getmetatable(value) == LNVL.Character then
            value.id = key
        end
    end
end

-- Return the LNVL module.
return LNVL
