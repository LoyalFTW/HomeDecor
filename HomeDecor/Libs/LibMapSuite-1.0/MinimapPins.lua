local MAJOR = "LibMapSuite-1.0"
local Lib = LibStub(MAJOR)
if not Lib then return end
local private = Lib.private
if (private.modules.MinimapPins or 0) >= 1 then return end
private.modules.MinimapPins = 1

local Pins = private.MinimapPins or { pins = {}, providers = {} }
private.MinimapPins = Pins

local indoorDiameter = { [0] = 300, 240, 180, 120, 80, 50 }
local outdoorDiameter = { [0] = 466.6667, 400, 333.3333, 266.6667, 200, 133.3333 }

local function IsIndoors(zoom)
    local inside = tonumber(GetCVar and GetCVar("minimapInsideZoom"))
    local outside = tonumber(GetCVar and GetCVar("minimapZoom"))
    if inside == zoom and outside ~= zoom then return true end
    if outside == zoom and inside ~= zoom then return false end
    return _G.IsIndoors and _G.IsIndoors() or false
end

local function GetDiameter()
    if C_Minimap and C_Minimap.GetViewRadius then
        local radius = C_Minimap.GetViewRadius()
        if radius and radius > 0 then return radius * 2 end
    end
    local zoom = Minimap:GetZoom() or 0
    return (IsIndoors(zoom) and indoorDiameter or outdoorDiameter)[zoom] or outdoorDiameter[0]
end

local function GetShape()
    if Lib.GetMinimapShape then return Lib:GetMinimapShape() end
    return private.Compat:GetMinimapShape()
end

local function SetTexture(pin, icon)
    if not pin.icon then return end
    if type(icon) == "table" then
        if pin.icon.SetAtlas then pin.icon:SetAtlas(icon.atlas, icon.useAtlasSize) end
    else
        pin.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    end
end

local function CreatePin(key, data)
    local pin = data.frame or CreateFrame("Button", nil, Minimap)
    pin.LibMapSuiteProvidedFrame = data.frame and true or nil
    pin.LibMapSuiteOriginalParent = data.frame and pin:GetParent() or nil
    pin:SetParent(Minimap)
    pin:SetFrameStrata("MEDIUM")
    pin:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 8)
    if not data.frame or data.size then pin:SetSize(data.size or 18, data.size or 18) end
    if not pin.icon and (not data.frame or data.icon) then
        pin.icon = pin:CreateTexture(nil, "ARTWORK")
        pin.icon:SetAllPoints()
    end
    SetTexture(pin, data.icon)
    if not data.frame then
        pin:RegisterForClicks("AnyUp")
        pin:SetScript("OnClick", function(self, button)
            if self.data.OnClick then self.data.OnClick(self, button, self.data) end
        end)
        pin:SetScript("OnEnter", function(self)
            if not self.data.OnTooltipShow then return end
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            self.data.OnTooltipShow(GameTooltip, self.data)
            GameTooltip:Show()
        end)
        pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    pin.key, pin.data = key, data
    return pin
end

local function Resolve(pin)
    local data = pin.data
    if pin.sourceMapID == data.mapID and pin.sourceX == data.x and pin.sourceY == data.y then
        return pin.worldX, pin.worldY, pin.instanceID
    end
    pin.sourceMapID, pin.sourceX, pin.sourceY = data.mapID, data.x, data.y
    pin.worldX, pin.worldY, pin.instanceID = Lib:MapToWorld(data.mapID, data.x, data.y)
    return pin.worldX, pin.worldY, pin.instanceID
end

local function Place(pin, playerX, playerY, playerInstance, facing, diameter)
    local worldX, worldY, instanceID = Resolve(pin)
    if not worldX or instanceID ~= playerInstance then pin:Hide() return end

    local dx, dy = worldX - playerX, worldY - playerY
    local sinFacing, cosFacing = math.sin(facing), math.cos(facing)
    local screenX = -dx * cosFacing + dy * sinFacing
    local screenY = dx * sinFacing + dy * cosFacing
    local halfW, halfH = Minimap:GetWidth() / 2, Minimap:GetHeight() / 2
    local x = screenX * Minimap:GetWidth() / diameter
    local y = screenY * Minimap:GetHeight() / diameter
    local boundX = math.max(0, halfW - pin:GetWidth() / 2)
    local boundY = math.max(0, halfH - pin:GetHeight() / 2)
    local shape = GetShape()
    local outside

    if shape ~= "ROUND" then
        outside = math.abs(x) > boundX or math.abs(y) > boundY
        if outside and pin.data.showOnEdge then
            x, y = math.max(-boundX, math.min(boundX, x)), math.max(-boundY, math.min(boundY, y))
        end
    else
        local nx, ny = boundX > 0 and x / boundX or 0, boundY > 0 and y / boundY or 0
        local length = math.sqrt(nx * nx + ny * ny)
        outside = length > 1
        if outside and pin.data.showOnEdge then x, y = x / length, y / length; x, y = x * boundX, y * boundY end
    end

    if outside and not pin.data.showOnEdge then pin:Hide() return end
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", Minimap, "CENTER", x, y)
    if pin.data.rotateIcon and pin.icon then pin.icon:SetRotation(-facing) end
    pin:SetAlpha(outside and (pin.data.edgeAlpha or 0.75) or (pin.data.alpha or 1))
    pin:Show()
end

function Pins:Update()
    local playerX, playerY, instanceID = Lib:GetPlayerWorldPosition("player")
    if not playerX then
        for _, pin in pairs(self.pins) do pin:Hide() end
        return
    end
    local rotates = GetCVar and GetCVar("rotateMinimap") == "1"
    local facing = rotates and GetPlayerFacing and GetPlayerFacing() or 0
    local diameter = GetDiameter()
    for _, pin in pairs(self.pins) do
        if pin.enabled then Place(pin, playerX, playerY, instanceID, facing or 0, diameter) else pin:Hide() end
    end
end

local driver = Pins.driver or CreateFrame("Frame")
Pins.driver = driver
driver:UnregisterAllEvents()
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("ZONE_CHANGED_NEW_AREA")
driver:RegisterEvent("MINIMAP_UPDATE_ZOOM")
driver:SetScript("OnEvent", function() Pins:Update() end)
driver:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.05 then return end
    self.elapsed = 0
    Pins:Update()
end)
driver:Hide()

local function SetDriver()
    driver:SetShown(next(Pins.pins) ~= nil)
end

function Lib:RegisterMinimapPin(key, data)
    assert(type(key) == "string" and key ~= "", MAJOR .. ": minimap pin key required")
    assert(type(data) == "table" and data.mapID and data.x and data.y, MAJOR .. ": minimap pin requires mapID, x and y")
    if Pins.pins[key] then self:UnregisterMinimapPin(key) end
    local pin = CreatePin(key, data)
    pin.enabled = data.hidden ~= true
    Pins.pins[key] = pin
    SetDriver()
    Pins:Update()
    return pin
end

function Lib:UnregisterMinimapPin(key)
    local pin = Pins.pins[key]
    if not pin then return end
    pin:Hide()
    if not pin.LibMapSuiteProvidedFrame then
        pin:SetScript("OnClick", nil)
        pin:SetScript("OnEnter", nil)
        pin:SetScript("OnLeave", nil)
    else
        pin:SetParent(pin.LibMapSuiteOriginalParent or UIParent)
    end
    Pins.pins[key] = nil
    SetDriver()
end

function Lib:GetMinimapPin(key) return Pins.pins[key] end

function Lib:SetMinimapPinPosition(key, mapID, x, y)
    local pin = Pins.pins[key]
    if not pin then return false end
    pin.data.mapID, pin.data.x, pin.data.y = mapID, x, y
    pin.sourceMapID = nil
    Pins:Update()
    return true
end

function Lib:ShowMinimapPin(key)
    local pin = Pins.pins[key]
    if not pin then return false end
    pin.enabled = true
    Pins:Update()
    return true
end

function Lib:HideMinimapPin(key)
    local pin = Pins.pins[key]
    if not pin then return false end
    pin.enabled = false
    pin:Hide()
    return true
end

function Lib:RefreshMinimapPins() Pins:Update() end

function Lib:RegisterMinimapPinProvider(provider)
    assert(type(provider) == "string" and provider ~= "", MAJOR .. ": provider required")
    Pins.providers[provider] = Pins.providers[provider] or {}
    return Pins.providers[provider]
end

function Lib:AddMinimapPin(provider, id, data)
    self:RegisterMinimapPinProvider(provider)
    local key = provider .. ":" .. tostring(id)
    Pins.providers[provider][id] = key
    return self:RegisterMinimapPin(key, data)
end

function Lib:RemoveMinimapPin(provider, id)
    local list = Pins.providers[provider]
    local key = list and list[id]
    if not key then return end
    self:UnregisterMinimapPin(key)
    list[id] = nil
end

function Lib:RemoveMinimapPinProvider(provider)
    local list = Pins.providers[provider]
    if not list then return end
    local keys = {}
    for _, key in pairs(list) do keys[#keys + 1] = key end
    for _, key in ipairs(keys) do self:UnregisterMinimapPin(key) end
    Pins.providers[provider] = nil
end
