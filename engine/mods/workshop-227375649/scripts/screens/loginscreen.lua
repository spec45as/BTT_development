require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Spinner = require "widgets/spinner"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local PopupDialogScreen = require "screens/popupdialog"

local UI_ATLAS = "images/ui.xml"
local EMAIL_VALID_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@!#$%&'*+-/=?^_`{|}~"
local EMAIL_MAX_LENGTH = 254 -- http://tools.ietf.org/html/rfc5321#section-4.5.3.1
local MIN_AGE = 3 -- ages less than this prompt error message, eg. if they didn't change the date at all

local LoginScreen = Class(Screen, function(self)
	Screen._ctor(self, "LoginScreen")

	self:DoInit()

end)

function LoginScreen:OnControl(control, down)
	if LoginScreen._base.OnControl(self, control, down) then return true end

	if not down and control == CONTROL_CANCEL then
		self:Close()
		return true
	end
end

local sett = LoadSettings('starvinggames', {user='Wilson'})

function LoginScreen:OnBecomeActive()
	LoginScreen._base.OnBecomeActive(self)

	self.edit:SetFocus()
	self.edit:SetEditing(true)
	SetPause(true,'Login')
end

function LoginScreen:Accept()
	sett.user = self.edit:GetString()
	SaveSettings('starvinggames', sett)
	self:Close()
end

function LoginScreen:Close()
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen(self)
	self.edit:SetEditing(false)
	SetPause(false)
	IsLoginActivated = false
end

function LoginScreen:DoInit()

	TheInput:EnableDebugToggle(false)

	self.maxYear = tonumber(os.date("%Y"))
	self.minYear = self.maxYear - 130

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)	
    
	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)
	
	self.root = self.proot:AddChild(Widget("ROOT"))
    --self.root:SetPosition(-RESOLUTION_X/2,-RESOLUTION_Y/2,0)
    

	--throw up the background
    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.6, 2, 1)    

    local title_size = 300
    local title_offset = 120

    self.title = self.root:AddChild(Text(TITLEFONT, 50))

    self.title:SetString("Please enter a user name")
    self.title:SetHAlign(ANCHOR_MIDDLE)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	--self.title:SetRegionSize( title_size, 50 )
    self.title:SetPosition(0, title_offset, 0)


	local label_width = 200
	local label_height = 50
	local label_offset = 275

	local space_between = 30
	local height_offset = 60

	local email_fontsize = 30

	local edit_width = 550
	local edit_bg_padding = 60

    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.edit = self.root:AddChild( TextEdit( BODYTEXTFONT, email_fontsize, "" ) )
	self.edit:SetPosition( (edit_width * .5) - label_offset + space_between, height_offset, 0 )
	self.edit:SetRegionSize( edit_width, label_height )
	self.edit:SetHAlign(ANCHOR_LEFT)
	self.edit:SetFocusedImage( self.edit_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.edit:SetTextLengthLimit(EMAIL_MAX_LENGTH)
	self.edit:SetCharacterFilter( EMAIL_VALID_CHARS )

	local menu_items = {
		{ text = "Accept", cb = function() self:Accept() end },
		{ text = STRINGS.UI.EMAILSCREEN.CANCEL, cb = function() self:Close() end },
	}

	self.menu = self.root:AddChild(Menu(menu_items, 200, true))
	self.menu:SetPosition(-100, -130)

	self.edit:SetFocus()
end

return LoginScreen