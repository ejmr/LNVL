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

    -- borderColor: The color of the border we place around the
    -- Drawable.  If the color is LNVL.Color.Transparent, which is the
    -- default, then we will not draw any border.
    drawable.borderColor = LNVL.Color.Transparent

    -- borderSize: The size of the border in pixels.  By default this
    -- is zero because normally we do not put borders around
    -- Drawables.  In order to have a border a Drawable object must
    -- change this property and 'borderColor' above.
    drawable.borderSize = 0

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
        local position
        if drawable["position"] ~= nil then
            position = tostring(drawable.position) .. ", "
        end
        return string.format("<Drawable: %s at %s%d, %d>",
                             tostring(drawable.image),
                             position,
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
-- coordinates in the 'location' property.  Depending on the values of
-- the 'borderColor' and 'borderSize' properties we may also add a
-- border around the Drawable.  See the commentary for those
-- properties in the Drawable:new() constructor for what types of
-- values they must have in order to make a border appear.
function LNVL.Drawable:draw()
    love.graphics.setColorMode("replace")

    if self.borderColor ~= LNVL.Color.Transparent and self.borderSize > 0 then
        love.graphics.setColor(self.borderColor)
        love.graphics.rectangle("fill",
                                self.location[1] - self.borderSize,
                                self.location[2] - self.borderSize,
                                self:getWidth() + self.borderSize * 2,
                                self:getHeight() + self.borderSize * 2)
    end

    love.graphics.draw(self.image, self.location[1], self.location[2])
end

-- Provide access to the width and height of the Drawable image.
function LNVL.Drawable:getWidth() return self.image:getWidth() end
function LNVL.Drawable:getHeight() return self.image:getHeight() end

-- Return the class as the module.
return LNVL.Drawable
