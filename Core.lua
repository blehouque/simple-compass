-- Coordinates addon startup, frame movement, events, and compass updates.
local _, addon = ...

local data = addon.Database.Initialize()
addon.frame = addon.CompassView.Create(data)

local elapsed = 0
local driver = CreateFrame("Frame")
driver:RegisterEvent("PLAYER_LOGIN")
driver:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cff33ff99SimpleCompass|r loaded. Type /sc for help."
        )
    end
end)

driver:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < addon.Config.UpdateInterval then
        return
    end

    elapsed = 0
    addon.CompassView.Update(addon.frame, GetPlayerFacing())
end)

addon.frame:SetScript("OnDragStart", function(self)
    if not data.locked then
        self:StartMoving()
    end
end)

addon.frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    addon.Database.SavePosition(point, x, y)
end)

addon.Commands.Register()