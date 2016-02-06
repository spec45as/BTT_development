local DAMAGE_DIST = 2
local DAMAGE_AMOUNT = -15
local DAMAGE_INTERVAL = 0.5

local Pikable = Class(function(self, inst)
	self.inst = inst
	self.inst:StartUpdatingComponent(self)
	self.damage_timer = DAMAGE_INTERVAL
	self.test_group = false
end)


function Pikable:DoDamage()	
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, DAMAGE_DIST)		
	--local clicked = TheInput:GetWorldEntityUnderMouse()
	for k, v in pairs(ents) do
		if v ~= GetPlayer() and v.entity:IsValid() and v.entity:IsVisible() then
			if not v.components.pikable then
				if v.components.health then
					if v:IsNear( self.inst, DAMAGE_DIST ) then
						v.components.health:DoDelta( DAMAGE_AMOUNT, nil, "pikable")
					end
				end
				if v.components.workable then
					v.components.workable:WorkedBy( self.inst, 1 )
				end
			end
		end
	end
end

function Pikable:OnUpdate(dt)
	local move_pikable = TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) and self.test_group == false
	local move_pikable = move_pikable or ( TheInput:IsMouseDown(MOUSEBUTTON_MIDDLE) and self.test_group == true )
	if move_pikable then
		self.inst.components.locomotor:PushAction(BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition(), nil, 0.2), true )
	end

	self.damage_timer = self.damage_timer - dt
	if self.damage_timer < 0 then
		self:DoDamage()
		self.damage_timer = DAMAGE_INTERVAL
	end

end

function Pikable:OnLoad(data)
	self.inst:StartUpdatingComponent(self)
end

return Pikable
