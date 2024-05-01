local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require("openmw.async")
local core = require("openmw.core")

local calendar = require('openmw_aux.calendar')
local settings = require("scripts.VeilOfTheForgotten.settings")

local storedActors = {}
local controlledActors = {}

local function captureComplete(actor)
    local name = actor.type.records[actor.recordId].name
    local oldRecord = types.Weapon.records["zhac_ball_01"]
    local newRecordDraft = types.Weapon.createRecordDraft({template =oldRecord, name = oldRecord.name  .. " (" .. name .. ")"})
    local newRecord = world.createRecord(newRecordDraft)
    local newItem = world.createObject(newRecord.id)
    storedActors[newRecord.id] = actor.id
    table.insert(controlledActors,actor.id)
    newItem:moveInto(world.players[1])
    actor:teleport("toddtest",actor.position)
    
end
local function releaseAtTarget(data)
    local weapon = data.weapon
    local pos = data.pos

  if storedActors[weapon] then
    for index, value in ipairs(world.getCellByName("ToddTest"):getAll(types.NPC)) do
        if value.id == storedActors[weapon] then
          --  async:newUnsavableSimulationTimer(3, function()
                value:teleport(world.players[1].cell,pos)
                value:sendEvent("onRelease")
           -- end)
            storedActors[weapon] = nil
            return
        end
    end
  end
    
end
local function returnItem(data)
    local item = data.itemId
    local actor = data.actor
    world.createObject(item):moveInto(actor)
end
return{
    eventHandlers= {
        captureComplete = captureComplete,
        releaseAtTarget = releaseAtTarget,
        returnItem = returnItem,
    },
    engineHandlers = {
       onLoad = function (data)
        storedActors = data.storedActors or {}
       end,
       onSave = function ()
        return {storedActors = storedActors}
       end,
    }
}