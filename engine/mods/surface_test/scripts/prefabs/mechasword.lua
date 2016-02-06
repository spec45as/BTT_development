local assets=
{
	Asset("ANIM", "anim/mechasword.zip"),
	Asset("ANIM", "anim/mechasword_swap.zip"),
	Asset("IMAGE", "images/inventoryimages/mechasword.tex"),
	Asset("ATLAS", "images/inventoryimages/mechasword.xml"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "mechasword_swap", "mechasword")
	--owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")   
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
    
    inst.AnimState:SetBank("mechasword")
    inst.AnimState:SetBuild("mechasword")
	    anim:PlayAnimation("idle")

    
    inst:AddTag("sharp")
    
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(68)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(120)
    inst.components.finiteuses:SetUses(120)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mechasword.xml"
   
   inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

STRINGS.NAMES.MECHASWORD = "Gear Sword"
STRINGS.RECIPE_DESC.MECHASWORD = "Sword enhanced with technology."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MECHASWORD = {	
	"Is this...Sword of a Thousand Truths?",
	"Sharp sword",
	 
}

STRINGS.CHARACTERS.GENERIC.DESCRIBE.MECHASWORD = {	

	"SHARP WEAPON.",
	 
}

return Prefab( "common/inventory/mechasword", fn, assets)