local ADDON, NS = ...
NS.UI = NS.UI or {}

local Panels = {}
NS.UI.GatherTrackMiniFarmingPanels = Panels

local GTUtil = NS.UI.GatherTrackMiniUtil
local Farming = NS.UI.GatherTrackMiniFarming
local LTUtils = NS.GT and NS.GT.Utils
local CreateFrame = CreateFrame
local unpack = unpack or table.unpack

local ORDER = { "lumber", "ore", "herb" }
local MIN_FRAME_WIDTH = 220
local MIN_FRAME_HEIGHT = 196
local MAX_FRAME_WIDTH = 320
local MAX_FRAME_HEIGHT = 360

local function FormatWholeNumber(value)
  value = tonumber(value) or 0
  return tostring(math.floor(value + 0.0001))
end

local function FormatRate(value, active, totalGained)
  value = tonumber(value) or 0
  totalGained = tonumber(totalGained) or 0
  return FormatWholeNumber(value)
end

local function AddBreakdownTooltip(itemID, owner, stats)
  if not itemID or not GameTooltip then return end
  GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
  GameTooltip:SetItemByID(itemID)

  stats = stats or {}
  local bagCount = tonumber(stats.focusBagCount) or 0
  local overallCount = tonumber(stats.focusOverallCount) or 0
  local sessionCount = tonumber(stats.focusSessionCount) or 0
  local recentAmount = tonumber(stats.focusRecentAmount) or 0
  local perHour = tonumber(stats.focusPerHour) or 0

  GameTooltip:AddLine(" ")
  if recentAmount > 0 then
    GameTooltip:AddDoubleLine("Just Gathered", "+" .. FormatWholeNumber(recentAmount), 0.82, 0.88, 0.95, 1, 1, 1)
  end
  GameTooltip:AddDoubleLine("Session", FormatWholeNumber(sessionCount), 0.82, 0.88, 0.95, 1, 1, 1)
  GameTooltip:AddDoubleLine("Bags", FormatWholeNumber(bagCount), 0.82, 0.88, 0.95, 1, 1, 1)
  if overallCount > 0 then
    GameTooltip:AddDoubleLine("Overall", FormatWholeNumber(overallCount), 0.82, 0.88, 0.95, 1, 1, 1)
  end
  GameTooltip:AddDoubleLine("Per Hour", FormatWholeNumber(perHour), 0.82, 0.88, 0.95, 1, 1, 1)

  local AccountWide = NS.UI and NS.UI.GatherTrackAccountWide
  if AccountWide and AccountWide.GetCharacterBreakdown then
    local breakdown = AccountWide:GetCharacterBreakdown(itemID)
    if breakdown and #breakdown > 0 then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Stored In", 0.82, 0.88, 0.95)
      for _, data in ipairs(breakdown) do
        local countStr = LTUtils and LTUtils.FormatNumberCompact and LTUtils.FormatNumberCompact(data.count or 0) or tostring(data.count or 0)
        if data.warband then
          GameTooltip:AddDoubleLine(data.label, countStr, 0.50, 0.78, 1.0, 0.50, 0.78, 1.0)
        else
          GameTooltip:AddDoubleLine(data.label, countStr, 0.85, 0.85, 0.85, 1, 1, 1)
        end
      end
    end
  end

  GameTooltip:Show()
end

local function CreateBackdrop(frame, bg, border)
  if LTUtils and LTUtils.CreateBackdrop then
    LTUtils.CreateBackdrop(frame, bg, border)
    return
  end
  frame:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8", edgeFile = "Interface/Buttons/WHITE8x8", edgeSize = 1 })
  frame:SetBackdropColor(unpack(bg))
  frame:SetBackdropBorderColor(unpack(border))
end

local function ApplyBackdropAlpha(frame, bg, border, alpha, showBackgrounds)
  if not frame then return end
  if showBackgrounds then
    frame:SetBackdropColor(bg[1], bg[2], bg[3], (bg[4] or 1) * alpha)
    frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1)
  else
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
  end
end

local function ensureDB()
  local db = GTUtil.GetDB()
  db.gatherFarming = db.gatherFarming or {}
  db.gatherFarming.main = db.gatherFarming.main or {}
  local s = db.gatherFarming.main
  if s.width == nil then s.width = MIN_FRAME_WIDTH end
  if s.height == nil then s.height = MIN_FRAME_HEIGHT end
  if s.collapsed == nil then s.collapsed = false end
  if s.alpha == nil then s.alpha = 0.96 end
  if s.point == nil then s.point = "CENTER" end
  if s.relPoint == nil then s.relPoint = "CENTER" end
  if s.x == nil then s.x = 0 end
  if s.y == nil then s.y = -180 end
  if s.open == nil then s.open = false end
  if s.userClosed == nil then s.userClosed = false end
  return s
end

local function makeStat(parent, label)
  local box = CreateFrame("Frame", nil, parent)
  box.label = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  box.label:SetPoint("TOP", 0, 0)
  box.label:SetJustifyH("CENTER")
  box.label:SetText(label)
  box.label:SetTextColor(0.58, 0.62, 0.70, 1)
  box.value = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  box.value:SetPoint("TOP", box.label, "BOTTOM", 0, -1)
  box.value:SetJustifyH("CENTER")
  box.value:SetText("0")
  return box
end

local function makeAction(parent, label)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetHeight(14)
  CreateBackdrop(b, { 0.12, 0.13, 0.16, 1 }, { 0.24, 0.26, 0.31, 1 })
  b._bg = { 0.12, 0.13, 0.16, 1 }
  b._border = { 0.24, 0.26, 0.31, 1 }
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  b.text:SetPoint("CENTER")
  b.text:SetText(label)
  return b
end

local function makeRow(parent)
  local row = CreateFrame("Button", nil, parent)
  row:SetHeight(11)
  row:EnableMouse(true)
  row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.text:SetPoint("TOPLEFT", 0, 0)
  row.text:SetPoint("TOPRIGHT", 0, 0)
  row.text:SetJustifyH("CENTER")
  row.text:SetWordWrap(false)
  row:SetScript("OnEnter", function(self)
    if self.itemID then
      AddBreakdownTooltip(self.itemID, self, self.stats)
    end
  end)
  row:SetScript("OnLeave", function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
  return row
end

local function createCard(parent, kind)
  local info = GTUtil.GetKindInfo(kind)
  local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  CreateBackdrop(card, { 0.08, 0.09, 0.11, 1 }, { info.accent[1], info.accent[2], info.accent[3], 0.45 })
  card._bg = { 0.08, 0.09, 0.11, 1 }
  card._border = { info.accent[1], info.accent[2], info.accent[3], 0.45 }

  card.pill = CreateFrame("Frame", nil, card, "BackdropTemplate")
  CreateBackdrop(card.pill, { info.accent[1] * 0.18, info.accent[2] * 0.18, info.accent[3] * 0.18, 1 }, { info.accent[1], info.accent[2], info.accent[3], 0.4 })
  card.pill._bg = { info.accent[1] * 0.18, info.accent[2] * 0.18, info.accent[3] * 0.18, 1 }
  card.pill._border = { info.accent[1], info.accent[2], info.accent[3], 0.4 }
  card.pill:SetSize(30, 11)
  card.pill.text = card.pill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  card.pill.text:SetPoint("CENTER")
  card.pill.text:SetText(info.title:sub(1, 1))

  card.total = makeStat(card, "G")
  card.focus = makeStat(card, "B")
  card.rate = makeStat(card, "H")

  card.materialsLine = card:CreateTexture(nil, "ARTWORK")
  card.materialsLine:SetColorTexture(1, 1, 1, 0.10)

  card.rows = {}
  for i = 1, 1 do
    card.rows[i] = makeRow(card)
  end
  return card
end

local function hideAuxiliaryPanels(frame)
  if not frame then return end
  if frame.settingsPopup and frame.settingsPopup:IsShown() then
    frame.settingsPopup:Hide()
  end
end

function Panels:Create()
  if self.frame then return self.frame end

  local db = ensureDB()
  local expandedHeight = db.height or MIN_FRAME_HEIGHT
  local collapsedHeight = 42
  local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  frame:SetSize(db.width or MIN_FRAME_WIDTH, db.collapsed and collapsedHeight or expandedHeight)
  frame:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(216)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:SetClampedToScreen(true)
  frame:EnableMouse(true)
  frame:Hide()
  frame:SetResizeBounds(MIN_FRAME_WIDTH, MIN_FRAME_HEIGHT, MAX_FRAME_WIDTH, MAX_FRAME_HEIGHT)
  CreateBackdrop(frame, { 0.06, 0.07, 0.09, db.alpha or 0.96 }, { 0.78, 0.82, 0.88, 0.65 })
  frame._bg = { 0.06, 0.07, 0.09, 0.96 }
  frame._border = { 0.78, 0.82, 0.88, 0.65 }

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(22)
  CreateBackdrop(header, { 0.10, 0.11, 0.14, 1 }, { 0.78, 0.82, 0.88, 0.75 })
  header._bg = { 0.10, 0.11, 0.14, 1 }
  header._border = { 0.78, 0.82, 0.88, 0.75 }
  header:RegisterForDrag("LeftButton")
  header:EnableMouse(true)
  header:SetScript("OnDragStart", function() frame:StartMoving() end)
  header:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local pt, _, relPt, x, y = frame:GetPoint(1)
    db.point, db.relPoint, db.x, db.y = pt, relPt, x, y
  end)

  local collapseBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  collapseBtn:SetSize(14, 14)
  collapseBtn:SetPoint("LEFT", 4, 0)
  CreateBackdrop(collapseBtn, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  collapseBtn._bg = { 0.14, 0.15, 0.18, 1 }
  collapseBtn._border = { 0.26, 0.28, 0.33, 1 }
  collapseBtn.icon = collapseBtn:CreateTexture(nil, "OVERLAY")
  collapseBtn.icon:SetAllPoints()
  collapseBtn.icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  collapseBtn.icon:SetRotation(db.collapsed and 0 or -1.5708)

  local settingsBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  settingsBtn:SetSize(14, 14)
  settingsBtn:SetPoint("RIGHT", -22, 0)
  CreateBackdrop(settingsBtn, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  settingsBtn._bg = { 0.14, 0.15, 0.18, 1 }
  settingsBtn._border = { 0.26, 0.28, 0.33, 1 }
  settingsBtn.icon = settingsBtn:CreateTexture(nil, "OVERLAY")
  settingsBtn.icon:SetAllPoints()
  settingsBtn.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")

  local close = CreateFrame("Button", nil, header, "BackdropTemplate")
  close:SetSize(14, 14)
  close:SetPoint("RIGHT", -4, 0)
  CreateBackdrop(close, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  close._bg = { 0.14, 0.15, 0.18, 1 }
  close._border = { 0.26, 0.28, 0.33, 1 }
  close.txt = close:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  close.txt:SetPoint("CENTER")
  close.txt:SetText("x")
  close:SetScript("OnClick", function()
    frame:Hide()
    db.open = false
    db.userClosed = true
  end)

  frame.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.title:SetPoint("LEFT", collapseBtn, "RIGHT", 4, 0)
  frame.title:SetPoint("RIGHT", settingsBtn, "LEFT", -46, 0)
  frame.title:SetJustifyH("LEFT")
  frame.title:SetText("Gather Farming")
  frame.title:SetTextColor(0.82, 0.88, 0.95, 1)

  frame.timerChip = CreateFrame("Frame", nil, header, "BackdropTemplate")
  CreateBackdrop(frame.timerChip, { 0.17, 0.13, 0.07, 0.95 }, { 0.92, 0.74, 0.28, 0.40 })
  frame.timerChip._bg = { 0.17, 0.13, 0.07, 0.95 }
  frame.timerChip._border = { 0.92, 0.74, 0.28, 0.40 }
  frame.timerChip:SetPoint("RIGHT", settingsBtn, "LEFT", -4, 0)
  frame.timerChip:SetSize(34, 14)

  frame.timerText = frame.timerChip:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.timerText:SetPoint("CENTER", 0, 0)
  frame.timerText:SetText("0:00")
  frame.timerText:SetTextColor(1.00, 0.86, 0.52, 1)

  local controls = CreateFrame("Frame", nil, frame)
  controls:SetPoint("BOTTOMLEFT", 10, 10)
  controls:SetPoint("BOTTOMRIGHT", -10, 10)
  controls:SetHeight(16)
  frame.controls = controls

  frame.startPause = makeAction(controls, "Start")
  frame.reset = makeAction(controls, "Reset")

  frame.startPause:SetScript("OnClick", function()
    local ctx = GTUtil.GetSharedCtx()
    local anyActive = false
    local anyPaused = false
    for _, kind in ipairs(ORDER) do
      local session = Farming:EnsureSession(kind)
      if session.active then
        anyActive = true
        if session.paused then
          anyPaused = true
        end
      end
    end

    if not anyActive then
      for _, kind in ipairs(ORDER) do
        Farming:Start(kind, ctx)
      end
    else
      for _, kind in ipairs(ORDER) do
        local session = Farming:EnsureSession(kind)
        if session.active then
          local shouldToggle = (anyPaused and session.paused) or ((not anyPaused) and (not session.paused))
          if shouldToggle then
            Farming:TogglePause(kind)
          end
        end
      end
    end

    Panels:Refresh(nil, ctx)
  end)

  frame.reset:SetScript("OnClick", function()
    local ctx = GTUtil.GetSharedCtx()
    for _, kind in ipairs(ORDER) do
      Farming:Reset(kind, ctx)
    end
    Panels:Refresh(nil, ctx)
  end)

  local content = CreateFrame("Frame", nil, frame)
  content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -6)
  content:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -34)
  content:SetPoint("BOTTOMLEFT", controls, "TOPLEFT", 0, 0)
  content:SetPoint("BOTTOMRIGHT", controls, "TOPRIGHT", 0, 0)
  frame.content = content
  frame.cards = {}

  for _, kind in ipairs(ORDER) do
    frame.cards[kind] = createCard(content, kind)
  end

  local settings = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  settings:SetFrameStrata("FULLSCREEN_DIALOG")
  settings:SetFrameLevel(500)
  settings:SetSize(240, 110)
  settings:Hide()
  CreateBackdrop(settings, { 0.08, 0.09, 0.11, 0.98 }, { 0.78, 0.82, 0.88, 0.7 })
  local settingsTitle = settings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  settingsTitle:SetPoint("TOP", 0, -12)
  settingsTitle:SetText("Farming Options")
  local alphaLabel = settings:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  alphaLabel:SetPoint("TOPLEFT", 16, -40)
  alphaLabel:SetText("Transparency")
  local alphaSlider = CreateFrame("Slider", nil, settings, "OptionsSliderTemplate")
  alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -10)
  alphaSlider:SetWidth(150)
  alphaSlider:SetMinMaxValues(0.2, 1)
  alphaSlider:SetValueStep(0.05)
  alphaSlider:SetObeyStepOnDrag(true)
  alphaSlider:SetValue(db.alpha or 0.96)
  alphaSlider:SetScript("OnValueChanged", function(_, value)
    db.alpha = value
    if frame._applyAlpha then frame._applyAlpha(value) end
  end)
  frame.settingsPopup = settings
  settingsBtn:SetScript("OnClick", function()
    if settings:IsShown() then
      settings:Hide()
    else
      settings:ClearAllPoints()
      settings:SetPoint("TOP", header, "BOTTOM", 0, -8)
      settings:Show()
      settings:Raise()
    end
  end)

  local function applyCollapsed()
    local collapsed = db.collapsed and true or false
    content:SetShown(not collapsed)
    controls:SetShown(not collapsed)
    if collapsed then hideAuxiliaryPanels(frame) end
    if frame.resizeGrip then frame.resizeGrip:SetShown(not collapsed) end
    frame:SetHeight(collapsed and collapsedHeight or (db.height or expandedHeight))
    collapseBtn.icon:SetRotation(collapsed and 0 or -1.5708)
  end

  local function layout()
    local contentWidth = math.max(170, content:GetWidth() or (frame:GetWidth() - 20))
    local gap = 4
    local y = 0

    local function layoutCard(card)
      local inset = 6
      local inner = math.max(150, card:GetWidth() - (inset * 2))
      local gap2 = 4
      local topY = -4
      local pillWidth = 20
      local statsAvailable = inner - pillWidth - (gap2 * 3)
      local statWidth = math.floor(statsAvailable / 3)
      if statWidth < 20 then statWidth = 20 end

      card.pill:ClearAllPoints()
      card.pill:SetPoint("TOPLEFT", card, "TOPLEFT", inset, topY)
      card.pill:SetWidth(pillWidth)
      card.pill:SetHeight(12)

      local statsLeft = inset + pillWidth + gap2
      card.total:ClearAllPoints()
      card.total:SetPoint("TOPLEFT", card, "TOPLEFT", statsLeft, topY)
      card.total:SetWidth(statWidth)
      card.total:SetHeight(16)
      card.focus:ClearAllPoints()
      card.focus:SetPoint("TOPLEFT", card.total, "TOPRIGHT", gap2, 0)
      card.focus:SetWidth(statWidth)
      card.focus:SetHeight(16)
      card.rate:ClearAllPoints()
      card.rate:SetPoint("TOPLEFT", card.focus, "TOPRIGHT", gap2, 0)
      card.rate:SetWidth(statWidth)
      card.rate:SetHeight(16)

      card.materialsLine:ClearAllPoints()
      card.materialsLine:SetPoint("TOPLEFT", card, "TOPLEFT", inset, -22)
      card.materialsLine:SetPoint("TOPRIGHT", card, "TOPRIGHT", -inset, -22)
      card.materialsLine:SetHeight(1)

      local row = card.rows[1]
      row:ClearAllPoints()
      row:SetPoint("TOPLEFT", card, "TOPLEFT", inset, -31)
      row:SetPoint("TOPRIGHT", card, "TOPRIGHT", -inset, -31)

      card:SetHeight(42)
    end

    frame.startPause:ClearAllPoints()
    frame.startPause:SetPoint("TOPLEFT", controls, "TOPLEFT", 0, 0)
    frame.startPause:SetPoint("TOPRIGHT", controls, "TOP", -2, 0)
    frame.reset:ClearAllPoints()
    frame.reset:SetPoint("TOPLEFT", controls, "TOP", 2, 0)
    frame.reset:SetPoint("TOPRIGHT", controls, "TOPRIGHT", 0, 0)

    local visibleCards = {}
    for _, kind in ipairs(ORDER) do
      if frame.cards[kind]:IsShown() then
        visibleCards[#visibleCards + 1] = frame.cards[kind]
      end
    end

    for _, card in ipairs(visibleCards) do
      card:ClearAllPoints()
      card:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
      card:SetWidth(contentWidth)
      layoutCard(card)
      y = y + card:GetHeight() + gap
    end

    if #visibleCards == 0 then
      y = 0
    end

    content:SetHeight(math.max(1, y))
  end

  frame._applyAlpha = function(value)
    local showBackgrounds = value >= 0.3
    ApplyBackdropAlpha(frame, frame._bg, frame._border, value, showBackgrounds)
    ApplyBackdropAlpha(header, header._bg, header._border, value, showBackgrounds)
    ApplyBackdropAlpha(collapseBtn, collapseBtn._bg, collapseBtn._border, value, showBackgrounds)
    ApplyBackdropAlpha(settingsBtn, settingsBtn._bg, settingsBtn._border, value, showBackgrounds)
    ApplyBackdropAlpha(close, close._bg, close._border, value, showBackgrounds)
    ApplyBackdropAlpha(frame.timerChip, frame.timerChip._bg, frame.timerChip._border, value, showBackgrounds)
    for _, kind in ipairs(ORDER) do
      local card = frame.cards[kind]
      ApplyBackdropAlpha(card, card._bg, card._border, value, showBackgrounds)
      ApplyBackdropAlpha(card.pill, card.pill._bg, card.pill._border, value, showBackgrounds)
    end
    ApplyBackdropAlpha(frame.startPause, frame.startPause._bg, frame.startPause._border, value, showBackgrounds)
    ApplyBackdropAlpha(frame.reset, frame.reset._bg, frame.reset._border, value, showBackgrounds)
  end

  collapseBtn:SetScript("OnClick", function()
    db.collapsed = not db.collapsed
    applyCollapsed()
  end)

  local resizeGrip = CreateFrame("Button", nil, frame)
  resizeGrip:SetSize(18, 18)
  resizeGrip:SetPoint("BOTTOMRIGHT", -2, 2)
  resizeGrip:EnableMouse(true)
  resizeGrip:RegisterForDrag("LeftButton")
  resizeGrip.tex = resizeGrip:CreateTexture(nil, "OVERLAY")
  resizeGrip.tex:SetAllPoints()
  resizeGrip.tex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  resizeGrip:SetScript("OnDragStart", function()
    frame:StartSizing("BOTTOMRIGHT")
  end)
  resizeGrip:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    db.width = math.max(MIN_FRAME_WIDTH, math.min(MAX_FRAME_WIDTH, frame:GetWidth()))
    db.height = math.max(collapsedHeight, math.max(MIN_FRAME_HEIGHT, math.min(MAX_FRAME_HEIGHT, frame:GetHeight())))
    frame:SetSize(db.width, db.height)
    layout()
    Panels:Refresh(nil, GTUtil.GetSharedCtx())
  end)
  frame.resizeGrip = resizeGrip

  frame:SetScript("OnSizeChanged", function()
    layout()
  end)
  frame:HookScript("OnShow", function()
    C_Timer.After(0, function()
      if not frame or not frame:IsShown() then return end
      layout()
    end)
  end)
  frame:HookScript("OnHide", function()
    hideAuxiliaryPanels(frame)
  end)
  frame._layout = layout

  applyCollapsed()
  frame._applyAlpha(db.alpha or 0.96)

  self.frame = frame
  return frame
end

function Panels:Refresh(kind, ctx)
  local frame = self:Create()
  local db = ensureDB()
  ctx = ctx or GTUtil.GetSharedCtx()
  if GTUtil.ShouldHideInInstance() then
    if frame:IsShown() then
      hideAuxiliaryPanels(frame)
      frame:Hide()
    end
    return
  end

  local activeCount = 0
  local sharedTimer = "0:00"
  local anyPaused = false
  local visibleCount = 0
  for _, gatherKind in ipairs(ORDER) do
    local card = frame.cards[gatherKind]
    local enabled = GTUtil.IsKindEnabled(ctx, gatherKind)
    card:SetShown(enabled)
    if enabled then
      visibleCount = visibleCount + 1
    end
    local stats = Farming:GetStats(gatherKind, ctx)
    local session = Farming:EnsureSession(gatherKind)
    if enabled and session.active then
      activeCount = activeCount + 1
      if sharedTimer == "0:00" then
        sharedTimer = stats.sessionTime or "0:00"
      end
      if session.paused then
        anyPaused = true
      end
    end
    if enabled then
      local topItems = stats.topItems or {}
      local firstItem = topItems[1]
      local row = card.rows[1]
      local focusItemID = stats.focusItemID or (firstItem and firstItem.itemID) or nil
      local focusItem = nil
      if focusItemID then
        for _, item in ipairs(topItems) do
          if item.itemID == focusItemID then
            focusItem = item
            break
          end
        end
      end
      focusItem = focusItem or firstItem

      card.total.value:SetText(FormatWholeNumber(stats.focusSessionCount or 0))
      card.focus.value:SetText(FormatWholeNumber(stats.focusBagCount or 0))
      card.rate.value:SetText(FormatRate(stats.focusPerHour, session.active, stats.focusSessionCount))

      if focusItem then
        row.itemID = focusItem.itemID
        row.stats = stats
        local rowText = (focusItem.name or "-")
        if gatherKind == "lumber" then
          rowText = rowText:gsub(" Lumber$", "")
        end
        row.text:SetText(rowText)
        row:Show()
      else
        row.itemID = nil
        row.stats = nil
        row.text:SetText("-")
        row:Show()
      end
    end
  end

  if frame.timerText then
    frame.timerText:SetText(sharedTimer)
  end
  if frame.startPause then
    frame.startPause.text:SetText(activeCount == 0 and "Start" or (anyPaused and "Resume" or "Pause"))
  end
  frame.controls:SetShown((not db.collapsed) and visibleCount > 0)
  if frame._layout then
    frame._layout()
  end
end

function Panels:Show(kind, autoOpened)
  local frame = self:Create()
  local db = ensureDB()
  local trackDB = GTUtil.GetDB()
  local autoFarmEnabled = trackDB and trackDB.autoStartFarming and true or false
  if autoOpened and db.userClosed and not autoFarmEnabled then
    return
  end
  if GTUtil.ShouldHideInInstance() then
    if not autoOpened then
      db.open = true
      db.userClosed = false
    end
    return
  end
  frame:Show()
  frame:Raise()
  if not autoOpened then
    db.open = true
    db.userClosed = false
  end
  self:Refresh(kind, GTUtil.GetSharedCtx())
end

function Panels:Toggle(kind)
  local frame = self:Create()
  if frame:IsShown() then
    hideAuxiliaryPanels(frame)
    frame:Hide()
    local db = ensureDB()
    db.open = false
    db.userClosed = true
  else
    self:Show(kind, false)
  end
end

function Panels:RestoreOpen()
  if ensureDB().open then
    self:Show(nil, false)
  end
end

return Panels
