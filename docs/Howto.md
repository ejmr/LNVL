How to Use LNVL
===============

This documents explains how to use LNVL: the LÖVE Visual Novel engine.
It is a tutorial and a guide for users wanting to use LNVL to create
their own stories.  This document assumes you can run LNVL and are
comfortable writing scripts with a text editor of your choice, but
makes no other assumptions about your knowledge of scripting or
programming languages.  However, it does assume you are familiar with
[visual novels][nvl] and their related concepts.

The document will sometimes refer to the reader as *the author.*


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
LNVL provides is a [domain-specific language][dsl] (DSL) written in
Lua.  This DSL makes it easier to write scripts for LNVL, but it also
means that, if necessary, authors have the full power of the Lua
programming language at their disposal.


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
one LNVL always expects to exist because that is the first one it
displays.  That means every LNVL script *must* define the `START`
scene.

The example scene is empty though.  You can add narration to the scene
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

### Backgrounds ###

By default a scene has a black background with a white background for
the dialog container.  But you can change these.

To change the dialog box color you can to set the `boxBackgroundColor`
property of the scene.  You must assign the property a list of three
or four numbers, representing the red, green, blue, and (optional)
alpha channels, respectively.  But to make this easier LNVL provides a
`Color` module that has pre-defined names for colors.  For example,
after creating a scene and its dialog you can change its background
color like so:

    START = LNVL.Scene:new{
        boxBackgroundColor = LNVL.Color.NavyBlue,
        "Thus begins our tale...",
    }

The file `src/rgb.txt` names every color you can use; although the
`Color` module always uses title-case names, so the file lists
‘gray50’ but in scripts you write `LNVL.Color.Gray50`.  If you want
transparency you can use `LNVL.Color.Transparent` for any color.

Instead of names you can use [short-hand hexadecimal notation][color-hex]:

    START = LNVL.Scene:new{
        boxBackgroundColor = LNVL.Color.fromHex("#088008"),
        "...",
    }

As for the black background around the dialog box, LNVL lets you use
images for that part of the scene.  You give a background picture to a
scene with by assigning `background` the name of an image file:

    START = LNVL.Scene:new{
        background = "examples/images/Sunny-Hill.jpg",
        "...",
    }

Now LNVL will draw that image throughout the entire scene content.

### Fonts ###

Naturally fonts are important in LNVL because every scene uses one to
render dialog.  Visual novels would be boring if every one used the
same font.  So there are multiple ways you can change the font for
scenes.

The first way is to change the global font.  The file
`src/settings.lua` provides many of the default values for LNVL.
Inside that file is the setting `LNVL.Settings.Scenes.DefaultFont`.
As its verbose name indicates, it represents the default font that
every scene will use.  You can change that default font by giving that
setting the value of [a `Font` object][love-font] using the LÖVE engine
functions; see their documentation for more information.

You may also change the font only for an individual scene without
affecting the rest.  The way you do this is similar to how you change
the background image of a scene.  For example:

    START:setFont("path/to/myFont.ttf", 16)

The first argument is a path to the font file, and the second is the
size of the font in pixels.  So this example code loads a TrueType
font (TTF) and tells the scene to draw the dialog with that font at a
size of sixteen pixels.  This will only affect the `START` scene;
every other scene will continue to use the global default font
discussed above.

LNVL also lets you change the font color for scenes.  Every scene uses
the color from `LNVL.Settings.Scenes.TextColor` by default.  You can
change that value to control the default text color for all scenes.
You can change the color for individual scenes by naming the color
when you create the scene, like so:

    START = LNVL.Scene:new{
        textColor = LNVL.Color.Peach,
        "This narration will be in peach.",
        "It will override the default setting.",
    }

Later on you will see how scenes can have characters who speak dialog.
Those characters can have individual colors for their speech.  Colors
for characters *always* take precedence over colors for scenes.

### Changing Scenes ###

Cramming an entire story into one scene would create a mess.  You
*could* do it, but that doesn’t make it a good idea.  It is easier to
put a story together by breaking it down into scenes just as you would
if you were writing a play.  You can create as many scenes as you want
by assigning them to names of your choice.  For example:

    START = LNVL.Scene:new{…}

    MIDDLE = LNVL.Scene:new{…}

    END = LNVL.Scene:new{…}

This example code creates three scenes.  Remember that every LNVL
script must have the `START` screen.  But the rest of the names are
arbitrary and can be anything you want.  The example scene names are
in all capital letters, but this is not a requirement, only a
suggested convention.

Creating scenes, however, does nothing to connect them to one another.
In the example above LNVL would not know how to progress from `START`
to the `MIDDLE` scene.  You can connect the two using the
`LNVL.Scene.changeTo()` function.  Here is an example:

    START = LNVL.Scene:new{
        "And so our story begins...",
        "Except I really have nothing to say as a narrator.",
        "Oh well.  Let's move along!",
        LNVL.Scene.changeTo("MIDDLE"),
    }

    MIDDLE = LNVL.Scene:new{
        "Now then...",

        -- Just pretend an actual story is here and save me the effort
        -- of writing some dumb garbage, ok?

    }

The important line here is the final part of the `START` scene:
`LNVL.Scene.changeTo("MIDDLE")`.  This tells LNVL to transition to the
`MIDDLE` scene once it reaches the end of `START`.  Notice the name of
the scene is in quotes; this is a requirement.  If you omit the quotes
then LNVL will crash with an error.

You can place additional dialog or anything else after a line using
`changeTo()` but there is no good reason to do so.  LNVL will not
display any dialog or do anything else in a scene once it is told to
switch to another scene.  So that means `changeTo()` is best placed as
the final part of a scene.


Characters
----------

Every good story needs characters.  So LNVL provides a way to create
characters and plug them into your tale.  Here is a simple example of
a character:

    Lobby = LNVL.Character:new{name="Lobby", textColor="#363"}

This creates the character `Lobby` and defines his name and color,
i.e. the color of that character’s dialog on screen.

### Speaking With Characters ###

You use characters inside of scenes to specify who says which lines of
dialog.  All you have to do is write strings of dialog in the scene
like in the example above, except you provide the character name
before the string.  That tells LNVL which character is speaking that
line.  For example, here is a short scene of two characters speaking:

    Lobby = LNVL.Character:new{name="Lobby", textColor="#363"}
    Eric = LNVL.Character:new{name="Eric", textColor="#66a"}

    START = LNVL.Scene:new{
        Eric "Hello Lobby!",
        Lobby "Eh?  What?  What time is this?",
        Eric "Are you alright Lobby?",
        Lobby "I'm going back to bed, forget this..."
    }

To make a character speak all you have to do is type the dialog after
the character’s name.  This helps your scripts read naturally.  But
what if you have one character speak numerous lines in a row?  You
could copy the character name each time, but LNVL provides a way for
you to avoid that repetition: by writing a *monologue.*  Here is an
example:

    START = LNVL.Scene:new{
        Eric:monologue {
            "Look Lobby, we need to talk.",
            "You have a problem.",
            "And it worries me.  It worries all your friends.",
            "You don't work.  You steal money from me constantly. " ..
                "You're intoxicated every day...",
            "We just want to help you Lobby."
        },
        Lobby "Eh, what?  Sorry.  I wasn't listening."
    }

By using `Eric:monologue { … }` you can write multiple lines of dialog
for that character without having to prefix every line with the
character’s name.  But be careful to add the comma after the closing
curly-brace in a monologue.  That is a common syntax error that will
cause LNVL to reject your script.

### Character Images ###

Often you will want to show a character on screen, as is common in
visual novels, role-playing games, and all manner of genres.  LNVL
allows you to assign multiple images to a character and change between
them throughout a scene.  This can help convey your story by showing
changes in a character’s emotion through art, for example.

To use images with a character you must first provide a default image,
like so:

    Lobby = LNVL.Character:new{
        name = "Lobby Jones",
        textColor = "#363",
        image = "images/Lobby-Default.png",
    }

Notice the new property: `image`.  This has a path to an image file
which LNVL will use as the default picture for that character.  Now
LNVL will show that image whenever the character speaks.

But it would be dull if you could only use one image.  So LNVL lets
you change character images during scenes by making a character
‘become’ something else.  Think of it as the character becoming
surprised, excited, saddened—like that.  That is why you use the
`becomes` function of characters in scripts to change their images.
Here is an example:

    START = LNVL.Scene:new{
        Lobby "So I thought about what you said and...",
        Lobby:becomes("images/Lobby-crying.png"),
        Lobby "...I realize I need help.",
        Lobby "I'm sorry for everything.  Please forgive me!",
        Lobby:becomesNormal(),
        Lobby "Heh, nah, I'm just kidding.  Dummy.",
        Lobby:becomes("images/Lobby-laughing.png"),
    }

The lines like `Lobby:becomes("images/Lobby-crying.png")` tell LNVL to
change the character image of screen.  As you can see, it accepts the
path to an image file as its argument.  The path must obey
[the restrictions LÖVE has on files][love-files].

The initial image you give when creating the character is the ‘normal’
image.  That means `Lobby:becomesNormal()` reverts the character back
to his original image.  You could use `becomes()` and provide the path
to the original image, but LNVL lets you use `becomesNormal()` as a
short-cut.

### Image Positions ###

You will not want every character portrait to appear at the same place
on screen.  If you did then they would overlap and block each other
out!  So LNVL allows you specify where each character image should
appear.

Character images appear on the left side on the screen by default.
The first way you can change this is to specify the position when you
create a character, like so:

    Lobby = LNVL.Character:new{
        name = "Lobby Jones",
        textColor = "#363",
        image = "images/Lobby-Default.png",
        position = "Right",
    }

This is the same as the character definition from earlier but with one
addition: the new `position` property.  The string `"Right"` tells
LNVL that it should draw Lobby’s image on the right side of the screen
instead of the usual left.  These are the acceptable values for
`position`:

1. `"Left"`
2. `"Center"`
3. `"Right"`
4. `"TopLeft"`
5. `"TopCenter"`
6. `"TopRight"`
7. `"BottomLeft"`
8. `"BottomCenter"`
9. `"BottomRight"`

They do not provide pixel-perfect control over the position.  Instead
LNVL decides what is best for ‘Right’, for example, based on settings
such as the screen size and the width of other elements on screen.
This helps prevent you from accidentally covering up other things with
character images.

The second way to change a character position is by using the `isAt`
function.  It requires one of the three strings above as its
argument.  But unlike the `position` property, `isAt` allows you to
change the position of a character dynamically in the middle of the
scene.  For example:

    START = LNVL.Scene:new{
        Lobby "Want to see how fast I can run?",
        Lobby:isAt "Center",
        Lobby "Ok---hold on, I'm getting there.",
        Lobby:isAt "Right",
        Lobby:becomes "images/Lobby-exhausted.png",
        Lobby "I need to stop smoking...",
    }

Each use of `isAt` makes LNVL draw the character image at the new
position.  This is useful to move a character to a new position when
you introduce another in a scene to avoid any overlap.  You can also
use it for dramatic effects; if you have characters in an argument,
for example, you could group characters on each side based on their
conflicting points-of-view, maybe with a mediator in the center trying
to calm everyone down.  Look at popular visual novels for ideas about
how you can convey feelings in a story through the use of character
portrait positioning.



[lua]: http://www.lua.org/
[dsl]: http://en.wikipedia.org/wiki/Domain_specific_language
[color-hex]: http://en.wikipedia.org/wiki/Web_colors#Shorthand_hexadecimal_form
[love-font]: https://love2d.org/wiki/Font
[love-files]: https://love2d.org/wiki/love.filesystem
[nvl]: http://en.wikipedia.org/wiki/Visual_novel
