local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, async = pcall(require, "openmw.async")
local anim = require('openmw.animation')
local doorClosing = false

local doorOpening = false

local playerIsInVault = false
local checkForExit = false
local cutsceneState = 0
local openDelay = 2
local doorObj
local function getObjByID(id, cell)
    if not cell then
        cell = world.players[1].cell
    end
    for index, value in ipairs(cell:getAll()) do
        if value.recordId == id then
            return value
        end
    end
end
local function openDoor()
    doorOpening = true
    core.sound.playSound3d("SothaDoorOpen", doorObj, { volume = 3 })
    async:newUnsavableSimulationTimer(openDelay, function()
        world.mwscript.getGlobalVariables(actor).zhac_doorstate = 1
    end
    )

    playerIsInVault = world.players[1].position.x > 11318
    checkForExit = true
end
local function closeDoor()
    world.mwscript.getGlobalVariables(actor).zhac_doorstate = 0
    doorClosing = true
end
local function onUpdate(dt)
    if not doorObj then
        for index, value in ipairs(world.players[1].cell:getAll(types.Activator)) do
            if value.recordId == "zhac_vault_door" then
                doorObj = value
            end
        end
    end
    if doorClosing then
        local completion = anim.getCurrentTime(doorObj, "death1")
        if completion and completion > 12 then
            core.sound.playSound3d("AB_Thunderclap0", doorObj, { volume = 3 })
            doorClosing = false
        end
    end
    if doorOpening then
        local completion = anim.getCurrentTime(doorObj, "idle1")
        if completion and completion > 6.6 then
            doorOpening = false

            if types.Player.quests(world.players[1]).zhac_vault1.stage < 41 then
                if cutsceneState == 1 then
                    cutsceneState = 2
                    local center, right, left = getObjByID("zhac_mvault_rguard_c"), getObjByID("zhac_mvault_lguard"),
                        getObjByID("zhac_mvault_rguard")
                    center:sendEvent("exitVaultCenter")
                    async:newUnsavableSimulationTimer(2, function()
                        left:sendEvent("exitVaultLeft")
                        right:sendEvent("exitVaultRight")
                    end)
                end
            end
        end
    end
    if checkForExit then
        if types.Player.quests(world.players[1]).zhac_vault1.stage >= 50 then
            local playerIsInVaultNow = world.players[1].position.x > 11318
            if playerIsInVaultNow ~= playerIsInVault then
                closeDoor()
                checkForExit = false
            end
        end
    end
end
--zhac_carryingitems
I.Activation.addHandlerForType(types.Activator, function(obj, actor)
    if obj.recordId == "zhac_door_button" or obj.recordId == "ab_furn_shrinemephala_a" then
        if world.mwscript.getGlobalVariables(actor).zhac_doorstate == 0 then
            openDoor()
        else
            closeDoor()
        end
        return false
    end
end)
I.Activation.addHandlerForType(types.NPC, function(obj, actor)
    local playerHasItems = false
    for index, value in ipairs(types.Actor.inventory(actor):getAll()) do
        playerHasItems = true
    end
    if playerHasItems then
        world.mwscript.getGlobalVariables(actor).zhac_carryingitems = 1
    else
        world.mwscript.getGlobalVariables(actor).zhac_carryingitems = 0
    end
end)
local function goToVault()
    world.players[1]:teleport("Andelor Ancestral Tomb", util.vector3(8861.6123046875, 4152.15234375, 11424.8330078125))
end
local function StartCutscene1() --make the NPCs come out
    if types.Player.quests(world.players[1]).zhac_vault1.stage < 41 then
        openDoor()
        cutsceneState = 1
        world.players[1]:sendEvent("startCutscene")
        async:newUnsavableSimulationTimer(openDelay, function()

        end)
    end
end
local function firstApproach()
    if types.Player.quests(world.players[1]).zhac_vault1.stage < 20 and types.Player.quests(world.players[1]).zhac_vault1.stage < 20 then
        types.Player.quests(world.players[1]).zhac_vault1:addJournalEntry(20)
    end
end
local function onPlayerAdded()
    world.players[1]:teleport("Andelor Ancestral Tomb", util.vector3(8861.6123046875, 4152.15234375, 11424.8330078125))
end
local checkinCOunt = 0
local function checkInWhenDone(id)
    checkinCOunt = checkinCOunt + 1
    if checkinCOunt > 1 then
        world.mwscript.getGlobalVariables(actor).zhac_doorstate = 0
        doorClosing = true
        checkinCOunt = -1
    end
end
return
{
    engineHandlers = {
        onUpdate = onUpdate,
        onPlayerAdded = onPlayerAdded,
    },
    eventHandlers = {
        goToVault = goToVault,
        StartCutscene1 = StartCutscene1,
        firstApproach = firstApproach,
        checkInWhenDone = checkInWhenDone
    }
}
