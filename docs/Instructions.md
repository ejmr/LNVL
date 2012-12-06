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
instructions for details on what arguments they require.

**Note:** Unless stated otherwise, the arguments table for the action
function of every instruction has a `scene` property representing the
`LNVL.Scene` object containing the instruction.

Every `LNVL.Instruction` object exists in the `LNVL.Instructions`
table.  The keys are the names of the instructions as strings.  The
values are the objects themselves.


List of Instructions
--------------------

Below are all of the instructions recognized by LNVL, listed
alphabetically by name.  There are also descriptions of the value and
actors for each instruction where appropriate.

### say ###

This instruction prints dialog to the screen.  The table for its
action function requires the following properties:

1. `content`: A string representing the dialog to say.



[1]: http://www.lua.org/manual/5.1/manual.html#2.5.7
[2]: http://www.lua.org/manual/5.1/manual.html#2.8
