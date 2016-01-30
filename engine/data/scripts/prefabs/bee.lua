local beecommon = require "brains/beecommon"

--[[
Bees.lua

bee
Default bee type. Flies around to flowers and pollinates them, generally gets spawned out of beehives or player-made beeboxes

killerbee
Aggressive version of the bee. Doesn't pollinate anythihng, but attacks anything within range. If it has a home to go to and no target,
it should head back there. Killer bees come out to defend beehives when they, the hive or worker bees are attacked
]]--
local assets =
{
    Asset("ANIM", "anim/bee.zip"),
    Asset("ANIM", "anim/bee_build.zip"),
    Asset("ANIM", "anim/bee_angry_build.zip"),
    Asset("SOUND", "sound/bee.fsb"),
}

local prefabs =
{
    "stinger",
    "honey",
}

local workersounds =
{
    takeoff = "dontstarve/bee/bee_takeoff",
    attack = "dontstarve/bee/bee_attack",
    buzz = "dontstarve/bee/bee_fly_LP",
    hit = "dontstarve/bee/bee_hurt",
    death = "dontstarve/bee/bee_death",
}

local killersounds =
{
    takeoff = "dontstarve/bee/killerbee_takeoff",
    attack = "dontstarve/bee/killerbee_attack",
    buzz = "dontstarve/bee/killerbee_fly_LP",
    hit = "dontstarve/bee/killerbee_hurt",
    death = "dontstarve/bee/killerbee_death",
}

local function OnWorked(inst, worker)
    inst:PushEvent("detachchild")
    if worker.components.inventory ~= nil then
        if METRICS_ENABLED then
            FightStat_Caught(inst)
        end

        inst.SoundEmitter:KillAllSounds()

        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function OnDropped(inst)
    inst.sg:GoToState("catchbreath")
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.brain ~= nil then
        inst.brain:Start()
    end
    if inst.sg ~= nil then
        inst.sg:Start()
    end
    if inst.components.stackable ~= nil and inst.components.stackable:IsStack() then
        local x, y, z = inst.Transform:GetWorldPosition()
        while inst.components.stackable:IsStack() do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(x, y, z)
            end
        end
    end
end

local function OnPickedUp(inst)
    inst.sg:GoToState("idle")
    inst.SoundEmitter:KillSound("buzz")
    inst.SoundEmitter:KillAllSounds()
end

local function KillerRetarget(inst)
    return FindEntity(inst, SpringCombatMod(8),
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        { "_combat", "_health" },
        { "insect", "INLIMBO" },
        { "character", "animal", "monster" })
end

local function SpringBeeRetarget(inst)
    return TheWorld.state.isspring and
        FindEntity(inst, 4,
            function(guy)
                return inst.components.combat:CanTarget(guy)
            end,
            { "_combat", "_health" },
            { "insect", "INLIMBO" },
            { "character", "animal", "monster" })
        or nil
end

local function commonfn(build, tags)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLightWatcher()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1, .5)
    inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.FLYERS)

    inst.DynamicShadow:SetSize(.8, .5)
    inst.Transform:SetFourFaced()

    inst:AddTag("bee")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("cattoyairborne")
    inst:AddTag("flying")
    for i, v in ipairs(tags) do
        inst:AddTag(v)
    end

    inst.AnimState:SetBank("bee")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst:SetStateGraph("SGbee")

    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.nobounce = true
    -- inst.components.inventoryitem:SetOnDroppedFn(OnDropped) Done in MakeFeedableSmallLivestock
    -- inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true

    ---------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("honey", 1)
    inst.components.lootdropper:AddRandomLoot("stinger", 5)   
    inst.components.lootdropper.numrandomloot = 1

    ------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 1))
    MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 1))

    ------------------

    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetPlayerStunlock(PLAYERSTUNLOCK.RARELY)

    ------------------

    inst:AddComponent("sleeper")
    ------------------

    inst:AddComponent("knownlocations")

    ------------------

    inst:AddComponent("inspectable")

    ------------------

    inst:AddComponent("tradable")

    inst:ListenForEvent("attacked", beecommon.OnAttacked)
    inst:ListenForEvent("worked", beecommon.OnWorked)

    MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME*2, OnPickedUp, OnDropped)

    return inst
end

-- local brainfn = loadfile("scripts/brains/beebrain.lua")
-- assert(type(brainfn) == "function", brainfn)

local workerbrain = require("brains/beebrain")
local killerbrain = require("brains/killerbeebrain")

local function OnWake(inst)
    if not inst.components.inventoryitem:IsHeld() then
        inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
    end
end

local function OnSleep(inst)
    inst.SoundEmitter:KillSound("buzz")
end

local function workerbee()
    local inst = commonfn("bee_build", { "worker" })

    if not TheWorld.ismastersim then
        return inst
    end

    if TheWorld.state.isspring then
        inst.AnimState:SetBuild("bee_angry_build")
    end

    inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
    inst:AddComponent("pollinator")
    inst:SetBrain(workerbrain)
    inst.sounds = workersounds

    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep    

    MakeHauntableChangePrefab(inst, "killerbee")

    return inst
end

local function OnSpawnedFromHaunt(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable:Panic()
    end
end

local function killerbee()
    local inst = commonfn("bee_angry_build", { "killer", "scarytoprey" })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.health:SetMaxHealth(TUNING.BEE_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.BEE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BEE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, KillerRetarget)
    inst:SetBrain(killerbrain)
    inst.sounds = killersounds

    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep    

    MakeHauntablePanic(inst)
    inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)

    return inst
end 

return Prefab("bee", workerbee, assets, prefabs),
        Prefab("killerbee", killerbee, assets, prefabs)