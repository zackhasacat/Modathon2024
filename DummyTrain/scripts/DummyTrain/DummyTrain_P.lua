-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")

local self = require("openmw.self")
local types = require('openmw.types')
local nearby = require('openmw.nearby')
local camera = require('openmw.camera')
local util = require('openmw.util')
local I = require('openmw.interfaces')
local ui = require('openmw.ui')
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
local dummies = {
    furn_practice_dummy = true
}
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
    local dist = (destPos - pos):length()
    if ret.hitPos then
        dist = (ret.hitPos - pos):length()
    end
    return ret, ret2, destPos, dist
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
    core.sendGlobalEvent("placeArrow", { rotation = newRot, id = arrowId, position = newPos, actor = self.object })
end
local function calculateHitChance(weaponSkill, attackBonus, currentFatigue, maxFatigue, agility, luck)
    -- Calculate fatigue factor
    local fatigueFactor = 0.75 + 0.5 * (currentFatigue / maxFatigue)

    -- Calculate the hit chance
    local hitChance = (weaponSkill + attackBonus) * fatigueFactor + agility * 0.25 + luck * 0.125

    return hitChance
end
local weaponSkills = {
    [types.Weapon.TYPE.ShortBladeOneHand] = "shortBlade",
    [types.Weapon.TYPE.LongBladeOneHand] = "longBlade",
    [types.Weapon.TYPE.LongBladeTwoHand] = "longBlade",
    [types.Weapon.TYPE.BluntOneHand] = "bluntWeapon",
    [types.Weapon.TYPE.BluntTwoClose] = "bluntWeapon",
    [types.Weapon.TYPE.BluntTwoWide] = "bluntWeapon",
    [types.Weapon.TYPE.SpearTwoWide] = "spear",
    [types.Weapon.TYPE.AxeOneHand] = "axe",
    [types.Weapon.TYPE.AxeTwoHand] = "axe",
    [types.Weapon.TYPE.MarksmanBow] = "marksman",
    [types.Weapon.TYPE.MarksmanCrossbow] = "marksman",
    [types.Weapon.TYPE.MarksmanThrown] = "marksman",
    [types.Weapon.TYPE.Arrow] = "marksman",
    [types.Weapon.TYPE.Bolt] = "marksman",
}
local function getWeaponPlayerSkillLevel(weapon)
    if not weapon.type == types.Weapon then
        return 0
    end
    local weaponTYPE = weapon.type.record(weapon).type
    local skillId = weaponSkills[weaponTYPE]

    local statData = types.NPC.stats.skills[skillId:lower()]
    if not statData then
        error("unknown weapon type: " .. skillId)
    end
    return statData(self).modified,  skillId
end
local function onFrame(dt)
    local drawing = self.controls.use == 1
    if drawing then
        wasDrawing = true
    elseif not drawing and wasDrawing then
        local cast, cast2, pos, dist = getObjInCrosshairs(self, nil, false, nil)
        if not cast.hitPos then
            return
        end
        if not cast.hitObject then
            return
        end
        if not dummies[cast.hitObject.recordId] then
            return
        end
        local range = core.getGMST("fCombatDistance")
        local weapon = getEquipment(self)[types.Actor.EQUIPMENT_SLOT.CarriedRight]
        if weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.SpearTwoWide then
            range = range * 1.8
        elseif weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.BluntTwoClose then
            range = range * 1.5
        elseif weapon and weapon.type == types.Weapon and weapon.type.record(weapon).type == types.Weapon.TYPE.BluntTwoWide then
            range = range * 1.5
        end
        local inRange = dist < range
        local weaponSkillLevel, weaponSkill = getWeaponPlayerSkillLevel(weapon)
        local attackBonus = types.Actor.activeEffects(self):getEffect("fortifyattack").magnitude - types.Actor.activeEffects(self):getEffect("blind").magnitude
        local chance = calculateHitChance(getWeaponPlayerSkillLevel(weapon), attackBonus,
            types.Actor.stats.dynamic.fatigue(self).current, types.Actor.stats.dynamic.fatigue(self).base,
            types.Actor.stats.attributes.agility(self).modified, types.Actor.stats.attributes.luck(self).modified)
        local roll = math.random(0, 100)
        local hit = roll > chance
        if hit then
            print(weaponSkill)
            I.SkillProgression.skillUsed(weaponSkill:lower(), {skillGain = 1,useType = I.SkillProgression.SKILL_USE_TYPES.Weapon_SuccessfulHit})
            ui.showMessage("Miss: Firing at:" .. cast.hitObject.recordId .. "with chance " .. tostring(chance))
        else
            ui.showMessage("Hit: Firing at:" .. cast.hitObject.recordId .. "with chance " .. tostring(chance))
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
