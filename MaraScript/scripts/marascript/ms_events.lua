local file = {}
local player
local objects = require("scripts.marascript.ms_objects")
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

file.baseonUpdate = function (dt,follow)
    
end

return file