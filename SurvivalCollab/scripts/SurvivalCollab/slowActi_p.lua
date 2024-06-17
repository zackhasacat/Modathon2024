local input = require("openmw.input")
local core = require("openmw.core")
local async = require('openmw.async')
input.registerActionHandler("Activate", async:callback(function(state)
    print(state .. "Is the state")
end))
return {
    engineHandlers = {

    }
}
