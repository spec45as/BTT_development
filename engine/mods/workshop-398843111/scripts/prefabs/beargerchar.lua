local MakePlayerCharacter = require "prefabs/player_common"

local assets =
{
	Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("SOUND", "sound/bearger.fsb"),

}

local prefabs = {}

local start_inv =
{
	"spear",
	"hammer",
	"honey",
	"honey",
	"honey",
	"honey",
	"honey",
}


local function OnCollide(inst, other)
    if not other:HasTag("tree") then return end

    local v1 = Vector3(inst.Physics:GetVelocity())
    if v1:LengthSq() < 1 then return end

    inst:DoTaskInTime(2*FRAMES, function()
        if other and other.components.workable and other.components.workable.workleft > 0 then
            SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
            other.components.workable:Destroy(inst)
        end
    end)

end

local fn = function(inst)

	inst.AnimState:SetBank("bearger")
	inst.AnimState:SetBuild("bearger_build")
	inst:SetStateGraph("SGbearger_char")

	-----------------------------------------

	local trans = inst.entity:AddTransform()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(6, 3.5)

	MakeCharacterPhysics(inst, 1000, 1.5)
	inst.Physics:SetCollisionCallback(OnCollide)

	-----------------------------------------

	inst:AddTag("epic")
	inst:AddTag("monster")

	inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.BEARGER_MELEE_RANGE)
    inst.components.combat:SetAreaDamage(6, 0.8)
    inst.components.combat.hiteffectsymbol = "bearger_body"
    inst.components.combat:SetAttackPeriod(TUNING.BEARGER_ATTACK_PERIOD)

	inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 4
    inst.components.groundpounder.numRings = 5

	inst.components.health:SetMaxHealth(3000)
	inst.components.hunger:SetMax(200)
	inst.components.sanity:SetMax(200)
	inst.components.sanity.dapperness = TUNING.DAPPERNESS_HUGE

	inst.components.eater.monsterimmune = true

	inst.components.talker:IgnoreAll()

	inst.components.temperature.mintemp = 10
	inst.components.temperature.maxtemp = 20

	inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(6)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(180/255, 195/255, 150/255)

	-----------------------------------------

	inst.MiniMapEntity:SetIcon( "wilson.png" )

	TUNING.SPEAR_DAMAGE = 200
	TUNING.SPEAR_USES = 999999
	TUNING.HAMMER_DAMAGE = 200
	TUNING.HAMMER_USES = 999999

end

return MakePlayerCharacter("beargerchar", prefabs, assets, fn, start_inv)
