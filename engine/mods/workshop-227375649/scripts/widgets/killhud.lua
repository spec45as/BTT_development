local Widget = require "widgets/widget"
local TextWidget = require "widgets/text"
require "modsettings"

--local sett = LoadSettings('starvinggames', {user='Wilson', host='http://localhost:8080'})
local sett = LoadSettings('starvinggames', {user='Wilson', host='http://possession-dev.appspot.com'})

local function RequestKills(fn)	
	TheSim:QueryServer(sett.host..'/get_kill',fn,"GET")	
end

local function PostKill(str)
	if str ~= "file_load" then
		if not str then
			str = "Shenanigans"
		end
		
		local days = GetClock().numcycles or 0
		local death_str = "On day "..days..", "..sett.user.." was killed by "..str.."."
		TheSim:QueryServer(sett.host..'/post_kill',function() end,"POST", 'content="'..death_str..'"')		
	end
end

local KillHUD = Class(Widget, function(self)
	Widget._ctor(self, "Kill HUD")
	scheduler:ExecutePeriodic(5, function() RequestKills(function(result, is_successful, result_code) self:UpdateKills(result, is_successful, result_code) end) end)
	self.kill_texts = {}
	for i = 1,5 do
		local kt = self:AddChild(TextWidget(UIFONT, 25))
		kt:SetPosition(-150, 280 - i * 25)
		self.kill_texts[i] = kt
	end
	
	GetPlayer():ListenForEvent( "death", function(inst, data) PostKill(data.cause) end)	
end)

function KillHUD:UpdateKills(result, is_successful, result_code)
	if is_successful then
		local kti = 1
		for i in string.gmatch(result, "[^\?]+") do
			local kt = self.kill_texts[kti]
			kt:SetString(i)
			kti = kti + 1
		end
	end
end

GetPlayer():DoTaskInTime( 0, function() 
	local controls = GetPlayer().HUD.controls
	controls.bottomright_root:AddChild(KillHUD())
	end)

return KillHUD
