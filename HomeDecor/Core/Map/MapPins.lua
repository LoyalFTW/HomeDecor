local _, NS = ...

local MapPins = {
  active = {},
  free = {},
  seen = {},
  byMap = {},
  byMapAll = {},
  mapParents = {},
  mapContinents = {},
  miniActive = {},
  miniFree = {},
  badgeActive = {},
  badgeFree = {},
  attached = false,
  revision = 0,
  stats = { refreshes = 0, clears = 0, created = 0, bound = 0, candidates = 0 },
}
NS.Systems.MapPins = MapPins

local MAX_PINS = 24
local MAX_MINIMAP_PINS = 12
local MAX_BADGES = 24

local function HBDPins()
  local stub = _G.LibStub
  return stub and stub("HereBeDragons-Pins-2.0", true)
end

local function ApplyPinStyle(pin, mini)
  local settings = NS.Systems.Settings
  local style = settings and settings:GetValue("mapPinStyle", "house") or "house"
  local size = tonumber(settings and settings:GetValue("mapPinSize", 1) or 1) or 1
  local color = settings and settings:GetValue("mapPinColor", { r = 1, g = 1, b = 1 }) or { r = 1, g = 1, b = 1 }
  size = math.max(0.5, math.min(2, size))
  local base = mini and 14 or 16
  if style == "dot" then
    if pin.bg then pin.bg:Hide() end
    pin:SetSize(math.floor(base * size), math.floor(base * size))
    pin.icon:ClearAllPoints()
    pin.icon:SetPoint("CENTER")
    pin.icon:SetSize(14 * size, 14 * size)
    pin.icon:SetTexture("Interface\\Common\\Indicator-Yellow")
    pin.icon:SetTexCoord(0, 1, 0, 1)
    pin.icon:SetVertexColor(0, 0, 0, 0.9)
    if not pin.innerCircle then pin.innerCircle = pin:CreateTexture(nil, "OVERLAY") end
    pin.innerCircle:ClearAllPoints()
    pin.innerCircle:SetPoint("CENTER")
    pin.innerCircle:SetSize(10 * size, 10 * size)
    pin.innerCircle:SetTexture("Interface\\Common\\Indicator-Yellow")
    pin.innerCircle:SetTexCoord(0, 1, 0, 1)
    pin.innerCircle:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, 1)
    pin.innerCircle:Show()
  else
    if pin.innerCircle then pin.innerCircle:Hide() end
    if pin.bg then
      pin.bg:ClearAllPoints()
      pin.bg:SetAllPoints()
      pin.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
      pin.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
      pin.bg:Show()
    end
    pin:SetSize(math.floor(base * size), math.floor(base * size))
    pin.icon:ClearAllPoints()
    pin.icon:SetAllPoints()
    pin.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
    pin.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    pin.icon:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, 1)
  end
  pin.icon:SetDesaturated(false)
end

local function ApplyBadgeStyle(frame)
  local settings = NS.Systems.Settings
  local style = settings and settings:GetValue("mapPinStyle", "house") or "house"
  local size = tonumber(settings and settings:GetValue("mapPinSize", 1) or 1) or 1
  local color = settings and settings:GetValue("mapPinColor", { r = 1, g = 1, b = 1 }) or { r = 1, g = 1, b = 1 }
  size = math.max(0.5, math.min(2, size))
  frame:SetSize(22 * size, 22 * size)
  if style == "dot" then
    frame.bg:Hide()
    frame.icon:ClearAllPoints()
    frame.icon:SetPoint("CENTER")
    frame.icon:SetSize(20 * size, 20 * size)
    frame.icon:SetTexture("Interface\\Common\\Indicator-Yellow")
    frame.icon:SetTexCoord(0, 1, 0, 1)
    frame.icon:SetVertexColor(0, 0, 0, 0.9)
    if not frame.innerCircle then frame.innerCircle = frame:CreateTexture(nil, "OVERLAY") end
    frame.innerCircle:ClearAllPoints()
    frame.innerCircle:SetPoint("CENTER")
    frame.innerCircle:SetSize(16 * size, 16 * size)
    frame.innerCircle:SetTexture("Interface\\Common\\Indicator-Yellow")
    frame.innerCircle:SetTexCoord(0, 1, 0, 1)
    frame.innerCircle:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, 1)
    frame.innerCircle:Show()
  else
    if frame.innerCircle then frame.innerCircle:Hide() end
    frame.bg:ClearAllPoints()
    frame.bg:SetAllPoints()
    frame.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    frame.bg:SetVertexColor(0.1, 0.1, 0.1, 0.9)
    frame.bg:Show()
    frame.icon:ClearAllPoints()
    frame.icon:SetAllPoints()
    frame.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
    frame.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
    frame.icon:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, 1)
  end
end

local function MapInfo(mapID)
  return _G.C_Map and _G.C_Map.GetMapInfo and _G.C_Map.GetMapInfo(mapID)
end

local function IsWorldMapType(mapType)
  local types = _G.Enum and _G.Enum.UIMapType
  return types and (mapType == types.World or mapType == types.Cosmic)
end

local function IsContinentMapType(mapType)
  local types = _G.Enum and _G.Enum.UIMapType
  return types and mapType == types.Continent
end

function MapPins:GetContinent(mapID)
  local cached = self.mapContinents[mapID]
  if cached ~= nil then return cached or nil end
  local current = mapID
  local visited = {}
  while current and not visited[current] do
    visited[current] = true
    local info = MapInfo(current)
    if not info then break end
    if IsContinentMapType(info.mapType) then
      self.mapContinents[mapID] = current
      return current
    end
    local parent = self.mapParents[current]
    if parent == nil then
      parent = info.parentMapID or false
      self.mapParents[current] = parent
    end
    current = parent or nil
  end
  self.mapContinents[mapID] = false
  return nil
end

local function EnsureBadge(pin)
  if pin.badge then return pin.badge end
  pin.badge = pin:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  pin.badge:SetPoint("BOTTOMRIGHT", 3, -3)
  pin.badge:SetTextColor(1, 0.82, 0.2)
  return pin.badge
end

local function PinTitle(record)
  if not record then return "Decor source" end
  if record.sourceType == "vendor" then
    return record.vendorName or (record.sourceID and NS.Systems.NPCNames:Get(record.sourceID)) or (record.sourceID and ("Vendor #" .. tostring(record.sourceID))) or "Vendor"
  end
  return tostring(record.sourceType or record.category or "Decor source")
end

local VENDOR_CLASSES = {
  [103693] = "Hunter", [105986] = "Rogue", [112318] = "Shaman", [112323] = "Druid",
  [93550] = "Death Knight", [100196] = "Paladin", [112338] = "Monk", [112392] = "Warrior",
  [112401] = "Priest", [112407] = "Demon Hunter", [112434] = "Warlock", [112440] = "Mage",
}

local CLASS_COLORS = {
  ["Death Knight"] = { 0.77, 0.12, 0.23 }, ["Demon Hunter"] = { 0.64, 0.19, 0.79 },
  ["Druid"] = { 1, 0.49, 0.04 }, ["Hunter"] = { 0.67, 0.83, 0.45 },
  ["Mage"] = { 0.25, 0.78, 0.92 }, ["Monk"] = { 0, 1, 0.59 },
  ["Paladin"] = { 0.96, 0.55, 0.73 }, ["Priest"] = { 1, 1, 1 },
  ["Rogue"] = { 1, 0.96, 0.41 }, ["Shaman"] = { 0, 0.44, 0.87 },
  ["Warlock"] = { 0.53, 0.53, 0.93 }, ["Warrior"] = { 0.78, 0.61, 0.43 },
}

local function FactionName(value)
  if type(value) ~= "table" then return value and tostring(value) or nil end
  local alliance, horde
  for _, faction in pairs(value) do
    if faction == "Alliance" then alliance = true elseif faction == "Horde" then horde = true end
  end
  if alliance and horde then return "Both" end
  if alliance then return "Alliance" end
  if horde then return "Horde" end
end

local function FactionText(faction)
  if faction == "Alliance" then return "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:16|t Alliance" end
  if faction == "Horde" then return "|TInterface\\FriendsFrame\\PlusManz-Horde:16:16|t Horde" end
  if faction == "Both" then return "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:16|t |TInterface\\FriendsFrame\\PlusManz-Horde:16:16|t Both" end
  return faction
end

local function SetPinTooltipOwner(pin)
  local anchor = NS.Systems.Settings:GetValue("mapTooltipAnchor", "ANCHOR_RIGHT")
  if anchor == "ANCHOR_MIDDLE" then
    _G.GameTooltip:SetOwner(pin, "ANCHOR_NONE")
    _G.GameTooltip:ClearAllPoints()
    _G.GameTooltip:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  else
    _G.GameTooltip:SetOwner(pin, anchor)
  end
end

local function AppendVendorDecorSummary(tooltip, record, shiftDown)
  local npcID = tonumber(record and record.sourceID)
  if not npcID then return end
  local seen = {}
  local missing = {}
  local owned, total = 0, 0
  NS.Systems.Pipeline:ForEach(nil, function(candidate)
    if candidate.sourceType ~= "vendor" or tonumber(candidate.sourceID) ~= npcID then return end
    local key = tostring(candidate.decorID or candidate.itemID or candidate.id or "")
    if key == "" or seen[key] then return end
    seen[key] = true
    total = total + 1
    if NS.Systems.Collection:IsOwned(candidate) then
      owned = owned + 1
    elseif shiftDown then
      local title = NS.Systems.Housing:GetDisplay(candidate)
      missing[#missing + 1] = title
    end
  end)
  if total == 0 then return end
  tooltip:AddLine(" ", 0, 0, 0)
  tooltip:AddLine("Home|cffff7d0aDecor|r", 1, 0.82, 0)
  tooltip:AddDoubleLine("Collected", tostring(owned) .. " / " .. tostring(total), 1, 1, 1, 1, 1, 1)
  if owned == total then
    tooltip:AddLine("All collected", 0.3, 1, 0.3)
  elseif not shiftDown then
    tooltip:AddLine("Hold Shift to show missing decor", 0.8, 0.8, 0.8)
  else
    table.sort(missing)
    for index = 1, math.min(#missing, 25) do tooltip:AddLine(missing[index], 1, 0.2, 0.2) end
    if #missing > 25 then tooltip:AddLine("+" .. tostring(#missing - 25) .. " more...", 0.8, 0.8, 0.8) end
  end
end

local function ShowPinTooltip(pin)
  local record = pin.record
  if not record or not _G.GameTooltip then return end
  local shiftDown = _G.IsShiftKeyDown and _G.IsShiftKeyDown() == true
  pin.tooltipShift = shiftDown
  SetPinTooltipOwner(pin)
  _G.GameTooltip:SetText(PinTitle(record), 1, 1, 1)
  if record.zone then _G.GameTooltip:AddLine(tostring(record.zone), 0.8, 0.8, 0.8) end
  local faction = FactionName(record.faction)
  if faction then _G.GameTooltip:AddDoubleLine("Faction", FactionText(faction), 0.8, 0.8, 0.8, 0.8, 0.8, 0.8) end
  local class = VENDOR_CLASSES[tonumber(record.sourceID)]
  if class then
    local color = CLASS_COLORS[class] or { 0.8, 0.8, 0.8 }
    _G.GameTooltip:AddDoubleLine("Requires", class, 0.8, 0.8, 0.8, color[1], color[2], color[3])
  end
  _G.GameTooltip:AddLine(" ", 0, 0, 0)
  _G.GameTooltip:AddLine(NS.Systems.Navigation:IsActive(record) and "Left-click: Clear Waypoint" or "Left-click: Set Waypoint", 1, 0.82, 0)
  if pin.isMinimap then
    _G.GameTooltip:AddLine(record.sourceType == "vendor" and "Right-click: Open Vendor in Tracker" or "Right-click: Open Source in Tracker", 1, 0.82, 0)
  else
    _G.GameTooltip:AddLine(record.sourceType == "vendor" and "Right-click: View Vendor Items" or "Right-click: View Source Items", 1, 0.82, 0)
  end
  if shiftDown and record.sourceID then _G.GameTooltip:AddLine("NPC ID: " .. tostring(record.sourceID), 0.8, 0.8, 0.8) end
  AppendVendorDecorSummary(_G.GameTooltip, record, shiftDown)
  _G.GameTooltip:Show()
end

local function UpdatePinTooltip(pin, elapsed)
  pin.tooltipElapsed = (pin.tooltipElapsed or 0) + elapsed
  if pin.tooltipElapsed < 0.1 then return end
  pin.tooltipElapsed = 0
  local shiftDown = _G.IsShiftKeyDown and _G.IsShiftKeyDown() == true
  if shiftDown ~= pin.tooltipShift then ShowPinTooltip(pin) end
end

local function EnterPinTooltip(pin)
  pin.tooltipElapsed = 0
  ShowPinTooltip(pin)
  pin:SetScript("OnUpdate", UpdatePinTooltip)
end

local function LeavePinTooltip(pin)
  pin:SetScript("OnUpdate", nil)
  pin.tooltipElapsed = nil
  pin.tooltipShift = nil
  if _G.GameTooltip then _G.GameTooltip:Hide() end
end

local function ResetPinTooltip(pin)
  pin:SetScript("OnUpdate", nil)
  pin.tooltipElapsed = nil
  pin.tooltipShift = nil
  if _G.GameTooltip and _G.GameTooltip.GetOwner and _G.GameTooltip:GetOwner() == pin then _G.GameTooltip:Hide() end
end

local function NewMiniPin()
  local pin = CreateFrame("Button", nil, _G.Minimap)
  pin.isMinimap = true
  pin:SetSize(14, 14)
  pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  pin.bg = pin:CreateTexture(nil, "BACKGROUND")
  pin.bg:SetAllPoints()
  pin.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  pin.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
  pin.icon = pin:CreateTexture(nil, "ARTWORK")
  pin.icon:SetAllPoints()
  pin.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
  EnsureBadge(pin)
  pin:SetScript("OnClick", function(self, button)
    local record = self.record
    if not record then return end
    if button == "LeftButton" then
      NS.Systems.Navigation:Toggle(record)
      if self:IsMouseOver() then ShowPinTooltip(self) end
      return
    end
    LeavePinTooltip(self)
    if NS.UI and NS.UI.TrackerPanel and NS.UI.TrackerPanel.OpenArea then NS.UI.TrackerPanel:OpenArea(record) end
  end)
  pin:SetScript("OnEnter", EnterPinTooltip)
  pin:SetScript("OnLeave", LeavePinTooltip)
  return pin
end

local function NewMapBadge()
  local badge = CreateFrame("Button", nil, UIParent)
  badge:SetSize(22, 22)
  badge:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  badge.bg = badge:CreateTexture(nil, "BACKGROUND")
  badge.bg:SetAllPoints()
  badge.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  badge.bg:SetVertexColor(0.05, 0.05, 0.05, 0.9)
  badge.icon = badge:CreateTexture(nil, "ARTWORK")
  badge.icon:SetAllPoints()
  badge.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
  badge.icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
  badge.icon:SetVertexColor(1, 1, 1, 1)
  badge.countBg = badge:CreateTexture(nil, "OVERLAY")
  badge.countBg:SetSize(17, 13)
  badge.countBg:SetPoint("BOTTOMRIGHT", 4, -3)
  badge.countBg:SetColorTexture(0, 0, 0, 0.85)
  badge.count = badge:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  badge.count:SetPoint("CENTER", badge.countBg)
  badge.count:SetTextColor(1, 0.82, 0.2)
  badge:SetScript("OnClick", function(self, button)
    if not self.mapID then return end
    if button == "LeftButton" and _G.WorldMapFrame then _G.WorldMapFrame:SetMapID(self.mapID) end
    if button == "RightButton" then NS.UI.MapDirectory:Open(self.mapID) end
  end)
  badge:SetScript("OnEnter", function(self)
    if not self.mapID then return end
    GameTooltip:SetOwner(self, NS.Systems.Settings:GetValue("mapTooltipAnchor", "ANCHOR_RIGHT"))
    GameTooltip:SetText(self.name or "Decor locations")
    GameTooltip:AddLine(tostring(self.total or 0) .. " decor sources", 1, 1, 1)
    GameTooltip:AddLine("Left-click: Open map", 0.8, 0.8, 0.8)
    GameTooltip:Show()
  end)
  badge:SetScript("OnLeave", function() GameTooltip:Hide() end)
  return badge
end

local function NewPin(parent)
  local pin = CreateFrame("Button", nil, parent)
  MapPins.stats.created = MapPins.stats.created + 1
  pin:SetSize(18, 18)
  pin:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  pin.bg = pin:CreateTexture(nil, "BACKGROUND")
  pin.bg:SetAllPoints()
  pin.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  pin.bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
  pin.icon = pin:CreateTexture(nil, "ARTWORK")
  pin.icon:SetAllPoints()
  pin.icon:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\Icon")
  EnsureBadge(pin)
  pin:SetScript("OnClick", function(button, mouseButton)
    if not button.record or not NS.UI or not NS.UI.CatalogView then return end
    if mouseButton == "LeftButton" then
      NS.Systems.Navigation:Toggle(button.record)
      if button:IsMouseOver() then ShowPinTooltip(button) end
      return
    end
    LeavePinTooltip(button)
    local sourceFilter = button.record.sourceType == "vendor" and ("vendor:" .. tostring(button.record.sourceID)) or ("source:" .. tostring(button.record.sourceType or button.record.category))
    NS.UI.MapDirectory:Open(button.record.mapID, sourceFilter)
  end)
  pin:SetScript("OnEnter", EnterPinTooltip)
  pin:SetScript("OnLeave", LeavePinTooltip)
  return pin
end

function MapPins:Prewarm(parent)
  if not parent then return end
  while (#self.active + #self.free) < MAX_PINS do
    local pin = NewPin(parent)
    pin:Hide()
    self.free[#self.free + 1] = pin
  end
end

function MapPins:Acquire(parent)
  local pin = table.remove(self.free)
  if pin then
    pin:SetParent(parent)
    return pin
  end
  return NewPin(parent)
end

function MapPins:Clear()
  NS.Systems.Diagnostics:Mark("MapPins:Clear")
  NS.Systems.Diagnostics:Checkpoint("MapPins:Clear")
  self.revision = self.revision + 1
  self.stats.clears = self.stats.clears + 1
  for index = 1, #self.active do
    local pin = self.active[index]
    local pins = HBDPins()
    if pins then pins:RemoveWorldMapIcon(NS.Name, pin) end
    ResetPinTooltip(pin)
    pin.record = nil
    EnsureBadge(pin):Hide()
    pin:Hide()
    self.free[#self.free + 1] = pin
  end
  wipe(self.active)
end

function MapPins:ClearMinimap()
  local pins = HBDPins()
  for index = 1, #self.miniActive do
    local pin = self.miniActive[index]
    if pins then pins:RemoveMinimapIcon(NS.Name, pin) end
    ResetPinTooltip(pin)
    pin.record = nil
    EnsureBadge(pin):Hide()
    pin:Hide()
    self.miniFree[#self.miniFree + 1] = pin
  end
  wipe(self.miniActive)
end

function MapPins:ClearBadges()
  local pins = HBDPins()
  for index = 1, #self.badgeActive do
    local badge = self.badgeActive[index]
    if pins then pins:RemoveWorldMapIcon(NS.Name, badge) end
    badge:Hide()
    self.badgeFree[#self.badgeFree + 1] = badge
  end
  wipe(self.badgeActive)
end

function MapPins:RefreshBadges(mapID)
  self:ClearBadges()
  local map = _G.WorldMapFrame
  local info = mapID and MapInfo(mapID)
  local mapType = info and info.mapType
  local worldMap = IsWorldMapType(mapType)
  local continentMap = IsContinentMapType(mapType)
  if not map or not mapID or not (worldMap or continentMap) then return end
  local pins = HBDPins()
  if not pins then return end
  local groups = {}
  for childMapID, locations in pairs(self.byMapAll) do
    local continentID = self:GetContinent(childMapID)
    local anchorMapID
    if worldMap then
      anchorMapID = continentID or childMapID
    elseif continentID == mapID then
      anchorMapID = childMapID
    end
    if anchorMapID and childMapID ~= mapID and #locations > 0 then
      local group = groups[anchorMapID]
      if not group then
        group = { mapID = anchorMapID, total = 0 }
        groups[anchorMapID] = group
      end
      group.total = group.total + #locations
    end
  end
  for anchorMapID, group in pairs(groups) do
    if #self.badgeActive >= MAX_BADGES then break end
      local badge = table.remove(self.badgeFree) or NewMapBadge()
      local childInfo = MapInfo(anchorMapID)
      badge.mapID = anchorMapID
      badge.name = childInfo and childInfo.name or "Decor locations"
      badge.total = group.total
      badge.count:SetText(tostring(group.total))
      ApplyBadgeStyle(badge)
      badge:Show()
      local showFlag = worldMap and _G.HBD_PINS_WORLDMAP_SHOW_WORLD or _G.HBD_PINS_WORLDMAP_SHOW_CONTINENT
      if pins:AddWorldMapIconMap(NS.Name, badge, anchorMapID, 0.5, 0.5, showFlag) then
        self.badgeActive[#self.badgeActive + 1] = badge
      else
        badge:Hide()
        self.badgeFree[#self.badgeFree + 1] = badge
      end
  end
end

function MapPins:RefreshMinimap()
  self:ClearMinimap()
  if NS.Systems.Settings and not NS.Systems.Settings:Get("mapMinimapPins") then return end
  local pins = HBDPins()
  if not pins or not _G.C_Map or not _G.C_Map.GetBestMapForUnit then return end
  local mapID = _G.C_Map.GetBestMapForUnit("player")
  local locations = mapID and self.byMapAll[mapID]
  for index = 1, math.min(#(locations or {}), MAX_MINIMAP_PINS) do
    local marker = locations[index]
    local record = marker.record
    local pin = table.remove(self.miniFree) or NewMiniPin()
    pin.record = record
    local badge = EnsureBadge(pin)
    badge:SetText(marker.count > 1 and tostring(marker.count) or "")
    badge:SetShown(marker.count > 1)
    ApplyPinStyle(pin, true)
    pin:Show()
    pins:AddMinimapIconMap(NS.Name, pin, record.mapID, record.mapX, record.mapY, true, true)
    self.miniActive[#self.miniActive + 1] = pin
  end
end

function MapPins:Layout()
  NS.Systems.Diagnostics:Mark("MapPins:Layout")
end

function MapPins:RebuildTrackedIndex()
  wipe(self.byMap)
  wipe(self.byMapAll)
  wipe(self.mapParents)
  wipe(self.mapContinents)
  wipe(self.seen)
  NS.Systems.Pipeline:ForEach(nil, function(record)
    local mapID, x, y = record.mapID, record.mapX, record.mapY
    if not mapID or not x or not y then return end
    local key = tostring(record.sourceID or record.id or record.decorID) .. ":" .. tostring(math.floor(x * 10000)) .. ":" .. tostring(math.floor(y * 10000))
    local seen = self.seen[mapID]
    if not seen then
      seen = {}
      self.seen[mapID] = seen
    end
    local marker = seen[key]
    if marker then
      marker.count = marker.count + 1
      if NS.Systems.Tracker:IsTracked(record) then marker.tracked = true end
      return
    end
    local locations = self.byMap[mapID]
    if not locations then
      locations = {}
      self.byMap[mapID] = locations
    end
    marker = { record = record, count = 1, tracked = NS.Systems.Tracker:IsTracked(record) }
    seen[key] = marker
    locations[#locations + 1] = marker
    local all = self.byMapAll[mapID]
    if not all then
      all = {}
      self.byMapAll[mapID] = all
    end
    all[#all + 1] = marker
  end)
  wipe(self.seen)
end

function MapPins:Refresh()
  NS.Systems.Diagnostics:Mark("MapPins:Refresh")
  NS.Systems.Diagnostics:Checkpoint("MapPins:Refresh:start")
  self._scheduled = nil
  self.stats.refreshes = self.stats.refreshes + 1
  self:Clear()
  self:ClearBadges()
  if NS.Systems.Settings and not NS.Systems.Settings:Get("mapPins") then return end
  local map = _G.WorldMapFrame
  local canvas = map and map.ScrollContainer and map.ScrollContainer.Child
  if not map or not canvas or not map:IsShown() then return end
  self:Prewarm(canvas)
  local mapID = map:GetMapID()
  if not mapID then return end
  local locations = self.byMapAll[mapID]
  self.stats.candidates = locations and #locations or 0
  for index = 1, #(locations or {}) do
    if #self.active >= MAX_PINS then break end
    local marker = locations[index]
    local record = marker.record
    local pin = self:Acquire(canvas)
    pin.record = record
    pin.x = record.mapX
    pin.y = record.mapY
    local badge = EnsureBadge(pin)
    badge:SetText(marker.count > 1 and tostring(marker.count) or "")
    badge:SetShown(marker.count > 1)
    ApplyPinStyle(pin, false)
    pin:Show()
    local pins = HBDPins()
    if pins and pins:AddWorldMapIconMap(NS.Name, pin, record.mapID, record.mapX, record.mapY) then
      self.active[#self.active + 1] = pin
      self.stats.bound = self.stats.bound + 1
    else
      pin:Hide()
      self.free[#self.free + 1] = pin
    end
  end
  self:Layout()
  self:RefreshBadges(mapID)
  NS.Systems.Diagnostics:Checkpoint("MapPins:Refresh:end")
end

function MapPins:QueueRefresh(includeMinimap)
  if includeMinimap then self._refreshMinimap = true end
  if self._refreshQueued then return end
  self._refreshQueued = true
  local function refresh()
    local refreshMinimap = MapPins._refreshMinimap
    MapPins._refreshQueued = nil
    MapPins._refreshMinimap = nil
    MapPins:Refresh()
    if refreshMinimap then MapPins:RefreshMinimap() end
  end
  if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0, refresh) else refresh() end
end

function MapPins:RequestRefresh()
  NS.Systems.Diagnostics:Mark("MapPins:RequestRefresh")
  self:QueueRefresh(true)
end

function MapPins:RequestMapRefresh()
  NS.Systems.Diagnostics:Mark("MapPins:RequestMapRefresh")
  self:QueueRefresh(false)
end

function MapPins:Attach()
  local map = _G.WorldMapFrame
  if self.attached or not map then return end
  self.attached = true
  self:Prewarm(map.ScrollContainer and map.ScrollContainer.Child)
  if NS.UI and NS.UI.MapDirectory then NS.UI.MapDirectory:Attach() end
  self.mapEvents = self.mapEvents or CreateFrame("Frame")
  self.mapEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.mapEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  self.mapEvents:SetScript("OnEvent", function() MapPins:RefreshMinimap() end)
  map:HookScript("OnShow", function()
    NS.Systems.Diagnostics:StartMapTrace()
    MapPins._observedMapID = map:GetMapID()
    MapPins:RequestMapRefresh()
  end)
  map:HookScript("OnHide", function()
    MapPins:Clear()
    MapPins:ClearBadges()
    NS.Systems.Diagnostics:StopMapTrace()
  end)
  map:HookScript("OnSizeChanged", function()
    NS.Systems.Diagnostics:Mark("Map:OnSizeChanged")
    MapPins:Layout()
  end)
  hooksecurefunc(map, "SetMapID", function()
    NS.Systems.Diagnostics:Mark("Map:SetMapID")
    local mapID = map:GetMapID()
    if MapPins._observedMapID == mapID then return end
    MapPins._observedMapID = mapID
    NS.Systems.Diagnostics:Checkpoint("Map:SetMapID")
    MapPins:RequestMapRefresh()
  end)
  self:RefreshMinimap()
end

function MapPins:Open(record)
  local mapID = record and record.mapID
  if not mapID or not _G.WorldMapFrame then return false end
  self:Attach()
  if _G.C_Map and _G.C_Map.OpenWorldMap then
    _G.C_Map.OpenWorldMap(mapID)
  else
    _G.WorldMapFrame:Show()
    _G.WorldMapFrame:SetMapID(mapID)
  end
  return true
end
