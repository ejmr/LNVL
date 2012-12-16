How to Use LNVL
===============

This documents explains how to use LNVL: the LÖVE Visual Novel engine.
It is a tutorial and a guide for users wanting to use LNVL to create
their own stories.  This document assumes you can run LNVL and are
comfortable writing scripts with a text editor of your choice, but
makes no other assumptions about your knowledge of scripting or
programming languages.  The document will sometimes refer to the
reader as the *author.*


The Bird’s-Eye View of LNVL
---------------------------

You use LNVL as the author by writing *scripts.*  These are files that
do things like:

1. Describe scenes for action to take place.
2. Create characters to interact with each other.
3. Provide the dialog and narration for your story.
4. Present options to the reader so he can make choices affecting the
story on a scale that you control.

LNVL scripts are plain text files; you can write them with any text
editor.  But the scripts use their own special language.  This
language provides ways for you to do all of the things listed above.
Here is a simple example:

    Lobby = LNVL.Character:new{name="Lobby Jones", image="images/Lobby.png"}

    START = LNVL.Scene:new{
        Lobby "Hello everyone!",
        Lobby "My name is Lobby Jones.",
        Lobby "And this is my short introduction.",
        Lobby "Now goodbye to you!"
    }

This script creates one character, Lobby Jones, and one scene.  All of
the action in LNVL takes place within scenes, so every script must
define at least one scene.  The action always begins with the `START`
scene, so that is the one you create.  And within that scene you have
our Lobby character speak four lines of dialog.  The user would see
these lines one-by-one and could navigate back and forth between them
at his leisure.

Computer programmers may recognize this language is actually the
[Lua programming language][lua].  That is true.  The special language
LNVL provides is [domain-specific language][dsl] (DSL) written in Lua.
This DSL makes it easier to write scripts for LNVL, but it also means
that, if necessary, authors have the full power of the Lua programming
language at their disposal.


Creating Scenes
---------------

A *scene* is the container for everything that happens in LNVL.  All
character dialog, all background images, all transitions, all of these
things take place inside of a scene.  That means you cannot do
anything without first creating a scene.  Here is the most basic
example:

    START = LNVL.Scene:new{}

The name for this new scene is `START`, which is a special name.  Any
non-trivial story using LNVL will contain multiple scenes, but there
must always be an initial scene.  `START` is that initial scene, the
one LNVL always expects to exist because that is the first one is
displays.  That means every LNVL script *must* define the `START`
scene.

Our example scene is empty though.  You can add narration to the scene
by adding strings.  LNVL will display each string one at a time,
allowing the user to move back and forth through them.  LNVL considers
strings separated with commas as different lines of dialog.  However,
you can concatenate strings too long to fit comfortably on a single
line using the `..` operator.  For example:

    START = LNVL.Scene:new{
        "Hello world!",
        "This is our second line of narration.",
        "And this is the third but even though it spans " ..
          "multiple lines it is actually a single string " ..
          "instead of many.",
        "But now this is our last line of dialog."
    }


Characters
----------

Every good story needs characters.  So LNVL provides a way to create
characters and plug them into your tale.  Here is a simple example of
a character:

    Lobby = LNVL.Character:new{name="Lobby", color="#363"}

The creates the character `Lobby` and defines his name and color,
i.e. the color of that character’s dialog on screen.

### Speaking With Characters ###

You use characters inside of scenes to specify who says which lines of
dialog.  All you have to do is write strings of dialog in the scene
like in the example above, except you provide the character name
before the string.  That tells LNVL which character is speaking that
line.  For example, here is a short scene of two characters speaking:

    Lobby = LNVL.Character:new{name="Lobby", color="#363"}
    Eric = LNVL.Character:new{name="Eric", color=#66a}

    START = LNVL.Scene:new{
        Eric "Hello Lobby!",
        Lobby "Eh?  What?  What time is this?",
        Eric "Are you alright Lobby?",
        Lobby "I'm going back to bed, forget this..."
    }



[lua]: http://www.lua.org/
[dsl]: http://en.wikipedia.org/wiki/Domain_specific_language
