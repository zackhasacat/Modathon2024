local I = require('openmw.interfaces')
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local storage = require("openmw.storage")
local async = require("openmw.async")
local input = require("openmw.input")
local time = require('openmw_aux.time')


local function RestEnd(data)
    local duration = data.duration
    if data.isWait then
        return
    end
    I.NeedsPlayer.relieveNeed("Energy",duration * 2)
end


return {
    interfaceName = "NeedsPlayer_Energy",
    interface = {
    },
    engineHandlers = {
    },
    eventHandlers = {
        RestEnd = RestEnd,
    }
}