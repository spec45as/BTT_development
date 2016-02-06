_G = GLOBAL
assert = _G.assert
error = _G.error
require = _G.require

local Highlight = require "components/highlight"

--------------------------------------------------------------------

local SELECTION_BOX_MODIFIER = assert(_G.KEY_SHIFT)
local CHERRY_PICKING_MODIFIER = SELECTION_BOX_MODIFIER

--------------------------------------------------------------------

Assets = {
	Asset( "ATLAS", "images/selection_square.xml" ),
	Asset( "IMAGE", "images/selection_square.tex" ),
}

--------------------------------------------------------------------

AddSimPostInit(function(player)
	player:AddComponent("actionqueuer")
	player.components.actionqueuer:SetSelectionBoxModifier(SELECTION_BOX_MODIFIER)
	player.components.actionqueuer:SetCherryPickingModifier(CHERRY_PICKING_MODIFIER)

	local pc = player.components.playercontroller
	if pc then
		pc.OnControl = (function()
			local OnControl = pc.OnControl

			return function(self, ...)
				if not (SELECTION_BOX_MODIFIER and _G.TheInput:IsKeyDown(SELECTION_BOX_MODIFIER)) and not (CHERRY_PICKING_MODIFIER and _G.TheInput:IsKeyDown(CHERRY_PICKING_MODIFIER)) then
					return OnControl(self, ...)
				end
			end
		end)()

		pc.OnUpdate = (function()
			local OnUpdate = pc.OnUpdate

			return function(self, dt)
				local was_directwalking = self.directwalking
				local was_dragging = self.draggingonground
				OnUpdate(self, dt)
				if (not was_directwalking and self.directwalking) or (not was_dragging and self.draggingonground) then
					self.inst:PushEvent("playercontroller_move")
				end
			end
		end)()

		pc.DoAction = (function()
			local DoAction = pc.DoAction

			return function(self, bufaction, ...)
				if bufaction then
					self.inst:PushEvent("playercontroller_move")
				end
				return DoAction(self, bufaction, ...)
			end
		end)()
	end

	local loco = player.components.locomotor
	if loco then
		loco.PushAction = (function()
			local PushAction = loco.PushAction

			return function(self, bufaction, ...)
				self.inst:PushEvent("locomotor_pushaction", {action = bufaction})
				return PushAction(self, bufaction, ...)
			end
		end)()
	end
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
