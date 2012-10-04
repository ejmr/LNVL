-- This example shows how to present a menu with two choices.  Each
-- choice jumps the story to one of two possible scenes.  This example
-- also demonstrates jumping to other scenes in general.

Eric = LNVL.Character{name = "Eric", color = "#c8ffc8"}
Jeff = LNVL.Character{name = "Jeff", color = "#c8c8ff"}
Judge = LNVL.Character{name = "The Great Judgini", color = "#ffc8c8"}

START = LNVL.Scene{
    Jeff:says "Isn't this copyright infringement again?",
    Eric:says "Would you just shut up...",
    Judge:says "I have reviewed the evidence.  How do you plead?",

    -- Each choice has two parts: a line of text to present to the
    -- player, and the name of the scene to jump to if that is the
    -- selection he makes.
    LNVL.Menu({"Not Guilty", "NOT_GUILTY"},
              {"Obviously Guilty", "THE_TRUTH"}),
}

NOT_GUILTY = LNVL.Scene{
    Eric:says "Not guilty, your Honor.",
    Judge:says "Denied!  It's opposite day!",
    Jeff:says "Wait, what the...",
    LNVL:jumpTo("THE_TRUTH"),
}

THE_TRUTH = LNVL.Scene{
    Eric:says "Ok, so we infringed on copyrighted material...",
    Jeff:says "You did.",
    Judge:says "Then I hearby sentence you to hard labor in that prison from Rambo 2.",
    Jeff:says "What?!?",
    Eric:says "Oh cool, do we get a visit from Richard Crenna?",
    Judge:says "No.  He died in 2003, remember?",
    Eric:says "Oh yeah...",
    LNVL:jumpTo("END"),
}

END = LNVL.Scene{
    Jeff:says "I hate you.  I hate you so much.",
    Eric:says "I love you too buddy.",
    Jeff:says "So much hate..."
}

-- That is how you make arbitrary jumps to other scenes and poor
-- references to other media.