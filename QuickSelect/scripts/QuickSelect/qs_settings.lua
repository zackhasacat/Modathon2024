local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local storage = require('openmw.storage')
local async = require('openmw.async')
local util = require('openmw.util')
local ui = require('openmw.ui')
local I = require('openmw.interfaces')

local settings = storage.playerSection("SettingsQuickSelect")

I.Settings.registerPage {
    key = "SettingsQuickSelect",
    l10n = "SettingsQuickSelect",
    name = "QuickSelect",
    description = "These settings allow you to modify the behavior of the Quickselect bar."
}
I.Settings.registerGroup {
    key = "SettingsQuickSelect",
    page = "SettingsQuickSelect",
    l10n = "SettingsQuickSelect",
    name = "Main Settings",
    permanentStorage = true,

    settings = {
        {
            key = "previewOtherHotbars",
            renderer = "checkbox",
            name = "Show Next and Previous Hotbars",
            description =
            "If enabled, a preview of the next and previous hotbars will be shown above and below the current hotbar.",
            default = false
        },
        {
            key = "persistMode",
            renderer = "checkbox",
            name = "Enable Legacy Summon",
            description =
            "If Legacy Summon is enabled, the summon spell will attempt to teleport to a predetermined location, if it can't find one, it will use the position in front of you.",
            default = false
        }
    },

}
return settings