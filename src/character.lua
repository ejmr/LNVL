--[[
    --
    -- This file implements characters in LNVL.  Characters represent
    -- actors in scenes and are typically the medium through which most
    -- dialog will be shown.
    --
--]]

-- Create the LNVL.Character class.
LNVL.Character = {}
LNVL.Character.__index = LNVL.Character

-- The constructor for characters.
function LNVL.Character:new(properties)
    local character = {}
    setmetatable(character, LNVL.Character)

    -- name: The name of the character as a string.  Right now we set
    -- it as an empty string because the loop later through
    -- 'properties' should give it a value.  If it does not then we
    -- will signal an error, because every character must have a name.
    character.name = ""

    -- color: The color that we use for lines this character speaks
    -- during a scene.  We expect this to be a table of three integers
    -- representing the red, green, and blue values of the colors,
    -- with values in the 0--255 range.
    character.color = {0, 0, 0}

    -- images: A hash of images for the character.  These are the
    -- sprites we display on screen when the character is speaking,
    -- for example.  All of the values in the table are Image objects,
    -- i.e. created by love.graphics.newImage().  The keys are strings
    -- which are pathnames to the image files.  However, the table
    -- also has one key named 'normal'; this key points to the
    -- default image for the character, the one we intend to use the
    -- most often.
    character.images = { normal = nil }

    -- currentImage: A key for the 'images' table above, i.e. a
    -- string, naming the image we currently use to draw the
    -- character.
    character.currentImage = "normal"

    -- position: This property has one of the LNVL.Position.*
    -- constants as its value.  It indicates where on the screen the
    -- character's images should appear by default.  Characters will
    -- appear on the left side of the screen unless a script overrides
    -- this value.
    character.position = LNVL.Position.Left

    -- Overwrite any default property values above with ones given to
    -- the constructor.
    for name,value in pairs(properties) do
        if rawget(character, name) ~= nil then
            rawset(character, name, value)
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
        character.images.normal = love.graphics.newImage(properties.image)
        character.images[properties.image] = character.images.normal
    end

    -- If the loop above set the 'color' property to a string then we
    -- assume it now has a value like '#33cfaf', i.e. a hex color
    -- string.  We need to convert that back into a table of RGB color
    -- values.
    if type(character.color) == "string" then
        character.color = LNVL.Color.fromHex(character.color)
    end

    -- Make sure the character has a name, because we do not support
    -- unnamed characters.
    if character.name == nil or character.name == "" then
        error("Cannot create unnamed character")
    end

    return character
end

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
function LNVL.Character:says(text)
    return LNVL.Opcode:new("say", {content=text, character=self})
end

-- This method accepts a table of strings and treats all of them as
-- lines of dialog spoken by the character.  This is a way that
-- scripts can provide monologues without having to repeat the
-- character object over and over.  The function returns a 'monologue'
-- opcode with the dialog and character attached.
function LNVL.Character:monologue(lines)
    return LNVL.Opcode:new("monologue", {content=lines, character=self})
end

-- If we call a Character object as a function then we treat that as a
-- short-cut for calling the says() method.  This can make dialog
-- scripts more readable.
LNVL.Character.__call = function (f, ...)
    if type(f) == "function" then
        return f(...)
    else
        return f:says(...)
    end
end

-- This method changes the position of a character, which primarily
-- affects where we draw his image.  The argument is a string which
-- must be a valid key for the LNVL.Position table.  The method has to
-- return an opcode but since we update the position immediately we
-- have nothing to process later, thus we return a 'no-op'.
function LNVL.Character:isAt(place)
    self.position = LNVL.Position[place]
    return LNVL.Opcode:new("no-op")
end

-- This method accepts a string as a path to an image file, and
-- changes the character's current image to that.  If the file is not
-- part of the 'character.images' table then we will store it there
-- for future reference; and if we have already loaded that image once
-- we just use that table without reloading the image file.
--
-- The method returns two opcodes telling the engine to set the new
-- image and then draw it to the screen.
function LNVL.Character:becomes(filename)
    if self.images[filename] == nil then
        self.images[filename] = love.graphics.newImage(filename)
    end

    local opcodes = {
        LNVL.Opcode:new("set-character-image", {character=self, image=filename}),
        LNVL.Opcode:new("draw-character", {character=self, position=LNVL.Position.Center}),
    }

    return opcodes
end

-- This method is a short-cut for character:becomes("normal"),
-- i.e. changing back to their default image.
function LNVL.Character:becomesNormal()
    return self:becomes("normal")
end

-- Return the class as a module.
return LNVL.Character
