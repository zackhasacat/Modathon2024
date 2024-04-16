-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")
local input = require("openmw.input")
local ui = require("openmw.ui")
local async = require("openmw.async")
local util = require("openmw.util")
local self = require("openmw.self")
local vfs = require('openmw.vfs')
local types = require('openmw.types')
local storage = require('openmw.storage')
local I = require("openmw.interfaces")
local anim = require('openmw.animation')
local nearby = require('openmw.nearby')
local debug = require('openmw.debug')
local camera = require('openmw.camera')
local Camera = require('openmw.camera')
local rotOffset = 0
local function anglesToV(pitch, yaw)
    local xzLen = math.cos(pitch)
    return util.vector3(xzLen * math.sin(yaw), -- x
        xzLen * math.cos(yaw),                 -- y
        math.sin(pitch)                        -- z
    )
end
local function getCameraDirData(sourcePos)
    local pos = sourcePos
    local pitch, yaw

    pitch = -(Camera.getPitch() + Camera.getExtraPitch())
    yaw = (Camera.getYaw() + Camera.getExtraYaw())

    return pos, anglesToV(pitch, yaw)
end
local function getObjInCrosshairs(ignoreOb, mdist, alwaysPost, sourcePos) --Gets the object the player is looking at. Does not work in third person.
    if not sourcePos then
        sourcePos = Camera.getPosition()
    end
    local pos, v = getCameraDirData(sourcePos)

    local dist = 8500
    if (mdist ~= nil) then dist = mdist end

    local ret = nearby.castRenderingRay(pos, pos + v * dist, { ignore = self })
    local ret2 = nearby.castRay(pos, pos + v * dist, { ignore = self })
    local destPos = (pos + v * dist)

    return ret,ret2, destPos
end
local function createRotation(x, y, z)
    if (core.API_REVISION < 40) then
        return util.vector3(x, y, z)
    else
        local rotate = util.transform.rotateZ(z)
        local rotatex = util.transform.rotateX(x)
        local rotatey = util.transform.rotateY(y)
        rotate = rotate:__mul(rotatey)
        rotate = rotate:__mul(rotatex)
        return rotate
    end
end

local wasDrawing = false
local function placeNewArrow(arrowId)

    local xRot = camera.getPitch() - math.rad(rotOffset)
    local zRot = self.rotation:getAnglesZYX()
    local cast, cast2 = getObjInCrosshairs(self,nil,false,nil)
    if not cast.hitPos then
        return
    end
    if cast.hitObject and (cast.hitObject.type == types.NPC or cast.hitObject.type == types.Creature) then
        return
    end
    if cast2.hitObject and (cast2.hitObject.type == types.NPC or cast2.hitObject.type == types.Creature) then
        return
    end--Fired arrows will go through solid items, so need to check if it would have hit an NPC, otherwise you can get it stuck in a bottle, but still hit someone.

    local newRot = createRotation(xRot, 0, zRot)
    local newPos = cast.hitPos
    core.sendGlobalEvent("placeArrow", { rotation = newRot, id = arrowId ,position = newPos})
end
local function onFrame(dt)
  
    local drawing = self.controls.use == 1
    if drawing then
        wasDrawing = true
    elseif not drawing and wasDrawing then
        local weapon = types.Actor.getEquipment(self)[types.Actor.EQUIPMENT_SLOT.CarriedRight]

        local arrow = types.Actor.getEquipment(self)[types.Actor.EQUIPMENT_SLOT.Ammunition]
        if weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanBow then
            rotOffset = 0
        elseif weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanCrossbow then
            rotOffset = 0
        elseif weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanThrown then
            rotOffset = 180
            arrow = weapon
        else
            return
        end
        if not arrow then return end
        placeNewArrow(arrow.recordId)
        wasDrawing = false
    end
end
return {

    interfaceName = "ArrowStick",
    interface = {
        getArrowRotation = getArrowRotation,
    },
    eventHandlers = {
        showPlayerMessage = function(msg)
            ui.showMessage(msg)
        end
    },
    engineHandlers = {
        onFrame = onFrame,
    }
}
