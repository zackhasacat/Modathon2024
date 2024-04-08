local cam = require('openmw.interfaces').Camera
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local I = require('openmw.interfaces')
local storage = require("openmw.storage")
local async = require("openmw.async")
local input = require("openmw.input")
local camera = require("openmw.camera")

local cameraTarget = self

local function getPositionBehind(obj)
    local distance = 164
    local currentRotation = -obj.rotation.z
    currentRotation = currentRotation - math.rad(-90)
    local obj_x_offset = distance * math.cos(currentRotation + math.pi)
    local obj_y_offset = distance * math.sin(currentRotation + math.pi)
    local obj_x_position = obj.position.x + obj_x_offset
    local obj_y_position = obj.position.y + obj_y_offset
    return util.vector3(obj_x_position, obj_y_position, obj.position.z + 150)
end




local function onUpdate(dt)
    if (cameraTarget.id ~= self.id) then
        camera.setStaticPosition(getPositionBehind(cameraTarget))
        camera.setYaw(cameraTarget.rotation.z)
    end
end
local function setCameraTarget(target)
    if (target.id == self.id) then
        camera.setMode(camera.MODE.FirstPerson)
    else
        camera.setMode(camera.MODE.Static)
    end
    cameraTarget = target
end

return {
    interfaceName  = "SlaveScript",
    interface      = {
        version = 1,
        setCameraTarget = setCameraTarget,
    },

    engineHandlers = {
        onInit = onInit,
        onLoad = onLoad,
        onSave = onSave,
        onUpdate = onUpdate,
        onInactive = onInactive,
    },
    eventHandlers  = {
        AS_compshare = function (npc)
            I.UI.setMode(I.UI.MODE.Companion, { target = npc })
        end,
        onLoadEvent = onLoadEvent,
        setStat = setStat,
        setEquipment = setEquipment,
        setBadItems = setBadItems,
        equipItems = equipItems,
        findValidPlants = findValidPlants,
        findNextPlant = findNextPlant,
    }
}
