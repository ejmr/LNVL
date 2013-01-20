LNVL Instruction Set
====================



Introduction
------------

The LÖVE Visual Novel (LNVL) engine works by executing a series of
‘instructions’.  These instructions tell the engine to display dialog,
change a background image, bring a character sprite into view, and so
on.  This document explains the technical design of the instruction
system and how it fits into LNVL.  Computer programmers who want to
extend the functionality of LNVL will hopefully find this information
useful.


Structure of Instructions
-------------------------

Instructions in LNVL are [tables][1].  They all have the
[metatable][2] `LNVL.Instruction`.  This way programmers can use
`getmetatable()` to identify LNVL instructions.  Each instruction has
the following properties:

1. `name`: A string naming the instruction.  This is the intended way
to differentiate between instructions.

2. `action`: A function that executes the instruction.  The function
accepts a table of arguments but the exact arguments differ from
instruction to instruction.  See the documentation for individual
instructions for details on what arguments they require.  These
functions are not expected to return anything.

**Note:** Unless stated otherwise, the arguments table for the action
function of every instruction has a `scene` property representing the
`LNVL.Scene` object containing the instruction.

Every `LNVL.Instruction` object exists in the `LNVL.Instructions`
table.  The keys are the names of the instructions as strings.  The
values are the objects themselves.


Opcodes and Their Role
----------------------

LNVL does not *directly* build a list of instructions to execute.
Instead it creates a list of ‘opcodes’.  Each opcode contains the
information LNVL needs to determine which instruction to run and how
to run it.  This extra step of indirection in the process allows LNVL
to pass additional information to instructions more easily.

Each `LNVL.Scene` has a list of opcodes that describe what happens in
that scene.  As the player steps through the scene in the game, LNVL
steps through each opcode one-by-one.  Multiple opcodes may point to
the same instruction but provide different supplementary data, e.g. a
scene may have a lot of opcodes for the `say` instruction but each
will provide its own line of dialog.

The `LNVL.Opcode` class represents opcodes.  An opcode has two
properties:

1. `name`: The name of the instruction LNVL should execute when
it encounters this opcode.

2. `arguments`: A table of additional arguments to give to the
instruction when LNVL executes it.  The definitions of the
instructions dictate the contents of this table, so they will vary
from opcode to opcode.

The function `LNVL.drawCurrentContent()` adds the aforementioned
`scene` property to `arguments`.  Because of this, opcodes *must not*
provide their own `scene` property because LNVL will overrite its
value when executing the related instruction.


How Opcodes and Instructions Interact
-------------------------------------

When LNVL loads a scene, that is, an `LNVL.Scene` object, it creates an
array of opcodes.  Each piece of content in the scene, every argument
given to the `LNVL.Scene:new()` constructor, results in the creation
of one or more `LNVL.Opcode` objects which the engine collects in that
array.  This happens in the `LNVL.Scene:createOpcodeFromContent()`
method, which LNVL calls once for each piece of scene content and
creates one or more opcodes as a result.

Instructions are generic actions that LNVL provides, such as
displaying dialog or drawing an image.  Opcodes fill in the blanks of
instructions so that they have specific effects.  For example, the
`set-image` instruction provides a generic way to set the image for
any object; the `set-character-image` opcode creates a `set-image`
instruction with the additional information necessary to modify a
given character image.

That is the basic relationship between opcodes and instructions.
Opcodes provide specific parameters to instructions, which are more
generic actions in the engine.  Everything LNVL does that the user
sees is the result of executing an instruction.  This happens in the
`LNVL.Scene:drawCurrentContent()` method since scenes are what
contains the opcodes LNVL uses to piece together instructions.


List of Opcodes
---------------

Below are all of the opcodes used in the LNVL engine, listed
alphabetically by name.  Opcodes are always written in lowercase
within the engine code.  Each entry describes what the opcode does and
what instruction or instructions it creates.

### Change-Scene ###

The `change-scene` opcode tells LNVL to switch to a different scene,
i.e. another `LNVL.Scene` object.

### Draw-Character ###

The `draw-character` opcode renders a character to screen.  The opcode
provides information to the `draw-image` instruction, telling it what
image to draw and where.

### Monologue ###

The `monologue` opcode expands into multiple `say` opcodes, used by
the `LNVL.Character:monologue()` method to present multiple lines of
dialog by a single character at once.

### No-Op ###

The `no-op` opcode is unique in that it invokes no instruction.
There are certain methods which can appear within a scene, such as
`LNVL.Character:isAt()`, which require no instruction to affect the
game.  However, because they appear in a scene they must return an
opcode in order for the engine to properly compile the list of
instructions to execute.  The `no-op` opcode exists for those
functions to use.

### Say ###

The `say` opcode generates a `say` instruction.  The commonly-used
methods of `LNVL.Character` objects create this opcode in order to
compile dialog for a particular scene.

### Set-Character-Image ###

The `set-character-image` opcode creates a `set-image` instruction
that will change the image used to display an `LNVL.Character` on
screen.


List of Instructions
--------------------

Below are all of the instructions recognized by LNVL, listed
alphabetically by name.  Instruction names are always written in
lowercase within the engine itself; e.g. the section for the ‘Say’
instruction refers to `say` in the code.  Following the description of
each instruction is a list of any required or optional arguments it
may have.

### Draw-Image ###

This instruction renders an image to the screen.  The arguments table
for its action function requires the following properties:

1. `image`: The image to display.  This must be [an Image object][3].

2. `location`: An array of two elements representing the X and Y
coordinates on screen where the engine will draw the image.

### Say ###

This instruction prints dialog to the screen.  The arguments table for
its action function requires the following properties:

1. `content`: A string representing the dialog to say.

2. `character`: **(Optional)** A instance of an `LNVL.Character` who
will speak the dialog.  If this argument is present the text will
appear in the color defined by the `character.color` property.

### Set-Image ###

This instruction changes images for scenes, characters, and anything
else that uses images for display.  The arguments table for its action
function requires the following properties:

1. `target`: The object whose image will change.  Currently the engine
supports only `LNVL.Character` objects as valid targets.

2. `image`: The new image to use.  This must be [an Image object][3].

### Set-Scene ###

This instruction changes the currently active scene.  The arguments
table for its action function requires one property:

1. `name`: The name of a scene as a string to use as the new current
scene.  The instruction looks for an `LNVL.Scene` object with this
name in the global scope, i.e. inside of `_G`.  That scene becomes the
value of the global `LNVL.currentScene` variable.



[1]: http://www.lua.org/manual/5.1/manual.html#2.5.7
[2]: http://www.lua.org/manual/5.1/manual.html#2.8
[3]: https://love2d.org/wiki/Image
