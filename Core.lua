local ADDON_NAME = ...

--------------------------------------------------
--- Constants
--------------------------------------------------

local BAR_WIDTH = 220
local BAR_HEIGHT = 40
local DEGREES_VISIBLE = 120
local MARKER_STEP = 15
local CARDINALS = {
    [0]   = "S",
    [45]  = "SE",
    [90]  = "E",
    [135] = "NE",
    [180] = "N",
    [225] = "NO",
    [270] = "O",
    [315] = "SO",
}

--------------------------------------------------
-- Database
--------------------------------------------------

SimpleCompassDB = SimpleCompassDB or {}

local defaults = {
    point = "TOP",
    x = 0,
    y = -120,
    locked = false,
}

local function CopyDefaults(source, destination)
    for k, v in pairs(source) do
        if destination[k] == nil then
            destination[k] = v
        end
    end
end

CopyDefaults(defaults, SimpleCompassDB)

--------------------------------------------------
-- Direction logic
--------------------------------------------------

local DIRECTIONS = {
    "S",
    "SW",
    "W",
    "NW",
    "N",
    "NE",
    "E",
    "SE",
}

local function GetHeading()
    local facing = GetPlayerFacing()

    if not facing then
        return "?", 0
    end

    local degrees = math.floor(math.deg(facing))

    degrees = degrees % 360

    local index = math.floor((degrees + 22.5) / 45) % 8 + 1

    return DIRECTIONS[index], degrees
end

local function ComputeOffset(markerAngle, playerAngle)

    local diff = playerAngle - markerAngle

    while diff > 180 do
        diff = diff - 360
    end

    while diff < -180 do
        diff = diff + 360
    end

    return diff
end

--------------------------------------------------
-- Main Frame
--------------------------------------------------

local frame = CreateFrame("Frame", "SimpleCompassFrame", UIParent)

frame:SetSize(BAR_WIDTH, BAR_HEIGHT)
frame:SetMovable(not SimpleCompassDB.locked)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

local center = frame:CreateTexture(nil, "OVERLAY")
center:SetSize(2, BAR_HEIGHT)
center:SetColorTexture(1, 0.8, 0, 1)
center:SetPoint("CENTER")

frame.markers = {}
for angle = 0, 345, MARKER_STEP do

    local fs = frame:CreateFontString(
        nil,
        "OVERLAY",
        "GameFontNormal"
    )

    fs.angle = angle

    frame.markers[#frame.markers + 1] = fs
end

local function GetLabel(angle)
    if CARDINALS[angle] then
        return CARDINALS[angle]
    end

    return "|cff888888·|r"
end

local function SetPosition()
    frame:ClearAllPoints()

    frame:SetPoint(
        SimpleCompassDB.point,
        UIParent,
        SimpleCompassDB.point,
        SimpleCompassDB.x,
        SimpleCompassDB.y
    )
end

SetPosition()

--------------------------------------------------
-- Background
--------------------------------------------------

frame.bg = frame:CreateTexture(nil, "BACKGROUND")
frame.bg:SetAllPoints()
frame.bg:SetColorTexture(0, 0, 0, 0.40)

--------------------------------------------------
-- Border
--------------------------------------------------

frame.border = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")

if frame.border.SetBackdrop then
    frame.border:SetAllPoints()

    frame.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })

    frame.border:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
end

--------------------------------------------------
-- FontString
--------------------------------------------------

frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.text:SetPoint("CENTER")

--------------------------------------------------
-- Drag & Drop
--------------------------------------------------

local function SavePosition()
    local point, _, _, x, y = frame:GetPoint()

    SimpleCompassDB.point = point
    SimpleCompassDB.x = math.floor(x)
    SimpleCompassDB.y = math.floor(y)
end

frame:SetScript("OnDragStart", function(self)
    if not SimpleCompassDB.locked then
        self:StartMoving()
    end
end)

frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

--------------------------------------------------
-- Update Loop
--------------------------------------------------

local elapsed = 0
local UPDATE_INTERVAL = 0.05

local function UpdateCompass()

    local facing = GetPlayerFacing()

    if not facing then
        return
    end

    local playerAngle = math.deg(facing) % 360

    for _, marker in ipairs(frame.markers) do

        local diff = ComputeOffset(
            marker.angle,
            playerAngle
        )

        if math.abs(diff) <= (DEGREES_VISIBLE / 2) then

            marker:Show()

            local x =
                (diff / (DEGREES_VISIBLE / 2))
                * (BAR_WIDTH / 2)

            marker:ClearAllPoints()
            marker:SetPoint("CENTER", frame, "CENTER", x, 0)

            marker:SetText(
                GetLabel(marker.angle)
            )

        else
            marker:Hide()
        end
    end
end

frame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta

    if elapsed < UPDATE_INTERVAL then
        return
    end

    elapsed = 0

    UpdateCompass()
end)

--------------------------------------------------
-- Events
--------------------------------------------------

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)

    if event == "PLAYER_LOGIN" then

        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff33ff99SimpleCompass|r loaded. Type /sc for help."
        )

    end
end)

--------------------------------------------------
-- Slash Commands
--------------------------------------------------

SLASH_SIMPLECOMPASS1 = "/sc"
SLASH_SIMPLECOMPASS2 = "/simplecompass"

SlashCmdList["SIMPLECOMPASS"] = function(msg)

    msg = string.lower(msg or "")

    if msg == "lock" then

        SimpleCompassDB.locked = true

        print("SimpleCompass: locked")

    elseif msg == "unlock" then

        SimpleCompassDB.locked = false

        print("SimpleCompass: unlocked")

    elseif msg == "reset" then

        frame:ClearAllPoints()

        SimpleCompassDB.point = defaults.point
        SimpleCompassDB.x = defaults.x
        SimpleCompassDB.y = defaults.y

        SetPosition()

        print("SimpleCompass: position reset")

    else

        print("SimpleCompass commands:")
        print("/sc lock")
        print("/sc unlock")
        print("/sc reset")

    end
end