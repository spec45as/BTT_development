local assets=
{
	Asset("ANIM", "anim/bigmedkit.zip"),

    Asset("ATLAS", "images/inventoryimages/bigmedkit.xml"),
    Asset("IMAGE", "images/inventoryimages/bigmedkit.tex"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("bigmedkit")
    inst.AnimState:SetBuild("bigmedkit")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM 
  
    inst:AddComponent("inspectable")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(60)
  
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bigmedkit.xml"

	return inst
end

STRINGS.NAMES.BIGMEDKIT = "Big medkit"
STRINGS.RECIPE_DESC.BIGMEDKIT = "Big medkit"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BIGMEDKIT = "Very big medkit"

return Prefab( "common/inventory/bigmedkit", fn, assets) 