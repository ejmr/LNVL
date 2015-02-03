LNVL
====

LNVL implements a simple [visual novel][nvl] component for use in
games based on the [LÖVE engine][love].  LNVL provides only basic
functionality and works best as an addition to another program which
provides actual gameplay.  The great [Ren’Py][renpy] engine is the
main inspiration for LNVL, but this project does not attempt to be an
all-encompassing visual novel engine like Ren’Py.


Important Note
--------------

As of 25 August 2014 you **must** re-clone the repository because we
rewrote the entire history to remove the superfluous `lnvl.love` file.
You can build it from the makefile now.


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

LNVL uses the [GNU General Public License][gpl].

However, one file, `src/rgb.txt`, comes from the
[XFree86 project][xfree86] and therefore uses
[version 1.1 of their license.][xlicense]


Special Thanks
--------------

* Yusuke Tanaka for providing compatibility with LÖVE 0.9.1.
* The code for `LNVL.Debug.TableToString()` uses the work of
  [Julio Manuel Fernandez-Diaz](http://lua-users.org/wiki/TableSerialization).



[nvl]: http://en.wikipedia.org/wiki/Visual_novel
[love]: http://love2d.org/
[renpy]: http://www.renpy.org/
[xfree86]: http://www.xfree86.org/
[xlicense]: http://www.xfree86.org/legal/licenses.html
[pandoc]: http://johnmacfarlane.net/pandoc/
[gpl]: http://www.gnu.org/copyleft/gpl.html
[gnu make]: https://www.gnu.org/software/make/
