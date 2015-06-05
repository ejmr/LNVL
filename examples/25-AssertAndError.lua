-- This example script tests calling assert() and error() from within
-- dialog scripts in order to generate debugging information.

Eric = Character {dialogName="Eric", textColor="#a33"}

assert(Eric == nil, "Character 'Eric' is nil.  (A complete lie.)")
assert(Eric, "This output should never appear.")

START = Scene {}

error("There is no START scene.  (Another lie.)")
