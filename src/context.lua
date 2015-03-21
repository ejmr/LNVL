--[[

This file provides the Context class.  By default, LNVL scripts cannot
interact with “the outside world.”  They are trapped in a sandbox: the
LNVL.ScriptEnvironment global table.  However, since LNVL is intended
to be a component embedded in other games we need a way to share data
between LNVL dialog scripts and those games.  We accomplish this with
Context objects.  They serve a role similar to LNVL.ScriptEnvironment
but they are specific to a single LNVL script.  By putting data into a
Context and that giving that to LNVL.LoadScript() we can have LNVL
dialog scripts with limited read-write access to data that is outside
of LNVL itself.

--]]

local Context = {}
Context.__index = Context

-- Constructor
function Context:new()
    local context = setmetatable({}, Context)

    -- data: This table stores the key-value pairs that LNVL scripts
    -- will be able to access and affect if given this context.  Use
    -- the methods add() and remove() instead of manipulating this
    -- table directly.  This table has weak values since we assume the
    -- data is coming from somewhere else outside of LNVL where it is
    -- stored more stably.  Or to put it another way, a Context is
    -- meant to hold copies of data which already exists elsewhere.
    context.data = setmetatable({}, { __mode = "v" })

    return context
end

function Context:add(name, value)
    self.data[name] = value
end

function Context:remove(name)
    self.data[name] = nil
end

function Context:get(name)
    return self.data[name]
end

Context.set = Context.add
    
return Context
