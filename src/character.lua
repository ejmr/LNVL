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

    -- Overwrite any default property values above with ones given to
    -- the constructor.
    for name,value in pairs(properties) do
        if rawget(character, name) ~= nil then
            rawset(character, name, value)
        end
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

-- Return the class as a module.
return LNVL.Character
