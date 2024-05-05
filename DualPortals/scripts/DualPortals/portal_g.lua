local world = require("openmw.world")
local types = require("openmw.types")
local util = require("openmw.util")
local marker1Cell
local marker1Pos
local marker1X, marker1Y

local marker2Cell
local marker2Pos
local marker2X, marker2Y



local function createPortalAt(data)
    local id = data.id
    local cell = data.cell
    local position = data.position
    local x, y = data.x, data.y
    local markerObj

    if id == 1 and not marker1Cell then
        marker1Cell = cell
        markerObj = world.createObject("zhac_portalmarker_1")
        marker1Pos = position
        marker1X = x
        marker1Y = y
    elseif id == 1 and marker1Cell then
        local cell
        if not marker1X then
            cell = world.getCellByName(marker1Cell)
        else
            cell = world.getExteriorCell(marker1X, marker1Y)
        end
        for index, value in ipairs(cell:getAll(types.Activator)) do
            if value.recordId == "zhac_portalmarker_1" then
                markerObj = value
                break
            end
        end
        marker1Pos = position
        marker1Cell = cell
        marker1X = x
        marker1Y = y
    elseif id == 2 and not marker2Cell then
        marker2Cell = cell
        markerObj = world.createObject("zhac_portalmarker_2")
        marker2Pos = position
        marker2X = x
        marker2Y = y
    elseif id == 2 and marker2Cell then
        local cell
        if not marker2X then
            cell = world.getCellByName(marker1Cell)
        else
            cell = world.getExteriorCell(marker2X, marker2Y)
        end
        for index, value in ipairs(cell:getAll(types.Activator)) do
            if value.recordId == "zhac_portalmarker_2" then
                markerObj = value
                break
            end
        end
        marker2Pos = position
        marker2Cell = cell
        marker2X = x
        marker2Y = y
    end
    markerObj:teleport(cell, position)
    markerObj:setScale(0.00001)
end

local function tpToPortal(state)
    if state == 1 then
        local cell = marker2Cell
        if marker2X then
            cell = world.getExteriorCell(marker2X, marker2Y)
        end

        if cell then
            world.players[1]:teleport(cell, marker1Pos + util.vector3(0, 0, 100), { onGround = true })
        else
            return
        end
    else
        local cell = marker1Cell
        if marker1X then
            cell = world.getExteriorCell(marker1X, marker1Y)
        end
        if cell then
            world.players[1]:teleport(cell, marker1Pos + util.vector3(0, 0, 100), { onGround = true })
        else
            return
        end
    end
    world.players[1]:sendEvent("playTeleportSound")
end
return {
    eventHandlers = {
        createPortalAt = createPortalAt,
        tpToPortal = tpToPortal,
    },
    engineHandlers = {
        onSave = function()
            return {
                marker1Cell = marker1Cell,
                marker1Pos = marker1Pos,
                marker2Cell = marker2Cell,
                marker2Pos = marker2Pos,
                marker1X = marker1X,
                marker1Y = marker1Y,
                marker2X = marker2X,
                marker2Y = marker2Y
            }
        end,
        onLoad = function(data)
            marker1Cell = data.marker1Cell
            marker1Pos = data.marker1Pos
            marker2Cell = data.marker2Cell
            marker2Pos = data.marker2Pos
            marker1X = data.marker1X
            marker1Y = data.marker1Y
            marker2X = data.marker2X
            marker2Y = data.marker2Y
        end
    }
}
