local storage = require("openmw.storage")
local self = require("openmw.self")
local types = require("openmw.types")

local playerSettings = storage.globalSection("SettingsDebugMode")
local util = require("openmw.util")
local core = require("openmw.core")
local I = require("openmw.interfaces")
local badInv = nil
local badWait = -1
local nearby = require ("openmw.nearby")
local function onActive()


    local function distanceBetweenPos(vector1, vector2)

        --Quick way to find out the distance between two vectors.
        --Very similar to getdistance in mwscript
        local dx = vector2.x - vector1.x
        local dy = vector2.y - vector1.y
        local dz = vector2.z - vector1.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
if(self.recordId == "zhac_comptrigger") then
for index, value in ipairs(nearby.actors) do
    if(distanceBetweenPos(self.position,value.position) < 10 and value.type ~= types.Player) then
        core.sendGlobalEvent("CompShare",value)
        break
    end
end
    core.sendGlobalEvent("ZackUtilsDelete",self)

end
end

return {
    interfaceName  = "SlaveScript",
    interface      = {
        version = 1,
    },

    engineHandlers = {
        onLoad = onLoad,
        onSave = onSave,
        onUpdate = onUpdate,
        onActive = onActive,
    },
    eventHandlers  = {
        onLoadEvent = onLoadEvent,
        setStat = setStat,
        setEquipment = setEquipment,
        setBadItems = setBadItems,
        equipItems = equipItems,
    }
}