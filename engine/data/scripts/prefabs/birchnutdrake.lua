local assets =
{
    Asset("ANIM", "anim/treedrake.zip"),
    Asset("ANIM", "anim/treedrake_build.zip"),
}

local prefabs =
{
    "acorn",
    "twigs",
}

local brain = require("brains/birchnutdrakebrain")

local function RetargetFn(inst)
    return not inst.sg:HasStateTag("hidden")
        and FindEntity(
                inst,
                inst.range or TUNING.DECID_MONSTER_TARGET_DIST * 1.5,
                function(guy)
                    return inst.components.combat:CanTarget(guy)
                end,
                { "_combat" }, --See entityreplica.lua (re: "_combat" tag)
                { "wall", "birchnutdrake", "INLIMBO" }
            )
        or nil
end

local function KeepTargetFn(inst, target)
    return not inst.sg:HasStateTag("exit")
        and (inst.sg:HasStateTag("hidden")
            or (target ~= nil and
                not target.components.health:IsDead() and
                inst.components.combat:CanTarget(target) and
                inst:IsNear(target, 20)
                )
            )
end

local function CanShareTarget(dude)
    return dude:HasTag("birchnutdrake") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 15, CanShareTarget, 10)
end

local function OnLostTarget(inst)
    if not inst.sg:HasStateTag("hidden") and inst:GetTimeAlive() > 5 then
        inst.sg:GoToState("exit")
    end
end

local function Exit(inst)
    if not inst.sg:HasStateTag("hidden") then
        inst.sg:GoToState("exit")
    end
end

local function Enter(inst)
    if not inst.sg:HasStateTag("hidden") then
        inst.sg:GoToState("enter")
    end
end

local function SleepTest()
    return false
end

local function OnDeath(inst, data, immediate)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        if immediate then
            inst.components.burnable:Extinguish()
        else
            inst:DoTaskInTime(.5, OnDeath, nil, true)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.25, .75)

    inst.Transform:SetFourFaced()
    MakeCharacterPhysics(inst, 1, .25)

    inst.AnimState:SetBank("treedrake")
    inst.AnimState:SetBuild("treedrake_build")
    inst.AnimState:PlayAnimation("enter")

    inst:AddTag("beaverchewable")
    inst:AddTag("birchnutdrake")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.numrandomloot = 1
    inst.components.lootdropper:AddRandomLoot("acorn", .4)
    inst.components.lootdropper:AddRandomLoot("twigs", .6)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3.5

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(5)
    inst.components.combat:SetRange(2.5, 3)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/decidous/drake_hit")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:DoTaskInTime(5, inst.ListenForEvent, "losttarget", OnLostTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(50)

    inst:AddComponent("sleeper")
    inst.components.sleeper.sleeptestfn = SleepTest

    inst:AddComponent("knownlocations")

    inst:SetStateGraph("SGbirchnutdrake")
    inst:SetBrain(brain)

    MakeSmallBurnableCharacter(inst, "treedrake_root", Vector3(0, -1, .1))
    inst.components.burnable:SetBurnTime(10)
    inst.components.health.fire_damage_scale = 2
    inst:ListenForEvent("death", OnDeath)
    inst.components.propagator.flashpoint = 5 + math.random() * 3
    MakeSmallFreezableCharacter(inst)

    inst.Exit = Exit
    inst.Enter = Enter

    -- Enter(inst)

    return inst
end

return Prefab("birchnutdrake", fn, assets, prefabs)