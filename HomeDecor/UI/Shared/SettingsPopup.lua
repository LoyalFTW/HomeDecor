local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.SettingsPopup = NS.UI.SettingsPopup or {}
local Popup = NS.UI.SettingsPopup

local C = NS.UI.Controls
local Theme = NS.UI.Theme
local CreateFrame = CreateFrame
local unpack = unpack or table.unpack
local floor = math.floor

local function T()
  return Theme and Theme.colors or {}
end

local function ensureAppearance()
  local profile = NS.db and NS.db.profile
  if not profile then return nil, nil end
  profile.ui = profile.ui or {}
  profile.ui.appearance = profile.ui.appearance or {}
  local appearance = profile.ui.appearance
  if appearance.fontMedia == nil then
    appearance.fontMedia = Theme.MEDIA_DEFAULT_TOKEN
  end
  if appearance.fontScale == nil then appearance.fontScale = 1.0 end
  appearance.colors = appearance.colors or {}

  profile.filters = profile.filters or {}
  profile.mapPins = profile.mapPins or {}
  profile.minimap = profile.minimap or { hide = false }
  profile.tracker = profile.tracker or {}
  if profile.mapPins.minimap == nil then profile.mapPins.minimap = true end
  if profile.mapPins.worldmap == nil then profile.mapPins.worldmap = true end
  if profile.tracker.showFavoritesOnZoneEnter == nil then
    profile.tracker.showFavoritesOnZoneEnter = true
  end
  return profile, appearance
end

local function backdrop(frame, bg, border)
  if C and C.Backdrop then C:Backdrop(frame, bg, border) end
end

local function hover(frame, normal, over, border, borderOver)
  if C and C.ApplyHover then C:ApplyHover(frame, normal, over, border, borderOver) end
end

local function newText(parent, template, text, role)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  fs:SetText(text or "")
  if C and C.TextColor then C:TextColor(fs, role or "text") end
  return fs
end

local function refreshPins()
  local pins = NS.Systems and NS.Systems.MapPins
  if not pins then return end
  if pins.RefreshCurrentZone then pcall(function() pins:RefreshCurrentZone() end) end
  if pins.RefreshWorldMap then pcall(function() pins:RefreshWorldMap() end) end
end

function Popup:Apply(root, refreshColors)
  local _, appearance = ensureAppearance()
  if not appearance then return end
  if Theme and Theme.ApplyProfile then Theme:ApplyProfile() end
  if refreshColors and C and C.RefreshRegisteredBorders then
    C:RefreshRegisteredBorders()
  end

  local UI = NS.UI or {}
  local main = root or UI.MainFrame
  local seen = {}
  local function refreshFrame(frame)
    if not frame or seen[frame] or not C or not C.RefreshAppearance then return end
    seen[frame] = true
    C:RefreshAppearance(frame, refreshColors and true or false)
    if not refreshColors then return end
    if frame.settings then C:RefreshAppearance(frame.settings, true) end
    if frame.settingsPopup then C:RefreshAppearance(frame.settingsPopup, true) end
    if frame.legacySettings then C:RefreshAppearance(frame.legacySettings, true) end
  end

  refreshFrame(main)
  if main and main.view and main.view.Render then
    main.view:Render()
    if C and C.RefreshAppearance then C:RefreshAppearance(main, false) end
  end

  refreshFrame(UI.CompactMode and UI.CompactMode.frame)
  refreshFrame(UI.Tracker and UI.Tracker.frame)
  refreshFrame(UI.MapPopup and UI.MapPopup.frame)
  refreshFrame(UI.VendorAssistant and UI.VendorAssistant.frame)
  refreshFrame(UI.GatherTrackList and UI.GatherTrackList.frame)
  refreshFrame(UI.GatherTrackList and UI.GatherTrackList.settings)
  refreshFrame(UI.GatherTrackMiniPanels and UI.GatherTrackMiniPanels.frame)
  refreshFrame(UI.GatherTrackMiniFarmingPanels and UI.GatherTrackMiniFarmingPanels.frame)
  refreshFrame(UI.DecorAH and UI.DecorAH.frame)
  refreshFrame(UI.DecorAH_Queue and UI.DecorAH_Queue.frame)
  refreshFrame(UI.DecorAH_SalesPanel and UI.DecorAH_SalesPanel.frame)
  refreshFrame(UI.AltsProfessions and UI.AltsProfessions.frame)
  refreshFrame(_G.HomeDecorChangelogPopup)
  refreshFrame(self.frame)
end

local function makeButton(parent, text, width)
  local colors = T()
  local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
  backdrop(button, colors.panel, colors.border)
  button:SetSize(width or 120, 24)
  hover(button, colors.panel, colors.hover, colors.border, colors.accentSoft)
  button.text = newText(button, "GameFontNormal", text, "text")
  button.text:SetPoint("CENTER")
  return button
end

local function makeCheck(parent, text, onClick)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  cb.label = newText(cb, "GameFontHighlight", text, "text")
  cb.label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  cb:SetScript("OnClick", function(self)
    onClick(self:GetChecked() and true or false)
  end)
  return cb
end

local function makeSlider(parent, text, minimum, maximum, step, formatter, onChange, applyOnRelease)
  local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
  slider:SetSize(190, 16)
  slider:SetMinMaxValues(minimum, maximum)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  slider.label = newText(parent, "GameFontHighlight", text, "text")
  slider.label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
  slider.value = newText(parent, "GameFontNormalSmall", "", "accent")
  slider.value:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", 0, 4)
  if slider.Low then slider.Low:SetText("") end
  if slider.High then slider.High:SetText("") end
  slider:SetScript("OnValueChanged", function(self, value)
    value = floor((value / step) + 0.5) * step
    self.value:SetText(formatter(value))
    if not Popup._syncing and not applyOnRelease then onChange(value) end
  end)
  if applyOnRelease then
    slider:SetScript("OnMouseUp", function(self)
      if Popup._syncing then return end
      local value = floor(((self:GetValue() or minimum) / step) + 0.5) * step
      onChange(value)
      Popup:Sync()
    end)
  end
  return slider
end

local function makeSwatch(parent, text, key)
  local colors = T()
  local row = CreateFrame("Frame", nil, parent)
  row:SetSize(224, 28)
  row.label = newText(row, "GameFontHighlight", text, "text")
  row.label:SetPoint("LEFT", 0, 0)

  local button = CreateFrame("Button", nil, row, "BackdropTemplate")
  backdrop(button, colors.panel, colors.border)
  button:SetSize(27, 22)
  button:SetPoint("RIGHT", row, "RIGHT", 0, 0)
  button.fill = button:CreateTexture(nil, "ARTWORK")
  button.fill:SetPoint("TOPLEFT", 3, -3)
  button.fill:SetPoint("BOTTOMRIGHT", -3, 3)

  button:SetScript("OnClick", function()
    if not ColorPickerFrame then return end
    local current = T()[key]
    local info = { r = current[1], g = current[2], b = current[3], hasOpacity = false }
    info.swatchFunc = function()
      local r, g, b = ColorPickerFrame:GetColorRGB()
      Theme:SetColor(key, r, g, b)
      Popup:Apply(nil, true)
      Popup:Sync()
    end
    info.cancelFunc = function(previous)
      Theme:SetColor(key, previous.r, previous.g, previous.b)
      Popup:Apply(nil, true)
      Popup:Sync()
    end
    ColorPickerFrame:SetupColorPickerAndShow(info)
    ColorPickerFrame:SetFrameStrata("TOOLTIP")
    ColorPickerFrame:SetFrameLevel((Popup.frame and Popup.frame:GetFrameLevel() or 300) + 100)
    ColorPickerFrame:Raise()
  end)

  row.swatch = button
  row.key = key
  return row
end

function Popup:Sync()
  if not self.frame then return end
  local profile, appearance = ensureAppearance()
  if not profile then return end

  local controls = self.controls
  controls.showMinimap:SetChecked(profile.minimap.hide ~= true)
  controls.miniPins:SetChecked(profile.mapPins.minimap == true)
  controls.worldPins:SetChecked(profile.mapPins.worldmap == true)
  controls.hideCollected:SetChecked(profile.filters.hideCollected == true)
  controls.favorites:SetChecked(profile.tracker.showFavoritesOnZoneEnter ~= false)
  controls.compact:SetChecked(profile.ui.compactMode == true)

  self._syncing = true
  local sizeControl = NS.UI.ResizeBar
  local root = NS.UI.MainFrame
  controls.size:SetValue(sizeControl and sizeControl:GetDisplayValue(root) or 100)
  controls.fontScale:SetValue(appearance.fontScale or 1)
  self._syncing = false
  if controls.fontDropdown and controls.fontDropdown.ApplyText then
    controls.fontDropdown:ApplyText("Game Default")
  end
  for _, swatch in ipairs(controls.swatches) do
    local color = T()[swatch.key]
    swatch.swatch.fill:SetColorTexture(color[1], color[2], color[3], 1)
  end
end

function Popup:Create(owner)
  if self.frame then return self.frame end
  local colors = T()
  local panel = CreateFrame("Frame", "HomeDecorSettingsPopup", UIParent, "BackdropTemplate")
  self.frame = panel
  self.controls = { swatches = {} }

  panel:SetSize(552, 626)
  panel:SetFrameStrata("FULLSCREEN_DIALOG")
  panel:SetFrameLevel(300)
  panel:SetClampedToScreen(true)
  panel:EnableMouse(true)
  backdrop(panel, colors.bg, colors.border)

  local header = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(44)
  backdrop(header, colors.header, colors.border)

  local title = newText(header, "GameFontNormalLarge", "HomeDecor Settings", "accent")
  title:SetPoint("LEFT", 14, 6)
  local subtitle = newText(header, "GameFontHighlightSmall", "Quick controls and appearance", "textMuted")
  subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)

  local close = makeButton(header, "X", 24)
  close:SetPoint("RIGHT", -10, 0)
  if C and C.TextColor then C:TextColor(close.text, "accent") end
  close:SetScript("OnClick", function() panel:Hide() end)

  local appearanceTitle = newText(panel, "GameFontNormal", "Appearance", "accent")
  appearanceTitle:SetPoint("TOPLEFT", 20, -68)

  local size = makeSlider(panel, "Window Size", 0, 200, 5,
    function(value) return tostring(value) end,
    function(value)
      local resize = NS.UI and NS.UI.ResizeBar
      if resize then resize:SetDisplayValue(NS.UI.MainFrame, value) end
    end,
    true)
  self.controls.size = size
  size:SetPoint("TOPLEFT", 22, -112)

  local fontScale = makeSlider(panel, "Font Size", 0.80, 1.35, 0.05,
    function(value) return string.format("%d%%", value * 100) end,
    function(value)
      local _, appearance = ensureAppearance()
      if not appearance then return end
      appearance.fontScale = value
      Popup:Apply()
    end)
  self.controls.fontScale = fontScale
  fontScale:SetPoint("TOPLEFT", 300, -112)

  local fontLabel = newText(panel, "GameFontHighlight", "Font", "text")
  fontLabel:SetPoint("TOPLEFT", 22, -153)
  local dropdownFactory = NS.UI and NS.UI.Dropdown
  if dropdownFactory and dropdownFactory.Create then
    local dropdown = dropdownFactory.Create(
      panel, "", nil, 190,
      function()
        local _, appearance = ensureAppearance()
        return appearance and appearance.fontMedia or Theme.MEDIA_DEFAULT_TOKEN
      end,
      function(value)
        Theme:SetFont(value)
        Popup:Apply()
      end,
      function() return Theme:GetFontOptions() end,
      nil, C, colors
    )
    dropdown:SetSize(190, 24)
    dropdown:SetPoint("TOPLEFT", 22, -176)
    if dropdown.list then dropdown.list:SetFrameLevel(panel:GetFrameLevel() + 20) end
    if dropdown.sub then dropdown.sub:SetFrameLevel(panel:GetFrameLevel() + 21) end
    if dropdown._catcher then dropdown._catcher:SetFrameLevel(panel:GetFrameLevel() - 1) end
    self.controls.fontDropdown = dropdown
  end

  local reset = makeButton(panel, "Reset Appearance", 190)
  reset:SetPoint("TOPLEFT", 22, -211)
  reset:SetScript("OnClick", function()
    Theme:ResetAppearance()
    Popup:Apply(nil, true)
    Popup:Sync()
  end)

  local swatchData = {
    { "Accent Color", "accent" },
    { "Text Color", "text" },
    { "Highlight Color", "highlight" },
    { "Border Color", "border" },
    { "Background Color", "bg" },
    { "Panel Color", "panel" },
  }
  for i, entry in ipairs(swatchData) do
    local swatch = makeSwatch(panel, entry[1], entry[2])
    swatch:SetPoint("TOPLEFT", 300, -151 - ((i - 1) * 31))
    self.controls.swatches[#self.controls.swatches + 1] = swatch
  end

  local divider = panel:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1, 1, 1, 0.12)
  divider:SetHeight(1)
  divider:SetPoint("TOPLEFT", 20, -353)
  divider:SetPoint("TOPRIGHT", -20, -353)

  local quickTitle = newText(panel, "GameFontNormal", "Quick Options", "accent")
  quickTitle:SetPoint("TOPLEFT", 20, -372)

  local showMinimap = makeCheck(panel, "Show minimap button", function(value)
    if NS.UI.SetMinimapHidden then NS.UI.SetMinimapHidden(NS.db, not value) end
  end)
  self.controls.showMinimap = showMinimap
  showMinimap:SetPoint("TOPLEFT", 20, -402)

  local miniPins = makeCheck(panel, "Minimap decor pins", function(value)
    local profile = ensureAppearance()
    profile.mapPins.minimap = value
    refreshPins()
  end)
  self.controls.miniPins = miniPins
  miniPins:SetPoint("TOPLEFT", 20, -434)

  local worldPins = makeCheck(panel, "World map decor pins", function(value)
    local profile = ensureAppearance()
    profile.mapPins.worldmap = value
    refreshPins()
  end)
  self.controls.worldPins = worldPins
  worldPins:SetPoint("TOPLEFT", 20, -466)

  local hideCollected = makeCheck(panel, "Hide collected decor", function(value)
    local profile = ensureAppearance()
    profile.filters.hideCollected = value
    if NS.UI.MainFrame and NS.UI.MainFrame.view and NS.UI.MainFrame.view.Render then
      NS.UI.MainFrame.view:Render()
    end
  end)
  self.controls.hideCollected = hideCollected
  hideCollected:SetPoint("TOPLEFT", 292, -402)

  local favorites = makeCheck(panel, "Zone favorite alerts", function(value)
    local profile = ensureAppearance()
    profile.tracker.showFavoritesOnZoneEnter = value
  end)
  self.controls.favorites = favorites
  favorites:SetPoint("TOPLEFT", 292, -434)

  local compact = makeCheck(panel, "Open in compact mode", function(value)
    local profile = ensureAppearance()
    profile.ui.compactMode = value
  end)
  self.controls.compact = compact
  compact:SetPoint("TOPLEFT", 292, -466)

  local note = newText(panel, "GameFontHighlightSmall",
    "More controls for vendors, gathering, map pins and edit mode are available in Full Options.",
    "textMuted")
  note:SetWidth(510)
  note:SetJustifyH("LEFT")
  note:SetWordWrap(true)
  note:SetPoint("TOPLEFT", 20, -514)

  local full = makeButton(panel, "Full Options", 244)
  full:SetPoint("BOTTOMLEFT", 20, 20)
  full:SetScript("OnClick", function()
    panel:Hide()
    if NS.UI.Options and NS.UI.Options.Open then NS.UI.Options:Open() end
  end)

  local done = makeButton(panel, "Done", 244)
  done:SetPoint("BOTTOMRIGHT", -20, 20)
  done:SetScript("OnClick", function() panel:Hide() end)

  if UISpecialFrames then table.insert(UISpecialFrames, "HomeDecorSettingsPopup") end
  if owner and not owner.__hdSettingsHideHook then
    owner.__hdSettingsHideHook = true
    owner:HookScript("OnHide", function() panel:Hide() end)
  end
  panel:Hide()
  return panel
end

function Popup:Toggle(owner, anchor)
  local panel = self:Create(owner)
  if panel:IsShown() then
    panel:Hide()
    return
  end
  panel:ClearAllPoints()
  if anchor then
    panel:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 8, -8)
  else
    panel:SetPoint("CENTER")
  end
  self:Sync()
  self:Apply(owner)
  panel:Show()
end

return Popup
