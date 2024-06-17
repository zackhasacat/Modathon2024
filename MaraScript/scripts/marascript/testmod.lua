local ms_core = require("scripts.marascript.ms_core")

local modData = ms_core.init("testmod")
local val 

modData:addEvent("onUpdate", function(dt)
    if not val then
      val  = modData:getData("val") or 0
    end
    val = val + 1
    modData:setData("val", val)
end)

return modData:returnTable()