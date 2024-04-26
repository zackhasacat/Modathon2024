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

function needBase.save(self)
    local savedTable = {}

    -- Iterate over all keys and values in the object
    for key, value in pairs(self) do
        -- Check if the value is not a function
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
