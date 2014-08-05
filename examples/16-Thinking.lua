--[[

    This example demonstrates how to express a character's thoughts.
    Character's can either "think" a single string, or a list of
    strings, similar to a monologue.

--]]

Lobby = Character { dialogName = "Lobby Jones the Lobster" }

START = Scene {
    Lobby:thinks "Hmm, another seafood resturant having a special on lobster...",
    Lobby:thinks {
        "Why so many gluttons for lobster?",
        "Especially for red lobsters.",
        "Red Lobsters..."
    }
}
