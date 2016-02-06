local assets=
{
	Asset("ANIM", "anim/ds_rabbit_basic.zip"),
	Asset("ANIM", "anim/rabbit_build.zip"),
	Asset("SOUND", "sound/rabbit.fsb"),
}

local rabbitsounds = 
{
    scream = "dontstarve/rabbit/scream",
    hurt = "dontstarve/rabbit/scream_short",
}

local PIKBIT_SPEED_MULTIPLER = 2.0

local colours=
{
    {255/255,0/255,0/255},
    {0/255,255/255,0/255},
    {0/255,0/255,255/255},
    {0/255,255/255,255/255},
}

local function BecomeRabbit(inst)
	if not inst.israbbit or inst.iswinterrabbit then
		inst.AnimState:SetBuild("rabbit_build")
	    inst.israbbit = true
		inst.sounds = rabbitsounds
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    anim:SetBank("rabbit")
    anim:SetBuild("rabbit_build")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.RABBIT_RUN_SPEED * PIKBIT_SPEED_MULTIPLER
    inst:SetStateGraph("SGpikbit")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    
    inst.data = {}
        
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chest"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.RABBIT_HEALTH)
    inst.components.health.murdersound = "dontstarve/rabbit/scream_short"

    inst:AddComponent("pikable")

	BecomeRabbit(inst)
            
    local colour_index = math.random(#colours)
	inst.AnimState:SetMultColour(colours[colour_index][1],colours[colour_index][2],colours[colour_index][3],1)

    return inst
end

return Prefab( "forest/animals/pikbit", fn, assets, nil) 
