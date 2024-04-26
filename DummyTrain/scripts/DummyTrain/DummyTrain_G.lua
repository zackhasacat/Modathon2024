local _, world = pcall(require, "openmw.world")
local _, async = pcall(require, "openmw.async")
local core = require("openmw.core")
local util = require("openmw.util")
local compatMode = core.API_REVISION == 29
local function rotateArrow(data)
    local obj = data.obj
    data.obj:teleport(obj.cell, obj.position, data.rotation)
end
local xrot
local xpos
local itemToMove
local function onItemActive(item)
 
end

local function onUpdate()
    if itemToMove and itemToMove.rotation ~= xrot then
        itemToMove:teleport(itemToMove.cell.name, itemToMove.position, xrot)
        itemToMove = nil
    end
end
local function placeArrow(data)
    async:newUnsavableSimulationTimer(0.1, function()
        local id = data.id
        local pos = data.position
        local rot = data.rotation
        local player = data.actor
        print(id, pos, rot)
        xrot = rot
        xpos = util.vector3(pos.x,pos.y,pos.z )
        local temppos = util.vector3(pos.x,pos.y,pos.z - 1000)
        local newArrow
        if not compatMode then
            newArrow= world.createObject(id)
        else
            for index, value in ipairs(world.getCellByName("ZHAC_ArrowCell"):getAll()) do
                if value.recordId == "zhac_test_arrowplace" then
                    newArrow = value
                end
            end
        end
        newArrow:teleport(player.cell.name, temppos, rot)
    end)
end
return
{
    interfaceName = "ArrowStick",
    interface = {
    },
    engineHandlers = {
        onItemActive = onItemActive,
      --  onUpdate = onUpdate,
    },
    eventHandlers = {
        rotateArrow = rotateArrow,
        placeArrow = placeArrow,
    }
}
