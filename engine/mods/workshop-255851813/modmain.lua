Assets = {}

require = GLOBAL.require
require "signplus/signbuffered"

local function TweakSign(inst)
	local l = inst.entity:AddLabel()
	inst.Label:SetFontSize(16)
	inst.Label:SetFont(GLOBAL.BODYTEXTFONT)
	inst.Label:SetPos(0, 1, 0)
	inst.Label:SetText("")
	inst.Label:SetColour(255/255,255/255,255/255)
	inst.Label:Enable(false)

	inst:AddComponent("signdata")

	function inst:CheckLabel()
		if inst.Label and inst.components and inst.components.signdata and inst.components.signdata.UpdateLabel then
			inst.components.signdata:UpdateLabel()
		end
	end
	local world = GLOBAL.GetWorld()

	inst:DoTaskInTime( 0.1, function() 
		inst:ListenForEvent( "dusktime", 	function() inst:CheckLabel() 	end, world)
		inst:ListenForEvent( "daytime", 	function() inst:CheckLabel() 	end, world)
		inst:ListenForEvent( "nighttime", 	function() inst:CheckLabel() 	end, world)
		inst:ListenForEvent( "clocktick", 	function() inst:CheckLabel() 	end, world)
	end)
end

local function TweakChest(inst)
	TweakSign(inst)
	inst.components.signdata.nolmb = true
end

AddPrefabPostInit("homesign", TweakSign)
AddPrefabPostInit("redsign", TweakSign)
AddPrefabPostInit("bluesign", TweakSign)
AddPrefabPostInit("greensign", TweakSign)
AddPrefabPostInit("pinksign", TweakSign)

AddPrefabPostInit("icebox", TweakChest)
AddPrefabPostInit("treasurechest", TweakChest)
AddPrefabPostInit("pandoraschest", TweakChest)
AddPrefabPostInit("skullchest", TweakChest)
AddPrefabPostInit("minotaurchest", TweakChest)
AddPrefabPostInit("cellar", TweakChest)
AddPrefabPostInit("dragonflychest", TweakChest)
AddPrefabPostInit("bluebox", TweakChest)	-- TARDIS mod

--SW
AddPrefabPostInit("luggagechest", TweakChest)
AddPrefabPostInit("octopuschest", TweakChest)
