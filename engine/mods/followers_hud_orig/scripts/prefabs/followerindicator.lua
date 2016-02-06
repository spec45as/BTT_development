
local assets=
{
    Asset("ANIM", "anim/indicator_pointer.zip"),
}


local prefabs =
{
    "followerindicator",
}    


local function fn()

    local inst = CreateEntity()

    local trans = inst.entity:AddTransform()

    local anim = inst.entity:AddAnimState()
    
    anim:SetBank("indicator_pointer")

    anim:SetBuild("indicator_pointer")

    anim:PlayAnimation("indicator_pointer", true )

    inst:AddComponent("locomotor")

    inst.components.locomotor.runspeed = 7

    MakeCharacterPhysics(inst, -1, -1)
    MakeObstaclePhysics(inst, -1)

    inst:DoTaskInTime(3, function(inst) inst:Remove() end)
    
    return inst

end

return Prefab( "followerindicator", fn, assets, prefabs) 