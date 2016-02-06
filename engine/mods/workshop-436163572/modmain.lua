local TheInput = GLOBAL.TheInput
GetPlayer = GLOBAL.GetPlayer

modimport "transformation.lua"

local MOBS = {"camera"}

local current = 0
local function SelectMob()
	if not GetPlayer().sg:HasStateTag("moving") then
		current = current + 1
		if current > #MOBS then
			current = 1
		end
		Transform(MOBS[current])
	end
end

local function Untransform()
	local name = GetPlayer().prefab
	if name ~= "waxwell" then
		GetPlayer().components.sanity.dapperness = 0
	end
	if name ~= "webber" then
		GetPlayer().components.eater.monsterimmune = false
		GetPlayer().components.locomotor.triggerscreep = true
	end
	GetPlayer().components.talker:StopIgnoringAll()
	GetPlayer().AnimState:SetBank("wilson")
	GetPlayer().AnimState:SetBuild(name)
	GetPlayer():SetStateGraph("SGwilson")
	GetPlayer():RemoveTag("spider")
	GetPlayer():RemoveTag("pig")
	GetPlayer():RemoveTag("monster")
	GetPlayer():RemoveTag("tree")
	GetPlayer():RemoveTag("leif")
	current = 0
	GetPlayer().Transform:SetScale(1,1,1)
	GetPlayer().entity:AddDynamicShadow():SetSize(1.3, .6)
	GetPlayer().components.locomotor.runspeed = 7
	GetPlayer().components.playercontroller.actionbuttonoverride = nil
	GetPlayer().components.playeractionpicker.leftclickoverride = nil
	GetPlayer().components.playeractionpicker.rightclickoverride = nil
end

---------------------------------------------------------

local function Taunt()
	GetPlayer().AnimState:PlayAnimation("unknown")
	GetPlayer().sg:GoToState("unknown")
end

local function Sleep()
	GetPlayer().AnimState:PlayAnimation("unknown")
	GetPlayer().sg:GoToState("unknown")
	GetPlayer().components.playercontroller:Enable(true)
end

TheInput:AddKeyDownHandler(GetModConfigData("transform_key"), SelectMob)
TheInput:AddKeyDownHandler(GetModConfigData("taunt_key"), Taunt)
TheInput:AddKeyDownHandler(GetModConfigData("sleep_key"), Sleep)
TheInput:AddKeyDownHandler(GetModConfigData("untransform_key"), Untransform)
