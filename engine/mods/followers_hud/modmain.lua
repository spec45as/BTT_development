local require = GLOBAL.require

Assets = {
	Asset( "ANIM", "anim/pig_meter.zip"),

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

local CurrentBadge = nil
local controls = nil

local Follower1Id, Follower2Id, Follower3Id, Follower4Id, Follower5Id, Follower6Id, Follower7Id, Follower8Id, Follower9Id, Follower10Id, Follower11Id, Follower12Id = "", "", "", "", "", "", "", "", "", "", "", "" 
local Follower1Health, Follower2Health, Follower3Health, Follower4Health, Follower5Health, Follower6Health, Follower7Health, Follower8Health, Follower9Health, Follower10Health, Follower11Health, Follower12Health = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

local MaxFollowing = 12
local FollowerPing = .5

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

    local Badge = require "widgets/badge"
    local Text = require "widgets/text"

    local FollowerDefault = Class(Badge, function(status, owner)
        Badge._ctor(status, "follower_meter", owner)
    end)

    for i = 1, MaxFollowing, 1 do

        if i == 1 then
            controls.follower1 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower1
        elseif i == 2 then
            controls.follower2 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower2            
        elseif i == 3 then
            controls.follower3 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower3          
        elseif i == 4 then
            controls.follower4 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower4            
        elseif i == 5 then
            controls.follower5 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower5            
        elseif i == 6 then
            controls.follower6 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower6            
        elseif i == 7 then
            controls.follower7 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower7            
        elseif i == 8 then
            controls.follower8 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower8            
        elseif i == 9 then
            controls.follower9 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower9            
        elseif i == 10 then
            controls.follower10 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower10            
        elseif i == 11 then
            controls.follower11 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower11            
        elseif i == 12 then
            controls.follower12 = controls.top_root:AddChild(FollowerDefault(owner))
            CurrentBadge = controls.follower12            
        end

        CurrentBadge:SetPercent(1)                    
        CurrentBadge:SetHAnchor(GLOBAL.ANCHOR_LEFT)
        CurrentBadge:SetVAnchor(GLOBAL.ANCHOR_TOP)
        CurrentBadge:Hide()
    end

    inst:DoPeriodicTask(FollowerPing, function()
		for selected_inst in pairs(inst.components.actionqueuer.selected_insts) do
			FollowerHUDCheck(inst)
			return
		end

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
    end)

end

AddSimPostInit(AddFollowerStatus)

function FollowerHUDCheck(inst)
    local increment = 40 + (GLOBAL.PlayerProfile:GetHUDSize() * 4)
    local count, badgeV = 0, 0

    local CurrentFollowers = {}
    for k, v in pairs(GLOBAL.GetPlayer().components.actionqueuer.selected_insts) do 
        CurrentFollowers[k] = math.floor(k.components.health:GetPercent()*10000)
    end

    for k,v in spairs(CurrentFollowers, function(t,a,b) return t[a] > t[b] end) do

        if k.components.health.currenthealth > 0 then
            
                if count < MaxFollowing then
                    badgeV = -60
                    count = count + 1
                    if math.floor(count / 11) == 1 then badgeV = -130 end
                    if count == 1 then
                        CurrentBadge = GLOBAL.GetPlayer().HUD.controls.follower1                            
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

                    CurrentBadge:SetScale(0.5 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10),0.5 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10),0.5 + ((GLOBAL.PlayerProfile:GetHUDSize() / 2) / 10))
                    local badgeH = 0
					local maxOnRow = 10
					if count > maxOnRow then badgeH = -(104 + ((maxOnRow-2) * increment) + (GLOBAL.PlayerProfile:GetHUDSize() * 4.8)) end
					CurrentBadge:SetPosition(104 + ((count - 1) * increment) + (GLOBAL.PlayerProfile:GetHUDSize() * 4.8) + badgeH, badgeV - GLOBAL.PlayerProfile:GetHUDSize(), 50)

                    CurrentBadge.anim:GetAnimState():SetBank("pig_meter")
                    CurrentBadge.anim:GetAnimState():SetBuild("pig_meter")
                    
                    CurrentBadge:Show()

                    CurrentBadge:SetPercent(k.components.health:GetPercent())
                    CurrentBadge.num:SetString(tostring(math.ceil(k.components.health.currenthealth)))
					
                    if k.components.health:GetPercent() < .3 then 
                        CurrentBadge.pulse:GetAnimState():SetMultColour(1,.5,0,1) -- Orange
                        CurrentBadge.pulse:GetAnimState():PlayAnimation("pulse")
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