local _, NS = ...

NS.UI = NS.UI or {}
local MapDirectory = { records = {} }
NS.UI.MapDirectory = MapDirectory

local ROW_HEIGHT = 52
local ROW_COUNT = 10

local function CurrentMapID()
  local map = _G.WorldMapFrame
  if map and map.GetMapID then
    local mapID = map:GetMapID()
    if mapID then return mapID end
  end
  if _G.C_Map and _G.C_Map.GetBestMapForUnit then
    return _G.C_Map.GetBestMapForUnit("player")
  end
end

local function MapName(mapID)
  local info = _G.C_Map and _G.C_Map.GetMapInfo and _G.C_Map.GetMapInfo(mapID)
  return info and info.name or (mapID and ("Map " .. tostring(mapID)) or "Current map")
end

local function SourceName(record)
  if record.sourceType == "vendor" and record.sourceID then
    return NS.Systems.NPCNames:Get(record.sourceID) or ("Vendor #" .. tostring(record.sourceID))
  end
  return tostring(record.sourceType or record.category or "Other sources")
end

local function Preview(record)
  local itemID = record and (record.itemID or record.id)
  if itemID and _G.DressUpItemLink and pcall(_G.DressUpItemLink, "item:" .. tostring(itemID)) then return end
  NS.UI.Inspector:Show(record)
end

function MapDirectory:CreateRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  row:SetBackdropColor(0.06, 0.08, 0.11, 0.96)
  row:SetBackdropBorderColor(0.2, 0.25, 0.32, 1)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(36, 36)
  row.icon:SetPoint("LEFT", 8, 0)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(16, 16)
  row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 10, -5)
  row.title:SetPoint("TOPRIGHT", -8, -5)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 10, 5)
  row.meta:SetPoint("BOTTOMRIGHT", -8, 5)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetWordWrap(false)
  row:SetScript("OnClick", function(self, button)
    if self.header then
      MapDirectory.openSources = MapDirectory.openSources or {}
      MapDirectory.openSources[self.sourceKey] = not MapDirectory.openSources[self.sourceKey]
      MapDirectory:Build()
      MapDirectory:Render()
      return
    end
    local record = self.record
    if not record or NS.UI.ItemInteractions:HandleClick(record) then return end
    if button == "RightButton" then
      NS.Systems.Navigation:Open(record)
    else
      Preview(record)
    end
  end)
  row:SetScript("OnEnter", function(self)
    if self.record then NS.UI.ItemTooltip:Show(self, self.record, "map") end
  end)
  row:SetScript("OnLeave", function() NS.UI.ItemTooltip:Hide() end)
  return row
end

function MapDirectory:Create()
  if self.frame then return self.frame end
  local parent = _G.WorldMapFrame or UIParent
  local frame = CreateFrame("Frame", "HomeDecorMapDirectory", parent, "BackdropTemplate")
  frame:SetSize(350, 470)
  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 18, -70)
  frame:SetClampedToScreen(true)
  frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  frame:SetBackdropColor(0.025, 0.02, 0.012, 0.93)
  frame:SetBackdropBorderColor(0.85, 0.5, 0.16, 1)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 14, -14)
  title:SetText("Decor Tracker")
  frame.title = title
  local toggle = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  toggle:SetSize(24, 22)
  toggle:SetPoint("TOPRIGHT", -36, -12)
  toggle:SetScript("OnClick", function()
    local minimized = not NS.Systems.Settings:GetValue("mapOverlayMinimized", true)
    NS.Systems.Settings:SetValue("mapOverlayMinimized", minimized)
    MapDirectory:ApplyMinimized()
  end)
  frame.toggle = toggle
  frame.map = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  frame.map:SetSize(170, 22)
  frame.map:SetPoint("TOPLEFT", 12, -43)
  frame.map:SetScript("OnClick", function(self)
    NS.UI.Dropdown:Show(self, MapDirectory.maps, MapDirectory.mapID, function(value)
      MapDirectory:SetMap(value)
      MapDirectory:Render()
    end)
  end)
  frame.count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.count:SetPoint("TOPRIGHT", -42, -18)
  local close = NS.UI.Controls:CreateCloseButton(frame, function() frame:Hide() end)
  close:SetPoint("TOPRIGHT", -8, -8)
  local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  refresh:SetSize(58, 22)
  refresh:SetPoint("TOPRIGHT", close, "BOTTOMLEFT", -4, -5)
  refresh:SetText("Here")
  refresh:SetScript("OnClick", function() MapDirectory:SetMap(CurrentMapID()) end)
  local source = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  source:SetSize(250, 22)
  source:SetPoint("TOPLEFT", 12, -70)
  source:SetScript("OnClick", function(self)
    NS.UI.Dropdown:Show(self, MapDirectory.sources, MapDirectory.sourceFilter, function(value)
      MapDirectory.sourceFilter = value
      NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
      MapDirectory:Build()
      MapDirectory:Render()
    end)
  end)
  frame.source = source
  local scroll = NS.UI.Controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", 12, -98)
  scroll:SetPoint("BOTTOMRIGHT", -28, 12)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetWidth(300)
  content:SetHeight(1)
  NS.UI.Controls:ConfigureScrollFrame(scroll, content, { step = ROW_HEIGHT, onScroll = function() MapDirectory:Render() end })
  frame.scroll = scroll
  frame.content = content
  frame.rows = {}
  for index = 1, ROW_COUNT do
    local row = self:CreateRow(content)
    NS.UI.Controls:ForwardScrollWheel(row, scroll)
    row:Hide()
    frame.rows[index] = row
  end
  frame:SetScript("OnShow", function() MapDirectory:Refresh() end)
  frame:Hide()
  self.frame = frame
  return frame
end

function MapDirectory:ApplyMinimized()
  local frame = self.frame
  if not frame then return end
  local minimized = NS.Systems.Settings:GetValue("mapOverlayMinimized", true) == true
  frame.map:SetShown(not minimized)
  frame.source:SetShown(not minimized)
  frame.count:SetShown(not minimized)
  frame.scroll:SetShown(not minimized)
  frame.title:SetText(minimized and (MapName(self.mapID) .. " Decor") or "Decor Tracker")
  frame.toggle:SetText(minimized and "+" or "-")
  frame:SetSize(minimized and 190 or 350, minimized and 34 or 470)
end

function MapDirectory:CreateLauncher()
  if self.launcher then return self.launcher end
  local map = _G.WorldMapFrame
  if not map then return end
  local stub = _G.LibStub
  local library = stub and stub("Krowi_WorldMapButtons-1.4", true)
  if not library then return end
  local button = library:Add("HomeDecorWorldMapButtonTemplate", "Button")
  button.Refresh = function(self) self:Show() end
  button:SetScript("OnClick", function() MapDirectory:ToggleOptions(button) end)
  button:SetScript("OnMouseDown", function(self)
    self.Icon:ClearAllPoints()
    self.Icon:SetPoint("TOPLEFT", 8, -8)
  end)
  button:SetScript("OnMouseUp", function(self)
    self.Icon:ClearAllPoints()
    self.Icon:SetPoint("TOPLEFT", 6, -6)
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Home|cffff7d0aDecor|r")
    GameTooltip:AddLine("Map overlay and pin controls", 1, 1, 1)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  self.launcher = button
  return button
end

function MapDirectory:CreateOptions()
  if self.options then return self.options end
  local frame = CreateFrame("Frame", "HomeDecorMapOptions", UIParent, "BackdropTemplate")
  frame:SetSize(290, 258)
  frame:SetFrameStrata("DIALOG")
  frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  frame:SetBackdropColor(0.025, 0.02, 0.012, 0.97)
  frame:SetBackdropBorderColor(0.85, 0.5, 0.16, 1)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -12)
  title:SetText("HomeDecor Map Controls")
  frame.checks = {}
  local options = {
    { key = "mapOverlay", label = "Show decor overlay", default = true },
    { key = "mapPins", label = "Show world map pins", default = true },
    { key = "mapMinimapPins", label = "Show minimap pins", default = true },
    { key = "mapOverlayIncludeCollected", label = "Include collected decor", default = false },
  }
  for index = 1, #options do
    local option = options[index]
    local check = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    check:SetSize(22, 22)
    check:SetPoint("TOPLEFT", 12, -34 - (index - 1) * 32)
    check.key = option.key
    check.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    check.label:SetPoint("LEFT", check, "RIGHT", 3, 0)
    check.label:SetText(option.label)
    check:SetScript("OnClick", function(self)
      NS.Systems.Settings:Set(self.key, self:GetChecked())
      if self.key == "mapOverlay" then
        if self:GetChecked() then MapDirectory:ShowOverlay() else MapDirectory:Hide() end
      elseif self.key == "mapOverlayIncludeCollected" then
        MapDirectory:Refresh()
      else
        NS.Systems.MapPins:RequestRefresh()
      end
    end)
    check.default = option.default
    frame.checks[index] = check
  end
  local style = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  style:SetSize(104, 22)
  style:SetPoint("BOTTOMLEFT", 12, 42)
  style:SetScript("OnClick", function(self)
    local nextStyle = NS.Systems.Settings:GetValue("mapPinStyle", "house") == "house" and "dot" or "house"
    NS.Systems.Settings:SetValue("mapPinStyle", nextStyle)
    self:SetText("Pins: " .. (nextStyle == "house" and "House" or "Dot"))
    NS.Systems.MapPins:RequestRefresh()
  end)
  frame.style = style
  local sizeDown = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  sizeDown:SetSize(28, 22)
  sizeDown:SetPoint("LEFT", style, "RIGHT", 6, 0)
  sizeDown:SetText("-")
  local sizeUp = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  sizeUp:SetSize(28, 22)
  sizeUp:SetPoint("LEFT", sizeDown, "RIGHT", 2, 0)
  sizeUp:SetText("+")
  local function ChangeSize(delta)
    local value = tonumber(NS.Systems.Settings:GetValue("mapPinSize", 1)) or 1
    value = math.max(0.7, math.min(1.5, value + delta))
    NS.Systems.Settings:SetValue("mapPinSize", value)
    frame.size:SetText(string.format("%.1fx", value))
    NS.Systems.MapPins:RequestRefresh()
  end
  sizeDown:SetScript("OnClick", function() ChangeSize(-0.1) end)
  sizeUp:SetScript("OnClick", function() ChangeSize(0.1) end)
  frame.size = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.size:SetPoint("LEFT", sizeUp, "RIGHT", 5, 0)
  local tooltip = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  tooltip:SetSize(126, 22)
  tooltip:SetPoint("BOTTOMRIGHT", -12, 12)
  tooltip:SetScript("OnClick", function(self)
    local current = NS.Systems.Settings:GetValue("mapTooltipAnchor", "ANCHOR_RIGHT")
    local nextAnchor = current == "ANCHOR_RIGHT" and "ANCHOR_LEFT" or (current == "ANCHOR_LEFT" and "ANCHOR_CURSOR" or "ANCHOR_RIGHT")
    NS.Systems.Settings:SetValue("mapTooltipAnchor", nextAnchor)
    self:SetText("Tooltip: " .. (nextAnchor == "ANCHOR_RIGHT" and "Right" or (nextAnchor == "ANCHOR_LEFT" and "Left" or "Cursor")))
  end)
  frame.tooltip = tooltip
  local color = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  color:SetSize(126, 22)
  color:SetPoint("BOTTOMLEFT", 12, 12)
  color:SetText("Pin color")
  color:SetScript("OnClick", function()
    local value = NS.Systems.Settings:GetValue("mapPinColor", { r = 1, g = 1, b = 1 })
    if not _G.ColorPickerFrame then return end
    _G.ColorPickerFrame:SetupColorPickerAndShow({
      r = value.r or 1,
      g = value.g or 1,
      b = value.b or 1,
      hasOpacity = false,
      swatchFunc = function()
        local r, g, b = _G.ColorPickerFrame:GetColorRGB()
        NS.Systems.Settings:SetValue("mapPinColor", { r = r, g = g, b = b })
        NS.Systems.MapPins:RequestRefresh()
      end,
    })
  end)
  frame:SetScript("OnShow", function()
    for index = 1, #frame.checks do
      local check = frame.checks[index]
      check:SetChecked(NS.Systems.Settings:GetValue(check.key, check.default))
    end
    local pinStyle = NS.Systems.Settings:GetValue("mapPinStyle", "house")
    frame.style:SetText("Pins: " .. (pinStyle == "house" and "House" or "Dot"))
    frame.size:SetText(string.format("%.1fx", tonumber(NS.Systems.Settings:GetValue("mapPinSize", 1)) or 1))
    local anchor = NS.Systems.Settings:GetValue("mapTooltipAnchor", "ANCHOR_RIGHT")
    frame.tooltip:SetText("Tooltip: " .. (anchor == "ANCHOR_RIGHT" and "Right" or (anchor == "ANCHOR_LEFT" and "Left" or "Cursor")))
  end)
  frame:Hide()
  self.options = frame
  return frame
end

function MapDirectory:ToggleOptions(anchor)
  local frame = self:CreateOptions()
  if frame:IsShown() then
    frame:Hide()
    return
  end
  frame:ClearAllPoints()
  frame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -4, 0)
  frame:Show()
end

function MapDirectory:Build()
  wipe(self.records)
  self.maps = self.maps or {}
  wipe(self.maps)
  self.sources = self.sources or {}
  wipe(self.sources)
  local mapID = self.mapID
  if not mapID then return end
  self.sourceKeys = self.sourceKeys or {}
  wipe(self.sourceKeys)
  local seen = self.sourceKeys
  seen.all = true
  self.sources[1] = { label = "All Sources", value = "all" }
  local mapSeen = {}
  local groups = {}
  self.totalDecor = 0
  self.totalCollected = 0
  NS.Systems.Pipeline:ForEach(nil, function(record)
    if record.mapID and not mapSeen[record.mapID] then
      mapSeen[record.mapID] = true
      self.maps[#self.maps + 1] = { label = MapName(record.mapID), value = record.mapID }
    end
    if tonumber(record.mapID) == tonumber(mapID) and record.mapX and record.mapY then
      local _, _, owned = NS.Systems.Housing:GetDisplay(record)
      local includeCollected = NS.Systems.Settings:GetValue("mapOverlayIncludeCollected", false)
      if includeCollected or not owned then
      local sourceKey = record.sourceType == "vendor" and ("vendor:" .. tostring(record.sourceID)) or ("source:" .. tostring(record.sourceType or record.category))
      if not seen[sourceKey] then
        seen[sourceKey] = true
        self.sources[#self.sources + 1] = { label = SourceName(record), value = sourceKey }
      end
      local group = groups[sourceKey]
      if not group then
        group = { key = sourceKey, name = SourceName(record), zone = record.zone, records = {}, collected = 0, total = 0 }
        groups[sourceKey] = group
      end
      group.total = group.total + 1
      if owned then group.collected = group.collected + 1 end
      group.records[#group.records + 1] = record
      self.totalDecor = self.totalDecor + 1
      if owned then self.totalCollected = self.totalCollected + 1 end
      end
    end
  end)
  table.sort(self.sources, function(left, right)
    if left.value == "all" then return true end
    if right.value == "all" then return false end
    return left.label < right.label
  end)
  table.sort(self.maps, function(left, right) return left.label < right.label end)
  self.openSources = self.openSources or {}
  local orderedGroups = {}
  for _, group in pairs(groups) do orderedGroups[#orderedGroups + 1] = group end
  table.sort(orderedGroups, function(left, right) return left.name < right.name end)
  for index = 1, #orderedGroups do
    local group = orderedGroups[index]
    if not self.sourceFilter or self.sourceFilter == "all" or self.sourceFilter == group.key then
      self.records[#self.records + 1] = { header = true, sourceKey = group.key, title = group.name, zone = group.zone, total = group.total, collected = group.collected }
      if self.openSources[group.key] then
        table.sort(group.records, function(left, right) return tostring(left.title or left.decorID or "") < tostring(right.title or right.decorID or "") end)
        for recordIndex = 1, #group.records do self.records[#self.records + 1] = { record = group.records[recordIndex] } end
      end
    end
  end
end

function MapDirectory:Render()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local total = #self.records
  frame.map:SetText(MapName(self.mapID))
  local selected = "All Sources"
  for index = 1, #self.sources do
    local option = self.sources[index]
    if option.value == (self.sourceFilter or "all") then selected = option.label break end
  end
  frame.source:SetText(selected)
  frame.count:SetText(tostring(self.totalDecor or 0) .. " decor")
  frame.content:SetHeight(math.max(1, total * ROW_HEIGHT))
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  local visible = math.max(0, math.min(ROW_COUNT, total - first))
  for index = 1, visible do
    local entry = self.records[first + index]
    local row = frame.rows[index]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((first + index - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((first + index - 1) * ROW_HEIGHT))
    row.header = entry.header == true
    row.sourceKey = entry.sourceKey
    row.record = entry.record
    if row.header then
      row.icon:SetTexture(nil)
      row.check:Hide()
      row.title:SetText((self.openSources and self.openSources[entry.sourceKey] and "-  " or "+  ") .. entry.title)
      row.meta:SetText(tostring(entry.zone or "") .. "  " .. tostring(entry.collected or 0) .. " / " .. tostring(entry.total or 0))
      row.title:SetTextColor(1, 0.82, 0.2)
    else
      local record = entry.record
      local title, icon, owned = NS.Systems.Housing:GetDisplay(record)
      row.icon:SetTexture(icon)
      row.title:SetText(title)
      row.check:SetShown(owned)
      local cost = NS.Systems.Cost and NS.Systems.Cost.Format and NS.Systems.Cost:Format(record)
      local dyeLabel = NS.Systems.Housing:GetDyeableLabel(record)
      row.meta:SetText(tostring(record.sourceType or record.category or "Source") .. (dyeLabel and "  -  " .. dyeLabel or "") .. (cost and "  -  " .. cost or ""))
      row.title:SetTextColor(1, 1, 1)
    end
    row:Show()
  end
  for index = visible + 1, ROW_COUNT do
    frame.rows[index].record = nil
    frame.rows[index].header = nil
    frame.rows[index]:Hide()
  end
  self:ApplyMinimized()
end

function MapDirectory:Refresh()
  if not self.frame or not self.frame:IsShown() then return end
  self:Build()
  self:Render()
end

function MapDirectory:SetMap(mapID)
  self.mapID = tonumber(mapID) or CurrentMapID()
  self.sourceFilter = "all"
  local frame = self:Create()
  NS.UI.Controls:ResetScrollFrame(frame.scroll, false)
  self:Build()
  if frame:IsShown() then self:Render() end
end

function MapDirectory:Open(mapID, sourceFilter)
  NS.UI.Controls:CloseTransientPopups()
  local frame = self:Create()
  self:SetMap(mapID or CurrentMapID())
  if sourceFilter then
    NS.Systems.Settings:SetValue("mapOverlayMinimized", false)
    self.sourceFilter = sourceFilter
    self.openSources = self.openSources or {}
    self.openSources[sourceFilter] = true
    self:Build()
  end
  frame:Show()
  self:Render()
end

function MapDirectory:ShowOverlay()
  if NS.Systems.Settings and not NS.Systems.Settings:Get("mapOverlay") then return end
  self:Open(CurrentMapID())
  self:ApplyMinimized()
end

function MapDirectory:Hide()
  NS.UI.Controls:CloseTransientPopups()
  if self.frame then self.frame:Hide() end
end

function MapDirectory:Toggle()
  NS.UI.Controls:CloseTransientPopups()
  local frame = self:Create()
  if frame:IsShown() then
    frame:Hide()
  else
    self:Open(CurrentMapID())
  end
end

function MapDirectory:Attach()
  self:CreateLauncher()
  local map = _G.WorldMapFrame
  if self.mapHooks or not map then return end
  self.mapHooks = true
  map:HookScript("OnShow", function() MapDirectory:ShowOverlay() end)
  map:HookScript("OnHide", function()
    MapDirectory:Hide()
    if MapDirectory.options then MapDirectory.options:Hide() end
  end)
  hooksecurefunc(map, "SetMapID", function()
    if MapDirectory.frame and MapDirectory.frame:IsShown() then MapDirectory:ShowOverlay() end
  end)
  if map:IsShown() then self:ShowOverlay() end
end
