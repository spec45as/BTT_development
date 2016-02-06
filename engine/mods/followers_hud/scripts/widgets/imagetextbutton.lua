local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Button = require "widgets/button"
local Image = require "widgets/image"

local ImageTextButton = Class(Button, function(self, atlas, normal)
    Button._ctor(self, "ImageTextButton")

    if not atlas then
        atlas = atlas or "images/ui.xml"
        normal = normal or "button.tex"
    end

    self.image = self:AddChild(Image())
    self.image:MoveToBack()

    self.atlas = atlas
	self.image_normal = normal

    self.commandtext = self:AddChild(Text(UIFONT, 80))
    self.commandtext:SetHAlign(ANCHOR_MIDDLE)
    self.commandtext:SetPosition(20, -300, 0)

    self.commandtext:Hide()
    self.image:SetTexture(self.atlas, self.image_normal)
end)

function ImageTextButton:ChangeImage(newatlas, newnormal)

    self.atlas = newatlas
    self.image_normal = newnormal
    self.image:SetTexture(self.atlas, self.image_normal)

end

function ImageTextButton:OnGainFocus()
	ImageTextButton._base.OnGainFocus(self)
    if self:IsEnabled() then
        self.commandtext:Show()
    	self.image:SetTexture(self.atlas, self.image_normal)
	end

    if self.image_normal == self.image_normal then
        self.image:SetScale(1.2,1.2,1.2)
    end

end

function ImageTextButton:OnLoseFocus()
	ImageTextButton._base.OnLoseFocus(self)
    if self:IsEnabled() then
        self.commandtext:Hide()
    	self.image:SetTexture(self.atlas, self.image_normal)
	end

    if self.image_normal == self.image_normal then
        self.image:SetScale(1,1,1)
    end
end

function ImageTextButton:GetSize()
    return self.image:GetSize()
end

return ImageTextButton