local _, NS = ...

local MapDirectory = NS.UI.MapDirectory
local Settings = NS.Systems.Settings
local Controls = NS.UI.Controls

local C = {
  bg = Controls.colors.background,
  header = Controls.colors.header,
  panel = Controls.colors.panel,
  row = Controls.colors.row,
  hover = Controls.colors.hover,
  border = Controls.colors.border,
  accent = Controls.colors.accent,
  bright = Controls.colors.text,
  text = Controls.colors.text,
  muted = Controls.colors.muted,
}

local function Backdrop(frame, background, border)
  Controls:Backdrop(frame, background or C.panel, border or C.border)
end

local function TextColor(text, color)
  Controls:TextColor(text, color)
end

local function CurrentMapID()
  if _G.WorldMapFrame and _G.WorldMapFrame.GetMapID then
    local mapID = _G.WorldMapFrame:GetMapID()
    if mapID then return mapID end
  end
  return _G.C_Map and _G.C_Map.GetBestMapForUnit and _G.C_Map.GetBestMapForUnit("player")
end

local function MapName(mapID)
  local info = _G.C_Map and _G.C_Map.GetMapInfo and _G.C_Map.GetMapInfo(mapID)
  return info and info.name or "Current Map"
end

local function SourceName(record)
  if record.sourceType == "vendor" and record.sourceID then
    return NS.Systems.NPCNames:Get(record.sourceID) or ("Vendor #" .. tostring(record.sourceID))
  end
  return tostring(record.sourceType or record.category or "Other sources")
end

local function SourceKey(record)
  if record.sourceType == "vendor" then return "vendor:" .. tostring(record.sourceID) end
  return "source:" .. tostring(record.sourceType or record.category)
end

local function Preview(record)
  local itemID = record and (record.itemID or record.id)
  if itemID and _G.DressUpItemLink and pcall(_G.DressUpItemLink, "item:" .. tostring(itemID)) then return end
  NS.UI.Inspector:Show(record)
end

function MapDirectory:Build()
  NS.Systems.Diagnostics:Mark("MapDirectory:Build")
  wipe(self.records)
  self.openSources = self.openSources or {}
  self.totalDecor = 0
  self.totalCollected = 0
  self.vendorCount = 0
  local groups = {}
  local ordered = {}
  local includeCollected = Settings:GetValue("mapOverlayIncludeCollected", false)
  NS.Systems.Pipeline:ForEach(nil, function(record)
    if tonumber(record.mapID) ~= tonumber(self.mapID) or not record.mapX or not record.mapY then return end
    local owned = NS.Systems.Collection:IsOwned(record)
    local key = SourceKey(record)
    local group = groups[key]
    if not group then
      group = { key = key, name = SourceName(record), zone = record.zone, records = {}, total = 0, collected = 0 }
      groups[key] = group
      ordered[#ordered + 1] = group
      self.vendorCount = self.vendorCount + 1
    end
    group.total = group.total + 1
    self.totalDecor = self.totalDecor + 1
    if owned then
      group.collected = group.collected + 1
      self.totalCollected = self.totalCollected + 1
    end
    if includeCollected or not owned then group.records[#group.records + 1] = record end
  end)
  table.sort(ordered, function(left, right) return left.name < right.name end)
  for index = 1, #ordered do
    local group = ordered[index]
    if #group.records > 0 then
      self.records[#self.records + 1] = { header = true, sourceKey = group.key, title = group.name, zone = group.zone, total = group.total, collected = group.collected }
      if self.openSources[group.key] then
        table.sort(group.records, function(left, right) return tostring(left.title or left.decorID or "") < tostring(right.title or right.decorID or "") end)
        for recordIndex = 1, #group.records do self.records[#self.records + 1] = { record = group.records[recordIndex] } end
      end
    end
  end
end

function MapDirectory:CreateRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(34)
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  Backdrop(row, C.row, C.border)
  row.arrow = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.arrow:SetPoint("LEFT", 6, 0)
  TextColor(row.arrow, C.accent)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(26, 26)
  row.icon:SetPoint("LEFT", 6, 0)
  row.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
  row.check = row:CreateTexture(nil, "OVERLAY")
  row.check:SetSize(14, 14)
  row.check:SetPoint("TOP", row.icon, "TOP", 0, 2)
  row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
  row.title = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -2)
  row.title:SetPoint("RIGHT", -48, 0)
  row.title:SetJustifyH("LEFT")
  row.title:SetWordWrap(false)
  row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.meta:SetPoint("TOPLEFT", row.title, "BOTTOMLEFT", 0, -2)
  row.meta:SetPoint("RIGHT", -48, 0)
  row.meta:SetJustifyH("LEFT")
  row.meta:SetWordWrap(false)
  TextColor(row.meta, C.muted)
  row.owned = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.owned:SetPoint("RIGHT", -7, 0)
  TextColor(row.owned, C.muted)
  row:SetScript("OnClick", function(self, button)
    if self.header then
      MapDirectory.openSources[self.sourceKey] = not MapDirectory.openSources[self.sourceKey]
      MapDirectory:Build()
      MapDirectory:Render()
      return
    end
    local record = self.record
    if not record or NS.UI.ItemInteractions:HandleClick(record) then return end
    if button == "RightButton" then NS.Systems.Navigation:Open(record) else Preview(record) end
  end)
  row:SetScript("OnEnter", function(self)
    self:SetBackdropColor(C.hover[1], C.hover[2], C.hover[3], C.hover[4])
    if self.record then NS.UI.ItemTooltip:Show(self, self.record, "map") end
  end)
  row:SetScript("OnLeave", function(self)
    self:SetBackdropColor(C.row[1], C.row[2], C.row[3], C.row[4])
    NS.UI.ItemTooltip:Hide()
  end)
  return row
end

function MapDirectory:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorMapDirectory", UIParent, "BackdropTemplate")
  frame:SetSize(300, 330)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(210)
  frame:SetClampedToScreen(false)
  frame:EnableMouse(true)
  Backdrop(frame, { 0.02, 0.02, 0.025, 0.86 }, C.border)
  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.title:SetPoint("TOPLEFT", 10, -8)
  frame.title:SetPoint("TOPRIGHT", -30, -8)
  frame.title:SetJustifyH("LEFT")
  TextColor(frame.title, C.accent)
  frame.toggle = CreateFrame("Button", nil, frame)
  frame.toggle:SetSize(18, 18)
  frame.toggle:SetPoint("TOPRIGHT", -5, -5)
  frame.toggle.text = frame.toggle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.toggle.text:SetAllPoints()
  frame.toggle:SetScript("OnClick", function()
    Settings:SetValue("mapOverlayMinimized", not Settings:GetValue("mapOverlayMinimized", true))
    MapDirectory:ApplyMinimized()
    MapDirectory:Position()
  end)
  frame.meta = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.meta:SetPoint("TOPLEFT", 10, -31)
  frame.meta:SetPoint("TOPRIGHT", -10, -31)
  frame.meta:SetJustifyH("LEFT")
  TextColor(frame.meta, C.muted)
  frame.divider = frame:CreateTexture(nil, "ARTWORK")
  frame.divider:SetPoint("TOPLEFT", 10, -53)
  frame.divider:SetPoint("TOPRIGHT", -10, -53)
  frame.divider:SetHeight(1)
  frame.divider:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 0.35)
  local scroll = Controls:CreateScrollFrame(frame)
  scroll:SetPoint("TOPLEFT", 8, -60)
  scroll:SetPoint("BOTTOMRIGHT", -24, 8)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(268, 1)
  Controls:ConfigureScrollFrame(scroll, content, { step = 36, onScroll = function() MapDirectory:Render() end })
  frame.scroll = scroll
  frame.content = content
  frame.rows = {}
  for index = 1, 12 do
    local row = self:CreateRow(content)
    Controls:ForwardScrollWheel(row, scroll)
    row:Hide()
    frame.rows[index] = row
  end
  frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.empty:SetPoint("CENTER", scroll)
  frame.empty:SetText("No HomeDecor decor on this map.")
  TextColor(frame.empty, C.muted)
  frame:SetScript("OnShow", function() MapDirectory:Refresh() end)
  frame:Hide()
  self.frame = frame
  return frame
end

function MapDirectory:Position()
  if not self.frame then return end
  local anchor = (_G.WorldMapFrame and _G.WorldMapFrame.ScrollContainer) or _G.WorldMapFrame or UIParent
  local groupID = self.mapID and _G.C_Map and _G.C_Map.GetMapGroupID and _G.C_Map.GetMapGroupID(self.mapID)
  self.frame:ClearAllPoints()
  self.frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 7, groupID and -31 or -6)
end

function MapDirectory:ApplyMinimized()
  local frame = self.frame
  if not frame then return end
  local minimized = Settings:GetValue("mapOverlayMinimized", true) == true
  frame:SetSize(minimized and 190 or 300, minimized and 24 or 330)
  frame.meta:SetShown(not minimized)
  frame.divider:SetShown(not minimized)
  frame.scroll:SetShown(not minimized)
  frame.empty:SetShown(not minimized and #self.records == 0)
  frame.toggle.text:SetText(minimized and "|cff888888+|r" or "|cff888888-|r")
  frame.toggle:SetScript("OnEnter", function() frame.toggle.text:SetText(minimized and "|cffff7d0a+|r" or "|cffff7d0a-|r") end)
  frame.toggle:SetScript("OnLeave", function() frame.toggle.text:SetText(minimized and "|cff888888+|r" or "|cff888888-|r") end)
end

function MapDirectory:Render()
  NS.Systems.Diagnostics:Mark("MapDirectory:Render")
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local total = #self.records
  frame.title:SetText("|TInterface\\AddOns\\HomeDecor\\Media\\Icon:13:13:0:0|t  " .. tostring(self.totalDecor or 0) .. " decor in this zone")
  frame.meta:SetText(tostring(self.vendorCount or 0) .. " Vendors  |  " .. tostring(self.totalCollected or 0) .. " collected")
  local contentHeight = math.max(1, total * 36)
  if frame._contentHeight ~= contentHeight then
    frame._contentHeight = contentHeight
    frame.content:SetHeight(contentHeight)
  end
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / 36))
  local visible = math.max(0, math.min(#frame.rows, total - first))
  for index = 1, visible do
    local entry = self.records[first + index]
    local row = frame.rows[index]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((first + index - 1) * 36))
    row:SetPoint("TOPRIGHT", 0, -((first + index - 1) * 36))
    row.header = entry.header == true
    row.sourceKey = entry.sourceKey
    row.record = entry.record
    if row.header then
      row.arrow:Show()
      row.arrow:SetText(self.openSources[entry.sourceKey] and "-" or "+")
      row.icon:Hide()
      row.check:Hide()
      row.title:ClearAllPoints()
      row.title:SetPoint("TOPLEFT", 18, -4)
      row.title:SetPoint("RIGHT", -58, 0)
      row.title:SetText(entry.title)
      TextColor(row.title, C.bright)
      row.meta:SetText(tostring(entry.zone or MapName(self.mapID)))
      row.owned:SetText(tostring(entry.collected or 0) .. " / " .. tostring(entry.total or 0))
    else
      local record = entry.record
      local title, icon, owned = NS.Systems.Housing:GetCatalogDisplay(record)
      row.arrow:Hide()
      row.icon:Show()
      row.icon:SetTexture(icon)
      row.check:SetShown(owned)
      row.title:ClearAllPoints()
      row.title:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -2)
      row.title:SetPoint("RIGHT", -48, 0)
      row.title:SetText(title)
      TextColor(row.title, owned and C.muted or C.text)
      row.meta:SetText(SourceName(record))
      row.owned:SetText(owned and "1" or "")
    end
    row:Show()
  end
  for index = visible + 1, #frame.rows do frame.rows[index]:Hide() end
  frame.empty:SetShown(total == 0)
  self:ApplyMinimized()
  self:Position()
end

function MapDirectory:CreateOptions()
  if self.options then return self.options end
  local frame = CreateFrame("Frame", "HomeDecorMapOptions", UIParent, "BackdropTemplate")
  frame:SetWidth(260)
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(220)
  frame:SetClampedToScreen(true)
  Backdrop(frame, C.bg, C.border)
  local y = 0
  local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  titleBar:SetPoint("TOPLEFT", 1, -1)
  titleBar:SetPoint("TOPRIGHT", -1, -1)
  titleBar:SetHeight(28)
  Controls:MakeMovable(frame, titleBar, nil, function()
    local point, _, relativePoint, x, positionY = frame:GetPoint()
    Settings:SetValue("mapOptionsPosition", { point = point, relativePoint = relativePoint, x = x, y = positionY })
  end)
  Backdrop(titleBar, C.header, C.border)
  local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  title:SetPoint("LEFT", 8, 0)
  title:SetText("Home|cffff7d0aDecor|r")
  local close = CreateFrame("Button", nil, titleBar)
  close:SetSize(20, 20)
  close:SetPoint("RIGHT", -4, 0)
  close.text = close:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  close.text:SetAllPoints()
  close.text:SetText("|cff888888x|r")
  close:SetScript("OnClick", function() frame:Hide() end)
  close:SetScript("OnEnter", function() close.text:SetText("|cffff7d0ax|r") end)
  close:SetScript("OnLeave", function() close.text:SetText("|cff888888x|r") end)
  y = 31
  frame.checks = {}
  local function Section(label)
    local bar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    bar:SetPoint("TOPLEFT", 1, -(y + 1))
    bar:SetPoint("TOPRIGHT", -1, -(y + 1))
    bar:SetHeight(18)
    Backdrop(bar, C.header, C.border)
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", 8, 0)
    text:SetText(label:upper())
    TextColor(text, C.accent)
    y = y + 22
  end
  local function Check(key, label, default, onChanged)
    local row = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    row:SetPoint("TOPLEFT", 1, -y)
    row:SetPoint("TOPRIGHT", -1, -y)
    row:SetHeight(22)
    Backdrop(row, C.row, C.border)
    local check = Controls:CreateCheckButton(row, label)
    check:SetSize(18, 18)
    check:SetPoint("LEFT", 6, 0)
    TextColor(check.label, C.text)
    check:SetScript("OnClick", function(self)
      Settings:SetValue(key, self:GetChecked() == true)
      onChanged(self:GetChecked() == true)
    end)
    check.Sync = function(self) self:SetChecked(Settings:GetValue(key, default)) end
    frame.checks[#frame.checks + 1] = check
    y = y + 26
  end
  Section("Decor Overlay")
  Check("mapOverlay", "Show zone decor overlay", true, function(value) if value then MapDirectory:ShowOverlay() else MapDirectory:Hide() end end)
  Check("mapOverlayIncludeCollected", "Include collected decor", false, function() MapDirectory:Refresh() end)
  y = y + 2
  Section("Map Pins")
  Check("mapPins", "Show world map pins", true, function() NS.Systems.MapPins:RequestRefresh() end)
  Check("mapMinimapPins", "Show minimap pins", true, function() NS.Systems.MapPins:RequestRefresh() end)
  y = y + 2
  Section("Pin Appearance")
  local styleRow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  styleRow:SetPoint("TOPLEFT", 1, -y)
  styleRow:SetPoint("TOPRIGHT", -1, -y)
  styleRow:SetHeight(22)
  Backdrop(styleRow, C.row, C.border)
  local styleLabel = styleRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  styleLabel:SetPoint("LEFT", 10, 0)
  styleLabel:SetText("Style")
  TextColor(styleLabel, C.muted)
  frame.styleButtons = {}
  local styles = { { "house", "House" }, { "dot", "Dot" } }
  for index = 1, #styles do
    local entry = styles[index]
    local button = CreateFrame("Button", nil, styleRow, "BackdropTemplate")
    button:SetSize(76, 18)
    button:SetPoint("RIGHT", -(6 + (#styles - index) * 78), 0)
    Backdrop(button, C.panel, C.border)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.text:SetAllPoints()
    button.text:SetText(entry[2])
    button:SetScript("OnClick", function()
      Settings:SetValue("mapPinStyle", entry[1])
      frame:Sync()
      NS.Systems.MapPins:RequestRefresh()
    end)
    frame.styleButtons[index] = button
  end
  y = y + 26
  local colorRow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  colorRow:SetPoint("TOPLEFT", 1, -y)
  colorRow:SetPoint("TOPRIGHT", -1, -y)
  colorRow:SetHeight(22)
  Backdrop(colorRow, C.row, C.border)
  local colorLabel = colorRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  colorLabel:SetPoint("LEFT", 10, 0)
  colorLabel:SetText("Color")
  TextColor(colorLabel, C.muted)
  frame.swatchButton = CreateFrame("Button", nil, colorRow, "BackdropTemplate")
  frame.swatchButton:SetSize(18, 18)
  frame.swatchButton:SetPoint("RIGHT", -42, 0)
  Backdrop(frame.swatchButton, { 0, 0, 0, 0.7 }, C.border)
  frame.swatch = frame.swatchButton:CreateTexture(nil, "ARTWORK")
  frame.swatch:SetPoint("TOPLEFT", 2, -2)
  frame.swatch:SetPoint("BOTTOMRIGHT", -2, 2)
  frame.reset = CreateFrame("Button", nil, colorRow, "BackdropTemplate")
  frame.reset:SetSize(34, 16)
  frame.reset:SetPoint("LEFT", frame.swatchButton, "RIGHT", 3, 0)
  Backdrop(frame.reset, C.panel, C.border)
  frame.reset.text = frame.reset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.reset.text:SetAllPoints()
  frame.reset.text:SetText("Reset")
  TextColor(frame.reset.text, C.muted)
  frame.reset:SetScript("OnClick", function()
    Settings:SetValue("mapPinColor", { r = 1, g = 1, b = 1 })
    frame:Sync()
    NS.Systems.MapPins:RequestRefresh()
  end)
  frame.swatchButton:SetScript("OnClick", function()
    local value = Settings:GetValue("mapPinColor", { r = 1, g = 1, b = 1 })
    _G.ColorPickerFrame:SetupColorPickerAndShow({
      r = value.r or 1, g = value.g or 1, b = value.b or 1, hasOpacity = false,
      swatchFunc = function()
        local r, g, b = _G.ColorPickerFrame:GetColorRGB()
        Settings:SetValue("mapPinColor", { r = r, g = g, b = b })
        frame.swatch:SetColorTexture(r, g, b)
        NS.Systems.MapPins:RequestRefresh()
      end,
    })
  end)
  y = y + 26
  local sizeRow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  sizeRow:SetPoint("TOPLEFT", 1, -y)
  sizeRow:SetPoint("TOPRIGHT", -1, -y)
  sizeRow:SetHeight(42)
  Backdrop(sizeRow, C.row, C.border)
  local sizeLabel = sizeRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  sizeLabel:SetPoint("TOPLEFT", 10, -6)
  sizeLabel:SetText("Size")
  TextColor(sizeLabel, C.muted)
  frame.sizeValue = sizeRow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.sizeValue:SetPoint("LEFT", sizeLabel, "RIGHT", 6, 0)
  TextColor(frame.sizeValue, C.accent)
  frame.slider = Controls:CreateSlider(sizeRow, {
    height = 14,
    minimum = 0.5,
    maximum = 2,
    step = 0.1,
    background = C.panel,
    border = C.border,
    accent = C.accent,
    onChanged = function(_, value)
      value = math.floor(value * 10 + 0.5) / 10
      Settings:SetValue("mapPinSize", value)
      frame.sizeValue:SetText(string.format("%.1fx", value))
      NS.Systems.MapPins:RequestRefresh()
    end,
  })
  frame.slider:SetPoint("BOTTOMLEFT", 10, 7)
  frame.slider:SetPoint("BOTTOMRIGHT", -10, 7)
  y = y + 48
  Section("Tooltip Position")
  local anchorRow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  anchorRow:SetPoint("TOPLEFT", 1, -y)
  anchorRow:SetPoint("TOPRIGHT", -1, -y)
  anchorRow:SetHeight(22)
  Backdrop(anchorRow, C.row, C.border)
  local anchors = { { "ANCHOR_LEFT", "Left" }, { "ANCHOR_RIGHT", "Right" }, { "ANCHOR_MIDDLE", "Middle" }, { "ANCHOR_BOTTOM", "Bottom" }, { "ANCHOR_CURSOR", "Cursor" } }
  frame.anchorButtons = {}
  for index = 1, #anchors do
    local entry = anchors[index]
    local button = CreateFrame("Button", nil, anchorRow, "BackdropTemplate")
    button:SetSize(48, 18)
    button:SetPoint("LEFT", 5 + (index - 1) * 50, 0)
    Backdrop(button, C.panel, C.border)
    button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    button.text:SetAllPoints()
    button.text:SetText(entry[2])
    button:SetScript("OnClick", function()
      Settings:SetValue("mapTooltipAnchor", entry[1])
      frame:Sync()
    end)
    frame.anchorButtons[index] = button
  end
  y = y + 28
  frame:SetHeight(y)
  function frame:Sync()
    for index = 1, #self.checks do self.checks[index]:Sync() end
    local style = Settings:GetValue("mapPinStyle", "house")
    for index = 1, #self.styleButtons do
      local active = styles[index][1] == style
      Backdrop(self.styleButtons[index], active and C.hover or C.panel, active and C.accent or C.border)
      TextColor(self.styleButtons[index].text, active and C.bright or C.muted)
    end
    local color = Settings:GetValue("mapPinColor", { r = 1, g = 1, b = 1 })
    self.swatch:SetColorTexture(color.r or 1, color.g or 1, color.b or 1)
    local size = tonumber(Settings:GetValue("mapPinSize", 1)) or 1
    self.slider:SetValueSilently(size)
    self.sizeValue:SetText(string.format("%.1fx", size))
    local anchor = Settings:GetValue("mapTooltipAnchor", "ANCHOR_RIGHT")
    for index = 1, #self.anchorButtons do
      local active = anchors[index][1] == anchor
      Backdrop(self.anchorButtons[index], active and C.hover or C.panel, active and C.accent or C.border)
      TextColor(self.anchorButtons[index].text, active and C.bright or C.muted)
    end
  end
  frame:SetScript("OnShow", function(self) self:Sync() end)
  frame:Hide()
  self.options = frame
  return frame
end

function MapDirectory:CreateLauncher()
  if self.launcher then return self.launcher end
  if not _G.WorldMapFrame then return end
  local library = _G.LibStub and _G.LibStub("Krowi_WorldMapButtons-1.4", true)
  if not library then return end
  local button = library:Add("HomeDecorWorldMapButtonTemplate", "Button")
  self.launcher = button
  return button
end

function MapDirectory:ToggleOptions(anchor)
  local frame = self:CreateOptions()
  if frame:IsShown() then frame:Hide() return end
  frame:ClearAllPoints()
  local position = Settings:GetValue("mapOptionsPosition")
  if type(position) == "table" and position.point and position.x and position.y then
    frame:SetPoint(position.point, UIParent, position.relativePoint or position.point, position.x, position.y)
  else
    frame:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
  end
  frame:Show()
  frame:Raise()
end

function MapDirectory:SetMap(mapID)
  self.mapID = tonumber(mapID) or CurrentMapID()
  local frame = self:Create()
  Controls:ResetScrollFrame(frame.scroll, false)
  self:Build()
  if frame:IsShown() then self:Render() end
end

function MapDirectory:Refresh()
  if not self.frame or not self.frame:IsShown() or self._showing then return end
  if self._rebuildQueued then return end
  self._rebuildQueued = true
  local function rebuild()
    MapDirectory._rebuildQueued = nil
    if not MapDirectory.frame or not MapDirectory.frame:IsShown() then return end
    MapDirectory:Build()
    MapDirectory:Render()
  end
  if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0, rebuild) else rebuild() end
end

function MapDirectory:Open(mapID, sourceFilter)
  local frame = self:Create()
  if sourceFilter then
    Settings:SetValue("mapOverlayMinimized", false)
    self.openSources[sourceFilter] = true
  end
  self:SetMap(mapID or CurrentMapID())
  self._showing = true
  frame:Show()
  self._showing = nil
  self:Render()
end

function MapDirectory:ShowOverlay()
  if not Settings:Get("mapOverlay") then return end
  self:Open(CurrentMapID())
end

function MapDirectory:QueueOverlay()
  if self._overlayQueued then return end
  self._overlayQueued = true
  local function show()
    MapDirectory._overlayQueued = nil
    local map = _G.WorldMapFrame
    if map and map:IsShown() then MapDirectory:ShowOverlay() end
  end
  if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0, show) else show() end
end

function MapDirectory:Attach()
  self:CreateLauncher()
  local map = _G.WorldMapFrame
  if self.mapHooks or not map then return end
  self.mapHooks = true
  map:HookScript("OnShow", function()
    MapDirectory._observedMapID = map:GetMapID()
    MapDirectory:QueueOverlay()
  end)
  map:HookScript("OnHide", function()
    MapDirectory:Hide()
    if MapDirectory.options then MapDirectory.options:Hide() end
  end)
  hooksecurefunc(map, "SetMapID", function()
    local mapID = map:GetMapID()
    if MapDirectory._observedMapID == mapID then return end
    MapDirectory._observedMapID = mapID
    if MapDirectory.frame and MapDirectory.frame:IsShown() then MapDirectory:QueueOverlay() end
  end)
  if map:IsShown() then
    self._observedMapID = map:GetMapID()
    self:QueueOverlay()
  end
end

HomeDecorWorldMapButtonMixin = {}

function HomeDecorWorldMapButtonMixin:OnLoad() end

function HomeDecorWorldMapButtonMixin:Refresh()
  self:Show()
end

function HomeDecorWorldMapButtonMixin:OnClick()
  MapDirectory:ToggleOptions(self)
end

function HomeDecorWorldMapButtonMixin:OnMouseDown()
  self.Icon:ClearAllPoints()
  self.Icon:SetPoint("TOPLEFT", 8, -8)
end

function HomeDecorWorldMapButtonMixin:OnMouseUp()
  self.Icon:ClearAllPoints()
  self.Icon:SetPoint("TOPLEFT", 6, -6)
end

function HomeDecorWorldMapButtonMixin:OnEnter()
  GameTooltip:SetOwner(self, "ANCHOR_LEFT")
  GameTooltip:AddLine("Home|cffff7d0aDecor|r")
  GameTooltip:AddLine("Map overlay and pin settings", 1, 1, 1)
  GameTooltip:Show()
end

function HomeDecorWorldMapButtonMixin:OnLeave()
  GameTooltip:Hide()
end

function HomeDecorWorldMapButtonMixin:OnHide()
  if MapDirectory.options then MapDirectory.options:Hide() end
end
