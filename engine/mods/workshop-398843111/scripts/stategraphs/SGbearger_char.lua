require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.HAMMER, "attack"),
	ActionHandler(ACTIONS.GOHOME, "taunt"),
	ActionHandler(ACTIONS.PICKUP, "doshortaction"),
	ActionHandler(ACTIONS.PICK, "doshortaction"),
	ActionHandler(ACTIONS.HAMMER, "attack"),
	ActionHandler(ACTIONS.EAT, "eat_loop"),
	ActionHandler(ACTIONS.DROP, "doshortaction"),

}

local events =
{
	EventHandler("wakeup",
	function(inst)
		inst.sg:GoToState("wakeup")
	end),
}

local SHAKE_DIST = 40

local function ShakeIfClose(inst)

	inst.components.playercontroller:ShakeCamera(inst, "FULL", 0.4, 0.02, 1, SHAKE_DIST)

end


local function DoFootstep(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
		ShakeIfClose(inst)
end

local function DoFoleySounds(inst)

	for k,v in pairs(inst.components.inventory.equipslots) do
		if v.components.inventoryitem and v.components.inventoryitem.foleysound then
			inst.SoundEmitter:PlaySound(v.components.inventoryitem.foleysound)
		end
	end

    if inst.prefab == "wx78" then
        inst.SoundEmitter:PlaySound("dontstarve/movement/foley/wx78")
    end
end

local events=
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),

	EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("sleeping") then
			inst.sg:GoToState("taunt")
		end
		if inst.sg:HasStateTag("idle") then
			if data.eslot == EQUIPSLOTS.HANDS then
				inst.sg:GoToState("taunt")
			else
				inst.sg:GoToState("idle")
			end
        end
    end),
}

local states=
{
	State{
        name = "sleep",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_pre")
            inst.components.playercontroller:Enable(false)
            inst.components.health:SetInvincible(true)
        end,

        onexit=function(inst)
            inst.components.health:SetInvincible(false)
            inst.components.playercontroller:Enable(true)
        end,

    },

    State{
        name = "sleepin",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_loop")
            inst.components.locomotor:Stop()
            --inst.Controller:Enable(false)
            --inst.AnimState:Hide()
            inst:PerformBufferedAction()
        end,

        onexit= function(inst)
            --inst.Controller:Enable(true)
            --inst.AnimState:Show()
        end,

    },

	State{
        name = "wakeup",

        onenter = function(inst)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.components.health:SetInvincible(true)
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
            inst.components.health:SetInvincible(false)
        end,


        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("eat_loop")
                local timeout = math.random()+.5
                local ba = inst:GetBufferedAction()
                if ba and ba.target and ba.target:HasTag("honeyed") then
                    timeout = timeout*2
                end
                inst.sg:SetTimeout(timeout)
				inst:PerformBufferedAction()
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew") end),
        },

        ontimeout = function(inst)
            inst.last_eat_time = GetTime()
            inst.sg:GoToState("eat_pst")
        end,

    },

    State{
        name = "eat_pst",
        tags = {"busy"},

        onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("eat_pst")
        end,

        timeline=
        {
        },

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

	State{
        name = "doshortaction",
        tags = {"doing", "busy"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.sg:SetTimeout(6*FRAMES)
        end,


        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(10*FRAMES, function( inst )
            inst.sg:RemoveStateTag("doing")
            inst.sg:AddStateTag("idle")
            end),
			TimeEvent(35*FRAMES, function(inst)
				inst:PerformBufferedAction()
			end),
        },

        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
        },
    },

	State{
        name = "hit",
        tags = {"hit", "busy"},

        onenter = function(inst, cb)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end

                inst.AnimState:PlayAnimation("hit")
                inst.AnimState:PlayAnimation("standing_hit")
            end,

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst)
			--print(debugstack())
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local weapon = inst.components.combat:GetWeapon()
            local otherequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            if weapon then
                inst.AnimState:PlayAnimation("ground_pound")
            else
				inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh")
            end

            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end

        end,

        timeline=
        {
            TimeEvent(35*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) inst.sg:RemoveStateTag("abouttoattack") end),
            TimeEvent(36*FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
            TimeEvent(37*FRAMES, function(inst)
				if not inst.sg.statemem.slow then
					inst.sg:RemoveStateTag("attack")
				end
            end),
            TimeEvent(24*FRAMES, function(inst)
				if inst.sg.statemem.slow then
					inst.sg:RemoveStateTag("attack")
				end
            end),
			TimeEvent(20*FRAMES, function(inst)
				if not inst.sg.statemem.slow then
					inst.components.groundpounder:GroundPound()
				end
			end),
			TimeEvent(4*FRAMES, function(inst)
				if inst.sg.statemem.slow then
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack")
				end
			end),
		},

		events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
	},


	State{
            name = "run_start",
            tags = {"moving", "running", "canrotate"},

            onenter = function(inst)
				local weapon = inst.components.combat:GetWeapon()

                inst.components.locomotor:RunForward()
				local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_pre" or "charge_pre"
					if weapon then
						inst.AnimState:PlayAnimation(anim)
						inst.components.locomotor.runspeed = 10
						inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
					else
						inst.AnimState:PlayAnimation("walk_pre")
						inst.components.locomotor.runspeed = 6
					end
			end,

            events =
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("run") end ),
            },
        },

    State{
            name = "run",
            tags = {"moving", "running", "canrotate"},

            onenter = function(inst)
                local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_loop" or "charge_roar_loop"
                    local weapon = inst.components.combat:GetWeapon()
					if weapon then
						inst.AnimState:PlayAnimation(anim)
						inst.components.locomotor.runspeed = 10
						if not inst.SoundEmitter:PlayingSound("taunt") then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt") end
					else
						inst.AnimState:PlayAnimation("walk_loop")
						inst.components.locomotor.runpspeed = 6
					end

					inst.components.locomotor:RunForward()

				if inst.components.combat and inst.components.combat.target and math.random() < .5 then
                    inst:DoTaskInTime(math.random(13)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/grrrr") end)
                end
            end,

            events=
            {
                EventHandler("animqueueover", function(inst) inst.sg:GoToState("run") end ),
            },

            timeline=
            {
                TimeEvent(2*FRAMES, function(inst)
                    if inst.components.combat.target then
                        DoFootstep(inst)
                    end
                end),
                TimeEvent(18*FRAMES, function(inst)
                    if inst.components.combat.target then
                        DoFootstep(inst)
                    end
                end),
                TimeEvent(4*FRAMES, function(inst)
                    if not inst.components.combat.target then
                        DoFootstep(inst)
                    end
                end),
                TimeEvent(30*FRAMES, function(inst)
                    if not inst.components.combat.target then
                        DoFootstep(inst)
                    end
                end),
            },
        },

    State{
            name = "run_stop",
            tags = {"canrotate"},

            onenter = function(inst)
				local weapon = inst.components.combat:GetWeapon()
                inst.components.locomotor:Stop()
				local anim = (inst.components.combat.target and not inst.components.combat.target:HasTag("beehive")) and "charge_pst" or "charge_pst"
                DoFootstep(inst)
				if weapon then
                    inst.AnimState:PlayAnimation(anim)
				else
					inst.AnimState:PlayAnimation("walk_pst")
				end
			end,

            events=
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
            },
        },

	State{
        name="item_hat",
        tags = {"idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

	State{
        name="item_out",
        tags = {"idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

	State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")

            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
                inst:ClearBufferedAction()
                inst.components.knownlocations:RememberLocation("home", nil)
            end
        end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt") end),
		},

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

}

CommonStates.AddIdle(states)
--[[CommonStates.AddSleepStates(states,
{

	sleeptimeline =
    {
        --TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.grunt) end)
    },
})--]]
CommonStates.AddFrozenStates(states)

return StateGraph("deerclops", states, events, "idle", actionhandlers)
