-- For use with Tup: <http://gittup.org/tup/>

local sources = {
    "LNVL.lua",
    "src/*.lua",
    "src/settings.lua.example",
    "src/rgb.txt",
    "examples/*.lua",
    "main.lua",
}

tup.rule(
    {"LNVL.lua", "./src/*.lua", "./src/settings.lua.example"},
    "^ Running luacheck on LNVL^ luacheck %f --std=luajit"
)

-- Our invocation of Luacheck on the example/test code uses many more
-- options because we have to make the scripts aware of the global
-- shortcut constructors that LNVL provides, among other things.
tup.rule(
    {"main.lua", "./examples"},
    [[^ Running luacheck on examples^ luacheck %f \
      --std=luajit --globals love \
      --read-globals Scene Character Color Set Get ChangeToScene Pause Menu ChangeSceneBackgroundTo \
      --allow-defined-top \
      --ignore="password" \
      --no-unused --no-unused-globals]]
)

tup.rule(
    sources,
    [[^ Creating TAGS^ ctags-exuberant -e --languages=lua %f \
          --regex-lua="/Processors\[\"([a-z-]+)\"\].+/Opcode.\1/" \
          --regex-lua="/Implementations\[\"([a-z-]+)\"\].+/Instruction.\1/"]],
    {"TAGS"}
)

tup.rule(
    {"src/settings.lua.example"},
    "^ Creating src/settings.lua^ cp %f %o",
    {"src/settings.lua"}
)

tup.rule(
    sources,
    "^ Creating LNVL.love^ zip --quiet --recurse-paths --compression-method store --update %o %f",
    {"LNVL.love"}
)
