Technical Overview of LNVL
==========================

This document describes the technical behavior of LNVL, intended for
programmers who want to modify or extend the engine.


Execution Model
---------------

1. `LNVL.Initialize()` creates the global `LNVL` table and adds the
   engine’s modules to that table.  This step happens only once.

2. The function `LNVL.LoadScript()` loads each dialog script.  There
   is no inherent limit to the number of scripts which LNVL can load.
   The rest of the steps described below occur once for each script.

3. All variables created in the dialog script become key-value pairs
   of the `LNVL.ScriptEnvironment` table, where the keys are the
   variable names, pointing to their corresponding value.  The values,
   i.e. the variables, will typically be either characters or scenes.

4. If the variable is a `Scene` object then LNVL processes all of its
   arguments.  That is, everything given to the constructor.

5. Each individual arugment in the constructor creates an `Opcode`
   object.  These opcodes hold data which LNVL will use later, e.g. to
   construct the scene visually on screen.  Each `Scene` maintains a
   table of the `Opcode` objects made in the constructor, along with
   an index to the current opcode.

6. Calling `Scene:draw()` will fetch the current opcode using the
   aforementioned index.  The opocde is then given an additional piece
   of information: a reference to the `Scene` containing it, which is
   not available when creating the opcodes because the constructor is
   still running and thus there is no `Scene` to use then.

7. LNVL will look-up the instruction for that opcode and then run it.
   These instructions perform many of the actions which the player
   sees, e.g. introducing character sprites, changing scenes,
   modifying the background, and so forth.
