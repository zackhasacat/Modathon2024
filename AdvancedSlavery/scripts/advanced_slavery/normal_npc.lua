local storage = require("openmw.storage")
local self = require("openmw.self")
local types = require("openmw.types")

local playerSettings = storage.globalSection("SettingsDebugMode")
local util = require("openmw.util")
local core = require("openmw.core")
local I = require("openmw.interfaces")
local badInv = nil
local badWait = -1
local nearby = require("openmw.nearby")
local SlaveScript = "scripts/advanced_slavery/slave.lua"


local function onUpdate(dt)
if(types.Actor.activeSpells(self):isSpellActive('zhac_slavespell_enslave')) then
    core.sendGlobalEvent("makeSlave",self)
  

end

end

return {
    engineHandlers = {
      onUpdate = onUpdate,
    },
  }