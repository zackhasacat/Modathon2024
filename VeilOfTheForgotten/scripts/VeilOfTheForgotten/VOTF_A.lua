local I = require("openmw.interfaces")
local self = require("openmw.self")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local guideState = nil
local isPendingCapture = false
local expireDt = 0
local isPawn = false
local frozen = false
local anim = require('openmw.animation')
local function isCaptured()
    return types.Actor.activeSpells(self):isSpellActive("zhac_soulcapture_shock")
end
local function onRelease()
    types.Actor.stats.ai.fight(self).base = 0
    types.Actor.stats.ai.hello(self).base = 0
    types.Actor.stats.ai.alarm(self).base = 0
    I.AI.removePackages()
    types.Actor.setStance(self,types.Actor.STANCE.Nothing)
    async:newUnsavableSimulationTimer(3, function()
        types.Actor.stats.ai.fight(self).base = 0
        types.Actor.stats.ai.hello(self).base = 0
        types.Actor.stats.ai.alarm(self).base = 0
        I.AI.removePackages()
        types.Actor.setStance(self,types.Actor.STANCE.Nothing)
    end)
end
local function makeIntoDoll()
    self:enableAI(false)
    onRelease()
    frozen = true
end
local function checkForCapture()
    isPendingCapture = true
    expireDt = core.getSimulationTime() + 10
end
local function onUpdate(dt)
    if isPendingCapture then
        if  core.getSimulationTime() < expireDt then
            if isCaptured() then
                core.sendGlobalEvent("captureComplete", self)
                isPendingCapture = false
                isPawn = true
            end
        else
            print("canceling capture")
            isPendingCapture = false
        end
    end
    if frozen then
        anim.skipAnimationThisFrame(self)
    end
end
return {
    eventHandlers = {
        checkForCapture = checkForCapture,
        onRelease = onRelease,
        makeIntoDoll = makeIntoDoll,
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onSave = function ()
            return  {
                isPawn = isPawn,
                frozen = frozen,
            }
        end,
        onLoad = function (data)
            if data then
                isPawn = data.isPawn
                frozen = data.frozen
            end
        end
    }
}
