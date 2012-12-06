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
to differentiate between instructions.  Each instruction has an
associated 'action', a function which will execute that instruction.
That function accepts at least two arguments, described in the order
below.  Actions may accept additional arguments as needed for
instructions; however, there are no guidelines for these arguments and
developers should keep them to a minimum so as to introduce as little
inconsistency in the system as possible.

2. `value`: A value associated with the instruction, usually meant for
use with the action described above.

3. `actor`: The object (i.e. another table) that performs that action
function above.  For example, if the instruction is for a character to
enter a scene, the actor would be the character.  Some instructions do
not have actors; those instructions have a `nil` value for this
property.

### An Example Instruction ###

Here is an example of an instruction that tells LNVL to display a line
of dialog by a character:

    {
        "name": "say",
        "value": "Hello!",
        "actor": Lobby,
    }

LNVL would look-up the action function for this instruction—let’s call
it `say()`—and call it like so: `say("Hello!", Lobby)`.  In this
example `Lobby` is likely an `LNVL.Character` object.  The instruction
would use information about the character to determine how to display
and format the dialog, for example.


List of Instructions
--------------------

Below are all of the instructions recognized by LNVL, listed
alphabetically by name.  There are also descriptions of the value and
actors for each instruction where appropriate.

### say ###

This instruction prints dialog to the screen.

**Value:** The string to display.

**Actor:** If this is nil then LNVL displays the value as-is.  If the
actor is non-nil then it must be an `LNVL.Character` object, in which
case the properties of that character affect the display of the dialog
(for example its color).



[1]: http://www.lua.org/manual/5.1/manual.html#2.5.7
[2]: http://www.lua.org/manual/5.1/manual.html#2.8
