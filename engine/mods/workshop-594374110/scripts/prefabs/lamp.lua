local assets=
{
	Asset("ANIM", "anim/lamp.zip"),

    Asset("ATLAS", "images/inventoryimages/lamp.xml"),
    Asset("IMAGE", "images/inventoryimages/lamp.tex"),
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
    
    inst.AnimState:SetBank("lamp")
    inst.AnimState:SetBuild("lamp")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)

local light = inst.entity:AddLight()
    inst.Light:Enable(true)
	inst.Light:SetRadius(8)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.7)
    inst.Light:SetColour(40/260,100/260,240/260)


	return inst
end


STRINGS.NAMES.LAMP = "Lamp"
STRINGS.RECIPE_DESC.LAMP = "More light!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMP = "Wow, light!"



return Prefab( "common/inventory/lamp", fn, assets),
 MakePlacer("common/lamp_placer", "lamp", "lamp", "idle") 