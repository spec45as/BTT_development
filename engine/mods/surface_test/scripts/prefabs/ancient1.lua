local assets=
{
	Asset("ANIM", "anim/ancient1.zip"),
	Asset("ATLAS", "images/inventoryimages/ancient1_map.xml"),
    Asset("IMAGE", "images/inventoryimages/ancient1_map.tex"),
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

SetSharedLootTable( 'ancientloot1',
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
	minimap:SetIcon( "ancient1_map.tex" )
    
    inst:AddTag("structure")
   MakeObstaclePhysics(inst, .5)
    
    inst.AnimState:SetBank("ancient1")
    inst.AnimState:SetBuild("ancient1")
	inst.AnimState:PlayAnimation("idle")
		
    inst:AddComponent("inspectable")
	
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('ancientloot1')
	
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit) 
	
	
    return inst
end


STRINGS.NAMES.ANCIENT1 = "Strange Device"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ANCIENT1 = {	
	"Specialized invention ... I think.",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.ANCIENT1 = {	
	"NO DATA.",
	 
}

return Prefab( "common/ancient1", fn, assets, prefabs)