######################################################################
#
# **IMPORTANT NOTE**
#
# LNVL is meant to be built using Tup.  This Makefile is an available
# fallback for developers who do not have or use Tup.  However, this
# Makefile may not always be up to date with regard to properly
# building LNVL, and so developers are encouraged to use Tup instead.
#
#     http://gittup.org/tup/
#
######################################################################
#
# This GNU Makefile performs the following operations:
#
# 1. It creates a TAGS file for GNU Emacs if the ctags-exuberant[3]
# program is available.
#
# 2. It creates the 'src/settings.lua' file from the example settings
# file.  But it will not overwrite the settings file if it already
# exists in order to preserve existing changes.  If there are changes
# to the example settings file then you must manually delete
# 'src/settings.lua' in order for the build system to update it.
#
# 3. It ensures all third-party libraries are available.
#
# 4. And most importantly, it builds the LÖVE archive for LNVL.  This
# package is not necessary for games using LNVL, but it is useful to
# us for testing purposes.
#
# The targets for these tasks are, in the order above:
#
#     - tags
#     - settings
#     - libs
#     - archive
#
# There is also the target 'clean' if you want to wipe everything out
# and start with a fresh slate.
#
# The 'all' target performs all of these tasks except 'clean'.
#
######################################################################

TARGETS = settings libs archive

all : $(TARGETS) tags

.PHONY : all $(TARGETS) clean

tags :
	ctags-exuberant -Re --languages=lua \
		--regex-lua="/Processors\[\"([a-z-]+)\"\].+/Opcode.\1/" \
		--regex-lua="/Implementations\[\"([a-z-]+)\"\].+/Instruction.\1/"

settings :
	if [ ! -e "src/settings.lua" ]; then \
		cp "src/settings.lua.example" "src/settings.lua"; \
	fi

libs :
	git submodule init && git submodule update --remote

SOURCES = "main.lua" "LNVL.lua" "src/" "libs/" "examples/"
ARCHIVE = "LNVL.love"

archive :
	if [ -e "$(ARCHIVE)" ]; then rm "$(ARCHIVE)"; fi
	zip --quiet --recurse-paths --compression-method store \
		--update "$(ARCHIVE)" $(SOURCES)

clean :
	rm LNVL.love
	rm TAGS
	rm ./docs/html/html/ -rf
	rm ./src/settings.lua
	rm ./libs/ -rf
