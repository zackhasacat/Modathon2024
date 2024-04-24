local I = require("openmw.interfaces")
local ambient = require('openmw.ambient')
local async = require("openmw.async")
local core = require("openmw.core")
local self = require("openmw.self")
local ui = require("openmw.ui")
local util = require("openmw.util")
local types = require("openmw.types")
local input = require("openmw.input")

local utility = require("scripts.QuickSelect.qs_utility")
local tooltipData = require("scripts.QuickSelect.ci_tooltipgen")
local messageBoxUtil = require("scripts.QuickSelect.messagebox")
local QuickSelectWindow
local hoveredOverId
local columnsAndRows = {}
local selectedCol = 1
local selectedRow = 1

local num = 1
local scale = 0.8
local tooltip
local lis = {}

local slotToSave

local function mouseMove(mouseEvent, data)
    if tooltip then
        tooltip:destroy()
        tooltip = nil
    end
    if data.data.item then
        tooltip = utility.drawListMenu(tooltipData.genToolTips(data.data.item),
            utility.itemWindowLocs.BottomCenter, nil, "HUD")
        -- ui.showMessage("Mouse moving over icon" .. data.item.recordId)
    elseif data.data.data.spell then
        local spellRecord = core.magic.spells.records[data.data.data.spell]

        tooltip = utility.drawListMenu(tooltipData.genToolTips({ spell = spellRecord }),
            utility.itemWindowLocs.BottomCenter, nil, "HUD")
    end
end
local function mouseClick(mouseEvent, data)
    local id = data.id
    if data.props.spellData or data.spellData then
        local spell = data.props.spellData

        if not spell.id then
            --print("no id")
        end
        if spell.enchant then
            I.QuickSelect_Storage.saveStoredEnchantData(spell.enchant, spell.id, slotToSave)
         --   ui.showMessage("Saved enchant to slot " .. slotToSave)
        else
            I.QuickSelect_Storage.saveStoredSpellData(spell.id, "Spell", slotToSave)

          --  ui.showMessage("Saved spell to slot " .. slotToSave)
        end
        if QuickSelectWindow then
            QuickSelectWindow:destroy()
            QuickSelectWindow = nil
        end
        if tooltip then
            tooltip:destroy()
            tooltip = nil
        end
        I.UI.setMode()
        slotToSave = nil
        return
    else
    end
    if tooltip then
        tooltip:destroy()
        tooltip = nil
    end
    if data.data then
        if not slotToSave then
            messageBoxUtil.showMessageBox(nil, { core.getGMST("sQuickMenu1") },
                { core.getGMST("sQuickMenu2"), core.getGMST("sQuickMenu3"), core.getGMST("sQuickMenu4"), core.getGMST(
                    "sCancel") })
            -- ui.showMessage("Mouse moving over icon" .. data.item.recordId)
            if QuickSelectWindow then
                QuickSelectWindow:destroy()
                QuickSelectWindow = nil
            end
            if tooltip then
                tooltip:destroy()
                tooltip = nil
            end
            slotToSave = data.data.num
        elseif data.data.item then
            I.QuickSelect_Storage.saveStoredItemData(data.data.item.recordId, slotToSave)
            if QuickSelectWindow then
                QuickSelectWindow:destroy()
                QuickSelectWindow = nil
            end
            if tooltip then
                tooltip:destroy()
                tooltip = nil
            end
            I.UI.setMode()
            slotToSave = nil
        end
    end
end
local function mouseMoveButton(event, data)
    for index, value in ipairs(QuickSelectWindow.layout.content[1].content[2].content[1].content[1].content) do
        QuickSelectWindow.layout.content[1].content[2].content[1].content[1].content[index].content[1].content[1].template =
            I.MWUI.templates.textNormal
    end
    data.template = I.MWUI.templates.textHeader

    QuickSelectWindow:update()
end
local function renderButton(text)
    local itemTemplate
    itemTemplate = I.MWUI.templates.borders

    return {
        type = ui.TYPE.Container,
        --  events = {},
        template = itemTemplate,
        content = ui.content { utility.renderItemBold(text) },
    }
end
local function getSkillBase(skillID, actor)
    return types.NPC.stats.skills[skillID:lower()](actor).base
end
local function createItemIcon(item, spell, num)
    local icon
    if item and not spell then
        icon = I.Controller_Icon_QS.getItemIcon(item)
    else
        return {}
    end
    local boxedIcon = utility.renderItemBoxed(icon, util.vector2(utility.iconSize * 1.5, utility.iconSize * 1.5), nil,
        util.vector2(0.5, 0.5),
        { item = item, num = num } ,{
            mouseMove = async:callback(mouseMove),
            mouseClick = async:callback(mouseClick),
        })
    local padding = utility.renderItemBoxed(ui.content { boxedIcon },
        util.vector2(utility.iconSize * 1.5, utility.iconSize * 1.5),
        I.MWUI.templates.padding)
    return padding
end
local function getItemRow()
    local items = {}
    local inv = types.Actor.inventory(self):getAll()
    local count = num + 10
    while num < count do
        table.insert(items, createItemIcon(inv[num], nil, num))
        num = num + 1
    end
    return items
end
local function createHotbarItem(item, xicon, num, data)
    local icon
    if item and not xicon then
        icon = I.Controller_Icon_QS.getItemIcon(item)
    elseif xicon then
        icon = I.Controller_Icon_QS.getSpellIcon(xicon)
    elseif num then
        icon = ui.content {
            {
                type = ui.TYPE.Text,
                template = I.MWUI.templates.textNormal,
                props = {
                    text = tostring(num),
                    textSize = 20 * scale,
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
    local boxedIcon = utility.renderItemBoxed(icon, util.vector2(utility.iconSize * 1.5, utility.iconSize * 1.5), nil,
        util.vector2(0.5, 0.5),
        { item = item, num = num, data = data }, {
            mouseMove = async:callback(mouseMove),
            mouseClick = async:callback(mouseClick),
        })
    local padding = utility.renderItemBoxed(ui.content { boxedIcon }, util.vector2(utility.iconSize * 2, utility.iconSize * 2),
        I.MWUI.templates.padding)
    return padding
end
local function getHotbarItems()
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
        table.insert(items, createHotbarItem(item, icon, num, data))
        num = num + 1
    end
    return items
end
local function drawItemSelect()
    if QuickSelectWindow then
        QuickSelectWindow:destroy()
    end
    local xContent = {}
    local content  = {}
    num            = 1
    --Draw search menu

    table.insert(content, utility.renderItemBold(core.getGMST("sQuickMenu6")))

    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getItemRow(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    --rcontent = flexedItems(content,false)
    --   table.insert(content,flexedItems(lis, true))
    -- table.insert(content, imageContent(resource, size))
    content = ui.content(content)
    QuickSelectWindow = ui.create {
        layer = "Windows",
        template = I.MWUI.templates.boxTransparentThick
        ,
        props = {
            anchor = util.vector2(0.5, 0.5),
            relativePosition = util.vector2(0.5, 0.5),
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
                    --    size = util.vector2(0, 0),
                }
            }
        }
    }
end
local function getAllEnchantments(actorInv, onlyCastable)
    local ret = {}
    for index, value in ipairs(actorInv:getAll()) do
        local ench = utility.FindEnchantment(value)
        if (ench and not onlyCastable) then
            table.insert(ret, { enchantment = ench, item = value })
        elseif ench and onlyCastable and (ench.type == core.magic.ENCHANTMENT_TYPE.CastOnUse or ench.type == core.magic.ENCHANTMENT_TYPE.CastOnce) then
            table.insert(ret, { enchantment = ench, item = value })
        end
    end
    return ret
end
local function drawSpellSelect()
    if QuickSelectWindow then
        QuickSelectWindow:destroy()
    end
    local xContent = {}
    local content  = {}
    num            = 1
    --local trainerRow = utility.renderItemBoxed({}, util.vector2((160 * scale) * 7, 400 * scale),
    ---    I.MWUI.templates.padding)

    table.insert(content, utility.renderItemBold(core.getGMST("sMagicSelectTitle")))
    local spellsAndIds = {}
    for index, spell in ipairs(types.Actor.spells(self)) do
        if spell.type == core.magic.SPELL_TYPE.Power or spell.type == core.magic.SPELL_TYPE.Spell then
            table.insert(spellsAndIds, { id = spell.id, name = spell.name, type = "Spell" })
        end
    end
    for index, ench in ipairs(getAllEnchantments(types.Actor.inventory(self), true)) do
        table.insert(spellsAndIds,
            { id = ench.item.recordId, name = ench.item.type.record(ench.item).name, type = "Enchant", enchant = ench
            .item.type.record(ench.item).enchant })
        --print("ench nane" .. ench.item.type.record(ench.item).name)
    end
    for i = 1, 10, 1 do
        if spellsAndIds[i] then
            table.insert(xContent, utility.renderItemBold(spellsAndIds[i].name, nil, nil, nil, true, spellsAndIds[i],{
                mouseMove = async:callback(mouseMoveButton),
                mousePress = async:callback(mouseClick)
            }))
        end
    end
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(xContent, false), utility.scaledVector2(400, 300), I.MWUI.templates.borders,
            util.vector2(0.5, 0.5)))
    content = ui.content(content)
    QuickSelectWindow = ui.create {
        layer = "Windows",
        template = I.MWUI.templates.boxTransparentThick
        ,
        props = {
            anchor = util.vector2(0.5, 0.5),
            relativePosition = util.vector2(0.5, 0.5),
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
                    --    size = util.vector2(0, 0),
                }
            }
        }
    }
end
local function drawQuickSelect()
    if QuickSelectWindow then
        QuickSelectWindow:destroy()
    end
    local xContent = {}
    local content  = {}
    num            = 1
    --local trainerRow = utility.renderItemBoxed({}, util.vector2((160 * scale) * 7, 400 * scale),
    ---    I.MWUI.templates.padding)

    table.insert(content, utility.renderItemBold(core.getGMST("sQuickMenuTitle")))
    table.insert(content, utility.renderItemBold(core.getGMST("sQuickMenuInstruc")))

    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getHotbarItems(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getHotbarItems(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))
    table.insert(content,
        utility.renderItemBoxed(utility.flexedItems(getHotbarItems(), true), utility.scaledVector2(900, 100),
            I.MWUI.templates.padding,
            util.vector2(0.5, 0.5)))

    content = ui.content(content)
    QuickSelectWindow = ui.create {
        layer = "Windows",
        template = I.MWUI.templates.boxTransparentThick
        ,
        props = {
            anchor = util.vector2(0.5, 0.5),
            relativePosition = util.vector2(0.5, 0.5),
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
                    --    size = util.vector2(0, 0),
                }
            }
        }
    }
end

local function openQuickSelect()
    --I.UI.setMode("Interface", { windows = {} })
    drawQuickSelect()
end

local function UiModeChanged(data)
    if not data.newMode then
        if QuickSelectWindow then
            QuickSelectWindow:destroy()
            QuickSelectWindow = nil
        end
        if tooltip then
            tooltip:destroy()
            tooltip = nil
        end
        I.QuickSelect_Hotbar.drawHotbar()
        slotToSave = nil
    end
end

local function onKeyPress(key)
    if not QuickSelectWindow then return end

    local nextCol = selectedCol
    local nextRow = selectedRow
    if key.code == input.KEY.LeftArrow then
        nextCol = nextCol - 1
    elseif key.code == input.KEY.RightArrow then
        nextCol = nextCol + 1
    elseif key.code == input.KEY.DownArrow then
        nextRow = nextRow + 1
    elseif key.code == input.KEY.UpArrow then
        nextRow = nextRow - 1
    end
    if not columnsAndRows[nextCol] or not columnsAndRows[nextCol][nextRow] then

    else
        hoveredOverId = columnsAndRows[nextCol][nextRow]
        selectedCol = nextCol
        selectedRow = nextRow
        drawQuickSelect()
    end
end
local function onControllerButtonPress(id)
    if not QuickSelectWindow then return end

    local nextCol = selectedCol
    local nextRow = selectedRow
    if id == input.CONTROLLER_BUTTON.DPadLeft then
        nextCol = nextCol - 1
    elseif id == input.CONTROLLER_BUTTON.DPadRight then
        nextCol = nextCol + 1
    elseif id == input.CONTROLLER_BUTTON.DPadDown then
        nextRow = nextRow + 1
    elseif id == input.CONTROLLER_BUTTON.DPadUp then
        nextRow = nextRow - 1
    end
    if not columnsAndRows[nextCol] or not columnsAndRows[nextCol][nextRow] then

    else
        hoveredOverId = columnsAndRows[nextCol][nextRow]
        selectedCol = nextCol
        selectedRow = nextRow
        drawQuickSelect()
    end
end
I.UI.registerWindow(I.UI.WINDOW.QuickKeys, drawQuickSelect, function() --
    if QuickSelectWindow then
        QuickSelectWindow:destroy()
        QuickSelectWindow = nil
    end
    if tooltip then
        tooltip:destroy()
        tooltip = nil
    end
end)
local function ButtonClicked(data)
    local text = data.text
    num = 1
    if text == core.getGMST("sQuickMenu2") then
        drawItemSelect()
    elseif text == core.getGMST("sQuickMenu3") then
        drawSpellSelect()
    end
end
return {

    interfaceName = "QuickSelect_Win1",
    interface = {
        drawQuickSelect = drawQuickSelect,
        openQuickSelect = openQuickSelect,
        getQuickSelectWindow = function()
            return QuickSelectWindow
        end,
    },
    eventHandlers = {
        UiModeChanged = UiModeChanged,
        drawQuickSelect = drawQuickSelect,
        openQuickSelect = openQuickSelect,
        ButtonClicked = ButtonClicked,
    },
    engineHandlers = {
        onKeyPress = onKeyPress,
        onControllerButtonPress = onControllerButtonPress,
    }
}
