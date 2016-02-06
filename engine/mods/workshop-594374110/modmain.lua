PrefabFiles = {
  "shotgun",
  "shells",
  "chainsaw",
  "staff_projectile",
  "medkit",
  "bigmedkit",
  "plazmagun",
  "plazma",
  "pl_staff_projectile",  
  "sphere",
  "supersphere",
  "candles",
  "lamp",
  "boom",
  "doublesgun"
}




local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH



Assets = {	
	Asset("ANIM", MODROOT.."anim/shotgun.zip"),
	Asset("ANIM", MODROOT.."anim/swap_shotgun.zip"),
	Asset("ANIM", MODROOT.."anim/doublesgun.zip"),
	Asset("ANIM", MODROOT.."anim/swap_doublesgun.zip"),
	Asset("ANIM", MODROOT.."anim/shells.zip"),
        Asset("ANIM", MODROOT.."anim/chainsaw.zip"),
        Asset("ANIM", MODROOT.."anim/swap_chainsaw.zip"),
        Asset("ANIM", MODROOT.."anim/staff_projectile.zip"),
        Asset("ANIM", MODROOT.."anim/bigmedkit.zip"),
        Asset("ANIM", MODROOT.."anim/medkit.zip"),
        Asset("ANIM", MODROOT.."anim/plazmagun.zip"),
	Asset("ANIM", MODROOT.."anim/swap_plazmagun.zip"),
        Asset("ANIM", MODROOT.."anim/plazma.zip"),
        Asset("ANIM", MODROOT.."anim/sphere.zip"),
        Asset("ANIM", MODROOT.."anim/supersphere.zip"),
        Asset("ANIM", MODROOT.."anim/candles.zip"),
        Asset("ANIM", MODROOT.."anim/lamp.zip"),
        Asset("ANIM", MODROOT.."anim/boom.zip"),

        Asset("IMAGE", MODROOT.."images/inventoryimages/shotgun.tex"),
	Asset("ATLAS", MODROOT.."images/inventoryimages/shotgun.xml"),
        Asset("IMAGE", MODROOT.."images/inventoryimages/doublesgun.tex"),
	Asset("ATLAS", MODROOT.."images/inventoryimages/doublesgun.xml"),
	Asset("IMAGE", MODROOT.."images/inventoryimages/shells.tex"),
	Asset("ATLAS", MODROOT.."images/inventoryimages/shells.xml"),
	Asset("IMAGE", MODROOT.."images/inventoryimages/chainsaw.tex"),
	Asset("ATLAS", MODROOT.."images/inventoryimages/chainsaw.xml"),
        Asset("IMAGE", MODROOT.."images/inventoryimages/medkit.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/medkit.xml"),
        Asset("IMAGE", MODROOT.."images/inventoryimages/bigmedkit.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/bigmedkit.xml"),
        Asset("IMAGE", MODROOT.."images/inventoryimages/plazmagun.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/plazmagun.xml"),          
        Asset("IMAGE", MODROOT.."images/inventoryimages/plazma.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/plazma.xml"),  
        Asset("IMAGE", MODROOT.."images/inventoryimages/sphere.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/sphere.xml"),  
        Asset("IMAGE", MODROOT.."images/inventoryimages/supersphere.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/supersphere.xml"), 
        Asset("IMAGE", MODROOT.."images/inventoryimages/candles.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/candles.xml"), 
        Asset("IMAGE", MODROOT.."images/inventoryimages/lamp.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/lamp.xml"), 
        Asset("IMAGE", MODROOT.."images/inventoryimages/boom.tex"),
        Asset("ATLAS", MODROOT.."images/inventoryimages/boom.xml"), 

        Asset("SOUNDPACKAGE", "sound/doom_sound.fev"),
    Asset("SOUND", "sound/doom_sound_bank00.fsb"),


}


RemapSoundEvent( "dontstarve/HUD/health_down", "doom_sound/player/health_down" )
RemapSoundEvent( "dontstarve/HUD/collect_resource", "doom_sound/item/pickup_item" )
RemapSoundEvent( "dontstarve/HUD/collect_newitem", "doom_sound/item/pickup_item" )
RemapSoundEvent( "dontstarve/HUD/health_up", "doom_sound/item/sphere_use" )
RemapSoundEvent( "dontstarve/HUD/click_move", "doom_sound/other/press_button" )
RemapSoundEvent( "dontstarve/HUD/craft_down", "doom_sound/other/select" )
RemapSoundEvent( "dontstarve/HUD/craft_up", "doom_sound/other/select" )


local shotgun = GLOBAL.Ingredient( "shotgun", 1)
  shotgun.atlas = "images/inventoryimages/shotgun.xml"
local doublesgun = GLOBAL.Ingredient( "doublesgun", 1)
  doublesgun.atlas = "images/inventoryimages/doublesgun.xml"
local shells = GLOBAL.Ingredient( "shells", 1)
  shells.atlas = "images/inventoryimages/shells.xml"
local chainsaw = GLOBAL.Ingredient( "chainsaw", 1)
  chainsaw.atlas = "images/inventoryimages/chainsaw.xml"
local medkit = GLOBAL.Ingredient( "medkit", 1)
  medkit.atlas = "images/inventoryimages/medkit.xml"
local bigmedkit = GLOBAL.Ingredient( "bigmedkit", 1)
  bigmedkit.atlas = "images/inventoryimages/bigmedkit.xml"
local plazmagun = GLOBAL.Ingredient( "plazmagun", 1)
  plazmagun.atlas = "images/inventoryimages/plazmagun.xml"
local plazma = GLOBAL.Ingredient( "plazma", 1)
  plazma.atlas = "images/inventoryimages/plazma.xml"
local sphere = GLOBAL.Ingredient( "sphere", 1)
  sphere.atlas = "images/inventoryimages/sphere.xml"
local supersphere = GLOBAL.Ingredient( "supersphere", 1)
  supersphere.atlas = "images/inventoryimages/supersphere.xml"
local candles = GLOBAL.Ingredient( "candles", 1)
  candles.atlas = "images/inventoryimages/candles.xml"
local lamp = GLOBAL.Ingredient( "lamp", 1)
  lamp.atlas = "images/inventoryimages/lamp.xml"
local boom = GLOBAL.Ingredient( "boom", 1)
  boom.atlas = "images/inventoryimages/boom.xml"

function modGamePostInit() 
	local shotgun = GLOBAL.Recipe("shotgun", { Ingredient("flint", 2), Ingredient("marble", 4), Ingredient("cane", 1)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_ONE)
        shotgun.atlas = "images/inventoryimages/shotgun.xml"

	local doublesgun = GLOBAL.Recipe("doublesgun", { Ingredient("flint", 3), Ingredient("gears", 3), Ingredient("cane", 2)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_TWO)
        doublesgun.atlas = "images/inventoryimages/doublesgun.xml"

	local shells = GLOBAL.Recipe("shells", { Ingredient("gunpowder", 2), Ingredient("rocks", 3), Ingredient("cutreeds", 4)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_ONE, nil, nil, nil, 4)
        shells.atlas = "images/inventoryimages/shells.xml"
        
        local chainsaw = GLOBAL.Recipe("chainsaw", { Ingredient("houndstooth", 5), Ingredient("rope", 2), Ingredient("goldnugget", 2)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_TWO)
        chainsaw.atlas = "images/inventoryimages/chainsaw.xml"

        local medkit = GLOBAL.Recipe("medkit", { Ingredient("spidergland", 1),  Ingredient("papyrus", 1)}, 
        RECIPETABS.SURVIVAL,  TECH.SCIENCE_ONE)
        medkit.atlas = "images/inventoryimages/medkit.xml"

        local bigmedkit = GLOBAL.Recipe("bigmedkit", { Ingredient("spidergland", 3), Ingredient("manrabbit_tail", 1),  Ingredient("papyrus", 2)}, 
        RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
        bigmedkit.atlas = "images/inventoryimages/bigmedkit.xml"
  
        local plazmagun = GLOBAL.Recipe("plazmagun", { Ingredient("boards", 2), Ingredient("nightmarefuel", 4), Ingredient("horn", 1)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_TWO)
        plazmagun.atlas = "images/inventoryimages/plazmagun.xml"
       
        
        local plazma = GLOBAL.Recipe( "plazma",  { Ingredient("cutstone", 1), Ingredient("purplegem", 1), Ingredient("lightbulb", 2)}, 
        RECIPETABS.WAR,  TECH.SCIENCE_TWO, nil, nil, nil, 10)
        plazma.atlas = "images/inventoryimages/plazma.xml"

        
        local sphere = GLOBAL.Recipe("sphere", { Ingredient("nightmarefuel", 6),  Ingredient("bluegem", 1)}, 
        RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
        sphere.atlas = "images/inventoryimages/sphere.xml"
 
        local supersphere = GLOBAL.Recipe("supersphere", { Ingredient("sphere", 1),  Ingredient("nightmare_timepiece", 1)}, 
        RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
        supersphere.atlas = "images/inventoryimages/supersphere.xml"
      
        local candles= GLOBAL.Recipe("candles", { Ingredient("goldnugget", 3), Ingredient("torch", 3), Ingredient("cutreeds", 2)}, 
        RECIPETABS.TOWN,  TECH.SCIENCE_TWO, "candles_placer")
        candles.atlas = "images/inventoryimages/candles.xml"

        local lamp= GLOBAL.Recipe("lamp", { Ingredient("lightbulb", 2), Ingredient("boards", 3), Ingredient("plazma", 2)}, 
        RECIPETABS.TOWN,  TECH.SCIENCE_TWO, "lamp_placer")
        lamp.atlas = "images/inventoryimages/lamp.xml"

        local boom = GLOBAL.Recipe("boom", { Ingredient("gunpowder", 3), Ingredient("rocks", 3)}, 
        RECIPETABS.TOWN,  TECH.SCIENCE_TWO, "boom_placer")
        boom.atlas = "images/inventoryimages/boom.xml"

	end
AddGamePostInit(modGamePostInit)


SpawnPrefab = GLOBAL.SpawnPrefab


AddSimPostInit(SimInit)