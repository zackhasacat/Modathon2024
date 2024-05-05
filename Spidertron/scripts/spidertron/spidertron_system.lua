local cam = require('openmw.interfaces').Camera
local camera = require('openmw.camera')
local core = require('openmw.core')
local self = require('openmw.self')
local nearby = require('openmw.nearby')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')
local storage = require("openmw.storage")
local async = require("openmw.async")
local input = require("openmw.input")
local calendar = require('openmw_aux.calendar')

local torsoRecordId = "ZHAC_Spider_Torso"
local legRecordId = "ZHAC_Spider_Leg"

local mainObjId
local mainObj
local legObjIds = {}
local legObjs = {}

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

local function constructSpidertron(position)
    mainObjId = nil
    mainObj = nil
    legObjIds = {}
    legObjs = {}
    core.sendGlobalEvent("createSpidertronObj", position)
end
local function onSpidertronCreated(data)
    local torso = data.torso
    local legs = data.legs
    mainObjId = torso.id
    mainObj = torso
    for index, value in ipairs(legs) do
        table.insert(legObjIds, value.id)
        table.insert(legObjs, value)
    end
end

local function objCreateReturn()

end

local function findLegObjs()
    if mainObjId and #legObjs > 0 then
        return
    end
    local foundLegs = 0

    for index, acti in ipairs(nearby.activators) do
        if acti.id == mainObjId then
            mainObj = acti
        else
            for index, legId in ipairs(legObjIds) do
                print(legId)
                if acti.id == legObjIds[index] then
                    table.insert(legObjs, acti)
                    foundLegs = foundLegs + 1
                end
            end
        end
    end
    return foundLegs
end
local function rayCast(position)
    local pos1 = position + util.vector3(0, 0, 10000)
    local pos2 = position + util.vector3(0, 0, -1000)

    local ret = nearby.castRay(pos1, pos2, { collisionType = nearby.COLLISION_TYPE.HeightMap })
    if not ret.hitPos then
        error("unable to find hit")
    end
    return ret.hitPos
end
local function transformToAngles(t)
	local x, y, z

	--z, y, x = t:getAnglesZYX() -- Broken in OpenMW

	-- Temporary replacement code
	local forward = t * util.vector3(0, 1, 0)
	local up = t * util.vector3(0, 0, 1)
	forward = forward:normalize()
	up = up:normalize()

	if math.abs(up.z) < 1e-5 then
		x = -0.5 * math.pi
		y = math.atan2(-up.x, -up.y)
	else
		x = math.atan2(up.y, up.z)
		y = -math.asin(up.x)
	end
	local fz = (util.transform.rotateY(-y) * util.transform.rotateX(-x)) * forward
	z = math.atan2(fz.x, fz.y)

	return { x = x, y = y, z = z }
end

local function setLegZRot(angle, legNum)
    if not mainObjId or #legObjs == 0 then
        findLegObjs()
    end
    local rotation = createRotation(0, 0, math.rad(angle))
    core.sendGlobalEvent("teleportAsNeeded", { obj = legObjs[legNum], rot = rotation })
end
local function getObjects()
    local ret = {}
    for index, value in ipairs(legObjs) do
        table.insert(ret, value)
    end
    table.insert(ret, mainObj)
    return ret
end
local function rotateVector2D(vec, angle)
    local cosA = math.cos(angle)
    local sinA = math.sin(angle)
    local x = vec.x * cosA - vec.y * sinA
    local y = vec.x * sinA + vec.y * cosA
    return util.vector3(x, y, 0)
end
local function getObjCorners(obj, num, posOffset,rotation)
    local pos = obj.position + posOffset
    local box = obj:getBoundingBox()
    local halfSize = obj:getBoundingBox().halfSize
    local corners = {}
    local rotationZ =rotation - math.rad(90)

    -- Calculate sine and cosine of rotation angle
    local cosZ = math.cos(rotationZ)
    local sinZ = math.sin(rotationZ)
    local angle = -rotationZ

    -- Calculate rotated corner points
    local corner1 = pos - rotateVector2D(util.vector3(-halfSize.x, -halfSize.y, 0), angle)
    local corner2 = pos + rotateVector2D(util.vector3(halfSize.x, -halfSize.y, 0), angle)
    local corner3 = pos + rotateVector2D(util.vector3(halfSize.x, halfSize.y, 0), angle)
    local corner4 = pos + rotateVector2D(util.vector3(-halfSize.x, halfSize.y, 0), angle)

    local toPos = corner1
    if num == 1 then
        toPos = corner2
    elseif num == 2 then
        toPos = corner3
    elseif num == 3 then
        toPos = corner4
    end

    local groundCorner1 = rayCast(corner1)
    local groundCorner2 = rayCast(corner2)
    local groundCorner3 = rayCast(corner3)
    local groundCorner4 = rayCast(corner4)

    local val = { obj = obj, corner1 = corner1, corner2 = corner2, corner3 = corner3, corner4 = corner4, groundCorner1 =
    groundCorner1, groundCorner2 = groundCorner2, groundCorner3 = groundCorner3, groundCorner4 = groundCorner4, pos = pos,
    rotationZ = rotationZ,
    }
    core.sendGlobalEvent("teleportCart", val)
    return val
end
return {
    interfaceName = "Spidertron",
    interface = {
        constructSpidertron = constructSpidertron,
        setLegZRot = setLegZRot,
        findLegObjs = findLegObjs,
        rayCast = rayCast,
        getObjects = getObjects,
        getObjCorners = getObjCorners
    },
    eventHandlers = {
        onSpidertronCreated = onSpidertronCreated,
    },
    engineHandlers = {
        onSave = function()
            return { mainObjId = mainObjId, legObjIds = legObjIds }
        end,
        onLoad = function(data)
            mainObjId = data.mainObjId
            legObjIds = data.legObjIds
        end

    }
}
