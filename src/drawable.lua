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

    -- position: A constant from the LNVL.Position table indicating
    -- the relative position of the Drawable on screen.  This provides
    -- a way to set a location without having to specify actual
    -- coordinates, which is useful when we only care about where the
    -- Drawable appears relative to other objects on screen.
    --
    -- The setPosition() method actually converts the value of this
    -- property into location coordinates.
    drawable.position = nil

    -- Apply any properties given to the constructor, possibly
    -- replacing the default values above.
    for name,value in pairs(properties) do
        rawset(drawable, name, value)
    end

    -- This is somewhat redundant but lets us keep the
    -- position-to-location conversion all within one place.
    if drawable.position ~= nil then
        drawable:setPosition(drawable.position)
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

-- This method accepts an LNVL.Position, e.g. LNVL.Position.Center,
-- and uses that to set the 'location' coordinates of the Drawable.
-- It lets us describe the location of a Drawable in terms of a
-- position relative to the screen instead of in absolute coordinates.
function LNVL.Drawable:setPosition(position)
    self.position = position

    -- We interpret the 'position' property relative to location of
    -- the scene's dialog container, based on the global settings for
    -- scenes.  This way "Left" and "Right" mean aligned with the left
    -- and right edges of the dialog box, and "Center" means in the
    -- center of that.  In all three cases the position will be just
    -- above that dialog box.

    local image_width = self.image:getWidth()
    local image_height = self.image:getHeight()
    local vertical_position = LNVL.Settings.Scenes.Y - image_height - 10

    if self.position == LNVL.Position.Center then
        self.location = {
            LNVL.Settings.Screen.Center[1] - image_width / 2,
            vertical_position,
        }
    elseif self.position == LNVL.Position.Right then
        self.location = {
            LNVL.Settings.Scenes.Width - image_width + LNVL.Settings.Scenes.X,
            vertical_position,
        }
    elseif self.position == LNVL.Position.Left then
        self.location = {
            LNVL.Settings.Scenes.X,
            vertical_position,
        }
    end
end

-- This method will render the Drawable to screen, appearing at the
-- coordinates in the 'location' property.
function LNVL.Drawable:draw()
    love.graphics.setColorMode("replace")
    love.graphics.draw(self.image, self.location[1], self.location[2])
end

-- Provide access to the width and height of the Drawable image.
function LNVL.Drawable:getWidth() return self.image:getWidth() end
function LNVL.Drawable:getHeight() return self.image:getHeight() end

-- Return the class as the module.
return LNVL.Drawable
