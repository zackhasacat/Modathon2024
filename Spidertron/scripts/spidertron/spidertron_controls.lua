local I = require('openmw.interfaces')
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
local controlled = false
local moveObj
local function setControlState(state,obj)
    if not state then
        I.Controls.overrideMovementControls(false)
    else
        I.Controls.overrideMovementControls(true)
    end
    controlled = state
    moveObj = obj
end
local function onUpdate()
    if not controlled or not moveObj then
        return
    end
    local goForward = input.isKeyPressed(input.KEY.W)
    if goForward then
        local cameraAngle = camera.getYaw()
        local myPos = util.vector3(moveObj.position.x, moveObj.position.y, moveObj.position.z)
        local forward = util.vector3(math.sin(cameraAngle), math.cos(cameraAngle), 0)
        forward = forward * 4
       -- local objsToMove = I.Spidertron.getObjects()
        local moveData = I.Spidertron.getObjCorners(moveObj,0,forward,cameraAngle)
        --table.insert(objsToMove,self)
       -- core.sendGlobalEvent("moveObjectsInDir",{objs = {moveObj}, dir = forward,moveData = moveData})
    end
    
end

return {
    interfaceName = "SpidertronControls",
    interface = {
        setControlState = setControlState },
    engineHandlers = {
        onUpdate = onUpdate
    }
}
