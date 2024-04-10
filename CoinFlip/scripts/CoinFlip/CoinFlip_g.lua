local I = require("openmw.interfaces")

local v2 = require("openmw.util").vector2
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local storage = require("openmw.storage")
local world = require("openmw.world")
local async = require("openmw.async")
local SlaveScript = "scripts/advanced_slavery/slave.lua"
local timeDelay = 0.01
local useMountMenu = true
local coinObj
local coinDistance = 0
local coinRot = 0
local coinAscent = true
local coinOriginZPos
math.randomseed(os.time())

local isOpenMW = true
local function getPosition(x, y, z)
    if isOpenMW then
        return util.vector3(x, y, z)
    else
        return  tes3vector3.new(x,y,z)
    end
end
local function getItemRecordId(obj)
    if isOpenMW then
        return obj.recordId
    else

        return obj.baseObject.id:lower()
    end
end
local function runWithDelay(delay, func)
    if isOpenMW then
        async:newUnsavableSimulationTimer(delay, func)
    else
        timer.start({ duration = delay, callback = func })
    end
end
local function getRotation(x, y, z)
    if isOpenMW then
        local rot = util.transform.rotateY(math.rad(coinRot))
        return rot
    else
       return tes3vector3.new(x,y,z)
    end
end
local function teleportObject(object, cell, position, rotation)

    if isOpenMW then
        object:teleport(cell, position, rotation)
    else
        tes3.positionCell({ reference = actor, cell = cell, position =position })
    end
end
local function randomBool()
    -- Seed the random number generator; ideally, call this once at the start of your program
    -- math.randomseed(os.time())

    if math.random() < 0.5 then
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
        newRot = getRotation(0, math.rad(0))
        if randomBool() then
            newRot = getRotation(0, math.rad(180), 0)
            newZPos = coinOriginZPos + 0.1111
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
    if getItemRecordId(coin) == "gold_001" then
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
