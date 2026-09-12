local _, NS = ...

NS.UI = NS.UI or {}
local Launcher = {}
NS.UI.MinimapLauncher = Launcher

local LDB_NAME = "HomeDecor"
local MINIMAP_ICON = "Interface\\AddOns\\HomeDecor\\Media\\Icon"

local function Click(mouseButton)
    if mouseButton == "LeftButton" then
        if NS.UI.CatalogView then
            NS.UI.CatalogView:Toggle()
        end
    elseif mouseButton == "RightButton" then
        if NS.UI.Settings then
            NS.UI.Settings:OpenOptions()
        end
    end
end

local function PopulateTooltip(tooltip)
    tooltip:AddLine("HomeDecor", 1, 1, 1)
    tooltip:AddLine("Left Click: Open catalog", 0.8, 0.8, 0.8)
    tooltip:AddLine("Right Click: AddOn settings", 0.8, 0.8, 0.8)
    tooltip:AddLine("Use /hd minimap to hide this button", 0.5, 0.5, 0.5)
end

local function Enter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    PopulateTooltip(GameTooltip)
    GameTooltip:Show()
end

local function Leave()
    GameTooltip:Hide()
end

local function RegisterCompartment(launcher)
    if launcher.compartmentRegistered or not AddonCompartmentFrame or not AddonCompartmentFrame.RegisterAddon then
        return
    end

    AddonCompartmentFrame:RegisterAddon({
        text = LDB_NAME,
        icon = MINIMAP_ICON,
        notCheckable = true,
        registerForAnyClick = true,
        func = function(_, menuInputData)
            Click(menuInputData and menuInputData.buttonName or "LeftButton")
        end,
        funcOnEnter = Enter,
        funcOnLeave = Leave,
    })
    launcher.compartmentRegistered = true
end

local function Place(button, position)
    local angle = math.rad(tonumber(position) or 225)
    local radius = (Minimap:GetWidth() / 2) + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function CreateFallbackButton(profile)
    local button = CreateFrame("Button", "HomeDecorMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(24, 24)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER")
    icon:SetTexture(MINIMAP_ICON)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(52, 52)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetSize(24, 24)
    highlight:SetPoint("CENTER")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")

    button:SetScript("OnClick", function(_, mouseButton)
        Click(mouseButton)
    end)
    button:SetScript("OnEnter", Enter)
    button:SetScript("OnLeave", Leave)
    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local centerX, centerY = Minimap:GetCenter()
            local cursorX, cursorY = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local position = math.deg(math.atan2(cursorY / scale - centerY, cursorX / scale - centerX)) % 360
            profile.minimap.minimapPos = position
            Place(self, position)
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    Place(button, profile.minimap.minimapPos)
    button:SetShown(profile.minimap.hide ~= true)
    return button
end

function Launcher:Init()
    if self.ready then return end

    local profile = NS.Systems.Database:GetProfile()
    if not profile or not Minimap then return end

    profile.minimap = profile.minimap or { hide = false }
    profile.minimap.showInCompartment = true

    local iconLib = LibStub and LibStub("LibDBIcon-1.0", true)
    local dataBroker = LibStub and LibStub("LibDataBroker-1.1", true)
    if iconLib and dataBroker then
        local dataObject = dataBroker:NewDataObject(LDB_NAME, {
            type = "launcher",
            text = LDB_NAME,
            icon = MINIMAP_ICON,
            OnClick = function(_, mouseButton)
                Click(mouseButton)
            end,
            OnTooltipShow = PopulateTooltip,
        })

        if not iconLib.IsRegistered or not iconLib:IsRegistered(LDB_NAME) then
            iconLib:Register(LDB_NAME, dataObject, profile.minimap)
        end
        if iconLib.IsButtonCompartmentAvailable and iconLib:IsButtonCompartmentAvailable() then
            iconLib:AddButtonToCompartment(LDB_NAME, MINIMAP_ICON)
            self.compartmentRegistered = true
        else
            RegisterCompartment(self)
        end
        self.button = iconLib.GetMinimapButton and iconLib:GetMinimapButton(LDB_NAME) or nil
        self.iconLib = iconLib
        self.dataObject = dataObject
        self.ready = true
        return
    end

    self.button = CreateFallbackButton(profile)
    RegisterCompartment(self)
    self.ready = true
end

function Launcher:SetMinimapHidden(hide)
    local profile = NS.Systems.Database:GetProfile()
    if not profile then return end

    profile.minimap = profile.minimap or { hide = false }
    profile.minimap.hide = hide and true or false
    if self.iconLib then
        if hide then
            self.iconLib:Hide(LDB_NAME)
        else
            self.iconLib:Show(LDB_NAME)
        end
    elseif self.button then
        self.button:SetShown(not hide)
    end
end
