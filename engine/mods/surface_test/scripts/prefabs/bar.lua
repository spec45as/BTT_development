local assets=
{
    Asset("ANIM", "anim/bar.zip"),						-- Animation Zip
    Asset("ATLAS", "images/inventoryimages/bar.xml"),	-- Atlas for inventory TEX
    Asset("IMAGE", "images/inventoryimages/bar.tex"),	-- TEX for inventory
}

local function fn(Sim)
	-- Create a new entity
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	
	-- Set animation info
	inst.AnimState:SetBuild("bar")
	inst.AnimState:SetBank("bar")
	inst.AnimState:PlayAnimation("idle")
	
	-- Make it edible
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue =  TUNING.HEALING_SMALL*2	-- Amount to heal
	inst.components.edible.hungervalue =  TUNING.CALORIES_SMALL	-- Amount to fill belly
	inst.components.edible.sanityvalue =  TUNING.SANITY_SMALL	-- Amount to help Sanity
	
	-- Make it perishable
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	-- Make it stackable
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	-- Make it inspectable
	inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	
	-- Make it an inventory item
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bar"	-- Use our TEX sprite
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bar.xml"	-- here's the atlas for our tex
	
	
	return inst
end

STRINGS.NAMES.BAR = "Protein Bar"

-- Randomizes the inspection line upon inspection.
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BAR = {	
	"This is edible?",
	"It looks ugly, but smells good...",
}

STRINGS.CHARACTERS.WX78.DESCRIBE.BAR = {	
	"PROTEIN SOURCE.",

}

-- Return our prefab
return Prefab( "common/inventory/bar", fn, assets)