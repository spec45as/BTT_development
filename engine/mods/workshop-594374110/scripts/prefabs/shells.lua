local assets=
{
	Asset("ANIM", "anim/shells.zip"),

    Asset("ATLAS", "images/inventoryimages/shells.xml"),
    Asset("IMAGE", "images/inventoryimages/shells.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
   
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("shells")
    inst.AnimState:SetBuild("shells")
    inst.AnimState:PlayAnimation("idle")
    

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM   
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/shells.xml"

	return inst
end

STRINGS.NAMES.SHELLS = "Shells"
STRINGS.RECIPE_DESC.SHELLS = "Nice ammo for nice gun!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHELLS = "Power in my hand!"

return Prefab( "common/inventory/shells", fn, assets) 