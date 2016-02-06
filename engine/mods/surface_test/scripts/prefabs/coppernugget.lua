local assets=
{
	Asset("ANIM", "anim/coppernugget.zip"),
	Asset("ATLAS", "images/inventoryimages/coppernugget.xml"),	-- Atlas for inventory TEX
    Asset("IMAGE", "images/inventoryimages/coppernugget.tex"),	-- TEX for inventory
}

local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("coppernugget")
    inst.AnimState:SetBuild("coppernugget")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 2
   
    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")
    
	--inst:AddComponent("extractable")
      --  inst.components.extractable.product = "goldnugget"
		
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "coppernugget"	-- Use our TEX sprite
    inst.components.inventoryitem.atlasname = "images/inventoryimages/coppernugget.xml"	-- here's the atlas for our tex
	
    return inst
end

STRINGS.NAMES.COPPERNUGGET = "Copper Nugget"

-- Randomizes the inspection line upon inspection.
STRINGS.CHARACTERS.GENERIC.DESCRIBE.COPPERNUGGET = {	
	"Now don't shine...",
	"I got it strengthen somehow...",
}

STRINGS.CHARACTERS.WX78.DESCRIBE.COPPERNUGGET = {	
	"MINERAL.",

}

return Prefab( "common/inventory/coppernugget", fn, assets) 
