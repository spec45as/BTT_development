require "brains/knightbrain"
--require "brains/batbrain"
require "stategraphs/SGmechabat"

local assets=
{
	Asset("ANIM", "anim/mechabat.zip"),
	Asset("SOUND", "sound/bat.fsb"),

}

local prefabs =
{
    "gears",
    "metal",
	"trinket_6",
}

SetSharedLootTable( 'mechabat',
{
    {'gears',    0.40},
    {'metal',      0.40},
    {'trinket_6',0.40},
})

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function Retarget(inst)

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > TUNING.KNIGHT_TARGET_DIST*TUNING.KNIGHT_TARGET_DIST) and not
    (inst.components.follower and inst.components.follower.leader) then
        return
    end
    
    local newtarget = FindEntity(inst, TUNING.KNIGHT_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster") )
                   and not (guy:HasTag("chess") and (guy.components.follower and not guy.components.follower.leader))
                   and not ((inst.components.follower and inst.components.follower.leader == GetPlayer()) and (guy.components.follower and guy.components.follower.leader == GetPlayer()))
                   and not (inst.components.follower and inst.components.follower.leader == guy)
                   and inst.components.combat:CanTarget(guy)
    end)
    return newtarget
end

local function KeepTarget(inst, target)
    if (inst.components.follower and inst.components.follower.leader) then
        return true
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    local targetPos = Vector3(target.Transform:GetWorldPosition() )
    return homePos and distsq(homePos, targetPos) < MAX_CHASEAWAY_DIST*MAX_CHASEAWAY_DIST
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker and attacker:HasTag("chess") then return end
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("chess") end, MAX_TARGET_SHARES)
end

local function OnWingDown(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bat/flap")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    local scaleFactor = 0.75
    inst.Transform:SetScale(scaleFactor, scaleFactor, scaleFactor)
    
    MakeGhostPhysics(inst, 1, .5)

    anim:SetBank("bat")
    anim:SetBuild("mechabat")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 6
    
    inst:SetStateGraph("SGmechabat")

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("chess")
   -- inst:AddTag("scarytoprey")
    inst:AddTag("knight")
    inst:AddTag("flying")
 
    local brain = require "brains/knightbrain"
    inst:SetBrain(brain)

    
    inst:AddComponent("sleeper")
	inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "bat_body"
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.BAT_ATTACK_DIST)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(150)
    inst.components.combat:SetDefaultDamage(30)
    inst.components.combat:SetAttackPeriod(TUNING.BAT_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('mechabat')

    inst:AddComponent("inventory")

   --[[ inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("guano")
    inst.components.periodicspawner:SetRandomTimes(120,240)
    inst.components.periodicspawner:SetDensityInRange(30, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()]]
    
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    
    inst:DoTaskInTime(1*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)
    
    inst:ListenForEvent("wingdown", OnWingDown)

	inst:AddComponent("follower")
	
    MakeMediumBurnableCharacter(inst, "bat_body")
    MakeMediumFreezableCharacter(inst, "bat_body")

   -- inst:AddComponent("teamattacker")
  --  inst.components.teamattacker.team_type = "bat"


    inst:ListenForEvent("attacked", OnAttacked)
    
    return inst
end

STRINGS.NAMES.MECHABAT = "Clockwork Pawn"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MECHABAT = {	
	"Insane machine.",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.MECHABAT = {	
	"FLYING AUTOMATON.",
	 
}

return Prefab("chessboard/mechabat", fn, assets, prefabs) 
