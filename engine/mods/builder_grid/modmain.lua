-- Thanks to simplex for this clever memoized DST check!
local is_dst
local function IsDST()
    if is_dst == nil then
		-- test changing this to: (still need to test single-player)
        is_dst = GLOBAL.TheSim:GetGameID() == "DST"
        -- is_dst = GLOBAL.kleifileexists("scripts/networking.lua") and true or false
    end
    return is_dst
end

local function GetPlayer()
	if IsDST() then
		return GLOBAL.ThePlayer
	else
		return GLOBAL.GetPlayer()
	end
end

local KEY_CTRL = GLOBAL.KEY_CTRL
local Vector3 = GLOBAL.Vector3
local TheInput = GLOBAL.TheInput
local table = GLOBAL.table

local CTRL = GetModConfigData("CTRL")
local BUILDGRID = GetModConfigData("BUILDGRID")

local SMALLGRIDSIZE = GetModConfigData("SMALLGRIDSIZE")
local MEDGRIDSIZE = GetModConfigData("MEDGRIDSIZE")
local BIGGRIDSIZE = GetModConfigData("BIGGRIDSIZE")

local COLORS = GetModConfigData("COLORS")
local h = 1
local l = 1/8
local badcolor = Vector3(h, l, l)
local goodcolor = Vector3(l, h, l)
if COLORS == "redblue" then
	badcolor = Vector3(h, l, l)
	goodcolor = Vector3(l, l, h)
elseif COLORS == "blackwhite" then
	badcolor = Vector3(l, l, l)
	goodcolor = Vector3(h, h, h)
end

local HIDEPLACER = GetModConfigData("HIDEPLACER")
local HIDECURSOR = GetModConfigData("HIDECURSOR")
local REDUCECHESTSPACING = GetModConfigData("REDUCECHESTSPACING")
if REDUCECHESTSPACING then--and GLOBAL.rawget(GLOBAL, "SaveGameIndex") then
-- other geometry mods ignore the special case for chests that increases the spacing for them
-- in Builder:CanBuildAtPoint; however, reducing the built-in spacing by just a little bit
-- gives similar behavior in terms of which lattice points you can build the chest
	if IsDST() then
		local treasurechestrecipe = GLOBAL.GetValidRecipe('treasurechest')
		treasurechestrecipe.min_spacing = treasurechestrecipe.min_spacing - 0.1
	else
		AddPrefabPostInit("world", function()
			local treasurechestrecipe = GLOBAL.GetRecipe('treasurechest')
			treasurechestrecipe.min_spacing = treasurechestrecipe.min_spacing - 0.1
		end)
	end
		
	-- this should work when they fix recipe.lua
	-- local treasurechestrecipe = IsDST()
								-- and GLOBAL.GetValidRecipe('treasurechest')
								-- or  GLOBAL.GetRecipe('treasurechest')
	-- treasurechestrecipe.min_spacing = treasurechestrecipe.min_spacing - 0.1
end

PrefabFiles = {
	"buildgridplacer",
}
Assets = {
	Asset("ANIM", "anim/buildgridplacer.zip"),
}
AddPrefabPostInit("buildgridplacer")

----------placer-----
--#rezecib Rewrote this using the current DST OnUpdate as a base
local function PlacerPostInit(self)
	self.buildgrid = nil
	self.lastpt = nil
	self.baseinst = self.inst
	
	local function SetCursorVisibility(show)
		if GLOBAL.TheFrontEnd and GLOBAL.TheFrontEnd.screenstack
			and GLOBAL.TheFrontEnd.screenstack[1]
			and GLOBAL.TheFrontEnd.screenstack[1].controls
			and GLOBAL.TheFrontEnd.screenstack[1].controls.mousefollow
			and GLOBAL.TheFrontEnd.screenstack[1].controls.mousefollow.children
			then
			local cursor_object = nil
			for k,v in pairs(GLOBAL.TheFrontEnd.screenstack[1].controls.mousefollow.children) do
				if v then cursor_object = v end
			end
			if cursor_object then
				if show then
					if cursor_object.image then cursor_object.image:Show() end
					if cursor_object.quantity then cursor_object.quantity:Show() end
					if cursor_object.percent then cursor_object.percent:Show() end
				else
					if cursor_object.image then cursor_object.image:Hide() end
					if cursor_object.quantity then cursor_object.quantity:Hide() end
					if cursor_object.percent then cursor_object.percent:Hide() end
				end
			end
		end
	end
	
	local function MakeGridInst()	
		self.gridinst = GLOBAL.SpawnPrefab("buildgridplacer")	
		self.gridinst.AnimState:SetBank("buildgridplacer")
		self.gridinst.AnimState:SetBuild("buildgridplacer")
		self.gridinst.AnimState:PlayAnimation("anim", true)
		self.gridinst.AnimState:SetOrientation(GLOBAL.ANIM_ORIENTATION.Default)
		self.gridinst.Transform:SetScale(1.7,1.7,1.7)
	end
	
	local function testpoint(pt)
		local canbuild = self.testfn == nil or self.testfn(pt)--:Get())
		return canbuild, canbuild and goodcolor or badcolor
	end
		
	local function RefreshBuildGrid()
		for x,r in pairs(self.buildgrid) do
			for z,bgp in pairs(r) do
				local bgpt = Vector3(x, 0, z)
				local can_build, color = testpoint(bgpt)
				bgp.AnimState:SetAddColour(color.x, color.y, color.z, 0)
			end
		end
	end
	
	local function RemoveBuildGrid()
		if self.buildgrid then for x,r in pairs(self.buildgrid) do
			for z,e in pairs(r) do
				e:Remove()
			end
		end end
		self.buildgrid = nil
	end
	
	local OldOnUpdate = self.OnUpdate
	local function NewOnUpdate(self, dt)
		--#rezecib Need these here to let the rest of the code match Placer:OnUpdate for easy syncing
		local TheWorld = IsDST() and GLOBAL.TheWorld or GLOBAL.GetWorld()
		--#rezecib Restores the default game behavior by holding ctrl
		if CTRL ~= TheInput:IsKeyDown(KEY_CTRL) then
			RemoveBuildGrid()
			if self.gridinst then
				self.gridinst.AnimState:SetAddColour(0,0,0,0)
				self.gridinst.AnimState:SetMultColour(0,0,0,0)
			end
			self.baseinst.AnimState:SetMultColour(1,1,1,1)
			self.inst = self.baseinst
			SetCursorVisibility(true)
			return OldOnUpdate(self, dt)
		end
		local pt = nil --#rezecib Added to keep the pt location for the build grid
		local ThePlayer = GetPlayer()
		if ThePlayer == nil then
			return
		elseif not TheInput:ControllerAttached() then
			-- Mouse input
			pt = self.selected_pos or TheInput:GetWorldPosition() --#rezecib Removed local
			if self.snap_to_tile then
				pt = Vector3(TheWorld.Map:GetTileCenterPoint(pt:Get()))
			elseif self.snap_to_meters then
				pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			elseif self.snap_to_flood then 
				-- Flooding tiles exist at odd-numbered integer coordinates
				local center = Vector3(TheWorld.Flooding:GetTileCenterPoint(pt:Get()))
				pt.x = center.x
				pt.y = center.y
				pt.z = center.z
			else --#rezecib Added this block, everything else should match Placer:OnUpdate
				pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
			end
			
		else -- Controller input
			local offset = 1
			if self.recipe then 
				if self.recipe.distance then 
					offset = self.recipe.distance - 1
					offset = math.max(offset, 1)
				end 
			elseif self.invobject then 
				if self.invobject.components.deployable then 
					offset = self.invobject.components.deployable.deploydistance or offset
				end 
			end
			
			if self.snap_to_tile then
				--Using an offset in this causes a bug in the terraformer functionality while using a controller.
				pt = Vector3(ThePlayer.entity:LocalToWorldSpace(0,0,0)) --#rezecib Removed local
				pt = Vector3(TheWorld.Map:GetTileCenterPoint(pt:Get()))
			elseif self.snap_to_meters then
				pt = Vector3(ThePlayer.entity:LocalToWorldSpace(offset,0,0)) --#rezecib Removed local
				pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			elseif self.snap_to_flood then 
				pt = Vector3(ThePlayer.entity:LocalToWorldSpace(offset,0,0))
				local center = Vector3(TheWorld.Flooding:GetTileCenterPoint(pt:Get()))
				pt.x = center.x
				pt.y = center.y
				pt.z = center.z
			else
				pt = ThePlayer:GetPosition()
				pt = Vector3( pt.x+offset+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
			end
		end
		self.inst.Transform:SetPosition(pt:Get())	
		
		if self.fixedcameraoffset ~= nil then
			self.inst.Transform:SetRotation(self.fixedcameraoffset - GLOBAL.TheCamera:GetHeading()) -- rotate against the camera
		end
		
		local color = nil
		self.can_build, color = testpoint(self.inst:GetPosition())

		self.inst.AnimState:SetAddColour(color.x*2, color.y*2, color.z*2, 0)
		if HIDEPLACER and not self.snap_to_tile then
			if self.gridinst == nil then MakeGridInst() end
			self.gridinst.AnimState:SetAddColour(1,1,1,0)
			self.gridinst.AnimState:SetMultColour(1,1,1,1)
			self.baseinst.AnimState:SetAddColour(0,0,0,0)
			self.baseinst.AnimState:SetMultColour(0,0,0,0)
			self.inst = self.gridinst
		end
		if HIDECURSOR then
			SetCursorVisibility(false)
		end
		
		--#rezecib added everything below for build grid
		local function BuildGridPoint(x, z, bgp)
			-- print((bgp and "moved to" or "added"), x, z)
			if not bgp then bgp = GLOBAL.SpawnPrefab(self.placertype) end
			if not self.buildgrid[x] then self.buildgrid[x] = {} end
			self.buildgrid[x][z] = bgp
			local bgpt = Vector3(x, 0, z)
			bgp.Transform:SetPosition(bgpt:Get())
			local can_build, color = testpoint(bgpt)
			bgp.AnimState:SetAddColour(color.x, color.y, color.z, 0)
			if(self.placertype == "gridplacer") then
				bgp.AnimState:SetMultColour(.05, .05, .05, 0.05)
			end
		end
		
		local function RemoveBlock(lx, hx, ix, lz, hz, iz, removelist)
			if self.buildgrid == nil then return end
			if ix == 0 then ix = 1 end
			if iz == 0 then iz = 1 end
			for x = lx, hx, ix do
				for z = lz, hz, iz do
					local row = self.buildgrid[x]
					if row == nil then
						print("missing row:", x, z)
						--#rezecib this is to prevent crashes if it gets here
						RemoveBuildGrid()
						return
					end
					table.insert(removelist, row[z])
					self.buildgrid[x][z] = nil
				end
			end
		end
		
		local function AddBlock(lx, hx, ix, lz, hz, iz, removelist, i)
			for x = lx, hx, ix do
				for z = lz, hz, iz do
					BuildGridPoint(x, z, removelist[i])
					i = i + 1
				end
			end
			return i
		end
		
		local lastpt = self.lastpt
		self.lastpt = pt
		local hadgrid = self.buildgrid ~= nil
		if not hadgrid then self.buildgrid = {} end
		self.placertype = self.inst.prefab == "gridplacer" and "gridplacer" or "buildgridplacer"
		if self.placertype == "gridplacer" then
			self.inst.AnimState:SetAddColour(1,1,1,0)
		end
		if (not BUILDGRID) or 
			(hadgrid and lastpt and pt and lastpt.x == pt.x and lastpt.z == pt.z) then return end
		if pt and pt.x and pt.z then
			local d = 0.5
			local GRIDSIZE = SMALLGRIDSIZE
			if self.snap_to_meters then
				d = 1
				GRIDSIZE = MEDGRIDSIZE
			end
			if self.snap_to_flood then
				d = 2
				-- this shows the derivation, we're taking the average "size" of each of these,
				-- then scaling it to the new spacing, and rounding
				-- GRIDSIZE = math.floor((MEDGRIDSIZE*1 + BIGGRIDSIZE*4)/(2*2) + 0.5)
				GRIDSIZE = math.floor(MEDGRIDSIZE/4 + BIGGRIDSIZE + 0.5)
			end
			if self.snap_to_tile then
				d = 4
				GRIDSIZE = BIGGRIDSIZE
			end
			if hadgrid then
				local dx = (pt.x - lastpt.x)
				local sx = dx == 0 and 1 or dx/math.abs(dx)
				local dz = (pt.z - lastpt.z)
				local sz = dz == 0 and 1 or dz/math.abs(dz)
				local removelist = {}
				if math.abs(dx) > d*GRIDSIZE*2 or math.abs(dz) > d*GRIDSIZE*2 then
					--the old and new grids have no overlap, move all the points
					for x = lastpt.x - GRIDSIZE*d, lastpt.x + GRIDSIZE*d, d do
						for z = lastpt.z - GRIDSIZE*d, lastpt.z + GRIDSIZE*d, d do
							BuildGridPoint(x+dx, z+dz, self.buildgrid[x][z])
							self.buildgrid[x][z] = nil
						end
					end
				else
					-- removing these placers from buildgrid and adding them to the list
					if dx ~= 0 then RemoveBlock( -- x-side
						lastpt.x - sx*GRIDSIZE*d, pt.x - sx*(GRIDSIZE+1)*d, sx*d,
						pt.z - sz*GRIDSIZE*d, lastpt.z + sz*GRIDSIZE*d, sz*d,
						removelist
					) end
					if dz ~= 0 then RemoveBlock( -- z-side
						pt.x - sx*GRIDSIZE*d, lastpt.x + sx*GRIDSIZE*d, sx*d,
						lastpt.z - sz*GRIDSIZE*d, pt.z - sz*(GRIDSIZE+1)*d, sz*d,
						removelist
					) end
					if dx ~= 0 and dz ~= 0 then RemoveBlock( -- corner
						lastpt.x - sx*GRIDSIZE*d, pt.x - sx*(GRIDSIZE+1)*d, sx*d,
						lastpt.z - sz*GRIDSIZE*d, pt.z - sz*(GRIDSIZE+1)*d, sz*d,
						removelist
					) end
					
					-- moving the removed placers to the leading edges of the buildgrid
					local i = 1
					if dx ~= 0 then i = AddBlock( -- x-side
						pt.x + sx*GRIDSIZE*d, lastpt.x + sx*(GRIDSIZE+1)*d, -sx*d,
						lastpt.z + sz*GRIDSIZE*d, pt.z - sz*GRIDSIZE*d, -sz*d,
						removelist, i
					) end
					if dz ~= 0 then i = AddBlock( -- z-side
						lastpt.x + sx*GRIDSIZE*d, pt.x - sx*GRIDSIZE*d, -sx*d,
						pt.z + sz*GRIDSIZE*d, lastpt.z + sz*(GRIDSIZE+1)*d, -sz*d,
						removelist, i
					) end
					if dx ~= 0 and dz ~= 0 then i = AddBlock( -- corner
						pt.x + sx*GRIDSIZE*d, lastpt.x + sx*(GRIDSIZE+1)*d, -sx*d,
						pt.z + sz*GRIDSIZE*d, lastpt.z + sz*(GRIDSIZE+1)*d, -sz*d,
						removelist, i
					) end
				end

			else
				for bgx = -GRIDSIZE, GRIDSIZE do
					local x = pt.x + d*bgx
					for bgz = -GRIDSIZE, GRIDSIZE do
						local z = pt.z + d*bgz
						-- if bgx ~= 0 or bgz ~= 0 then
							BuildGridPoint(x, z)
						-- end
					end
				end			
			end
		end
		
		if self.buildgrid and self.buildgrid[pt.x] and self.buildgrid[pt.x][pt.z] then
			local addx, addy, addz, adda = self.buildgrid[pt.x][pt.z].AnimState:GetAddColour()
			if math.abs(color.x - addx) > 0.1 then
				RefreshBuildGrid()
			end
		end
	end
	self.OnUpdate = NewOnUpdate
	
	self.inst:ListenForEvent("onremove", function()
		RemoveBuildGrid()
		if self.gridinst then self.gridinst:Remove() end
	end)
end
AddComponentPostInit("placer", PlacerPostInit)

----------builder-----
--#rezecib Added this to make DST-compatible
-- for DST
local function BuilderReplicaPostConstruct(self)
	local OldCanBuildAtPoint = self.CanBuildAtPoint
	local function NewCanBuildAtPoint(self, pt, recipe, ...)
		if CTRL == TheInput:IsKeyDown(KEY_CTRL) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		return OldCanBuildAtPoint(self, pt, recipe, ...)
	end
	self.CanBuildAtPoint = NewCanBuildAtPoint
	local OldMakeRecipeAtPoint = self.MakeRecipeAtPoint
	local function NewMakeRecipeAtPoint(self, recipe, pt, ...)
		if CTRL == TheInput:IsKeyDown(KEY_CTRL) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		OldMakeRecipeAtPoint(self, recipe, pt, ...)
	end
	self.MakeRecipeAtPoint = NewMakeRecipeAtPoint
end

-- for single-player; don't add the rotation stuff
local function BuilderPostInit(self)
	local OldCanBuildAtPoint = self.CanBuildAtPoint
	local function NewCanBuildAtPoint(self, pt, recipe, ...)
		if CTRL == TheInput:IsKeyDown(KEY_CTRL) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		return OldCanBuildAtPoint(self, pt, recipe, ...)
	end
	self.CanBuildAtPoint = NewCanBuildAtPoint
	local OldMakeRecipe = self.MakeRecipe
	local function NewMakeRecipe(self, recipe, pt, onsuccess, ...)
		if pt and CTRL == TheInput:IsKeyDown(KEY_CTRL) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		OldMakeRecipe(self, recipe, pt, onsuccess, ...)
	end
	self.MakeRecipe = NewMakeRecipe
end

if IsDST() then
	AddClassPostConstruct("components/builder_replica", BuilderReplicaPostConstruct)
else
	AddComponentPostInit("builder", BuilderPostInit)
end

----------deployable-----
--#rezecib tore this from RoG's deployable component; the mouseover messes up the grid for
--  things that use default_test as their main CanDeploy reporter (e.g. tooth traps)
local function default_test(inst, pt)
	local tiletype = GLOBAL.GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GLOBAL.GROUND.IMPASSABLE
	if ground_OK then
		-- local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
		-- if MouseCharacter and not MouseCharacter:HasTag("player") then
			-- return false
		-- end
	    local ents = GLOBAL.TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, {'NOBLOCK', 'player', 'FX'}) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v.entity:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if GLOBAL.distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		return true
	end
	return false
end

--#rezecib Rewrote this a bit to no longer fully replace the old functions
-- instead, it just modifies the point that gets passed to them
local function DeployablePostInit(self)
	local function ShouldRound(self, deployer, player)
		local continue = false
		if IsDST() then
			if self.mode ~= GLOBAL.DEPLOYMODE.WALL and self.mode ~= GLOBAL.DEPLOYMODE.TURF then
				continue = true
			end
		else
			if self.placer == nil or (self.placer ~= "gridplacer"
							and self.placer:sub(1,5) ~= "wall_"
							and self.placer:sub(1,5) ~= "mech_")
			then
				continue = true
			end
		end
		if continue then
			return CTRL == TheInput:IsKeyDown(KEY_CTRL) and (player == nil or deployer == player)
		else	
			return false
		end
	end
	
	--#rezecib this only gets called on the host, so we need to modify inventoryitem too
	-- now that I've modified inventoryitem_replica, this may no longer be necessary
	local OldCanDeploy = self.CanDeploy
	if not IsDST() then
		OldCanDeploy = function(self, ...)
			if self.test then
				return self.test(self.inst, ...)
			else
				return default_test(self.inst, ...)
			end
			-- This is the vanilla version, but the Shipwrecked one above should be better?
			-- return self.test and self.test(self.inst, ...) or default_test(self.inst, ...)
		end
	end
	local function NewCanDeploy(self, pt, mouseover, ...)
		local player = GetPlayer()
		if ShouldRound(self, player, player) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		return OldCanDeploy(self, pt, nil, ...) --removing mouseover should help some DST things
	end
	self.CanDeploy = NewCanDeploy
	
	local OldDeploy = self.Deploy
	local function NewDeploy(self, pt, deployer, ...)
		local player = GetPlayer()
		if ShouldRound(self, deployer, player) then
			pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
		end
		return OldDeploy(self, pt, deployer, ...)
	end
	self.Deploy = NewDeploy
end
AddComponentPostInit("deployable", DeployablePostInit)

local function InventoryItemReplicaPostConstruct(self)
	local OldCanDeploy = self.CanDeploy
	local function NewCanDeploy(self, pt, mouseover, ...)
		local mode = self.classified and self.classified.deploymode:value() or nil
		if mode ~= GLOBAL.DEPLOYMODE.WALL and mode ~= GLOBAL.DEPLOYMODE.TURF then
			if CTRL == TheInput:IsKeyDown(KEY_CTRL) then
				pt = Vector3( pt.x+.25-(pt.x+.25)%.5, 0, pt.z+.25-(pt.z+.25)%.5)
			end
		end
		return OldCanDeploy(self, pt, nil, ...)
	end
	self.CanDeploy = NewCanDeploy
end
if IsDST() then
	AddClassPostConstruct("components/inventoryitem_replica", InventoryItemReplicaPostConstruct)
end

-- #rezecib Added this to fix planting on clients in DST
-- This feels really hackish...... but there doesn't seem to be a better way to do it,
--  since this is directly called from the monstrous PlayerController functions
if IsDST() then
	local OldSendRPCToServer = GLOBAL.SendRPCToServer
	local function SendRPCToServer(code, ...)
		local arg = {...}
		--#rezecib not the best solution to the CTRL check here, but... no good options :(
		if (CTRL == TheInput:IsKeyDown(KEY_CTRL))
			and (code == GLOBAL.RPC.ActionButton or code == GLOBAL.RPC.RightClick)
			and arg and arg[1] == GLOBAL.ACTIONS.DEPLOY.code then
			local ThePlayer = GLOBAL.ThePlayer
			if not (ThePlayer and ThePlayer.replica and ThePlayer.replica.inventory and
				ThePlayer.replica.inventory.classified and ThePlayer.replica.inventory.classified:GetActiveItem()
				and (ThePlayer.replica.inventory.classified:GetActiveItem():HasTag("wallbuilder") 
					or ThePlayer.replica.inventory.classified:GetActiveItem():HasTag("groundtile"))) then
				arg[2] = arg[2]+.25-(arg[2]+.25)%.5
				arg[3] = arg[3]+.25-(arg[3]+.25)%.5
			end
			OldSendRPCToServer(code, GLOBAL.unpack(arg))
		else
			OldSendRPCToServer(code, ...)
		end
	end
	GLOBAL.SendRPCToServer = SendRPCToServer
end