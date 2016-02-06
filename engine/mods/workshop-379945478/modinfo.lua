name = "Friend or Foe"
description = "Provides a visual aide for followers and foes"
api_version = 6
author = "nossr50"
version = "1.2"
forumthread = "0"

dont_starve_compatible = true
reign_of_giants_compatible = true

icon_atlas = "mod_icon.xml"
icon = "mod_icon.tex"

configuration_options =
{

	{
		name = "Friendly_Color",
		label = "Friendly Color",
		options =	{
						{description = "Green (Default)", data = "green"},
						{description = "Blue", data = "blue"},
					},

		default = "green",
	
	},
	
	{
		name = "Enemy_Color",
		label = "Enemy Color",
		options =	{
						{description = "Red (Default)", data = "red"},
						{description = "Yellow", data = "yellow"},
					},

		default = "red",
	
	},
	
	{
		name = "FX_Strength",
		label = "FX Strength",
		options =	{
						{description = "Dim", data = "dim"},
						{description = "Moderate (Default)", data = "moderate"},
						{description = "Bright", data = "bright"},
						{description = "Very Bright", data = "extreme"},
					},

		default = "moderate",
	
	},
}