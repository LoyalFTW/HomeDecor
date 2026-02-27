local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.Options = NS.UI.Options or {}
local Options = NS.UI.Options
local function L(k) return (NS.L and NS.L[k]) or k end

local CreateFrame = _G.CreateFrame
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
local Settings = _G.Settings

local function bool(v)
  return v and true or false
end

local function ensureProfile()
  local db = NS.db
  local prof = db and db.profile
  if not prof then return nil end
  prof.mapPins = prof.mapPins or {}
  if prof.mapPins.minimap == nil then prof.mapPins.minimap = true end
  if prof.mapPins.worldmap == nil then prof.mapPins.worldmap = true end
  if prof.mapPins.pinStyle == nil then prof.mapPins.pinStyle = "house" end
  if prof.mapPins.pinSize == nil then prof.mapPins.pinSize = 1.0 end
  if prof.mapPins.pinTooltipAnchor == nil then prof.mapPins.pinTooltipAnchor = "ANCHOR_RIGHT" end
  if prof.mapPins.pinColor == nil or type(prof.mapPins.pinColor) ~= "table" then
    prof.mapPins.pinColor = { r = 1.0, g = 1.0, b = 1.0 }
  else
    prof.mapPins.pinColor.r = prof.mapPins.pinColor.r or 1.0
    prof.mapPins.pinColor.g = prof.mapPins.pinColor.g or 1.0
    prof.mapPins.pinColor.b = prof.mapPins.pinColor.b or 1.0
  end
  prof.minimap = prof.minimap or { hide = false }
  prof.vendor = prof.vendor or {}
  if prof.vendor.showCollectedCheckmark == nil then prof.vendor.showCollectedCheckmark = true end
  if prof.vendor.showOwnedCount == nil then prof.vendor.showOwnedCount = false end
  if prof.vendor.showVendorNPCTooltip == nil then prof.vendor.showVendorNPCTooltip = false end
  prof.lumberTrack = prof.lumberTrack or {}
  prof.quickBar = prof.quickBar or {}
  if prof.quickBar.enabled == nil then prof.quickBar.enabled = true end
  prof.quickBar.keybinds = prof.quickBar.keybinds or {}
  for i = 1, 8 do
    if prof.quickBar.keybinds[i] == nil then
      prof.quickBar.keybinds[i] = "F" .. i
    end
  end
  prof.editMode = prof.editMode or {}
  prof.editMode.keybinds = prof.editMode.keybinds or {}
  local emKbDefaults = { copy="CTRL-C", cut="CTRL-X", paste="CTRL-V", duplicate="CTRL-D", lock="L" }
  for k, v in pairs(emKbDefaults) do
    if prof.editMode.keybinds[k] == nil then
      prof.editMode.keybinds[k] = v
    end
  end
  if prof.lumberTrack.hideZero == nil then prof.lumberTrack.hideZero = false end
  if prof.lumberTrack.showIcons == nil then prof.lumberTrack.showIcons = true end
  if prof.lumberTrack.compactMode == nil then prof.lumberTrack.compactMode = false end
  if prof.lumberTrack.alpha == nil then prof.lumberTrack.alpha = 0.7 end
  if prof.lumberTrack.goal == nil then prof.lumberTrack.goal = 1000 end
  if prof.lumberTrack.search == nil then prof.lumberTrack.search = "" end
  if prof.lumberTrack.autoGoal == nil then prof.lumberTrack.autoGoal = false end
  if prof.lumberTrack.accountWide == nil then prof.lumberTrack.accountWide = false end
  if prof.lumberTrack.autoStartFarming == nil then prof.lumberTrack.autoStartFarming = false end
  return prof
end

local function refreshPins()
  local MP = NS.Systems and NS.Systems.MapPins
  if not MP then return end
  if MP.RefreshCurrentZone then pcall(function() MP:RefreshCurrentZone() end) end
  if MP.RefreshWorldMap then pcall(function() MP:RefreshWorldMap() end) end
end

local function openCategoryFrame(panel)
  if Settings and Settings.OpenToCategory and panel then
    local cat = panel.category
    local id

    if type(cat) == "table" then
      id = cat.ID
      if not id and type(cat.GetID) == "function" then
        local ok, v = pcall(cat.GetID, cat)
        if ok then id = v end
      end
    elseif type(cat) == "number" then
      id = cat
    end

    if id then
      Settings.OpenToCategory(id)
      return
    end

    if panel.name then
      pcall(function() Settings.OpenToCategory(panel.name) end)
      return
    end
  end

  if InterfaceOptionsFrame_OpenToCategory and panel then
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
  end
end

local function mkCheckbox(parent, label, sub)
  local b = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  b.Text:SetText(label)
  if sub and sub ~= "" then
    b.tooltipText = label
    b.tooltipRequirement = sub
  end
  return b
end

local function mkDropdown(parent, width)
  local dropdown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
  _G.UIDropDownMenu_SetWidth(dropdown, width or 120)
  return dropdown
end

local function mkColorPicker(parent, label)
  local button = CreateFrame("Button", nil, parent)
  button:SetSize(20, 20)

  button.bg = button:CreateTexture(nil, "BACKGROUND")
  button.bg:SetAllPoints()
  button.bg:SetColorTexture(0, 0, 0, 0.5)

  button.color = button:CreateTexture(nil, "ARTWORK")
  button.color:SetPoint("TOPLEFT", 2, -2)
  button.color:SetPoint("BOTTOMRIGHT", -2, 2)
  button.color:SetColorTexture(1, 1, 1)

  button.label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  button.label:SetPoint("LEFT", button, "RIGHT", 5, 0)
  button.label:SetText(label)

  button:SetScript("OnClick", function(self)
    if not _G.ColorPickerFrame then return end
    local prof = ensureProfile()
    if not prof then return end

    local info = {}
    info.r = prof.mapPins.pinColor.r
    info.g = prof.mapPins.pinColor.g
    info.b = prof.mapPins.pinColor.b
    info.hasOpacity = false
    info.swatchFunc = function()
      local r, g, b = _G.ColorPickerFrame:GetColorRGB()
      prof.mapPins.pinColor.r = r
      prof.mapPins.pinColor.g = g
      prof.mapPins.pinColor.b = b
      self.color:SetColorTexture(r, g, b)
      refreshPins()
    end
    info.cancelFunc = function(restore)
      prof.mapPins.pinColor.r = restore.r
      prof.mapPins.pinColor.g = restore.g
      prof.mapPins.pinColor.b = restore.b
      self.color:SetColorTexture(restore.r, restore.g, restore.b)
      refreshPins()
    end

    _G.ColorPickerFrame:SetupColorPickerAndShow(info)
  end)

  return button
end

local function mkSlider(parent, label, minVal, maxVal, step)
  local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  slider:SetMinMaxValues(minVal, maxVal)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)

  slider.label = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  slider.label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 2)
  slider.label:SetText(label)

  slider.valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  slider.valueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 2)

  slider.Low:SetText(string.format("%.1f", minVal))
  slider.High:SetText(string.format("%.1f", maxVal))

  return slider
end

function Options:Ensure()
  if self.panel then return end

  local panel = CreateFrame("Frame")
  panel.name = "HomeDecor"

  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText(L("ADDON_NAME"))

  local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  sub:SetText(L("OPT_SUBTITLE"))

  local y = -60

  local cbMinimapButton = mkCheckbox(panel, L("OPT_SHOW_MINIMAP_BTN"))
  cbMinimapButton:SetPoint("TOPLEFT", 16, y)
  y = y - 34

  local minimapHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  minimapHeader:SetPoint("TOPLEFT", 16, y)
  minimapHeader:SetText(L("OPT_MINIMAP"))
  y = y - 24

  local cbMiniPins = mkCheckbox(panel, L("OPT_MINIMAP_PINS"))
  cbMiniPins:SetPoint("TOPLEFT", 32, y)
  y = y - 34

  local worldmapHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  worldmapHeader:SetPoint("TOPLEFT", 16, y)
  worldmapHeader:SetText(L("OPT_WORLD_MAP"))
  y = y - 24

  local cbWorldPins = mkCheckbox(panel, L("OPT_WORLDMAP_PINS"))
  cbWorldPins:SetPoint("TOPLEFT", 32, y)
  y = y - 34

  local worldTooltipAnchorLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  worldTooltipAnchorLabel:SetPoint("TOPLEFT", 32, y)
  worldTooltipAnchorLabel:SetText(L("OPT_WORLDMAP_TOOLTIP_ANCHOR"))

  local ANCHOR_OPTIONS_WORLD = {
    { value = "ANCHOR_LEFT",   label = L("ANCHOR_LEFT")   or "Left"   },
	{ value = "ANCHOR_RIGHT",  label = L("ANCHOR_RIGHT")  or "Right"  },
    { value = "ANCHOR_MIDDLE", label = L("ANCHOR_MIDDLE") or "Middle" },
    { value = "ANCHOR_BOTTOM", label = L("ANCHOR_BOTTOM") or "Bottom" },
    { value = "ANCHOR_CURSOR", label = L("ANCHOR_CURSOR") or "Cursor" },
  }

  local ddWorldTooltipAnchor = mkDropdown(panel, 120)
  ddWorldTooltipAnchor:SetPoint("LEFT", worldTooltipAnchorLabel, "RIGHT", 0, -3)

  _G.UIDropDownMenu_Initialize(ddWorldTooltipAnchor, function(self)
    local prof = ensureProfile()
    if not prof then return end
    for _, entry in ipairs(ANCHOR_OPTIONS_WORLD) do
      local info = _G.UIDropDownMenu_CreateInfo()
      info.text    = entry.label
      info.value   = entry.value
      info.checked = (prof.mapPins.pinTooltipAnchor == entry.value)
      info.func    = function()
        prof.mapPins.pinTooltipAnchor = entry.value
        _G.UIDropDownMenu_SetText(ddWorldTooltipAnchor, entry.label)
      end
      _G.UIDropDownMenu_AddButton(info)
    end
  end)

  y = y - 40

  local filterHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  filterHeader:SetPoint("TOPLEFT", 16, y)
  filterHeader:SetText(L("FILTERS"))
  y = y - 24

  local cbHideCollected = mkCheckbox(panel, L("OPT_HIDE_COLLECTED"),
    L("OPT_HIDE_COLLECTED_TIP"))
  cbHideCollected:SetPoint("TOPLEFT", 32, y)
  y = y - 34

  local appearanceHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  appearanceHeader:SetPoint("TOPLEFT", 16, y)
  appearanceHeader:SetText(L("OPT_PIN_APPEARANCE"))
  y = y - 24

  local styleLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  styleLabel:SetPoint("TOPLEFT", 32, y)
  styleLabel:SetText(L("OPT_PIN_STYLE"))

  local ddPinStyle = mkDropdown(panel, 120)
  ddPinStyle:SetPoint("LEFT", styleLabel, "RIGHT", 0, -3)

  _G.UIDropDownMenu_Initialize(ddPinStyle, function(self)
    local prof = ensureProfile()
    if not prof then return end

    local info = _G.UIDropDownMenu_CreateInfo()

    info.text = L("OPT_PIN_HOUSE")
    info.value = "house"
    info.checked = (prof.mapPins.pinStyle == "house")
    info.func = function()
      prof.mapPins.pinStyle = "house"
      _G.UIDropDownMenu_SetText(ddPinStyle, L("OPT_PIN_HOUSE"))
      refreshPins()
    end
    _G.UIDropDownMenu_AddButton(info)

    info.text = L("OPT_PIN_DOT")
    info.value = "dot"
    info.checked = (prof.mapPins.pinStyle == "dot")
    info.func = function()
      prof.mapPins.pinStyle = "dot"
      _G.UIDropDownMenu_SetText(ddPinStyle, L("OPT_PIN_DOT"))
      refreshPins()
    end
    _G.UIDropDownMenu_AddButton(info)
  end)

  y = y - 34

  local colorPicker = mkColorPicker(panel, L("OPT_PIN_COLOR"))
  colorPicker:SetPoint("TOPLEFT", 32, y)

  local btnResetColor = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  btnResetColor:SetSize(100, 22)
  btnResetColor:SetPoint("LEFT", colorPicker.label, "RIGHT", 10, 0)
  btnResetColor:SetText(L("OPT_RESET_COLOR"))
  btnResetColor:SetScript("OnClick", function()
    local prof = ensureProfile()
    if not prof then return end
    prof.mapPins.pinColor.r = 1.0
    prof.mapPins.pinColor.g = 1.0
    prof.mapPins.pinColor.b = 1.0
    colorPicker.color:SetColorTexture(1, 1, 1)
    refreshPins()
  end)

  y = y - 40

  local sizeSlider = mkSlider(panel, L("OPT_PIN_SIZE"), 0.5, 2.0, 0.1)
  sizeSlider:SetSize(200, 16)
  sizeSlider:SetPoint("TOPLEFT", 32, y)
  sizeSlider:SetScript("OnValueChanged", function(self, value)
    local prof = ensureProfile()
    if not prof then return end
    value = math.floor(value * 10 + 0.5) / 10
    prof.mapPins.pinSize = value
    self.valueText:SetText(string.format("%.1fx", value))
    refreshPins()
  end)

  y = y - 40

  local trackerHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  trackerHeader:SetPoint("TOPLEFT", 16, y)
  trackerHeader:SetText(L("OPT_TRACKER_HEADER"))
  y = y - 24

  local cbShowFavoritesOnZone = mkCheckbox(panel, L("OPT_HIGHLIGHT_ZONE"),
    L("OPT_HIGHLIGHT_ZONE_TIP"))
  cbShowFavoritesOnZone:SetPoint("TOPLEFT", 32, y)

  local function syncFromDB()
    local prof = ensureProfile()
    if not prof then return end
    cbMinimapButton:SetChecked(not bool(prof.minimap.hide))
    cbMiniPins:SetChecked(bool(prof.mapPins.minimap))
    cbWorldPins:SetChecked(bool(prof.mapPins.worldmap))
    cbHideCollected:SetChecked(bool(prof.filters and prof.filters.hideCollected))

    local tracker = prof.tracker or {}
    cbShowFavoritesOnZone:SetChecked(tracker.showFavoritesOnZoneEnter ~= false)

    if prof.mapPins.pinStyle == "dot" then
      _G.UIDropDownMenu_SetText(ddPinStyle, L("OPT_PIN_DOT"))
    else
      _G.UIDropDownMenu_SetText(ddPinStyle, L("OPT_PIN_HOUSE"))
    end

    local c = prof.mapPins.pinColor
    colorPicker.color:SetColorTexture(c.r, c.g, c.b)

    local size = prof.mapPins.pinSize or 1.0
    sizeSlider:SetValue(size)
    sizeSlider.valueText:SetText(string.format("%.1fx", size))

    local curAnchor = prof.mapPins.pinTooltipAnchor or "ANCHOR_RIGHT"
    local anchorLabel = curAnchor
    for _, entry in ipairs(ANCHOR_OPTIONS_WORLD) do
      if entry.value == curAnchor then anchorLabel = entry.label break end
    end
    _G.UIDropDownMenu_SetText(ddWorldTooltipAnchor, anchorLabel)
  end

  cbMinimapButton:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local show = self:GetChecked() and true or false
    prof.minimap.hide = not show
    if NS.UI and NS.UI.SetMinimapHidden then
      pcall(NS.UI.SetMinimapHidden, NS.db, not show)
    else
      local LDBIcon = _G.LibStub and _G.LibStub("LibDBIcon-1.0", true)
      if LDBIcon and LDBIcon:IsRegistered(ADDON) then
        if show then LDBIcon:Show(ADDON) else LDBIcon:Hide(ADDON) end
      end
    end
  end)

  cbMiniPins:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.mapPins.minimap = self:GetChecked() and true or false
    refreshPins()
  end)

  cbHideCollected:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.filters = prof.filters or {}
    prof.filters.hideCollected = self:GetChecked() and true or false
    local UI = NS.UI
    if UI and UI.MainFrame and UI.MainFrame.view then
      pcall(function() UI.MainFrame.view:RequestRender(true) end)
    end
  end)

  cbWorldPins:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.mapPins.worldmap = self:GetChecked() and true or false
    refreshPins()
  end)

  cbShowFavoritesOnZone:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.tracker = prof.tracker or {}
    prof.tracker.showFavoritesOnZoneEnter = self:GetChecked() and true or false
  end)

  panel:SetScript("OnShow", syncFromDB)

  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    panel.category = category
  else
    local add = _G.InterfaceOptions_AddCategory
    if add then add(panel) end
  end

  self.panel = panel

  local vendorPanel = CreateFrame("Frame")
  vendorPanel.name = L("VENDOR_OPTIONS")

  local vendorTitle = vendorPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  vendorTitle:SetPoint("TOPLEFT", 16, -16)
  vendorTitle:SetText(L("VENDOR_OPTIONS"))

  local vendorSub = vendorPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  vendorSub:SetPoint("TOPLEFT", vendorTitle, "BOTTOMLEFT", 0, -6)
  vendorSub:SetText(L("OPT_VENDOR_SUBTITLE"))

  local vy = -60

  local cbCollectedCheckmark = mkCheckbox(vendorPanel, L("OPT_SHOW_CHECKMARK"),
    L("OPT_SHOW_CHECKMARK_TIP"))
  cbCollectedCheckmark:SetPoint("TOPLEFT", 16, vy)
  vy = vy - 34

  local cbOwnedCount = mkCheckbox(vendorPanel, L("OPT_SHOW_OWNED_COUNT"),
    L("OPT_SHOW_OWNED_COUNT_TIP"))
  cbOwnedCount:SetPoint("TOPLEFT", 16, vy)
  vy = vy - 34

  local cbVendorNPCTooltip = mkCheckbox(vendorPanel, L("OPT_VENDOR_TOOLTIP"),
    L("OPT_VENDOR_TOOLTIP_TIP"))
  cbVendorNPCTooltip:SetPoint("TOPLEFT", 16, vy)

  local function syncVendorFromDB()
    local prof = ensureProfile()
    if not prof then return end
    local v1 = bool(prof.vendor.showCollectedCheckmark)
    local v2 = bool(prof.vendor.showOwnedCount)
    local v3 = bool(prof.vendor.showVendorNPCTooltip)
    cbCollectedCheckmark:SetChecked(v1)
    cbCollectedCheckmark.value = v1
    cbOwnedCount:SetChecked(v2)
    cbOwnedCount.value = v2
    cbVendorNPCTooltip:SetChecked(v3)
    cbVendorNPCTooltip.value = v3
  end

  vendorPanel:SetScript("OnShow", syncVendorFromDB)

  local settingsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
  if settingsFrame and settingsFrame.HookScript then
    settingsFrame:HookScript("OnShow", syncVendorFromDB)
  end

  if Settings and Settings.OpenToCategory then
    hooksecurefunc(Settings, "OpenToCategory", function()
      C_Timer.After(0, syncVendorFromDB)
    end)
  end

  cbCollectedCheckmark:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.vendor.showCollectedCheckmark = val
    self.value = val
    local CM = NS.UI and NS.UI.VendorCheckMarks
    if CM then
      if val then
        if CM.Refresh then pcall(CM.Refresh, CM) end
      else
        if CM.HideAll then pcall(CM.HideAll, CM) end
      end
    end
  end)

  cbOwnedCount:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.vendor.showOwnedCount = val
    self.value = val
    local DC = NS.UI and NS.UI.VendorDecorCounters
    if DC then
      if val then
        if DC.Refresh then pcall(DC.Refresh, DC) end
      else
        if DC.HideAll then pcall(DC.HideAll, DC) end
      end
    end
  end)

  cbVendorNPCTooltip:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.vendor.showVendorNPCTooltip = val
    self.value = val
  end)

  if Settings and Settings.RegisterCanvasLayoutSubcategory then
    local vendorCategory = Settings.RegisterCanvasLayoutSubcategory(panel.category, vendorPanel, vendorPanel.name)
    Settings.RegisterAddOnCategory(vendorCategory)
    vendorPanel.category = vendorCategory
    if panel.category then
      panel.category.collapsed = true
    end
  else
    vendorPanel.parent = panel
    local add = _G.InterfaceOptions_AddCategory
    if add then add(vendorPanel) end
  end

  self.vendorPanel = vendorPanel

  local lumberPanel = CreateFrame("Frame")
  lumberPanel.name = L("LUMBER_OPTIONS")

  local lumberTitle = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  lumberTitle:SetPoint("TOPLEFT", 16, -16)
  lumberTitle:SetText(L("LUMBER_OPTIONS"))

  local lumberSub = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  lumberSub:SetPoint("TOPLEFT", lumberTitle, "BOTTOMLEFT", 0, -6)
  lumberSub:SetText(L("OPT_LUMBER_SUBTITLE"))

  local ly = -60

  local lumberDisplayHeader = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  lumberDisplayHeader:SetPoint("TOPLEFT", 16, ly)
  lumberDisplayHeader:SetText(L("OPT_LUMBER_DISPLAY"))
  ly = ly - 24

  local cbLumberShowIcons = mkCheckbox(lumberPanel,
    L("LUMBER_SHOW_ICONS"),
    L("OPT_LUMBER_SHOW_ICONS_TIP"))
  cbLumberShowIcons:SetPoint("TOPLEFT", 32, ly)
  ly = ly - 34

  local cbLumberHideZero = mkCheckbox(lumberPanel,
    L("LUMBER_HIDE_ZERO"),
    L("OPT_LUMBER_HIDE_ZERO_TIP"))
  cbLumberHideZero:SetPoint("TOPLEFT", 32, ly)
  ly = ly - 34

  local cbLumberCompact = mkCheckbox(lumberPanel,
    L("LUMBER_COMPACT_MODE"),
    L("LUMBER_COMPACT_TIP"))
  cbLumberCompact:SetPoint("TOPLEFT", 32, ly)
  ly = ly - 34

  local lumberAlphaSlider = mkSlider(lumberPanel,
    L("TRANSPARENCY_COLON"), 0, 1, 0.05)
  lumberAlphaSlider:SetSize(200, 16)
  lumberAlphaSlider:SetPoint("TOPLEFT", 32, ly)
  lumberAlphaSlider.Low:SetText("0%")
  lumberAlphaSlider.High:SetText("100%")
  lumberAlphaSlider:SetScript("OnValueChanged", function(self, value)
    local prof = ensureProfile()
    if not prof then return end
    value = math.floor(value * 20 + 0.5) / 20
    prof.lumberTrack.alpha = value
    self.valueText:SetText(string.format("%.0f%%", value * 100))
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      local sharedCtx = LumberList.sharedCtx
      if sharedCtx.frame then sharedCtx.frame._bgAlpha = value end
      sharedCtx.showRowBackgrounds = value >= 0.3
      local Rows = NS.UI.LumberTrackRows
      if Rows and Rows.UpdateRowTransparency then
        Rows:UpdateRowTransparency(sharedCtx)
      end
    end
  end)
  ly = ly - 40

  local lumberGoalsHeader = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  lumberGoalsHeader:SetPoint("TOPLEFT", 16, ly)
  lumberGoalsHeader:SetText(L("OPT_LUMBER_GOALS"))
  ly = ly - 24

  local lumberGoalLabel = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  lumberGoalLabel:SetPoint("TOPLEFT", 32, ly)
  lumberGoalLabel:SetText(L("LUMBER_GOAL_AMOUNT"))

  local lumberGoalInput = CreateFrame("EditBox", nil, lumberPanel, "InputBoxTemplate")
  lumberGoalInput:SetPoint("LEFT", lumberGoalLabel, "RIGHT", 10, 0)
  lumberGoalInput:SetSize(80, 20)
  lumberGoalInput:SetAutoFocus(false)
  lumberGoalInput:SetFontObject(GameFontHighlight)
  lumberGoalInput:SetMaxLetters(6)
  lumberGoalInput:SetNumeric(true)
  lumberGoalInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  lumberGoalInput:SetScript("OnEnterPressed", function(self)
    local prof = ensureProfile()
    if not prof then self:ClearFocus() return end
    local val = math.max(1, math.min(tonumber(self:GetText()) or 1000, 999999))
    self:SetText(tostring(val))
    prof.lumberTrack.goal = val
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      LumberList.sharedCtx.goal = val
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(LumberList.sharedCtx) end
    end
    self:ClearFocus()
  end)
  ly = ly - 34

  local cbLumberAutoGoal = mkCheckbox(lumberPanel,
    L("LUMBER_AUTO_CALC_GOALS"),
    L("LUMBER_AUTO_CALC_GOALS_TIP"))
  cbLumberAutoGoal:SetPoint("TOPLEFT", 32, ly)
  ly = ly - 34

  local lumberFarmingHeader = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  lumberFarmingHeader:SetPoint("TOPLEFT", 16, ly)
  lumberFarmingHeader:SetText(L("OPT_LUMBER_FARMING"))
  ly = ly - 24

  local cbLumberAutoFarm = mkCheckbox(lumberPanel,
    L("LUMBER_AUTO_FARM"),
    L("LUMBER_AUTO_FARM_TIP"))
  cbLumberAutoFarm:SetPoint("TOPLEFT", 32, ly)
  ly = ly - 34

  local lumberAccountHeader = lumberPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  lumberAccountHeader:SetPoint("TOPLEFT", 16, ly)
  lumberAccountHeader:SetText(L("OPT_LUMBER_ACCOUNT"))
  ly = ly - 24

  local cbLumberAccountWide = mkCheckbox(lumberPanel,
    L("LUMBER_ACCOUNT_WIDE"),
    L("OPT_LUMBER_ACCOUNT_WIDE_TIP"))
  cbLumberAccountWide:SetPoint("TOPLEFT", 32, ly)

  local function syncLumberFromDB()
    local prof = ensureProfile()
    if not prof then return end
    local lt = prof.lumberTrack

    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    local sharedCtx  = LumberList and LumberList.sharedCtx
    if sharedCtx then
      lt.showIcons        = sharedCtx.showIcons ~= false
      lt.hideZero         = sharedCtx.hideZero and true or false
      lt.compactMode      = sharedCtx.compactMode and true or false
      lt.autoStartFarming = sharedCtx.autoStartFarming and true or false
      lt.autoGoal         = sharedCtx.autoGoal and true or false
      if tonumber(sharedCtx.goal) then lt.goal = sharedCtx.goal end
      if sharedCtx.frame and tonumber(sharedCtx.frame._bgAlpha) then
        lt.alpha = sharedCtx.frame._bgAlpha
      end
      local AccountWide = NS.UI and NS.UI.LumberTrackAccountWide
      if AccountWide then lt.accountWide = AccountWide:IsEnabled() end
    end

    local showIcons = bool(lt.showIcons ~= false)
    cbLumberShowIcons:SetChecked(showIcons)
    cbLumberShowIcons.value = showIcons

    cbLumberHideZero:SetChecked(bool(lt.hideZero))
    cbLumberHideZero.value = bool(lt.hideZero)

    cbLumberCompact:SetChecked(bool(lt.compactMode))
    cbLumberCompact.value = bool(lt.compactMode)

    cbLumberAutoFarm:SetChecked(bool(lt.autoStartFarming))
    cbLumberAutoFarm.value = bool(lt.autoStartFarming)

    local AccountWide = NS.UI and NS.UI.LumberTrackAccountWide
    local awEnabled = AccountWide and AccountWide:IsEnabled() or bool(lt.accountWide)
    cbLumberAccountWide:SetChecked(awEnabled)
    cbLumberAccountWide.value = awEnabled

    local goalVal = tonumber(lt.goal) or 1000
    lumberGoalInput:SetText(tostring(goalVal))

    local autoGoal = bool(lt.autoGoal)
    cbLumberAutoGoal:SetChecked(autoGoal)
    cbLumberAutoGoal.value = autoGoal
    if autoGoal then
      lumberGoalInput:Disable()
      lumberGoalLabel:SetTextColor(0.5, 0.5, 0.5, 1)
    else
      lumberGoalInput:Enable()
      lumberGoalLabel:SetTextColor(1, 1, 1, 1)
    end

    local alpha = tonumber(lt.alpha) or 0.7
    lumberAlphaSlider:SetValue(alpha)
    lumberAlphaSlider.valueText:SetText(string.format("%.0f%%", alpha * 100))
  end

  lumberPanel:SetScript("OnShow", syncLumberFromDB)

  local lumberSettingsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
  if lumberSettingsFrame and lumberSettingsFrame.HookScript then
    lumberSettingsFrame:HookScript("OnShow", syncLumberFromDB)
  end

  if Settings and Settings.OpenToCategory then
    hooksecurefunc(Settings, "OpenToCategory", function()
      C_Timer.After(0, syncLumberFromDB)
    end)
  end

  cbLumberShowIcons:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.showIcons = val
    self.value = val
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      LumberList.sharedCtx.showIcons = val
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(LumberList.sharedCtx) end
    end
  end)

  cbLumberHideZero:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.hideZero = val
    self.value = val
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      LumberList.sharedCtx.hideZero = val
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(LumberList.sharedCtx) end
    end
  end)

  cbLumberCompact:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.compactMode = val
    self.value = val
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      local sharedCtx = LumberList.sharedCtx
      sharedCtx.compactMode = val
      if sharedCtx.rows then
        for i, row in pairs(sharedCtx.rows) do
          if row then row:Hide(); row:SetParent(nil) end
          sharedCtx.rows[i] = nil
        end
      end
      if LumberList.compactBtn then
        local Tx = NS.LT and NS.LT.Utils and NS.LT.Utils.GetTheme and NS.LT.Utils.GetTheme() or {}
        if val then
          LumberList.compactBtn:SetBackdropBorderColor(unpack(Tx.accentBright or Tx.accent or {1,0.82,0.2,1}))
          LumberList.compactBtn.icon:SetVertexColor(unpack(Tx.accent or {1,0.82,0.2,1}))
        else
          LumberList.compactBtn:SetBackdropBorderColor(unpack(Tx.border or {0.24,0.24,0.28,0.8}))
          LumberList.compactBtn.icon:SetVertexColor(0.6, 0.6, 0.6, 1)
        end
      end
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(sharedCtx) end
    end
  end)

  cbLumberAutoGoal:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.autoGoal = val
    self.value = val
    if val then
      lumberGoalInput:Disable()
      lumberGoalLabel:SetTextColor(0.5, 0.5, 0.5, 1)
    else
      lumberGoalInput:Enable()
      lumberGoalLabel:SetTextColor(1, 1, 1, 1)
    end
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      LumberList.sharedCtx.autoGoal = val
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(LumberList.sharedCtx) end
    end
  end)

  cbLumberAutoFarm:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.autoStartFarming = val
    self.value = val
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      LumberList.sharedCtx.autoStartFarming = val
    end
  end)

  cbLumberAccountWide:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local val = self:GetChecked() and true or false
    prof.lumberTrack.accountWide = val
    self.value = val
    local AccountWide = NS.UI and NS.UI.LumberTrackAccountWide
    if AccountWide then AccountWide:SetEnabled(val) end
    local LumberList = NS.UI and NS.UI.LumberTrackLumberList
    if LumberList and LumberList.sharedCtx then
      local Render = NS.UI.LumberTrackRender
      if Render and Render.Refresh then Render:Refresh(LumberList.sharedCtx) end
    end
  end)

  if Settings and Settings.RegisterCanvasLayoutSubcategory then
    local lumberCategory = Settings.RegisterCanvasLayoutSubcategory(panel.category, lumberPanel, lumberPanel.name)
    Settings.RegisterAddOnCategory(lumberCategory)
    lumberPanel.category = lumberCategory
  else
    lumberPanel.parent = panel
    local add = _G.InterfaceOptions_AddCategory
    if add then add(lumberPanel) end
  end

  self.lumberPanel = lumberPanel

  
  
  

  local editorPanel = CreateFrame("Frame")
  editorPanel.name = L("OPT_EDITOR_PANEL_NAME")

  
  local editorTitle = editorPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  editorTitle:SetPoint("TOPLEFT", 16, -16)
  editorTitle:SetText(L("OPT_EDITOR_PANEL_NAME"))

  local editorSub = editorPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  editorSub:SetPoint("TOPLEFT", editorTitle, "BOTTOMLEFT", 0, -6)
  editorSub:SetText(L("OPT_EDITOR_SUBTITLE"))

  
  local scrollFrame = CreateFrame("ScrollFrame", nil, editorPanel, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT",     editorPanel, "TOPLEFT",      0,  -55)
  scrollFrame:SetPoint("BOTTOMRIGHT", editorPanel, "BOTTOMRIGHT", -28,   4)

  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetWidth(scrollFrame:GetWidth() or 580)
  scrollChild:SetHeight(1)   
  scrollFrame:SetScrollChild(scrollChild)

  
  scrollFrame:HookScript("OnSizeChanged", function(self)
    scrollChild:SetWidth(self:GetWidth())
  end)

  
  local ey = -8

  
  local genHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  genHeader:SetPoint("TOPLEFT", 16, ey)
  genHeader:SetText(L("OPT_EDITOR_GENERAL"))
  ey = ey - 24

  local cbEditorOn = mkCheckbox(scrollChild, L("OPT_EDITOR_ENABLE"),
    L("OPT_EDITOR_ENABLE_TIP"))
  cbEditorOn:SetPoint("TOPLEFT", 32, ey)
  ey = ey - 34

  local cbHud = mkCheckbox(scrollChild, L("OPT_EDITOR_HUD"),
    L("OPT_EDITOR_HUD_TIP"))
  cbHud:SetPoint("TOPLEFT", 32, ey)
  ey = ey - 34

  
  local clipHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  clipHeader:SetPoint("TOPLEFT", 16, ey)
  clipHeader:SetText(L("OPT_EDITOR_CLIPBOARD"))
  ey = ey - 24

  local cbClipboard = mkCheckbox(scrollChild, L("OPT_EDITOR_CLIPBOARD_CB"),
    L("OPT_EDITOR_CLIPBOARD_TIP"))
  cbClipboard:SetPoint("TOPLEFT", 32, ey)
  ey = ey - 34

  
  local qbHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  qbHeader:SetPoint("TOPLEFT", 16, ey)
  qbHeader:SetText(L("OPT_EDITOR_QUICKBAR"))
  ey = ey - 24

  local cbQuickBar = mkCheckbox(scrollChild, L("OPT_EDITOR_QUICKBAR_CB"),
    L("OPT_EDITOR_QUICKBAR_TIP"))
  cbQuickBar:SetPoint("TOPLEFT", 32, ey)
  ey = ey - 44

  
  local kbHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  kbHeader:SetPoint("TOPLEFT", 16, ey)
  kbHeader:SetText(L("OPT_EDITOR_KEYBINDS"))
  ey = ey - 24

  local kbNote = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  kbNote:SetPoint("TOPLEFT", 32, ey)
  kbNote:SetText(L("OPT_EDITOR_KB_NOTE"))
  ey = ey - 22

  
  
  local function displayKey(binding)
    if not binding or binding == "" then return "—" end
    local s = binding
    s = s:gsub("CTRL%-",  "Ctrl+")
    s = s:gsub("SHIFT%-", "Shift+")
    s = s:gsub("ALT%-",   "Alt+")
    if #s == 1 then s = s:upper() end
    return s
  end

  
  local captureBtn   = nil
  local captureFrame = CreateFrame("Frame", nil, UIParent)
  captureFrame:SetAllPoints(UIParent)
  captureFrame:EnableKeyboard(false)
  captureFrame:SetPropagateKeyboardInput(false)
  captureFrame:Hide()

  local MODIFIERS = {
    LCTRL=true, RCTRL=true, LSHIFT=true, RSHIFT=true,
    LALT=true,  RALT=true,  LMETA=true,  RMETA=true,
  }

  local function stopCapture(restoreLabel)
    if captureBtn then
      if restoreLabel then
        if captureBtn.applyBinding then
          
          local prof = ensureProfile()
          local key  = prof and prof.quickBar.keybinds[captureBtn.slotIndex]
                        or ("F" .. (captureBtn.slotIndex or 1))
          captureBtn:SetText(displayKey(key))
        else
          
          local prof = ensureProfile()
          local key  = prof and prof.editMode.keybinds
                        and prof.editMode.keybinds[captureBtn.action] or ""
          captureBtn:SetText(displayKey(key ~= "" and key or nil))
        end
      end
      captureBtn = nil
    end
    captureFrame:EnableKeyboard(false)
    captureFrame:Hide()
  end

  captureFrame:SetScript("OnKeyDown", function(self, key)
    if not captureBtn then stopCapture(false) return end
    if MODIFIERS[key] then return end

    local binding = ""
    if IsControlKeyDown() then binding = binding .. "CTRL-"  end
    if IsShiftKeyDown()   then binding = binding .. "SHIFT-" end
    if IsAltKeyDown()     then binding = binding .. "ALT-"   end
    binding = binding .. key

    if captureBtn.applyBinding then
      
      if key == "ESCAPE" then
        captureBtn.applyBinding("")
        captureBtn:SetText("—")
      else
        captureBtn.applyBinding(binding)
        captureBtn:SetText(displayKey(binding))
      end
    else
      
      local EM = NS.Systems and NS.Systems.EditMode
      if key == "ESCAPE" then
        if EM then EM.SetKeybind(captureBtn.action, "") end
        local prof = ensureProfile()
        local saved = prof and prof.editMode.keybinds
                      and prof.editMode.keybinds[captureBtn.action] or ""
        captureBtn:SetText(saved ~= "" and displayKey(saved) or "—")
      else
        if EM then EM.SetKeybind(captureBtn.action, binding) end
        local prof  = ensureProfile()
        local saved = prof and prof.editMode.keybinds
                      and prof.editMode.keybinds[captureBtn.action] or binding
        captureBtn:SetText(displayKey(saved ~= "" and saved or nil))
      end
    end
    stopCapture(false)
  end)

  
  local KEYBIND_ACTIONS = {
    { action = "copy",      label = L("OPT_KB_COPY") },
    { action = "cut",       label = L("OPT_KB_CUT") },
    { action = "paste",     label = L("OPT_KB_PASTE") },
    { action = "duplicate", label = L("OPT_KB_DUPLICATE") },
    { action = "lock",   label = L("OPT_KB_LOCK") },
  }

  local kbButtons = {}

  for _, entry in ipairs(KEYBIND_ACTIONS) do
    local rowLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    rowLabel:SetPoint("TOPLEFT", 32, ey)
    rowLabel:SetText(entry.label)
    rowLabel:SetWidth(120)

    local bindBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    bindBtn:SetSize(110, 22)
    bindBtn:SetPoint("LEFT", rowLabel, "RIGHT", 8, 0)
    bindBtn.action = entry.action

    local resetBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    resetBtn:SetSize(60, 22)
    resetBtn:SetPoint("LEFT", bindBtn, "RIGHT", 4, 0)
    resetBtn:SetText(L("RESET"))
    resetBtn:SetScript("OnClick", function()
      local EM = NS.Systems and NS.Systems.EditMode
      if EM then EM.SetKeybind(entry.action, nil) end
      local prof = ensureProfile()
      local key  = prof and prof.editMode.keybinds and prof.editMode.keybinds[entry.action] or ""
      bindBtn:SetText(displayKey(key ~= "" and key or nil))
      if captureBtn == bindBtn then stopCapture(false) end
    end)

    bindBtn:SetScript("OnClick", function(self)
      if captureBtn == self then stopCapture(true) return end
      if captureBtn then stopCapture(true) end
      captureBtn = self
      self:SetText(L("OPT_EDITOR_PRESS_KEY"))
      captureFrame:EnableKeyboard(true)
      captureFrame:Show()
    end)

    table.insert(kbButtons, { btn = bindBtn, action = entry.action })
    ey = ey - 30
  end

  
  ey = ey - 10

  local qbKbHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  qbKbHeader:SetPoint("TOPLEFT", 16, ey)
  qbKbHeader:SetText(L("OPT_EDITOR_QB_KEYBINDS"))
  ey = ey - 20

  local qbKbNote = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  qbKbNote:SetPoint("TOPLEFT", 32, ey)
  qbKbNote:SetText(L("OPT_EDITOR_KB_NOTE"))
  ey = ey - 22

  local qbKbButtons = {}

  for i = 1, 8 do
    local slotLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    slotLabel:SetPoint("TOPLEFT", 32, ey)
    slotLabel:SetText(L("OPT_EDITOR_SLOT") .. " " .. i)
    slotLabel:SetWidth(120)

    local qbBindBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    qbBindBtn:SetSize(110, 22)
    qbBindBtn:SetPoint("LEFT", slotLabel, "RIGHT", 8, 0)
    qbBindBtn.slotIndex = i

    local qbResetBtn = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    qbResetBtn:SetSize(60, 22)
    qbResetBtn:SetPoint("LEFT", qbBindBtn, "RIGHT", 4, 0)
    qbResetBtn:SetText(L("RESET"))
    qbResetBtn:SetScript("OnClick", function()
      local QB = NS.Systems and NS.Systems.QuickBar
      if QB and QB.Keys then QB.Keys.SetKeybind(i, nil) end
      local prof = ensureProfile()
      local key  = prof and prof.quickBar.keybinds and prof.quickBar.keybinds[i] or ("F" .. i)
      qbBindBtn:SetText(displayKey(key))
      if captureBtn == qbBindBtn then stopCapture(false) end
    end)

    qbBindBtn:SetScript("OnClick", function(self)
      if captureBtn == self then stopCapture(true) return end
      if captureBtn then stopCapture(true) end
      captureBtn = self
      self:SetText(L("OPT_EDITOR_PRESS_KEY"))
      captureFrame:EnableKeyboard(true)
      captureFrame:Show()
    end)

    qbBindBtn.applyBinding = function(binding)
      local QB = NS.Systems and NS.Systems.QuickBar
      if QB and QB.Keys then
        QB.Keys.SetKeybind(i, (binding ~= "" and binding or nil))
      end
      local prof = ensureProfile()
      local key  = prof and prof.quickBar.keybinds and prof.quickBar.keybinds[i] or ("F" .. i)
      qbBindBtn:SetText(displayKey(key))
    end

    table.insert(qbKbButtons, { btn = qbBindBtn, slotIndex = i })
    ey = ey - 30
  end

  
  ey = ey - 10

  local conflictHeader = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  conflictHeader:SetPoint("TOPLEFT", 16, ey)
  conflictHeader:SetText(L("OPT_EDITOR_CONFLICTS"))
  ey = ey - 20

  local conflictNote = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  conflictNote:SetPoint("TOPLEFT", 32, ey)
  conflictNote:SetText(L("OPT_EDITOR_CONFLICTS_NOTE"))
  ey = ey - 22

  
  local CONFLICT_FEATURES = { "QuickBar", "Recent", "Keybinds", "ModeBar" }
  local FEATURE_LABELS_UI = {
    QuickBar = L("OPT_EDITOR_QUICKBAR"),
    Recent   = L("OPT_EDITOR_RECENT"),
    Keybinds = L("OPT_EDITOR_KEYBINDS"),
    ModeBar  = L("OPT_EDITOR_MODEBAR"),
  }

  
  local function getConflictAddonTitle()
    local addons = {
      { id = "HousingCompanion",         title = "Housing Companion" },
      { id = "AdvancedDecorationTools",  title = "Adv. Decoration Tools" },
    }
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded
    for _, a in ipairs(addons) do
      if isLoaded and isLoaded(a.id) then return a.title, a.id end
    end
    return nil, nil
  end

  
  local conflictRows = {}
  local conflictNoConflictLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  conflictNoConflictLabel:SetPoint("TOPLEFT", 32, ey)
  conflictNoConflictLabel:SetText(L("OPT_EDITOR_NO_CONFLICTS"))
  conflictNoConflictLabel:SetTextColor(0.5, 0.5, 0.5)
  ey = ey - 26

  for _, feature in ipairs(CONFLICT_FEATURES) do
    local rowY = ey

    local fLabel = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fLabel:SetPoint("TOPLEFT", 32, rowY)
    fLabel:SetText(FEATURE_LABELS_UI[feature] or feature)
    fLabel:SetWidth(90)

    local btnHD = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    btnHD:SetSize(100, 22)
    btnHD:SetPoint("LEFT", fLabel, "RIGHT", 6, 0)
    btnHD:SetText(L("ADDON_NAME"))

    local btnOther = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
    btnOther:SetSize(140, 22)
    btnOther:SetPoint("LEFT", btnHD, "RIGHT", 4, 0)
    btnOther:SetText(L("OPT_EDITOR_OTHER_ADDON"))  

    local statusText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    statusText:SetPoint("LEFT", btnOther, "RIGHT", 8, 0)
    statusText:SetWidth(100)

    
    
    local function applyAllOwners(owner)
      local prof = ensureProfile()
      if not prof then return end
      prof.addonConflict = prof.addonConflict or {}
      for _, f in ipairs(CONFLICT_FEATURES) do
        prof.addonConflict[f] = owner
      end
    end

    
    local function disableAllHDFeatures()
      local EM = NS.Systems and NS.Systems.EditMode
      if EM then
        local db = EM.DB()
        db.on         = false
        db.hud        = false
        db.clipboard  = false
        db.batchPlace = false
        db.lock       = false
        db.rotPanel   = false
        if HouseEditorFrame and HouseEditorFrame:IsShown() then
          if EM.HUD    and EM.HUD.Destroy        then EM.HUD.Destroy()     end
          if EM.RotPanel and EM.RotPanel.Hide    then EM.RotPanel.Hide()   end
          if EM.Keys   and EM.Keys.Clear         then EM.Keys.Clear()      end
          if EM.Batch  and EM.Batch.Reset        then EM.Batch.Reset()     end
        end
      end
      local prof = ensureProfile()
      if prof then
        prof.quickBar         = prof.quickBar or {}
        prof.quickBar.enabled = false
      end
      local QB = NS.Systems and NS.Systems.QuickBar
      if QB then
        if QB.UI   and QB.UI.Hide        then QB.UI:Hide()    end
        if QB.Keys and QB.Keys.Clear     then QB.Keys.Clear() end
      end
      cbEditorOn:SetChecked(false)
      cbHud:SetChecked(false)
      cbClipboard:SetChecked(false)
      cbQuickBar:SetChecked(false)
    end

    
    local function enableAllHDFeatures()
      local EM = NS.Systems and NS.Systems.EditMode
      if EM then
        local db = EM.DB()
        db.on         = true
        db.hud        = true
        db.clipboard  = true
        db.batchPlace = true
        db.lock       = true
        db.rotPanel   = true
        if HouseEditorFrame and HouseEditorFrame:IsShown() then
          if EM.HUD    and EM.HUD.Boot           then EM.HUD.Boot()        end
          if EM.RotPanel and EM.RotPanel.Boot    then EM.RotPanel.Boot()   end
          if EM.Keys   and EM.Keys.Apply         then EM.Keys.Apply()      end
          if EM.HUD    and EM.HUD.Refresh        then EM.HUD.Refresh()     end
        end
      end
      local prof = ensureProfile()
      if prof then
        prof.quickBar         = prof.quickBar or {}
        prof.quickBar.enabled = true
      end
      local QB = NS.Systems and NS.Systems.QuickBar
      if QB and HouseEditorFrame and HouseEditorFrame:IsShown() then
        if QB.UI   and QB.UI.Show         then QB.UI:Show()      end
        if QB.Keys and QB.Keys.Apply      then QB.Keys.Apply()   end
      end
      cbEditorOn:SetChecked(true)
      cbHud:SetChecked(true)
      cbClipboard:SetChecked(true)
      cbQuickBar:SetChecked(true)
    end

    btnHD:SetScript("OnClick", function()
      applyAllOwners("HomeDecor")
      enableAllHDFeatures()
      
      for _, row in ipairs(conflictRows) do
        row.statusText:SetText("|cff00ff00Active|r")
      end
    end)

    btnOther:SetScript("OnClick", function()
      local _, conflictId = getConflictAddonTitle()
      if not conflictId then return end
      applyAllOwners(conflictId)
      disableAllHDFeatures()
      
      for _, row in ipairs(conflictRows) do
        row.statusText:SetText("|cffffff00Yielded|r")
      end
    end)

    table.insert(conflictRows, {
      feature    = feature,
      fLabel     = fLabel,
      btnHD      = btnHD,
      btnOther   = btnOther,
      statusText = statusText,
    })

    ey = ey - 30
  end

  
  scrollChild:SetHeight(math.abs(ey) + 20)

  
  
  
  local function syncEditorFromDB()
    local prof = ensureProfile()
    if not prof then return end

    local db = prof.editMode

    cbEditorOn:SetChecked(db.on ~= false)
    cbHud:SetChecked(db.hud ~= false)
    cbClipboard:SetChecked(
      db.clipboard ~= false and db.batchPlace ~= false
      and db.lock ~= false and db.rotPanel ~= false
    )
    cbQuickBar:SetChecked(prof.quickBar.enabled ~= false)

    
    for _, entry in ipairs(kbButtons) do
      local key = (db.keybinds and db.keybinds[entry.action]) or ""
      entry.btn:SetText(displayKey(key ~= "" and key or nil))
    end

    
    for _, entry in ipairs(qbKbButtons) do
      local key = prof.quickBar.keybinds[entry.slotIndex] or ("F" .. entry.slotIndex)
      entry.btn:SetText(displayKey(key))
    end

    if captureBtn then stopCapture(true) end

    
    local conflictTitle, conflictId = getConflictAddonTitle()
    local hasConflict = conflictTitle ~= nil

    conflictNoConflictLabel:SetShown(not hasConflict)

    for _, row in ipairs(conflictRows) do
      row.fLabel:SetShown(hasConflict)
      row.btnHD:SetShown(hasConflict)
      row.btnOther:SetShown(hasConflict)
      row.statusText:SetShown(hasConflict)

      if hasConflict then
        
        row.btnOther:SetText(conflictTitle)

        local owner = prof.addonConflict and prof.addonConflict[row.feature]
        if owner == nil then
          row.btnHD:SetText(L("ADDON_NAME"))
          row.statusText:SetText("|cffaaaaaa Undecided|r")
        elseif owner == "HomeDecor" then
          row.btnHD:SetText(L("ADDON_NAME"))
          row.statusText:SetText("|cff00ff00Active|r")
        else
          row.btnHD:SetText(L("ADDON_NAME"))
          row.statusText:SetText("|cffffff00Yielded|r")
        end
      end
    end

    
    scrollFrame:SetVerticalScroll(0)
  end

  editorPanel:SetScript("OnShow", syncEditorFromDB)

  local editorSettingsFrame = _G.SettingsPanel or _G.InterfaceOptionsFrame
  if editorSettingsFrame and editorSettingsFrame.HookScript then
    editorSettingsFrame:HookScript("OnShow", syncEditorFromDB)
  end

  if Settings and Settings.OpenToCategory then
    hooksecurefunc(Settings, "OpenToCategory", function()
      C_Timer.After(0, syncEditorFromDB)
    end)
  end

  

  cbEditorOn:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    local EM  = NS.Systems and NS.Systems.EditMode
    if not EM then
      
      local prof = ensureProfile()
      if prof then prof.editMode.on = val end
      return
    end
    EM.DB().on = val
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
      if val then
        EM.HUD.Boot(); EM.RotPanel.Boot(); EM.Keys.Apply()
      else
        EM.HUD.Destroy(); EM.RotPanel.Hide(); EM.Keys.Clear()
      end
    end
  end)

  cbHud:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    local EM  = NS.Systems and NS.Systems.EditMode
    if not EM then
      local prof = ensureProfile()
      if prof then prof.editMode.hud = val end
      return
    end
    EM.DB().hud = val
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
      if val then EM.HUD.Boot(); EM.HUD.Refresh()
      else        EM.HUD.Destroy() end
    end
  end)

  cbClipboard:SetScript("OnClick", function(self)
    local val = self:GetChecked() and true or false
    local EM  = NS.Systems and NS.Systems.EditMode
    if not EM then
      local prof = ensureProfile()
      if prof then
        prof.editMode.clipboard  = val
        prof.editMode.batchPlace = val
        prof.editMode.lock       = val
        prof.editMode.rotPanel   = val
      end
      return
    end
    local db = EM.DB()
    db.clipboard  = val
    db.batchPlace = val
    db.lock       = val
    db.rotPanel   = val
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
      if val then
        EM.Keys.Apply(); EM.RotPanel.Boot()
      else
        EM.Keys.Clear()
        if EM.Batch and EM.Batch.Reset then EM.Batch.Reset() end
        if EM.RotPanel and EM.RotPanel.Hide then EM.RotPanel.Hide() end
      end
      if EM.HUD and EM.HUD.Refresh then EM.HUD.Refresh() end
    end
  end)

  cbQuickBar:SetScript("OnClick", function(self)
    local val  = self:GetChecked() and true or false
    local prof = NS.db and NS.db.profile
    if prof then
      prof.quickBar         = prof.quickBar or {}
      prof.quickBar.enabled = val
    end
    if HouseEditorFrame and HouseEditorFrame:IsShown() then
      local QB = NS.Systems and NS.Systems.QuickBar
      if QB and QB.UI then
        if val then QB.UI:Show() else QB.UI:Hide() end
      end
    end
  end)

  if Settings and Settings.RegisterCanvasLayoutSubcategory then
    local editorCategory = Settings.RegisterCanvasLayoutSubcategory(panel.category, editorPanel, editorPanel.name)
    Settings.RegisterAddOnCategory(editorCategory)
    editorPanel.category = editorCategory
  else
    editorPanel.parent = panel
    local add = _G.InterfaceOptions_AddCategory
    if add then add(editorPanel) end
  end

  self.editorPanel = editorPanel
end

function Options:Open()
  self:Ensure()
  openCategoryFrame(self.panel)
end

return Options
