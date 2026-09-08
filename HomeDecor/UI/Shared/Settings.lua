local _, NS = ...

NS.UI = NS.UI or {}
local AddonSettings = {}
NS.UI.Settings = AddonSettings

local Controls = NS.UI.Controls

local function Profile()
  return NS.Systems.Database:GetProfile()
end

local function Value(key, default)
  return NS.Systems.Settings:GetValue(key, default)
end

local function SetValue(key, value)
  NS.Systems.Settings:SetValue(key, value)
end

local function RefreshCatalog()
  if NS.UI.CatalogView and NS.UI.CatalogView.frame then NS.UI.CatalogView:Refresh(true) end
end

local function RefreshPins()
  if NS.Systems.MapPins then NS.Systems.MapPins:RequestRefresh() end
end

function AddonSettings:SetMinimapShown(shown)
  local profile = Profile()
  if not profile then return end
  profile.minimap = profile.minimap or { hide = false }
  profile.minimap.hide = shown ~= true
  if NS.UI.MinimapLauncher then NS.UI.MinimapLauncher:SetShown(shown) end
end

function AddonSettings:Apply(key)
  if key == "mapPins" or key == "mapMinimapPins" or key == "mapPinStyle" or key == "mapPinSize" or key == "mapPinColor" or key == "mapTooltipAnchor" then
    RefreshPins()
  elseif key == "vendorAssistant" then
    if not Value(key, true) then NS.UI.VendorAssistant:Hide() else NS.UI.VendorAssistant:ShowForCurrentVendor() end
  elseif key == "vendorMarkers" then
    NS.UI.VendorMarkers:Refresh()
  elseif key == "quickBar" or key == "editorFeatures" or key == "editorHints" or key == "editorClock" or key == "editorClockDisplay" or key == "editorClockSource" or key == "editorClockFormat" then
    NS.UI.QuickBar:SyncEditor()
  elseif key == "hideCollected" or key == "openCompact" then
    RefreshCatalog()
  end
end

local function Text(parent, template, value, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  text:SetText(value or "")
  Controls:TextColor(text, role or "text")
  return text
end

local function PopupButton(parent, label, width)
  return Controls:CreateButton(parent, label, width or 120, 24)
end

local function PopupCheck(parent, label, onClick)
  local check = Controls:CreateCheckButton(parent, label)
  check:SetSize(24, 24)
  Controls:TextColor(check.label, "text")
  check:SetScript("OnClick", function(self) onClick(self:GetChecked() == true) end)
  return check
end

local function PopupSlider(parent, label, minimum, maximum, step, display, changed)
  local slider
  slider = Controls:CreateSlider(parent, {
    width = 188,
    height = 10,
    minimum = minimum,
    maximum = maximum,
    step = step,
    onDisplay = function(_, value) if slider and slider.value then slider.value:SetText(display(value)) end end,
    onChanged = function(_, value) changed(value) end,
  })
  slider.label = Text(parent, "GameFontHighlight", label, "text")
  slider.label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 7)
  slider.value = Text(parent, "GameFontNormalSmall", "", "accent")
  slider.value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 7)
  return slider
end

local function PopupSwatch(parent, label, key)
  local row = CreateFrame("Frame", nil, parent)
  row:SetSize(224, 28)
  row.label = Text(row, "GameFontHighlight", label, "text")
  row.label:SetPoint("LEFT")
  row.button = CreateFrame("Button", nil, row, "BackdropTemplate")
  row.button:SetSize(27, 22)
  row.button:SetPoint("RIGHT")
  Controls:Backdrop(row.button, Controls.colors.panel, Controls.colors.border)
  row.button.fill = row.button:CreateTexture(nil, "ARTWORK")
  row.button.fill:SetPoint("TOPLEFT", 3, -3)
  row.button.fill:SetPoint("BOTTOMRIGHT", -3, 3)
  row.key = key
  row.button:SetScript("OnClick", function()
    if not _G.ColorPickerFrame then return end
    local current = Controls.colors[key]
    local previous = { r = current[1], g = current[2], b = current[3] }
    local info = { r = previous.r, g = previous.g, b = previous.b, hasOpacity = false }
    info.swatchFunc = function()
      local r, g, b = _G.ColorPickerFrame:GetColorRGB()
      Controls:SetAppearanceColor(key, r, g, b)
      AddonSettings:Sync()
    end
    info.cancelFunc = function()
      Controls:SetAppearanceColor(key, previous.r, previous.g, previous.b)
      AddonSettings:Sync()
    end
    _G.ColorPickerFrame:SetupColorPickerAndShow(info)
    _G.ColorPickerFrame:SetFrameStrata("TOOLTIP")
  end)
  return row
end

function AddonSettings:Sync()
  local frame = self.frame
  if not frame then return end
  local profile = Profile()
  if not profile then return end
  frame.controls.showMinimap:SetChecked(not (profile.minimap and profile.minimap.hide))
  frame.controls.miniPins:SetChecked(Value("mapMinimapPins", true))
  frame.controls.worldPins:SetChecked(Value("mapPins", true))
  frame.controls.hideCollected:SetChecked(Value("hideCollected", false))
  frame.controls.favorites:SetChecked(Value("zoneFavoriteAlerts", true))
  frame.controls.compact:SetChecked(Value("openCompact", false))
  frame.syncing = true
  local catalog = NS.UI.CatalogView and NS.UI.CatalogView.frame
  local scale = catalog and catalog.GetWindowScaleDisplay and catalog:GetWindowScaleDisplay() or math.floor((tonumber(profile.ui.scale) or 0.87) * 100 + 0.5)
  frame.controls.size:SetValueSilently(scale)
  frame.controls.fontScale:SetValueSilently(tonumber(profile.ui.appearance and profile.ui.appearance.fontScale) or 1)
  frame.syncing = nil
  frame.controls.size.value:SetText(tostring(math.floor(scale + 0.5)))
  frame.controls.fontScale.value:SetText(string.format("%d%%", (tonumber(profile.ui.appearance and profile.ui.appearance.fontScale) or 1) * 100))
  for _, swatch in ipairs(frame.controls.swatches) do
    local color = Controls.colors[swatch.key]
    swatch.button.fill:SetColorTexture(color[1], color[2], color[3], 1)
  end
end

function AddonSettings:Create()
  if self.frame then return self.frame end
  local panel = CreateFrame("Frame", "HomeDecorSettings", UIParent, "BackdropTemplate")
  panel:SetSize(552, 626)
  panel:SetPoint("CENTER")
  panel:SetFrameStrata("FULLSCREEN_DIALOG")
  panel:SetFrameLevel(300)
  panel:SetClampedToScreen(true)
  panel:EnableMouse(true)
  Controls:Backdrop(panel, Controls.colors.background, Controls.colors.border)
  panel.controls = { swatches = {} }

  local header = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(44)
  Controls:Backdrop(header, Controls.colors.header, Controls.colors.border)
  local title = Text(header, "GameFontNormalLarge", "HomeDecor Settings", "accent")
  title:SetPoint("LEFT", 14, 6)
  local subtitle = Text(header, "GameFontHighlightSmall", "Quick controls and appearance", "muted")
  subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
  local close = Controls:CreateCloseButton(header, function() panel:Hide() end, 24, 24)
  close:SetPoint("RIGHT", -10, 0)

  local appearanceTitle = Text(panel, "GameFontNormal", "Appearance", "accent")
  appearanceTitle:SetPoint("TOPLEFT", 20, -68)
  local size = PopupSlider(panel, "Window Size", 0, 200, 5, function(value) return tostring(math.floor(value + 0.5)) end, function(value)
    if panel.syncing then return end
    local catalog = NS.UI.CatalogView:Create()
    if catalog.ApplyWindowScale then catalog.ApplyWindowScale(value) end
  end)
  panel.controls.size = size
  size:SetPoint("TOPLEFT", 22, -112)
  local fontScale = PopupSlider(panel, "Font Size", 0.8, 1.35, 0.05, function(value) return string.format("%d%%", value * 100) end, function(value)
    if panel.syncing then return end
    local profile = Profile()
    profile.ui.appearance.fontScale = math.floor(value * 100 + 0.5) / 100
    Controls:ApplyAppearance()
  end)
  panel.controls.fontScale = fontScale
  fontScale:SetPoint("TOPLEFT", 300, -112)
  local fontLabel = Text(panel, "GameFontHighlight", "Font", "text")
  fontLabel:SetPoint("TOPLEFT", 22, -153)
  local font = PopupButton(panel, "Game Default", 190)
  font:SetPoint("TOPLEFT", 22, -176)
  panel.controls.font = font
  local reset = PopupButton(panel, "Reset Appearance", 190)
  reset:SetPoint("TOPLEFT", 22, -211)
  reset:SetScript("OnClick", function() Controls:ResetAppearance() AddonSettings:Sync() end)

  local swatches = {
    { "Accent Color", "accent" },
    { "Text Color", "text" },
    { "Highlight Color", "highlight" },
    { "Border Color", "border" },
    { "Background Color", "background" },
    { "Panel Color", "panel" },
  }
  for index, entry in ipairs(swatches) do
    local swatch = PopupSwatch(panel, entry[1], entry[2])
    swatch:SetPoint("TOPLEFT", 300, -151 - ((index - 1) * 31))
    panel.controls.swatches[#panel.controls.swatches + 1] = swatch
  end

  local divider = panel:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1, 1, 1, 0.12)
  divider:SetHeight(1)
  divider:SetPoint("TOPLEFT", 20, -353)
  divider:SetPoint("TOPRIGHT", -20, -353)
  local quickTitle = Text(panel, "GameFontNormal", "Quick Options", "accent")
  quickTitle:SetPoint("TOPLEFT", 20, -372)
  local showMinimap = PopupCheck(panel, "Show minimap button", function(value) AddonSettings:SetMinimapShown(value) end)
  panel.controls.showMinimap = showMinimap
  showMinimap:SetPoint("TOPLEFT", 20, -402)
  local miniPins = PopupCheck(panel, "Minimap decor pins", function(value) SetValue("mapMinimapPins", value) AddonSettings:Apply("mapMinimapPins") end)
  panel.controls.miniPins = miniPins
  miniPins:SetPoint("TOPLEFT", 20, -434)
  local worldPins = PopupCheck(panel, "World map decor pins", function(value) SetValue("mapPins", value) AddonSettings:Apply("mapPins") end)
  panel.controls.worldPins = worldPins
  worldPins:SetPoint("TOPLEFT", 20, -466)
  local hideCollected = PopupCheck(panel, "Hide collected decor", function(value) SetValue("hideCollected", value) AddonSettings:Apply("hideCollected") end)
  panel.controls.hideCollected = hideCollected
  hideCollected:SetPoint("TOPLEFT", 292, -402)
  local favorites = PopupCheck(panel, "Zone favorite alerts", function(value) SetValue("zoneFavoriteAlerts", value) end)
  panel.controls.favorites = favorites
  favorites:SetPoint("TOPLEFT", 292, -434)
  local compact = PopupCheck(panel, "Open in compact mode", function(value) SetValue("openCompact", value) end)
  panel.controls.compact = compact
  compact:SetPoint("TOPLEFT", 292, -466)
  local note = Text(panel, "GameFontHighlightSmall", "More controls for vendors, gathering, map pins and edit mode are available in Full Options.", "muted")
  note:SetWidth(510)
  note:SetJustifyH("LEFT")
  note:SetWordWrap(true)
  note:SetPoint("TOPLEFT", 20, -514)
  local full = PopupButton(panel, "Full Options", 244)
  full:SetPoint("BOTTOMLEFT", 20, 20)
  full:SetScript("OnClick", function() panel:Hide() AddonSettings:OpenOptions() end)
  local done = PopupButton(panel, "Done", 244)
  done:SetPoint("BOTTOMRIGHT", -20, 20)
  done:SetScript("OnClick", function() panel:Hide() end)
  if UISpecialFrames then table.insert(UISpecialFrames, "HomeDecorSettings") end
  local owner = NS.UI.CatalogView and NS.UI.CatalogView.frame
  if owner then owner:HookScript("OnHide", function() panel:Hide() end) end
  panel:SetScript("OnShow", function() AddonSettings:Sync() end)
  panel:Hide()
  self.frame = panel
  return panel
end

function AddonSettings:Toggle()
  local frame = self:Create()
  Controls:ToggleFrame(frame, function() self:Sync() end)
end

local function OptionTitle(panel, title, subtitle)
  local heading = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  heading:SetPoint("TOPLEFT", 16, -16)
  heading:SetText(title)
  local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -6)
  sub:SetText(subtitle)
end

local function OptionHeader(panel, label, y)
  local text = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  text:SetPoint("TOPLEFT", 16, y)
  text:SetText(label)
  return text
end

local function OptionCheck(panel, label, y, read, write)
  local check = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
  check:SetPoint("TOPLEFT", 24, y)
  check.Text:SetText(label)
  check:SetScript("OnClick", function(self) write(self:GetChecked() == true) end)
  check.Sync = function(self) self:SetChecked(read() == true) end
  return check
end

local function OptionDropdown(panel, label, y, width, entries, read, write)
  local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  text:SetPoint("TOPLEFT", 32, y)
  text:SetText(label)
  local dropdown = CreateFrame("Frame", nil, panel, "UIDropDownMenuTemplate")
  dropdown:SetPoint("LEFT", text, "RIGHT", 0, -3)
  _G.UIDropDownMenu_SetWidth(dropdown, width or 120)
  _G.UIDropDownMenu_Initialize(dropdown, function()
    local current = read()
    for _, entry in ipairs(entries) do
      local info = _G.UIDropDownMenu_CreateInfo()
      info.text = entry.label
      info.value = entry.value
      info.checked = current == entry.value
      info.func = function() write(entry.value) dropdown:Sync() end
      _G.UIDropDownMenu_AddButton(info)
    end
  end)
  dropdown.Sync = function(self)
    local current = read()
    for _, entry in ipairs(entries) do
      if entry.value == current then _G.UIDropDownMenu_SetText(self, entry.label) return end
    end
    _G.UIDropDownMenu_SetText(self, entries[1].label)
  end
  return dropdown
end

local function OptionSlider(panel, label, y, minimum, maximum, step, read, write)
  local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
  slider:SetSize(200, 16)
  slider:SetPoint("TOPLEFT", 32, y)
  slider:SetMinMaxValues(minimum, maximum)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  slider.label = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  slider.label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
  slider.label:SetText(label)
  if slider.Low then slider.Low:SetText(string.format("%.1f", minimum)) end
  if slider.High then slider.High:SetText(string.format("%.1f", maximum)) end
  slider.value = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  slider.value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 2)
  slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value / step + 0.5) * step
    self.value:SetText(string.format("%.1fx", value))
    if not self.syncing then write(value) end
  end)
  slider.Sync = function(self)
    self.syncing = true
    self:SetValue(read())
    self.syncing = nil
  end
  return slider
end

local function OptionColor(panel, label, x, y, read, write)
  local button = CreateFrame("Button", nil, panel, "BackdropTemplate")
  button:SetSize(24, 20)
  button:SetPoint("TOPLEFT", x, y)
  Controls:Backdrop(button, Controls.colors.panel, Controls.colors.border)
  button.fill = button:CreateTexture(nil, "ARTWORK")
  button.fill:SetPoint("TOPLEFT", 3, -3)
  button.fill:SetPoint("BOTTOMRIGHT", -3, 3)
  button.label = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  button.label:SetPoint("LEFT", button, "RIGHT", 6, 0)
  button.label:SetText(label)
  button:SetScript("OnClick", function()
    if not _G.ColorPickerFrame then return end
    local current = read()
    local previous = { r = current.r or 1, g = current.g or 1, b = current.b or 1 }
    local info = { r = previous.r, g = previous.g, b = previous.b, hasOpacity = false }
    info.swatchFunc = function() local r, g, b = _G.ColorPickerFrame:GetColorRGB() write({ r = r, g = g, b = b }) button:Sync() end
    info.cancelFunc = function() write(previous) button:Sync() end
    _G.ColorPickerFrame:SetupColorPickerAndShow(info)
  end)
  button.Sync = function(self) local color = read() self.fill:SetColorTexture(color.r or 1, color.g or 1, color.b or 1, 1) end
  return button
end

local function OptionKeybind(panel, label, x, y, read, write, resetValue, slot)
  local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  text:SetPoint("TOPLEFT", x, y)
  text:SetWidth(42)
  text:SetJustifyH("RIGHT")
  text:SetText(label)
  local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  button:SetSize(82, 22)
  button:SetPoint("LEFT", text, "RIGHT", 7, 0)
  local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  reset:SetSize(48, 22)
  reset:SetPoint("LEFT", button, "RIGHT", 4, 0)
  reset:SetText("Reset")
  local function Display(key)
    if not key or key == "" then return "—" end
    return key:gsub("CTRL", "Ctrl"):gsub("SHIFT", "Shift"):gsub("ALT", "Alt")
  end
  button.Sync = function(self) self:SetText(Display(read())) end
  button:EnableKeyboard(false)
  button:SetScript("OnClick", function() NS.UI.Keybinds:CaptureQuickBar(slot, function() button:Sync() end) end)
  reset:SetScript("OnClick", function() write(resetValue) button:Sync() end)
  return button
end

local function RegisterPanel(panel, parentCategory)
  local api = _G.Settings
  if api and api.RegisterCanvasLayoutCategory then
    local category
    if parentCategory and api.RegisterCanvasLayoutSubcategory then category = api.RegisterCanvasLayoutSubcategory(parentCategory, panel, panel.name) else category = api.RegisterCanvasLayoutCategory(panel, panel.name) end
    api.RegisterAddOnCategory(category)
    panel.category = category
    return category
  end
  if parentCategory then panel.parent = "HomeDecor" end
  if _G.InterfaceOptions_AddCategory then _G.InterfaceOptions_AddCategory(panel) end
  return panel
end

function AddonSettings:EnsureOptions()
  if self.optionsPanel then return end
  local panel = CreateFrame("Frame")
  panel.name = "HomeDecor"
  OptionTitle(panel, "HomeDecor", "Configure HomeDecor features, maps, filters, and display behavior.")
  OptionHeader(panel, "General", -62)
  local controls = {}
  controls[#controls + 1] = OptionCheck(panel, "Show minimap button", -82, function() local p = Profile() return not (p.minimap and p.minimap.hide) end, function(value) self:SetMinimapShown(value) end)
  controls[#controls + 1] = OptionCheck(panel, "Show vendor decor assistant", -116, function() return Value("vendorAssistant", true) end, function(value) SetValue("vendorAssistant", value) self:Apply("vendorAssistant") end)
  controls[#controls + 1] = OptionCheck(panel, "Hide collected decor", -150, function() return Value("hideCollected", false) end, function(value) SetValue("hideCollected", value) self:Apply("hideCollected") end)
  controls[#controls + 1] = OptionCheck(panel, "Zone favorite alerts", -184, function() return Value("zoneFavoriteAlerts", true) end, function(value) SetValue("zoneFavoriteAlerts", value) end)
  controls[#controls + 1] = OptionCheck(panel, "Open in compact mode", -218, function() return Value("openCompact", false) end, function(value) SetValue("openCompact", value) end)
  OptionHeader(panel, "Map Pins", -262)
  controls[#controls + 1] = OptionCheck(panel, "Show decor pins on the minimap", -282, function() return Value("mapMinimapPins", true) end, function(value) SetValue("mapMinimapPins", value) self:Apply("mapMinimapPins") end)
  controls[#controls + 1] = OptionCheck(panel, "Show decor pins on the world map", -316, function() return Value("mapPins", true) end, function(value) SetValue("mapPins", value) self:Apply("mapPins") end)
  local style = OptionDropdown(panel, "Pin style:", -358, 115, { { label = "House", value = "house" }, { label = "Dot", value = "dot" } }, function() return Value("mapPinStyle", "house") end, function(value) SetValue("mapPinStyle", value) self:Apply("mapPinStyle") end)
  local anchor = OptionDropdown(panel, "Tooltip anchor:", -398, 115, { { label = "Left", value = "ANCHOR_LEFT" }, { label = "Right", value = "ANCHOR_RIGHT" }, { label = "Middle", value = "ANCHOR_MIDDLE" }, { label = "Bottom", value = "ANCHOR_BOTTOM" }, { label = "Cursor", value = "ANCHOR_CURSOR" } }, function() return Value("mapTooltipAnchor", "ANCHOR_RIGHT") end, function(value) SetValue("mapTooltipAnchor", value) self:Apply("mapTooltipAnchor") end)
  local pinSize = OptionSlider(panel, "Pin size", -458, 0.5, 2, 0.1, function() return tonumber(Value("mapPinSize", 1)) or 1 end, function(value) SetValue("mapPinSize", value) self:Apply("mapPinSize") end)
  local pinColor = OptionColor(panel, "Pin color", 300, -458, function() return Value("mapPinColor", { r = 1, g = 1, b = 1 }) end, function(value) SetValue("mapPinColor", value) self:Apply("mapPinColor") end)
  local function SyncMain()
    for _, control in ipairs(controls) do control:Sync() end
    style:Sync()
    anchor:Sync()
    pinSize:Sync()
    pinColor:Sync()
  end
  panel:HookScript("OnShow", function() C_Timer.After(0, SyncMain) end)
  local rootCategory = RegisterPanel(panel)
  self.optionsPanel = panel

  local vendor = CreateFrame("Frame")
  vendor.name = "Vendor Options"
  OptionTitle(vendor, "Vendor Options", "Control what HomeDecor overlays on the vendor window.")
  OptionHeader(vendor, "Vendor Display", -62)
  local vendorControls = {
    OptionCheck(vendor, "Show vendor decor assistant", -82, function() return Value("vendorAssistant", true) end, function(value) SetValue("vendorAssistant", value) self:Apply("vendorAssistant") end),
    OptionCheck(vendor, "Show collected, tracked, and saved markers", -116, function() return Value("vendorMarkers", true) end, function(value) SetValue("vendorMarkers", value) self:Apply("vendorMarkers") end),
  }
  local function SyncVendor() for _, control in ipairs(vendorControls) do control:Sync() end end
  vendor:HookScript("OnShow", function() C_Timer.After(0, SyncVendor) end)
  RegisterPanel(vendor, rootCategory)
  self.vendorPanel = vendor

  local gather = CreateFrame("Frame")
  gather.name = "Gather Tracker"
  OptionTitle(gather, "Gather Tracker", "Configure tracked materials, sessions, and the farming display.")
  OptionHeader(gather, "Materials", -62)
  local gatherSettings = function() return NS.Systems.GatherTracker:GetSettings() end
  local gatherControls = {
    OptionCheck(gather, "Track lumber", -82, function() return gatherSettings().trackLumber end, function(value) gatherSettings().trackLumber = value NS.UI.GatherTracker:Refresh(true) end),
    OptionCheck(gather, "Track ore", -116, function() return gatherSettings().trackOre end, function(value) gatherSettings().trackOre = value NS.UI.GatherTracker:Refresh(true) end),
    OptionCheck(gather, "Track herbs", -150, function() return gatherSettings().trackHerbs end, function(value) gatherSettings().trackHerbs = value NS.UI.GatherTracker:Refresh(true) end),
    OptionCheck(gather, "Hide materials with zero", -184, function() return gatherSettings().hideZero end, function(value) gatherSettings().hideZero = value NS.UI.GatherTracker:Refresh(true) end),
    OptionCheck(gather, "Auto-start farming on first gain", -218, function() return gatherSettings().autoFarm end, function(value) gatherSettings().autoFarm = value end),
    OptionCheck(gather, "Show minimap farming HUD", -252, function() return gatherSettings().hudEnabled end, function(value) gatherSettings().hudEnabled = value NS.UI.GatherTracker:RefreshHUD() end),
    OptionCheck(gather, "Use compact farmer display", -286, function() return gatherSettings().farmerCompact end, function(value) gatherSettings().farmerCompact = value NS.UI.GatherTracker:RefreshFarmer() end),
  }
  local scope = OptionDropdown(gather, "Count materials for:", -334, 145, { { label = "All Characters", value = "account" }, { label = "Current Character", value = "character" } }, function() return gatherSettings().scope end, function(value) gatherSettings().scope = value NS.UI.GatherTracker:Refresh(true) end)
  local function SyncGather() for _, control in ipairs(gatherControls) do control:Sync() end scope:Sync() end
  gather:HookScript("OnShow", function() C_Timer.After(0, SyncGather) end)
  RegisterPanel(gather, rootCategory)
  self.gatherPanel = gather

  local editor = CreateFrame("Frame")
  editor.name = "Housing Editor"
  OptionTitle(editor, "Housing Editor", "Configure HomeDecor features for the housing editor.")
  OptionHeader(editor, "General", -62)
  local editorControls = {
    OptionCheck(editor, "Enable Editing Features", -82, function() return Value("editorFeatures", true) end, function(value) SetValue("editorFeatures", value) self:Apply("editorFeatures") end),
    OptionCheck(editor, "Show keybind hint panel", -116, function() return Value("editorHints", true) end, function(value) SetValue("editorHints", value) self:Apply("editorHints") end),
  }
  OptionHeader(editor, "Editor Clock & Timer", -160)
  editorControls[#editorControls + 1] = OptionCheck(editor, "Show editor clock", -180, function() return Value("editorClock", true) end, function(value) SetValue("editorClock", value) self:Apply("editorClock") end)
  local clockDisplay = OptionDropdown(editor, "Main display:", -222, 125, { { label = "Current time", value = "clock" }, { label = "Session timer", value = "session" } }, function() return Value("editorClockDisplay", "clock") end, function(value) SetValue("editorClockDisplay", value) if NS.UI.QuickBar.clock then NS.UI.QuickBar.clock.showSession = value == "session" end self:Apply("editorClockDisplay") end)
  local clockSource = OptionDropdown(editor, "Time source:", -262, 125, { { label = "Game setting", value = "auto" }, { label = "Local time", value = "local" }, { label = "Realm time", value = "realm" } }, function() return Value("editorClockSource", "auto") end, function(value) SetValue("editorClockSource", value) self:Apply("editorClockSource") end)
  local clockFormat = OptionDropdown(editor, "Time format:", -302, 125, { { label = "Game setting", value = "auto" }, { label = "12-hour", value = "12" }, { label = "24-hour", value = "24" } }, function() return Value("editorClockFormat", "auto") end, function(value) SetValue("editorClockFormat", value) self:Apply("editorClockFormat") end)
  local resetTime = CreateFrame("Button", nil, editor, "UIPanelButtonTemplate")
  resetTime:SetSize(136, 24)
  resetTime:SetPoint("TOPLEFT", 32, -344)
  resetTime:SetText("Reset total time")
  resetTime:SetScript("OnClick", function() NS.UI.QuickBar:ResetEditorTime() end)
  OptionHeader(editor, "Quick Bar", -392)
  editorControls[#editorControls + 1] = OptionCheck(editor, "Show Quick Bar", -412, function() return Value("quickBar", true) end, function(value) SetValue("quickBar", value) self:Apply("quickBar") end)
  local note = editor:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  note:SetPoint("TOPLEFT", 32, -454)
  note:SetWidth(540)
  note:SetJustifyH("LEFT")
  note:SetText("Quick Bar bindings are shown below. Reset restores F1 through F8.")
  local keyButtons = {}
  for slot = 1, 8 do
    local slotIndex = slot
    local column = (slotIndex - 1) % 2
    local row = math.floor((slotIndex - 1) / 2)
    keyButtons[#keyButtons + 1] = OptionKeybind(editor, "Slot " .. tostring(slotIndex), 32 + column * 270, -488 - row * 30, function() return NS.UI.QuickBar:GetKeybind(slotIndex) end, function(key) NS.UI.QuickBar:SetKeybind(slotIndex, key) end, "F" .. tostring(slotIndex), slotIndex)
  end
  local function SyncEditor()
    for _, control in ipairs(editorControls) do control:Sync() end
    for _, button in ipairs(keyButtons) do button:Sync() end
    clockDisplay:Sync()
    clockSource:Sync()
    clockFormat:Sync()
  end
  editor:HookScript("OnShow", function() C_Timer.After(0, SyncEditor) end)
  editor:HookScript("OnHide", function() NS.UI.Keybinds:Cancel() end)
  RegisterPanel(editor, rootCategory)
  self.editorPanel = editor
  SyncMain()
  SyncVendor()
  SyncGather()
  SyncEditor()
end

function AddonSettings:OpenOptions()
  self:EnsureOptions()
  local api = _G.Settings
  local category = self.optionsPanel and self.optionsPanel.category
  if api and api.OpenToCategory and category then
    local id = category.GetID and category:GetID() or category.ID
    if id then api.OpenToCategory(id) else api.OpenToCategory("HomeDecor") end
  elseif _G.InterfaceOptionsFrame_OpenToCategory then
    _G.InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
    _G.InterfaceOptionsFrame_OpenToCategory(self.optionsPanel)
  end
end
