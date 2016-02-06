--[[local rocksalt_assets =
{
	Asset("ANIM", "anim/rocksalt.zip"),
}
]]
local stonehand_assets =
{
	Asset("ANIM", "anim/stonehand.zip"),
}

local prefabs =
{
   -- "saltnugget",
   -- "rocks",
	"coppernugget",
}    


--[[SetSharedLootTable( 'rocksalt',
{
	{'rocks',     	 1.0},
    {'saltnugget',   1.0},
    {'saltnugget',   1.0},
    {'saltnugget',   1.0},
    {'saltnugget',   0.7},
    {'saltnugget',   0.5},
	{'rocks',     	 0.5},
})]]

SetSharedLootTable( 'stonehand',
{
	{'coppernugget',   1.0},
    {'coppernugget',   1.0},
    {'coppernugget',   1.0},
    {'coppernugget',   0.8},
    {'coppernugget',   0.4},
    {'coppernugget',   0.2},
})

local function baserock_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeObstaclePhysics(inst, 1.)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rock.png" )

	inst:AddComponent("lootdropper") 
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	
	inst.components.workable:SetOnWorkCallback(
		function(inst, worker, workleft)
			local pt = Point(inst.Transform:GetWorldPosition())
			if workleft <= 0 then
				inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
				inst.components.lootdropper:DropLoot(pt)
				inst:Remove()
			else
				
				
				if workleft < TUNING.ROCKS_MINE*(1/3) then
					inst.AnimState:PlayAnimation("low")
				elseif workleft < TUNING.ROCKS_MINE*(2/3) then
					inst.AnimState:PlayAnimation("med")
				else
					inst.AnimState:PlayAnimation("full")
				end
			end
		end)     

    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)    

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "ROCK"
	MakeSnowCovered(inst, .01)        
	return inst
end

--[[local function rocksalt_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("rocksalt")
	inst.AnimState:SetBuild("rocksalt")
	inst.AnimState:PlayAnimation("full")

	inst.components.lootdropper:SetChanceLootTable('rocksalt')

	return inst
end]]

local function stonehand_fn(Sim)
	local inst = baserock_fn(Sim)
	inst.AnimState:SetBank("stonehand")
	inst.AnimState:SetBuild("stonehand")
	inst.AnimState:PlayAnimation("full")

	inst.components.lootdropper:SetChanceLootTable('stonehand')

	return inst
end

--STRINGS.NAMES.ROCKSALT = "Boulder"
STRINGS.NAMES.STONEHAND = "Stone Hand"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.STONEHAND = {	
	"Very strange boulder...",
	 
}

STRINGS.CHARACTERS.WX78.DESCRIBE.STONEHAND = {	
	"BOULDER.",
	 
}

return --Prefab("forest/objects/rocks/rocksalt", rocksalt_fn, rocksalt_assets, prefabs),
Prefab("forest/objects/rocks/stonehand", stonehand_fn, stonehand_assets, prefabs)

