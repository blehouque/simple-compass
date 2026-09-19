local ADDON_NAME = ...

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

--------------------------------------------------
-- Main Frame
--------------------------------------------------

local frame = CreateFrame("Frame", "SimpleCompassFrame", UIParent)

frame:SetSize(220, 36)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

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

frame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta

    if elapsed < UPDATE_INTERVAL then
        return
    end

    elapsed = 0

    local direction, degrees = GetHeading()

    self.text:SetText(
        string.format("%s  %03d°", direction, degrees)
    )
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