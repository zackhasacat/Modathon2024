local world = require("openmw.world")
local types = require("openmw.types")
local util = require("openmw.util")
local marker1Cell
local marker1Pos
local marker1X, marker1Y
local marker1Obj

local marker2Cell
local marker2Pos
local marker2X, marker2Y
local marker2Obj



local function createPortalAt(data)
    local id = data.id
    local xcell = data.cell
    local position = data.position
    local x, y = data.x, data.y
    local markerObj
    if id == 1 and not marker1Cell then
        marker1Cell = xcell
        marker1Obj = world.createObject("zhac_portalmarker_1")
        marker1Pos = position
        marker1X = x
        marker1Y = y
        markerObj = marker1Obj
    elseif id == 1 and marker1Obj then
        markerObj = marker1Obj
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
        marker1Cell = xcell
        marker1X = x
        marker1Y = y
    elseif id == 2 and not marker2Cell then
        marker2Cell = xcell
        marker2Obj = world.createObject("zhac_portalmarker_2")
        marker2Pos = position
        marker2X = x
        marker2Y = y
        markerObj = marker2Obj
    elseif id == 2 and marker2Obj then
        markerObj = marker2Obj
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
        marker2Cell = xcell
        marker2X = x
        marker2Y = y
    end
    markerObj:teleport(xcell, position)
    markerObj:setScale(0.00001)
end

local function tpToPortal(state)
    if state == 1 then
        if marker2Obj then
            world.players[1]:sendEvent("playTeleportSound")
            world.players[1]:teleport(marker2Obj.cell, marker2Obj.position + util.vector3(0, 0, 100), { onGround = true })
            return
        else
            print("no marker 2")
            return
        end
        local cell = marker2Cell
        if marker2X then
            cell = world.getExteriorCell(marker2X, marker2Y)
        end

        if cell then
            world.players[1]:teleport(cell, marker2Pos + util.vector3(0, 0, 100), { onGround = true })
        else
            return
        end
    else
        if marker1Obj then
            world.players[1]:sendEvent("playTeleportSound")
            world.players[1]:teleport(marker1Obj.cell, marker1Obj.position + util.vector3(0, 0, 100), { onGround = true })
            return
        else
            print("no marker 1")
            return
        end
        print(state)
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
                marker2Y = marker2Y,
                marker2Obj = marker2Obj,
                marker1Obj = marker1Obj
            }
        end,
        onLoad = function(data)
            if data then
                marker1Cell = data.marker1Cell
                marker1Pos = data.marker1Pos
                marker2Cell = data.marker2Cell
                marker2Pos = data.marker2Pos
                marker1X = data.marker1X
                marker1Y = data.marker1Y
                marker2X = data.marker2X
                marker2Y = data.marker2Y
                marker1Obj = data.marker1Obj
                marker2Obj = data.marker2Obj
            end
        end
    }
}
