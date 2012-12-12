--[[
--
-- This module defines a class of colors.  It maps names in the
-- LNVL.Color table to tables of RGB values suitable as arguments to
-- love.graphics.setColor() and similar functions.  We generate the
-- list of colors dynamically from the 'rgb.txt' file from X11.  The
-- license at
--
--     http://www.xfree86.org/legal/licenses.html
--
-- applies to that 'rgb.txt' file.
--
--]]

-- Create the table to hold our colors.
LNVL.Color = {}
LNVL.Color.__index = LNVL.Color

-- Our handle to the 'rgb.txt' file.  Even though the text file is in
-- the same directory as this module we load the module from the
-- parent directory, and so our path to 'rgb.txt' must reflect that.
local rgb_file = io.open("src/rgb.txt", "r")

-- The first line of the file contains some metadata that we do not
-- need, so we read one line to throw it away.
rgb_file:read()

-- Now we loop through every remaining line, parsing it into an entry
-- for our table of colors.  Every line has this format:
--
--     red gren blue    colorName
--
-- So that dictates the regular expression we use to match entries.

local rgb_entry_regex = "(%d+)%s+(%d+)%s+(%d+)%s+(%w+)"

for line in rgb_file:lines() do
    for r,g,b,name in string.gmatch(line, rgb_entry_regex) do
        LNVL.Color[name] = {r, g, b}
    end
end

-- When we finish parsing we need to close our file.
rgb_file:close()

-- Return our table as a module.
return LNVL.Color