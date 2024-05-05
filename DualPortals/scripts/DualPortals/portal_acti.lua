local self = require("openmw.self")

local core = require("openmw.core")
local util = require("openmw.util")
local nearby = require("openmw.nearby")
local state = 0
local lastPosition
local zModify = 0
if self.recordId == "zhac_portalmarker_1" then
    state = 1
elseif self.recordId == "zhac_portalmarker_2" then
    state = 2
else
    return {}
end

local function getEffectPosition()
    return self.position + util.vector3(0, 0, zModify)
end
local delay = 0
local playerEnterDistance = 200
local playerHoldDistance = 100
local playerDistState = {
    inRangeTp = 1,
    inRangeNoTp = 2,
    outOfRange = 3,
}
local playerCurrState = playerDistState.outOfRange
local mySound = "Crystal Ringing"
local soundFor1 = "Illusion bolt"
local soundFor2 = "destruction bolt"
local function onUpdate(dt)
    local pos = getEffectPosition()
    if not core.sound.isSoundPlaying(mySound, self) then
        core.sound.playSound3d(mySound, self,{volume = 2})
    end
    if state == 1 and not core.sound.isSoundPlaying(soundFor1, self) then
        core.sound.playSound3d(soundFor1, self,{volume = 0.5,pitch = 0.5})
    elseif state == 2 and not core.sound.isSoundPlaying(soundFor2, self) then
        core.sound.playSound3d(soundFor2, self,{volume = 0.5})
    end
    if self.position then
        delay = delay + dt
        if delay > 0.4 then
            delay = 0
            core.vfx.spawn("VFX_MysticismArea", pos, { scale = 15 })
            if state == 1 then
                core.vfx.spawn("portal1", pos, { scale = 15 })
            else
                core.vfx.spawn("VFX_DestructArea", pos, { scale = 15 })
            end
        end
    end
    if lastPosition ~= self.position then
        lastPosition = self.position
        zModify = 0
    elseif zModify < 200 then
        zModify = zModify + (dt * 100)
    end
    local playerDist = (self.position - nearby.players[1].position):length()

    if playerDist < playerEnterDistance and playerCurrState == playerDistState.outOfRange then
        if playerDist > playerHoldDistance then
            playerCurrState = playerDistState.inRangeTp
            core.sendGlobalEvent("tpToPortal", state)
        else
            playerCurrState = playerDistState.inRangeNoTp
        end
    elseif playerDist > playerEnterDistance and playerCurrState ~= playerDistState.outOfRange then
        playerCurrState = playerDistState.outOfRange
    end
        
end
return { --I.ZS_DualPortals.startPortalAnim(selected.position)
    interfaceName = "ZS_DualPortals",
    interface = {
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onSave = function ()
            return {
                zModify = zModify,
                lastPosition = lastPosition,
                playerCurrState = playerCurrState,
            }
            
        end,
        onLoad = function (data)
            zModify = data.zModify
            lastPosition = data.lastPosition
            playerCurrState = data.playerCurrState
        end
    },
}
