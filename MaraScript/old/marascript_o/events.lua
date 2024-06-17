local file = {}

file.EVENTS = {
    ["onUpdate"] = "onUpdate",
    ["onLoad"] = "onLoad",
    ["onPlayerCellChange"] = "onPlayerCellChange",
    ["ObjectActivated"] = "ObjectActivated"
}

local registeredEvents = {}
for key, value in pairs(file.EVENTS) do
    registeredEvents[key] = {}
end

file.registerEvent = function(event, func)
    if file.EVENTS[event] then
        if not file[event] then
            file[event] = {}
        end
        table.insert(file[event], func)
    end
end


return file