--camera controls
local camera_paused = false

local PlayerHud = GLOBAL.require("screens/playerhud")
local oldfn = PlayerHud.OnRawKey
function PlayerHud:OnRawKey( key, down )
	if oldfn(self, key, down) then return true end
		
	--local camera = GLOBAL.TheCamera
	--local offset = {x = 0, y = 0, z = 0}	
	--local cameraSpeed = 10
		
	if down then
		--[[if key == GLOBAL.KEY_P then
			if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_CTRL) then
				camera_paused = not camera_paused
				GLOBAL.TheCamera:SetPaused(camera_paused)
			end
		else]]
		
		if key == GLOBAL.KEY_H then
			if GLOBAL.TheInput:IsKeyDown(GLOBAL.KEY_LCTRL) then
				GLOBAL.GetPlayer().HUD:Toggle()
			end
		end
		--[[
		if key == GLOBAL.KEY_W then	
			offset.y = cameraSpeed
		elseif key == GLOBAL.KEY_S then
			offset.y = -cameraSpeed
		elseif key == GLOBAL.KEY_A then
			offset.x = -cameraSpeed
		elseif key == GLOBAL.KEY_D then
			offset.x = cameraSpeed
		end
		
		camera.currentpos.x = camera.currentpos.x + offset.x
		camera.currentpos.y = camera.currentpos.y + offset.y
		camera.currentpos.z = camera.currentpos.z + offset.z
]]
	end
end

--zoom settings
local lerp = function(lower, upper, t)
   if t > 1 then t = 1 elseif t < 0 then t = 0 end
   return lower*(1-t)+upper*t 
end

function updateZoom(inst)
	inst.SetDefaultOriginal = inst.SetDefault
	
	inst.SetDefault = function(self,inst)
		self:SetDefaultOriginal(inst)
		self.maxdist = 120
		self.mindist = 5
    		self.mindistpitch = 20
    		self.maxdistpitch = 120--60
			self.fov = 45
	end
	
	inst.SnapOriginal = inst.Snap
	
	--[[оцепка камеры от вещей (фикс)
	inst.SetTarget = function(self,target)
		if not self.target or not target then return end
		self.target = target
		self.targetpos.x, self.targetpos.y, self.targetpos.z = self.target.Transform:GetWorldPosition()
	end]]
	
	inst.Snap = function(self,inst)
		self:SnapOriginal(inst)
		--self:SetTarget(nil)
		--self:SetPaused(true)
		--self.target = nil
		
		local percent_d = (self.distance - self.mindist) / (self.maxdist - self.mindist)
		curved_percent_d = math.sqrt(percent_d)*10
    		self.pitch = lerp(self.mindistpitch, self.maxdistpitch, curved_percent_d)
	end
	
			
end

AddGlobalClassPostConstruct("cameras/followcamera", "FollowCamera", updateZoom)

--revealer
local function revealer( inst )

	GLOBAL.RunScript("consolecommands")
	
	inst:DoTaskInTime( 0.001, function() 
	
				minimap = TheSim:FindFirstEntityWithTag("minimap")
				minimap.MiniMap:ShowArea(0,0,0,40000)
	end)

end

AddSimPostInit( revealer )