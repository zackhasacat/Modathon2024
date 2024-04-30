local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require("openmw.async")
local core = require("openmw.core")

local calendar = require('openmw_aux.calendar')

local storedActors = {}
local controlledActors = {}
local spokenToActor
local function captureComplete(actor)
    local name = actor.type.records[actor.recordId].name
    local oldRecord = types.Weapon.records["zhac_ball_01"]
    local newRecordDraft = types.Weapon.createRecordDraft({
        template = oldRecord,
        name = oldRecord.name ..
            "(" .. name .. ")"
    })
    local newRecord = world.createRecord(newRecordDraft)
    local newItem = world.createObject(newRecord.id)
    storedActors[newRecord.id] = actor.id
    table.insert(controlledActors, actor.id)
    newItem:moveInto(world.players[1])
    actor:teleport("toddtest", actor.position)
end
local function releaseAtTarget(data)
    local weapon = data.weapon
    local pos = data.pos

    if storedActors[weapon] then
        for index, value in ipairs(world.getCellByName("ToddTest"):getAll(types.NPC)) do
            if value.id == storedActors[weapon] then
                --  async:newUnsavableSimulationTimer(3, function()
                local pz = world.players[1].rotation:getAnglesZYX()
                local rot = util.transform.rotateZ(pz - math.rad(180) )
               
                value:teleport(world.players[1].cell, pos,rot)
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
local function npcActivation(actor, player)
    for index, value in ipairs(controlledActors) do
        if value == actor.id then
            world.mwscript.getGlobalVariables(player)["zhac_speakingto_controlled"] = 1
            async:newUnsavableSimulationTimer(1, function()
                world.mwscript.getGlobalVariables(player)["zhac_speakingto_controlled"] = 0
            end)
            spokenToActor = actor
            return
        end
    end
end
I.Activation.addHandlerForType(types.NPC, npcActivation)
local function miscActivation(item, player)
    if item.recordId == ("T_Com_CrystalBallStand_01"):lower() then
        local weapon = types.Actor.getEquipment(player)[types.Actor.EQUIPMENT_SLOT.CarriedRight]
        if weapon and storedActors[weapon.recordId] then
            weapon:teleport(item.cell, item.position, item.rotation)
            return false
        end
    elseif storedActors[item.recordId] then
        for index, value in ipairs(world.getCellByName("ToddTest"):getAll(types.NPC)) do
            if value.id == storedActors[item.recordId] then
                --  async:newUnsavableSimulationTimer(3, function()
                types.Actor.spells(value):add("zhac_debug_fly")
                value:teleport(world.players[1].cell,
                    util.vector3(item.position.x, item.position.y, item.position.z + 5))
                value:sendEvent("makeIntoDoll")
                -- end)
                value:setScale(0.1)
                return false
            end
        end
        return false
    end
end
I.Activation.addHandlerForType(types.Miscellaneous, miscActivation)
I.Activation.addHandlerForType(types.Weapon, miscActivation)
--T_Com_CrystalBallStand_01
return {
    eventHandlers = {
        captureComplete = captureComplete,
        releaseAtTarget = releaseAtTarget,
        returnItem = returnItem,
    },
    engineHandlers = {
        onLoad = function(data)
            storedActors = data.storedActors or {}
            controlledActors = data.controlledActors or {}
        end,
        onSave = function()
            return { storedActors = storedActors, controlledActors = controlledActors }
        end,
        onItemActive = function(item)
            if item.recordId == "zhac_marker_compshare" and spokenToActor then
                item:remove()
                world.players[1]:sendEvent("openCompShare", spokenToActor)
            end
        end
    }
}
