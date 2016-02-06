local assets=
{
    Asset("ANIM", "anim/doublesgun.zip"),
    Asset("ANIM", "anim/swap_shotgun.zip"),
 
    Asset("ATLAS", "images/inventoryimages/doublesgun.xml"),
    Asset("IMAGE", "images/inventoryimages/doublesgun.tex"),
}
local prefabs = 
{
    "staff_projectile",
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_doublesgun", "swap_doublesgun")
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
    
    anim:SetBank("doublesgun")
    anim:SetBuild("doublesgun")
    anim:PlayAnimation("idle")
    
    inst:AddTag("firestaff")
    inst:AddTag("rangediceweapon")


 local function canattack(inst, target)
   if GetPlayer().components.inventory:Has("shells", 2) then
       return true
    end
 end
 local function onattack(inst, owner, target)   
    owner.components.inventory:ConsumeByName("shells", 2)
    owner.SoundEmitter:PlaySound("doom_sound/item/doublesgun_fire")
      
 end
 
    -------


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(70)
    inst.components.weapon:SetRange(5)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetCanAttack(canattack)
    inst.components.weapon:SetProjectile("staff_projectile")
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
  
	
    
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/doublesgun.xml"
 


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
  
    return inst
end

STRINGS.NAMES.DOUBLESGUN = "Super shotgun"
STRINGS.RECIPE_DESC.DOUBLESGUN = "Double power"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DOUBLESGUN = "Like in good old times..."

return  Prefab("common/inventory/doublesgun", fn, assets, prefabs)