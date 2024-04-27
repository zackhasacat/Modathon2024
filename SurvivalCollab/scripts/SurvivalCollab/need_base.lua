local needBase = {
    current = 0,
    base = 0,
    decayRate = 0.1,
    name = "Base"

}
function needBase.update(self, minutesPassed)
    self.current = self.current - ((self.decayRate) * minutesPassed)
end

function needBase.newNeed(name, base, decayRate)
    local newNeed = {}
    for key, value in pairs(needBase) do
        newNeed[key] = value
    end
    newNeed.name = name
    newNeed.base = base
    newNeed.current = base
    newNeed.decayRate = decayRate
    return newNeed
end
function needBase.relieve(self,amount)
    self.current = self.current + amount
    if self.current > self.base then
        self.current = self.base
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
