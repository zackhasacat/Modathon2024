local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local async = require('openmw.async')
local util = require('openmw.util')
local ui = require('openmw.ui')
local I = require('openmw.interfaces')

local utility = require("scripts.QuickSelect.qs_utility")
local hotBarElement
local num = 1
local function createHotbarItem(item, xicon, num, data, half)
    local icon
    local isEquipped = I.QuickSelect_Storage.isSlotEquipped(num)
    local sizeX = utility.iconSize
    local sizeY = utility.iconSize
    if half then
        sizeY = sizeY / 2
    end
    if item and not xicon then
        icon = I.Controller_Icon.getItemIcon(item, half)
    elseif xicon then
        icon = I.Controller_Icon.getSpellIcon(xicon, half)
    elseif num then
        icon = ui.content {
            {
                type = ui.TYPE.Text,
                template = I.MWUI.templates.textNormal,
                props = {
                    text = tostring(num),
                    textSize = 20 * 1,
                    relativePosition = util.vector2(0.5, 0.5),
                    anchor = util.vector2(0.5, 0.5),
                    arrange = ui.ALIGNMENT.Center,
                    align = ui.ALIGNMENT.Center,
                },
                item = item,
                num = num,
                events = {
                    --          mouseMove = async:callback(mouseMove),
                },
            }
        }
    end
    local boxedIcon = utility.renderItemBoxed(icon, util.vector2(sizeX * 1.5, sizeY * 1.5), nil,
        util.vector2(0.5, 0.5),
        { item = item, num = num, data = data })
    local paddingTemplate = I.MWUI.templates.padding
    if isEquipped then
        paddingTemplate = I.MWUI.templates.borders
    end
    local padding = utility.renderItemBoxed(ui.content { boxedIcon },
        util.vector2(sizeX * 2, sizeY * 2),
        paddingTemplate, util.vector2(0.5, 0.5))
    return padding
end
local function getHotbarItems(half)
    local items = {}
    local inv = types.Actor.inventory(self):getAll()
    local count = num + 10
    while num < count do
        local data = I.QuickSelect_Storage.getFavoriteItemData(num)
        print(num)
        local item
        local effect
        local icon
        if data.item then
            item = types.Actor.inventory(self):find(data.item)
        elseif data.spell or data.enchantId then
            if data.spellType:lower() == "spell" then
                local spell = types.Actor.spells(self)[data.spell]
                if spell then
                    effect = spell.effects[1]
                    icon = effect.effect.icon
                    --    print("Spell" .. data.spell)
                end
            elseif data.spellType:lower() == "enchant" then
                local enchant = utility.getEnchantment(data.enchantId)
                if enchant then
                    effect = enchant.effects[1]
                    icon = effect.effect.icon
                end
            end
        end
        table.insert(items, createHotbarItem(item, icon, num, data, half))
        num = num + 1
    end
    return items
end
local function drawHotbar()
    if hotBarElement then
        hotBarElement:destroy()
    end
    local xContent = {}
    local content  = {}
    num            = 1 + (10 * I.QuickSelect.getSelectedPage())
    --local trainerRow = renderItemBoxed({}, util.vector2((160 * scale) * 7, 400 * scale),
    ---    I.MWUI.templates.padding)
    
    if I.QuickSelect.getSelectedPage() > 0 then
        
    num            = 1 + (10 * (I.QuickSelect.getSelectedPage() - 1))
        table.insert(content,
            utility.renderItemBoxed(utility.flexedItems(getHotbarItems(true), true, util.vector2(0.5, 0.5)),
                utility.scaledVector2(900, 100),
                I.MWUI.templates.padding,
                util.vector2(0.5, 0.5)))
    end
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getHotbarItems(), true, util.vector2(0.5, 0.5)),
            utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    if I.QuickSelect.getSelectedPage() <2 then
        table.insert(content,
            utility.renderItemBoxed(utility.flexedItems(getHotbarItems(true), true, util.vector2(0.5, 0.5)),
                utility.scaledVector2(900, 100),
                I.MWUI.templates.padding,
                util.vector2(0.5, 0.5)))
    end
    content = ui.content(content)
    hotBarElement = ui.create {
        layer = "HUD",
        template = I.MWUI.templates.boxTransparentThick
        ,
        props = {
            anchor = util.vector2(0.5, 1),
            relativePosition = util.vector2(0.5, 1),
            arrange = ui.ALIGNMENT.Center,
            align = ui.ALIGNMENT.Center,
        },
        content = ui.content {
            {
                type = ui.TYPE.Flex,
                content = content,
                props = {
                    horizontal = false,
                    align = ui.ALIGNMENT.Center,
                    arrange = ui.ALIGNMENT.Center,
                    size = util.vector2(400, 40),
                }
            }
        }
    }
end

return {
    --I.QuickSelect_Hotbar.drawHotbar()
    interfaceName = "QuickSelect_Hotbar",
    interface = { drawHotbar = drawHotbar,
    },
    engineHandlers = {
        onInputAction = onInputAction,
    }
}
