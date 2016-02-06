local ACTIONS = GLOBAL.ACTIONS
local STRINGS = GLOBAL.STRINGS
ActionHandler = GLOBAL.ActionHandler
Vector3 = GLOBAL.Vector3

--[[local function Charge(FiniteUses)
	function FiniteUses:Recharge(num)
		self:SetUses(self.current + (num or 1))
	end
end

AddComponentPostInit("finiteuses", Charge)]]




GLOBAL.STRINGS.ACTIONS.ACTIVATEFORCE = "Activate"
GLOBAL.STRINGS.ACTIONS.CHARGER = "Charge"

function ForcefieldSimPostInit()

ACTIONS.ACTIVATEFORCE = GLOBAL.Action()
ACTIONS.ACTIVATEFORCE.fn = function(act)
 local tar = act.target or act.invobject
  if tar and tar.components.activateforce then
        tar.components.activateforce:Working(tar)
        return true
    end
end

ACTIONS.CHARGER = GLOBAL.Action(2, true, true)
ACTIONS.CHARGER.fn = function(act)
	if act.target and act.invobject and act.invobject.components.charger then
		return act.invobject.components.charger:Docharge(act.target, act.doer)
	end
end



for k,v in pairs(ACTIONS) do
	 if k == "ACTIVATEFORCE" or "CHARGER" then
    		v.str = STRINGS.ACTIONS[k] or "ACTION"
   		 v.id = k
	 end
end 

-- required to extract animation

local function addActionHandler(SGname, action, state, condition)
	actionHandler = GLOBAL.ActionHandler(action, state, condition)
	for k,v in pairs(GLOBAL.SGManager.instances) do	
		if(k.sg.name == SGname) then
			k.sg.actionhandlers[action] = actionHandler
			break
		end
	end 
end

local function addState(SGname, state)
	 for k,v in pairs(GLOBAL.SGManager.instances) do	
		if(k.sg.name == SGname) then
			k.sg.states[state.name] =  state
			break
		end
	 end
end

-- Activate anim and sound

addActionHandler("wilson", GLOBAL.ACTIONS.ACTIVATEFORCE, "activateforce")

local activateforce = GLOBAL.State{
        name = "activateforce",
        tags = {"doing"},
        
        onenter = function(inst, timeout)
            
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod", "make")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
            inst:PerformBufferedAction()
        
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("make")
        end, 
    }

    addState("wilson", activateforce)
	end
AddSimPostInit(ForcefieldSimPostInit)