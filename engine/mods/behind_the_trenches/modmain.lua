local main = GLOBAL.require("lua/main")

--[[
local easing = GLOBAL.require("easing")

Assets =
{
	Asset("IMAGE", "images/btt_main_menu.tex"),
	Asset("ATLAS", "images/btt_main_menu.xml"),
	Asset("IMAGE", "images/btt_logo.tex"),
	Asset("ATLAS", "images/btt_logo.xml"),
}
GLOBAL.require "screens/popupdialog"
GLOBAL.require "screens/newgamescreen"
GLOBAL.require "widgets/statusdisplays"
local Widget = GLOBAL.require "widgets/widget"
local TextButton = GLOBAL.require "widgets/textbutton"
local ImageButton = GLOBAL.require "widgets/imagebutton"
local Image = GLOBAL.require "widgets/image"
local easing = GLOBAL.require("easing")

local function UpdateMainScreen(self)
	self.updatename:SetString("Don't Starve: Behind The Trenches")

	--remove buttons
	if self.motd then
		if self.motd.button then
			self.motd.button:Kill()
		end
		self.motd:Kill()
	end
	if self.wilson then
		self.wilson:Kill()
	end
	if self.shield then
		self.shield:Kill()
	end
	if self.banner then
		self.banner:Kill()
	end
	if self.submenu then
		self.submenu:Kill()
	end
	if self.promo then
		self.promo:Kill()
	end
	if self.screecher then
		self.screecher:Kill()
	end
	if self.beta_reg then
		self.beta_reg:Kill()
	end
    if self.RoGUpgrade then
        self.RoGUpgrade:Kill()
    end
    if self.chester_upsell then
        self.chester_upsell:Kill()
    end
	
	self.bg:SetTexture("images/btt_main_menu.xml", "btt_main_menu.tex")

	self.logo = self.fixed_root:AddChild(Image("images/btt_logo.xml", "btt_logo.tex"))
    self.logo:SetVRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.logo:SetHRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.logo:SetPosition(400-70, 260-50, 0)

    local logoscale = 0.5
    self.logo:SetScale(logoscale,logoscale,logoscale)
end
AddClassPostConstruct("screens/mainscreen", UpdateMainScreen)
]]