-- This example script shows a basic conversation between two
-- characters and shows the most simple way to create characters.  In
-- this example each Character has a 'dialogName' and a 'textColor'
-- that determines what his text looks like on screen.  Then we use
-- those objects inside of the Scene to actually create conversation.

Eric = Character {dialogName = "Eric", textColor = "#c8ffc8"}
Jeff = Character {dialogName = "Jeff", textColor = "#c8c8ff"}

START = Scene {
    boxBackgroundColor = Color.DeepSkyBlue4,
    borderColor = Color.White,
    Jeff "Why did you use a copyrighted song for an example?",
    Eric "Oh come on, who is going to sue us?",
    Jeff "Susumu Hirawhat's-his-name?  You know, the author?",
    Eric "That guy has no idea who we are.  Quit worrying.",
    Eric "Also he seems pretty cool.",
    Jeff "He 'seems cool'?  How comforting...",
    Eric "Make the example one of your socio-economical rants then!",
    Eric "I'm not going to argue about this!"
}

-- And that's how we handle that.
