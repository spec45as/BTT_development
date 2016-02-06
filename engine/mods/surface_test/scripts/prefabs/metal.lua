local assets=
{
	Asset("ANIM", "anim/metal.zip"),
	Asset("ATLAS", "images/inventoryimages/metal.xml"),	-- Atlas for inventory TEX
    Asset("IMAGE", "images/inventoryimages/metal.tex"),	-- TEX for inventory
}

local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("metal")
    inst.AnimState:SetBuild("metal")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 2
   
    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")
    		
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "metal"	-- Use our TEX sprite
    inst.components.inventoryitem.atlasname = "images/inventoryimages/metal.xml"	-- here's the atlas for our tex
	
    return inst
end

STRINGS.NAMES.METAL = "Metal Plates"
STRINGS.RECIPE_DESC.METAL = "Harder than rock."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.METAL = {	
	"Light and durable material",
	"The principles of this world are strange",
}

STRINGS.CHARACTERS.WX78.DESCRIBE.METAL = {	
	"DURABLE MATERIAL",

}

local coppernugget = Ingredient("coppernugget", 1)
coppernugget.atlas = "images/inventoryimages/coppernugget.xml"

local crafting_recipe = Recipe("metal", {coppernugget ,Ingredient("nitre", 1)}, RECIPETABS.REFINE, {SCIENCE=1})
crafting_recipe.atlas = "images/inventoryimages/metal.xml"

return Prefab( "common/inventory/metal", fn, assets) 