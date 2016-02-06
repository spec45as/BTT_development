modimport("scripts/tile_adder.lua")

GLOBAL.require("constants")
local GROUND = GLOBAL.GROUND
GLOBAL.require("map/lockandkey")
GLOBAL.require("map/tasks")
local LOCKS = GLOBAL.LOCKS
local KEYS = GLOBAL.KEYS
local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")
local SIZE_VARIATION = 1
GLOBAL.require("map/terrain")
GLOBAL.require("map/level")
local LEVELTYPE = GLOBAL.LEVELTYPE

AddTile("BTT_DIRT", 50, "dirt", {noise_texture = "levels/textures/btt_dirt.tex",    runsound="dontstarve/movement/run_marble",		walksound="dontstarve/movement/walk_marble",	snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud"}, {noise_texture = "levels/textures/mini_btt_dirt.tex"})
AddTile("BTT_GRASSY_GRASS", 51, "dirt", {noise_texture = "levels/textures/btt_grassy_grass.tex",    runsound="dontstarve/movement/run_marble",		walksound="dontstarve/movement/walk_marble",	snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud"}, {noise_texture = "levels/textures/mini_btt_grassy_grass.tex"})

Layouts["no_mans_land"] = StaticLayout.Get("map/static_layouts/no_mans_land")

AddRoom("btt_grassy_grass", {
					colour={r=1,g=1,b=1,a=1},
					value = GLOBAL.GROUND.BTT_GRASSY_GRASS,
					tags = {"ForceConnected",   "MazeEntrance"},
					contents =  {
									distributepercent = .8,
					                distributeprefabs= 
					                {
                                        fireflies = 0.2,
					                    evergreen = 10,
					                    grass = .8,
					                    sapling=.8,
					                },
					            }
					})

AddRoom("btt_dirt", {
					colour={r=1,g=1,b=1,a=1},
					value =  GLOBAL.GROUND.BTT_DIRT,
					contents =  {
					                distributepercent = .25,
					                distributeprefabs=
					                {
					                    evergreen = 5,
					                    sapling=.3,
										skeleton = 1
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					})
		
AddTask("btt_map", {
		locks={},
		keys_given=KEYS.NONE,
		entrance_room = "btt_dirt",
		room_choices={
			["btt_dirt"] = 10 + math.random(1,5), 
			["btt_grassy_grass"] = 5 + math.random(1,5),  			
		}, 
		room_bg=GROUND.BTT_DIRT,
		background_room="btt_grassy_grass",
		colour={r=1,g=1,b=1,a=1},

	}) 
	
	AddLevel(LEVELTYPE.SURVIVAL, {
			id="BTT_WORLD",
			name="BTT_TEST",
			desc="BTT_TEST",
			overrides={
					{"loop",		"always"},
					{"branching",		"always"},
					{"branching",		"always"},
					{"world_size", 		"tiny"},
					{"islands", 		"never"},	
					{"roads", 			"always"},
					{"start_setpeice", 	"no_mans_land"},		
					{"start_node",		"btt_dirt"},
			},
			tasks = {
					--"Island Make a pick",
			},
			--[[
			numoptionaltasks = 4,
			optionaltasks = {
					"Island Befriend the pigs",
			},
			set_pieces = {
				["ResurrectionStone"] = { count=2, tasks={"Island Make a pick", "Island Dig that rock", "Island Great Plains", "Island Squeltch", "Island Beeeees!", "Island Speak to the king", "Island Forest hunters" } },
			},
			
			ordered_story_setpieces = {
				"TeleportatoRingLayout",
				"TeleportatoBoxLayout",
				"TeleportatoCrankLayout",
				"TeleportatoPotatoLayout",
				"AdventurePortalLayout",
				"TeleportatoBaseLayout",
			},
			
			required_prefabs = {
				"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone", "adventure_portal", "pigking"
			},
			]]
	})
	
GLOBAL.require("map/level")
local LEVELTYPE = GLOBAL.LEVELTYPE

local function AddTaskTech(level)
	level.tasks = {}
	table.insert(level.tasks, "btt_map")
end

AddLevelPreInit("BTT_WORLD", AddTaskTech)








