name = "Geometric Placement"
description = "Snaps objects to a grid when placing and displays a build grid around it (unless you hold ctrl). Credits to zkm2erjfdb and Levorto for writing the original single-player versions."
author = "rezecib"
version = "1.5.1"

forumthread = "http://forums.kleientertainment.com/files/file/1108-geometric-placement/"

api_version = 6
api_version_dst = 10

priority = -10

-- Compatible with the base game, RoG, SW, and DST
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

--These let clients know if they need to get the mod from the Steam Workshop to join the game
all_clients_require_mod = false

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = true

--This lets people search for servers with this mod by these tags
server_filter_tags = {}

local smallgridsizeoptions = {}
for i=1,10 do
	smallgridsizeoptions[i] = {description=""..(i*5).."", data=i*5}
end
local medgridsizeoptions = {}
for i=1,12 do
	medgridsizeoptions[i] = {description=""..(i*2).."", data=i*2}
end
local biggridsizeoptions = {}
for i=1,10 do
	biggridsizeoptions[i] = {description=""..(i).."", data=i}
end

configuration_options =
{
	{
		name = "CTRL",
		label = "CTRL Toggles On/Off",
		options =	{
						{description = "On", data = true},
						{description = "Off", data = false},
					},
		default = false,	
	},
	{
		name = "BUILDGRID",
		label = "Show Build Grid",
		options =	{
						{description = "On", data = true},
						{description = "Off", data = false},
					},
		default = true,	
	},
	{
		name = "HIDEPLACER",
		label = "Hide Placer",
		options =	{
						{description = "On", data = true},
						{description = "Off", data = false},
					},
		default = false,	
	},
	{
		name = "HIDECURSOR",
		label = "Hide Cursor Item",
		options =	{
						{description = "On", data = true},
						{description = "Off", data = false},
					},
		default = false,	
	},
	{
		name = "SMALLGRIDSIZE",
		label = "Small Grid Size",
		options = smallgridsizeoptions,
		default = 10,	
	},
	{
		name = "MEDGRIDSIZE",
		label = "Medium (walls) Grid Size",
		options = medgridsizeoptions,
		default = 6,	
	},
	{
		name = "BIGGRIDSIZE",
		label = "Large (turf) Grid Size",
		options = biggridsizeoptions,
		default = 2,	
	},
	{
		name = "COLORS",
		label = "Grid Colors",
		options =	{
						{description = "Red/Green", data = false},
						{description = "Red/Blue", data = "redblue"},
						{description = "Black/White", data = "blackwhite"},
					},
		default = false,	
	},
	{
		name = "REDUCECHESTSPACING",
		label = "Tighter Chests",
		options =	{
						{description = "Yes", data = true},
						{description = "No", data = false},
					},
		default = true,	
	},
}