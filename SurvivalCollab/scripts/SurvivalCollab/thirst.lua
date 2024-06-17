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

local morrowindDrinks = {
    ["potion_ancient_brandy"] = {saturation = 3},
    ["potion_cyro_brandy_01"] = {saturation = 3},
    ["potion_cyro_whiskey_01"] = {saturation = 3},
    ["potion_comberry_brandy_01"] = {saturation = 3},
    ["Potion_local_brew_01"] = {saturation = 3},
    ["potion_comberry_wine_01"] = {saturation = 3},
    ["potion_skooma_01"] = {saturation = 3},
    ["potion_local_liquor_01"] = {saturation = 3},
    ["p_vintagecomberrybrandy1"] = {saturation = 3}
}

local savedDrinks = {}

local function onConsume(potion)
    if morrowindDrinks[potion.recordId] then
        I.NeedsPlayer.relieveNeed("Thirst", morrowindDrinks[potion.recordId].saturation)
    elseif savedDrinks[potion.recordId] then
        print("saved thirst for  " .. potion.recordId)
        I.NeedsPlayer.relieveNeed("Thirst", savedDrinks[potion.recordId].saturation)
    else
        print("NO thirst for  " .. potion.recordId)
    end
end
local function addSavedDrink(data)
    savedDrinks[data.id] = {saturation = data.saturation}
    
end


return {
    interfaceName = "NeedsPlayer_Thirst",
    interface = {
        addSavedDrink = addSavedDrink,
    },
    engineHandlers = {
        onConsume = onConsume,
        onSave = function ()
            return {savedDrinks = savedDrinks}
        end,
        onLoad = function (data)
            if data then
                savedDrinks = data.savedDrinks
            end
        end
    },
    eventHandlers = {
        addSavedDrink = addSavedDrink,
    }
}