######################################################################
#
# This GNU Makefile performs the following operations:
#
# 1. It builds the HTML documentation from the Markdown files if the
# program Pandoc[1] is available.
#
# 2. It creates a TAGS file for GNU Emacs if the ctags-exuberant[2]
# program is available.
#
# 3. It creates the 'src/settings.lua' file from the example settings
# file.  But it will not overwrite the settings file if it already
# exists in order to preserve existing changes.  If there are changes
# to the example settings file then you must manually delete
# 'src/settings.lua' in order for the build system to update it.
#
# 4. And most importantly, it builds the LÖVE archive for LNVL.  This
# package is not necessary for games using LNVL, but it is useful to
# us for testing purposes.
#
# 5. It will delete all of the HTML documentation for regeneration as
# well as the settings file and the 'lnvl.love' archive.  Only use
# this target to create a fresh, clean start.
#
# The targets for these tasks are, in the order above:
#
#     - docs
#     - tags
#     - settings
#     - archive
#     - clean
#
# The 'all' target performs all of these tasks except 'clean'.
#
#
#
# [1]: http://johnmacfarlane.net/pandoc/
# [2]: http://ctags.sourceforge.net/
#
######################################################################

TARGETS = docs tags settings archive

all : $(TARGETS)

.PHONY : all $(TARGETS) clean

docs :
	cd ./docs/ && ./build-html.sh

tags :
	ctags-exuberant -Re --languages=lua \
		--regex-lua="/Opcode\.Processor\[\"([a-z-]+)\"\].+/Opcode.\1/" \
		--regex-lua="/LNVL\.Instructions\[\"([a-z-]+)\"\].+/Instruction.\1/"

settings :
	if [ ! -e "src/settings.lua" ]; then \
		cp "src/settings.lua.example" "src/settings.lua"; \
	fi

SOURCES = "*.lua" "src/" "examples/"
ARCHIVE = "lnvl.love"

archive :
	if [ -e "$(ARCHIVE)" ]; then rm "$(ARCHIVE)"; fi
	zip --quiet --recurse-paths --compression-method store \
		--update "$(ARCHIVE)" $(SOURCES)

clean :
	rm lnvl.love
	rm TAGS
	rm ./docs/html/*.html
	rm ./src/settings.lua

