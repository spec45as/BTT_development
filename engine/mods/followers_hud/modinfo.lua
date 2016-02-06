name = "Followers All in One" -- v1.3
description = "Adds a health badge for your followers\n\nBelow the health badge is the followers loyalty percentage\n\nNow with Follower Commands.\n\nHuge amount of options in the Configure Mod too."

author = "Bones"

api_version = 6
version = "1.26"
priority = 2.5

dont_starve_compatible = true
reign_of_giants_compatible = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

forumthread = "44520-follower-badges"

local function range(a, z, step, default, pre, defaultpre)

	local function append(t, i)
		t[#t + 1] = i
		return t
	end

	local opts = {}

	for i = a, z, step do
		if i == default then
			append(opts, {description = defaultpre..i.." (default)", data = i})
		else
			append(opts, {description = pre..i, data = i})
		end
	end

	if #opts > 0 then
		local fdata = opts[#opts].data
		if fdata < z and fdata + step - z < 1e-10 then
			append(opts, {description = z, data = z})
		end
	end

	return opts

end

configuration_options =
{
	
	{
		name = "OptionMaxFollowers",
		label = "Maximum Badges",
		options = range(1, 12, 1, 12, "", ""),		
		default = 12,
	},

	{
		name = "OptionCheckingForFollowers",
		label = "Check for Followers",
		options = range(.1, 2, .1, .5, "", ""),
		default = .5,
	},

	{
		name = "OptionCommands",
		label = "Follower Command",
		options =	{
						{description = "Off", data=false},
						{description = "On (default)", data=true},
					},
		default = true,
	},

	{
		name = "OptionHUDdown",
		label = "Badges Up(-) Down(+)",
		options = range(-300, 300, 10, 0, "", ""),
		default = 0,
	},

	{
		name = "OptionHUDhorizontal",
		label = "Badges Left(-) Right(+)",
		options = range(-900, 900, 10, 0, "", ""),
		default = 0,
	},

	{
		name = "OptionLoyaltyDisplay",
		label = "Loyalty Display",
		options =	{
						{description = "Text", data=false},
						{description = "Graphic (default)", data=true},
					},
		default = true,
	},

	{
		name = "OptionLoyaltyGraphicHover",
		label = "Loyalty Graphic Hover",
		options =	{
						{description = "Percent", data=false},
						{description = "Loyalty (default)", data=true},
					},
		default = true,
	},

	{
		name = "BadgeOrdering",
		label = "Order Badges By",
		options =	{
						{description = "Loyalty (default)", data=false},
						{description = "Health", data=true},
					},
		default = false,
	},

	{
		name = "HealthDisplayedAs",
		label = "On Badge Hover",
		options =	{
						{description = "Percent (default)", data=false},
						{description = "Amount", data=true},
					},
		default = false,
		default = 12,
	},

	{
		name = "OptionCommandsRemove",
		label = "Remove Command",
		options =	{
						{description = "Magic Hats", data="MagicHats"},
						{description = "Off", data="false"},
						{description = "On (default)", data="true"},
					},
		default = "true",
	},

	{
		name = "OptionLowHealth",
		label = "Low Health Alarm",
		options =	{
						{description = "Off", data=false},
						{description = "On (default)", data=true},
					},
		default = true,
	},

	{
		name = "ChesterIncluded",
		label = "Chester - Included",
		options =	{
						{description = "No (original)", data=false},
						{description = "Obviously!", data=true},
					},
		default = true,
	},

	{
		name = "ChesterFollow",
		label = "Chester - Follow Distance",
		options = range(1, 15, 1, 1, "", "Near "),		
		default = 1,
	},

	{
		name = "ChesterShhh",
		label = "Chester - Quieter",
		options =	{
						{description = "Normal (default)", data=false},
						{description = "Peace at last!", data=true},
					},
		default = false,
	},

	{
		name = "ChesterBFF",
		label = "Chester - BFF",
		options =	{
						{description = "Hated (default)", data=false},
						{description = "Loved", data=true},
					},
		default = false,
	},

	{
		name = "GlommerFix",
		label = "Glommer - Included",
		options =	{
						{description = "No", data=false},
						{description = "Yes (default)", data=true},
					},
		default = true,
	},

	{
		name = "GlommerShhh",
		label = "Glommer - Quieter",
		options =	{
						{description = "Normal (default)", data=false},
						{description = "Peace at last!", data=true},
					},
		default = false,
	},

	{
		name = "GlommerBFF",
		label = "Glommer - BFF",
		options =	{
						{description = "Hated (default)", data=false},
						{description = "Loved", data=true},
					},
		default = false,
	},

	{
		name = "AbigailCharged",
		label = "Abigail's Flower",
		options =	{
						{description = "Normal (default)", data=false},
						{description = "Charged", data=true},
					},
		default = false,
	},

	{
		name = "TallbirdEggHatch",
		label = "Tallbird's Egg",
		options =	{
						{description = "Normal (default)", data=false},
						{description = "Hatched", data=true},
					},
		default = false,
	},

	{
		name = "HornFollowers",
		label = "Beefalo's from Horn",
		options = range(1, 12, 1, 5, "", ""),		
		default = 5,
	},

	{
		name = "HornEffective",
		label = "Horn Power",
		options = range(1, 10, 1, 1, "x", "x"),		
		default = 1,
	},

	{
		name = "SpiderHatEffective",
		label = "Spider Hat Durability",
		options = range(1, 30, 1, 1, "x", "x"),		
		default = 1,
	},

	{
		name = "AbigailFollow",
		label = "Abigail Follow Distance",
		options = range(1, 15, 1, 1, "", "Near "),		
		default = 2,
	},

	{
		name = "ShadowFollow",
		label = "Shadow Follow Distance",
		options = range(1, 15, 1, 1, "", "Near "),		
		default = 3,
	},

	{
		name = "CatcoonFollow",
		label = "Catcoon Follow Distance",
		options = range(1, 15, 1, 1, "", "Near "),		
		default = 6,
	},

	{
		name = "MandrakeFollowers",
		label = "Mandrake - Max Badges",
		options = range(0, 12, 1, 12, "", ""),		
		default = 12,
	},

	{
		name = "MandrakeShhh",
		label = "Mandrakes - Quieter",
		options =	{
						{description = "Normal (default)", data=false},
						{description = "Peace at last!", data=true},
					},
		default = false,
	},

	{
		name = "NoWerepigs",
		label = "Werepigs - Followers?",
		options =	{
						{description = "Yes (default)", data=false},
						{description = "No", data=true},
					},
		default = false,
	},

}