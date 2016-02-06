require "stategraphs/SGmechatentacle"

local assets=
{
	Asset("ANIM", "anim/mechatentacle.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs =
{
    "monstermeat",
    "tentaclespike",
    "tentaclespots",
}

SetSharedLootTable( 'mechatentacle',
{
    {'metal',   1.0},
    {'metal',   0.5},
    {'gears', 0.5},
    {'trinket_6', 0.2},
})

local function retargetfn(inst)
    return FindEntity(inst, TUNING.TENTACLE_ATTACK_DIST, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return (guy.components.combat.target == inst or guy:HasTag("character") or guy:HasTag("monster") or guy:HasTag("animal")) and not guy:HasTag("prey") and not guy:HasTag("chess") and not (guy.prefab == inst.prefab)
        end
    end)
end


local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < TUNING.TENTACLE_STOPATTACK_DIST*TUNING.TENTACLE_STOPATTACK_DIST
    else
        return false
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.Physics:SetCylinder(0.25,2)
    
    inst.AnimState:SetBank("tentacle")
    inst.AnimState:SetBuild("mechatentacle")
    inst.AnimState:PlayAnimation("idle")
 	inst.entity:AddSoundEmitter()

    inst:AddTag("monster")    
    inst:AddTag("hostile")
    inst:AddTag("chess")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.TENTACLE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    
    MakeLargeFreezableCharacter(inst)
    
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('mechatentacle')
    
    inst:SetStateGraph("SGmechatentacle")

    return inst
end

STRINGS.NAMES.MECHATENTACLE = "King Hand"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MECHATENTACLE = {	
	"What is this?",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.MECHATENTACLE = {	
	"DEFENCE SYSTEM.",
	 
}

STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MECHATENTACLE = {	
	"Pathetic machine.",
	 
}

return Prefab( "marsh/monsters/mechatentacle", fn, assets, prefabs) 
