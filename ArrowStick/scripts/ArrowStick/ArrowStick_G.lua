local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, async = pcall(require, "openmw.async")
local anim = require('openmw.animation')
local function rotateArrow(data)
    local obj = data.obj
    data.obj:teleport(obj.cell,obj.position,data.rotation)
end
local function placeArrow(data)
    async:newUnsavableSimulationTimer(0.1,function()
    local id = data.id
    local pos = data.position
    local rot = data.rotation
    print(id,pos,rot)
    local newArrow = world.createObject(id)
    newArrow:teleport(world.players[1].cell,pos,rot)

    end)
end
return
{
    interfaceName = "ArrowStick",
    interface = {
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onPlayerAdded = onPlayerAdded,
    },
    eventHandlers = {
        rotateArrow = rotateArrow,
        placeArrow = placeArrow,
        firstApproach = firstApproach,
        checkInWhenDone = checkInWhenDone
    }
}
