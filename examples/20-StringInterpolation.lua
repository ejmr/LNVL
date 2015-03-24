--[[

This script tests string interpolation.  That is, the ability to embed
a variable in a string of dialog and have LNVL use the value assigned
to that variable.  This is useful for injecting data from outside LNVL
into a dialogue script.  The test uses four variables:

1. Person
2. Adjective
3. Response
4. ClosingRemark

The fourth variable comes from a Context outside of this script in
order to test the interpolation of variables from external contexts.

--]]

Person    = "Lobby Jones"
Adjective = "fine"
Response  = "Capital my good chum!"

START = Scene {
    "Hello <<Person>>!",
    "How are you on this <<Adjective>> day?",
    "<<Response>>",
    "<<ClosingRemark>>",
}
