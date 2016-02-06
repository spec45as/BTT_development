local assets=
{
 Asset("ANIM", "anim/metalarmor.zip"),
 Asset("IMAGE", "images/inventoryimages/metalarmor.tex"),
 Asset("ATLAS", "images/inventoryimages/metalarmor.xml"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "metalarmor", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")  
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_marble")
    inst.AnimState:SetBuild("metalarmor")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/marblearmour"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/metalarmor.xml"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.WILSON_HEALTH * 10, 0.88)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

STRINGS.NAMES.METALARMOR = "Metal Armor"
STRINGS.RECIPE_DESC.METALARMOR = "Armor of metal plates"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.METALARMOR = {	
	"With this I am like a walking fortress!",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.METALARMOR = {	
	"UPGRADE FOR BASIC CASING",
	 
}
local metal = Ingredient("metal", 4)
metal.atlas = "images/inventoryimages/metal.xml"

local crafting_recipe = Recipe("metalarmor", {metal ,Ingredient("silk", 4),Ingredient("papyrus",2)}, RECIPETABS.WAR, {SCIENCE=1})
crafting_recipe.atlas = "images/inventoryimages/metalarmor.xml"

return Prefab( "common/inventory/metalarmor", fn, assets) 