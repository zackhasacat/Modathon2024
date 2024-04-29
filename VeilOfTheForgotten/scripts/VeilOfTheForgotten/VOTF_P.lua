-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local ui = require('openmw.ui')
local ambient = require('openmw.ambient')
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

    local ret = nearby.castRay(pos, pos + v * dist, { ignore = self })
    local destPos = (pos + v * dist)

    return ret
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
local pendingReturnWeapon
local returnPos
local returnDelay = 0
local function returnPendingActor()
    core.sendGlobalEvent("releaseAtTarget", { weapon = pendingReturnWeapon, pos = returnPos })
    pendingReturnWeapon = nil
end
local function findVictim(release, weapon)
    local xRot = camera.getPitch() - math.rad(rotOffset)
    local zRot = getRotation(self.rotation).z ---- math.rad(rotOffset2)
    local cast = getObjInCrosshairs(self, nil, false, nil)

    if release and not cast.hitPos and weapon then
        print("no hit")
        --give the item back
        core.sendGlobalEvent("returnItem", { itemId = weapon, actor = self })
        ui.showMessage("Your globe has been returned to you.")
        return
    elseif not release and not cast.hitPos then
        return
    end

    local navMeshPosition = nearby.findNearestNavMeshPosition(cast.hitPos)
    if not navMeshPosition and weapon then
        core.sendGlobalEvent("returnItem", { itemId = weapon, actor = self })
        ui.showMessage("Your globe has been returned to you.")
        return
    end
    local dist
    if weapon then
        dist = (cast.hitPos - navMeshPosition):length()
        print(dist)
        if dist > 200 then
            core.sendGlobalEvent("returnItem", { itemId = weapon, actor = self })
            ui.showMessage("Your globe has been returned to you.")
            return
        end
        local path = nearby.findPath(self.position, navMeshPosition,{includeFlags = nearby.NAVIGATOR_FLAGS.Walk})
        if path ~= nearby.FIND_PATH_STATUS.Success then
            core.sendGlobalEvent("returnItem", { itemId = weapon, actor = self })
            ui.showMessage("Your globe has been returned to you.")
            return
        end
    end
    if release and cast.hitPos then
        pendingReturnWeapon = weapon
        returnPos = navMeshPosition
        returnDelay = 3
        return
    end
    if cast.hitObject and (cast.hitObject.type == types.NPC or cast.hitObject.type == types.Creature) then
        ui.showMessage("Hitting " .. cast.hitObject.type.record(cast.hitObject).name)
        cast.hitObject:sendEvent("checkForCapture")
        return
    end
end
local function onFrame(dt)
    local drawing = self.controls.use == 1
    if pendingReturnWeapon and ambient.isSoundPlaying("destruction area") then
        returnDelay = 0
    elseif pendingReturnWeapon and returnDelay > 0 then
        returnDelay = returnDelay - dt
    end
    if returnPendingActor and returnDelay <= 0 then
        returnPendingActor()
        returnDelay = 0
    end
    if drawing then
        wasDrawing = true
    elseif not drawing and wasDrawing then
        local weapon = getEquipment(self)[types.Actor.EQUIPMENT_SLOT.CarriedRight]
        if not weapon then
            error("No weapon equipped")
        end
        if weapon.recordId == "zhac_ball_01" then
            findVictim()
        else
            print(weapon.recordId)
            findVictim(true, weapon.recordId)
        end
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