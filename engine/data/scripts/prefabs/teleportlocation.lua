local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()

	inst:AddTag("teleportlocation")
    --[[Non-networked entity]]

	return inst
end

return Prefab("common/teleportlocation", fn)