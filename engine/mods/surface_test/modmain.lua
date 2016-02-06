modimport("scripts/prefabs.lua")
modimport("scripts/activateforce.lua")
modimport("scripts/steambitems.lua")

--Changes "pick up" to "use" for "food machine".
AddSimPostInit(function(inst)
	local oldactionstringoverride = inst.ActionStringOverride
	function inst:ActionStringOverride(bufaction)
		if bufaction.action == GLOBAL.ACTIONS.PICK and bufaction.target and bufaction.target.prefab == "foodgen" then
			return "Use"
		end
		if oldactionstringoverride then
			return oldactionstringoverride(inst, bufaction)
		end
	end
end)
