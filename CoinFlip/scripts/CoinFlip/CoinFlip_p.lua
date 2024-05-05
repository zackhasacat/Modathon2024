local ui = require("openmw.ui")



return {
    eventHandlers = {CF_ShowMessage = function (msg)
        ui.showMessage(msg  )
    end}
}