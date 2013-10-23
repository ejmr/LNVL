--[[
--
-- This class represents drawable objects in LNVL.  These are objects
-- that we render to the screen, such as character avatars.  The most
-- important public API methods of the class are:
--
-- 1. draw()
-- 2. setPosition()
-- 3. setLocation()
--
-- The first two methods defer to handlers that games can customize.
-- See the documentation for 'LNVL.Settings.Handlers.Drawable' for
-- more information.
--
-- The Drawable class makes a strict distinction between the terms
-- 'position' and 'location', as seen in the methods above.  The word
-- 'position' always refers to an instance of the LNVL.Position class.
-- The word 'location' always refers to an array of two numbers
-- representing X--Y screen coordinates, e.g.  acceptable values for
-- the love.graphics.point() function.  While the distinction in
-- terminology is admittedly arbitrary and potentially confusing,
-- there are absolutely no exceptions to their usage in this module or
-- any other part of LNVL code or documentation.
--
--]]

-- Create the Drawable class.
local Drawable = {}
Drawable.__index = Drawable

-- Our constructor.
function Drawable:new(properties)
    local drawable = {}
    setmetatable(drawable, Drawable)

    -- image: The actual image to render when we draw this object.
    -- This property must be an Image object from LÖVE, e.g. the
    -- result of love.graphics.newImage().
    drawable.image = nil

    -- location: An array of two numbers representing the X and Y
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
Drawable.__tostring = function (drawable)
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

-- This method forcibly sets the location of a Drawable with a new
-- pair of X--Y screen coordinates.  Both arguments must be numbers.
function Drawable:setLocation(x, y)
    self.location = {x, y}
end

-- This table contains the functions that we use as the default handlers
-- to satisfy the requirements of 'LNVL.Settings.Handlers.Drawable'.
Drawable.DefaultHandlers = {}

-- This method accepts an LNVL.Position, e.g. LNVL.Position.Center,
-- and uses that to set the 'location' coordinates of the Drawable.
-- It lets us describe the location of a Drawable in terms of a
-- position relative to the screen instead of in absolute coordinates.
--
-- See the documentation for the LNVL.Position class for details about
-- the meaning of the possible position values and where they cause
-- Drawables to appear on screen.
function Drawable.DefaultHandlers.setPosition(self, position)
    self.position = position

    local image_width = self.image:getWidth()
    local image_height = self.image:getHeight()

    -- This lookup table contains X and Y coordinates for all of the
    -- various values of position, augmented for the dimensions of the
    -- Drawable image.  We can assign the values from this table
    -- directly to the 'location' of the Drawable and be done.
    local location_for_position = {}

    location_for_position["Center"] = {
        LNVL.Settings.Screen.Center[1] - image_width / 2,
        LNVL.Settings.Scenes.Y - image_height - 10
    }

    location_for_position["Right"] = {
        LNVL.Settings.Scenes.Width - image_width + LNVL.Settings.Scenes.X,
        location_for_position["Center"][2]
    }

    location_for_position["Left"] = {
        LNVL.Settings.Scenes.X,
        location_for_position["Center"][2]
    }

    location_for_position["TopCenter"] = {
        location_for_position["Center"][1],
        0
    }

    location_for_position["TopRight"] = {
        LNVL.Settings.Scenes.Width - image_width + LNVL.Settings.Scenes.X,
        0
    }

    location_for_position["TopLeft"] = {
        LNVL.Settings.Scenes.X,
        0
    }

    location_for_position["BottomCenter"] = {
        location_for_position["Center"][1],
        LNVL.Settings.Screen.Height - image_height - 10
    }

    location_for_position["BottomRight"] = {
        LNVL.Settings.Scenes.Width - image_width + LNVL.Settings.Scenes.X,
        LNVL.Settings.Screen.Height - image_height - 10
    }

    location_for_position["BottomLeft"] = {
        LNVL.Settings.Scenes.X,
        LNVL.Settings.Screen.Height - image_height - 10
    }

    self.location = location_for_position[self.position]
end

-- This method will render the Drawable to screen, appearing at the
-- coordinates in the 'location' property.  Depending on the values of
-- the 'borderColor' and 'borderSize' properties we may also add a
-- border around the Drawable.  See the commentary for those
-- properties in the Drawable:new() constructor for what types of
-- values they must have in order to make a border appear.
function Drawable.DefaultHandlers.draw(self)
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

-- Assign the default handlers above to the proper place so the engine
-- can find them in the methods to follow.
LNVL.Settings.Handlers = {}
LNVL.Settings.Handlers.Drawable = {
    ["draw"] = Drawable.DefaultHandlers.draw,
    ["setPosition"] = Drawable.DefaultHandlers.setPosition,
}

-- Provide the public API methods that defer to the handlers above.
function Drawable:draw()
    LNVL.Settings.Handlers.Drawable["draw"](self)
end
function Drawable:setPosition(position)
    LNVL.Settings.Handlers.Drawable["setPosition"](self, position)
end

-- Provide access to the width and height of the Drawable image.
function Drawable:getWidth() return self.image:getWidth() end
function Drawable:getHeight() return self.image:getHeight() end

-- Return the class as the module.
return Drawable
