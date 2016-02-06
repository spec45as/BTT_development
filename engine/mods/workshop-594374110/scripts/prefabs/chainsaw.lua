local assets=
{
    Asset("ANIM", "anim/chainsaw.zip"),
    Asset("ANIM", "anim/swap_chainsaw.zip"),
 
    Asset("ATLAS", "images/inventoryimages/chainsaw.xml"),
    Asset("IMAGE", "images/inventoryimages/chainsaw.tex"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_chainsaw", "swap_chainsaw")
	owner.SoundEmitter:PlaySound("doom_sound/item/chainsaw_pickup")  
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("chainsaw")
    anim:SetBuild("chainsaw")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")

    local function onattack(inst, owner, target)
    owner.SoundEmitter:PlaySound("doom_sound/item/chainsaw_fire")
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(64)
    inst.components.weapon:SetOnAttack(onattack)
    -------
        
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP)
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
    inst.components.finiteuses:SetOnFinished( onfinished )
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 0.5)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chainsaw.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end



STRINGS.NAMES.CHAINSAW = "Chainsaw"
STRINGS.RECIPE_DESC.CHAINSAW = "Someone wanna meat?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHAINSAW = "Someone wanna meat? No?"

return Prefab( "common/inventory/chainsaw", fn, assets) 
