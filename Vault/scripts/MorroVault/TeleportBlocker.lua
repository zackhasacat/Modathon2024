local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local anim = require('openmw.animation')
local player
local lastCell
local lastPos
local blocked = false
local wasInRes = false
local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end

local function canTeleportInCell(cell)
    if startsWith(cell.name, "Resdaynia Sanctuary") or (cell.name == "Andelor Ancestral Tomb" and player.position.x > 11318) then
        types.Player.setTeleportingEnabled(player,false)
        wasInRes = true
    else
        if wasInRes then
            types.Player.setTeleportingEnabled(player,true)
            wasInRes = false
        end
    end
end
local function onCellChange(newCell, oldCell)
    print("New cell: " .. newCell.name)
    canTeleportInCell(newCell)
end
local roomState = 0
local function onUpdate()
    if not player then
        if not world.players[1] then
            return
        end
        player = world.players[1]
    end
    if player.cell.name == "Andelor Ancestral Tomb" then
        if roomState ~= 1 and player.position.x > 11318 then
            roomState = 1
            canTeleportInCell(player.cell)
        elseif roomState ~= 2 then
            roomState = 2
            canTeleportInCell(player.cell)
        end
    end
    if player.cell ~= lastCell then
        onCellChange(player.cell, lastCell)
        lastCell = player.cell
    end
    lastPos = player.position
end
return
{
    engineHandlers = {
        onUpdate = onUpdate
    }
}
