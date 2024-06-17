local file = {}
local interFaceLoaded, I = pcall(require, "openmw.interfaces")

local utilLoaded, util = pcall(require, "openmw.util")
local coreLoaded, core = pcall(require, "openmw.core")
local typesLoaded, types = pcall(require, "openmw.types")
local storageLoaded, storage = pcall(require, "openmw.storage")
local worldLoaded, world = pcall(require, "openmw.world")
local mwse = not coreLoaded
function file.getPlayer()
    if (mwse) then
        return tes3.player
    end
    for index, value in ipairs(world.activeActors) do
        if (value.type == types.Player) then
            return value
        end
    end
end

return file