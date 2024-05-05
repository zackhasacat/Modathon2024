local ui = require("openmw.ui")
local core = require("openmw.core")
local self = require("openmw.self")

return {
    eventHandlers = {CF_ShowMessage = function (msg)
        ui.showMessage(msg  )
    end},
    engineHandlers = {
        onLoad = function ()
           core.sendGlobalEvent("CF_SetPlayer",self.object)
        end
    }
}