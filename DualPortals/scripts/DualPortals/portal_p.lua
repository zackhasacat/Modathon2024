local core = require("openmw.core")
local util = require("openmw.util")
local ambient = require("openmw.ambient")
local position
local portalType = 1

local function startPortalAnim(pos,type)
    if type then
        portalType = type
    end
    position = pos --+ util.vector3(0,0,100)
end
local delay = 0
local function onUpdate(dt)
    if position then
  
end
end

local function playTeleportSound()
    ambient.playSound("mysticism hit")
end
return {--I.ZS_DualPortals.startPortalAnim(selected.position)
    interfaceName = "ZS_DualPortals",
    interface = {
        startPortalAnim = startPortalAnim,
    },
    engineHandlers = {
        onUpdate = onUpdate,
    },
    eventHandlers = {
        playTeleportSound = playTeleportSound,
    }
}