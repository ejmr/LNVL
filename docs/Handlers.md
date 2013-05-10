Customizing LNVL Behavior via ‘Handlers’
========================================

This document explains how programmers can customize certain parts of
the LNVL engine through its ‘handler’ mechanism.  The text assumes the
reader is comfortable with [the Lua programming language][lua] and
[the LÖVE engine][love] which LNVL uses.  It does not assume any prior
knowledge about the internals of LNVL itself.


The Definition of Handlers
--------------------------

A *handler* is a Lua function or [coroutine][] which LNVL expects the
host game to provide (i.e. the game using LNVL).  These handlers
provide entry points for developers to hook custom logic into the LNVL
engine.  All handlers exist in the `LNVL.Settings.Handlers` table and
have descriptions and documentation in the `src/settings.lua.example`
file.  Programmers should consider the comments in that file to be
authoritative in the event there are any differences or discrepancies
between this document and the explanations from that file.

LNVL ignores the return values of all handlers unless noted
otherwise.


How to Create Handlers
----------------------

The description and initial definition of all handlers exists in the
`src/settings.lua.example` file.  Any game using LNVL must create a
copy of this file with the name `src/settings.lua` where developers
can customize the values within for their game.  However, unlike
other settings, developers *must not* implement their own handlers
within that same file.

LNVL loads the `Settings` module very early during initialization
(see `LNVL.Initialize()`).  The engine does not require developers to
implement any handlers and so LNVL provides default implementations
for each.  LNVL does not load most of these defaults until later in
the initialization process, after it finishes loading the `Settings`
module.  For that reason any custom handler implementation added to
the `Settings` module will be later over-written by LNVL’s default
implementation.

Therefore the best time for developers to hook their own handlers into
LNVL is after the function `LNVL.Initialize()` finishes and before
calling `LNVL.LoadScript()` or any other engine function.  Following
that guideline will ensure that LNVL is aware of the developers’
custom handlers before performing anything beyond the necessary
engine initialization.  For example:

```lua
local LNVL = require("LNVL")

LNVL.Initialize()

-- Now is a good time to insert any custom handlers.  In this example
-- we provide a handler to customize how LNVL renders scenes.
LNVL.Settings.Handlers.Scene = function (scene)
    scene:refreshActiveCharacters()
    for name,character in pairs(scene.activeCharacters) do
        doSomethingSpecialWith(character)
    end
end
```

Now any call to `LNVL.CurrentScene:draw()`, the standard API for
rendering the current scene, would use the custom handler above.



[lua]: http://lua.org/
[love]: http://love2d.org/
[coroutine]: http://www.lua.org/manual/5.1/manual.html#2.11
