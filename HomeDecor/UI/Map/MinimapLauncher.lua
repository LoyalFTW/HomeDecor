local _, NS = ...

NS.UI = NS.UI or {}
local Launcher = {}
NS.UI.MinimapLauncher = Launcher

local function Click(mouseButton)
  if mouseButton == "RightButton" then NS.UI.Settings:OpenOptions() else NS.UI.CatalogView:Toggle() end
end

local function Enter(self)
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine("HomeDecor")
  GameTooltip:AddLine("Left Click: Open catalog", 1, 1, 1)
  GameTooltip:AddLine("Right Click: AddOn settings", 1, 1, 1)
  GameTooltip:Show()
end

local function Leave()
  GameTooltip:Hide()
end

local function Place(button, position)
  local angle = math.rad(tonumber(position) or 225)
  local radius = (Minimap:GetWidth() / 2) + 5
  button:ClearAllPoints()
  button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

function Launcher:SetShown(shown)
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return end
  profile.minimap = profile.minimap or { hide = false }
  profile.minimap.hide = shown ~= true
  if self.iconLib then
    if shown == true then self.iconLib:Show("HomeDecor") else self.iconLib:Hide("HomeDecor") end
  elseif self.button then
    self.button:SetShown(shown == true)
  end
end

function Launcher:Init()
  if self.ready then return end
  local profile = NS.Systems.Database:GetProfile()
  if not profile or not Minimap then return end
  profile.minimap = profile.minimap or { hide = false }
  local iconLib = LibStub and LibStub("LibDBIcon-1.0", true)
  local dataBroker = LibStub and LibStub("LibDataBroker-1.1", true)
  if iconLib and dataBroker then
    local dataObject = dataBroker:NewDataObject("HomeDecor", {
      type = "launcher",
      icon = "Interface\\AddOns\\HomeDecor\\Media\\Icon",
      OnClick = function(_, mouseButton) Click(mouseButton) end,
      OnEnter = Enter,
      OnLeave = Leave,
    })
    iconLib:Register("HomeDecor", dataObject, profile.minimap)
    self.button = iconLib:GetMinimapButton("HomeDecor")
    self.iconLib = iconLib
    self.dataObject = dataObject
    self.ready = true
    return
  end
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
  icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetSize(52, 52)
  border:SetPoint("TOPLEFT")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetSize(24, 24)
  highlight:SetPoint("CENTER")
  highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  highlight:SetBlendMode("ADD")
  button:SetScript("OnClick", function(_, mouseButton) Click(mouseButton) end)
  button:SetScript("OnEnter", Enter)
  button:SetScript("OnLeave", Leave)
  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local centerX, centerY = Minimap:GetCenter()
      local cursorX, cursorY = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      local position = math.deg(math.atan2(cursorY / scale - centerY, cursorX / scale - centerX)) % 360
      profile.minimap.minimapPos = position
      profile.minimap.angle = position
      Place(self, position)
    end)
  end)
  button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  Place(button, profile.minimap.minimapPos or profile.minimap.angle)
  button:SetShown(profile.minimap.hide ~= true)
  self.button = button
  self.ready = true
end
