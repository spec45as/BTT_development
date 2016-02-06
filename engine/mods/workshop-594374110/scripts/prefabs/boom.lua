local assets =
{
	Asset("ANIM", "anim/boom.zip"),


    Asset("ATLAS", "images/inventoryimages/boom.xml"),
    Asset("IMAGE", "images/inventoryimages/boom.tex"),
}

local prefabs =
{
    "explode_small"
}

local function onhammered(inst, worker)
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.lootdropper:DropLoot()
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
    inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PushAnimation("idle")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end
local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)

    --local explode = PlayFX(pos,"explode", "explode", "small")
    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boom")
    inst.AnimState:SetBuild("boom")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
	MakeSmallBurnable(inst, 3+math.random()*3)
    MakeSmallPropagator(inst)

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
	
	local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(1)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.4)
    inst.Light:SetColour(109/260,234/260,109/260)
	MakeObstaclePhysics(inst, 0.3) --зона непроходимости
    

    return inst
end


STRINGS.NAMES.BOOM = "Explosive barrel"
STRINGS.RECIPE_DESC.BOOM = "BOOM!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOM = "Is it dangerous?"
return Prefab( "common/inventory/boom", fn, assets, prefabs) ,
  MakePlacer( "common/boom_placer", "boom", "boom", "idle")