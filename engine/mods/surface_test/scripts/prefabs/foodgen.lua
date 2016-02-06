local assets=
{
	Asset("ANIM", "anim/foodgen.zip"),
	Asset("ATLAS", "images/inventoryimages/foodgen_map.xml"),
    Asset("IMAGE", "images/inventoryimages/foodgen_map.tex"),
	Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "bar",
	"trinket_6",
} 

SetSharedLootTable( 'foogentloot',
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
	inst.AnimState:PushAnimation("idle")
end 

local function getstatus(inst)
	
	if inst.components.pickable and not inst.components.pickable:CanBePicked() then
		STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOODGEN = {	
		"It's empty",

		}
		STRINGS.CHARACTERS.WX78.DESCRIBE.FOODGEN = {	
		"ERROR: UNIT OFFLINE",

		}
	else
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOODGEN = {	
		"That thing produces food!",
		}
	STRINGS.CHARACTERS.WX78.DESCRIBE.FOODGEN = {	
		"PROTEIN UNIT",

		}
	end
end  

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("idle") 
	inst.AnimState:PushAnimation("idle", true)
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation("idle", true)
	
end



local function onpickedfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	inst.AnimState:PushAnimation("empty", true)
	
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("empty", true)
	
end


	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
	    local sound = inst.entity:AddSoundEmitter()
		
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon( "foodgen_map.tex" )
	    
	    anim:SetBank("foodgen")
	    anim:SetBuild("foodgen")
	    anim:PlayAnimation("idle",true)
	    anim:SetTime(math.random()*2)

		inst:AddComponent("pickable")
		inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
		
		inst.components.pickable:SetUp("bar", TUNING.GRASS_REGROW_TIME)
		inst.components.pickable.onregenfn = onregenfn
		inst.components.pickable.onpickedfn = onpickedfn
		inst.components.pickable.makeemptyfn = makeemptyfn
		inst.components.pickable.makefullfn = makefullfn

	    --if stage == 1 then
			--inst.components.pickable:MakeBarren()
		--end
		
		inst:AddComponent("lootdropper")
		inst.components.lootdropper:SetChanceLootTable('foogentloot')
		
	    inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = getstatus	

		 inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(4)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit) 
	    
	    ---------------------        

	    --MakeMediumBurnable(inst)
	    --MakeSmallPropagator(inst)
		--MakeNoGrowInWinter(inst)    
	    ---------------------   
	    
	    return inst
	end   

STRINGS.NAMES.FOODGEN = "Food Generation Machine"

return Prefab( "common/foodgen", fn, assets, prefabs)