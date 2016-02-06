local Image = require "widgets/image"

local GeoUtil = require "actionqueue.geometryutil"


--------------------------------------------------------------------


local UPDATE_PERIOD = 0.1
local SELECTION_BOX_TINT = {1, 1, 1, 0.15} -- r, g, b, a
local UNSELECTABLE_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}


--------------------------------------------------------------------


local function CancelThread(thread)
	thread:SetList(nil)
end

local ActionGetter
do
	local forbidden_target_components = {
		inspectable = true,
		combat = true,
	}

	local forbidden_item_components = {
		weapon = true,
	}

	local allowed_actions = {
		[ACTIONS.REPAIR] = true,
		[ACTIONS.CHOP] = true,
		[ACTIONS.PICK] = true,
		[ACTIONS.PICKUP] = true,
		[ACTIONS.MINE] = true,
		[ACTIONS.DIG] = true,
		[ACTIONS.GIVE] = true,
		[ACTIONS.DRY] = true,
		[ACTIONS.EXTINGUISH] = true,
		[ACTIONS.BAIT] = true,
		[ACTIONS.CHECKTRAP] = true,
		[ACTIONS.HARVEST] = true,
		[ACTIONS.SHAVE] = true,
		[ACTIONS.NET] = true,
		[ACTIONS.FERTILIZE] = true,
		[ACTIONS.HAMMER] = true,
		[ACTIONS.RESETMINE] = true,
		[ACTIONS.ACTIVATE] = true,
		[ACTIONS.TURNON] = true,
		[ACTIONS.TURNOFF] = true,
		[ACTIONS.USEITEM] = true,
		[ACTIONS.TAKEITEM] = true,
	}

	local special_cases = {}

	special_cases[ACTIONS.PICKUP] = function(target, right)
		if right then
			return false
		end
		if target.components.mine and not target.components.mine.inactive then
			return false
		end
		if target.components.trap and not target.components.trap.isset then
			return false
		end
		return true
	end

	local function filter_actions(actions, last_size, target, right)
		for i = #actions, last_size + 1, -1 do
			local is_valid = true
			local act = actions[i]
			if not allowed_actions[act] then
				is_valid = false
			else
				local test = special_cases[act]
				if test then
					is_valid = test(target, right, act)
				end
			end
			if not is_valid then
				table.remove(actions, i)
			end
		end
	end

	local function bufaction_less(a, b)
		return a.action.priority > b.action.priority
	end

	ActionGetter = function(inst, max, get_buffered)
		assert( type(max) == "number" and max > 0 )

		return function(target, right)
			local active_item, equipped_item
			if inst.components.inventory then
				local iv = inst.components.inventory
				active_item = iv:GetActiveItem()
				equipped_item = iv:GetEquippedItem(EQUIPSLOTS.HANDS)
			end

			local actions = {}
			local nactions = 0

			if active_item then
				for k, v in pairs(active_item.components) do
					if not forbidden_item_components[k] and v.CollectUseActions then
						v:CollectUseActions(inst, target, actions, right)

						filter_actions(actions, nactions, target, right)
						nactions = #actions

						if nactions >= max then
							break
						end
					end
				end

				if get_buffered then
					for i, v in ipairs(actions) do
						actions[i] = BufferedAction(inst, target, v, active_item)
					end
				end
			else
				local nequippedactions = 0 -- Only used/updated if get_buffered is given.

				if equipped_item then
					for k, v in pairs(equipped_item.components) do
						if not forbidden_item_components[k] and v.CollectUseActions then
							v:CollectUseActions(inst, target, actions, right)

							filter_actions(actions, nactions, target, right)
							nactions = #actions

							if nactions >= max then
								break
							end
						end
					end

					if get_buffered then
						for i, v in ipairs(actions) do
							actions[i] = BufferedAction(inst, target, v, equipped_item)
						end

						nequippedactions = nactions
					end
				end
				if nactions < max then
					for k, v in pairs(target.components) do
						if not forbidden_target_components[k] and v.CollectSceneActions then
							v:CollectSceneActions(inst, actions, right)

							filter_actions(actions, nactions, target, right)
							nactions = #actions

							if nactions >= max then
								break
							end
						end
					end

					if nactions < max then
						if target.inherentsceneaction and not right then
							table.insert(actions, target.inherentsceneaction)
							filter_actions(actions, nactions, target, right)
							nactions = #actions
						end
					end

					if nactions < max then
						if target.inherentscenealtaction and right then
							table.insert(actions, target.inherentscenealtaction)
							filter_actions(actions, nactions, target, right)
							nactions = #actions
						end
					end

					if get_buffered then
						for i = nequippedactions + 1, #actions do
							local v = actions[i]
							actions[i] = BufferedAction(inst, target, v)
						end
					end
				end
			end

			if get_buffered then
				table.sort(actions, bufaction_less)
			end

			return actions
		end
	end
end

--------------------------------------------------------------------

local AddMouseButtonHandler
local AddMouseMoveHandler
local InitializeHandlerAdders
do
	require "events"

	local mousedown = EventProcessor()
	local mouseup = EventProcessor()
	local mousemove = EventProcessor()

	AddMouseButtonHandler = function(button, down, fn)
		local proc = down and mousedown or mouseup

		proc:AddEventHandler(button, fn)
	end

	AddMouseMoveHandler = function(fn)
		mousemove:AddEventHandler("move", fn)
	end



	local initialized_handlers = false
	InitializeHandlerAdders = function()
		if initialized_handlers then return end

		local TheFrontEnd = rawget(_G, "TheFrontEnd")
		if not TheFrontEnd then return end

		TheFrontEnd.OnMouseButton = (function()
			local onbutt = TheFrontEnd.OnMouseButton

			return function(self, button, down, x, y)
				if not onbutt(self, button, down, x, y) then
					local proc = down and mousedown or mouseup
					proc:HandleEvent(button, x, y)
				else
					return true
				end
			end
		end)()

		TheFrontEnd.OnMouseMove = (function()
			local onmove = TheFrontEnd.OnMouseMove

			return function(self, x, y)
				mousemove:HandleEvent("move", x, y)
				return onmove(self, x, y)
			end
		end)()

		initialized_handlers = true
	end
end

--------------------------------------------------------------------


local MouseManager = Class(function(self, parent, button)
	self.parent = parent
	self.inst = parent.inst
	self.button = button

	self.selection_box_modifier = nil
	self.cherry_picking_modifier = nil

	self.handlers = nil

	self.ondown = function()
		return self:OnDown()
	end

	self.onup = function()
		return self:OnUp()
	end

	self.thread = nil
end)

function MouseManager:SetSelectionBoxModifier(key)
	self.selection_box_modifier = key
end

function MouseManager:SetCherryPickingModifier(key)
	self.cherry_picking_modifier = key
end

function MouseManager:IsSelecting()
	return self.thread ~= nil
end

function MouseManager:Clear()
	if self.thread then
		--KillThread(self.thread)
		CancelThread(self.thread)
		self.thread = nil
		self.parent:ClearSelectionRectangle()
	end
	if self.handlers and self.handlers.move then
		self.handlers.move:Remove()
		self.handlers.move = nil
	end
	self.update_selection = nil
end

local function MouseManager_OnDown_SelectionBox(self)
	local queued_movement = false
	local started_selection = false

	assert(self.handlers).move = AddMouseMoveHandler(function()
		queued_movement = true
	end)

	local pos0 = TheInput:GetScreenPosition()
	local x0, y0 = pos0.x, pos0.y

	local inst = self.inst
	local TheInput = _G.TheInput

	local is_right = (self.button == MOUSEBUTTON_RIGHT)
	local getAction = ActionGetter(inst, 1)

	local previous_ents = {}

	self.update_selection = function()
		local pos = TheInput:GetScreenPosition()

		if not started_selection then
			if GeoUtil.ManhattanDistance(pos, pos0) > 64 then
				started_selection = true
			else
				return
			end
		end

		local xmin, xmax = x0, pos.x
		if xmax < xmin then
			xmin, xmax = xmax, xmin
		end

		local ymin, ymax = y0, pos.y
		if ymax < ymin then
			ymin, ymax = ymax, ymin
		end

		self.parent:SetSelectionRectangle(xmin, ymin, xmax, ymax)

		local A, B, C, D = GeoUtil.MapScreenPt(xmin, ymin), GeoUtil.MapScreenPt(xmax, ymin), GeoUtil.MapScreenPt(xmax, ymax), GeoUtil.MapScreenPt(xmin, ymax)

		local isBounded = GeoUtil.NewQuadrilateralTester(A, B, C, D)

		local center = GeoUtil.MapScreenPt((xmin + xmax)/2, (ymin + ymax)/2)
		local x, y, z = center:Get()

		local radiussq = math.max(
			center:DistSq(A),
			center:DistSq(B),
			center:DistSq(C),
			center:DistSq(D)
		)

		local cur_ents = {}

		local ents = TheSim:FindEntities(x, y, z, math.sqrt(radiussq), nil, UNSELECTABLE_TAGS)
		for _, target in ipairs(ents) do
			if target.Transform and target:IsValid() and not target:IsInLimbo() and isBounded(target:GetPosition()) then
				local actions = getAction(target, is_right)
				if actions[1] then
					cur_ents[target] = true
					self.parent:SelectEntity(target, is_right)
				end
			end
		end

		for inst in pairs(previous_ents) do
			if not cur_ents[inst] then
				self.parent:DeselectEntity(inst)
			end
		end

		previous_ents = cur_ents
	end

	self.thread = self.inst:StartThread(function()
		while inst:IsValid() do
			if queued_movement then
				self.update_selection()
				queued_movement = false
			end
			Sleep(UPDATE_PERIOD)
		end
		self:Clear()
	end)
end

local function MouseManager_OnDown_CherryPick(self)
	local getAction = ActionGetter(self.inst, 1)
	local is_right = (self.button == MOUSEBUTTON_RIGHT)

	local ents = TheInput:GetAllEntitiesUnderMouse()

	for _, target in ipairs(ents) do
		if target.Transform and target:IsValid() and not target:IsInLimbo() then
			local actions = getAction(target, is_right)
			if actions[1] then
				self.parent:ToggleEntitySelection(target, is_right)
				return
			end
		end
	end

end

function MouseManager:OnDown()
	self:Clear()

	if not self.inst:IsValid() or self.parent:IsSelecting() then return end

	if not self.cherry_picking_modifier or TheInput:IsKeyDown(self.cherry_picking_modifier) then
		MouseManager_OnDown_CherryPick(self)
	end

	if not self.selection_box_modifier or TheInput:IsKeyDown(self.selection_box_modifier) then
		MouseManager_OnDown_SelectionBox(self)
	end
end

function MouseManager:OnUp()
	if self.update_selection then
		self.update_selection()
	end
	self.parent:ApplyToSelection()
	self:Clear()
end

function MouseManager:Attach()
	if self.handlers then return end
	self.handlers = {}

	self.handlers.down = AddMouseButtonHandler(self.button, true, self.ondown)
	self.handlers.up = AddMouseButtonHandler(self.button, false, self.onup)
	self.handlers.move = nil
end

function MouseManager:Dettach()
	self:Clear()

	if self.handlers then
		for _, handler in pairs(self.handlers) do
			handler:Remove()
		end
		self.handlers = nil
	end
end


--------------------------------------------------------------------


local function NewSelectionWidget(self)
	local widget = Image("images/selection_square.xml", "selection_square.tex")
	widget:SetTint(unpack(SELECTION_BOX_TINT))
	return widget
end

local ActionQueuer = Class(function(self, inst)
	self.inst = inst
	self.buttons = {MOUSEBUTTON_LEFT, MOUSEBUTTON_RIGHT}

	self.selection_box_modifier = nil
	self.cherry_picking_modifier = nil

	self.selection_widget = nil

	-- Maps inst to "right button?" (true or false)
	self.selected_insts = {}

	self.managers = {}
	self.event_listeners = nil

	self.enabled = false

	inst:DoTaskInTime(0, function(inst)
		if not (inst:IsValid() and inst.components.actionqueuer) then return end

		if inst.HUD and inst.HUD.controls then
			InitializeHandlerAdders()

			self.selection_widget = inst.HUD.controls:AddChild(NewSelectionWidget(self))
			self.selection_widget:Hide()
			
			for _, button in ipairs(self.buttons) do
				local mgr = MouseManager(self, button)
				mgr:SetSelectionBoxModifier(self.selection_box_modifier)
				mgr:SetCherryPickingModifier(self.cherry_picking_modifier)
				self.managers[button] = mgr
			end
		end

		self:Enable()
	end)
end)

function ActionQueuer:SetSelectionBoxModifier(key)
	self.selection_box_modifier = key
	for _, mgr in pairs(self.managers) do
		mgr:SetSelectionBoxModifier(key)
	end
end

function ActionQueuer:SetCherryPickingModifier(key)
	self.cherry_picking_modifier = key
	for _, mgr in pairs(self.managers) do
		mgr:SetCherryPickingModifier(key)
	end
end

function ActionQueuer:IsSelecting()
	for _, mgr in pairs(self.managers) do
		if mgr:IsSelecting() then
			return true
		end
	end
	return false
end

function ActionQueuer:IsSelectedEntity(inst)
	return self.selected_insts[inst] ~= nil
end

function ActionQueuer:SelectEntity(inst, right)
	if not inst:IsValid() or inst:IsInLimbo() then
		-- Just in case.
		self:DeselectEntity(inst)
		return
	end

	if self.selected_insts[inst] == nil then
		self.selected_insts[inst] = right or false

		local highlight = inst.components.highlight
		if not highlight then
			inst:AddComponent("highlight")
			highlight = inst.components.highlight
		end

		if not highlight.highlit then
			local override = inst.highlight_override
			if override then
				highlight:Highlight(override[1], override[2], override[3])
			else
				highlight:Highlight()
			end
		end

		--highlight:Flash(.2, .125, .1)
	end
end

function ActionQueuer:DeselectEntity(inst)
	if self.selected_insts[inst] ~= nil then
		self.selected_insts[inst] = nil
		if inst:IsValid() and inst.components.highlight then
			inst.components.highlight:UnHighlight()
		end
	end
end

function ActionQueuer:ToggleEntitySelection(inst, right)
	if self:IsSelectedEntity(inst) then
		self:DeselectEntity(inst)
	else
		self:SelectEntity(inst, right)
	end
end

function ActionQueuer:ClearSelectedEntities()
	for inst in pairs(self.selected_insts) do
		self:DeselectEntity(inst)
	end
end

function ActionQueuer:SetSelectionRectangle(x0, y0, x1, y1)
	local widget = self.selection_widget
	if widget then
		widget:SetPosition((x0 + x1)/2, (y0 + y1)/2)
		widget:SetSize(x1 - x0, y1 - y0)
		widget:Show()
	end
end

function ActionQueuer:ClearSelectionRectangle()
	local widget = self.selection_widget
	if widget then
		widget:Hide()	
	end
end

local function ActionQueuer_ClearEventListeners(self)
	if self.event_listeners then
		for _, data in ipairs(self.event_listeners) do
			self.inst:RemoveEventCallback(unpack(data))
		end
		self.event_listeners = nil
	end
end

function ActionQueuer:ApplyToSelection()
	--self:ClearSelectedEntities()
	
	if next(self.selected_insts) == nil then return end
	
	if self.selection_thread then
		--self:Interrupt()

		-- Simply selecting the entities is enough.
		return
	end

	if not self.inst:IsValid() then return end

	local getActions = ActionGetter(self.inst, math.huge, true)


	local selection_thread
	selection_thread = self.inst:StartThread(function()
		local inst = self.inst

		inst:ClearBufferedAction()

		local current_bufaction
		local interrupted = false

		local function interrupt_cb()
			interrupted = true
			self:Interrupt()
		end

		local function actionfailed_cb(inst, data)
			if data and data.action ~= nil and data.action == current_bufaction then
				interrupt_cb()
			end
		end

		local awoken = false
		local awakable = false
		local function actionsuccess_cb(inst, data)
			if data and data.action == current_bufaction then
				awoken = true
				if awakable then
					WakeTask(selection_thread)
				end
			end
		end

		local function locomotor_pushaction_cb(inst, data)
			if data and data.action ~= current_bufaction then
				interrupt_cb()
			end
		end

		self.event_listeners = self.event_listeners or {}
		do
			local old_listeners_sz = #self.event_listeners

			table.insert(self.event_listeners, {"actionfailed", actionfailed_cb})
			table.insert(self.event_listeners, {"actionsuccess", actionsuccess_cb})
			table.insert(self.event_listeners, {"locomotor_pushaction", locomotor_pushaction_cb})
			table.insert(self.event_listeners, {"playercontroller_move", interrupt_cb})

			for i = old_listeners_sz + 1, #self.event_listeners do
				local v = self.event_listeners[i]
				inst:ListenForEvent(unpack(v))
			end
		end

		local last_entity, last_action

		local function apply_action(target, bufaction)
			if bufaction == nil or not bufaction:TestForStart() then
				return false
			end

			if last_entity ~= nil and last_entity == target then
				if last_action ~= bufaction.action then
					return false
				end
			else
				last_entity = target
			end

			current_bufaction = bufaction
			last_action = bufaction.action

			if	bufaction.invobject and 
				bufaction.invobject.components.equippable and 
				bufaction.invobject.components.equippable.equipslot == EQUIPSLOTS.HANDS
			then
				if not bufaction.invobject.components.equippable.isequipped then 
					inst.components.inventory:Equip(bufaction.invobject)
				end
				
				if inst.components.inventory:GetActiveItem() == bufaction.invobject then
					inst.components.inventory:SetActiveItem(nil)
				end
			end

			if inst.components.locomotor then
				inst.components.locomotor:PushAction(bufaction, true)
			else
				inst:PushBufferedAction(bufaction)
			end

			return true
		end

		while inst:IsValid() and next(self.selected_insts) ~= nil do
			awoken = false
			awakable = true

			local target
			local mindistsq
			for ent in pairs(self.selected_insts) do
				if ent:IsValid() and not ent:IsInLimbo() then
					local distsq = inst:GetDistanceSqToInst(ent)
					if not mindistsq or distsq < mindistsq then
						mindistsq = distsq
						target = ent
					end
				else
					self:DeselectEntity(ent)
				end
			end

			if not target then break end

			local actions = getActions(target, self.selected_insts[target])

			if apply_action(target, actions[1]) then
				if interrupted then break end

				local delay
				if current_bufaction.action == ACTIONS.CHOP and inst.prefab == "woodie" then
					delay = (10 - 1)*FRAMES
				else
					delay = (14 - 1)*FRAMES
				end

				--Hibernate()
				if inst.sg and (inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("working")) then
					local delay
					if current_bufaction.action == ACTIONS.CHOP and inst.prefab == "woodie" then
						delay = (10 - 1)*FRAMES
					else
						delay = (14 - 1)*FRAMES
					end

					awakable = false
					Sleep(delay)
				else
					repeat
						Sleep(0.125)
					until awoken or (inst.sg and inst.sg:HasStateTag("idle"))
				end
			else
				self:DeselectEntity(target)
			end

			current_bufaction = nil
		end

		self.selection_thread = nil
		ActionQueuer_ClearEventListeners(self)
	end)
	self.selection_thread = selection_thread
end

function ActionQueuer:Interrupt()
	self:ClearSelectedEntities()
	for _, mgr in pairs(self.managers) do
		mgr:Clear()
	end
	self:ClearSelectionRectangle()
	if self.selection_thread then
		--KillThread(self.selection_thread)
		CancelThread(self.selection_thread)
		self.selection_thread = nil
	end
	ActionQueuer_ClearEventListeners(self)
end


--------------------------------------------------------------------


function ActionQueuer:Enable()
	if self.enabled then return end

	for _, mgr in pairs(self.managers) do
		mgr:Attach()
	end

	self.enabled = true
end

function ActionQueuer:Disable()
	self:Interrupt()

	if not self.enabled then return end

	for _, mgr in pairs(self.managers) do
		mgr:Dettach()
	end

	self.enabled = false
end

local function ActionQueuer_KillWidget(self)
	if self.selection_widget then
		self.selection_widget:Kill()
		self.selection_widget = nil
	end
end

function ActionQueuer:OnRemoveFromEntity()
	self:Disable()
	ActionQueuer_KillWidget(self)
end

function ActionQueuer:OnRemoveEntity()
	self:Disable()
	ActionQueuer_KillWidget(self)
end


--------------------------------------------------------------------


return ActionQueuer
