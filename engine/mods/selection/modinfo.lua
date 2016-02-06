name = "Action Queue"
id = "action.queue"
version = "1.1.3"
author = "simplex"
forumthread = ""


description = [[Allows queueing a sequence of actions (such as chopping, mining, etc.) by selecting targets within a bounding box, holding SHIFT.]]

local icon_stem = "modicon"



api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true


if icon_stem then
	icon = icon_stem .. ".tex"
	icon_atlas = icon_stem .. ".xml"
end


return icon_stem
