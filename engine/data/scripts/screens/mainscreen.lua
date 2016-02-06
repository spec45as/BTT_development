local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local WorldGenScreen = require "screens/worldgenscreen"
local PopupDialogScreen = require "screens/popupdialog"
local PlayerHud = require "screens/playerhud"
local LoadGameScreen = require "screens/loadgamescreen"
local CreditsScreen = require "screens/creditsscreen"
local ModsScreen = require "screens/modsscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local MovieDialog = require "screens/moviedialog"

local ControlsScreen = require "screens/controlsscreen"
local OptionsScreen = require "screens/optionsscreen"
local BroadcastingOptionsScreen = require "screens/broadcastingoptionsscreen"

--local RoGUpgrade = require "widgets/rogupgrade"

--local BetaRegistration = require "widgets/betaregistration"

local rcol = RESOLUTION_X/2 -200
local lcol = -RESOLUTION_X/2 +200

local bottom_offset = 60

local MainScreen = Class(Screen, function(self, profile)
	Screen._ctor(self, "MainScreen")
    self.profile = profile
	self.log = true
	self:AddEventHandler("onsetplayerid", function(...) self:OnSetPlayerID(...) end)
	self:DoInit() 
	self.menu.reverse = true
	self.default_focus = self.menu
    self.music_playing = false
end)


function MainScreen:DoInit( )
	STATS_ENABLE = true
	TheFrontEnd:GetGraphicsOptions():DisableStencil()
	TheFrontEnd:GetGraphicsOptions():DisableLightMapComponent()
	
	TheInputProxy:SetCursorVisible(true)
	self.bg = self:AddChild(Image("images/btt/btt_main_menu.xml", "btt_main_menu.tex"))

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    
    
    self.fixed_root = self:AddChild(Widget("root"))
    self.fixed_root:SetVAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetHAnchor(ANCHOR_MIDDLE)
    self.fixed_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.right_col = self.fixed_root:AddChild(Widget("right"))
	self.right_col:SetPosition(rcol, 0)

	self.left_col = self.fixed_root:AddChild(Widget("left"))
	self.left_col:SetPosition(lcol, 0)


	self.menu = self.right_col:AddChild(Menu(nil, 70))
	self.menu:SetPosition(0, -120, 0)
	self.menu:SetScale(.8)
   
   	self.logo = self.fixed_root:AddChild(Image("images/btt/btt_logo.xml", "btt_logo.tex"))
    --self.logo:SetVRegPoint(GLOBAL.ANCHOR_MIDDLE)
    --self.logo:SetHRegPoint(GLOBAL.ANCHOR_MIDDLE)
    self.logo:SetPosition(-200-70, 210-50, 0)

    local logoscale = 0.75
    self.logo:SetScale(logoscale,logoscale,logoscale)
	
	local PopupDialogScreen = require("screens/popupdialog")
	local ImageButton = require("widgets/imagebutton")
	--focus moving
		
	self:MainMenu()
	self.menu:SetFocus()
end

function MainScreen:OnSetPlayerID(playerid)
	if self.playerid then
		self.playerid:SetString(STRINGS.UI.MAINSCREEN.GREETING.. " "..playerid)
	end
end

function MainScreen:OnControl(control, down)
	if MainScreen._base.OnControl(self, control, down) then return true end
	
	if not down and control == CONTROL_CANCEL then
		if not self.mainmenu then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self:MainMenu()
			return true
		end
	end
end

function MainScreen:OnRawKey( key, down )
end

-- SUBSCREENS

function MainScreen:Settings()
	TheFrontEnd:PushScreen(OptionsScreen(false))
end

function MainScreen:Quit()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.ASKQUIT, STRINGS.UI.MAINSCREEN.ASKQUITDESC, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() RequestShutdown() end },{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MainScreen:OnExitButton()
		self:Quit()
end

function MainScreen:Refresh()
	self:MainMenu()
	TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
end

function MainScreen:ShowMenu(menu_items, posX, posY)
	self.mainmenu = false
	self.menu:Clear()
	
	for k = #menu_items, 1, -1  do
		local v = menu_items[k]
		self.menu:AddItem(v.text, v.cb, v.offset)
	end

	if posX and posY then
		self.menu:SetPosition(posX, posY, 0)
	end

	self.menu:SetFocus()
end

--[[
function MainScreen:OnModsButton()
	TheFrontEnd:PushScreen(ModsScreen(function(needs_reset)
		if needs_reset then
			SimReset()
		end

		TheFrontEnd:PopScreen()
	end))
end]]

function MainScreen:ResetProfile()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.RESETPROFILE, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:Reset() TheFrontEnd:PopScreen() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MainScreen:UnlockEverything()
	TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.MAINSCREEN.UNLOCKEVERYTHING, STRINGS.UI.MAINSCREEN.SURE, {{text=STRINGS.UI.MAINSCREEN.YES, cb = function() self.profile:UnlockEverything() TheFrontEnd:PopScreen() end},{text=STRINGS.UI.MAINSCREEN.NO, cb = function() TheFrontEnd:PopScreen() end}  }))
end

function MainScreen:OnCreditsButton()
	TheFrontEnd:GetSound():KillSound("FEMusic")
	TheFrontEnd:PushScreen( CreditsScreen() )
end
	

function MainScreen:CheatMenu()
end

function MainScreen:OnPlayButtonNACL()
	TheFrontEnd:PushScreen(
		PopupDialogScreen(STRINGS.UI.MAINSCREEN.PLAY_ON_STEAM, 
		 				  STRINGS.UI.MAINSCREEN.PLAY_ON_STEAM_DETAIL, {
							{text=STRINGS.UI.MAINSCREEN.NEWGO, cb = function() 
																		TheFrontEnd:PopScreen() 
																		TheSim:SendJSMessage("MainScreen:MoveToSteam")
																		TheFrontEnd:GetSound():KillSound("FEMusic")
																	end},
							{text=STRINGS.UI.MAINSCREEN.LATER, cb = function()
																		TheFrontEnd:PopScreen() 
																		TheFrontEnd:PushScreen(LoadGameScreen()) 
																		end}  
						}))	
end


function MainScreen:MainMenu()
	local function StartGame()
		TheFrontEnd:GetSound():KillSound("FEMusic")
		TheFrontEnd:Fade(false, 3, function()
			StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = "BTT_GAME"})
			SaveGameIndex:StartSurvivalMode("BTT_GAME", "wilson", {}, nil)
		end)
		--TheInputProxy:SetCursorVisible(false)
	end


	local menu_items = {}
	table.insert(menu_items, {text="New Battle", cb=StartGame, offset = Vector3(0,20,0)})

	table.insert(menu_items, {text="Settings", cb= function() self:Settings() end})
	table.insert( menu_items, {text=STRINGS.UI.MAINSCREEN.EXIT, cb= function() self:OnExitButton() end})

	
	self:ShowMenu(menu_items, 0, -120)
	self.mainmenu = true
end

function MainScreen:OnBecomeActive()
    MainScreen._base.OnBecomeActive(self)    
	self.menu:SetFocus()
end




local anims = 
{
	scratch = 1,
	hungry = 1,
	eat = 1,
}

function MainScreen:OnUpdate(dt)
	if PLATFORM == "PS4" and TheSim:ShouldPlayIntroMovie() then
		TheFrontEnd:PushScreen( MovieDialog("movies/forbidden_knowledge.mp4", function() TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic") end ) )
        self.music_playing = true
	elseif not self.music_playing then
        TheFrontEnd:GetSound():PlaySound("dontstarve/music/music_FE","FEMusic")
        self.music_playing = true
    end	
    
	self.timetonewanim = self.timetonewanim and self.timetonewanim - dt or 5 +math.random()*5
	if self.timetonewanim < 0 and self.wilson then
		self.wilson:GetAnimState():PushAnimation(weighted_random_choice(anims))		
		self.wilson:GetAnimState():PushAnimation("idle", true)		
		self.timetonewanim = 10 + math.random()*15
	end
end

function MainScreen:GetHelpText()
	if not self.mainmenu then
	    local controller_id = TheInput:GetControllerID()
	    return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
	else
		return ""
	end
end

return MainScreen
