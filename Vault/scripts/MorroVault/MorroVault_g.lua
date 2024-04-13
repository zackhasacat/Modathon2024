local _, world = pcall(require,"openmw.world")
local isOpenMW, I = pcall(require,"openmw.interfaces")

local _,util = pcall(require,"openmw.util")
local _,core = pcall(require,"openmw.core")
local _,types = pcall(require,"openmw.types")
local anim = require('openmw.animation')
local doorClosing = false

local doorOpening = false
local doorObj
local function onUpdate(dt)
    if doorClosing or doorOpening and not doorObj then
        for index, value in ipairs(world.players[1].cell:getAll(types.Activator)) do
            if value.recordId == "zhac_vault_door" then
                doorObj = value
            end
        end
    end
    if doorClosing then
        local completion = anim.getCurrentTime(doorObj, "death1")
        if completion > 12 then 
            core.sound.playSound3d("AB_Thunderclap0",doorObj,{volume = 3})
            doorClosing = false
        end
    end
    if doorOpening then
        local completion = anim.getCurrentTime(doorObj, "idle1")
        if completion and completion > 12 then 
            core.sound.playSound3d("thunderclap",doorObj)
            doorClosing = false
        end
        doorOpening = false
    end

end

I.Activation.addHandlerForType(types.Activator, function (obj,actor)
    if obj.recordId == "zhac_door_button" or obj.recordId == "ab_furn_shrinemephala_a" then
        if world.mwscript.getGlobalVariables(actor).zhac_doorstate == 0 then
            world.mwscript.getGlobalVariables(actor).zhac_doorstate = 1
            doorOpening = true
        else
            world.mwscript.getGlobalVariables(actor).zhac_doorstate = 0
            doorClosing = true

        end
        return false
    end
end)


return
{
engineHandlers = {
    onUpdate = onUpdate
}
}