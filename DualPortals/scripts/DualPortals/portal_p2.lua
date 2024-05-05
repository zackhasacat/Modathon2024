-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")
local I = require('openmw.interfaces')
if core.API_REVISION < 59 then
    I.Settings.registerPage {
        key = "SettingsVOTF",
        l10n = "SettingsVOTF",
        name = "Veil of the Forgotten",
        description = "Your OpenMW version is out of date. Please download a version of 0.49 from April 2024 or newer."
    }
    return {}
end
local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local ui = require('openmw.ui')
local ambient = require('openmw.ambient')
local anim = require('openmw.animation')
local rotOffset = 0
local rotOffset2 = 0

local hitPoint
local compatMode = core.API_REVISION == 29

local settings = require("scripts.VeilOfTheForgotten.settings")
local function getMyBall(actorId)
    if actorId == "tr_m2_darvon golaren" then
        return "zhac_ball_02"
    else
        return "zhac_ball_01"
    end
end
I.Settings.registerPage {
    key = "SettingsVOTF",
    l10n = "SettingsVOTF",
    name = "Veil of the Forgotten",
    description = "These settings allow you to modify the behavior of Veil of the Forgotten."
}
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
local waitForAnim = false
local function onFrame(dt)
    local drawing = self.controls.use == 1
    local activeSpell = types.Actor.getSelectedSpell(self)
    local stance = types.Actor.getStance(self)
    if stance ~= types.Actor.STANCE.Spell then
        return
    end
    if activeSpell.id ~= "zhac_spell_portal_1" and activeSpell.id ~= "zhac_spell_portal_2" then
        return
    end
    local num = 1
    if activeSpell.id == "zhac_spell_portal_2" then
        num = 2
    end
    if pendingReturnWeapon and ambient.isSoundPlaying("mysticism area") then
        if hitPoint then
            core.sendGlobalEvent("createPortalAt", { id = num, cell = self.cell.name, position = hitPoint, x = self.cell.gridX, y = self.cell.gridY})
            I.ZS_DualPortals.startPortalAnim(hitPoint,num)
            -- hitPoint = nil
            pendingReturnWeapon = false
        end
    end
    if drawing then
        wasDrawing = true
    elseif not drawing and wasDrawing then
        wasDrawing = false
        waitForAnim = true
    end
    if waitForAnim then
        local currentAnim = anim.getActiveGroup(self, 3)
        if currentAnim == "spellcast" then
            local stage = anim.getCurrentTime(self, "spellcast")
            if stage > 196.54 then
                waitForAnim = false
                hitPoint = getObjInCrosshairs().hitPos
                ui.showMessage("cast")
                pendingReturnWeapon = true
            end
        end
    end
end
return {

    interfaceName = "ArrowStick",
    interface = {
        getArrowRotation = getArrowRotation,
    },
    engineHandlers = {
        onFrame = onFrame,
    },
    eventHandlers = {
        openCompShare = function(actor)
            I.UI.setMode(I.UI.MODE.Companion, { target = actor })
        end,
        returnPendingActor = returnPendingActor,
    }
}
