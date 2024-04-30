local spokenToActor
local idToRelease

local dropAtFeet = true

local function getValue(id)
    if not tes3.player.data.votf then
        tes3.player.data.votf = {}
    end
   return  tes3.player.data.votf[id]
end
local function setValue(id,value)
    if not tes3.player.data.votf then
        tes3.player.data.votf = {}
    end
     tes3.player.data.votf[id] = value
end

local function pacifyRef(refId)
    local obj = tes3.getReference(refId)
    obj.mobile.fight = 0
    obj.mobile.hello = 0
    obj.mobile.alarm = 0
    obj.mobile:stopCombat(true)
    obj.data.isControlled = true
    tes3.setAIFollow({ reference = obj, target = tes3.player })
end
local function uiObjectTooltipCallback(e)
    if e.object and getValue(e.object.id) then
        local idcheck =  getValue(e.object.id)
        if idcheck then
            local obj = tes3.getReference(idcheck)
            e.tooltip:createLabel { text = "Occupant: " .. obj.object.name }
        end
    end
end
event.register(tes3.event.uiObjectTooltip, uiObjectTooltipCallback)
local function projectileHitEscape(point, weapon)
    if not weapon.id  then
        return
    end
    idToRelease = getValue(weapon.id)
    if idToRelease then
        
        local obj = tes3.getReference(idToRelease)
        tes3.positionCell { reference = obj, position = point, cell = tes3.player.cell }


        timer.start({
            duration = 0.3,
            callback = function()
                pacifyRef(idToRelease)
            end
        })
    end
end
local function projectileHitActorCallback(e)
    local weapon = e.firingWeapon
    if weapon.id == "zhac_ball_01"  then
        print("projectileHitActorCallback")
        local newObject = weapon:createCopy()
        
        if not dropAtFeet then
            tes3.addItem { reference = tes3.player, item = newObject, playSound = false }
            tes3.positionCell { reference = e.target, position = tes3vector3.new(0, 0, 0), cell = "zhac_ballstorage" }
           -- local itemData = tes3.addItemData { to = tes3.player, item = newObject }
          --  itemData.data.occupant = e.target.id
        else
            local newItem = tes3.createReference({ object = newObject, position = e.target.position, cell = e.target
            .cell, orientation = e.target.orientation })
           -- local itemData = tes3.addItemData { to = tes3.player, item = newObject }
           -- newItem.itemData.data.occupant = e.target.id
        end
        setValue(newObject.id,e.target.id)
        tes3.positionCell { reference = e.target, position = tes3vector3.new(0, 0, 0), cell = "zhac_ballstorage" }
    elseif getValue(weapon.id) then
        projectileHitEscape(e.target.position, weapon)
    end
end
event.register(tes3.event.projectileHitActor, projectileHitActorCallback)
local function projectileHitObjectCallback(e)
    local point = e.position
    local weapon = e.firingWeapon
    projectileHitEscape(point, weapon)
end
event.register(tes3.event.projectileHitObject, projectileHitObjectCallback)

event.register(tes3.event.projectileHitTerrain, projectileHitObjectCallback)
local function activateCallback(e)
    if e.target.object.id == "zhac_crystal_01" and tes3.getJournalIndex({ id = "ZHAC_MorianaQ_1" }) == 30 then
        tes3.messageBox({
            message =
            "As you touch the globe, the world goes dark.\n\nYou see a dark landscape. Red Mountain is in the distance, far more violent than it currently is.\nYou notice two fighters in the ruins of the city of Vivec. You recognize one as Moriana. They are going at each other, fire, shock, all sorts of magic.\n\nFinally, you see Moriana struck down. It all goes black, and you awake.",
            buttons = { "OK" }
        })

        tes3.setJournalIndex({ id = "ZHAC_MorianaQ_1", index = 40 })
        return false
    elseif e.target.data and e.target.data.isControlled == true then
        tes3.setGlobal("zhac_speakingto_controlled", 1)
        spokenToActor = e.target
        timer.start({
            duration = .5,
            callback = function()
                tes3.setGlobal("zhac_speakingto_controlled", 0)
            end
        })
    end
end
event.register(tes3.event.activate, activateCallback)

local function referenceActivatedCallback(e)
    if e.reference.object.id == "zhac_marker_compshare" then
        e.reference:delete()
        tes3.showContentsMenu { reference = spokenToActor }
    end
end
event.register(tes3.event.referenceActivated, referenceActivatedCallback)
