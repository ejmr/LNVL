--[[
--
-- This class represents drawable objects in LNVL.  These are objects
-- that we render to the screen, such as character avatars.
--
--]]

-- Create the LNVL.Drawable class.
LNVL.Drawable = {}
LNVL.Drawable.__index = LNVL.Drawable

-- Our constructor.
function LNVL.Drawable:new(properties)
    local drawable = {}
    setmetatable(drawable, LNVL.Drawable)

    -- image: The actual image to render when we draw this object.
    -- This property must be an Image object from LÖVE, e.g. the
    -- result of love.graphics.newImage().
    drawable.image = nil

    -- location: An array of two integers representing the X and Y
    -- screen coordinates where we will draw this object.
    drawable.location = {0, 0}

    -- Apply any properties given to the constructor, possibly
    -- replacing the default values above.
    for name,value in pairs(properties) do
        rawset(drawable, name, value)
    end

    return drawable
end

-- This function provides a string representation of a Drawable that
-- we can use in debugging output.
LNVL.Drawable.__tostring = function (drawable)
    if drawable.image == nil then
        return "<Drawable: No Image>"
    else
        return string.format("<Drawable: %s at %d, %d>",
                             tostring(drawable.image),
                             drawable.location[1],
                             drawable.location[2])
    end
end

-- This method will render the Drawable to screen, appearing at the
-- coordinates in the 'location' property.
function LNVL.Drawable:draw()
    love.graphics.setColorMode("replace")
    love.graphics.draw(self.image, self.location[1], self.location[2])
end

-- Return the class as the module.
return LNVL.Drawable
