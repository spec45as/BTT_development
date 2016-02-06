local assets=
{
	Asset("ANIM", "anim/pawnb.zip"),
	--Asset("ATLAS", "images/inventoryimages/ancient_map.xml"),
  --  Asset("IMAGE", "images/inventoryimages/ancient_map.tex"),
	Asset("SOUND", "sound/common.fsb"),

}

local prefabs = 

{
	"trinket_6",
}

SetSharedLootTable( 'pawnbloot',
{
    {'trinket_6',  1.0},
 
})

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("idle")
	--inst.AnimState:PushAnimation("idle")
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("chessjunk.png")
	
    
    inst:AddTag("structure")
    MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("pawnb")
    inst.AnimState:SetBuild("pawnb")
	inst.AnimState:PlayAnimation("idle")
		
    inst:AddComponent("inspectable")
	
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('pawnbloot')
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
	
	
    return inst
end


STRINGS.NAMES.PAWNB = "Pawn Remains"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PAWNB = {	
	"Another machine",
	 
}

return Prefab( "common/pawnb", fn, assets, prefabs)