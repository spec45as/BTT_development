local assets =
{
    Asset( "ANIM", "anim/ui_follower_commands.zip"),
} 

local prefabs =
{
    "followeritemslot",
}    

local slotpos = {Vector3(0,-140,0),}
local slotposMin = {Vector3(0,0,0),}

local function fn(Sim)

	local inst = CreateEntity()
    
	inst.entity:AddTransform()
    
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(6)
    inst.components.container.acceptsstacks = false
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_follower_commands"
    inst.components.container.widgetanimbuild = "ui_follower_commands"
    inst.components.container.side_widget = true
    inst.components.container.widgetpos = Vector3(0,-100,0)
    
    return inst

end

return Prefab( "followeritemslot", fn, assets) 
