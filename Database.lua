-- Initializes and updates the addon's saved settings.
local _, addon = ...

local Database = {}
addon.Database = Database

function Database.Initialize()
    SimpleCompassDB = SimpleCompassDB or {}

    for key, value in pairs(addon.Config.Defaults) do
        if SimpleCompassDB[key] == nil then
            SimpleCompassDB[key] = value
        end
    end

    Database.data = SimpleCompassDB
    return Database.data
end

function Database.ResetPosition()
    local data = Database.data
    local defaults = addon.Config.Defaults

    data.point = defaults.point
    data.x = defaults.x
    data.y = defaults.y
end

function Database.SavePosition(point, x, y)
    local data = Database.data

    data.point = point
    data.x = math.floor(x)
    data.y = math.floor(y)
end