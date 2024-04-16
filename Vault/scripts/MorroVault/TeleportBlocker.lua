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

local doorIsOpen = false

local antiCheese = true
local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end

local function isInVault(obj)
    if (startsWith(obj.cell.name, "Resdaynia Sanctuary") )then
      return true
    else
     return false
    end
end
local function kickPlayerOut()
    player:teleport("Resdaynia Sanctuary, Entrance",util.vector3(9726.462890625, 4234.05419921875, 11393))
end
local function canTeleportInCell(cell)
    if (startsWith(cell.name, "Resdaynia Sanctuary")  and cell.name ~= "Resdaynia Sanctuary, Entrance")or (cell.name == "Resdaynia Sanctuary, Entrance" and player.position.x > 11318) then
        if not wasInRes then
        if not doorIsOpen and antiCheese then
            kickPlayerOut()
            return
        end
    end
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
    if player.cell.name == "Resdaynia Sanctuary, Entrance" then
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
    interfaceName = "TeleportBlocker",
    interface = {
      setDoorOpen = function (state)
        doorIsOpen = state
      end
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onSave = function ()
            return {wasInRes = wasInRes,doorIsOpen = doorIsOpen,}
        end,
        onLoad = function (data)
            if data then
                wasInRes = data.wasInRes
                doorIsOpen = data.doorIsOpen
            end
        end
    }
}
