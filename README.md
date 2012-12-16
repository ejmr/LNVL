LNVL
====

LNVL implements a simple [visual novel][nvl] component for use in
games based on the [LÖVE engine][love].  LNVL provides only basic
functionality and works best as an addition to another program which
provides actual gameplay.  The great [Ren’Py][renpy] engine is the
main inspiration for LNVL, but this project does not attempt to be an
all-encompassing visual novel engine like Ren’Py.


Documentation
-------------

The `docs` directory contains documentation for LNVL.  Users who want
to write stories with LNVL will want to read the `Howto.md` document.
The rest of the documentation is useful to computer programmers who
wish to extend or expand the engine.  If you have the programs
[Tup][tup] and [Pandoc][pandoc] you can run the command `tup upd` to
create nice HTML versions of all of the documents.


License
-------

[GNU General Public License.](http://www.gnu.org/copyleft/gpl.html)

One file, `src/rgb.txt`, comes from the [XFree86 project][xfree86] and
therefore uses [version 1.1 of their license.][xlicense]



[nvl]: http://en.wikipedia.org/wiki/Visual_novel
[love]: http://love2d.org/
[renpy]: http://www.renpy.org/
[xfree86]: http://www.xfree86.org/
[xlicense]: http://www.xfree86.org/legal/licenses.html
[tup]: http://gittup.org/tup/
[pandoc]: http://johnmacfarlane.net/pandoc/
