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
            name = "Show Hotbar at all times",
            description =
            "If enabled, the hotbar will be visible at any time. If disabled, the hotbar will only be visible a hotkey is used, then will close when one is selected.",
            default = true
        },
        {
            key = "unEquipOnHotkey",
            renderer = "checkbox",
            name = "Unequip when selecting equipped items",
            description =
            "If enabled, selecting an item that is already equipped will unequip it. If disabled, selecting an item that is already equipped will do nothing.",
            default = true
        }
    },

}
settings:get("unEquipOnHotkey")
return settings