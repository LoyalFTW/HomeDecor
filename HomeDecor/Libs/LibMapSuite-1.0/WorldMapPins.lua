local MAJOR = "LibMapSuite-1.0"
local Lib = LibStub(MAJOR)
if not Lib then return end
local private, Compat = Lib.private, Lib.private.Compat
if (private.modules.WorldMapPins or 0) >= 6 then return end
private.modules.WorldMapPins = 6

local Pins = private.WorldMapPins or { registry = {}, providers = {}, pending = {} }
private.WorldMapPins = Pins
Pins.pending = Pins.pending or {}

local function IsInCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function QueueRepositionAll()
    Pins.pendingRefresh = true
    if Pins.watcher then Pins.watcher:RegisterEvent("PLAYER_REGEN_ENABLED") end
end

local function CurrentMapID()
    return WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
        or Compat:GetCurrentMapID()
end

local function Canvas()
    return Compat:GetWorldMapCanvas()
end

local function ResolvePosition(data, shownMapID)
    if not shownMapID or not data.mapID then return nil end
    if data.mapID == shownMapID then return data.x, data.y end
    return Lib:TranslateMapCoordinates(data.x, data.y, data.mapID, shownMapID, false)
end

local function ApplyAppearance(pin)
    local data = pin.pinData
    local size = data.size or data.scale or 20
    if not pin.LibMapSuiteProvidedFrame or data.size or data.scale then pin:SetSize(size, size) end
    if pin.icon then
        pin.icon:SetTexture(type(data.icon) == "function" and data.icon(pin) or data.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        if data.iconCoords then pin.icon:SetTexCoord(unpack(data.iconCoords)) else pin.icon:SetTexCoord(0, 1, 0, 1) end
    end
    pin:SetAlpha(data.alpha or 1)
end

local function CreatePin(name, data)
    local canvas = Canvas()
    if not canvas then return nil end
    local pin = data.frame or CreateFrame("Button", nil, canvas)
    pin.LibMapSuiteProvidedFrame = data.frame and true or nil
    pin.LibMapSuiteOriginalParent = data.frame and pin:GetParent() or nil
    pin:SetFrameStrata(data.strata or "HIGH")
    pin:SetFrameLevel((canvas:GetFrameLevel() or 0) + (data.frameLevel or 100))
    if pin.RegisterForClicks then pin:RegisterForClicks("LeftButtonUp", "RightButtonUp") end
    local icon = pin.icon
    if not icon and (not data.frame or data.icon) then
        icon = pin:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
    end
    pin.icon, pin.name, pin.pinData = icon, name, data
    local function AttachScript(script, handler)
        if data.frame and pin.HookScript then pin:HookScript(script, handler) else pin:SetScript(script, handler) end
    end
    if pin.RegisterForClicks then
        AttachScript("OnClick", function(self, button)
            local fn = self.pinData.OnClick
            if fn then fn(self, button, self.pinData) end
        end)
    end
    AttachScript("OnEnter", function(self)
        local fn = self.pinData.OnEnter
        if fn then fn(self) end
        if self.pinData.OnTooltipShow then
            GameTooltip:SetOwner(self, self.pinData.tooltipAnchor or "ANCHOR_RIGHT")
            self.pinData.OnTooltipShow(GameTooltip, self.pinData)
            GameTooltip:Show()
        end
    end)
    AttachScript("OnLeave", function(self)
        if self.pinData.OnLeave then self.pinData.OnLeave(self) end
        GameTooltip:Hide()
    end)
    if not data.frame then
        function pin:SetIcon(texture, coords)
            self.pinData.icon, self.pinData.iconCoords = texture, coords
            ApplyAppearance(self)
        end
    end
    ApplyAppearance(pin)
    return pin
end

function Pins:Reposition(pin)
    if not pin or not pin.pinData then return end
    if IsInCombat() then
        QueueRepositionAll()
        return
    end
    local data, canvas = pin.pinData, Canvas()
    if not canvas or data.hidden then pin:Hide(); return end
    if pin:GetParent() ~= canvas then pin:SetParent(canvas) end
    pin:SetFrameLevel((canvas:GetFrameLevel() or 0) + (data.frameLevel or 100))
    local x, y = ResolvePosition(data, CurrentMapID())
    if not x or x < 0 or x > 1 or y < 0 or y > 1 then pin:Hide(); return end
    local width, height = canvas:GetSize()
    if not width or width <= 0 or not height or height <= 0 then pin:Hide(); return end
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", canvas, "TOPLEFT", x * width, -y * height)
    local zoom = WorldMapFrame and WorldMapFrame.GetCanvasScale and WorldMapFrame:GetCanvasScale() or 1
    local minZoom, maxZoom = data.minZoom, data.maxZoom
    if (minZoom and zoom < minZoom) or (maxZoom and zoom > maxZoom) then pin:Hide(); return end
    pin:SetScale(data.scaleWithZoom and (data.baseScale or 1) / math.max(zoom, 0.01) or (data.frameScale or 1))
    pin:Show()
end

function Pins:RepositionAll()
    if IsInCombat() then
        QueueRepositionAll()
        return
    end
    self.pendingRefresh = nil
    for _, pin in pairs(self.registry) do self:Reposition(pin) end
end

function Lib:RegisterWorldMapPin(name, data)
    assert(type(name) == "string" and name ~= "", "RegisterWorldMapPin: name must be a non-empty string")
    assert(type(data) == "table" and type(data.mapID) == "number" and type(data.x) == "number" and type(data.y) == "number",
        "RegisterWorldMapPin: pinData requires numeric mapID, x and y")
    self:UnregisterWorldMapPin(name)
    local pin = CreatePin(name, data)
    if not pin then Pins.pending[name] = data; return nil end
    Pins.pending[name] = nil
    Pins.registry[name] = pin
    Pins:Reposition(pin)
    return pin
end

function Lib:UnregisterWorldMapPin(name)
    Pins.pending[name] = nil
    local pin = Pins.registry[name]
    if not pin then return end
    pin:Hide()
    pin:SetParent(pin.LibMapSuiteOriginalParent or UIParent)
    Pins.registry[name] = nil
end

function Lib:GetWorldMapPin(name) return Pins.registry[name] end
function Lib:SetWorldMapPinPosition(name, mapID, x, y)
    local pin = Pins.registry[name]
    if pin then
        pin.pinData.mapID, pin.pinData.x, pin.pinData.y = mapID, x, y
        Pins:Reposition(pin)
    end
    local data = Pins.pending[name]
    if data then data.mapID, data.x, data.y = mapID, x, y end
    return pin
end
function Lib:ShowWorldMapPin(name)
    local pin, data = Pins.registry[name], Pins.pending[name]
    if pin then pin.pinData.hidden = nil; Pins:Reposition(pin) end
    if data then data.hidden = nil end
    return pin
end
function Lib:HideWorldMapPin(name)
    local pin, data = Pins.registry[name], Pins.pending[name]
    if pin then pin.pinData.hidden = true; pin:Hide() end
    if data then data.hidden = true end
    return pin
end
function Lib:RefreshWorldMapPins() Pins:RepositionAll() end

function Lib:RegisterWorldMapPinProvider(provider)
    assert(type(provider) == "string" and provider ~= "", "provider must be a non-empty string")
    Pins.providers[provider] = Pins.providers[provider] or {}
    return provider
end
function Lib:AddWorldMapPin(provider, key, data)
    self:RegisterWorldMapPinProvider(provider)
    local name = provider .. ":" .. tostring(key)
    Pins.providers[provider][key] = name
    return self:RegisterWorldMapPin(name, data)
end
function Lib:RemoveWorldMapPin(provider, key)
    local names = Pins.providers[provider]
    if not names then return end
    self:UnregisterWorldMapPin(names[key]); names[key] = nil
end
function Lib:RemoveWorldMapPinProvider(provider)
    local names = Pins.providers[provider]
    if not names then return end
    for _, name in pairs(names) do self:UnregisterWorldMapPin(name) end
    Pins.providers[provider] = nil
end

local watcher = Pins.watcher or CreateFrame("Frame")
Pins.watcher = watcher
watcher:UnregisterAllEvents()
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
    end
    Pins:RepositionAll()
end)

local function HookWorldMap()
    if not WorldMapFrame then return end
    for name, data in pairs(Pins.pending) do
        local pin = CreatePin(name, data)
        if pin then
            Pins.registry[name] = pin
            Pins.pending[name] = nil
            Pins:Reposition(pin)
        end
    end
    if Pins.hooked then return end
    Pins.hooked = true
    WorldMapFrame:HookScript("OnShow", function() Pins:RepositionAll() end)
    WorldMapFrame:HookScript("OnSizeChanged", function() Pins:RepositionAll() end)
    if hooksecurefunc and WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function() Pins:RepositionAll() end)
    end
    if hooksecurefunc and WorldMapFrame.OnCanvasScaleChanged then
        hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", function() Pins:RepositionAll() end)
    end
    local canvas = Canvas()
    if canvas and canvas.HookScript then
        canvas:HookScript("OnSizeChanged", function() Pins:RepositionAll() end)
        if canvas.GetScript and canvas:GetScript("OnMouseWheel") then
            canvas:HookScript("OnMouseWheel", function() Pins:RepositionAll() end)
        end
    end
end
HookWorldMap()
watcher:RegisterEvent("ADDON_LOADED")
watcher:HookScript("OnEvent", HookWorldMap)
