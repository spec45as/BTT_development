local assets=
{
	Asset("ANIM", "anim/pawn.zip"),
	--Asset("ATLAS", "images/inventoryimages/ancient_map.xml"),
  --  Asset("IMAGE", "images/inventoryimages/ancient_map.tex"),
	Asset("SOUND", "sound/common.fsb"),

}

local prefabs = 

{
	"trinket_6",
	"metal",
	"gears",
	"thulecite", 
	"greengem",
	"yellowgem",
	"orangegem",
}

SetSharedLootTable( 'pawnloot',
{
    {'trinket_6',  0.5},
	{'metal',  0.4},
	{'gears',  0.2},
	{'thulecite',  0.1},
	{'greengem',  0.05},
	{'yellowgem',  0.05},
	{'orangegem',  0.05},
 
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
    
    inst.AnimState:SetBank("pawn")
    inst.AnimState:SetBuild("pawn")
	inst.AnimState:PlayAnimation("idle")
		
    inst:AddComponent("inspectable")
	
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('pawnloot')
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
	
	
    return inst
end


STRINGS.NAMES.PAWN = "Pawn Remains"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.PAWN = {	
	"Another machine",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.PAWN = {	
	"PROTOTYPE CODENAME: Q.U.E.E.N.",
	 
}

return Prefab( "common/pawn", fn, assets, prefabs)