LNVL
====

IMPORTANT: Development and Legal Status
---------------------------------------

LNVL is no longer in active development, and has not been since late 2015.
For personal reasons I rarely contribute to code publically anymore,
and thus I have archived this project on GitHub since I have no desire
or intention to respond to pull-requests or bug reports.  Nonetheless, I
give my complete support and blessing to anyone wishing to use this code
for any purpose.  I am not the *sole* author of the LNVL codebase, but I
am the principle author, having written almost every line.  For my part,
I release all LNVL code I've written to the Public Domain, and legally
release any claim of copyright for my work.  **The copyright remains
for the code I did not write.**  You can use Git (e.g. `git-blame`)
to see exactly who wrote which lines, if that is important to you for
legal reasons; I have no authority nor wish to reliquinsh the copyright
of LNVL's contributors.  If you want to have a "clean" (legally-speaking)
codebase to use, then I suggest you use Git to identify and then delete
all code authored by anyone *except* Eric James Michael Ritz.

*Note:* Git distinguishes between authors and committers; there is
code for which I am the committer but *not* the author, and I *do not*
release any such code to the Public Domain, only that for which I am
*both* the author and committer.

    -- ejmr, 10 May 2018



About
-----

LNVL implements a simple [visual novel][nvl] component for use in
games based on the [LÖVE engine][love].  LNVL provides only basic
functionality and works best as an addition to another program which
provides actual gameplay.  The great [Ren’Py][renpy] engine is the
main inspiration for LNVL, but this project does not attempt to be an
all-encompassing visual novel engine like Ren’Py.


Installation and Configuration
------------------------------

In order to use LNVL you first need to unzip it wherever you intend to
use that engine, i.e. where you will use `require("LNVL")` in your
code.  You must also initialize LNVL, providing (if necessary) the
path to the LNVL module.  For example:

```lua
local LNVL = require("LNVL")
LNVL.Initialize("game.src.LNVL")
```

This example assumes that LNVL is in the `./game/src/LNVL/` directory
from the root of the game incorporating the engine.  The documentation
at the beginning of the `LNVL.lua` file explains this process in more
detail, as does the commentary for the function `LNVL.Initialize()`,
which is in that same file.

Within the `src` directory is the `src/settings.lua.example` file.
Read through it to see how you can configure LNVL.  However, *do not*
edit that file directly.  LNVL expects to find a `src/settings.lua`
file, which is not part of the repository so that each installation
can have their own configuration.  If you have [GNU Make][] then you
can create this file by running `make settings` from the project’s
top-level directory.


Documentation
-------------

The `docs` directory contains documentation for LNVL.  Users who want
to write stories with LNVL will want to read the `Howto.md` document.
The rest of the documentation is useful to computer programmers who
wish to extend or expand the engine.  If you have the [Pandoc][]
program then you can create HTML versions of these documents for
(arguably) easier browsing by running the `make docs` command.


Examples
--------

The `examples` directory has scripts that demonstrate and test
different features of LNVL.  However, they currently will not run
because most of them rely on images which are not included in the
repository.  These images are currently assets borrowed from another
game project in development, but eventually they will be part of the
LNVL source.  My apologies until then for the inconvenience in being
unable to run any of the examples.


Copyright and License
---------------------

Copyright 2012, 2013, 2014, 2015 Plutono INC.

All work by Eric James Michael Ritz belongs to the Public Domain as of 2018.
Read the 'Status' section at the top of this document for details.

All of LNVL prior to the 10th of May 2018 is protected by the [GNU General Public License][gpl],
with two exceptions:

1. One file, `src/rgb.txt`, comes from the
[XFree86 project][xfree86] and therefore uses
[version 1.1 of their license.][xlicense]

2. LNVL also uses [`log.lua`][log.lua], Copyright 2014–2015 rxi, released
under [the MIT license](./libs/log/LICENSE).



Special Thanks
--------------

* Yusuke Tanaka for providing compatibility with LÖVE 0.9.1.
* The code for `LNVL.Debug.TableToString()` uses the work of
  [Julio Manuel Fernandez-Diaz](http://lua-users.org/wiki/TableSerialization).
* [rxi][] for the `log.lua` library.



Dedication
----------

*For Jeff, Ben, and Mira.*

As part of releasing my work to the Public Domain, I also hereby request
that future developers never remove this dedication from this documentation.

    -- ejmr



[nvl]: http://en.wikipedia.org/wiki/Visual_novel
[love]: http://love2d.org/
[renpy]: http://www.renpy.org/
[xfree86]: http://www.xfree86.org/
[xlicense]: http://www.xfree86.org/legal/licenses.html
[pandoc]: http://johnmacfarlane.net/pandoc/
[gpl]: http://www.gnu.org/copyleft/gpl.html
[gnu make]: https://www.gnu.org/software/make/
[log.lua]: https://github.com/rxi/log.lua
[rxi]: https://github.com/rxi
[Travis-CI-Badge]: https://travis-ci.org/ejmr/LNVL.svg
[Travis-CI]: https://travis-ci.org/ejmr/LNVL
