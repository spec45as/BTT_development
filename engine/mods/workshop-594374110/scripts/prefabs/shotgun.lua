local assets=
{
    Asset("ANIM", "anim/shotgun.zip"),
    Asset("ANIM", "anim/swap_shotgun.zip"),
 
    Asset("ATLAS", "images/inventoryimages/shotgun.xml"),
    Asset("IMAGE", "images/inventoryimages/shotgun.tex"),
}
local prefabs = 
{
    "staff_projectile",
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_shotgun", "swap_shotgun")
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
    
    anim:SetBank("shotgun")
    anim:SetBuild("shotgun")
    anim:PlayAnimation("idle")
    
    inst:AddTag("firestaff")
    inst:AddTag("rangediceweapon")


 local function canattack(inst, target)
   if GetPlayer().components.inventory:Has("shells", 1) then
       return true
    end
 end
 local function onattack(inst, owner, target)   
    owner.components.inventory:ConsumeByName("shells", 1)
    owner.SoundEmitter:PlaySound("doom_sound/item/shotgun_fire")
      
 end
 
    -------


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(50)
    inst.components.weapon:SetRange(7)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetCanAttack(canattack)
    inst.components.weapon:SetProjectile("staff_projectile")
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
  
	
    
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/shotgun.xml"
 


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
  
    return inst
end

STRINGS.NAMES.SHOTGUN = "Shotgun"
STRINGS.RECIPE_DESC.SHOTGUN = "Nice gun for hunt"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SHOTGUN = "Power in my hand!"

return  Prefab("common/inventory/shotgun", fn, assets, prefabs)