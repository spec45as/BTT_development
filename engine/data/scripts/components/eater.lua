local function clearcaneat(self, caneat)
    for i, v in ipairs(caneat) do
        self.inst:RemoveTag((type(v) == "table" and v.name or v).."_eater")
    end
end

local function oncaneat(self, caneat, old_caneat)
    if old_caneat ~= nil then
        clearcaneat(self, old_caneat)
    end
    if caneat ~= nil then
        for i, v in ipairs(caneat) do
            self.inst:AddTag((type(v) == "table" and v.name or v).."_eater")
        end
    end
end

local Eater = Class(function(self, inst)
    self.inst = inst
    self.eater = false
    self.strongstomach = false
    self.preferseating = { FOODGROUP.OMNI }
    self.caneat = { FOODGROUP.OMNI }
    self.oneatfn = nil
    self.lasteattime = nil
    self.ignoresspoilage = false
    self.eatwholestack = false
end,
nil,
{
    caneat = oncaneat,
})

function Eater:OnRemoveFromEntity()
    clearcaneat(self, self.caneat)
end

function Eater:SetDiet(caneat, preferseating)
    self.caneat = caneat
    self.preferseating = preferseating or caneat
end

function Eater:TimeSinceLastEating()
    return self.lasteattime ~= nil and GetTime() - self.lasteattime or nil
end

function Eater:HasBeen(time)
    return self.lasteattime == nil or self:TimeSinceLastEating() >= time
end

function Eater:OnSave()
    return self.lasteattime ~= nil
        and {
                time_since_eat = self:TimeSinceLastEating(),
            }
        or nil
end

function Eater:OnLoad(data)
    if data.time_since_eat then
        self.lasteattime = GetTime() - data.time_since_eat
    end
end

function Eater:SetCanEatHorrible()
    table.insert(self.preferseating, FOODTYPE.HORRIBLE)
    table.insert(self.caneat, FOODTYPE.HORRIBLE)
    self.inst:AddTag(FOODTYPE.HORRIBLE.."_eater")
end

function Eater:SetCanEatGears()
    table.insert(self.preferseating, FOODTYPE.GEARS)
    table.insert(self.caneat, FOODTYPE.GEARS)
    self.inst:AddTag(FOODTYPE.GEARS.."_eater")
end

function Eater:SetCanEatRaw()
    table.insert(self.preferseating, FOODTYPE.RAW)
    table.insert(self.caneat, FOODTYPE.RAW)
    self.inst:AddTag(FOODTYPE.RAW.."_eater")
end

function Eater:SetOnEatFn(fn)
    self.oneatfn = fn
end

function Eater:DoFoodEffects(food)
    return not (self.strongstomach and food:HasTag("monstermeat"))
end

function Eater:GetEdibleTags()
    local tags = {}
    for i, v in ipairs(self.caneat) do
        if type(v) == "table" then
            for i2, v2 in ipairs(v.types) do
                table.insert(tags, "edible_"..v2)
            end
        else
            table.insert(tags, "edible_"..v)
        end
    end
    return tags
end

function Eater:Eat(food)
    -- This used to be CanEat. The reason for two checks is to that special diet characters (e.g.
    -- wigfrid) can TRY to eat all foods (they get the actions for it) but upon actually put it in 
    -- their mouth, they bail and "spit it out" so to speak.
    if self:PrefersToEat(food) then
        if self.inst.components.health ~= nil and
            (food.components.edible.healthvalue >= 0 or self:DoFoodEffects(food)) then
            local delta = food.components.edible:GetHealth(self.inst)
            if delta ~= 0 then
                self.inst.components.health:DoDelta(delta, nil, food.prefab)
            end
        end

        if self.inst.components.hunger ~= nil then
            local delta = food.components.edible:GetHunger(self.inst)
            if delta ~= 0 then
                self.inst.components.hunger:DoDelta(delta)
            end
        end

        if self.inst.components.sanity ~= nil and
            (food.components.edible.sanityvalue >= 0 or self:DoFoodEffects(food)) then
            local delta = food.components.edible:GetSanity(self.inst)
            if delta ~= 0 then
                self.inst.components.sanity:DoDelta(delta)
            end
        end

        if self.inst.components.beaverness ~= nil then
            local delta = food.components.edible:GetWoodiness(self.inst)
            if delta ~= 0 then
                self.inst.components.beaverness:DoDelta(delta)
            end
        end

        self.inst:PushEvent("oneat", { food = food })
        if self.oneatfn ~= nil then
            self.oneatfn(self.inst, food)
        end

        if food.components.edible ~= nil then
            food.components.edible:OnEaten(self.inst)
        end

        if food:IsValid() then --might get removed in OnEaten...
            if not self.eatwholestack and food.components.stackable ~= nil then
                food.components.stackable:Get():Remove()
            else
                food:Remove()
            end
        end

        self.lasteattime = GetTime()

        return true
    end
end

function Eater:TestFood(food, testvalues)
    if food ~= nil and food.components.edible ~= nil then
        for i, v in ipairs(testvalues) do
            if type(v) == "table" then
                for i2, v2 in ipairs(v.types) do
                    if food:HasTag("edible_"..v2) then
                        return true
                    end
                end
            elseif food:HasTag("edible_"..v) then
                return true
            end
        end
    end
end

function Eater:PrefersToEat(inst)
    return self:TestFood(inst, self.preferseating)
end

function Eater:CanEat(inst)
    return self:TestFood(inst, self.caneat)
end

return Eater
