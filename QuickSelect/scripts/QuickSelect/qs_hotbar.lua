local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local storage = require('openmw.storage')
local async = require('openmw.async')
local input = require('openmw.input')
local util = require('openmw.util')
local ui = require('openmw.ui')
local I = require('openmw.interfaces')

local settings = storage.playerSection("SettingsQuickSelect")
local tooltipData = require("scripts.QuickSelect.ci_tooltipgen")
local utility = require("scripts.QuickSelect.qs_utility")
local hotBarElement
local tooltipElement
local num = 1
local enableHotbar = false

local pickSlotMode = false

local selectedNum = 1
local function drawToolTip()
    local inv = types.Actor.inventory(self):getAll()
    local data = I.QuickSelect_Storage.getFavoriteItemData(num)

    local item
    local effect
    local icon
    local spell
    if data.item then
        item = inv:find(data.item)
    elseif data.spell or data.enchantId then
        if data.spellType:lower() == "spell" then
             spell = types.Actor.spells(self)[data.spell]
            if spell then
                spell = spell
            end
        elseif data.spellType:lower() == "enchant" then
            local enchant = utility.getEnchantment(data.enchantId)
            if enchant then
                spell = enchant
            end
        end
    end

    if item then
        tooltipElement = utility.drawListMenu(tooltipData.genToolTips(item),
            utility.itemWindowLocs.TopCenter, nil, "HUD")
        -- ui.showMessage("Mouse moving over icon" .. data.item.recordId)
    elseif spell then
        local spellRecord = core.magic.spells.records[data.data.data.spell]

        tooltipElement = utility.drawListMenu(tooltipData.genToolTips({ spell = spellRecord }),
            utility.itemWindowLocs.TopCenter, nil, "HUD")
    end
end
local function createHotbarItem(item, xicon, num, data, half)
    local icon
    local isEquipped = I.QuickSelect_Storage.isSlotEquipped(num)
    local sizeX = utility.iconSize
    local sizeY = utility.iconSize

    local selected = num == selectedNum
    if half then
        sizeY = sizeY / 2
    end
    if item and not xicon then
        icon = I.Controller_Icon_QS.getItemIcon(item, half, selected)
    elseif xicon then
        icon = I.Controller_Icon_QS.getSpellIcon(xicon, half, selected)
    elseif num then
        icon = I.Controller_Icon_QS.getEmptyIcon(half, num, selected)
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
                    --    --print("Spell" .. data.spell)
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
    if tooltipElement then
        tooltipElement:destroy()
        tooltipElement = nil
    end
    if not enableHotbar then
        return
    end
    local xContent         = {}
    local content          = {}
    num                    = 1 + (10 * I.QuickSelect.getSelectedPage())
    --local trainerRow = renderItemBoxed({}, util.vector2((160 * scale) * 7, 400 * scale),
    ---    I.MWUI.templates.padding)
    local showExtraHotbars = settings:get("showExtraHotbars")
    if showExtraHotbars then
        if I.QuickSelect.getSelectedPage() > 0 then
            num = 1 + (10 * (I.QuickSelect.getSelectedPage() - 1))
            table.insert(content,
                utility.renderItemBoxed(utility.flexedItems(getHotbarItems(true), true, util.vector2(0.5, 0.5)),
                    utility.scaledVector2(600, 100),
                    I.MWUI.templates.padding,
                    util.vector2(0.5, 0.5)))
        end
    end
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getHotbarItems(), true, util.vector2(0.5, 0.5)),
            utility.scaledVector2(800, 80),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    if showExtraHotbars then
        if I.QuickSelect.getSelectedPage() < 2 then
            table.insert(content,
                utility.renderItemBoxed(utility.flexedItems(getHotbarItems(true), true, util.vector2(0.5, 0.5)),
                    utility.scaledVector2(900, 100),
                    I.MWUI.templates.padding,
                    util.vector2(0.5, 0.5)))
        end
    end
    content = ui.content(content)
    hotBarElement = ui.create {
        layer = "HUD",
        template = I.MWUI.templates.padding
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
                    size = util.vector2(380, 40),
                }
            }
        }
    }
end
local data
local function selectSlot(item, spell, enchant)
    enableHotbar = true
    pickSlotMode = true
    print(item,spell,enchant)
    data = { item = item, spell = spell, enchant = enchant }
    drawHotbar()
end
local function saveSlot()
    if pickSlotMode then
        local selectedSlot = selectedNum + (I.QuickSelect.getSelectedPage() * 10)
        if data.item and not data.enchant then
            I.QuickSelect_Storage.saveStoredItemData(data.item, selectedSlot)
        elseif data.spell then
            I.QuickSelect_Storage.saveStoredSpellData(data.spell, "Spell", selectedSlot)
        elseif data.enchant then
            I.QuickSelect_Storage.saveStoredEnchantData(data.enchant, data.item, selectedSlot)
        end
        enableHotbar = false
        pickSlotMode = false
        data = nil
    end
end
local function UiModeChanged(data)
    if  data.newMode then
      if pickSlotMode then
        pickSlotMode = false
        enableHotbar = false
        drawHotbar()
      end
    end
end
return {
    --I.QuickSelect_Hotbar.drawHotbar()
    interfaceName = "QuickSelect_Hotbar",
    interface = { drawHotbar = drawHotbar,
    selectSlot = selectSlot,
    },
    eventHandlers = {
        UiModeChanged = UiModeChanged,
    },
    engineHandlers = {
        onControllerButtonPress = function(btn)
            if core.isWorldPaused() and not pickSlotMode then
                return
            end
            if btn == input.CONTROLLER_BUTTON.LeftShoulder or btn == input.CONTROLLER_BUTTON.DPadLeft then
                if not enableHotbar then
                    enableHotbar = true
                    I.QuickSelect_Hotbar.drawHotbar()
                    return
                end
                selectedNum = selectedNum - 1
                if selectedNum < 1 then
                    selectedNum = 10
                end
                I.QuickSelect_Hotbar.drawHotbar()
                drawToolTip()
            elseif btn == input.CONTROLLER_BUTTON.RightShoulder or btn == input.CONTROLLER_BUTTON.DPadRight then
                if not enableHotbar then
                    enableHotbar = true
                    I.QuickSelect_Hotbar.drawHotbar()
                    return
                end
                selectedNum = selectedNum + 1
                if selectedNum > 10 then
                    selectedNum = 1
                end
                I.QuickSelect_Hotbar.drawHotbar()
                drawToolTip()
            elseif btn == input.CONTROLLER_BUTTON.A then
                if not enableHotbar then
                    return
                end
                if pickSlotMode then
                    saveSlot()
                    I.QuickSelect_Hotbar.drawHotbar()
                    return
                end
                print("EQUP ME"  )
                I.QuickSelect_Storage.equipSlot(selectedNum + (I.QuickSelect.getSelectedPage() * 10))
                enableHotbar = false
                I.QuickSelect_Hotbar.drawHotbar()
            elseif btn == input.CONTROLLER_BUTTON.B then
                if enableHotbar then
                    enableHotbar = false
                    I.QuickSelect_Hotbar.drawHotbar()
                end
            end
        end
    }
}
