_G = GLOBAL
assert = _G.assert
error = _G.error
require = _G.require

local Highlight = require "components/highlight"

--------------------------------------------------------------------

Assets = {
	Asset( "ATLAS", "images/selection_square.xml" ),
	Asset( "IMAGE", "images/selection_square.tex" ),
}

--------------------------------------------------------------------

AddSimPostInit(function(player)
	player:AddComponent("actionqueuer")
end)

Highlight.UnHighlight = (function()
	local UnHighlight = assert(Highlight.UnHighlight)

	local GetPlayer = _G.GetPlayer

	return function(self, ...)
		local p = GetPlayer()
		if p and p.components.actionqueuer and p.components.actionqueuer:IsSelectedEntity(self.inst) then
			return
		end

		return UnHighlight(self, ...)
	end
end)()
