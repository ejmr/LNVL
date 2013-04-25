--[[
--
-- LNVL: The LÖVE Visual Novel Engine
--
-- This is the only module your game must import in order to use LNVL.
-- Since the intent of LNVL is to act as a sub-module for a larger
-- game it cannot make assumptions about the paths to use in require()
-- statements below.  Often a prefix will need to appear in each of
-- those statements.  For that reason it is a two-step process to use
-- LNVL, for example:
--
--     local LNVL = require "LNVL"
--     LNVL.Initialize("prefix.to.LNVL.src")
--
-- Note well that the argument to Initialize does not end with a
-- period.  It is acceptable for the argument to be an empty string or
-- nil as well, if no path prefix is necessary.
--
-- See the file README.md for more information and links to the
-- official website with documentation.  See the file LICENSE for
-- information on the license for LNVL.
--
--]]

-- This table is the global namespace for all LNVL classes, functions,
-- and data.
LNVL = {}

-- We sandbox all dialog scripts we load via LNVL.LoadScript() in
-- their own environment so that global variables in those scripts
-- cannot clobber existing global variables in any game using LNVL or
-- in LNVL itself.  This table represents that environment.
--
-- We explicitly define the 'LNVL' key so that scripts can access the
-- LNVL table.  Without that key the scripts could not call any LNVL
-- functions and that would make it impossible to define scripts,
-- characters, or do anything meaningful.
LNVL.ScriptEnvironment = { ["LNVL"] = LNVL }

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
-- The function returns nothing.
function LNVL.CreateConstructorAlias(name, class)
    LNVL.ScriptEnvironment[name] = function (...)
        return class:new(...)
    end
end

-- This function creates a function alias, i.e. a function we can use
-- in scripts as a short-cut for a more verbose function defined
-- within LNVL.  The first argument must be the alias we want to
-- create, as a string, and the second argument a reference to the
-- actual function to call.  This function returns no value.
function LNVL.CreateFunctionAlias(name, implementation)
    LNVL.ScriptEnvironment[name] = function (...)
        return implementation(...)
    end
end

-- This property represents the current Scene in use.  We should
-- rarely change the value of this property directly.  Instead the
-- LNVL.LoadScript() function and Scene:changeTo() method are the
-- preferred ways to change changes.
LNVL.CurrentScene = nil

-- This function loads all of the LNVL sub-modules, initializing the
-- engine.  The argument, if given, must be a string that will be
-- treated a prefix to the paths for all require() statements we use
-- to load those sub-modules.  The function also assigns the argument
-- value to 'LNVL.PathPrefix' so that sub-modules may use it for any
-- path operations.
--
-- The 'prefix' argument must not end in a period.
function LNVL.Initialize(prefix)
    if prefix ~= nil then
        LNVL.PathPrefix = string.format("%s.", prefix)
    else
        LNVL.PathPrefix = ""
    end

    local loadModule = function (name, path)
        LNVL[name] = require(LNVL.PathPrefix .. path)
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

    -- Then we load the ClampedArray module to make it accesible to
    -- classes which define properties using that type.
    loadModule("ClampedArray", "src.clamped-array")

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
end

-- This function loads an external LNVL script, i.e. one defining
-- scenes and story content.  The argument is the path to the file;
-- the function assumes the caller has already ensured the file exists
-- and will crash with an error if the file is not found.  The
-- function returns no value.
function LNVL.LoadScript(filename)
    local script = love.filesystem.load(filename)
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
    -- should update the current scene if the 'START' scene exists.
    if LNVL.ScriptEnvironment["START"] ~= nil then
        LNVL.CurrentScene = LNVL.ScriptEnvironment["START"]
        assert(getmetatable(LNVL.CurrentScene) == LNVL.Scene)
    end
end

-- Return the LNVL module.
return LNVL
