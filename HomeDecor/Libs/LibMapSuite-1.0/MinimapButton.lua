local MAJOR = "LibMapSuite-1.0"
local LibMapSuite = LibStub(MAJOR)
if not LibMapSuite then return end
local private = LibMapSuite.private
if (private.modules.MinimapButtons or 0) >= 7 then return end
private.modules.MinimapButtons = 7
local Compat = private.Compat

local MinimapButton = private.MinimapButton or {}
private.MinimapButton = MinimapButton

MinimapButton.registry = MinimapButton.registry or {}
MinimapButton.order = MinimapButton.order or {}
MinimapButton.overflowThreshold = MinimapButton.overflowThreshold or 10
MinimapButton.retiredCompartmentEntries = MinimapButton.retiredCompartmentEntries or {}

local BUTTON_SIZE    = 31

local BORDER_SIZE_RETAIL  = 50
local BORDER_SIZE_CLASSIC = 53
local BG_SIZE_RETAIL      = 24
local BG_SIZE_CLASSIC     = 20
local ICON_SIZE_RETAIL    = 18
local ICON_SIZE_CLASSIC   = 17

MinimapButton.ringGap = MinimapButton.ringGap or 5

local function GetOrbitRadius()
    local canvas = Compat:GetMinimapCanvas()
    local w = canvas:GetWidth()
    local h = canvas:GetHeight()
    if not w or w == 0 then
        w, h = 140, 140
    end
    return math.max(w, h) / 2 + MinimapButton.ringGap
end

local function AngleToPosition(angleDeg)
    local shape = LibMapSuite.GetMinimapShape and LibMapSuite:GetMinimapShape() or Compat:GetMinimapShape()
    local radius = GetOrbitRadius()

    if shape == "SQUARE" then
        local rad = math.rad(angleDeg)
        local cos, sin = math.cos(rad), math.sin(rad)
        local scale = 1 / math.max(math.abs(cos), math.abs(sin))
        return cos * scale * radius, sin * scale * radius
    else
        local rad = math.rad(angleDeg)
        return math.cos(rad) * radius, math.sin(rad) * radius
    end
end

local function IsAngleFree(angleDeg, excludeButton)
    local radius = GetOrbitRadius()
    local circumference = 2 * math.pi * radius
    for _, btn in pairs(MinimapButton.registry) do
        if btn ~= excludeButton and btn:IsShown() and btn.db and btn.db.minimapPos then
            local newSize = excludeButton and excludeButton:GetWidth() or BUTTON_SIZE
            local occupiedSize = ((newSize or BUTTON_SIZE) + (btn:GetWidth() or BUTTON_SIZE)) / 2
            local minAngularGap = (occupiedSize / circumference) * 360
            local diff = math.abs(((btn.db.minimapPos - angleDeg) + 180) % 360 - 180)
            if diff < minAngularGap then
                return false
            end
        end
    end
    return true
end

local function FindFreeAngle(desiredAngle, excludeButton)
    if IsAngleFree(desiredAngle, excludeButton) then
        return desiredAngle
    end
    for step = 1, 180 do
        local plus = (desiredAngle + step) % 360
        local minus = (desiredAngle - step) % 360
        if IsAngleFree(plus, excludeButton) then return plus end
        if IsAngleFree(minus, excludeButton) then return minus end
    end
    return desiredAngle
end

local drawerButton = MinimapButton.drawerButton
local drawerContainer = MinimapButton.drawerContainer

local function EnsureDrawer()
    if drawerButton then
        drawerButton:SetScript("OnClick", function()
            MinimapButton.drawerExpanded = not MinimapButton.drawerExpanded
            MinimapButton:LayoutDrawer()
        end)
        return
    end

    drawerButton = CreateFrame("Button", "LibMapSuite10_Drawer", Compat:GetMinimapAnchorFrame())
    drawerButton:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    drawerButton:SetFrameStrata("MEDIUM")

    local icon = drawerButton:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    icon:SetAllPoints()
    drawerButton.icon = icon

    drawerContainer = CreateFrame("Frame", "LibMapSuite10_DrawerContainer", UIParent)
    drawerContainer:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    drawerContainer:Hide()
    MinimapButton.drawerButton, MinimapButton.drawerContainer = drawerButton, drawerContainer

    drawerButton:SetScript("OnClick", function(self)
        MinimapButton.drawerExpanded = not MinimapButton.drawerExpanded
        MinimapButton:LayoutDrawer()
    end)
end

function MinimapButton:LayoutDrawer()
    if not drawerContainer then return end
    local overflowed = self.overflowed or {}

    if not MinimapButton.drawerExpanded or #overflowed == 0 then
        drawerContainer:Hide()
        for _, btn in ipairs(overflowed) do btn:Hide() end
        return
    end

    drawerContainer:Show()
    drawerContainer:ClearAllPoints()
    drawerContainer:SetPoint("TOP", drawerButton, "BOTTOM", 0, -4)
    drawerContainer:SetSize(BUTTON_SIZE, (#overflowed * (BUTTON_SIZE + 4)))

    for i, btn in ipairs(overflowed) do
        btn:ClearAllPoints()
        btn:SetParent(drawerContainer)
        btn:SetPoint("TOP", drawerContainer, "TOP", 0, -(i - 1) * (BUTTON_SIZE + 4))
        btn:Show()
    end
end

function MinimapButton:RecalculateLayout()
    local visible = {}
    for _, name in ipairs(self.order) do
        local btn = self.registry[name]
        if btn and not (btn.db and btn.db.hide) then
            table.insert(visible, btn)
        end
    end

    local onRing, overflow = {}, {}
    for i, btn in ipairs(visible) do
        if i <= self.overflowThreshold then
            table.insert(onRing, btn)
        else
            table.insert(overflow, btn)
        end
    end
    self.overflowed = overflow

    local anchor = Compat:GetMinimapAnchorFrame()

    for _, btn in ipairs(onRing) do
        btn:SetParent(anchor)
        btn:ClearAllPoints()
        local angle = btn.db.minimapPos or 0
        local x, y = AngleToPosition(angle)
        btn:SetPoint("CENTER", anchor, "CENTER", x, y)
        btn:Show()
    end

    if #overflow > 0 then
        EnsureDrawer()
        drawerButton:ClearAllPoints()
        drawerButton:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -4, 4)
        drawerButton:Show()
        self:LayoutDrawer()
    elseif drawerButton then
        drawerButton:Hide()
        drawerContainer:Hide()
    end
end

local function CreateButtonFrame(name, buttonData, db)
    local btn = CreateFrame("Button", "LibMapSuite10_Button_" .. name, Compat:GetMinimapAnchorFrame())
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    btn:SetFrameStrata("MEDIUM")
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")

    local isRetail   = Compat.IsRetail
    local borderSize = isRetail and BORDER_SIZE_RETAIL  or BORDER_SIZE_CLASSIC
    local bgSize     = isRetail and BG_SIZE_RETAIL      or BG_SIZE_CLASSIC
    local iconSize   = buttonData.iconSize or (isRetail and ICON_SIZE_RETAIL or ICON_SIZE_CLASSIC)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(bgSize, bgSize)
    if isRetail then
        bg:SetPoint("CENTER", 0, 0)
    else
        bg:SetPoint("TOPLEFT", 7, -5)
    end

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    if isRetail then
        icon:SetPoint("CENTER", 0, 0)
    else
        icon:SetPoint("TOPLEFT", 7, -6)
    end
    local iconSource = type(buttonData.icon) == "function" and buttonData.icon() or buttonData.icon
    icon:SetTexture(iconSource or "Interface\\Icons\\INV_Misc_QuestionMark")
    if buttonData.iconCoords then
        icon:SetTexCoord(unpack(buttonData.iconCoords))
    else
        icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    end
    btn.icon = icon

    function btn:SetIcon(texturePath, coords)
        local src = type(texturePath) == "function" and texturePath() or texturePath
        self.icon:SetTexture(src or "Interface\\Icons\\INV_Misc_QuestionMark")
        self.icon:SetTexCoord(unpack(coords or {0.05, 0.95, 0.05, 0.95}))
    end

    local overlay = btn:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetSize(borderSize, borderSize)
    overlay:SetPoint("TOPLEFT", 0, 0)

    btn.name = name
    btn.buttonData = buttonData
    btn.db = db

    btn:SetScript("OnClick", function(self, button)
        if buttonData.OnClick then
            buttonData.OnClick(self, button)
        end
    end)

    btn:SetScript("OnEnter", function(self)
        if buttonData.OnEnter then buttonData.OnEnter(self) end
        local owner, anchor = Compat:GetDefaultTooltipAnchor(self)
        GameTooltip:SetOwner(owner, anchor)
        if buttonData.OnTooltipShow then
            buttonData.OnTooltipShow(GameTooltip)
        elseif buttonData.text then
            GameTooltip:SetText(buttonData.text)
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        if buttonData.OnLeave then buttonData.OnLeave(self) end
        GameTooltip:Hide()
    end)

    if buttonData.menu or buttonData.options then
        local menu = private.Menu
        if menu then menu:Attach(btn, buttonData.menu or buttonData.options, buttonData.menuButton) end
    end

    btn:SetScript("OnDragStart", function(self)
        if self.db.locked then return end
        self:SetScript("OnUpdate", function(self)
            local anchor = Compat:GetMinimapAnchorFrame()
            local mx, my = GetCursorPosition()
            local scale = anchor:GetEffectiveScale()
            mx, my = mx / scale, my / scale
            local cx, cy = anchor:GetCenter()
            local angle = math.deg(math.atan2(my - cy, mx - cx))
            self.db.minimapPos = FindFreeAngle(angle % 360, self)
            MinimapButton:RecalculateLayout()
        end)
    end)
    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    return btn
end

function LibMapSuite:RegisterMinimapButton(name, buttonData, db)
    assert(type(name) == "string", "RegisterMinimapButton: name must be a string")
    assert(type(buttonData) == "table", "RegisterMinimapButton: buttonData must be a table")
    db = db or {}

    if db.minimapPos == nil then
        local count = 0
        for _ in pairs(MinimapButton.registry) do count = count + 1 end
        db.minimapPos = (count * 47) % 360
    end
    db.minimapPos = FindFreeAngle(db.minimapPos)

    if MinimapButton.registry[name] then
        local showInCompartment = db.showInCompartment
        self:UnregisterMinimapButton(name)
        db.showInCompartment = showInCompartment
    end

    local btn = CreateButtonFrame(name, buttonData, db)
    MinimapButton.registry[name] = btn
    table.insert(MinimapButton.order, name)

    MinimapButton:RecalculateLayout()
    if db.showInCompartment then self:AddMinimapButtonToCompartment(name) end
    private:Fire("OnMinimapButtonRegistered", name, btn)
    return btn
end

function LibMapSuite:UnregisterMinimapButton(name)
    local btn = MinimapButton.registry[name]
    if not btn then return end
    self:RemoveMinimapButtonFromCompartment(name)
    btn:Hide()
    btn:SetParent(UIParent)
    MinimapButton.registry[name] = nil
    for i, n in ipairs(MinimapButton.order) do
        if n == name then table.remove(MinimapButton.order, i) break end
    end
    MinimapButton:RecalculateLayout()
end

function LibMapSuite:SetMinimapButtonIconSize(name, px)
    assert(type(name) == "string", "SetMinimapButtonIconSize: name must be a string")
    assert(type(px) == "number" and px > 0, "SetMinimapButtonIconSize: px must be a positive number")
    local btn = MinimapButton.registry[name]
    if not btn then return end
    btn.icon:SetSize(px, px)
end

function LibMapSuite:GetMinimapButton(name)
    return MinimapButton.registry[name]
end

function LibMapSuite:SetMinimapButtonIcon(name, texture, coords)
    local btn = MinimapButton.registry[name]
    if btn then btn:SetIcon(texture, coords) end
    return btn
end

function LibMapSuite:ShowMinimapButton(name)
    local btn = MinimapButton.registry[name]
    if btn then btn.db.hide = nil; MinimapButton:RecalculateLayout() end
    return btn
end

function LibMapSuite:HideMinimapButton(name)
    local btn = MinimapButton.registry[name]
    if btn then btn.db.hide = true; MinimapButton:RecalculateLayout() end
    return btn
end

function LibMapSuite:SetMinimapButtonPosition(name, angle)
    local btn = MinimapButton.registry[name]
    if btn and type(angle) == "number" then
        btn.db.minimapPos = angle % 360
        MinimapButton:RecalculateLayout()
    end
    return btn
end

function LibMapSuite:SetMinimapButtonLocked(name, locked)
    local btn = MinimapButton.registry[name]
    if btn then btn.db.locked = locked and true or nil end
    return btn
end

function LibMapSuite:SetMinimapButtonSize(name, pixels)
    assert(type(pixels) == "number" and pixels > 0, "SetMinimapButtonSize: pixels must be positive")
    local btn = MinimapButton.registry[name]
    if btn then btn:SetSize(pixels, pixels); MinimapButton:RecalculateLayout() end
    return btn
end

function LibMapSuite:SetMinimapButtonRingGap(pixels)
    assert(type(pixels) == "number", "SetMinimapButtonRingGap: pixels must be a number")
    MinimapButton.ringGap = pixels
    MinimapButton:RecalculateLayout()
end

function LibMapSuite:RefreshMinimapButton(name)
    local btn = MinimapButton.registry[name]
    if not btn then return nil end
    btn:SetIcon(btn.buttonData.icon, btn.buttonData.iconCoords)
    MinimapButton:RecalculateLayout()
    return btn
end

function LibMapSuite:IsMinimapButtonRegistered(name)
    return MinimapButton.registry[name] ~= nil
end

function LibMapSuite:GetMinimapButtonList()
    local result = {}
    for _, name in ipairs(MinimapButton.order) do
        if MinimapButton.registry[name] then result[#result + 1] = name end
    end
    return result
end

function LibMapSuite:IsAddonCompartmentAvailable()
    return AddonCompartmentFrame and AddonCompartmentFrame.RegisterAddon and true or false
end

function LibMapSuite:IsMinimapButtonInCompartment(name)
    local btn = MinimapButton.registry[name]
    return btn and btn.compartmentData ~= nil or false
end

function LibMapSuite:AddMinimapButtonToCompartment(name, customIcon)
    local btn = MinimapButton.registry[name]
    if not btn or btn.compartmentData or not self:IsAddonCompartmentAvailable() then return false end
    local data = btn.buttonData
    btn.db.showInCompartment = true
    local entry = MinimapButton.retiredCompartmentEntries[name] or {}
    entry.text = data.text or name
    entry.icon = customIcon or (type(data.icon) == "function" and data.icon() or data.icon)
    entry.notCheckable = true
    entry.registerForAnyClick = true
    entry.func = function(_, input)
        if data.OnClick then data.OnClick(btn, input and input.buttonName or "LeftButton") end
    end
    entry.funcOnEnter = function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        if data.OnTooltipShow then data.OnTooltipShow(GameTooltip) else GameTooltip:SetText(data.text or name) end
        GameTooltip:Show()
    end
    entry.funcOnLeave = function() GameTooltip:Hide() end

    btn.compartmentData = entry
    if not MinimapButton.retiredCompartmentEntries[name] then
        AddonCompartmentFrame:RegisterAddon(entry)
    else
        MinimapButton.retiredCompartmentEntries[name] = nil
        if AddonCompartmentFrame.UpdateDisplay then AddonCompartmentFrame:UpdateDisplay() end
    end
    return true
end

function LibMapSuite:RemoveMinimapButtonFromCompartment(name)
    local btn = MinimapButton.registry[name]
    if not btn or not btn.compartmentData or not AddonCompartmentFrame then return false end

    if AddonCompartmentFrame.UnregisterAddon then
        AddonCompartmentFrame:UnregisterAddon(btn.compartmentData)
    else
        btn.compartmentData.func = function() end
        btn.compartmentData.funcOnEnter = nil
        btn.compartmentData.funcOnLeave = nil
        MinimapButton.retiredCompartmentEntries[name] = btn.compartmentData
    end

    btn.compartmentData = nil
    btn.db.showInCompartment = nil
    if AddonCompartmentFrame.UpdateDisplay then AddonCompartmentFrame:UpdateDisplay() end
    return true
end

function LibMapSuite:SetMinimapButtonOverflowThreshold(n)
    assert(n == nil or (type(n) == "number" and n >= 0), "overflow threshold must be zero or greater")
    MinimapButton.overflowThreshold = n or 10
    MinimapButton:RecalculateLayout()
end

if not MinimapButton.callbacksRegistered then
    private:On("OnShapeChanged", function() MinimapButton:RecalculateLayout() end)
    private:On("OnSizeChanged", function() MinimapButton:RecalculateLayout() end)
    MinimapButton.callbacksRegistered = true
end
