LNVL Design Document
====================

This document outlines the overall design of LNVL: the LÖVE Visual
Novel engine.  It details how to use the engine from the perspective
of users or developers incorporating LNVL into an existing project.
The document also describes the terminology and concepts we use
throughout LNVL.



Basic Concepts
==============


Scenes
------

Everything in LNVL happens within a *scene.*  Like in a play, a scene
encompasses a particular sequence of dialog between one or more
characters.  A scene may take place in a specific location, and it may
transition between places as the action progresses.  Also scenes may
present the user with choices he has to make that determine the
direction of the scene; this allows developers to create branches in
the story.

Developers write all scenes in [Lua](http://www.lua.org).  That means
developers have the full power of Lua available for complex logic if
they need it.  But LNVL provides a library that handles all of the
fundamental functionality that most developers will need.  For
example, classes like `LNVL.Scene` and `LNVL.Character` provide the
necessities developers need to create scenes and characters,
respectively.  This makes LNVL scripts look like they use a
[domain-specific language][dsl] instead of regular Lua code.


Characters
----------


Menus and Choices
-----------------



Credits
=======

We owe thanks to Tom Rothamel and the rest of the [Ren’Py][rpy] team
for their work on the Ren’Py engine.  Its behavior and design inspires
much of LNVL.  We also owe thanks to W.Dee, creator of [KiriKiri][kk],
for similar inspiration.



[rpy]: http://www.renpy.org/
[kk]: http://kikyou.info/tvp/
[dsl]: http://en.wikipedia.org/wiki/Domain-specific_language
