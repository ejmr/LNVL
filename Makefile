# The name of the '*.love' file for the engine.
OUTPUT=lnvl.love

# By default put all of the Lua scripts into the $OUTPUT file we
# listed above.
all :
	zip --recurse-paths \
	--compression-method store \
	--update $(OUTPUT) *.lua src/*

# Create a TAGS file to use with GNU Emacs.
tags :
	ctags-exuberant -Re --languages=lua

# Remove the $OUTPUT file and perform any other cleanup.
clean :
	rm $(OUTPUT)
