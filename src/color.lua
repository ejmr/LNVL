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
-- That file gives the names of colors in varying cases; some use
-- title-case and some are all lower-case.  When creating the table of
-- colors we make each name title-case, e.g. the color name 'linen'
-- becomes 'Linen'.
--
--]]

-- Create the table to hold our colors.
local Color = {}
Color.__index = Color

-- Our handle to the 'rgb.txt' file.  Even though the text file is in
-- the same directory as this module we load the module from the
-- parent directory, and so our path to 'rgb.txt' must reflect that.
local rgb_file = love.filesystem.newFile(string.format("%s/src/rgb.txt", LNVL.PathPrefix))

-- We only need to read the file.
rgb_file:open("r")

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
        name = string.upper(name:sub(1, 1)) .. name:sub(2)
        Color[name] = {r, g, b}
    end
end

-- When we finish parsing we need to close our file.
rgb_file:close()

-- Add a sentinel value for representing transparency in the code.
-- This color has an integer for a value instead of an RGB table
-- because we really do not care what the value is.  We only need a
-- way to distinguish this color from all the rest, and using nil
-- would cause problems in places like Scene and Character
-- constructors.  Using a string would cause a problem with color
-- properties on which we automatically call Color.FromHex() if they
-- have a string value.
Color.Transparent = 0

-- This method accepts a color as a string, in hexadecimal format, and
-- returns a table with the corresponding RGB values.  The string can
-- be in the following formats:
--
-- 1. RRGGBB
-- 2. RGB
--
-- The second form is treated as if each element is doubled, i.e. we
-- treat 'faf' as if it were 'ffaaff'.  The string may optionally
-- begin with the '#' character, so strings like '#ffaaff' are also
-- acceptable.
function Color.FromHex(color_hex)
    local long_regex = "#?(%x%x)(%x%x)(%x%x)"
    local short_regex = "#?(%x)(%x)(%x)"
    local color = {}

    -- We can decide which regular expression to use based on the
    -- string length.  The short format '#fff' can be no longer than
    -- four characters.
    if string.len(color_hex) <= 4 then
        for red,green,blue in string.gmatch(color_hex, short_regex) do
            red = string.rep(red, 2)
            green = string.rep(green, 2)
            blue = string.rep(blue, 2)
            color = { tonumber(red, 16), tonumber(blue, 16), tonumber(green, 16) }
        end
    elseif string.len(color_hex) <= 7 then
        for red,green,blue in string.gmatch(color_hex, long_regex) do
            color = { tonumber(red, 16), tonumber(blue, 16), tonumber(green, 16) }
        end
    else
        -- We should never get here.
        error(string.format("Could not parse the color string %s", color_hex))
    end

    setmetatable(color, Color)
    return color
end

-- Provide a way to convert colors to strings for debugging purposes.
Color.__tostring = function (color)
    return string.format("Color {R=%d G=%d B=%g}",
                         color[1],
                         color[2],
                         color[3])
end

-- Allow dialog scripts to access this module by writing (for example)
-- 'Color.NavyBlue' instead of 'LNVL.Color.NavyBlue'.
LNVL.ScriptEnvironment["Color"] = Color

-- Return our table as a module.
return Color
