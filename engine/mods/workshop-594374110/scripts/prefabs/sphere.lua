local assets=
{
	Asset("ANIM", "anim/sphere.zip"),

    Asset("ATLAS", "images/inventoryimages/sphere.xml"),
    Asset("IMAGE", "images/inventoryimages/sphere.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("sphere")
    inst.AnimState:SetBuild("sphere")
    inst.AnimState:PlayAnimation("idle")
    

  
    inst:AddComponent("inspectable")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(100)
   


    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sphere.xml"

	return inst
end

STRINGS.NAMES.SPHERE = "Soul Sphere"
STRINGS.RECIPE_DESC.SPHERE = "Sphere"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPHERE = "Horrible"

return Prefab( "common/inventory/sphere", fn, assets) 