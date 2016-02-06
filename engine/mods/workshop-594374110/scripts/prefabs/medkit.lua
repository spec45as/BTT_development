local assets=
{
	Asset("ANIM", "anim/medkit.zip"),

    Asset("ATLAS", "images/inventoryimages/medkit.xml"),
    Asset("IMAGE", "images/inventoryimages/medkit.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("medkit")
    inst.AnimState:SetBuild("medkit")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM 
  
    inst:AddComponent("inspectable")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(25)
  
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/medkit.xml"

	return inst
end

STRINGS.NAMES.MEDKIT = "Medkit"
STRINGS.RECIPE_DESC.MEDKIT = "Small medkit"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MEDKIT = "Very small"

return Prefab( "common/inventory/medkit", fn, assets) 