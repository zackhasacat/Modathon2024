local I = require('openmw.interfaces')

local storage = require("openmw.storage")
local settings = storage.playerSection("SettingsNeedsZHAC")

I.Settings.registerPage {
    key = "SettingsNeedsZHAC",
    l10n = "SettingsNeedsZHAC",
    name = "ZHAC Needs",
    description = "These settings allow you to modify the behavior of the Quickselect bar."
}


I.Settings.registerGroup {
    key = "SettingsNeedsZHAC",
    page = "SettingsNeedsZHAC",
    l10n = "SettingsNeedsZHAC",
    name = "Main Settings",
    permanentStorage = true,

    settings = {
        {
            key = "Hungerbase",
            renderer = "number",
            name = "Hunger Base",
         default = 0
        },
        {
            key = "Hungerdecay",
            renderer = "number",
            name = "Hunger Decay",
         default = 0
        },
    },

}