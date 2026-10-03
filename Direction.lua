-- Provides reusable compass direction and label calculations.
local _, addon = ...

local Direction = {}
addon.Direction = Direction

function Direction.GetOffset(markerAngle, playerAngle)
    local difference = playerAngle - markerAngle

    if difference > 180 then
        difference = difference - 360
    elseif difference < -180 then
        difference = difference + 360
    end

    return difference
end

function Direction.GetLabel(angle)
    return addon.Config.Cardinals[angle] or "|cff888888·|r"
end