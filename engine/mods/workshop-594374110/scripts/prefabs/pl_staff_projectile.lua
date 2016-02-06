local assets=
{
	Asset("ANIM", "anim/staff_projectile.zip"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("projectile")
    anim:SetBuild("staff_projectile")
    
    inst:AddTag("projectile")
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end


local function brp()
    local inst = common()
    inst.AnimState:PlayAnimation("ice_spin_loop", true)
    local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(3)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(40/260,100/260,240/260)
    return inst
end



return Prefab( "common/inventory/pl_staff_projectile", brp, assets)
	  
      
