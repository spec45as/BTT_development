name = "Steam Biome"
description = "Explore new, dark area in ruins.\nIt is recommended to use with Steampunk mod and Tiny Alchemy Powers mod."
author = "Kuloslav and Hast"
version = "1.1"

forumthread = "http://steamcommunity.com/sharedfiles/filedetails/?id=226218366"

restart_required = false

api_version = 6

icon_atlas = "modicon.xml"
icon = "modicon.tex"

priority = 2

dont_starve_compatible = true
reign_of_giants_compatible = true

configuration_options =
{
	{
		name = "Alchemy Recipe",
		label = "Alchemy Engine Recipe",
		options =	{
						{description = "Original", data = "original"},
						{description = "Metal", data = "metal"},
					},

		default = "metal",
	
	},
	
	{
		name = "Fire Recipe",
		label = "Fire Supressor Recipe",
		options =	{
						{description = "Original", data = "original"},
						{description = "Metal", data = "metal"},
					},

		default = "metal",
	
	},
	
	{
		name = "Ice Recipe",
		label = "Icebox Recipe",
		options =	{
						{description = "Original", data = "original"},
						{description = "Metal", data = "metal"},
						{description = "Magic", data = "magic"},
						{description = "Both", data = "both"},
					},

		default = "metal",
	
	},

}
