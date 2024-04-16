local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, async = pcall(require, "openmw.async")
local anim = require('openmw.animation')

local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end
local itemBlacklist = {"a_siltstrider"}
local creatureBlacklist = {
    "ash_ghoul"
}
math.randomseed(os.time())
local function isInVault(obj)
   return startsWith(obj.cell.name, "Resdaynia Sanctuary")
end
local processedActors = {}
local function onActorActive(act)
    if  processedActors[act.id] or isInVault(act) then
        return
    end
    local randomNumber = math.random(0, 100)
    processedActors[act.id] = true
    if act.type == types.Creature then
        for index, value in ipairs(creatureBlacklist) do
            if value == act.recordId then
                return
            end
        end
    end
    if act.type == types.NPC then

        local race = types.NPC.record(act).race
        if race:lower() == "dark elf"and randomNumber < 30  then
            for index, value in ipairs(types.Actor.inventory(act):getAll()) do
                value:remove()
            end
            local club = world.createObject("iron club")
            club:moveInto(act)
            act:sendEvent("makeAgressive")
            return
        elseif randomNumber < 40 then
            local newCreature = world.createObject("ash_ghoul")
            newCreature:teleport(act.cell,act.position)
        elseif randomNumber < 30 then
            local newObj = world.createObject("Sound_Haunted00")
            newObj:teleport(act.cell,act.position)
        end
    end
    if not isInVault(act) then
        act:remove()
    end
end
local function onObjectActive(act)
    if act.type == types.Light then
        if not isInVault(act) then
            act:remove()
            act.enabled = false
            return
        end
    end
    for index, value in ipairs(itemBlacklist) do
        if value == act.recordId then
            
            act:remove()
            act.enabled = false
        end
    end
end
return
{
    engineHandlers = {
        onObjectActive = onObjectActive,
        onActorActive = onActorActive,
    },
    eventHandlers = {
    }
}
