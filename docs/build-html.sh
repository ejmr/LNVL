#!/bin/bash
#
# This script builds HTML documentation from the Markdown documents in
# the 'docs/' directory via the Pandoc program, available from
#
#     http://johnmacfarlane.net/pandoc/
#
# If you do not have Pandoc then you can also read HTML versions of
# those documents from the project GitHub page:
#
#     https://github.com/ejmr/LNVL/docs/
#
# That version will not have the custom stylesheet or table of
# contents that Pandoc generates, but is still a nice alternative if
# you do not wish to install Pandoc (which is a terrific program by
# the way).

which pandoc >/dev/null    # Run this to set $? to see if Pandoc is available.

if test $? != 0
then
    echo "Error: Cannot find the program Pandoc to create documentation"
    exit 1
fi

find . -type f -name "*.md" -print0 |   \
    xargs -0 -I "{}"                    \
    pandoc "{}"                         \
	-o "html/{}.html"               \
	-f markdown -t html5            \
	--standalone                    \
	--table-of-contents             \
	--css=Style.css                 \
	--smart                         \
	--indented-code-classes=lua
