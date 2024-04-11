
local anim = require('openmw.animation')

local self = require('openmw.self')

anim.setLoopingEnabled(self, "idle2", false)
local function doorOpen()
    anim.clearAnimationQueue(self, true)
    anim.playQueued(self, "Idle1",{})
end
local function doorClose()
    anim.clearAnimationQueue(self, true)
    anim.playQueued(self,"Death1",{})
   -- anim.playQueued(self, "idle3")
end

return
{
    eventHandlers = {
        doorClose = doorClose,
        doorOpen = doorOpen
    }
}