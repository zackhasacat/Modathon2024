local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, storage = pcall(require, "openmw.storage")
local _, world = pcall(require, "openmw.world")
local _, async = pcall(require, "openmw.async")
local constant
if isOpenMW then
 constant = require("scripts.CoinFlip.constant")
else
    constant = require("CoinFlip.constant")
end
local timeDelay = 0.01
local useMountMenu = true
local coinObj
local coinDistance = 0
local coinRot = 0
local coinAscent = true
local coinOriginZPos
local player
math.randomseed(os.time())

local function getPosition(x, y, z)
    if isOpenMW then
        return util.vector3(x, y, z)
    else
        return tes3vector3.new(x, y, z)
    end
end
local function getItemRecordId(obj)
    if isOpenMW then
        return obj.recordId
    else
        return obj.baseObject.id:lower()
    end
end
local function showPlayerMessage(msg)
    if isOpenMW then
        player:sendEvent("CF_ShowMessage", msg)
    else
        tes3.messageBox(msg)
    end
end
local function gameIsPaused()
    if isOpenMW then
    else
        return tes3.menuMode()
    end
end
local function runWithDelay(delay, func)
    if isOpenMW then
        async:newUnsavableSimulationTimer(delay, func)
    else
        timer.start({ duration = delay, callback = func })
    end
end
local function getPlayerLuck()
    if isOpenMW then
        return types.Actor.stats.attributes.luck(player).modified
    else
        return tes3.mobilePlayer.luck.current
    end
end
local function coinFlipChance()
    return 50--getPlayerLuck() * 0.01
end
local function teleportObjToPlayer(id)
    print(id)
    if isOpenMW then
        local cell = world.getCellByName("zhac_coinholdingcell")
        for index, obj in ipairs(cell:getAll()) do
            print(obj.recordId, id)
            if obj.recordId == id then
                obj:teleport(player.cell, player.position)
                return
            end
        end
    else
       local reference = tes3.getReference(id)
        tes3.positionCell({ reference = reference, cell = tes3.mobilePlayer.cell, position = tes3.mobilePlayer.position })
    end
end
local function getRotation(x, y, z)
    --TODO: account for z rotation so it faces the player still
    if isOpenMW then
        local rot = util.transform.rotateY(y)
        return rot
    else
        return tes3vector3.new(x, (y), z)
    end
end
local function teleportObject(object, cell, position, rotation)
    if isOpenMW then
        object:teleport(cell, position, rotation)
    else
        tes3.positionCell({ reference = object, cell = cell, position = position, orientation = rotation })
    end
end
local function randomBool()
    if math.random() < coinFlipChance() * 0.01 then
        
        return true
    else
        return false
    end
end

local function incrementAmount()
    local input = coinDistance
    local a = 1    -- Start value
    local b = 0.1  -- End value
    local min = 0  -- Minimum input value
    local max = 50 -- Maximum input value

    -- Ensure the input is within the expected range
    input = math.max(min, math.min(max, input))

    -- Adjusted interpolation formula
    local result = a + (b - a) * ((input - min) / (max - min))

    return result * 3
end
local function teleportCoin()
    local newZPos = coinOriginZPos + coinDistance

    local newRot = getRotation(0, math.rad(coinRot), 0)
    if coinDistance <= 0 and not coinAscent then
        newZPos = coinOriginZPos
        newRot = getRotation(0, math.rad(0), 0)
        if randomBool() then
            newRot = getRotation(0, math.rad(180), 0)
            --newZPos = coinOriginZPos + 0.1111
            showPlayerMessage("Heads, you are lucky!")
            print("123")
            teleportObjToPlayer("zhac_caster_lucky")
        else
            showPlayerMessage("Tails, you are not lucky!")
            print("123")
            teleportObjToPlayer("zhac_caster_unlucky")
        end
    end
    teleportObject(coinObj, coinObj.cell, getPosition(coinObj.position.x, coinObj.position.y, newZPos), newRot)
end
local function coinUpdate()
    if coinAscent then
        coinDistance = coinDistance + incrementAmount()
        if coinDistance > 50 then
            coinAscent = false
        end
    else
        coinDistance = coinDistance - incrementAmount()
    end
    coinRot = coinRot + 10
    teleportCoin()
    if coinDistance <= 0 and not coinAscent then
        return
    end
    runWithDelay(timeDelay, function()
        coinUpdate()
    end)
end
local function activateCoin(coin, player)
    if gameIsPaused() then
        return
    end
    if getItemRecordId(coin) == constant.coinId then
        coinOriginZPos = coin.position.z
        coinDistance = 0
        coinRot = 0
        coinAscent = true
        coinObj = coin
        runWithDelay(timeDelay, function()
            coinUpdate()
        end)
        return false
    end
end
local function activateMWSE(e)
    return activateCoin(e.target)
end
if isOpenMW then
    I.Activation.addHandlerForType(types.Miscellaneous, activateCoin)

else
    event.register(tes3.event.activate, activateMWSE)
    return {
    }
end
print("isOpenMW")
return {
    engineHandlers = {
        onPlayerAdded = function(p)
            player = p
        end

    },
    eventHandlers = {
        CF_SetPlayer = function(plr)
            player = plr
        end,
        CF_teleportObjToPlayer = teleportObjToPlayer
    }
}