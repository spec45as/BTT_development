local Widget = require "widgets/widget"
local TextWidget = require "widgets/text"
local LoginScreen  = require "screens/loginscreen"

require "modsettings"

IsLoginActivated  = false

local sett = LoadSettings('starvinggames', {user='Wilson'})

local Login = Class(Widget, function(self)
	Widget._ctor(self, "Login")
	self.text = self:AddChild(TextWidget(UIFONT, 25))
	self.text:SetPosition(-1350, 800)
	self.text:SetString( 'User '..sett.user )
	self:StartUpdating()
	self.user = sett.user
end)

function Login:OnUpdate()
	if TheInput:IsKeyDown(KEY_L) and TheInput:IsKeyDown(KEY_ALT) and not IsLoginActivated then
		IsLoginActivated = true
		TheFrontEnd:PushScreen(LoginScreen())
	end
	if self.user ~= sett.user then
		self.user = sett.user
		self.text:SetString( 'User '..sett.user )
	end
end

GetPlayer():DoTaskInTime( 0, function() 
	local controls = GetPlayer().HUD.controls
	controls.bottomright_root:AddChild(Login())
	end)

return Login
