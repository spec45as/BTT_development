require "prefabutil"

local function isgifting(inst)
    for k, v in pairs(inst.components.prototyper.doers) do
        if k.components.giftreceiver ~= nil and
            k.components.giftreceiver:HasGift() and
            k.components.giftreceiver.giftmachine == inst then
            return true
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation(isgifting(inst) and "proximity_gift_loop" or "proximity_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function doonact(inst, soundprefix)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding")
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:KillSound("idlesound")
        inst.SoundEmitter:KillSound("loop")
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function createmachine(level, name, soundprefix, techtree, giftsound)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local prefabs =
    {
        "collapse_small",
    }

    local function onturnon(inst)
        if inst._activetask == nil and not inst:HasTag("burnt") then
            if isgifting(inst) then
                if not inst.AnimState:IsCurrentAnimation("proximity_gift_loop") then
                    if inst.AnimState:IsCurrentAnimation("place") then
                        inst.AnimState:PushAnimation("proximity_gift_loop", true)
                    else
                        inst.AnimState:PlayAnimation("proximity_gift_loop", true)
                    end
                end
                if not inst.SoundEmitter:PlayingSound("loop") then
                    inst.SoundEmitter:KillSound("idlesound")
                    inst.SoundEmitter:PlaySound("dontstarve/common/research_machine_gift_active_LP", "loop")
                end
            else
                if not inst.AnimState:IsCurrentAnimation("proximity_loop") then
                    if inst.AnimState:IsCurrentAnimation("place") then
                        inst.AnimState:PushAnimation("proximity_loop", true)
                    else
                        inst.AnimState:PlayAnimation("proximity_loop", true)
                    end
                end
                if not inst.SoundEmitter:PlayingSound("idlesound") then
                    inst.SoundEmitter:KillSound("loop")
                    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_idle_LP", "idlesound")
                end
            end
        end
    end

    local function refreshonstate(inst)
        --V2C: if "burnt" tag, prototyper cmp should've been removed *see standardcomponents*
        if not inst:HasTag("burnt") and inst.components.prototyper.on then
            onturnon(inst)
        end
    end

    local function doneact(inst)
        inst._activetask = nil
        if not inst:HasTag("burnt") then
            if inst.components.prototyper.on then
                onturnon(inst)
            else
                onturnoff(inst)
            end
        end
    end

    local function onactivate(inst)
        if not inst:HasTag("burnt") then
            inst.AnimState:PlayAnimation("use")
            inst.AnimState:PushAnimation("idle", false)
            if not inst.SoundEmitter:PlayingSound("sound") then
                inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_run", "sound")
            end
            inst._activecount = inst._activecount + 1
            inst:DoTaskInTime(1.5, doonact, soundprefix)
            if inst._activetask ~= nil then
                inst._activetask:Cancel()
            end
            inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
        end
    end

    local function ongiftopened(inst)
        if not inst:HasTag("burnt") then
            inst.AnimState:PlayAnimation("gift")
            inst.AnimState:PushAnimation("idle", false)
            inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..giftsound.."_gift_recieve")
            if inst._activetask ~= nil then
                inst._activetask:Cancel()
            end
            inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
        end
    end

    local function onbuilt(inst)
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_place")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .4)

        inst.MiniMapEntity:SetPriority(5)
        inst.MiniMapEntity:SetIcon(name..".png")

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("prototyper")
        inst:AddTag("giftmachine")
        inst:AddTag("structure")
        inst:AddTag("level"..level)

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._activecount = 0
        inst._activetask = nil

        inst:AddComponent("inspectable")
        inst:AddComponent("prototyper")
        inst.components.prototyper.onturnon = onturnon
        inst.components.prototyper.onturnoff = onturnoff
        inst.components.prototyper.trees = techtree
        inst.components.prototyper.onactivate = onactivate

        inst:AddComponent("wardrobe")
        inst.components.wardrobe:SetCanUseAction(false) --also means NO wardrobe tag!
        inst.components.wardrobe:SetCanBeShared(true)
        inst.components.wardrobe:SetRange(TUNING.RESEARCH_MACHINE_DIST + .1)

        inst:ListenForEvent("onbuilt", onbuilt)

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)
        MakeSnowCovered(inst)

        MakeLargeBurnable(inst, nil, nil, true)
        MakeLargePropagator(inst)

        inst.OnSave = onsave 
        inst.OnLoad = onload

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("ms_addgiftreceiver", refreshonstate)
        inst:ListenForEvent("ms_removegiftreceiver", refreshonstate)
        inst:ListenForEvent("ms_giftopened", ongiftopened)

        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end

--Using old prefab names
return createmachine(1, "researchlab", "lvl1", TUNING.PROTOTYPER_TREES.SCIENCEMACHINE, "science"),
    createmachine(2, "researchlab2", "lvl2", TUNING.PROTOTYPER_TREES.ALCHEMYMACHINE, "alchemy"),
    MakePlacer("common/researchlab_placer", "researchlab", "researchlab", "idle" ),
    MakePlacer("common/researchlab2_placer", "researchlab2", "researchlab2", "idle")
