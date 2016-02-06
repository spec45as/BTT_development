local Image = require "widgets/image"

local GeoUtil = require "actionqueue.geometryutil"


--------------------------------------------------------------------


local UPDATE_PERIOD = 0.005
local SELECTION_BOX_TINT = {1, 1, 1, 0.05} -- r, g, b, a
local UNSELECTABLE_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}


--------------------------------------------------------------------

local function CancelThread(thread)
	thread:SetList(nil)
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
	self.handlers = nil

	self.ondown = function()
		return self:OnDown()
	end

	self.onup = function()
		return self:OnUp()
	end

	self.thread = nil
end)


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
		self.parent:ClearSelectedEntities()
		local ents = TheSim:FindEntities(x, y, z, math.sqrt(radiussq), nil, UNSELECTABLE_TAGS)
		for _, target in ipairs(ents) do
			if target.Transform and target:IsValid() and not target:IsInLimbo() and isBounded(target:GetPosition()) then
				if target.components and target.components.follower then
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

function MouseManager:OnDown()
	if self.button == MOUSEBUTTON_LEFT then
		self:Clear()

		if not self.inst:IsValid() or self.parent:IsSelecting() then return end

		
		MouseManager_OnDown_SelectionBox(self)
	elseif self.button == MOUSEBUTTON_RIGHT then
		for inst in pairs(self.parent.selected_insts) do
			inst.components.locomotor:PushAction(BufferedAction(inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition(), nil, 0.2), true )

		end
	end
end

function MouseManager:OnUp()
	if self.button == MOUSEBUTTON_LEFT then
		
		self.parent:ClearSelectedEntities()

		if self.update_selection then
			self.update_selection()
		end
		--self.parent:ApplyToSelection()
		self:Clear()
	end
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
				self.managers[button] = mgr
			end
		end

		self:Enable()
	end)
end)

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
		
		--GetPlayer().components.leader:AddFollower(inst)
        --inst.components.follower:AddLoyaltyTime(9999)

		if not highlight.highlit then
			local override = inst.highlight_override
			if override then
				highlight:Highlight(override[1], override[2], override[3])
			else
				highlight:Highlight()
			end
		end

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
	if next(self.selected_insts) == nil then return end
	--self:DeselectEntity(ent)
end

function ActionQueuer:Interrupt()
	self:ClearSelectedEntities()
	for _, mgr in pairs(self.managers) do
		mgr:Clear()
	end
	self:ClearSelectionRectangle()
	if self.selection_thread then
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
