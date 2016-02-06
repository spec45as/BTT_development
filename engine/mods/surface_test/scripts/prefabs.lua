PrefabFiles = {
	"bar",
	"foodgen",
	"tesla",
	"ancient1",
	"pawn",
	"pawnb",
	"coppernugget",
	"metal",
	"teslarod",
	"metalarmor",
	"schest",
	"greenfieldfx",
	"mechatentacle",
	"stonehand",
	"mechabat",
	"forcefieldn",
	"mechasword",
	"mechagun",
	"mechamine",
	"mechalance",
}

-- Map Icon -------------------------------------------------
local assets=
{

	Asset("ATLAS", "images/inventoryimages/foodgen_map.xml"),
    Asset("IMAGE", "images/inventoryimages/foodgen_map.tex"),
	Asset("ATLAS", "images/inventoryimages/tesla_map.xml"),
    Asset("IMAGE", "images/inventoryimages/tesla_map.tex"),
	Asset("ATLAS", "images/inventoryimages/ancient1_map.xml"),
    Asset("IMAGE", "images/inventoryimages/ancient1_map.tex"),
	Asset("ATLAS", "images/inventoryimages/ancient2_map.xml"),
    Asset("IMAGE", "images/inventoryimages/ancient2_map.tex"),
	Asset("ATLAS", "images/inventoryimages/ancient3_map.xml"),
    Asset("IMAGE", "images/inventoryimages/ancient3_map.tex"),
	Asset("ATLAS", "images/inventoryimages/ancient4_map.xml"),
    Asset("IMAGE", "images/inventoryimages/ancient4_map.tex"),
	Asset("ATLAS", "images/inventoryimages/mechamine.xml"),
    Asset("IMAGE", "images/inventoryimages/mechamine.tex"),
	
---------------------------------------------------------------
-- Tile textures --------------------------------------------------
	Asset( "IMAGE", "levels/textures/btt_dirt.tex" ),
	Asset( "IMAGE", "levels/textures/mini_btt_dirt.tex" ),
	Asset( "IMAGE", "levels/tiles/tech.tex" ),
	Asset( "FILE", "levels/tiles/tech.xml" ),
	
	Asset( "IMAGE", "levels/textures/btt_grassy_grass.tex" ),
	Asset( "IMAGE", "levels/textures/mini_btt_grassy_grass.tex" ),
	Asset( "IMAGE", "levels/tiles/whitefloor.tex" ),
	Asset( "FILE", "levels/tiles/whitefloor.xml" ),

----------------------------------------------------------------
}

--GLOBAL.STRINGS.NAMES.TURF_TEST = "Test Turf"


AddMinimapAtlas("images/inventoryimages/foodgen_map.xml")
AddMinimapAtlas("images/inventoryimages/tesla_map.xml")
AddMinimapAtlas("images/inventoryimages/ancient1_map.xml")
AddMinimapAtlas("images/inventoryimages/ancient2_map.xml")
AddMinimapAtlas("images/inventoryimages/ancient3_map.xml")
AddMinimapAtlas("images/inventoryimages/ancient4_map.xml")
AddMinimapAtlas("images/inventoryimages/mechamine.xml")
