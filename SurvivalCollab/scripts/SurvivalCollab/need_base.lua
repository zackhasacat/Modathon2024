
local storage = require("openmw.storage")
local playerStorage = storage.playerSection("SettingsNeedsZHAC")
local needBase = {
    current = 0,
    base = 0,
    decayRate = 0.1,
    name = "Base"

}
function needBase.update(self, minutesPassed)
    self.current = self.current - ((self:getDecayRate()) * minutesPassed)
end

function needBase.getBaseLevel(self)
    local valueCheck =playerStorage:get(self.name .. "base")
    if valueCheck then
        return valueCheck
    else
        return self.base
    end
end


function needBase.getDecayRate(self)
    local valueCheck =playerStorage:get(self.name .. "decay")
    if valueCheck then
        return valueCheck
    else
        return self.decayRate
    end
end


function needBase.newNeed(name, base, decayRate)
    local newNeed = {}
    for key, value in pairs(needBase) do
        newNeed[key] = value
    end
    newNeed.name = name
    newNeed.base = base
    newNeed.current = base
    playerStorage:set(newNeed.name .. "base",base)
    print(newNeed.name .. "decay")
    playerStorage:set(newNeed.name .. "decay",decayRate)
    newNeed.decayRate = decayRate
    return newNeed
end
function needBase.relieve(self,amount)
    self.current = self.current + amount
    if self.current > self:getBaseLevel() then
        self.current = self:getBaseLevel()
    end
    
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
