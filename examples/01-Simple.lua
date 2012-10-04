-- This script defines a very basic narration with no characters.  The
-- text is from the song 「庭師King」 (Gardner King) by Susumu
-- Hirasawa.  I chose to use it (without permission not surprisingly)
-- because it's a great song and it would make a bad-ass opening to an
-- adventure or RPG in my opinion.  My English translation of the
-- chorus and verse parts used are in the comments next to the text.

START = LNVL.Scene:new{
    "休まずにKING 働くよKING",            -- Without resting, our King, Always working, our King
    "人の庭に全て足りるまで",              -- Until this garden for humans has all it needs
    "たんと吹け風よ ダントツに爽快に",      -- A great wind blows, refreshing all
    "パンパンにシャツを 帆のように張らせ",   -- Fill your shirt, like the bursting sail of a ship
    "たんと吹け風よ 人体の宇宙（ そら） に", -- A great wind blows, throughout this universe of humans
    "働け庭師 休まずＫ Ｉ Ｎ Ｇ",          -- Keep working, our Gardener, Without resting, our King
}

-- By default scenes take up a pre-define area on screen.  So for
-- blocks of total narration we probably want that to fill up the
-- entire screen.
START.fullscreen = true