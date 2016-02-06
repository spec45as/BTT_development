local assets=
{
    Asset("ANIM", "anim/plazmagun.zip"),
    Asset("ANIM", "anim/swap_plazmagun.zip"),
 
    Asset("ATLAS", "images/inventoryimages/plazmagun.xml"),
    Asset("IMAGE", "images/inventoryimages/plazmagun.tex"),
}
local prefabs = 
{
  "pl_staff_projectile",  
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_plazmagun", "swap_plazmagun")
     owner.SoundEmitter:PlaySound("doom_sound/item/pickup_weapon")
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
	inst.entity:AddSoundEmitter() 

    ---- 
    MakeInventoryPhysics(inst)
    
    anim:SetBank("plazmagun")
    anim:SetBuild("plazmagun")
    anim:PlayAnimation("idle")
    
    inst:AddTag("icestaff")
    inst:AddTag("rangediceweapon")


 local function canattack(inst, target)


    if GetPlayer().components.inventory:Has("plazma", 1) then
       return true
    end
 end

 local function onattack(inst, owner, target)   
    owner.components.inventory:ConsumeByName("plazma", 1)
    owner.SoundEmitter:PlaySound("doom_sound/item/plasma_fire")
  
 end
 
    -------


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(75)
    inst.components.weapon:SetRange(14)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetCanAttack(canattack)
    inst.components.weapon:SetProjectile("pl_staff_projectile")
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(300)
    inst.components.finiteuses:SetUses(300)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
  
	
    
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/plazmagun.xml"
 


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
  
    return inst
end

STRINGS.NAMES.PLAZMAGUN = "Plasma gun"
STRINGS.RECIPE_DESC.PLAZMAGUN = "More power!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PLAZMAGUN = "Wow, modern weapon!"

return  Prefab("common/inventory/plazmagun", fn, assets, prefabs)