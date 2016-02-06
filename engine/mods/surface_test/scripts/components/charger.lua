local Charger = Class(function(self, inst)
    self.inst = inst
	self.oncharge = false
	self.chargefuel = "RECHARGE"
end)

function Charger:consume(target, doer, amount)
	if self.inst.components.stackable then
		self.inst.components.stackable:Get():Remove()
	elseif self.inst.components.finiteuses then
		if target.components.finiteuses then
			amount = RoundUp(100*amount/target.components.finiteuses.total)
		elseif target.components.fueled then
			amount = RoundUp(100*amount/target.components.fueled.maxfuel)
		end
	end
	
	if self.oncharge then
		self.oncharge(self.inst, target, doer)
	else
		if doer.SoundEmitter then
			doer.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
			doer.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing")
		end
	end
	return true
end

function Charger:Docharge(target, doer)
	local amount = 0

	
   --[[ if target.components.fueled and self.chargefuel == target.chargefuel and target.components.fueled:GetPercent() < 1 then	
		amount = RoundUp(target.components.fueled.maxfuel/6)

		if amount + target.components.fueled.currentfuel > target.components.fueled.maxfuel then
			amount = RoundUp(target.components.fueled.maxfuel - target.components.fueled.currentfuel)
		end

		if not self:consume(target, doer, amount) then return false end
		target.components.fueled:DoDelta(amount)
		
		return true]]
	if target.components.finiteuses and self.chargefuel == target.chargefuel and target.components.finiteuses.current < target.components.finiteuses.total then
		amount = RoundUp(target.components.finiteuses.total/5)

		if amount + target.components.finiteuses.current > target.components.finiteuses.total then
			amount = RoundUp(target.components.finiteuses.total - target.components.finiteuses.current)
			if not self:consume(target, doer, amount) then return false end
			target.components.finiteuses:SetUses(target.components.finiteuses.total)	
		else		
			if not self:consume(target, doer, amount) then return false end
			target.components.finiteuses:SetUses(amount+target.components.finiteuses.current)
		end		
		
		return true
	end
end

function Charger:CollectUseActions(doer, target, actions, right)
    if self.chargefuel == target.chargefuel then
        table.insert(actions, ACTIONS.CHARGER)
    end
end


return Charger