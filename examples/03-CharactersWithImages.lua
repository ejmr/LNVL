-- This example shows how to create characters that have images and
-- also change images during conversation, which can be used as a
-- dramatic effect.  Or annoy the player.  Whatever, it's your game.

Eric = Character {
    name = "Eric",
    textColor = "#c8ffc8",
    image = "examples/images/Eric-Normal.png",
    position = "Left",
}

Jeff = Character {
    name = "Jeff",
    textColor = "#c8c8ff",
    image = "examples/images/Jeff-Normal.png",
    position = "Right",
}

START = Scene {
    Jeff "Hey guess what genius?  We're being sued.  Hard.",
    Eric "By who?",
    Jeff "Sushimiya Hirasawa.  Because you copied his lyrics.",
    Eric "Oh my God could you please at least get his name right.",
    Eric "Let me see that anyways...",
    Eric:becomes("examples/images/Eric-Surprised.png"),
    Eric "Holy Hell, this is for one-hundred million yen in damages!",
    Eric "What is that?  Like, fifty dollars?!  We don't have that!",
    Jeff:becomes("examples/images/Jeff-Facepalm.png"),
    Jeff "I wanted to make just one game before you got us sued into the ground.",
    Eric:becomesNormal(),
    Eric "Time for Plan-B.",
    Jeff:becomesNormal(),
    Jeff "Flee America?",
    Eric "Exactly.  Throw a dart at a map of South America and let's just go.",
}

-- Twice the scene calls the becomeNormal() method on the characters.
-- This is a shortcut for
--
--     Eric:becomes(Eric.image)
--
-- using whatever the original, 'normal' character image was.
