local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require("openmw.async")
local core = require("openmw.core")
local calendar = require('openmw_aux.calendar')
local changedActors = {}
local createdItems
local itemsToCreate = {
    ["water_full"] = {
        id = "water_full",
        model = "meshes\\m\\Misc_Com_Bottle_15.NIF",
        icon = "icons\\m\\misc_com_bottle_15.dds",
        name = "Bottle of Water",
        type = types.Potion
    },
}
local function createItems()
    createdItems = {}
    for index, value in pairs(itemsToCreate) do
        local draft = value.type.createRecordDraft({ model = value.model, icon = value.icon, name = value.name })
        local newRecord = world.createRecord(draft)
        world.players[1]:sendEvent("addSavedDrink",{id = newRecord.id,saturation = 3})
        createdItems[index] = newRecord.id

    end
end
local function onActorActive(actor)
    if actor.type ~= types.NPC then
        return
    end
    local class = types.NPC.records[actor.recordId].class

    if class:lower() == "publican"  then

        if not createdItems or createdItems == {} then
            createItems()
        end
        for index, value in pairs(createdItems) do
            local countOf = types.Actor.inventory(actor):countOf(value)
            local toAdd =  10 - countOf
            if toAdd > 0 then
                
            local newItem = world.createObject(value, toAdd)
            newItem:moveInto(actor)
            end
        end
        changedActors[actor.id] = true
    end
end

return {
    interfaceName = "WaterSystem",
    interface = {
        getCreatedItems = function ()
            if not createdItems then
                createItems()
            end
            return createdItems
            
        end
    },
    engineHandlers = {
        onActorActive = onActorActive,
        onSave = function()
            return { changedActors = changedActors }
        end,
        onLoad = function(data)
            if not data then return end
            changedActors = data.changedActors
        end

    }
}
