local assets=
{ 
    Asset("ANIM", "anim/teslarod.zip"),
    Asset("ANIM", "anim/teslarod_swap.zip"), 

    Asset("ATLAS", "images/inventoryimages/teslarod.xml"),
    Asset("IMAGE", "images/inventoryimages/teslarod.tex"),
}

local prefabs = 
{
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

local function fn(colour)

    local function OnEquip(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_object", "teslarod_swap", "teslarod")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
    end

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("teslarod")
    anim:SetBuild("teslarod")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "teslarod"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/teslarod.xml"
	
	inst:AddComponent("inspectable")
    
	inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 15
	
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(120)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(bzz_attack)
    inst.components.weapon:SetProjectile("bishop_charge")
    
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished( onfinished )
	
	inst.components.finiteuses:SetMaxUses(1)
    inst.components.finiteuses:SetUses(1)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )

	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
    return inst
end

STRINGS.NAMES.TESLAROD = "Tesla Branch"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TESLAROD = {	
	"A piece of 'Tree'",
	"Vibrates with energy",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.TESLAROD = {	
	"PIECE OF ENERGY UNIT.",
	 
}

return  Prefab("common/inventory/teslarod", fn, assets, prefabs)