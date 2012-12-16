-- This example script shows how to simplify a conversation where one
-- character speaks many lines in a row.  We can group those lines of
-- dialog into a 'monologue' so that we do not have to repeat the
-- character name over and over.

Eric = LNVL.Character:new{name="Eric", color="#3a3"}
Jeff = LNVL.Character:new{name="Jeff", color="#a33"}

START = LNVL.Scene:new{
    Eric:monologue{
        "Now that we're out of jail, no hard feelings.",
        "Right?",
        "...",
        "Ok you don't look so happy.  Let me put things into perspective.",
        "We got to visit that cool prison right?",
        "I mean they filmed part of Rambo 2 there, so that was like a Hollywood trip!",
        "See, you ever kept a large rock as a souvenir.",
        "Hey, wait..."
    },
    Jeff "They're not going to find your body."
}