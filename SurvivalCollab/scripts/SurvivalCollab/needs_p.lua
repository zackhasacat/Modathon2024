local I = require('openmw.interfaces')
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local storage = require("openmw.storage")
local async = require("openmw.async")
local input = require("openmw.input")
local time = require('openmw_aux.time')
local needBase = require("scripts.SurvivalCollab.need_base")

local needs

local function initNeeds()
    needs = {}
    local hunger = needBase.newNeed("Hunger", 100, 0.01)
    local thirst = needBase.newNeed("Thirst", 100, 0.05)
    local energy = needBase.newNeed("Energy", 100, 0.04)
    table.insert(needs, hunger)
    table.insert(needs, thirst)
    table.insert(needs, energy)
end
local lastGameTime
local function onUpdate(dt)
    local gtDt = 0
    if lastGameTime then
        gtDt = core.getGameTime() - lastGameTime
    else
        lastGameTime = core.getGameTime()
        return
    end
    if not needs then
        initNeeds()
    end
    local minutesPassed = gtDt / time.minute
    if minutesPassed > 3 then
        for index, value in ipairs(needs) do
            value:update(minutesPassed)
        end
        lastGameTime = core.getGameTime()
        I.NeedsPlayer_UI.updateElement()
        
    end
end

local function relieveNeed(name,amount)
    for index, need in ipairs(needs) do
        if need.name == name then
            need:relieve(amount)
            I.NeedsPlayer_UI.updateElement()
            return
        end
    end
end
return {
    interfaceName = "NeedsPlayer",
    interface = {
        relieveNeed = relieveNeed,
        getNeedValue = function(name)
            for index, need in ipairs(needs) do
                if need.name == name then
                    return need.current
                end
            end
        end,
        getNeeds = function ()
            if not needs then
                initNeeds()
            end
            return needs
        end
    },
    engineHandlers = {
        onLoad = function(data)
            if not data then
                initNeeds()
            else
                local needData = data.needs
                needs = {}
                for index, needD in ipairs(needData) do
                    local loadedNeed = needBase.load(needD)
                    table.insert(needs,loadedNeed)
                end
                lastGameTime = data.lastGameTime
                I.NeedsPlayer_UI.updateElement()
            end
        end,
        onSave = function()
            local needsSaved = {}
            for index, need in ipairs(needs) do
                table.insert(needsSaved,need:save())
            end
            return { needs = needsSaved, delay = delay, lastGameTime = lastGameTime }
        end,
        onUpdate = onUpdate,
    },
    eventHandlers = {
        getRoomNavPos1 = getRoomNavPos1,
        ZS_ShowMessage = ZS_ShowMessage,
        InRoomCheck = InRoomCheck,
    }
}
