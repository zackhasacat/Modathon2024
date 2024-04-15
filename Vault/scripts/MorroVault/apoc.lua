local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, async = pcall(require, "openmw.async")
local anim = require('openmw.animation')

local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end

local function isInVault(obj)
   return startsWith(obj.cell.name, "Resdaynia Sanctuary")
end

local function onActorActive(act)
    if not isInVault(act) then
        act:remove()
    end
end
local function onObjectActive(act)
    if act.type == types.Light then
        if not isInVault(act) then
            act:remove()
            act.enabled = false
            print("Kill light")
        end
    end
end
return
{
    engineHandlers = {
        onObjectActive = onObjectActive,
        onActorActive = onActorActive,
    },
    eventHandlers = {
    }
}
