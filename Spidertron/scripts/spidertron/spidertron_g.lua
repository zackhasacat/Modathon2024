
local types = require("openmw.types")
local world = require("openmw.world")
local acti = require("openmw.interfaces").Activation
local util = require("openmw.util")
local I = require("openmw.interfaces")
local async = require("openmw.async")
local core = require("openmw.core")
local calendar = require('openmw_aux.calendar')

local function createRotation(x, y, z)
    if (core.API_REVISION < 40) then
        return util.vector3(x, y, z)
    else
        local rotate = util.transform.rotateZ(z)
        local rotatex = util.transform.rotateX(x)
        local rotatey = util.transform.rotateY(y)
        rotate = rotate:__mul(rotatey)
        rotate = rotate:__mul(rotatex)
        return rotate * rotatex * rotatey
    end
end
local function createSpidertronObj(position)
    local torso = world.createObject("ZHAC_Spider_Torso")
    local cell = world.players[1].cell
    torso:teleport(cell, position)
    local legs = {}
    for i = 1, 8 do
        local leg = world.createObject("ZHAC_Spider_Leg")
        local rotation = createRotation(0, 0, math.rad(i * 45))
        leg:teleport(cell, position,rotation)
        table.insert(legs, leg)
    end
    world.players[1]:sendEvent("onSpidertronCreated", { torso = torso, legs = legs })
end

local function moveObjectsInDir(data)
    local objs = data.objs
    local dir = data.dir
    local moveData = data.moveData
    
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
        return rotate * rotatex * rotatey
    end
end
local function calculateGroundNormal(corner1, corner2, corner3, corner4)
    -- Calculate two vectors representing edges of the ground
    local edge1 = corner2 - corner1
    local edge2 = corner3 - corner1
    
    -- Calculate the cross product of the edges to get the normal vector
    local normal = edge1:cross(edge2)
    normal:normalize()
    
    return normal
end
local function calculateRotationAngles(normal)
    -- Calculate the rotation angles around each axis to align the object's local up vector with the ground normal
    local thetaX = math.atan2(-normal.y, math.sqrt(normal.x^2 + normal.z^2))
    local thetaY = -math.atan2(normal.x, normal.z)
    local thetaZ = 0  -- Assuming no rotation around the local forward axis

    return thetaX, thetaY, thetaZ
end


local function teleportCart(data)
    local obj = data.obj

    local corner1 = data.corner1
    local corner2 = data.corner2
    local corner3 = data.corner3
    local corner4 = data.corner4

    local groundCorner1 = data.groundCorner1--corner1 position on ground
    local groundCorner2 = data.groundCorner2--corner2 position on ground
    local groundCorner3 = data.groundCorner3--corner3 position on ground
    local groundCorner4 = data.groundCorner4--corner4 position on ground
    

    local cell = world.players[1].cell
    local avgZ = (groundCorner1.z + groundCorner2.z + groundCorner3.z + groundCorner4.z) / 4
    avgZ = avgZ + 40


    local groundNormal = calculateGroundNormal(groundCorner2, groundCorner3, groundCorner4, groundCorner1)
    print(groundNormal)
    -- Calculate rotation angles from the ground normal
    local thetaX, thetaY = calculateRotationAngles(groundNormal)
    local rotation = createRotation(thetaX, thetaY, data.rotationZ)
--    print("doing itx")
    -- Teleport the object to the specified position
    --obj:teleport(obj.cell,data.pos, rotation)
    world.players[1]:teleport(obj.cell,util.vector3(data.pos.x, data.pos.y, avgZ))
    world.players[1]:sendEvent("activatePlacement",obj)
    
end


local function teleportAsNeeded(data)
    local obj = data.obj
    local rot = data.rot 
    local pos = data.pos or obj.position
    local cell = world.players[1].cell
    teleportCart(data.moveData)
end
return {
    eventHandlers = {
        createSpidertronObj = createSpidertronObj,
        teleportAsNeeded = teleportAsNeeded,
        moveObjectsInDir = moveObjectsInDir,
        teleportCart = teleportCart,
    }
}