-- For use with Tup: <http://gittup.org/tup/>

local sources = {
    "LNVL.lua",
    "src/*.lua",
    "src/rgb.txt",
    "examples/*.lua",
    "main.lua",
}

tup.rule(
    {"LNVL.lua", "./src/*.lua"},
    "^ Running luacheck^ luacheck %f --std=luajit"
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
