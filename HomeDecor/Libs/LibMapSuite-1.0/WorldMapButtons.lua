local MAJOR = "LibMapSuite-1.0"
local Lib = LibStub(MAJOR)
if not Lib then return end
local private, Compat, Menu = Lib.private, Lib.private.Compat, Lib.private.Menu
if (private.modules.WorldMapButtons or 0) >= 5 then return end
private.modules.WorldMapButtons = 5

local Rail = private.WorldMapButtons or { registry = {}, order = {}, x = -4, y = -2, spacing = 4 }
private.WorldMapButtons = Rail
Rail.retiredExternal = Rail.retiredExternal or {}

local function IsInCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function QueueLayoutAfterCombat()
    Rail.pendingLayout = true
    if Rail.watcher then Rail.watcher:RegisterEvent("PLAYER_REGEN_ENABLED") end
end

local function GetKrowiRail()
    return LibStub("Krowi_WorldMapButtons-1.4", true)
        or LibStub("Krowi_WorldMapButtons-1.3", true)
end

function Rail:HookExternalRails()
    local Krowi = GetKrowiRail()
    if not Krowi or Krowi.LibMapSuiteHooked or not hooksecurefunc or not Krowi.Add then return end
    Krowi.LibMapSuiteHooked = true
    hooksecurefunc(Krowi, "Add", function() Rail:QueueLayout() end)
    if Krowi.SetPoints then
        hooksecurefunc(Krowi, "SetPoints", function()
            if not Rail.applyingLayout then Rail:QueueLayout() end
        end)
    end
end

local function IsBlizzardRailButton(frame)
    if not frame then return false end
    return (WorldMapTrackingOptionsButtonMixin and frame.OnLoad == WorldMapTrackingOptionsButtonMixin.OnLoad)
        or (WorldMapTrackingPinButtonMixin and frame.OnLoad == WorldMapTrackingPinButtonMixin.OnLoad)
end

local function GetReservedOffset(anchor, vertical)
    local offset, Krowi = 0, GetKrowiRail()
    if Krowi and Krowi.Buttons then
        for _, frame in ipairs(Krowi.Buttons) do
            if frame and frame:IsShown() then
                local relative = frame.relativeFrame or anchor
                local size = vertical and frame:GetHeight() or frame:GetWidth()
                if not size or size <= 0 then size = 32 end
                frame:ClearAllPoints()
                frame:SetPoint("TOPRIGHT", relative, "TOPRIGHT",
                    Rail.x + (vertical and 0 or -offset), Rail.y + (vertical and -offset or 0))
                offset = offset + math.max(32, size) + Rail.spacing
            end
        end
    elseif WorldMapFrame and WorldMapFrame.overlayFrames then
        for _, frame in pairs(WorldMapFrame.overlayFrames) do
            if IsBlizzardRailButton(frame) and frame:IsShown() then
                local size = vertical and frame:GetHeight() or frame:GetWidth()
                offset = offset + math.max(32, size or 0) + Rail.spacing
            end
        end
    end
    return offset
end

local function RemoveOrder(name)
    for i = #Rail.order, 1, -1 do
        if Rail.order[i] == name then table.remove(Rail.order, i) end
    end
end

function Rail:RecalculateLayout()
    if IsInCombat() then
        QueueLayoutAfterCombat()
        return
    end
    self.pendingLayout = nil
    local anchor = Compat:GetWorldMapButtonRailAnchor()
    if not anchor then return end
    self.applyingLayout = true
    local vertical = Compat.IsRetail
    for _, name in ipairs(self.order) do
        local button = self.registry[name]
        if button and button.LibMapSuiteExternalRail then
            if button.LibMapSuiteHidden then button:Hide() else button:Show() end
        end
    end
    local offset = GetReservedOffset(anchor, vertical)
    for _, name in ipairs(self.order) do
        local button = self.registry[name]
        if button and button.LibMapSuiteExternalRail then
        elseif button and not button.LibMapSuiteHidden then
            button:SetParent(anchor)
            button:ClearAllPoints()
            local size = button:GetWidth() > 0 and button:GetWidth() or 32
            button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT",
                self.x + (vertical and 0 or -offset), self.y + (vertical and -offset or 0))
            offset = offset + size + self.spacing
            button:Show()
        elseif button then
            button:Hide()
        end
    end
    self.applyingLayout = nil
end

function Rail:QueueLayout()
    self:RecalculateLayout()
    if self.layoutQueued then return end
    self.layoutQueued = true
    local run = function()
        self.layoutQueued = nil
        self:RecalculateLayout()
    end
    if C_Timer and C_Timer.After then C_Timer.After(0, run) else run() end
end

function Lib:SetWorldMapButtonOffsets(x, y, spacing)
    Rail.x, Rail.y, Rail.spacing = x or Rail.x, y or Rail.y, spacing or Rail.spacing
    Rail:RecalculateLayout()
end

local function Configure(button, name, data, callerProvidedFrame)
    button.LibMapSuiteName, button.buttonData = name, data
    button:SetSize(data.size or 32, data.size or 32)
    button:SetFrameStrata(data.strata or "HIGH")
    local defaultStyle = data.style == "DEFAULT" or (data.style == nil and not callerProvidedFrame)
    -- A caller-provided frame owns its own click mask (e.g. a template that only
    -- wants left-click). Only the library's own default-style frame gets a mask
    -- imposed on it here.
    if defaultStyle then
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end
    if defaultStyle then
        local background = button.LibMapSuiteBackground or button:CreateTexture(nil, "BACKGROUND")
        background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        background:SetSize((data.size or 32) - 6, (data.size or 32) - 6)
        background:ClearAllPoints(); background:SetPoint("CENTER")
        button.LibMapSuiteBackground = background
    end

    -- A caller-provided frame keeps its own icon/texture layers untouched unless
    -- it explicitly opts in via data.icon; the library only owns the icon it
    -- creates itself (defaultStyle, or when a caller passes data.icon).
    local icon = button.icon
    if not icon and (not callerProvidedFrame or data.icon) then
        icon = button:CreateTexture(nil, "ARTWORK")
    end
    if icon then
        icon:ClearAllPoints()
        if defaultStyle then
            icon:SetSize(data.iconSize or 20, data.iconSize or 20)
            icon:SetPoint("CENTER")
        else
            icon:SetAllPoints()
        end
        icon:SetTexture(data.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        if data.iconCoords then icon:SetTexCoord(unpack(data.iconCoords))
        elseif defaultStyle then icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        else icon:SetTexCoord(0, 1, 0, 1) end
        button.icon = icon
    end

    if defaultStyle then
        local border = button.LibMapSuiteBorder or button:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        border:SetSize(50, 50)
        border:ClearAllPoints(); border:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.LibMapSuiteBorder = border
    end
    -- A caller-provided frame keeps its own highlight texture unless it opts in
    -- via data.highlight = true.
    if (defaultStyle and data.highlight ~= false) or data.highlight == true then
        button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    end
    -- A caller-provided frame's own scripts (e.g. XML-bound mixin methods) must
    -- keep firing, so they're hooked instead of replaced; buttonData callbacks
    -- fire alongside them, matching WorldMapPins.lua's CreatePin convention.
    local function AttachScript(script, handler)
        if callerProvidedFrame and button.HookScript then
            button:HookScript(script, handler)
        else
            button:SetScript(script, handler)
        end
    end
    AttachScript("OnClick", function(self, mouseButton)
        if self.buttonData.OnClick then self.buttonData.OnClick(self, mouseButton) end
    end)
    AttachScript("OnEnter", function(self)
        if self.buttonData.OnEnter then self.buttonData.OnEnter(self) end
        if self.buttonData.OnTooltipShow or self.buttonData.text then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if self.buttonData.OnTooltipShow then self.buttonData.OnTooltipShow(GameTooltip)
            else GameTooltip:SetText(self.buttonData.text) end
            GameTooltip:Show()
        end
    end)
    AttachScript("OnLeave", function(self)
        if self.buttonData.OnLeave then self.buttonData.OnLeave(self) end
        GameTooltip:Hide()
    end)
    if data.menu or data.options then Menu:Attach(button, data.menu or data.options, data.menuButton) end
    function button:Refresh()
        if self.buttonData.OnRefresh then self.buttonData.OnRefresh(self, WorldMapFrame and WorldMapFrame:GetMapID()) end
    end
    return button
end

function Lib:RegisterWorldMapButton(name, data)
    assert(type(name) == "string" and name ~= "", "RegisterWorldMapButton: name must be a non-empty string")
    assert(type(data) == "table", "RegisterWorldMapButton: buttonData must be a table")
    self:UnregisterWorldMapButton(name)
    Rail:HookExternalRails()
    local callerProvidedFrame = data.frame ~= nil
    local anchor = Compat:GetWorldMapButtonRailAnchor() or UIParent
    local Krowi = GetKrowiRail()
    local button = data.frame or Rail.retiredExternal[name]
    if not button and Krowi and Krowi.Add then
        button = Krowi:Add(data.template, data.frameType or "Button")
        button.LibMapSuiteExternalRail = true
    end
    button = button or CreateFrame(data.frameType or "Button", nil, anchor, data.template)
    Configure(button, name, data, callerProvidedFrame)
    Rail.registry[name] = button
    table.insert(Rail.order, name)
    Rail:QueueLayout()
    button:Refresh()
    return button
end

function Lib:AddWorldMapButton(name, frame, options)
    options = options or {}; options.frame = frame
    return self:RegisterWorldMapButton(name, options)
end

function Lib:UnregisterWorldMapButton(name)
    local button = Rail.registry[name]
    if not button then return end
    button:Hide()
    if button.LibMapSuiteExternalRail then Rail.retiredExternal[name] = button end
    Rail.registry[name] = nil; RemoveOrder(name)
    Rail:QueueLayout()
end
function Lib:GetWorldMapButton(name) return Rail.registry[name] end
function Lib:ShowWorldMapButton(name)
    local button = Rail.registry[name]
    if button then button.LibMapSuiteHidden = nil; Rail:QueueLayout() end
    return button
end
function Lib:HideWorldMapButton(name)
    local button = Rail.registry[name]
    if button then button.LibMapSuiteHidden = true; Rail:QueueLayout() end
    return button
end

local watcher = Rail.watcher or CreateFrame("Frame")
Rail.watcher = watcher
watcher:UnregisterAllEvents()
watcher:RegisterEvent("ADDON_LOADED")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent(event)
    end
    Rail:HookExternalRails()
    if WorldMapFrame and not Rail.hooked then
        Rail.hooked = true
        WorldMapFrame:HookScript("OnShow", function()
            Rail:QueueLayout()
            for _, button in pairs(Rail.registry) do button:Refresh() end
        end)
        if hooksecurefunc and WorldMapFrame.OnMapChanged then
            hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
                Rail:QueueLayout()
                for _, button in pairs(Rail.registry) do button:Refresh() end
            end)
        end
    end
    Rail:QueueLayout()
end)
