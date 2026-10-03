-- Registers slash commands for locking and positioning the compass.
local _, addon = ...

local Commands = {}
addon.Commands = Commands

local function PrintHelp()
    print("SimpleCompass commands:")
    print("/sc lock")
    print("/sc unlock")
    print("/sc reset")
end

function Commands.Register()
    SLASH_SIMPLECOMPASS1 = "/sc"
    SLASH_SIMPLECOMPASS2 = "/simplecompass"

    SlashCmdList["SIMPLECOMPASS"] = function(message)
        local command = string.lower(message or "")
        local data = addon.Database.data
        local frame = addon.frame

        if command == "lock" then
            data.locked = true
            addon.CompassView.SetLocked(frame, true)
            print("SimpleCompass: locked")
        elseif command == "unlock" then
            data.locked = false
            addon.CompassView.SetLocked(frame, false)
            print("SimpleCompass: unlocked")
        elseif command == "reset" then
            addon.Database.ResetPosition()
            addon.CompassView.SetPosition(frame, data)
            print("SimpleCompass: position reset")
        else
            PrintHelp()
        end
    end
end