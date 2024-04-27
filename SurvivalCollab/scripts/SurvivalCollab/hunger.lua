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

local morrowindFood = {
    ["ingred_saltrice_01"] = {saturation = 3},
    ["ingred_bread_01"] = {saturation = 5},
    ["ingred_comberry_01"] = {saturation = 5},
}

local function onConsume(food)
    if morrowindFood[food.recordId] then
        I.NeedsPlayer.relieveNeed("Hunger", morrowindFood[food.recordId].saturation)
        print("eatiubg")
    end
end



return {
    interfaceName = "NeedsPlayer_Hunger",
    interface = {
    },
    engineHandlers = {
        onConsume = onConsume,
    },
    eventHandlers = {
        RestEnd = RestEnd,
    }
}