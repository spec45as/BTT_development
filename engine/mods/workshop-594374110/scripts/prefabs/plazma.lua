local assets=
{
	Asset("ANIM", "anim/plazma.zip"),

    Asset("ATLAS", "images/inventoryimages/plazma.xml"),
    Asset("IMAGE", "images/inventoryimages/plazma.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("plazma")
    inst.AnimState:SetBuild("plazma")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM   
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/plazma.xml"

	return inst
end

STRINGS.NAMES.PLAZMA = "Plasma"
STRINGS.RECIPE_DESC.PLAZMA = "Plasma for weapon"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAZMA = "So...Power?"

return Prefab( "common/inventory/plazma", fn, assets) 