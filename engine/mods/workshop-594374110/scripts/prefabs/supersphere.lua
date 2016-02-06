local assets=
{
	Asset("ANIM", "anim/supersphere.zip"),

    Asset("ATLAS", "images/inventoryimages/supersphere.xml"),
    Asset("IMAGE", "images/inventoryimages/supersphere.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("supersphere")
    inst.AnimState:SetBuild("supersphere")
    inst.AnimState:PlayAnimation("idle")
    

  
    inst:AddComponent("inspectable")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(500)
  
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/supersphere.xml"

	return inst
end

STRINGS.NAMES.SUPERSPHERE = "Megasphere"
STRINGS.RECIPE_DESC.SUPERSPHERE = "Megasphere"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SUPERSPHERE = "More horrible"

return Prefab( "common/inventory/supersphere", fn, assets) 