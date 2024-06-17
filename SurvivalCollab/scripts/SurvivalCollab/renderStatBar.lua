local core = require('openmw.core')
local ui = require('openmw.ui')
local util = require('openmw.util')
local async = require('openmw.async')
local storage = require('openmw.storage')
local types = require('openmw.types')
local I = require('openmw.interfaces')
local showBarLabel = true
local renderStat
local bit8 = 255
local statColors = {
    hunger = util.color.rgb(255 / bit8, 165 / bit8, 0 / bit8),     -- Orange for hunger
    thirst = util.color.rgb(0 / bit8, 121 / bit8, 255 / bit8),    -- Blue for thirst
    energy = util.color.rgb(255 / bit8, 0 / bit8, 0 / bit8),    -- Dark blue for sleep/energy
}
local statTexture = ui.texture({ path = 'textures/menu_bar_gray.dds' })
local statSize = util.vector2(65, 13)
local function contEncumbranceData(cont)
    local encumCurrent = cont.type.getEncumbrance(cont)

    local baseCapac = 10
    if cont.type.getCapacity then
        baseCapac = cont.type.getCapacity(cont)
    end
    return { current = encumCurrent, base = baseCapac }
end
renderStat = function(actor, key,value,max,text)
    local currentVal = value
    local baseVal    = max
key = key:lower()
   
    local ratio = currentVal / baseVal

    local label
    local textToShow = ('%i/%i'):format(math.floor(currentVal), math.floor(baseVal))
    if text then
        textToShow = text
    end
    if showBarLabel then
        label = {
            type = ui.TYPE.Text,
            props = {
                relativePosition = util.vector2(0.5, 0.5),
                anchor = util.vector2(0.5, 0.5),
                text = textToShow,
                textColor = util.color.rgb(1, 1, 1),
                textSize = statSize.y,
            },
        }
    end
    return {
        template = I.MWUI.templates.boxTransparent,
        content = ui.content({
            {
                props = {
                    size = statSize,
                },
                content = ui.content({
                    {
                        name = 'image',
                        type = ui.TYPE.Image,
                        props = {
                            size = statSize:emul(util.vector2(ratio, 1)),
                            resource = statTexture,
                            color = statColors[key],
                        },
                    },
                    label,
                }),
            },
        }),
    }
end

return { renderStat = renderStat, contEncumbranceData = contEncumbranceData }
