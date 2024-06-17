local storage = require("openmw.storage")
local types = require("openmw.types")
local playerSelf = require("openmw.self")
local playerStorage = storage.playerSection("SettingsNeedsZHAC")
local needBase = {
    current = 0,
    base = 0,
    decayRate = 0.1,
    name = "Base"

}

function needBase.updateStatusEffects(self)
    local threshold = self.current / self.base * 100
    if threshold > 80 and self.highValueAbilityId then
        types.Actor.spells(playerSelf):add(self.highValueAbilityId)
    else
        types.Actor.spells(playerSelf):remove(self.highValueAbilityId)
    end

    if threshold < 20 and self.lowValueAbilityId then
        types.Actor.spells(playerSelf):add(self.lowValueAbilityId)
    else
        types.Actor.spells(playerSelf):remove(self.lowValueAbilityId)
    end
end

function needBase.update(self, minutesPassed)
    self.current = self.current - ((self:getDecayRate()) * minutesPassed)
    self:updateStatusEffects()
end

function needBase.getBaseLevel(self)
    local valueCheck = playerStorage:get(self.name .. "base")
    if valueCheck then
        return valueCheck
    else
        return self.base
    end
end

function needBase.getDecayRate(self)
    local valueCheck = playerStorage:get(self.name .. "decay")
    if valueCheck then
        return valueCheck
    else
        return self.decayRate
    end
end

function needBase.setStatusAbilities(self, lowValueAbilityID, highValueAbilityID)
    --under 20 percent, player gets lowValueAbilityID, above 80 percent, they get highValueAbilityID
    self.lowValueAbilityId = lowValueAbilityID
    self.highValueAbilityId = highValueAbilityID
end

function needBase.getSettingItems(self)
    return
    {
        {
            key = self.name .. "base",
            renderer = "number",
            name = self.name .. " Base",
            default = self.baseOriginal
        },
        {
            key = self.name .. "decay",
            renderer = "number",
            name = self.name .. " Decay Rate",
            default = self.decayOriginal
        }
    }
end

function needBase.newNeed(name, base, decayRate, lowValueAbilityID, highValueAbilityID)
    local newNeed = {}
    for key, value in pairs(needBase) do
        newNeed[key] = value
    end
    local currentBase = playerStorage:get(newNeed.name .. "base")
    local currentDecay = playerStorage:get(newNeed.name .. "decay")
    newNeed.name = name
    if not currentBase then
        currentBase = base
    end
    if not currentDecay then
        currentDecay = decayRate
    end
    newNeed.lowValueAbilityId = lowValueAbilityID
    newNeed.highValueAbilityId = highValueAbilityID
    newNeed.base = currentBase
    newNeed.current = currentBase
    newNeed.baseOriginal = base
    newNeed.decayOriginal = decayRate
    playerStorage:set(newNeed.name .. "base", currentBase)
    print(newNeed.name .. "decay")
    playerStorage:set(newNeed.name .. "decay", currentDecay)
    newNeed.decayRate = currentDecay
    return newNeed, newNeed:getSettingItems()
end

function needBase.relieve(self, amount)
    self.current = self.current + amount
    if self.current > self:getBaseLevel() then
        self.current = self:getBaseLevel()
    end
    self:updateStatusEffects()
end

function needBase.save(self)
    local savedTable = {}

    for key, value in pairs(self) do
        if type(value) ~= "function" then
            savedTable[key] = value
        end
    end

    return savedTable
end

function needBase.load(data)
    local newNeed = {}
    for key, value in pairs(needBase) do
        newNeed[key] = value
    end

    for key, value in pairs(data) do
        newNeed[key] = value
    end
    return newNeed
end

return needBase
