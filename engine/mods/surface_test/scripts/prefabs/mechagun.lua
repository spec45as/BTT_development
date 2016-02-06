local assets=
{
	Asset("ANIM", "anim/mechagun.zip"),
	Asset("ANIM", "anim/mechagun_swap.zip"),
	Asset("IMAGE", "images/inventoryimages/mechagun.tex"),
	Asset("ATLAS", "images/inventoryimages/mechagun.xml"),
}

local function bzz_attack(inst, attacker, target)

if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
        if target.sg and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
    end

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")
		 
    end

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "mechagun_swap", "mechagun")
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
    
    inst.AnimState:SetBank("mechagun")
    inst.AnimState:SetBuild("mechagun")
	    anim:PlayAnimation("idle")

    
    inst:AddTag("sharp")
    
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(150)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(bzz_attack)
    inst.components.weapon:SetProjectile("bishop_charge")
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(15)
    inst.components.finiteuses:SetUses(15)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mechagun.xml"
   
   inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

STRINGS.NAMES.MECHAGUN = "Gear Gun"
STRINGS.RECIPE_DESC.MECHAGUN = "Power in your hands!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MECHAGUN = {	
	"I feel power of the force with this.", 
}
STRINGS.CHARACTERS.WX78.DESCRIBE.MECHAGUN = {	
	"WEAPON UPGRADE.", 
}

return Prefab( "common/inventory/mechagun", fn, assets)