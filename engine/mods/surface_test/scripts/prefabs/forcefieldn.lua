local assets=
{
--	Asset("ANIM", "anim/grayamulet.zip"),
--	Asset("ANIM", "anim/torso_grayamulet.zip"),
--	Asset("ATLAS", "images/inventoryimages/grayamulet.xml"),
--   Asset("IMAGE", "images/inventoryimages/grayamulet.tex"),
	
	Asset("ANIM", "anim/forcefieldn.zip"),
	Asset("ATLAS", "images/inventoryimages/forcefieldn.xml"),
    Asset("IMAGE", "images/inventoryimages/forcefieldn.tex"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

---GRAY

--[[local function onequip_gray(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_grayamulet", "purpleamulet")
    if inst.components.fueled then
        inst.components.fueled:StartConsuming()        
    end
  
end

local function onunequip_gray(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end
 
end]]

---FORCEFIELD

   local function forcefield_proc(inst)
		local owner = GetPlayer()
		inst.components.finiteuses:Use(1) 
		inst:AddTag("forcefield")
		owner.components.health:SetInvincible(true)
       -- owner.components.health.absorb = (1)
        local fx = SpawnPrefab("greenfieldfx")
        fx.entity:SetParent(owner.entity)
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
        end
        fx:ListenForEvent("blocked", fx_hitanim, owner)

        inst.active = true

        owner:DoTaskInTime(--[[Duration]] 15, function()
            fx:RemoveEventCallback("blocked", fx_hitanim, owner)
            fx.kill_fx(fx)
            if inst:IsValid() then
                inst:RemoveTag("forcefield")
				owner.components.health:SetInvincible(false)
            --    owner.components.health.absorb = (0)
                owner:DoTaskInTime(--[[Cooldown]] 4, function() inst.active = false end)
            end
        end)
    end


---COMMON FUNCTIONS

local function onfinished(inst)
    inst:Remove()
end

local function unimplementeditem(inst)
    local player = GetPlayer()
    player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_UNIMPLEMENTED"))
    if player.components.health.currenthealth > 1 then
        player.components.health:DoDelta(-player.components.health.currenthealth * 0.5)
    end

    if inst.components.useableitem then
        inst.components.useableitem:StopUsingItem()
    end
end

local function commonfn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   
    
    inst:AddComponent("inspectable")
	
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    
    return inst
	
end



local function forcefieldn(inst)
    local inst = commonfn(inst)
		
		inst.AnimState:SetBank("forcefieldn")
		inst.AnimState:SetBuild("forcefieldn")

        inst.AnimState:PlayAnimation("idle")
		inst.chargefuel = "RECHARGER"
		inst:AddComponent("activateforce")
		inst.components.activateforce.onWorking = forcefield_proc
		
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(5)
		inst.components.finiteuses:SetUses(5)
		inst.components.finiteuses:SetOnFinished(onfinished)
		
		inst.components.inventoryitem.imagename = "forcefieldn"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/forcefieldn.xml"  

    return inst
end



STRINGS.NAMES.FORCEFIELDN = "Damaged Forcefield"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.FORCEFIELDN = {	
	"Lightweight and durable ... when it works.",
	"Needs fuel from time to time.",
	"It can fall apart without energy.",
}

STRINGS.CHARACTERS.WX78.DESCRIBE.FORCEFIELDN = {	
	"K.I.N.G. AUTOMATON PROTECTION UNIT.",
}


return Prefab( "common/inventory/forcefieldn", forcefieldn, assets)
