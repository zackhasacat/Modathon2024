local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require("openmw.async")
local core = require("openmw.core")

local function onItemActive(item)
    if not item.contentFile then
        
--print(item.id)
    end
end
--After an item is dropped, it will be marked as player owned, if the current location is not a "safe" location.

--Only player homes are safe. Rented inn rooms are also safe.

--After 24 hours(configurable), the item will be confiscated, and moved into a special container. The player may speak to a guard in the same cell as an evidence chest to retrieve it.

--They must pay a 25% fee for all items retrieved.

--Additionally, the item may go into a holding list for a week until it may be retrieved.
return {
    interfaceName = "ZS_ItemDecay",
    interface = {
    },
    engineHandlers = {
        onItemActive = onItemActive,
    },
    eventHandlers = {
    }
}
