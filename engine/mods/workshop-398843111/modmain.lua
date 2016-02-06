
AddPrefabPostInit("honey", function(inst)
	inst.components.edible.healthvalue = 100
end)

PrefabFiles = {
	"beargerchar",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/beargerchar.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/beargerchar.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/beargerchar.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/beargerchar.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/beargerchar_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/beargerchar_silho.xml" ),

    Asset( "IMAGE", "bigportraits/beargerchar.tex" ),
    Asset( "ATLAS", "bigportraits/beargerchar.xml" ),

}

GLOBAL.STRINGS.CHARACTER_TITLES.beargerchar = "Bearger"
GLOBAL.STRINGS.CHARACTER_NAMES.beargerchar = "Bearger"
GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.beargerchar = "*Likes honey"
GLOBAL.STRINGS.CHARACTER_QUOTES.beargerchar = "\"The Big Bear\""

table.insert(GLOBAL.CHARACTER_GENDERS.MALE, "beargerchar")


AddModCharacter("beargerchar")

