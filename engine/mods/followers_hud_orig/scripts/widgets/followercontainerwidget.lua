require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ImageTextButton = require "widgets/imagetextbutton"
local ItemTile = require "widgets/itemtile"

local DOUBLECLICKTIME = .33

local FollowerContainerWidget = Class(Widget, function(self, currentcontainer, owner)
    Widget._ctor(self, "Container")
    local scale = .6
    self:SetScale(scale,scale,scale)
    self.open = false
    self.inv = {}
    self.currentcontainer = currentcontainer
    self.owner = owner
    self:SetPosition(0, 0, 0)
    self.slotsperrow = 3
   
    self.bganim = self:AddChild(UIAnim())
	self.bgimage = self:AddChild(Image())
    self.isopen = false

    self.commandbuttonup = self:AddChild(ImageButton("images/up_arrow.xml","up_arrow.tex", "up_arrow.tex", "up_arrow.tex")) 
    self.commandbuttondown = self:AddChild(ImageButton("images/down_arrow.xml","down_arrow.tex", "down_arrow.tex", "down_arrow.tex")) 

    self.commandbuttonwhere = self:AddChild(ImageTextButton("images/command_where.xml","command_where.tex")) 
    self.commandbuttonpause = self:AddChild(ImageTextButton("images/command_pause.xml","command_pause.tex")) 
    self.commandbuttonplay = self:AddChild(ImageTextButton("images/command_play.xml","command_play.tex")) 
    self.commandbuttonremove = self:AddChild(ImageTextButton("images/command_remove.xml","command_remove.tex")) 

    self.commandbuttonwhere.commandtext:SetString("Follower Point")
    self.commandbuttonpause.commandtext:SetString("Pause Following")
    self.commandbuttonpause.commandtext:SetColour(1,.5, 0, 1)
    self.commandbuttonpause.commandtext:SetPosition(20, -375, 0)
    self.commandbuttonplay.commandtext:SetString("Resume Following")
    self.commandbuttonplay.commandtext:SetColour(0, 1, 0, 1)
    self.commandbuttonplay.commandtext:SetPosition(20, -375, 0)
    self.commandbuttonremove.commandtext:SetString("Remove Follower")
    self.commandbuttonremove.commandtext:SetColour(1, 0, 0, 1)
    self.commandbuttonremove.commandtext:SetPosition(20, -450, 0)

    self.commandbuttonremove:SetPosition(0, 103, 0)
    self.commandbuttonremove:Hide()
    self.commandbuttonpause:SetPosition(0, 28, 0)
    self.commandbuttonpause:Hide()
    self.commandbuttonplay:SetPosition(0, 28, 0)
    self.commandbuttonplay:Hide()
    self.commandbuttonwhere:SetPosition(0, -50, 0)
    self.commandbuttonwhere:Hide()

    self.commandbuttonup:SetPosition(70, -220, 0)
    self.commandbuttonup:SetScale(1.5,1.5,1)
    self.commandbuttonup:Hide()

    self.commandbuttondown:SetPosition(65, 10, 0)
    self.commandbuttondown:SetScale(1.5,1.5,1)

	self.commandbuttondown:SetOnClick(function()
        self:RemoveTempSlot()
        self:Open(currentcontainer, GetPlayer())
	    self.commandbuttonwhere:Show()
	    self.commandbuttonremove:Show()
	    self.commandbuttondown:Hide()
	    self.inst:DoTaskInTime(.3, function() self.commandbuttonup:Show() end)
    end)

    self.commandbuttonup:SetOnClick(function()
        self:Minimise()
        self.commandbuttonwhere:Hide()
        self.commandbuttonpause:Hide()
        self.commandbuttonplay:Hide()
        self.commandbuttonremove:Hide()
        self.commandbuttonup:Hide()
        self.inst:DoTaskInTime(.3, function() self.commandbuttondown:Show() end)
    end)


end)

function FollowerContainerWidget:Open(container, doer)

	container:AddTag("open")

	if container.components.container.widgetbgatlas and container.components.container.widgetbgimage then
		self.bgimage:SetTexture( container.components.container.widgetbgatlas, container.components.container.widgetbgimage )
	end
    
    if container.components.container.widgetanimbank then
		self.bganim:GetAnimState():SetBank(container.components.container.widgetanimbank)
	end
    
    if container.components.container.widgetanimbuild then
		self.bganim:GetAnimState():SetBuild(container.components.container.widgetanimbuild)
    end
    
    
    if container.components.container.widgetpos then
		self:SetPosition(container.components.container.widgetpos)
	end
	
	if container.components.container.widgetbuttoninfo and not TheInput:ControllerAttached() then
		self.button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
	    self.button:SetPosition(container.components.container.widgetbuttoninfo.position)
	    self.button:SetText(container.components.container.widgetbuttoninfo.text)
	    self.button:SetOnClick( function() container.components.container.widgetbuttoninfo.fn(container, doer) end )
	    self.button:SetFont(BUTTONFONT)
	    self.button:SetTextSize(35)
	    self.button.text:SetVAlign(ANCHOR_MIDDLE)
	    self.button.text:SetColour(0,0,0,1)
	    
		if container.components.container.widgetbuttoninfo.validfn then
			if container.components.container.widgetbuttoninfo.validfn(container, doer) then
				self.button:Enable()
			else
				self.button:Disable()
			end
		end
	end
	
	
    self.isopen = true
    self:Show()
    
	if self.bgimage.texture then
		self.bgimage:Show()
	else
		self.bganim:GetAnimState():PlayAnimation("open")
	end
	    
    self.onitemlosefn = function(inst, data) self:OnItemLose(data) end
    self.inst:ListenForEvent("itemlose", self.onitemlosefn, container)

    self.onitemgetfn = function(inst, data) self:OnItemGet(data) end
    self.inst:ListenForEvent("itemget", self.onitemgetfn, container)
	
	local num_slots = math.min( container.components.container:GetNumSlots(), #container.components.container.widgetslotpos)
	
	local n = 1
	for k,v in ipairs(container.components.container.widgetslotpos) do
	
		local slot = InvSlot(n,"images/hud.xml", "inv_slot.tex", self.owner, container.components.container)
		self.inv[n] = self:AddChild(slot)

		slot:SetPosition(v)

		if not container.components.container.side_widget then
			slot.side_align_tip = container.components.container.side_align_tip - v.x
		end
		
		local obj = container.components.container:GetItemInSlot(n)
		if obj then
			local tile = ItemTile(obj)
			slot:SetTile(tile)
		end
		
		n = n + 1
	end

    self.container = container
    
end    

function FollowerContainerWidget:OnItemGet(data)
    if data.slot and self.inv[data.slot] then
		local tile = ItemTile(data.item)
        self.inv[data.slot]:SetTile(tile)
        tile:Hide()

        if data.src_pos then
			local dest_pos = self.inv[data.slot]:GetWorldPosition()
			local inventoryitem = data.item.components.inventoryitem
			local im = Image(inventoryitem:GetAtlas(), inventoryitem:GetImage())
			im:MoveTo(data.src_pos, dest_pos, .3, function() tile:Show() im:Kill() end)
        else
			tile:Show() 
        end
	end
	
	if self.button and self.container and self.container.components.container.widgetbuttoninfo and self.container.components.container.widgetbuttoninfo.validfn then
		if self.container.components.container.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
end

function FollowerContainerWidget:OnUpdate(dt)

end

function FollowerContainerWidget:OnItemLose(data)
	local tileslot = self.inv[data.slot]
	if tileslot then
		tileslot:SetTile(nil)
	end
	
	if self.container and self.button and self.container.components.container.widgetbuttoninfo and self.container.components.container.widgetbuttoninfo.validfn then
		if self.container.components.container.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
	
end

function FollowerContainerWidget:RemoveTempSlot()

        for k,v in pairs(self.inv) do
            v:Kill()
        end

end    

function FollowerContainerWidget:Minimise(container)
    
    if self.isopen then        

		self.container:RemoveTag("open")

        for k,v in pairs(self.inv) do
            self:RemoveChild(v)
        end

        self.inst:DoTaskInTime(.3, function()

            local slot = InvSlot(1,"images/hud.xml", "inv_slot.tex", self.owner, self.container.components.container)
            self.inv[1] = self:AddChild(slot)
            slot:SetPosition(Vector3(0,100,0))

            if not self.container.components.container.side_widget then
                slot.side_align_tip = self.container.components.container.side_align_tip - v.x
            end
            
            local obj = self.container.components.container:GetItemInSlot(1)
            if obj then
                local tile = ItemTile(obj)
                slot:SetTile(tile)
            end

        end)

        self.bganim:GetAnimState():PlayAnimation("close")
        
        self.isopen = false
        
    end

end

return FollowerContainerWidget
