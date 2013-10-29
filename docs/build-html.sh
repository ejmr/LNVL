#!/bin/bash
#
# This script builds HTML documentation from the Markdown documents in
# the 'docs/' directory via the Pandoc program, available from
#
#     http://johnmacfarlane.net/pandoc/
#
# and the 'Markdown Templates' project available at
#
#     http://mixu.net/markdown-styles/
#
# If you do not have neither then you can also read HTML versions of
# those documents from the project GitHub page:
#
#     https://github.com/ejmr/LNVL/docs/
#
# That version will not have the custom stylesheet or table of
# contents but is still a nice alternative if you do not wish to
# install Pandoc (which is a terrific program by the way).

which pandoc >/dev/null    # Run this to set $? to see if Pandoc is available.

if test $? != 0
then
    echo "Error: Cannot find the program Pandoc to create documentation"
    exit 1
fi

which generate-md >/dev/null

if test $? != 0
then
    echo "Error: Cannot find the program generate-md to create documentation"
    exit 2
fi

generate-md --layout "jasonm23-foghorn" \
    --input "./" \
    --output "./html/"
