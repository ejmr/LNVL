-- This example shows how to create characters that have images and
-- also change images during conversation, which can be used as a
-- dramatic effect.  Or annoy the player.  Whatever, it's your game.

Eric = LNVL.Character:new{
    name = "Eric",
    color = "#c8ffc8",
    image = "images/Eric-Normal.png",
}

Jeff = LNVL.Character:new{
    name = "Jeff",
    color = "#c8c8ff",
    image = "images/Jeff-Normal.png",
}

START = LNVL.Scene:new{
    Jeff:says "Hey guess what genius?  We're being sued.  Hard.",
    Eric:says "By who?",
    Jeff:says "Sushimiya Hirasawa.  Because you copied his lyrics.",
    Eric:says "Oh my God could you please at least get his name right.",
    Eric:says "Let me see that anyways...",
    Eric:becomes("images/Eric-Surprised.png"),
    Eric:says "Holy Hell, this is for one-hundred million yen in damages!",
    Eric:says "What is that?  Like, fifty dollars?!  We don't have that!",
    Jeff:becomes("images/Jeff-Facepalm.png"),
    Jeff:says "I wanted to make just one game before you got us sued into the ground.",
    Eric:becomesNormal(),
    Eric:says "Time for Plan-B.",
    Jeff:becomesNormal(),
    Jeff:says "Flee America?",
    Eric:says "Exactly.  Throw a dart at a map of South America and let's just go.",
}

-- Twice the scene calls the becomeNormal() method on the characters.
-- This is a shortcut for
--
--     Eric:becomes(Eric.image)
--
-- using whatever the original, 'normal' character image was.