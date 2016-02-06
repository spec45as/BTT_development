local assets=
{
	Asset("ANIM", "anim/candles.zip"),

    Asset("ATLAS", "images/inventoryimages/candles.xml"),
    Asset("IMAGE", "images/inventoryimages/candles.tex"),
}


local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end



local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end




local function fn(Sim)

       local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter() 
    
        MakeObstaclePhysics(inst, .3)
    
    inst.AnimState:SetBank("candles")
    inst.AnimState:SetBuild("candles")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)

local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(3)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(255/260,250/260,80/260)


	return inst
end


STRINGS.NAMES.CANDLES = "Candles"
STRINGS.RECIPE_DESC.CANDLES = "Standard candles"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDLES = "Wow, light!"



return Prefab( "common/inventory/candles", fn, assets),
 MakePlacer("common/candles_placer", "candles", "candles", "idle") 