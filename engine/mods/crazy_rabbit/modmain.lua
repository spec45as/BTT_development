PrefabFiles = {
	"pikbit",
}

local SPAWN_RADIUS = 10.0

SpawnPrefab = GLOBAL.SpawnPrefab

function SimInit(player)
	for i=1,5 do 		
		local angle = math.random() * 3.14159 * 2.0
		local x,y,z = player.Transform:GetWorldPosition()
		x = x + math.cos( angle ) * SPAWN_RADIUS
		z = z + math.sin( angle ) * SPAWN_RADIUS

		SpawnPrefab(PrefabFiles[math.random(#PrefabFiles)]).Transform:SetPosition( x, y, z ) 
	end
end

AddSimPostInit(SimInit)