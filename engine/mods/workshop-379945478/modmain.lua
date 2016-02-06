local require = GLOBAL.require
_G = GLOBAL

local Leader = require "components/leader"
local Highlight = require "components/highlight"
local Combat = require "components/combat"
local Follower = require "components/follower"
local BehaviourNode = require "behaviourtree"
--local ChaseAndAttack = require 'behaviours/chaseandattack'
--require "behaviours/chaseandattack"


local config_FXStrength 			= GetModConfigData("FX_Strength")
local config_FriendlyColorChoice 	= GetModConfigData("Friendly_Color")
local config_EnemyColorChoice 		= GetModConfigData("Enemy_Color")

_G.FriendlyColor = {}
_G.FriendlyColor.r = 0
_G.FriendlyColor.g = .2
_G.FriendlyColor.b = 0

_G.EnemyColor = {}
_G.EnemyColor.r = .2
_G.EnemyColor.g = 0
_G.EnemyColor.b = 0

_G.BrightFriendlyColor = .2
_G.BrightEnemyColor = .2

function Leader:AddFollower(follower)
    if self.followers[follower] == nil and follower.components.follower then
        self.followers[follower] = true
        self.numfollowers = self.numfollowers + 1
        follower.components.follower:SetLeader(self.inst)
        follower:PushEvent("startfollowing", {leader = self.inst} )
        
        self.inst:ListenForEvent("death", function(inst, data) self:RemoveFollower(follower) end, follower)
        follower:ListenForEvent("death", function(inst, data) self:RemoveFollower(follower) end, self.inst)

	    if self.inst:HasTag( "player" ) and follower.prefab then
			_G.MarkFriend(follower)
		    _G.ProfileStatsAdd("befriend_"..follower.prefab)
	    end
	end
end

function Highlight:Highlight(r,g,b)
    self.highlit = true
    
    if self.inst:IsValid() 
		and self.inst:HasTag("player") or TheSim:GetLightAtPoint(self.inst.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF then
			local m = .2
			
			if self.inst:HasTag("bf_friendly") then
				self.highlight_add_colour_red 		= _G.FriendlyColor.r + _G.BrightFriendlyColor
				self.highlight_add_colour_green 	= _G.FriendlyColor.g + _G.BrightFriendlyColor
				self.highlight_add_colour_blue 		= _G.FriendlyColor.b + _G.BrightFriendlyColor
			elseif self.inst:HasTag("bf_enemy") then
				self.highlight_add_colour_red 		= _G.EnemyColor.r + _G.BrightEnemyColor
				self.highlight_add_colour_green 	= _G.EnemyColor.g + _G.BrightEnemyColor
				self.highlight_add_colour_blue 		= _G.EnemyColor.b + _G.BrightEnemyColor
			else
				self.highlight_add_colour_red 		= r or m
				self.highlight_add_colour_green 	= g or m
				self.highlight_add_colour_blue 		= b or m
			end
    end

	self:ApplyColour()    
end

function Highlight:UnHighlight()
    self.highlit = nil
	if self.inst:HasTag("bf_friendly") then
		self.highlight_add_colour_red 		= _G.FriendlyColor.r
		self.highlight_add_colour_green 	= _G.FriendlyColor.g
		self.highlight_add_colour_blue 		= _G.FriendlyColor.b
	elseif self.inst:HasTag("bf_enemy") then
		self.highlight_add_colour_red 		= _G.EnemyColor.r
		self.highlight_add_colour_green 	= _G.EnemyColor.g
		self.highlight_add_colour_blue 		= _G.EnemyColor.b
	else
		self.highlight_add_colour_red = nil
		self.highlight_add_colour_green = nil
		self.highlight_add_colour_blue = nil
	end
	self:ApplyColour()   
	if not self.flashing then
		self.inst:RemoveComponent("highlight")
	end
end

function Combat:SetTarget(target)
    local new = target ~= self.target
    local player = _G.GetPlayer()

    if new and (not target or self:IsValidTarget(target) ) and not (target and target.sg and target.sg:HasStateTag("hiding") and target:HasTag("player")) then

        if METRICS_ENABLED and self.target == player and new ~= player then
            FightStat_GaveUp(self.inst)
        end

		if self.target then
			self.lasttargetGUID = self.target.GUID
		else
			self.lasttargetGUID = nil
		end
		
        self.target = target
        self.inst:PushEvent("newcombattarget", {target=target})

        if METRICS_ENABLED and (player == target or target and target.components.follower and target.components.follower.leader == player) then
            FightStat_Targeted(self.inst)
        end
        
        if target and self.keeptargetfn then
            self.inst:StartUpdatingComponent(self)
        else
            self.inst:StopUpdatingComponent(self)
        end
        
        if target and self.inst.components.follower and self.inst.components.follower.leader == target and self.inst.components.follower.leader.components.leader then
			self.inst.components.follower.leader.components.leader:RemoveFollower(self.inst)
        end
		
		if target and target:HasTag("player") then
			self.inst:AddTag("bf_enemy")
			_G.MarkEnemy(self.inst)
		end
    end
end

function Combat:OnUpdate(dt)
    if not self.target then
        self.inst:StopUpdatingComponent(self)
        return
    end
    
    if self.keeptargetfn then
        self.keeptargettimeout = self.keeptargettimeout - dt
        if self.keeptargettimeout < 0 then
            self.keeptargettimeout = 1
            if not self.target:IsValid() or 
				not self.keeptargetfn(self.inst, self.target) or not 
                (self.target and self.target.components.combat and self.target.components.combat:CanBeAttacked(self.inst)) then    
                self.inst:PushEvent("losttarget")            
				
				if self.target:HasTag("player") then
					_G.UnMark(self.inst)
				end
				
                self:SetTarget(nil)
            end
        end
    end
end

function Combat:ValidateTarget()
    if self.target then
		if self:IsValidTarget(self.target) then
			return true
		else
			if self.target:HasTag("player") then
				_G.UnMark(self.inst)
			end
			
			self:SetTarget(nil)
		end
    end
end

function Combat:GiveUp()
    if self.inst.components.talker then
        local str = self:GetGiveUpString(self.target)
        if str then
            self.inst.components.talker:Say(str)
        end
        
    end

    if METRICS_ENABLED and GetPlayer() == self.target then
        FightStat_GaveUp(self.inst)
    end

    self.inst:PushEvent("giveuptarget", {target = self.target})
    if self.target then
		self.lasttargetGUID = self.target.GUID
    end
	
	if self.target:HasTag("player") then
		_G.UnMark(self.inst)
	end
	
    self.target = nil
    
end

function Follower:StopFollowing()
	if self.inst:IsValid() then
		self.inst:PushEvent("loseloyalty", {leader=self.inst.components.follower.leader})
		
		if self.inst:HasTag("bf_friendly") then 
			_G.UnMark(self.inst)
		end
		
		self.inst.components.follower:SetLeader(nil)
		self:StopLeashing()
	end
end

function _G.MakeGreen(target)
	target.AnimState:SetAddColour(_G.FriendlyColor.r, _G.FriendlyColor.g, _G.FriendlyColor.b, 1)
end

function _G.MakeRed(target)
	target.AnimState:SetAddColour(_G.EnemyColor.r, _G.EnemyColor.g, _G.EnemyColor.b, 1)
end

function _G.MakeNormal(target)
	target.AnimState:SetAddColour(0, 0, 0, 1)
end

function _G.MarkFriend(target)
	if target:HasTag("bf_enemy") then 
		target:RemoveTag("bf_enemy")
	end
		target:AddTag("bf_friendly")
	
	_G.MakeGreen(target)
end

function _G.MarkEnemy(target)
	if target:HasTag("bf_friendly") then 
		target:RemoveTag("bf_friendly")
	end
	
	target:AddTag("bf_enemy")
	
	_G.MakeRed(target)
end

function _G.UnMark(target)
	if target:HasTag("bf_friendly") then 
		target:RemoveTag("bf_friendly")
		_G.MakeNormal(target)
	end
	
	if target:HasTag("bf_enemy") then 
		target:RemoveTag("bf_enemy")
		_G.MakeNormal(target)
	end	
end

function _G.LostTarget(target)
	if target:HasTag("bf_enemy") then 
		if target.target and target.target:HasTag("player") then
			return
		else
			target:RemoveTag("bf_enemy")
			_G.MakeNormal(target)
		end
	end	
end

function InitMod()
	if config_FXStrength == "dim" then
		_G.FriendlyColor.g 	= .1
		_G.EnemyColor.r 	= .1
	elseif config_FXStrength == "moderate" then
		_G.FriendlyColor.g 	= .25
		_G.EnemyColor.r 	= .25
	elseif config_FXStrength == "bright" then
		_G.FriendlyColor.g 	= .4
		_G.EnemyColor.r 	= .4
	elseif config_FXStrength == "extreme" then
		_G.FriendlyColor.g 	= .6
		_G.EnemyColor.r 	= .6
	end
	
	--print(config_FriendlyColorChoice)
	if config_FriendlyColorChoice == "blue" then
		_G.FriendlyColor.b = _G.FriendlyColor.g + .2
		_G.FriendlyColor.g = 0
		
	end
	
	if config_EnemyColorChoice  == "yellow" then
		_G.EnemyColor.g = _G.EnemyColor.r
	end
	
	for k,v in pairs(GLOBAL.GetPlayer().components.leader.followers) do
		_G.MarkFriend(k)
    end
end

AddSimPostInit(InitMod)