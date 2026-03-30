local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}

local Settings = {}
NS.UI.GatherTrackSettings = Settings
local Utils = NS.GT.Utils

local CreateFrame = CreateFrame
local unpack = _G.unpack or table.unpack
local GameTooltip = GameTooltip

local function RefreshAll(sharedCtx)
  local Render = NS.UI.GatherTrackRender
  if Render and Render.Refresh then
    Render:Refresh(sharedCtx)
  end

  local GatherTrack = NS.UI.GatherTrackMini
  if GatherTrack and GatherTrack.RefreshAll then
    GatherTrack:RefreshAll(sharedCtx)
  end
end

local function CreateCheckbox(parent, x, y, label, tooltipText)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

  local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
  lbl:SetText(label)
  cb.label = lbl

  if tooltipText then
    cb:SetScript("OnEnter", function(self)
      if GameTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        GameTooltip:AddLine(tooltipText, 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
      end
    end)
    cb:SetScript("OnLeave", function()
      if GameTooltip then GameTooltip:Hide() end
    end)
  end

  return cb
end

local function CreateSectionLabel(parent, x, y, text, accent)
  local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  label:SetText(text)
  label:SetTextColor(unpack(accent or { 1, 0.82, 0.2, 1 }))

  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetPoint("LEFT", label, "RIGHT", 8, 0)
  line:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
  line:SetHeight(1)
  line:SetColorTexture(1, 1, 1, 0.12)

  return label, line
end

local function CreateCard(parent, x, y, width, height, title, theme)
  local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  card:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  card:SetSize(width, height)
  Utils.CreateBackdrop(card, theme.row or { 0.12, 0.12, 0.14, 1 }, theme.border)

  card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  card.title:SetPoint("TOPLEFT", 10, -8)
  card.title:SetText(title)
  card.title:SetTextColor(unpack(theme.accent or { 1, 0.82, 0.2, 1 }))

  card.line = card:CreateTexture(nil, "ARTWORK")
  card.line:SetPoint("TOPLEFT", card, "TOPLEFT", 10, -24)
  card.line:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, -24)
  card.line:SetHeight(1)
  card.line:SetColorTexture(1, 1, 1, 0.10)

  return card
end

function Settings:CreatePanel(parent, sharedCtx, onAlphaChange)
  if not parent then return nil end

  local db = Utils.GetDB()
  local T = Utils.GetTheme()

  local settings = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  settings:SetFrameStrata("DIALOG")
  settings:SetFrameLevel(parent:GetFrameLevel() + 20)
  settings:SetSize(382, 340)
  settings:SetPoint("CENTER", parent, "CENTER", 0, 0)
  settings:Hide()
  settings:EnableMouse(true)
  Utils.CreateBackdrop(settings, T.panel, T.border)

  local header = CreateFrame("Frame", nil, settings, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(26)
  Utils.CreateBackdrop(header, T.row or { 0.12, 0.12, 0.14, 1 }, T.border)

  local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("LEFT", 10, 0)
  title:SetText("Gather Options")
  title:SetTextColor(unpack(T.accent or {1, 0.82, 0.2, 1}))

  local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  closeBtn:SetSize(18, 18)
  closeBtn:SetPoint("RIGHT", -4, 0)
  Utils.CreateBackdrop(closeBtn, T.row or { 0.12, 0.12, 0.14, 1 }, T.border)
  closeBtn.txt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  closeBtn.txt:SetPoint("CENTER")
  closeBtn.txt:SetText("x")
  closeBtn:SetScript("OnClick", function()
    settings:Hide()
  end)

  local doneBtn = CreateFrame("Button", nil, settings, "BackdropTemplate")
  doneBtn:SetSize(52, 18)
  doneBtn:SetPoint("BOTTOMRIGHT", -10, 10)
  Utils.CreateBackdrop(doneBtn, T.row or { 0.12, 0.12, 0.14, 1 }, T.border)
  doneBtn.txt = doneBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  doneBtn.txt:SetPoint("CENTER")
  doneBtn.txt:SetText("Done")
  doneBtn:SetScript("OnClick", function()
    settings:Hide()
  end)

  settings:SetScript("OnMouseDown", function(_, button)
    if button == "RightButton" then
      settings:Hide()
    end
  end)

  local body = CreateFrame("Frame", nil, settings)
  body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -12)
  body:SetPoint("BOTTOMRIGHT", settings, "BOTTOMRIGHT", -16, 38)
  settings.body = body

  local leftX, rightX = 0, 170
  local topY = 0

  local displayCard = CreateCard(body, leftX, topY, 158, 72, "Display", T)
  local materialCard = CreateCard(body, leftX, -82, 158, 110, "Materials", T)
  local behaviorCard = CreateCard(body, rightX, topY, 168, 146, "Behavior", T)
  local goalsCard = CreateCard(body, leftX, -202, 158, 78, "Goal", T)
  local appearanceCard = CreateCard(body, rightX, -156, 168, 76, "Appearance", T)

  local iconsCB = CreateCheckbox(displayCard, 10, -30, L["LUMBER_SHOW_ICONS"])
  iconsCB:SetChecked(sharedCtx and sharedCtx.showIcons ~= false or true)
  iconsCB:SetScript("OnClick", function(self)
    if sharedCtx then
      sharedCtx.showIcons = self:GetChecked() and true or false
      if db then db.showIcons = sharedCtx.showIcons end
      RefreshAll(sharedCtx)
      local Rows = NS.UI.GatherTrackRows
      if Rows and Rows.Reflow then
        C_Timer.After(0.1, function() Rows:Reflow(sharedCtx) end)
      end
    end
  end)
  iconsCB.label:SetWidth(112)

  local hideCB = CreateCheckbox(displayCard, 10, -52, L["LUMBER_HIDE_ZERO"])
  hideCB:SetChecked(sharedCtx and sharedCtx.hideZero and true or false)
  hideCB:SetScript("OnClick", function(self)
    if sharedCtx then
      sharedCtx.hideZero = self:GetChecked() and true or false
      if db then db.hideZero = sharedCtx.hideZero end
      RefreshAll(sharedCtx)
    end
  end)
  hideCB.label:SetWidth(112)

  local trackLumberCB = CreateCheckbox(materialCard, 10, -30, L["LUMBER_TRACK_LUMBER"] or "Track Lumber",
    L["LUMBER_TRACK_LUMBER_TIP"] or "Show lumber in the tracker.")
  trackLumberCB:SetChecked(sharedCtx and sharedCtx.trackLumber ~= false or (db and db.trackLumber ~= false))
  trackLumberCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if sharedCtx then sharedCtx.trackLumber = checked end
    if db then db.trackLumber = checked end
    RefreshAll(sharedCtx)
  end)
  trackLumberCB.label:SetWidth(112)

  local trackOreCB = CreateCheckbox(materialCard, 10, -52, L["LUMBER_TRACK_ORE"] or "Track Ore",
    L["LUMBER_TRACK_ORE_TIP"] or "Show mining ore and stone in the tracker.")
  trackOreCB:SetChecked(sharedCtx and sharedCtx.trackOre and true or false)
  trackOreCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if sharedCtx then sharedCtx.trackOre = checked end
    if db then db.trackOre = checked end
    RefreshAll(sharedCtx)
  end)
  trackOreCB.label:SetWidth(112)

  local trackHerbsCB = CreateCheckbox(materialCard, 10, -74, L["LUMBER_TRACK_HERBS"] or "Track Herbs",
    L["LUMBER_TRACK_HERBS_TIP"] or "Show herbs in the tracker.")
  trackHerbsCB:SetChecked(sharedCtx and sharedCtx.trackHerbs and true or false)
  trackHerbsCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if sharedCtx then sharedCtx.trackHerbs = checked end
    if db then db.trackHerbs = checked end
    RefreshAll(sharedCtx)
  end)
  trackHerbsCB.label:SetWidth(112)

  local compactCB = CreateCheckbox(behaviorCard, 10, -30, L["LUMBER_COMPACT_MODE"],
    L["LUMBER_COMPACT_TIP"])
  compactCB:SetChecked(sharedCtx and sharedCtx.compactMode and true or false)
  compactCB:SetScript("OnClick", function(self)
    if sharedCtx then
      local newVal = self:GetChecked() and true or false
      sharedCtx.compactMode = newVal
      if db then db.compactMode = newVal end
      if sharedCtx.rows then
        for i, row in pairs(sharedCtx.rows) do
          if row then row:Hide(); row:SetParent(nil) end
          sharedCtx.rows[i] = nil
        end
      end
      local LumberList = NS.UI.GatherTrackList
      if LumberList and LumberList.compactBtn then
        local Tx = Utils.GetTheme()
        if newVal then
          LumberList.compactBtn:SetBackdropBorderColor(unpack(Tx.accentBright or Tx.accent))
          LumberList.compactBtn.icon:SetVertexColor(unpack(Tx.accent))
        else
          LumberList.compactBtn:SetBackdropBorderColor(unpack(Tx.border))
          LumberList.compactBtn.icon:SetVertexColor(0.6, 0.6, 0.6, 1)
        end
      end
      RefreshAll(sharedCtx)
    end
  end)
  settings.compactCB = compactCB
  compactCB.label:SetWidth(120)

  local autoFarmCB = CreateCheckbox(behaviorCard, 10, -52, L["LUMBER_AUTO_FARM"],
    L["LUMBER_AUTO_FARM_TIP"])
  autoFarmCB:SetChecked((db and db.autoStartFarming) and true or false)
  autoFarmCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if db then db.autoStartFarming = checked end
    if sharedCtx then sharedCtx.autoStartFarming = checked end
    RefreshAll(sharedCtx)
  end)
  autoFarmCB.label:SetWidth(120)

  local accountWideCB = CreateCheckbox(behaviorCard, 10, -74, L["LUMBER_ACCOUNT_WIDE"],
    "Combines lumber counts from all characters.\n\nHover over rows to see per-character breakdown.")
  local AccountWide = NS.UI.GatherTrackAccountWide
  accountWideCB:SetChecked(AccountWide and AccountWide:IsEnabled() or false)
  accountWideCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if AccountWide then AccountWide:SetEnabled(checked) end
    if db then db.accountWide = checked end
    RefreshAll(sharedCtx)
  end)
  accountWideCB.label:SetWidth(120)

  local hideInInstanceCB = CreateCheckbox(behaviorCard, 10, -96, L["LUMBER_HIDE_IN_INSTANCE"],
    L["LUMBER_HIDE_IN_INSTANCE_TIP"])
  hideInInstanceCB:SetChecked((db and db.hideInInstance) and true or false)
  hideInInstanceCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if db then db.hideInInstance = checked end
    if sharedCtx then sharedCtx.hideInInstance = checked end
    RefreshAll(sharedCtx)
  end)
  hideInInstanceCB.label:SetWidth(120)

  local goalLabel = goalsCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  goalLabel:SetPoint("TOPLEFT", 10, -34)
  goalLabel:SetText(L["LUMBER_GOAL_AMOUNT"])

  local goalInput = CreateFrame("EditBox", nil, goalsCard, "BackdropTemplate")
  goalInput:SetPoint("TOPRIGHT", -10, -28)
  goalInput:SetSize(58, 22)
  goalInput:SetAutoFocus(false)
  goalInput:SetFontObject(GameFontHighlight)
  goalInput:SetTextInsets(8, 8, 0, 0)
  goalInput:SetMaxLetters(6)
  goalInput:SetNumeric(true)
  Utils.CreateBackdrop(goalInput, T.row or {0.12, 0.12, 0.14, 1}, T.border or {0.24, 0.24, 0.28, 0.8})

  local goalVal = (sharedCtx and tonumber(sharedCtx.goal)) or (db and tonumber(db.goal)) or 1000
  goalInput:SetText(tostring(goalVal))
  goalInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  goalInput:SetScript("OnEnterPressed", function(self)
    local val = tonumber(self:GetText()) or 1000
    val = Utils.Clamp(val, 1, 999999)
    self:SetText(tostring(val))
    if sharedCtx then
      sharedCtx.goal = val
      if db then db.goal = val end
      RefreshAll(sharedCtx)
    end
    self:ClearFocus()
  end)

  local autoGoalCB = CreateCheckbox(goalsCard, 10, -56, L["LUMBER_AUTO_CALC_GOALS"],
    L["LUMBER_AUTO_CALC_GOALS_TIP"])
  autoGoalCB:SetChecked((db and db.autoGoal) and true or false)
  autoGoalCB:SetScript("OnClick", function(self)
    local checked = self:GetChecked() and true or false
    if db then db.autoGoal = checked end
    if sharedCtx then sharedCtx.autoGoal = checked end
    if checked then
      goalInput:Hide()
      goalLabel:SetTextColor(0.5, 0.5, 0.5, 1)
    else
      goalInput:Show()
      goalLabel:SetTextColor(1, 1, 1, 1)
    end
    RefreshAll(sharedCtx)
  end)
  autoGoalCB.label:SetWidth(112)

  if (db and db.autoGoal) then
    goalInput:Hide()
    goalLabel:SetTextColor(0.5, 0.5, 0.5, 1)
  end

  local alphaLabel = appearanceCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  alphaLabel:SetPoint("TOPLEFT", 10, -34)
  alphaLabel:SetText(L["TRANSPARENCY_COLON"])

  local slider = CreateFrame("Slider", nil, appearanceCard, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", 10, -50)
  slider:SetWidth(118)
  slider:SetMinMaxValues(0, 1)
  slider:SetValue(parent._bgAlpha or 0.7)
  slider:SetValueStep(0.05)

  local alphaValue = appearanceCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  alphaValue:SetPoint("LEFT", slider, "RIGHT", 6, 0)
  alphaValue:SetText(string.format("%.0f%%", (parent._bgAlpha or 0.7) * 100))

  slider:SetScript("OnValueChanged", function(self, value)
    parent._bgAlpha = value
    alphaValue:SetText(string.format("%.0f%%", value * 100))
    local d = Utils.GetDB()
    if d then d.alpha = value end
    local showBackgrounds = value >= 0.3
    if sharedCtx then
      sharedCtx.showRowBackgrounds = showBackgrounds
      local Rows = NS.UI.GatherTrackRows
      if Rows and Rows.UpdateRowTransparency then
        Rows:UpdateRowTransparency(sharedCtx)
      end
    end
    if type(onAlphaChange) == "function" then
      onAlphaChange(value, showBackgrounds)
    end
  end)

  settings.iconsCB = iconsCB
  settings.hideCB = hideCB
  settings.trackLumberCB = trackLumberCB
  settings.trackOreCB = trackOreCB
  settings.trackHerbsCB = trackHerbsCB
  settings.autoFarmCB = autoFarmCB
  settings.accountWideCB = accountWideCB
  settings.hideInInstanceCB = hideInInstanceCB
  settings.goalInput = goalInput
  settings.goalLabel = goalLabel
  settings.autoGoalCB = autoGoalCB
  settings.slider = slider
  settings.closeBtn = closeBtn
  settings.doneBtn = doneBtn

  return settings
end

function Settings:RefreshPanel(settingsPanel, sharedCtx)
  if not settingsPanel then return end

  local db = Utils.GetDB()
  local AccountWide = NS.UI.GatherTrackAccountWide

  if settingsPanel.iconsCB then
    settingsPanel.iconsCB:SetChecked(sharedCtx and sharedCtx.showIcons ~= false or true)
  end

  if settingsPanel.hideCB then
    settingsPanel.hideCB:SetChecked(sharedCtx and sharedCtx.hideZero and true or false)
  end

  if settingsPanel.trackLumberCB then
    settingsPanel.trackLumberCB:SetChecked(sharedCtx and sharedCtx.trackLumber ~= false or (db and db.trackLumber ~= false))
  end

  if settingsPanel.trackOreCB then
    settingsPanel.trackOreCB:SetChecked(sharedCtx and sharedCtx.trackOre and true or false)
  end

  if settingsPanel.trackHerbsCB then
    settingsPanel.trackHerbsCB:SetChecked(sharedCtx and sharedCtx.trackHerbs and true or false)
  end

  if settingsPanel.compactCB then
    settingsPanel.compactCB:SetChecked(sharedCtx and sharedCtx.compactMode and true or false)
  end

  if settingsPanel.autoFarmCB then
    settingsPanel.autoFarmCB:SetChecked((db and db.autoStartFarming) and true or false)
  end

  if settingsPanel.accountWideCB and AccountWide then
    settingsPanel.accountWideCB:SetChecked(AccountWide:IsEnabled())
  end

  if settingsPanel.hideInInstanceCB then
    local d = Utils.GetDB()
    settingsPanel.hideInInstanceCB:SetChecked((d and d.hideInInstance) and true or false)
  end

  if settingsPanel.goalInput then
    local goalVal = (sharedCtx and tonumber(sharedCtx.goal)) or (db and tonumber(db.goal)) or 1000
    settingsPanel.goalInput:SetText(tostring(goalVal))
  end

  if settingsPanel.autoGoalCB then
    local autoGoal = (db and db.autoGoal) and true or false
    settingsPanel.autoGoalCB:SetChecked(autoGoal)
    if settingsPanel.goalInput and settingsPanel.goalLabel then
      settingsPanel.goalInput:SetShown(not autoGoal)
      settingsPanel.goalLabel:SetTextColor(autoGoal and 0.5 or 1, autoGoal and 0.5 or 1, autoGoal and 0.5 or 1, 1)
    end
  end

  if settingsPanel.slider then
    local alpha = (db and tonumber(db.alpha)) or 0.7
    settingsPanel.slider:SetValue(alpha)
  end
end

function Settings:Get(key)
  local db = Utils.GetDB()
  return db[key]
end

function Settings:Set(key, value)
  local db = Utils.GetDB()
  db[key] = value
end

return Settings
