
local function ActionButton(inst)

	local action_target = GLOBAL.FindEntity(inst, 6, function(guy) return (guy.components.edible and inst.components.eater:CanEat(guy)) or
		 													 (guy.components.workable and guy.components.workable.workable and inst.components.worker:CanDoAction(guy.components.workable.action)) end)

	if not inst.sg:HasStateTag("busy") and action_target then
		if (action_target.components.edible and inst.components.eater:CanEat(action_target)) then
			return GLOBAL.BufferedAction(inst, action_target, GLOBAL.ACTIONS.EAT)
		elseif action_target.components.workable.workable then
			return GLOBAL.BufferedAction(inst, action_target, action_target.components.workable.action)
		end
	end
end

local function LeftClickPicker(inst, target_ent, pos)
    if inst.components.combat:CanTarget(target_ent) then
        return inst.components.playeractionpicker:SortActionList({GLOBAL.ACTIONS.ATTACK}, target_ent, nil)
    end

	if target_ent and target_ent.components.edible and inst.components.eater:CanEat(target_ent) then
		return inst.components.playeractionpicker:SortActionList({GLOBAL.ACTIONS.EAT}, target_ent, nil)
	end

    if target_ent and target_ent.components.workable and target_ent.components.workable.workable and inst.components.worker:CanDoAction(target_ent.components.workable.action) then
        return inst.components.playeractionpicker:SortActionList({target_ent.components.workable.action}, target_ent, nil)
    end
end

local function RightClickPicker(inst, target_ent, pos)
	return {}
end

local function EnableActionButton()
	if not GetPlayer().components.worker then
		GetPlayer():AddComponent("worker")
	end
	GetPlayer().components.playercontroller.actionbuttonoverride = ActionButton
	GetPlayer().components.playeractionpicker.leftclickoverride = LeftClickPicker
	GetPlayer().components.playeractionpicker.rightclickoverride = RightClickPicker
end

local function SetBank(bank) GetPlayer().AnimState:SetBank(bank) end
local function SetBuild(build) GetPlayer().AnimState:SetBuild(build) end
local function Damage(damage) GetPlayer().components.combat:SetDefaultDamage(damage) end
local function ResetScale() GetPlayer().Transform:SetScale(1,1,1) end
local function Health(health) GetPlayer().components.health:SetMaxHealth(health) end
local function ResetCombat() GetPlayer().components.combat:SetRange(3) GetPlayer().components.combat:SetAreaDamage(nil) end
local function RunSpeed(runspeed) GetPlayer().components.locomotor.runspeed = runspeed end
local function WalkSpeed(walkspeed) GetPlayer().components.locomotor.walkspeed = walkspeed end

function Transform(mob)
	EnableActionButton()
	GetPlayer().components.eater.monsterimmune = true
	GetPlayer().components.sanity.dapperness = TUNING.DAPPERNESS_HUGE
	GetPlayer().components.talker:IgnoreAll()
	if not GetPlayer().components.follower and not GetPlayer().components.lootdropper then
		GetPlayer():AddComponent("follower")
		GetPlayer():AddComponent("lootdropper")
	end

	if mob == "camera" then
		--    GROUND = 64, -- See BpWorld.cpp (ocean walls)
		GetPlayer().Physics:SetCollisionGroup(2048)
		GetPlayer().Physics:ClearCollisionMask()
		GetPlayer().Physics:CollidesWith(64)

		Health(99999)
		Damage(0)
		SetBank("unknown")
		SetBuild("unknown")
		RunSpeed(100)
		WalkSpeed(100)
		GetPlayer().sounds =
		{
			walk = "dontstarve/beefalo/walk",
			grunt = "dontstarve/beefalo/grunt",
			yell = "dontstarve/beefalo/yell",
			swish = "dontstarve/beefalo/tail_swish",
			curious = "dontstarve/beefalo/curious",
			angry = "dontstarve/beefalo/angry",
		}
		GetPlayer().components.locomotor.triggerscreep = true
		GetPlayer().entity:AddDynamicShadow():SetSize( 0, 0 )
				GetPlayer().Transform:SetScale(1,1,1)

		GetPlayer():SetStateGraph("SGBeefalo")
		ResetCombat()
		GetPlayer().components.combat:SetRange(0)

	end

end


