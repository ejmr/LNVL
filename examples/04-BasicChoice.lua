-- This example shows how to present a menu with two choices.  Each
-- choice jumps the story to one of two possible scenes.  This example
-- also demonstrates jumping to other scenes in general.

Eric = Character{name = "Eric", textColor = "#c8ffc8"}
Jeff = Character{name = "Jeff", textColor = "#c8c8ff"}
Judge = Character{name = "The Great Judgini", textColor = "#ffc8c8"}

START = Scene{
    Jeff "Isn't this copyright infringement again?",
    Eric "Would you just shut up...",
    Judge "I have reviewed the evidence.  How do you plead?",

    -- Each choice has two parts: a line of text to present to the
    -- player, and the name of the scene to jump to if that is the
    -- selection he makes.
    Menu{
        {"Not Guilty", "NOT_GUILTY"},
        {"Obviously Guilty", "THE_TRUTH"}
    },
}

NOT_GUILTY = Scene{
    Eric "Not guilty, your Honor.",
    Judge "Denied!  It's opposite day!",
    Jeff "Wait, what the...",
    ChangeToScene "THE_TRUTH",
}

THE_TRUTH = Scene{
    Eric "Ok, so we infringed on copyrighted material...",
    Jeff "You did.",
    Judge "Then I hearby sentence you to hard labor in that prison from Rambo 2.",
    Jeff "What?!?",
    Eric "Oh cool, do we get a visit from Richard Crenna?",
    Judge "No.  He died in 2003, remember?",
    Eric "Oh yeah...",
    ChangeToScene "END",
}

END = Scene{
    Jeff "I hate you.  I hate you so much.",
    Eric "I love you too buddy.",
    Jeff "So much hate..."
}

-- That is how you make arbitrary jumps to other scenes and poor
-- references to other media.
