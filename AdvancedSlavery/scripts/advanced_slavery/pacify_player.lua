local cam = require('openmw.interfaces').Camera
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local I = require('openmw.interfaces')
local storage = require("openmw.storage")
local async = require("openmw.async")
local input = require("openmw.input")
local Camera = require("openmw.camera")
local function anglesToV(pitch, yaw)
    local xzLen = math.cos(pitch)
    return util.vector3(xzLen * math.sin(yaw), -- x
        xzLen * math.cos(yaw),                 -- y
        math.sin(pitch)                        -- z
    )
end
local function getCameraDirData(sourcePos)
    local pos = sourcePos
    local pitch, yaw

    pitch = -(Camera.getPitch() + Camera.getExtraPitch())
    yaw = (Camera.getYaw() + Camera.getExtraYaw())

    return pos, anglesToV(pitch, yaw)
end
local function getObjInCrosshairs(ignoreOb, mdist, alwaysPost, sourcePos) --Gets the object the player is looking at. Does not work in third person.
    if not sourcePos then
        sourcePos = Camera.getPosition()
    end
    local pos, v = getCameraDirData(sourcePos)

    local dist = 500
    if (mdist ~= nil) then dist = mdist end

    if (ignoreOb) then
        local ret = nearby.castRay(pos, pos + v * dist, { ignore = ignoreOb })
        return ret.hitObject
    else
        local ret = nearby.castRenderingRay(pos, pos + v * dist)
        local destPos = (pos + v * dist)
        if (alwaysPost and ret.hitPos == nil) then
            return { hitPos = destPos }
        end
        return ret.hitObject, destPos
    end
end
local function onInputAction(action)
    if action == input.ACTION.Activate then
        local actor = getObjInCrosshairs(self)
        if actor and actor.type == types.NPC then
            print("found " .. actor.recordId)
            if not types.Actor.canMove(actor) then
                local healthPercent = types.Actor.stats.dynamic.health(actor).current /
                types.Actor.stats.dynamic.health(actor).base
                local fatiguePercent = types.Actor.stats.dynamic.fatigue(actor).current /
                types.Actor.stats.dynamic.fatigue(actor).base
                if fatiguePercent < 0 and healthPercent < 0.5 then
                    local bracerCount1 = types.Actor.inventory(self):countOf("slave_bracer_left")
                    local bracerCount2 = types.Actor.inventory(self):countOf("slave_bracer_right")
                    if bracerCount1 > 0 then
                        core.sendGlobalEvent("makeSlaveEvent",{npc = actor,bracerId = "slave_bracer_left"})
                    elseif bracerCount2 > 0 then
                            core.sendGlobalEvent("makeSlaveEvent",{npc = actor,bracerId = "slave_bracer_right"})
                    end
                end
            end
        else
            print()
        end
    end
end

return {
    engineHandlers = {
        onInputAction = onInputAction
    }
}
