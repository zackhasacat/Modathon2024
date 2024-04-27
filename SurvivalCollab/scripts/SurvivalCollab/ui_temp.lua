local cam = require('openmw.interfaces').Camera
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local storage = require("openmw.storage")
local I = require("openmw.interfaces")
local input = require("openmw.input")
local calendar = require('openmw_aux.calendar')
local time = require('openmw_aux.time')
local multilineText = [[
This is line one of the text.
This is line two of the text.
This is line three of the text.
]]
local element
local function textToShow()
    local needs = I.NeedsPlayer.getNeeds()
    local ls = {}
    for index, value in ipairs(needs) do
        table.insert(ls,value.name .. ": " .. tostring(math.ceil(value.current)) .. "/" .. tostring(value.base))
    end
    return ls
end
local function flexedItems(content, horizontal)
    if not horizontal then
        horizontal = false
    end
    return ui.content {
        {
            type = ui.TYPE.Flex,
            content = ui.content(content),
            events = {
            },
            props = {
                horizontal = horizontal,
                align = ui.ALIGNMENT.Start,
                arrange = ui.ALIGNMENT.Start,
            }
        }
    }
end

local function textContent(text, template, color)
    local tsize = 15
    if not color then
        template = I.MWUI.templates.textNormal
        color = template.props.textColor
    elseif color == "red" then
        template = I.MWUI.templates.textNormal
        color = util.color.rgba(5, 0, 0, 1)
    else
        template = I.MWUI.templates.textHeader
        color = template.props.textColor
        --  tsize = 20
    end

    return {
        type = ui.TYPE.Text,
        template = template,
        props = {
            text = tostring(text),
            textSize = tsize,
            arrange = ui.ALIGNMENT.Center,
            align = ui.ALIGNMENT.Center,
            textColor = color
        }
    }
end
local function updateElement()
    if element then
        element:destroy()
    end
    local content = {}
    local lines = textToShow()
    for index, value in ipairs(lines) do
        table.insert(content,textContent(value))
    end
    element = ui.create {
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
                content = ui.content(content),
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
return {
    interfaceName = "NeedsPlayer_UI",
    interface = {
        updateElement = updateElement,
    },
    engineHandlers = {
    },
    eventHandlers = {
    }
}
