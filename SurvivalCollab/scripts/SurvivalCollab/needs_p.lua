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
local settingsSystem = require("scripts.SurvivalCollab.needs_settings")
local needs
local menuMode = false
local function initNeeds()
    needs = {}
    local hunger, hSett = needBase.newNeed("Hunger", 100, 0.01,"ZHAC_Needs_Hunger_famished","ZHAC_Needs_Hunger_nourished")
    local thirst, tSett = needBase.newNeed("Thirst", 40, 0.05,"ZHAC_Needs_Thirst_thirsty","ZHAC_Needs_Thirst_quenched")
    local energy, eSett = needBase.newNeed("Energy", 100, 0.04,"ZHAC_Needs_Sleep_Tired","ZHAC_Needs_Sleep_Rested")
    table.insert(needs, hunger)
    table.insert(needs, thirst)
    table.insert(needs, energy)
    local settingList = {}
    for index, need in ipairs(needs) do
        for index, value in ipairs(need:getSettingItems()) do
            table.insert(settingList, value)
        end
    end
    settingsSystem.createNeedSection(settingList)
    I.NeedsPlayer_UI.updateElement()
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

local function relieveNeed(name, amount)
    for index, need in ipairs(needs) do
        if need.name == name then
            need:relieve(amount)
            I.NeedsPlayer_UI.updateElement()
            print("Relieved" .. tostring(amount))
            self:sendEvent("needRelieved", { name = name, amount = amount })
            return
        end
    end
end
local function UiModeChanged(data)
    local newMenuModeState = not (data.newMode == nil)
    if menuMode ~= newMenuModeState then
        menuMode = newMenuModeState
        I.NeedsPlayer_UI.updateElement(menuMode)
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
        getNeeds = function()
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
                    table.insert(needs, loadedNeed)
                end
                local settingList = {}
                for index, need in ipairs(needs) do
                    for index, value in ipairs(need:getSettingItems()) do
                        table.insert(settingList, value)
                    end
                end
                settingsSystem.createNeedSection(settingList)
                lastGameTime = data.lastGameTime
                I.NeedsPlayer_UI.updateElement()
            end
        end,
        onSave = function()
            local needsSaved = {}
            for index, need in ipairs(needs) do
                table.insert(needsSaved, need:save())
            end
            return { needs = needsSaved, lastGameTime = lastGameTime }
        end,
        onUpdate = onUpdate,
    },
    eventHandlers = {
        UiModeChanged = UiModeChanged,
    }
}
