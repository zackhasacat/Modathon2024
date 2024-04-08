local I = require("openmw.interfaces")

local v2 = require("openmw.util").vector2
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local storage = require("openmw.storage")
local world = require("openmw.world")
local async = require("openmw.async")
local SlaveScript = "scripts/advanced_slavery/slave.lua"

local function getInventory(object)
  --Gets the inventory of an object, actor or container.
  if (object.type == types.NPC or object.type == types.Creature or object.type ==
        types.Player) then
    print("actor")
    return types.Actor.inventory(object)
  elseif (object.type == types.Container) then
    return types.Container.content(object)
  end
  print("no?")
end
local function transferInventories(fromInv, toInv)
  fromInv = getInventory(fromInv)
  toInv = getInventory(toInv)
  for index, item in ipairs(fromInv:getAll()) do
    item:moveInto(toInv)
  end
end
local function transferInventoriesEvent(data)
  transferInventories(data.fromInv, data.toInv)
end
local function slaveCanBeBought(actor)
if not world.mwscript.getLocalScript(actor) then
  return false
end

  local val = world.mwscript.getLocalScript(actor).variables.slavestatus
  
  if not val then return false end
  if actor.cell.name == "Suran, Slave Market" then
    return true
  end
end
local function createMisc(name)
  local miscitem = {
    name = name,
    weight = 0.1,
    value = 10,
    icon = "icons\\m\\tx_key_standard_01.dds",
    model = "meshes\\m\\Key_Standard_01.NIF"
  }
  local ret = types.Miscellaneous.createRecordDraft(miscitem)
  local record = world.createRecord(ret)
  local item = world.createObject(record.id, 1)
  return item
end
local function makeSlave(npc)
  if (npc:hasScript(SlaveScript) == false) then
    local NPCKey = createMisc("Key to " .. types.NPC.record(npc).name .. "'s slave bracer")
    NPCKey:moveInto(world.players[1])
    local bracerCount1 = types.Actor.inventory(npc):countOf("slave_bracer_left")
    local bracerCount2 = types.Actor.inventory(npc):countOf("slave_bracer_right")
    local newBracer
    if bracerCount1 + bracerCount2 == 0 then
      newBracer = world.createObject("slave_bracer_left")
      newBracer:moveInto(npc)
    end
    npc:addScript(SlaveScript, { newBracer = newBracer })
  end
end
local spokenToActor
local function onItemActive(item)
  if item.recordId == "zhac_luareturn_item" then
    item:remove()
    local val = world.mwscript.getGlobalVariables(world.players[1]).zhac_luareturn
    if val == 1 then
      --companion share
      world.players[1]:sendEvent("AS_compshare", spokenToActor)
      async:newUnsavableSimulationTimer(0.1, function()
       spokenToActor:sendEvent("equipBracer")
      end)
    end

    world.mwscript.getGlobalVariables(world.players[1]).zhac_luareturn = 0
  end
end
local function checkSlave(actor)
  if world.mwscript.getLocalScript(actor) then
    local val = world.mwscript.getLocalScript(actor).variables.slavestatus
    if val and val == 2 and not actor:hasScript(SlaveScript) then
makeSlave(actor)
    end
  end
end
local function activateNPC(actor, player)
  if actor:hasScript(SlaveScript) then
    spokenToActor = actor
    world.mwscript.getGlobalVariables(player).zhac_talkingtoslave = 1
    async:newUnsavableSimulationTimer(0.1, function()
      world.mwscript.getGlobalVariables(player).zhac_talkingtoslave = 0
    end)
  else
    async:newUnsavableSimulationTimer(0.1, function()
      checkSlave(actor)
    end)
  end
end

I.Activation.addHandlerForType(types.NPC, activateNPC)
return {
  interfaceName  = "SlaveScript",
  interface      = {
    version = 1,
    makeSlave = makeSlave,
  },
  engineHandlers = {
    onActorActive = onActorActive,
    onPlayerAdded = onPlayerAdded,
    onLoad = onLoad,
    onItemActive = onItemActive,
  },
  eventHandlers  = {
    CompShare = CompShare,
    transferInventoriesEvent = transferInventoriesEvent,
    setSetting = setSetting,
    runMWscriptBridge = runMWscriptBridge,
    COCEvent = COCEvent,
    killAll = killAll,
    DebugActorSwap = DebugActorSwap,
    DoUnlock = DoUnlock,
    setOwner = setOwner,
    setOwnerFaction = setOwnerFaction,
    findAllRefs = findAllRefs,
    moveToId = moveToId,
    onFrame = onFrame,
    purgeMod = purgeMod,
    findRecordByName = findRecordByName,
    showDisabled = showDisabled,
    makeSlave = makeSlave,
  },
}
