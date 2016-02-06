chestfunctions = require("scenarios/chestfunctions")
loot =
{
    {
        item = "forcefieldn",
        count = 1
    },
}

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, loot)
end



return
{
    OnCreate = OnCreate,
}
