--[[
--
-- This file implements characters in LNVL.  Characters represent
-- actors in scenes and are typically the medium through which most
-- dialog will be shown.
--
--]]

-- Create the Character class.
local Character = {}
Character.__index = Character

-- The constructor for characters.
function Character:new(properties)
    local character = {}
    setmetatable(character, Character)

    -- dialogName: The name of the character as a string that we
    -- display in scene.  Right now we set it as an empty string
    -- because the loop later through 'properties' should give it a
    -- value.  If it does not then we default to using 'firstName'.
    -- If that has no value then we signal an error because every
    -- character must have a name.
    character.dialogName = ""

    -- firstName and lastName: These properties represent the full
    -- name of the character.
    character.firstName = ""
    character.lastName = ""

    -- textColor: The color that we use for lines this character
    -- speaks during a scene.  We expect this to be a table of three
    -- integers representing the red, green, and blue values of the
    -- colors, with values in the 0--255 range.  It may also be a
    -- named color from the LNVL.Color table.
    character.textColor = LNVL.Settings.Characters.TextColor

    -- font: This is a Font object representing the font we should use
    -- for all of this character's dialog.  By default this is nil and
    -- the character will use whatever font is defined for the scenes
    -- in which the character appears.  Later on in the constructor we
    -- check for a potential 'font' element in 'properties' and, if it
    -- exists, assign the appropriate object to this.
    character.font = nil

    -- images: A hash of images for the character.  These are the
    -- sprites we display on screen when the character is speaking,
    -- for example.  All of the values in the table are Drawable
    -- objects.  The keys are strings which are pathnames to the image
    -- files.  However, the table also has one key named 'normal';
    -- this key points to the default image for the character, the one
    -- we intend to use the most often.
    character.images = { normal = nil }

    -- currentImage: A key for the 'images' table above, i.e. a
    -- string, naming the image we currently use to draw the
    -- character.
    character.currentImage = "normal"

    -- borderColor: The color of the border we draw around the
    -- character image whenever it appears on screen.  If the value is
    -- LNVL.Color.Transparent then we will not draw a border.
    character.borderColor = LNVL.Settings.Characters.BorderColor

    -- borderSize: The width of the border, in pixels, to draw around
    -- the character image.  If this is zero then we will still
    -- technically draw a border, but it will have no width and thus
    -- not actually appear on screen.
    character.borderSize = LNVL.Settings.Characters.BorderSize

    -- position: This property has one of the LNVL.Position.*
    -- constants as its value.  It indicates where on the screen the
    -- character's images should appear by default.
    character.position = LNVL.Settings.Characters.DefaultPosition

    -- Overwrite any default property values above with ones given to
    -- the constructor.
    for name,value in pairs(properties) do
        if rawget(character, name) ~= nil then
            rawset(character, name, value)
        end
    end

    -- If the constructor received a 'font' property then we need to
    -- handle that.  The property may either be a string or an array.
    -- If it is a string then we treat that as the font name.  If it
    -- is an array then the first element is the font name as a string
    -- and the second (optional) element is the size in pixels as an
    -- integer.
    if properties["font"] ~= nil then
        if type(properties.font) == "string" then
            character.font = love.graphics.newFont(properties.font)
        elseif type(properties.font) == "table" then
            character.font = love.graphics.newFont(unpack(properties.font))
        end
    end

    -- If the constructor received a 'position' property then set the
    -- appropriate value to the character by looking up that property
    -- in the LNVL.Position table.
    if properties["position"] ~= nil then
        character.position = LNVL.Position[properties["position"]]
    end

    -- The constructor arguments may have an 'image' property.  If so,
    -- this is the image file we want to use for the normal character
    -- image, so we need to check for it.
    if properties["image"] ~= nil then
        character.images.normal = LNVL.Drawable:new{image=love.graphics.newImage(properties.image)}
        character.images[properties.image] = character.images.normal
    end

    -- The for-loop above may set the color-related properties to
    -- strings.  If so then we assume they now have a value like
    -- '#33cfaf', i.e. a hex color string.  We need to convert that
    -- back into a table of RGB color values.
    if type(character.textColor) == "string" then
        character.textColor = LNVL.Color.FromHex(character.textColor)
    end
    if type(character.borderColor) == "string" then
        character.borderColor = LNVL.Color.FromHex(character.borderColor)
    end

    -- Make sure the character has a name, because we do not support
    -- unnamed characters.  First try using the first name as a
    -- fallback name.
    
    if character.dialogName == nil or character.dialogName == "" then
        if character.firstName == nil or character.firstName == "" then
            error("Cannot create unnamed character")
        else
            character.dialogName = character.firstName
        end
    end

    -- If we are in debugging mode then dump the character data to the
    -- console so that we can verify everything looks correct.
    if LNVL.Settings.DebugModeEnabled == true then
        print("-- New Character --\n")
        print(LNVL.Debug.TableToString(character, character.dialogName))
    end

    return character
end

-- Create an alias for the constructor for use in dialog scripts.
LNVL.CreateConstructorAlias("Character", Character)

-- This is the method that characters use to speak in scripts.  It
-- accepts a string of text as an argument and returns a 'say' opcode
-- binding that line of text with the current Character object.  We do
-- this because we are very likely calling this method as an argument
-- to another function like LNVL.Scene:new(), which means Lua will
-- evaluate the argument (i.e. call the method) before the logic in
-- the calling function runs.  In those functions we want access to
-- the Character object, and the data given to the character,
-- e.g. here the text to speak.  So the only way to get that is to
-- attach the two and then return the entire object so we will have
-- access to them later.
function Character:says(text)
    return LNVL.Opcode:new("say", {content=text, character=self})
end

-- This method accepts a table of strings and treats all of them as
-- lines of dialog spoken by the character.  This is a way that
-- scripts can provide monologues without having to repeat the
-- character object over and over.  The function returns a 'monologue'
-- opcode with the dialog and character attached.
function Character:monologue(lines)
    return LNVL.Opcode:new("monologue", {content=lines, character=self})
end

-- A list of acceptable values for the parameter of the displayName()
-- method below.
local acceptableDisplayNameValues = {
    ["default"] = true,
    ["firstName"] = true,
    ["lastName"] = true,
    ["fullName"] = true,
}

-- This method changes the name which LNVL will display in dialog
-- screens whenever the character speaks.
function Character:displayName(nameType)
    if acceptableDisplayNameValues[nameType] then
        return LNVL.Opcode:new("set-character-name",
                               {character=self, name=nameType})
    end
    error(("Unacceptable character display name type: %s"):format(nameType))
end

-- Returns the character's full name.  This method is not meant for
-- use inside of scenes.  Use the displayName() method to show a
-- character's full name in dialog.  This method is for convenience
-- for games that use LNVL.
function Character:getFullName()
    return ("%s %s"):format(self.firstName, self.lastName)
end

-- If we call a Character object as a function then we treat that as a
-- short-cut for calling the says() method.  This can make dialog
-- scripts more readable.
Character.__call = function (character, ...)
    return character:says(...)
end

-- This method changes the position of a character, which primarily
-- affects where we draw his image.  The argument is a string which
-- must be a valid key for the LNVL.Position table.  The method
-- returns a 'move-character' opcode.
function Character:isAt(place)
    return LNVL.Opcode:new(
        "move-character",
        {
            character=self,
            position=LNVL.Position[place]
        })
end

-- This method accepts a string as a path to an image file, and
-- changes the character's current image to that.  If the file is not
-- part of the 'character.images' table then we will store it there
-- for future reference; and if we have already loaded that image once
-- we just use that table without reloading the image file.
--
-- The method returns an opcode telling the engine to use the new
-- character image.
function Character:becomes(filename)
    if self.images[filename] == nil then
        self.images[filename] = LNVL.Drawable:new{image=love.graphics.newImage(filename)}
    end

    return LNVL.Opcode:new("set-character-image", {character=self, image=filename})
end

-- This method is a short-cut for character:becomes("normal"),
-- i.e. changing back to their default image.
function Character:becomesNormal()
    return self:becomes("normal")
end

-- This function draws the character to the screen, drawing whichever
-- image the 'currentImage' property names.  Before drawing the image
-- we make sure the position of the image matches the position of the
-- character.  This is the default handler for drawing characters.
-- See 'LNVL.Settings.Handlers.Character' for more details.
function Character.DefaultHandler(self)
    local image = self.images[self.currentImage]

    if image ~= nil then
        image:setPosition(self.position)
        image:draw()
    end
end

-- Assign our default handler.
LNVL.Settings.Handlers.Character = Character.DefaultHandler

-- This method renders the character by invoking the appropriate
-- handler function just in case a game wants to use custom behavior
-- for rendering characters instead of LNVL's built-in process.
function Character:draw()
    LNVL.Settings.Handlers.Character(self)
end

-- This method removes a character from a scene by creating an opcode
-- that deactivates the character.
function Character:leavesTheScene()
    return LNVL.Opcode:new("deactivate-character", {character=self})
end

-- This function converts a Character object into a string for
-- debugging purposes.
Character.__tostring = function (character)
    return character.dialogName
end

-- Return the class as a module.
return Character
