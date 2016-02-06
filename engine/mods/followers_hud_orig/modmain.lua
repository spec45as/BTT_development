local require = GLOBAL.require

PrefabFiles = {
    "followeritemslot",
    "followerindicator",
}

Assets = {

    Asset( "ANIM", "anim/abigail_meter.zip"),
    Asset( "ANIM", "anim/beefalo_meter.zip"),
    Asset( "ANIM", "anim/bishop_meter.zip"),
    Asset( "ANIM", "anim/bunny_meter.zip"),
    Asset( "ANIM", "anim/catcoon_meter.zip"),
    Asset( "ANIM", "anim/chester_meter.zip"),
    Asset( "ANIM", "anim/cspider_meter.zip"),
    Asset( "ANIM", "anim/dangler_meter.zip"),
    Asset( "ANIM", "anim/darkchester_meter.zip"),
    Asset( "ANIM", "anim/emerling_meter.zip"),
    Asset( "ANIM", "anim/glommer_meter.zip"),
    Asset( "ANIM", "anim/knight_meter.zip"),
    Asset( "ANIM", "anim/mandrake_meter.zip"),
    Asset( "ANIM", "anim/merm_meter.zip"),
    Asset( "ANIM", "anim/pig_meter.zip"),
    Asset( "ANIM", "anim/rocky_meter.zip"),
    Asset( "ANIM", "anim/rook_meter.zip"),
    Asset( "ANIM", "anim/shadow_meter.zip"),
    Asset( "ANIM", "anim/shavebeef_meter.zip"),
    Asset( "ANIM", "anim/snowchester_meter.zip"),
    Asset( "ANIM", "anim/spider_meter.zip"),
    Asset( "ANIM", "anim/spitter_meter.zip"),
    Asset( "ANIM", "anim/swarrior_meter.zip"),
    Asset( "ANIM", "anim/tallbird_meter.zip"),
    Asset( "ANIM", "anim/teenbeef_meter.zip"),
    Asset( "ANIM", "anim/follow_meter.zip"),
    Asset( "ANIM", "anim/loyal_bar.zip"),
    -- All animations will be added into one file once happy with them

    Asset("ATLAS", "images/status_bg.xml"),

    Asset("ATLAS", "images/command_where.xml"),
    Asset("IMAGE", "images/command_where.tex"),
    Asset("ATLAS", "images/command_pause.xml"),
    Asset("IMAGE", "images/command_pause.tex"),
    Asset("ATLAS", "images/command_play.xml"),
    Asset("IMAGE", "images/command_play.tex"),
    Asset("ATLAS", "images/command_remove.xml"),
    Asset("IMAGE", "images/command_remove.tex"),
    Asset("ATLAS", "images/command_magichat.xml"),
    Asset("IMAGE", "images/command_magichat.tex"),

    Asset("ATLAS", "images/down_arrow.xml"),
    Asset("IMAGE", "images/down_arrow.tex"),
    Asset("ATLAS", "images/up_arrow.xml"),
    Asset("IMAGE", "images/up_arrow.tex"),

}

TUNING.HORN_MAX_FOLLOWERS = GetModConfigData("HornFollowers")
TUNING.HORN_EFFECTIVE_TIME = (20 * GetModConfigData("HornEffective"))
TUNING.SPIDERHAT_PERISHTIME = (TUNING.SPIDERHAT_PERISHTIME * GetModConfigData("SpiderHatEffective"))

local FollowerIndicator = nil

local CurrentBadge = nil
local controls = nil
local CurrentCommand = nil

local NToolsHAdjust = 0
local NToolsVAdjust = 0
local AlwaysOnIsOn = false

local Follower1Id, Follower2Id, Follower3Id, Follower4Id, Follower5Id, Follower6Id, Follower7Id, Follower8Id, Follower9Id, Follower10Id, Follower11Id, Follower12Id = "", "", "", "", "", "", "", "", "", "", "", "" 
local Follower1Health, Follower2Health, Follower3Health, Follower4Health, Follower5Health, Follower6Health, Follower7Health, Follower8Health, Follower9Health, Follower10Health, Follower11Health, Follower12Health = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

local Follower1Slot, Follower2Slot, Follower3Slot, Follower4Slot, Follower5Slot, Follower6Slot, Follower7Slot, Follower8Slot, Follower9Slot, Follower10Slot, Follower11Slot, Follower12Slot = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil 
local FollowerContainer1, FollowerContainer2, FollowerContainer3, FollowerContainer4, FollowerContainer5, FollowerContainer6, FollowerContainer7, FollowerContainer8, FollowerContainer9, FollowerContainer10, FollowerContainer11, FollowerContainer12 = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil 

local MaxFollowing = GetModConfigData("OptionMaxFollowers")
local FollowerPing = GetModConfigData("OptionCheckingForFollowers")
local BadgeOrderedLoyalty = GetModConfigData("BadgeOrdering")
local HealthAsGraphic = GetModConfigData("HealthDisplayedAs")
local LoyaltyDisplayGraphic = GetModConfigData("OptionLoyaltyDisplay")
local MandrakeMax = GetModConfigData("MandrakeFollowers")
local CommandsAreOn = GetModConfigData("OptionCommands")
local CommandsToRemoveOn = GetModConfigData("OptionCommandsRemove")
local ChesterToBeIncluded = GetModConfigData("ChesterIncluded")
local LowHealthPulse = GetModConfigData("OptionLowHealth")
local LoyaltyHelpMessage = GetModConfigData("OptionLoyaltyGraphicHover")

for _, moddir in ipairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
    if GLOBAL.KnownModIndex:GetModInfo(moddir).name == "N Tools" then 
        NToolsHAdjust = 110
        NToolsVAdjust = 63
    elseif GLOBAL.KnownModIndex:GetModInfo(moddir).name == "Always On Status" then
        AlwaysOnIsOn = true
    end
end  

local function spairs(t, order)
    local keys = {}
    local i = 0
    for k in pairs(t) do keys[#keys+1] = k end
    if order then table.sort(keys, function(a,b) return order(t, a, b) end) end
    return function()
        i = i + 1
        if keys[i] then return keys[i], t[keys[i]] end
    end
end

local function AddFollowerStatus(inst)

    controls = GLOBAL.GetPlayer().HUD.controls

    local Widget = require "widgets/widget"
    local FollowerContainerWidget = require "widgets/followercontainerwidget"

    local Badge = require "widgets/badge"
    local Text = require "widgets/text"
    local ImageButton = require "widgets/imagebutton"

    local FollowerDefault = Class(Badge, function(status, owner)
        Badge._ctor(status, "follower_meter", owner)
    end)

    local Loyaltybar = Class(Badge, function(status, owner)
        Badge._ctor(status, "loyal_bar", owner)
    end)

    local HUDdown = GetModConfigData("OptionHUDdown")
    local HUDhorizontal = GetModConfigData("OptionHUDhorizontal")

    for i = 1, MaxFollowing, 1 do

        if i == 1 then
            controls.follower1 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower1
            if CommandsAreOn then  
                Follower1ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer1 = GLOBAL.GetPlayer().HUD.controls.follower1:AddChild(FollowerContainerWidget(Follower1ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer1
                CurrentCommand:Open(Follower1ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 2 then
            controls.follower2 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower2            
            if CommandsAreOn then  
                Follower2ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer2 = GLOBAL.GetPlayer().HUD.controls.follower2:AddChild(FollowerContainerWidget(Follower2ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer2
                CurrentCommand:Open(Follower2ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 3 then
            controls.follower3 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower3          
            if CommandsAreOn then  
                Follower3ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer3 = GLOBAL.GetPlayer().HUD.controls.follower3:AddChild(FollowerContainerWidget(Follower3ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer3
                CurrentCommand:Open(Follower3ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 4 then
            controls.follower4 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower4            
            if CommandsAreOn then  
                Follower4ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer4 = GLOBAL.GetPlayer().HUD.controls.follower4:AddChild(FollowerContainerWidget(Follower4ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer4
                CurrentCommand:Open(Follower4ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 5 then
            controls.follower5 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower5            
            if CommandsAreOn then  
                Follower5ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer5 = GLOBAL.GetPlayer().HUD.controls.follower5:AddChild(FollowerContainerWidget(Follower5ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer5
                CurrentCommand:Open(Follower5ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 6 then
            controls.follower6 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower6            
            if CommandsAreOn then  
                Follower6ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer6 = GLOBAL.GetPlayer().HUD.controls.follower6:AddChild(FollowerContainerWidget(Follower6ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer6
                CurrentCommand:Open(Follower6ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 7 then
            controls.follower7 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower7            
            if CommandsAreOn then  
                Follower7ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer7 = GLOBAL.GetPlayer().HUD.controls.follower7:AddChild(FollowerContainerWidget(Follower7ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer7
                CurrentCommand:Open(Follower7ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 8 then
            controls.follower8 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower8            
            if CommandsAreOn then  
                Follower8ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer8 = GLOBAL.GetPlayer().HUD.controls.follower8:AddChild(FollowerContainerWidget(Follower8ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer8
                CurrentCommand:Open(Follower8ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 9 then
            controls.follower9 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower9            
            if CommandsAreOn then  
                Follower9ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer9 = GLOBAL.GetPlayer().HUD.controls.follower9:AddChild(FollowerContainerWidget(Follower9ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer9
                CurrentCommand:Open(Follower9ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 10 then
            controls.follower10 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower10            
            if CommandsAreOn then  
                Follower10ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer10 = GLOBAL.GetPlayer().HUD.controls.follower10:AddChild(FollowerContainerWidget(Follower10ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer10
                CurrentCommand:Open(Follower10ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 11 then
            controls.follower11 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower11            
            if CommandsAreOn then  
                Follower11ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer11 = GLOBAL.GetPlayer().HUD.controls.follower11:AddChild(FollowerContainerWidget(Follower11ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer11
                CurrentCommand:Open(Follower11ItemSlot, GLOBAL.GetPlayer())
            end
        elseif i == 12 then
            controls.follower12 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower12            
            if CommandsAreOn then  
                Follower12ItemSlot = GLOBAL.SpawnPrefab("followeritemslot")
                FollowerContainer12 = GLOBAL.GetPlayer().HUD.controls.follower12:AddChild(FollowerContainerWidget(Follower12ItemSlot, GLOBAL.GetPlayer()))
                CurrentCommand = FollowerContainer12
                CurrentCommand:Open(Follower12ItemSlot, GLOBAL.GetPlayer())
            end
        end

        CurrentBadge:SetPercent(1)                    
        CurrentBadge:SetHAnchor(GLOBAL.ANCHOR_LEFT)
        CurrentBadge:SetVAnchor(GLOBAL.ANCHOR_TOP)
        CurrentBadge:Hide()

        if not LoyaltyDisplayGraphic or AlwaysOnIsOn then
            CurrentBadge.textbar = CurrentBadge:AddChild(GLOBAL.Image("images/status_bg.xml", "status_bg.tex"))
            CurrentBadge.textbar:SetScale(.4,.43,0)
            CurrentBadge.textbar:SetPosition(-.5,-25,0)
        end

        if CommandsAreOn then
            CurrentCommand:SetScale(.3,.3,1)    
            CurrentCommand:Minimise()
        end
        
        if i == 1 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower1.loyaltime = controls.follower1:AddChild(Loyaltybar(owner))
            else
                controls.follower1.loyaltime = controls.follower1:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower1.loyaltime        
        elseif i == 2 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower2.loyaltime = controls.follower2:AddChild(Loyaltybar(owner))
            else
                controls.follower2.loyaltime = controls.follower2:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower2.loyaltime        
        elseif i == 3 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower3.loyaltime = controls.follower3:AddChild(Loyaltybar(owner))
            else
                controls.follower3.loyaltime = controls.follower3:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower3.loyaltime        
        elseif i == 4 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower4.loyaltime = controls.follower4:AddChild(Loyaltybar(owner))
            else
                controls.follower4.loyaltime = controls.follower4:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower4.loyaltime        
        elseif i == 5 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower5.loyaltime = controls.follower5:AddChild(Loyaltybar(owner))
            else
                controls.follower5.loyaltime = controls.follower5:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower5.loyaltime        
        elseif i == 6 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower6.loyaltime = controls.follower6:AddChild(Loyaltybar(owner))
            else
                controls.follower6.loyaltime = controls.follower6:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower6.loyaltime        
        elseif i == 7 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower7.loyaltime = controls.follower7:AddChild(Loyaltybar(owner))
            else
                controls.follower7.loyaltime = controls.follower7:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower7.loyaltime        
        elseif i == 8 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower8.loyaltime = controls.follower8:AddChild(Loyaltybar(owner))
            else
                controls.follower8.loyaltime = controls.follower8:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower8.loyaltime        
        elseif i == 9 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower9.loyaltime = controls.follower9:AddChild(Loyaltybar(owner))
            else
                controls.follower9.loyaltime = controls.follower9:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower9.loyaltime        
        elseif i == 10 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower10.loyaltime = controls.follower10:AddChild(Loyaltybar(owner))
            else
                controls.follower10.loyaltime = controls.follower10:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower10.loyaltime        
        elseif i == 11 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower11.loyaltime = controls.follower11:AddChild(Loyaltybar(owner))
            else
                controls.follower11.loyaltime = controls.follower11:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower11.loyaltime        
        elseif i == 12 then
            if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                controls.follower12.loyaltime = controls.follower12:AddChild(Loyaltybar(owner))
            else
                controls.follower12.loyaltime = controls.follower12:AddChild(Text(GLOBAL.NUMBERFONT, 28))
            end
            CurrentLoyalBadge = controls.follower12.loyaltime        
        end

        if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
            CurrentLoyalBadge:SetScale(.4,.43,1)
            CurrentLoyalBadge:SetPosition(-.5,-25,0)
            CurrentLoyalBadge.num:SetPosition(5, -35, 0)
            CurrentLoyalBadge:SetPercent(1)
            CurrentLoyalBadge:Hide()                  
        else
            CurrentLoyalBadge:SetHAlign(GLOBAL.ANCHOR_MIDDLE)
            CurrentLoyalBadge:SetPosition(3.5, -40.5, 0)
            CurrentLoyalBadge:SetScale(1,.78,1)
            CurrentLoyalBadge:Hide()
        end

    end

    inst:DoPeriodicTask(FollowerPing, function()
        if inst.components.leader:CountFollowers() > 0 then
            FollowerHUDCheck(inst)
        else
            GLOBAL.GetPlayer().HUD.controls.follower1:Hide()
            if MaxFollowing > 1 then GLOBAL.GetPlayer().HUD.controls.follower2:Hide() end
            if MaxFollowing > 2 then GLOBAL.GetPlayer().HUD.controls.follower3:Hide() end
            if MaxFollowing > 3 then GLOBAL.GetPlayer().HUD.controls.follower4:Hide() end
            if MaxFollowing > 4 then GLOBAL.GetPlayer().HUD.controls.follower5:Hide() end
            if MaxFollowing > 5 then GLOBAL.GetPlayer().HUD.controls.follower6:Hide() end
            if MaxFollowing > 6 then GLOBAL.GetPlayer().HUD.controls.follower7:Hide() end
            if MaxFollowing > 7 then GLOBAL.GetPlayer().HUD.controls.follower8:Hide() end
            if MaxFollowing > 8 then GLOBAL.GetPlayer().HUD.controls.follower9:Hide() end
            if MaxFollowing > 9 then GLOBAL.GetPlayer().HUD.controls.follower10:Hide() end
            if MaxFollowing > 10 then GLOBAL.GetPlayer().HUD.controls.follower11:Hide() end
            if MaxFollowing > 11 then GLOBAL.GetPlayer().HUD.controls.follower12:Hide() end
        end
    end)

end

AddSimPostInit(AddFollowerStatus)

local function ChesterAddFollowerHUDPostInit(inst)

    inst:DoPeriodicTask(1, function()
        local chesterbonetest = false
        for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
            if item.prefab == "chester_eyebone" then 
                chesterbonetest = true
            end
        end
        if chesterbonetest then
            GLOBAL.GetPlayer().components.leader:AddFollower(inst)
        else
            GLOBAL.GetPlayer().components.leader:RemoveFollower(inst)
        end
    end)

    if GetModConfigData("ChesterIncluded") then

        local slotpos_3x4 = {}

        for y = 2.5, -0.5, -1 do
            for x = 0, 2 do
                table.insert(slotpos_3x4, GLOBAL.Vector3(75*x-75*2+75, 75*y-75*2+75,0))
            end
        end

        local function FollowerMorphShadowChester(inst, dofx)
            inst:AddTag("spoiler")
            inst.components.container:SetNumSlots(12)
            inst.components.container.widgetslotpos = slotpos_3x4
            inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
            inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"
            inst.components.container.widgetpos = GLOBAL.Vector3(0,220,0)
            inst.components.container.widgetpos_controller = GLOBAL.Vector3(0,220,0)
            inst.components.container.side_align_tip = 160
            local KeepCheckForBone = true
            for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
                if item.prefab == "chester_eyebone" then 
                    if KeepCheckForBone and not item:HasTag("shadowbone") and not item:HasTag("snowbone") then
                        KeepCheckForBone = false
                        item:AddTag("shadowbone")
                        item:MorphShadowEyebone()
                    end
                end
            end
            inst.AnimState:SetBuild("chester_shadow_build")
            inst.ChesterState = "SHADOW"
            inst.MiniMapEntity:SetIcon("chestershadow.png")
        end

        local slotpos_3x3 = {}

        for y = 2, 0, -1 do
            for x = 0, 2 do
                table.insert(slotpos_3x3, GLOBAL.Vector3(80*x-80*2+80, 80*y-80*2+80,0))
            end
        end

        local function FollowerMorphSnowChester(inst, dofx)
            inst:AddTag("fridge")
            inst:AddTag("lowcool")
            local KeepCheckForBone = true
            for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
                if item.prefab == "chester_eyebone" then 
                    if KeepCheckForBone and not item:HasTag("shadowbone") and not item:HasTag("snowbone") then
                        KeepCheckForBone = false
                        item:AddTag("snowbone")
                        item:MorphSnowEyebone()
                    end
                end
            end
            inst.AnimState:SetBuild("chester_snow_build")
            inst.ChesterState = "SNOW"
            inst.MiniMapEntity:SetIcon("chestersnow.png")
        end

        local function FollowerMorphNormalChester(inst, dofx)
            
            local ChesterWas = ""

            if inst:HasTag("fridge") then ChesterWas = "Snow" end
            if inst:HasTag("spoiler") then ChesterWas = "Shadow" end

            inst:RemoveTag("fridge")
            inst:RemoveTag("lowcool")
            inst:RemoveTag("spoiler")
            inst.AnimState:SetBuild("chester_build")

            local KeepCheckForBone = true
            for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
                if item.prefab == "chester_eyebone" then 
                    if KeepCheckForBone and item:HasTag("shadowbone") then
                        KeepCheckForBone = false
                        item:RemoveTag("shadowbone")
                        item:MorphNormalEyebone()
                    end
                    if KeepCheckForBone and item:HasTag("snowbone") then
                        KeepCheckForBone = false
                        item:RemoveTag("snowbone")
                        item:MorphNormalEyebone()
                    end
                end
            end
            inst.ChesterState = "NORMAL"
            inst.MiniMapEntity:SetIcon("chester.png")
        end

        local function FollowerMorphChester(inst)
            local clock = GLOBAL.GetWorld().components.clock
            if not clock:IsNight() or inst.ChesterState ~= "NORMAL" or clock:GetMoonPhase() ~= "full" then
                return
            end
            local container = inst.components.container
            local canShadow, canSnow = inst:CanMorph()
            if canShadow then
                container:ConsumeByName("nightmarefuel", container:GetNumSlots())
                FollowerMorphShadowChester(inst, true)
            elseif canSnow then
                container:ConsumeByName("bluegem", container:GetNumSlots())
                FollowerMorphSnowChester(inst, true)
            end
        end

        local function OnPreLoad(inst, data)
            if not data then return end
            if data.ChesterState == "SHADOW" then
                FollowerMorphShadowChester(inst)
            elseif data.ChesterState == "SNOW" then
                FollowerMorphSnowChester(inst)
            end
        end

        inst.OnPreLoad = OnPreLoad
        inst.MorphChester = FollowerMorphChester

    end

    if GetModConfigData("ChesterShhh") then
        RemapSoundEvent( "dontstarve/creatures/chester/pant", "nothing" )
        RemapSoundEvent( "dontstarve/creatures/chester/boing", "nothing" )
    end

    if GetModConfigData("ChesterBFF") then
        inst:RemoveComponent("combat")
    end

end

local function GlommerAddFollowerHUDPostInit(inst)

    if GetModConfigData("GlommerFix") then

        inst:DoPeriodicTask(1, function()
            local glommerflowertest = false
            if inst:IsNear(GLOBAL.GetPlayer(), 50) then
                for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
                    if item.prefab == "glommerflower" then 
                        glommerflowertest = true
                    end
                end
            end
            if glommerflowertest then
                GLOBAL.GetPlayer().components.leader:AddFollower(inst)
            else
                GLOBAL.GetPlayer().components.leader:RemoveFollower(inst)
            end
        end)

        local function OnFollowerLoad(inst)
            local glommerflowertest = false
            for k,item in pairs(GLOBAL.GetPlayer().components.inventory.itemslots) do
                if item.prefab == "glommerflower" then
                    glommerflowertest = true
                end
            end
            if glommerflowertest == false then
                inst.sg:GoToState("flyaway")
                inst:DoTaskInTime(1, function() inst:Remove() end)
            end
        end
        inst.OnPreLoad = OnFollowerLoad 
        inst.Onload = nil
    end

    if GetModConfigData("GlommerShhh") then
        RemapSoundEvent( "dontstarve_DLC001/creatures/glommer/flap", "nothing" )
        RemapSoundEvent( "dontstarve_DLC001/creatures/glommer/idle_voice", "nothing" )
    end

    if GetModConfigData("GlommerBFF") then
        inst:RemoveComponent("combat")
    end

end

local function MandrakeAddFollowerHUDPostInit(inst)

    if GetModConfigData("MandrakeShhh") then
        RemapSoundEvent( "dontstarve/creatures/mandrake/walk", "nothing" )
    end

end

local function GlommerFlowerPostInit(inst)
    
    if GetModConfigData("GlommerFix") then
        local function OnFollowerPreLoad(inst, data)
            if data then
                inst.deadchild = data.deadchild
            end
        end
        inst.OnPreLoad = OnFollowerPreLoad
        inst.components.leader.onremovefollower = nil
    end

end

local function AbigailFlowerPostInit(inst)

    if GetModConfigData("AbigailCharged") then
        inst.components.cooldown.cooldown_duration = 1
        inst.components.cooldown:StartCharging()
    end

end

local function TallbirdEggPostInit(inst)

    if GetModConfigData("TallbirdEggHatch") then
        inst:DoTaskInTime(5, function()
            local smallbird = GLOBAL.SpawnPrefab("smallbird")
            smallbird.Transform:SetPosition(inst.Transform:GetWorldPosition())
            smallbird.sg:GoToState("hatch")
            inst:Remove()
        end)
    end

end

local function TallbirdPostInit(inst)

    local function SpawnAdult(inst)

        GLOBAL.MakeCharacterPhysics(inst, 10, .5)
        inst.AnimState:SetBank("tallbird")
        inst.AnimState:SetBuild("ds_tallbird_basic")
        inst.components.locomotor.walkspeed = 7
        inst.components.combat:SetDefaultDamage(TUNING.TALLBIRD_DAMAGE)
        inst.components.combat:SetAttackPeriod(TUNING.TALLBIRD_ATTACK_PERIOD)
        inst.AnimState:Hide("beakfull")
        inst.RemoveComponent("growable")

    end

    local growth_stages = {
        {name="tall", time = GetTallGrowTime, fn = function() end },
        {name="adult", fn = SetAdult}
    }

    inst.components.growable.stages = growth_stages
    SpawnAdult(inst)

end

local function SpiderDenPostInit(inst)

    if GLOBAL.GetPlayer().prefab == "webber" then

        local function onsleep(inst, sleeper)


            if GLOBAL.GetClock():IsDay() then
                local tosay = "ANNOUNCE_NODAYSLEEP"
                if GLOBAL.GetWorld():IsCave() then
                    tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
                end
                if sleeper.components.talker then
                    sleeper.components.talker:Say("It's too crowded in there")
                    return
                end
            end
            
            local hounded = GLOBAL.GetWorld().components.hounded

            local danger = GLOBAL.FindEntity(inst, 10, function(target) return target.components.combat and target.components.combat.target == inst end)
            
            if hounded and (hounded.warning or hounded.timetoattack <= 0) then
                danger = true
            end
            
            if danger then
                if sleeper.components.talker then
                    sleeper.components.talker:Say("Can't sleep now")
                end
                return
            end

            if sleeper.components.hunger.current < TUNING.CALORIES_MED then
                sleeper.components.talker:Say("Need to eat first")
                return
            end
            
            sleeper.components.health:SetInvincible(true)
            sleeper.components.playercontroller:Enable(false)

            GLOBAL.GetPlayer().HUD:Hide()
            GLOBAL.TheFrontEnd:Fade(false,1)

            inst:DoTaskInTime(1.2, function() 
                
                GLOBAL.GetPlayer().HUD:Show()
                GLOBAL.TheFrontEnd:Fade(true,1) 
                
                if GLOBAL.GetClock():IsDay() then

                    local tosay = "ANNOUNCE_NODAYSLEEP"
                    if GLOBAL.GetWorld():IsCave() then
                        tosay = "ANNOUNCE_NODAYSLEEP_CAVE"
                    end

                    if sleeper.components.talker then               
                        sleeper.components.talker:Say("It's too crowded in there")
                        sleeper.components.health:SetInvincible(false)
                        sleeper.components.playercontroller:Enable(true)
                        return
                    end
                end
                
                if sleeper.components.sanity then
                    sleeper.components.sanity:DoDelta(GLOBAL.TUNING.SANITY_HUGE)
                end
                
                if sleeper.components.hunger then
                    sleeper.components.hunger:DoDelta(-GLOBAL.TUNING.CALORIES_HUGE, false, true)
                end
                
                if sleeper.components.health then
                    sleeper.components.health:DoDelta(GLOBAL.TUNING.HEALING_HUGE, false, "tent", true)
                end
                
                if sleeper.components.temperature then
                    sleeper.components.temperature:SetTemperature(sleeper.components.temperature.maxtemp)
                end
                
                
                GLOBAL.GetClock():MakeNextDay()
                
                sleeper.components.health:SetInvincible(false)
                sleeper.components.playercontroller:Enable(true)
                sleeper.sg:GoToState("wakeup")  
            end) 
        end

        inst:AddComponent("sleepingbag")
        inst.components.sleepingbag.onsleep = onsleep

        end

end

AddPrefabPostInit("abigail_flower", AbigailFlowerPostInit)
AddPrefabPostInit("chester", ChesterAddFollowerHUDPostInit)
AddPrefabPostInit("glommer", GlommerAddFollowerHUDPostInit)
AddPrefabPostInit("glommerflower", GlommerFlowerPostInit)
AddPrefabPostInit("mandrake", MandrakeAddFollowerHUDPostInit)
AddPrefabPostInit("tallbirdegg_cracked", TallbirdEggPostInit)
--AddPrefabPostInit("smallbird", TallbirdPostInit)
AddPrefabPostInit("spiderden", SpiderDenPostInit)

local function ChangeFollowerDistance(brain)

    local NewDistance = 0
    if brain.inst.prefab == "chester" then
        NewDistance = 6 + GetModConfigData("ChesterFollow")
    elseif brain.inst.prefab == "abigail" then
        NewDistance = 6 + GetModConfigData("AbigailFollow")
    elseif brain.inst.prefab == "shadowwaxwell" then
        NewDistance = 6 + GetModConfigData("ShadowFollow")
    elseif brain.inst.prefab == "catcoon" then
        NewDistance = 6 + GetModConfigData("CatcoonFollow")
    end

    local follownod = nil
    local followindex = nil
    local fireindex = nil
    for i,node in ipairs(brain.bt.root.children) do
        if node.name == "Follow" then
            follownod = node
            followindex = i
            break
        end
    end
    follownod = GLOBAL.Follow(brain.inst, function() return brain.inst.components.follower.leader end, 0, NewDistance / 2, NewDistance)
    follownod.name = "FollowModded"
    table.remove(brain.bt.root.children, followindex)
    table.insert(brain.bt.root.children, followindex, follownod)

end

AddBrainPostInit("chesterbrain", ChangeFollowerDistance)
AddBrainPostInit("abigailbrain", ChangeFollowerDistance)
AddBrainPostInit("shadowwaxwellbrain", ChangeFollowerDistance)
if not GLOBAL.IsDLCEnabled(0) then
    if GLOBAL.IsDLCEnabled(1) then
        AddBrainPostInit("catcoonbrain", ChangeFollowerDistance) 
    end
end

function StopWerepigs(self, inst, time)
    if GetModConfigData("NoWerepigs") then
        function self.SetWere(self, inst, time)
            self.weretime = GLOBAL.TUNING.SEG_TIME*4
            local willTransform = {}
            if self.inst.components.follower.leader then

            else
                if self.onsetwerefn then self.onsetwerefn(self.inst) end
                self.inst:PushEvent("transformwere")
                if self.triggerlimit then self.triggeramount = 0 end
                local weretime = time or self.weretime
                self.targettime = GLOBAL.GetTime() + weretime
                self.targettick = GLOBAL.GetTickForTime(self.targettime)
                if not willTransform[self.targettick] then
                    willTransform[self.targettick] = {[self.inst] = self.inst}
                else
                    willTransform[self.targettick][self.inst] = self.inst
                end
            end
        end
    end
end

AddComponentPostInit("werebeast", StopWerepigs)

function FollowerHUDCheck(inst)

    local increment = 60 + (GLOBAL.PlayerProfile:GetHUDSize() * 4)
    local count, badgeV, MandrakeCount = 0, 0, 0 

    local CurrentFollowers = {}
    for k, v in pairs(GLOBAL.GetPlayer().components.leader.followers) do 
        if BadgeOrderedLoyalty then
            CurrentFollowers[k] = math.floor(k.components.health:GetPercent()*10000)
        else        
            if k.components.follower:GetLoyaltyPercent() == 0 then
                CurrentFollowers[k] = 10000 + k.components.health:GetPercent()
            else
                CurrentFollowers[k] = math.floor(k.components.follower:GetLoyaltyPercent()*10000) 
            end
        end
    end

    for k,v in spairs(CurrentFollowers, function(t,a,b) return t[a] > t[b] end) do

        if k.prefab == "mandrake" then MandrakeCount = MandrakeCount + 1 end
        if k.components.health.currenthealth > 0 then
            if k.prefab == "mandrake" and MandrakeCount > MandrakeMax then                 
            else
                if (k.prefab ~= "chester" or ChesterToBeIncluded) and count < MaxFollowing then
                    badgeV = -60
                    count = count + 1
                    if count % 2 == 0 then badgeV = -100 end
                    if count == 1 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower1                            
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer1.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer1.commandbuttonremove
                            CurrentBadgePause = FollowerContainer1.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer1.commandbuttonplay
                            CurrentBadgeSlot = Follower1ItemSlot                       
                        end
                        if Follower1Id == k and Follower1Health ~= k.components.health:GetPercent() then 
                            if Follower1Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower1Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower1Id = k
                        Follower1Health = k.components.health:GetPercent()
                    end
                    if count == 2 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower2
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer2.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer2.commandbuttonremove
                            CurrentBadgePause = FollowerContainer2.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer2.commandbuttonplay
                            CurrentBadgeSlot = Follower2ItemSlot
                        end
                        if Follower2Id == k and Follower2Health ~= k.components.health:GetPercent() then 
                            if Follower2Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower2Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower2Id = k
                        Follower2Health = k.components.health:GetPercent()
                    end
                    if count == 3 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower3
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer3.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer3.commandbuttonremove
                            CurrentBadgePause = FollowerContainer3.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer3.commandbuttonplay
                            CurrentBadgeSlot = Follower3ItemSlot
                        end
                        if Follower3Id == k and Follower3Health ~= k.components.health:GetPercent() then 
                            if Follower3Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower3Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower3Id = k
                        Follower3Health = k.components.health:GetPercent()
                    end
                    if count == 4 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower4
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer4.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer4.commandbuttonremove
                            CurrentBadgePause = FollowerContainer4.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer4.commandbuttonplay
                            CurrentBadgeSlot = Follower4ItemSlot
                        end
                        if Follower4Id == k and Follower4Health ~= k.components.health:GetPercent() then 
                            if Follower4Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower4Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower4Id = k
                        Follower4Health = k.components.health:GetPercent()
                    end
                    if count == 5 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower5
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer5.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer5.commandbuttonremove
                            CurrentBadgePause = FollowerContainer5.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer5.commandbuttonplay
                            CurrentBadgeSlot = Follower5ItemSlot
                        end
                        if Follower5Id == k and Follower5Health ~= k.components.health:GetPercent() then 
                            if Follower5Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower5Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower5Id = k
                        Follower5Health = k.components.health:GetPercent()
                    end
                    if count == 6 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower6
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer6.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer6.commandbuttonremove
                            CurrentBadgePause = FollowerContainer6.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer6.commandbuttonplay
                            CurrentBadgeSlot = Follower6ItemSlot
                        end
                        if Follower6Id == k and Follower6Health ~= k.components.health:GetPercent() then 
                            if Follower6Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower6Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower6Id = k
                        Follower6Health = k.components.health:GetPercent()
                    end
                    if count == 7 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower7
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer7.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer7.commandbuttonremove
                            CurrentBadgePause = FollowerContainer7.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer7.commandbuttonplay
                            CurrentBadgeSlot = Follower7ItemSlot
                        end
                        if Follower7Id == k and Follower7Health ~= k.components.health:GetPercent() then 
                            if Follower7Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower7Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower7Id = k
                        Follower7Health = k.components.health:GetPercent()
                    end
                    if count == 8 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower8
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer8.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer8.commandbuttonremove
                            CurrentBadgePause = FollowerContainer8.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer8.commandbuttonplay
                            CurrentBadgeSlot = Follower8ItemSlot
                        end
                        if Follower8Id == k and Follower8Health ~= k.components.health:GetPercent() then 
                            if Follower8Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower8Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower8Id = k
                        Follower8Health = k.components.health:GetPercent()
                    end
                    if count == 9 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower9
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer9.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer9.commandbuttonremove
                            CurrentBadgePause = FollowerContainer9.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer9.commandbuttonplay
                            CurrentBadgeSlot = Follower9ItemSlot
                        end
                        if Follower9Id == k and Follower9Health ~= k.components.health:GetPercent() then 
                            if Follower9Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower9Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower9Id = k
                        Follower9Health = k.components.health:GetPercent()
                    end
                    if count == 10 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower10
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer10.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer10.commandbuttonremove
                            CurrentBadgePause = FollowerContainer10.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer10.commandbuttonplay
                            CurrentBadgeSlot = Follower10ItemSlot
                        end
                        if Follower10Id == k and Follower10Health ~= k.components.health:GetPercent() then 
                            if Follower10Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower10Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower10Id = k
                        Follower10Health = k.components.health:GetPercent()
                    end
                    if count == 11 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower11
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer11.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer11.commandbuttonremove
                            CurrentBadgePause = FollowerContainer11.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer11.commandbuttonplay
                            CurrentBadgeSlot = Follower11ItemSlot
                        end
                        if Follower11Id == k and Follower11Health ~= k.components.health:GetPercent() then 
                            if Follower11Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower11Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower11Id = k
                        Follower11Health = k.components.health:GetPercent()
                    end
                    if count == 12 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower12
                        if CommandsAreOn then              
                            CurrentBadgeWhere = FollowerContainer12.commandbuttonwhere
                            CurrentBadgeRemove = FollowerContainer12.commandbuttonremove
                            CurrentBadgePause = FollowerContainer12.commandbuttonpause
                            CurrentBadgePlay = FollowerContainer12.commandbuttonplay
                            CurrentBadgeSlot = Follower12ItemSlot
                        end
                        if Follower12Id == k and Follower12Health ~= k.components.health:GetPercent() then 
                            if Follower12Health > k.components.health:GetPercent() then
                                CurrentBadge:PulseRed()
                            elseif Follower12Health < k.components.health:GetPercent() then
                                CurrentBadge:PulseGreen()
                            end
                        end
                        Follower12Id = k
                        Follower12Health = k.components.health:GetPercent()
                    end

                    CurrentBadge:SetScale(1 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10),1 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10),1 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10))
                    CurrentBadge:SetPosition(104 + ((count - 1) * increment) + NToolsHAdjust + (GLOBAL.PlayerProfile:GetHUDSize() * 4.8) +  GetModConfigData("OptionHUDhorizontal"), (badgeV - NToolsVAdjust) - GLOBAL.PlayerProfile:GetHUDSize() - GetModConfigData("OptionHUDdown"), 50)

                    if k.prefab == "abigail" then
                        CurrentBadge.anim:GetAnimState():SetBank("abigail_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("abigail_meter")
                    elseif k.prefab == "babybeefalo" then
                        CurrentBadge.anim:GetAnimState():SetBank("teenbeef_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("teenbeef_meter")
                    elseif k.prefab == "beefalo" then
                        if k.components.beard.bits == 0 then
                            CurrentBadge.anim:GetAnimState():SetBank("shavebeef_meter")
                            CurrentBadge.anim:GetAnimState():SetBuild("shavebeef_meter")                        
                        else
                            CurrentBadge.anim:GetAnimState():SetBank("beefalo_meter")
                            CurrentBadge.anim:GetAnimState():SetBuild("beefalo_meter")
                        end
                    elseif k.prefab == "bishop_nightmare" then
                        CurrentBadge.anim:GetAnimState():SetBank("bishop_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("bishop_meter")
                    elseif k.prefab == "bunnyman" then
                        CurrentBadge.anim:GetAnimState():SetBank("bunny_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("bunny_meter")
                    elseif k.prefab == "catcoon" then
                        CurrentBadge.anim:GetAnimState():SetBank("catcoon_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("catcoon_meter")
                    elseif k.prefab == "chester" then
                        if k:HasTag("spoiler") then
                            CurrentBadge.anim:GetAnimState():SetBank("darkchester_meter")
                            CurrentBadge.anim:GetAnimState():SetBuild("darkchester_meter")
                        elseif k:HasTag("fridge") then
                            CurrentBadge.anim:GetAnimState():SetBank("snowchester_meter")
                            CurrentBadge.anim:GetAnimState():SetBuild("snowchester_meter")
                        else
                            CurrentBadge.anim:GetAnimState():SetBank("chester_meter")
                            CurrentBadge.anim:GetAnimState():SetBuild("chester_meter")
                        end
                    elseif k.prefab == "emerling" then
                        CurrentBadge.anim:GetAnimState():SetBank("emerling_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("emerling_meter")
                    elseif k.prefab == "glommer" then
                        CurrentBadge.anim:GetAnimState():SetBank("glommer_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("glommer_meter")
                    elseif k.prefab == "knight_nightmare" then
                        CurrentBadge.anim:GetAnimState():SetBank("knight_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("knight_meter")
                    elseif k.prefab == "mandrake" then
                        CurrentBadge.anim:GetAnimState():SetBank("mandrake_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("mandrake_meter")
                    elseif k.prefab == "merm" then
                        CurrentBadge.anim:GetAnimState():SetBank("merm_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("merm_meter")
                    elseif k.prefab == "pigman" then
                        CurrentBadge.anim:GetAnimState():SetBank("pig_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("pig_meter")
                    elseif k.prefab == "rocky" then
                        CurrentBadge.anim:GetAnimState():SetBank("rocky_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("rocky_meter")
                    elseif k.prefab == "rook_nightmare" then
                        CurrentBadge.anim:GetAnimState():SetBank("rook_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("rook_meter")
                    elseif k.prefab == "shadowwaxwell" then
                        CurrentBadge.anim:GetAnimState():SetBank("shadow_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("shadow_meter")
                    elseif k.prefab == "smallbird" or k.prefab == "teenbird" or k.prefab == "tallbird" then
                        CurrentBadge.anim:GetAnimState():SetBank("tallbird_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("tallbird_meter")
                    elseif k.prefab == "spider" then
                        CurrentBadge.anim:GetAnimState():SetBank("spider_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("spider_meter")
                    elseif k.prefab == "spider_hider" then
                        CurrentBadge.anim:GetAnimState():SetBank("cspider_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("cspider_meter")
                    elseif k.prefab == "spider_spitter" then
                        CurrentBadge.anim:GetAnimState():SetBank("spitter_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("spitter_meter")
                    elseif k.prefab == "spider_dropper" then
                        CurrentBadge.anim:GetAnimState():SetBank("dangler_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("dangler_meter")
                    elseif k.prefab == "spider_warrior" then
                        CurrentBadge.anim:GetAnimState():SetBank("swarrior_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("swarrior_meter")
                    else
                        CurrentBadge.anim:GetAnimState():SetBank("follow_meter")
                        CurrentBadge.anim:GetAnimState():SetBuild("follow_meter")
                    end
                    CurrentBadge:Show()
                    CurrentBadge.loyaltime:Show()
                    if LoyaltyDisplayGraphic and not AlwaysOnIsOn then
                        if k.components.follower:GetLoyaltyPercent()*100 > 0 then
                            CurrentBadge.loyaltime:SetPercent(k.components.follower:GetLoyaltyPercent())
                            CurrentBadge.loyaltime.num:SetString(tostring(math.floor(k.components.follower:GetLoyaltyPercent()*100)).."%")                            
                        else
                            CurrentBadge.loyaltime:SetPercent(1)
                            CurrentBadge.loyaltime.num:SetString("Forever")                            
                        end

                        if LoyaltyHelpMessage then
                            CurrentBadge.loyaltime.num:SetString("Loyalty")
                        end
                    else
                        CurrentBadge.num:Hide()
                        if k.components.follower:GetLoyaltyPercent()*100 > 0 then
                            if math.floor(k.components.follower:GetLoyaltyPercent()*100) == 0 then
                                CurrentBadge.loyaltime:SetString("1%")
                            else
                                CurrentBadge.loyaltime:SetString(tostring(math.floor(k.components.follower:GetLoyaltyPercent()*100)).."%")
                            end
                        else
                            CurrentBadge.loyaltime:SetString("~")
                        end
                    end
                    CurrentBadge:SetPercent(k.components.health:GetPercent())
                    if HealthAsGraphic then 
                        CurrentBadge.num:SetString(tostring(math.ceil(k.components.health.currenthealth)))
                    else
                        if k.components.health:GetPercent()*100 > 99 then
                            CurrentBadge.num:SetString("Max")
                        else
                            CurrentBadge.num:SetString(tostring(math.ceil(k.components.health:GetPercent()*100)).."%")
                        end
                    end
                    if k.components.health:GetPercent() < .3 and LowHealthPulse then 
                        CurrentBadge.pulse:GetAnimState():SetMultColour(1,.5,0,1) -- Orange
                        CurrentBadge.pulse:GetAnimState():PlayAnimation("pulse")
                    end
                    if CommandsAreOn then 

                        if k:HasTag("BrainStopped") and CurrentBadgeSlot:HasTag("open") then
                            CurrentBadgePause:Hide()
                            CurrentBadgePlay:Show()
                        elseif not k:HasTag("BrainStopped") and CurrentBadgeSlot:HasTag("open") then
                            CurrentBadgePlay:Hide()
                            CurrentBadgePause:Show()
                        end     

                        for t,v in pairs(CurrentBadgeSlot.components.container.slots) do
                            if v.components.healer then
                                v.components.healer:Heal(k)
                            end
                            if k.components.trader then
                                if k.components.trader:CanAccept(v, GLOBAL.GetPlayer()) then
                                    k.components.trader:AcceptGift(GLOBAL.GetPlayer(), v)
                                else
                                    CurrentBadgeSlot.components.container:RemoveItem(v)
                                    local pos = GLOBAL.Vector3(k.Transform:GetWorldPosition())
                                    v.Transform:SetPosition(pos:Get())

                                    k.components.inventory:DropItem(v)
                                    if k.components.talker then k.components.talker:Say("Don't want that.") end
                                end
                            else
                                if k.prefab == "chester" and v.prefab ~= "chester_eyebone" and v.prefab~= "glommerflower" and not k.components.container:IsFull() then
                                    CurrentBadgeSlot.components.container:RemoveItem(v)
                                    k.components.container:GiveItem(v)
                                else
                                    CurrentBadgeSlot.components.container:RemoveItem(v)
                                    GLOBAL.GetPlayer().components.inventory:GiveItem(v)                                
                                end
                            end        
                        end

                        CurrentBadgeWhere:SetOnClick(function()
                            if FollowerIndicator == nil then
                                FollowerIndicator = GLOBAL.SpawnPrefab("followerindicator")
                                local pos = GLOBAL.Vector3(k.Transform:GetWorldPosition())
                                FollowerIndicator.Transform:SetPosition(pos:Get())                           
                                FollowerIndicator:DoPeriodicTask(.1, function() 
                                    if not FollowerIndicator:IsNear(k, .2) then
                                        FollowerIndicator.components.locomotor:GoToEntity(k)
                                        FollowerIndicator.components.locomotor:RunForward()
                                    end
                                end)
                                inst:DoTaskInTime(3, function() FollowerIndicator = nil end)
                            end
                        end)

                        if CommandsToRemoveOn == "true" then 
                            CurrentBadgeRemove:SetOnClick(function() 
                                GLOBAL.GetPlayer().components.leader:RemoveFollower(k) 
                                if k:HasTag("BrainStopped") then
                                    k:RemoveTag("BrainStopped")
                                    k:RestartBrain()                                
                                end
                            end)
                        elseif CommandsToRemoveOn == "false" then
                            CurrentBadgeRemove.commandtext:SetString("Disabled")
                            CurrentBadgeRemove:SetOnClick(function() end)
                        elseif CommandsToRemoveOn == "MagicHats" then
                            if k.prefab == "pigman" or k.prefab == "merm" then
                                CurrentBadgeRemove.commandtext:SetString("Magic Hat")
                                CurrentBadgeRemove:ChangeImage("images/command_magichat.xml", "command_magichat.tex")
                                CurrentBadgeRemove:SetOnClick(function() 
                                local RandomNumber = math.random(11)
                                local HatPrefab = nil
                                if RandomNumber == 1 then
                                    HatPrefab = GLOBAL.SpawnPrefab("strawhat")
                                elseif RandomNumber == 2 then
                                    HatPrefab = GLOBAL.SpawnPrefab("tophat")
                                elseif RandomNumber == 3 then
                                    HatPrefab = GLOBAL.SpawnPrefab("beefalohat")
                                elseif RandomNumber == 4 then
                                    HatPrefab = GLOBAL.SpawnPrefab("featherhat")
                                elseif RandomNumber == 5 then
                                    HatPrefab = GLOBAL.SpawnPrefab("beehat")
                                elseif RandomNumber == 6 then
                                    HatPrefab = GLOBAL.SpawnPrefab("minerhat")
                                elseif RandomNumber == 7 then
                                    HatPrefab = GLOBAL.SpawnPrefab("footballhat")
                                elseif RandomNumber == 8 then
                                    HatPrefab = GLOBAL.SpawnPrefab("earmuffs")
                                elseif RandomNumber == 9 then
                                    HatPrefab = GLOBAL.SpawnPrefab("winterhat")
                                elseif RandomNumber == 10 then
                                    HatPrefab = GLOBAL.SpawnPrefab("bushhat")
                                elseif RandomNumber == 11 then
                                    HatPrefab = GLOBAL.SpawnPrefab("flowerhat")
                                end
                                    k.components.trader:AcceptGift(GLOBAL.GetPlayer(), HatPrefab)
                                end)                            
                            else
                                CurrentBadgeRemove.commandtext:SetString("Disabled")
                                CurrentBadgeRemove:ChangeImage("images/command_remove.xml", "command_remove.tex")
                            end
                        end

                        CurrentBadgePause:SetOnClick(function()
                            if (k.components.sleeper and not k.components.sleeper:IsAsleep()) or not k.components.sleeper then    
                                if not k:HasTag("BrainStopped") then
                                    k:AddTag("BrainStopped")
                                    k:StopBrain()
                                    k.components.combat:GiveUp()
                                    k.components.locomotor:GoToEntity(GLOBAL.GetPlayer(), nil, true)
                                    inst:DoTaskInTime(3, function()
                                        k.components.locomotor:StopMoving()
                                        k.components.locomotor:Clear()
                                    end)
                                end
                            end                            
                        end)

                        CurrentBadgePlay:SetOnClick(function()
                            if (k.components.sleeper and not k.components.sleeper:IsAsleep()) or not k.components.sleeper then    
                                if k:HasTag("BrainStopped") then
                                    k:RemoveTag("BrainStopped")
                                    k:RestartBrain()
                                end
                            end
                        end)
                            
                    end
                end
            end
        end
    end

    if count < 2 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower2:Hide() end
    if count < 3 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower3:Hide() end
    if count < 4 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower4:Hide() end
    if count < 5 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower5:Hide() end
    if count < 6 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower6:Hide() end
    if count < 7 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower7:Hide() end
    if count < 8 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower8:Hide() end
    if count < 9 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower9:Hide() end
    if count < 10 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower10:Hide() end
    if count < 11 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower11:Hide() end
    if count < 12 and count < MaxFollowing then GLOBAL.GetPlayer().HUD.controls.follower12:Hide() end

end