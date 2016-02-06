require("map/level")

AddLevel(LEVELTYPE.SURVIVAL, { 
		id="SURVIVAL_DEFAULT",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[1],
		desc=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[1],
		overrides={
				{"world_size", 		"tiny"},
				{"start_setpeice", 	"DefaultStart"},		
				{"start_node",		"Clearing"},
		},
		tasks = {
				"Make a pick",
				--"Dig that rock",
				--"Great Plains",
				--"Squeltch",
				--"Beeeees!",
				--"Speak to the king",
				--"Forest hunters",
		},
		numoptionaltasks = 0,--4,
		optionaltasks = {
				--"Befriend the pigs",
				--"For a nice walk",
				--"Kill the spiders",
				--"Killer bees!",
				--"Make a Beehat",
				--"The hunters",
				--"Magic meadow",
				--"Frogs and bugs",
		},
		set_pieces = {
		--	["ResurrectionStone"] = { count=2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" } },
		--	["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
		},
		ordered_story_setpieces = {
			--"TeleportatoRingLayout",
			--"TeleportatoBoxLayout",
			--"TeleportatoCrankLayout",
			--"TeleportatoPotatoLayout",
			--"AdventurePortalLayout",
			--"TeleportatoBaseLayout",
		},
		required_prefabs = {
		--	"teleportato_ring",  "teleportato_box",  "teleportato_crank", "teleportato_potato", "teleportato_base", "chester_eyebone", "adventure_portal", "pigking"
		},
	})