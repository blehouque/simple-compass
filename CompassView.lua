-- Creates and updates the compass frame and its visual markers.
local _, addon = ...

local CompassView = {}
addon.CompassView = CompassView

local config = addon.Config

local function SetPosition(frame, data)
    frame:ClearAllPoints()
    frame:SetPoint(data.point, UIParent, data.point, data.x, data.y)
end

function CompassView.Create(data)
    local frame = CreateFrame("Frame", "SimpleCompassFrame", UIParent)
    frame:SetSize(config.BarWidth, config.BarHeight)
    frame:SetMovable(not data.locked)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    local background = frame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0, 0, 0, 0.40)
    frame.background = background

    local center = frame:CreateTexture(nil, "OVERLAY")
    center:SetSize(2, config.BarHeight)
    center:SetColorTexture(1, 0.8, 0, 1)
    center:SetPoint("CENTER")
    frame.center = center

    local border = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    if border.SetBackdrop then
        border:SetAllPoints()
        border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
        })
        border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    end
    frame.border = border

    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("CENTER")
    frame.heading = heading

    frame.markers = {}
    for angle = 0, 360 - config.MarkerStep, config.MarkerStep do
        local marker = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        marker.angle = angle
        frame.markers[#frame.markers + 1] = marker
    end

    SetPosition(frame, data)
    return frame
end

function CompassView.SetLocked(frame, locked)
    frame:SetMovable(not locked)
end

function CompassView.SetPosition(frame, data)
    SetPosition(frame, data)
end

function CompassView.Update(frame, facing)
    if not facing then
        return
    end

    local playerAngle = math.deg(facing) % 360
    local halfVisible = config.DegreesVisible / 2

    for _, marker in ipairs(frame.markers) do
        local difference = addon.Direction.GetOffset(marker.angle, playerAngle)

        if math.abs(difference) <= halfVisible then
            marker:Show()
            marker:ClearAllPoints()
            marker:SetPoint(
                "CENTER",
                frame,
                "CENTER",
                (difference / halfVisible) * (config.BarWidth / 2),
                0
            )
            marker:SetText(addon.Direction.GetLabel(marker.angle))
        else
            marker:Hide()
        end
    end
end