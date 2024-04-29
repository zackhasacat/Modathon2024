-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local rotOffset = 0
local rotOffset2 = 0
local compatMode = core.API_REVISION == 29


local function anglesToV(pitch, yaw)
    local xzLen = math.cos(pitch)
    return util.vector3(xzLen * math.sin(yaw), -- x
        xzLen * math.cos(yaw),                 -- y
        math.sin(pitch)                        -- z
    )
end
local getEquipment = types.Actor.getEquipment
if compatMode then
    getEquipment = types.Actor.equipment
end
local function getRotation(rot, angle)
    if compatMode then
        return rot
    else
        local z, y, x = rot:getAnglesZYX()
        return { x = x, y = y, z = z }
    end
end
local function getCameraDirData(sourcePos)
    local pos = sourcePos
    local pitch, yaw

    pitch = -(camera.getPitch() + camera.getExtraPitch())
    yaw = (camera.getYaw() + camera.getExtraYaw())

    return pos, anglesToV(pitch, yaw)
end

local function getObjInCrosshairs(ignoreOb, mdist, alwaysPost, sourcePos)
    if not sourcePos then
        sourcePos = camera.getPosition()
    end
    local pos, v = getCameraDirData(sourcePos)

    local dist = 8500
    if (mdist ~= nil) then dist = mdist end

    local ret = nearby.castRenderingRay(pos, pos + v * dist, { ignore = self })
    local ret2 = nearby.castRay(pos, pos + v * dist, { ignore = self })
    local destPos = (pos + v * dist)

    return ret, ret2, destPos
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
    local zRot = getRotation(self.rotation).z ---- math.rad(rotOffset2)
    local cast, cast2 = getObjInCrosshairs(self, nil, false, nil)
    if not cast.hitPos then
        return
    end
    if cast.hitObject and (cast.hitObject.type == types.NPC or cast.hitObject.type == types.Creature) then
        return
    end
    if cast2.hitObject and (cast2.hitObject.type == types.NPC or cast2.hitObject.type == types.Creature) then
        return
    end --Fired arrows will go through solid items, so need to check if it would have hit an NPC, otherwise you can get it stuck in a bottle, but still hit someone.

    local newRot = createRotation(xRot, 0, zRot)
    local newPos = cast.hitPos
    core.sendGlobalEvent("placeArrow", { rotation = newRot, id = arrowId, position = newPos ,actor = self.object})
end
local function onFrame(dt)
    local drawing = self.controls.use == 1
    if drawing then
        wasDrawing = true
    elseif not drawing and wasDrawing then
        local weapon = getEquipment(self)[types.Actor.EQUIPMENT_SLOT.CarriedRight]

        local arrow = getEquipment(self)[types.Actor.EQUIPMENT_SLOT.Ammunition]
        if weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanBow then
            rotOffset = 0
        elseif weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanCrossbow then
            rotOffset = 0
        elseif weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.MarksmanThrown then
            rotOffset = 180
            arrow = weapon
            return
        else
            return
        end
        if compatMode then
            rotOffset2 = 180
        end
        print(rotOffset)
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
    engineHandlers = {
        onFrame = onFrame,
    }
}
