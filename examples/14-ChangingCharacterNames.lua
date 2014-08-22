-- This example shows how the displayName() method affects the
-- character name that appears in dialog.

Eric = Character {
    dialogName = "Ren",
    firstName = "Eric",
    lastName = "Ritz",
    textColor = "#c8ffc8",
}

Jeff = Character {
    dialogName = "Wall",
    firstName = "Jeff",
    lastName = "Crenshaw",
    textColor = "#c8c8ff",
}

START = Scene {
    boxBackgroundColor = Color.DeepSkyBlue4,
    borderColor = Color.White,

    Eric "We're back to our old names.",
    Jeff "Why?",
    Eric:displayName "firstName",
    Eric "No reason.",
    Jeff:displayName "lastName",
    Jeff "Oh we can change them?  Neat!",
    Jeff "Wait...",
    Eric:displayName "fullName",
    Eric "Who uses only their last name?  Besides Brock Johnson.",
    Jeff:displayName "default",
    Jeff "Brock H. 'The H. Stands for Hercules' Johnson, that's who.  Get it right.",
}
