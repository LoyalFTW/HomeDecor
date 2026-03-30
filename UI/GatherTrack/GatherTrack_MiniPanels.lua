local ADDON, NS = ...
NS.UI = NS.UI or {}

local Panels = {}
NS.UI.GatherTrackMiniPanels = Panels

local GTUtil = NS.UI.GatherTrackMiniUtil
local LTUtils = NS.GT and NS.GT.Utils
local FarmingPanels = NS.UI.GatherTrackMiniFarmingPanels
local LegacySettings = NS.UI.GatherTrackSettings

local CreateFrame = CreateFrame
local unpack = unpack or table.unpack

local ORDER = { "lumber", "ore", "herb" }
local NORMAL_MIN_WIDTH = 340
local NORMAL_MIN_HEIGHT = 320
local NORMAL_MAX_WIDTH = 700
local NORMAL_MAX_HEIGHT = 900
local COMPACT_MIN_WIDTH = 300
local COMPACT_MIN_HEIGHT = 190
local COMPACT_MAX_WIDTH = 520
local COMPACT_MAX_HEIGHT = 520
local COMPACT_DEFAULT_WIDTH = 360
local COMPACT_DEFAULT_HEIGHT = 250

local function IsCompact(ctx)
  return ctx and ctx.compactMode and true or false
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
  db.gatherMini = db.gatherMini or {}
  db.gatherMini.main = db.gatherMini.main or {}
  local s = db.gatherMini.main
  if s.width == nil then s.width = 430 end
  if s.height == nil then s.height = 540 end
  if s.collapsed == nil then s.collapsed = false end
  if s.alpha == nil then s.alpha = 0.95 end
  if s.point == nil then s.point = "CENTER" end
  if s.relPoint == nil then s.relPoint = "CENTER" end
  if s.x == nil then s.x = 0 end
  if s.y == nil then s.y = 60 end
  if s.compactWidth == nil then s.compactWidth = COMPACT_DEFAULT_WIDTH end
  if s.compactHeight == nil then s.compactHeight = COMPACT_DEFAULT_HEIGHT end
  if s.open == nil then s.open = false end
  return s
end

local function GetSizeForMode(db, compactMode)
  if compactMode then
    local width = math.max(COMPACT_MIN_WIDTH, math.min(COMPACT_MAX_WIDTH, tonumber(db.compactWidth) or COMPACT_DEFAULT_WIDTH))
    local height = math.max(COMPACT_MIN_HEIGHT, math.min(COMPACT_MAX_HEIGHT, tonumber(db.compactHeight) or COMPACT_DEFAULT_HEIGHT))
    return width, height
  end

  local width = math.max(NORMAL_MIN_WIDTH, math.min(NORMAL_MAX_WIDTH, tonumber(db.width) or 430))
  local height = math.max(NORMAL_MIN_HEIGHT, math.min(NORMAL_MAX_HEIGHT, tonumber(db.height) or 540))
  return width, height
end

local function ApplyFrameMode(frame, db, compactMode)
  if not frame or not db then return end

  local minW = compactMode and COMPACT_MIN_WIDTH or NORMAL_MIN_WIDTH
  local minH = compactMode and COMPACT_MIN_HEIGHT or NORMAL_MIN_HEIGHT
  local maxW = compactMode and COMPACT_MAX_WIDTH or NORMAL_MAX_WIDTH
  local maxH = compactMode and COMPACT_MAX_HEIGHT or NORMAL_MAX_HEIGHT
  local width, height = GetSizeForMode(db, compactMode)

  frame:SetResizeBounds(minW, minH, maxW, maxH)
  frame:SetSize(width, height)
end

local function ApplyModeLayout(frame, compactMode)
  if not frame or not frame.header or not frame.summary or not frame.scroll or not frame.subtitle then
    return
  end

  compactMode = compactMode and true or false

  if compactMode then
    frame.header:SetHeight(24)
    frame.subtitle:ClearAllPoints()
    frame.subtitle:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 4, -4)
    frame.subtitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -24)

    frame.summary:ClearAllPoints()
    frame.summary:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -4)
    frame.summary:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -28)
    frame.summary:SetHeight(1)

    frame.scroll:ClearAllPoints()
    frame.scroll:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -6)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 10)
  else
    frame.header:SetHeight(28)
    frame.subtitle:ClearAllPoints()
    frame.subtitle:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 4, -10)
    frame.subtitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -38)

    frame.summary:ClearAllPoints()
    frame.summary:SetPoint("TOPLEFT", frame.subtitle, "BOTTOMLEFT", 0, -10)
    frame.summary:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -64)
    frame.summary:SetHeight(42)

    frame.scroll:ClearAllPoints()
    frame.scroll:SetPoint("TOPLEFT", frame.summary, "BOTTOMLEFT", 0, -10)
    frame.scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 40)
  end
end

local function createRow(parent)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(24)
  row.bg = row:CreateTexture(nil, "BACKGROUND")
  row.bg:SetAllPoints()
  row.bg:SetColorTexture(1, 1, 1, 0.03)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(16, 16)
  row.icon:SetPoint("LEFT", 8, 0)
  row.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
  row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
  row.name:SetPoint("RIGHT", row, "RIGHT", -70, 0)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.count = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  row.count:SetPoint("RIGHT", row, "RIGHT", -8, 0)
  row.count:SetJustifyH("RIGHT")
  row:SetScript("OnEnter", function(self)
    if self.itemID and GameTooltip then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetItemByID(self.itemID)
      GameTooltip:Show()
    end
  end)
  row:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  return row
end

local function applyRowLayout(row, compactMode, showIcons)
  if not row then return end

  compactMode = compactMode and true or false
  showIcons = showIcons ~= false

  row:SetHeight(compactMode and 18 or 24)
  row.icon:SetShown(showIcons)

  if compactMode then
    row.icon:SetSize(12, 12)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", 6, 0)
    row.name:SetFontObject("GameFontNormalSmall")
    row.count:SetFontObject("GameFontNormalSmall")
    row.count:ClearAllPoints()
    row.count:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    row.name:ClearAllPoints()
    if showIcons then
      row.name:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
    else
      row.name:SetPoint("LEFT", row, "LEFT", 6, 0)
    end
    row.name:SetPoint("RIGHT", row.count, "LEFT", -4, 0)
  else
    row.icon:SetSize(16, 16)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", 8, 0)
    row.name:SetFontObject("GameFontHighlightSmall")
    row.count:SetFontObject("GameFontNormalSmall")
    row.count:ClearAllPoints()
    row.count:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.name:ClearAllPoints()
    if showIcons then
      row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    else
      row.name:SetPoint("LEFT", row, "LEFT", 8, 0)
    end
    row.name:SetPoint("RIGHT", row.count, "LEFT", -6, 0)
  end
end

local function createSection(parent, kind)
  local info = GTUtil.GetKindInfo(kind)
  local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  CreateBackdrop(section, { 0.09, 0.10, 0.12, 1 }, { info.accent[1], info.accent[2], info.accent[3], 0.55 })
  section._bg = { 0.09, 0.10, 0.12, 1 }
  section._border = { info.accent[1], info.accent[2], info.accent[3], 0.55 }
  section.kind = kind

  section.header = CreateFrame("Frame", nil, section, "BackdropTemplate")
  section.header:SetPoint("TOPLEFT", 6, -6)
  section.header:SetPoint("TOPRIGHT", -6, -6)
  section.header:SetHeight(26)
  CreateBackdrop(section.header, { 0.11, 0.12, 0.15, 1 }, { info.accent[1], info.accent[2], info.accent[3], 0.7 })
  section.header._bg = { 0.11, 0.12, 0.15, 1 }
  section.header._border = { info.accent[1], info.accent[2], info.accent[3], 0.7 }

  section.title = section.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  section.title:SetPoint("LEFT", 10, 0)
  section.title:SetText(info.title)
  section.title:SetTextColor(unpack(info.accent))

  section.total = section.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  section.total:SetPoint("RIGHT", -10, 0)
  section.total:SetText("0")

  section.sub = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  section.sub:SetPoint("TOPLEFT", section.header, "BOTTOMLEFT", 2, -8)
  section.sub:SetPoint("RIGHT", section, "RIGHT", -10, 0)
  section.sub:SetJustifyH("LEFT")
  section.sub:SetTextColor(0.72, 0.75, 0.80, 1)
  section.sub:SetText("No materials tracked yet")

  section.rows = {}
  section.empty = section:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  section.empty:SetText("Nothing in bags yet")
  section.empty:SetTextColor(0.52, 0.56, 0.62, 1)

  section.footer = section:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  section.footer:SetPoint("BOTTOMLEFT", section, "BOTTOMLEFT", 10, 8)
  section.footer:SetPoint("BOTTOMRIGHT", section, "BOTTOMRIGHT", -10, 8)
  section.footer:SetJustifyH("LEFT")
  section.footer:SetTextColor(0.72, 0.75, 0.80, 1)
  section.footer:SetText("Top stack: -")

  return section
end

local function hideAuxiliaryPanels(frame)
  if not frame then return end
  if frame.legacySettings and frame.legacySettings:IsShown() then
    frame.legacySettings:Hide()
  end
  if frame.settingsPopup and frame.settingsPopup:IsShown() then
    frame.settingsPopup:Hide()
  end
end

function Panels:Create()
  if self.frame then return self.frame end

  local db = ensureDB()
  local expandedHeight = db.height or 540
  local collapsedHeight = 42

  local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  frame:SetSize(db.width or 430, db.collapsed and collapsedHeight or expandedHeight)
  frame:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(215)
  frame:SetMovable(true)
  frame:SetResizable(true)
  frame:SetClampedToScreen(true)
  frame:EnableMouse(true)
  frame:Hide()
  frame:SetResizeBounds(NORMAL_MIN_WIDTH, NORMAL_MIN_HEIGHT, NORMAL_MAX_WIDTH, NORMAL_MAX_HEIGHT)
  CreateBackdrop(frame, { 0.06, 0.07, 0.09, db.alpha or 0.95 }, { 0.22, 0.24, 0.28, 0.85 })
  frame._bg = { 0.06, 0.07, 0.09, 0.95 }
  frame._border = { 0.22, 0.24, 0.28, 0.85 }

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.header = header
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(28)
  CreateBackdrop(header, { 0.10, 0.11, 0.14, 0.98 }, { 0.88, 0.74, 0.34, 0.7 })
  header._bg = { 0.10, 0.11, 0.14, 0.98 }
  header._border = { 0.88, 0.74, 0.34, 0.7 }
  header:EnableMouse(true)
  header:RegisterForDrag("LeftButton")
  header:SetScript("OnDragStart", function() frame:StartMoving() end)
  header:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local pt, _, relPt, x, y = frame:GetPoint(1)
    db.point, db.relPoint, db.x, db.y = pt, relPt, x, y
  end)

  local collapseBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  collapseBtn:SetSize(18, 18)
  collapseBtn:SetPoint("LEFT", 6, 0)
  CreateBackdrop(collapseBtn, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  collapseBtn._bg = { 0.14, 0.15, 0.18, 1 }
  collapseBtn._border = { 0.26, 0.28, 0.33, 1 }
  collapseBtn.icon = collapseBtn:CreateTexture(nil, "OVERLAY")
  collapseBtn.icon:SetAllPoints()
  collapseBtn.icon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  collapseBtn.icon:SetRotation(db.collapsed and 0 or -1.5708)

  local settingsBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  settingsBtn:SetSize(18, 18)
  settingsBtn:SetPoint("RIGHT", -74, 0)
  CreateBackdrop(settingsBtn, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  settingsBtn._bg = { 0.14, 0.15, 0.18, 1 }
  settingsBtn._border = { 0.26, 0.28, 0.33, 1 }
  settingsBtn.icon = settingsBtn:CreateTexture(nil, "OVERLAY")
  settingsBtn.icon:SetAllPoints()
  settingsBtn.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")

  local farmBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  farmBtn:SetSize(40, 18)
  farmBtn:SetPoint("RIGHT", -28, 0)
  CreateBackdrop(farmBtn, { 0.14, 0.15, 0.18, 1 }, { 0.88, 0.74, 0.34, 0.65 })
  farmBtn._bg = { 0.14, 0.15, 0.18, 1 }
  farmBtn._border = { 0.88, 0.74, 0.34, 0.65 }
  farmBtn.txt = farmBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  farmBtn.txt:SetPoint("CENTER")
  farmBtn.txt:SetText("Farm")
  farmBtn:SetScript("OnClick", function()
    if FarmingPanels and FarmingPanels.Toggle then
      FarmingPanels:Toggle()
    end
  end)

  local close = CreateFrame("Button", nil, header, "BackdropTemplate")
  close:SetSize(18, 18)
  close:SetPoint("RIGHT", -6, 0)
  CreateBackdrop(close, { 0.14, 0.15, 0.18, 1 }, { 0.26, 0.28, 0.33, 1 })
  close._bg = { 0.14, 0.15, 0.18, 1 }
  close._border = { 0.26, 0.28, 0.33, 1 }
  close.x = close:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  close.x:SetPoint("CENTER")
  close.x:SetText("x")
  close:SetScript("OnClick", function()
    frame:Hide()
    db.open = false
  end)

  frame.title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.title:SetPoint("LEFT", collapseBtn, "RIGHT", 6, 0)
  frame.title:SetPoint("RIGHT", settingsBtn, "LEFT", -8, 0)
  frame.title:SetJustifyH("LEFT")
  frame.title:SetText("Gather Tracker")
  frame.title:SetTextColor(0.95, 0.84, 0.42, 1)

  frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  frame.subtitle:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 4, -10)
  frame.subtitle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -38)
  frame.subtitle:SetJustifyH("LEFT")
  frame.subtitle:SetTextColor(0.72, 0.75, 0.80, 1)
  frame.subtitle:SetText("One tracker for lumber, ore, and herbs.")

  local summary = CreateFrame("Frame", nil, frame)
  summary:SetPoint("TOPLEFT", frame.subtitle, "BOTTOMLEFT", 0, -10)
  summary:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -64)
  summary:SetHeight(42)
  frame.summary = summary
  frame.summaryCards = {}

  for _, kind in ipairs(ORDER) do
    local info = GTUtil.GetKindInfo(kind)
    local card = CreateFrame("Frame", nil, summary, "BackdropTemplate")
    CreateBackdrop(card, { 0.09, 0.10, 0.12, 1 }, { info.accent[1], info.accent[2], info.accent[3], 0.6 })
    card._bg = { 0.09, 0.10, 0.12, 1 }
    card._border = { info.accent[1], info.accent[2], info.accent[3], 0.6 }
    card.label = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    card.label:SetPoint("TOPLEFT", 8, -6)
    card.label:SetText(info.title)
    card.label:SetTextColor(unpack(info.accent))
    card.value = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    card.value:SetPoint("BOTTOMLEFT", 8, 7)
    card.value:SetText("0")
    frame.summaryCards[kind] = card
  end

  local scroll = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, -10)
  scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 40)
  local content = CreateFrame("Frame", nil, scroll)
  content:SetSize(1, 1)
  scroll:SetScrollChild(content)
  frame.scroll = scroll
  frame.content = content
  frame.sections = {}

  for _, kind in ipairs(ORDER) do
    frame.sections[kind] = createSection(content, kind)
  end

  local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  footer:SetPoint("BOTTOMLEFT", 10, 10)
  footer:SetPoint("BOTTOMRIGHT", -10, 10)
  footer:SetHeight(22)
  CreateBackdrop(footer, { 0.09, 0.10, 0.12, 1 }, { 0.20, 0.22, 0.26, 1 })
  footer._bg = { 0.09, 0.10, 0.12, 1 }
  footer._border = { 0.20, 0.22, 0.26, 1 }
  footer.label = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  footer.label:SetPoint("LEFT", 8, 0)
  footer.label:SetText("Bags total")
  footer.value = footer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  footer.value:SetPoint("RIGHT", -8, 0)
  footer.value:SetText("0")
  frame.footer = footer

  local settings = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
  settings:SetFrameStrata("FULLSCREEN_DIALOG")
  settings:SetFrameLevel(500)
  settings:SetSize(240, 110)
  settings:Hide()
  CreateBackdrop(settings, { 0.08, 0.09, 0.11, 0.98 }, { 0.88, 0.74, 0.34, 0.7 })
  local settingsTitle = settings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  settingsTitle:SetPoint("TOP", 0, -12)
  settingsTitle:SetText("Tracker Options")
  local alphaLabel = settings:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  alphaLabel:SetPoint("TOPLEFT", 16, -40)
  alphaLabel:SetText("Transparency")
  local alphaSlider = CreateFrame("Slider", nil, settings, "OptionsSliderTemplate")
  alphaSlider:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -10)
  alphaSlider:SetWidth(150)
  alphaSlider:SetMinMaxValues(0.2, 1)
  alphaSlider:SetValueStep(0.05)
  alphaSlider:SetObeyStepOnDrag(true)
  alphaSlider:SetValue(db.alpha or 0.95)
  alphaSlider:SetScript("OnValueChanged", function(_, value)
    db.alpha = value
    if frame._applyAlpha then frame._applyAlpha(value) end
  end)
  frame.settingsPopup = settings
  settingsBtn:SetScript("OnClick", function()
    local sharedCtx = GTUtil.GetSharedCtx()
    if LegacySettings and LegacySettings.CreatePanel then
      if not frame.legacySettings then
        frame.legacySettings = LegacySettings:CreatePanel(frame, sharedCtx, function(value)
          db.alpha = value
          if frame._applyAlpha then frame._applyAlpha(value) end
        end)
      end
      if frame.legacySettings then
        if frame.legacySettings:IsShown() then
          frame.legacySettings:Hide()
        else
          if LegacySettings.RefreshPanel then
            LegacySettings:RefreshPanel(frame.legacySettings, sharedCtx)
          end
          frame.legacySettings:ClearAllPoints()
          frame.legacySettings:SetPoint("CENTER", frame, "CENTER", 0, 0)
          frame.legacySettings:Show()
          frame.legacySettings:Raise()
        end
      end
      settings:Hide()
      return
    end

    if settings:IsShown() then
      settings:Hide()
    else
      settings:ClearAllPoints()
      settings:SetPoint("TOP", header, "BOTTOM", 0, -8)
      settings:Show()
      settings:Raise()
    end
  end)

  local function syncContentWidth()
    local w = scroll:GetWidth()
    if w and w > 1 then
      content:SetWidth(w)
    end
  end

  local function applyCollapsed()
    local collapsed = db.collapsed and true or false
    local compactMode = IsCompact(GTUtil.GetSharedCtx())
    ApplyModeLayout(frame, compactMode)
    frame.subtitle:SetShown(not collapsed)
    summary:SetShown(not collapsed)
    scroll:SetShown(not collapsed)
    footer:SetShown(not collapsed)
    if frame.resizeGrip then frame.resizeGrip:SetShown(not collapsed) end
    if collapsed then
      hideAuxiliaryPanels(frame)
    end
    if collapsed then
      frame:SetHeight(collapsedHeight)
    else
      ApplyFrameMode(frame, db, compactMode)
    end
    collapseBtn.icon:SetRotation(collapsed and 0 or -1.5708)
  end

  local function layout()
    local compactMode = IsCompact(GTUtil.GetSharedCtx())
    ApplyModeLayout(frame, compactMode)
    local innerWidth = math.max(compactMode and 260 or 320, frame:GetWidth() - 20)
    local summaryGap = 8
    local cardWidth = math.floor((innerWidth - (summaryGap * 2)) / 3)
    local visibleSummaryCards = {}
    for _, kind in ipairs(ORDER) do
      if frame.summaryCards[kind]:IsShown() then
        visibleSummaryCards[#visibleSummaryCards + 1] = frame.summaryCards[kind]
      end
    end

    local prevCard
    local visibleCount = math.max(1, #visibleSummaryCards)
    cardWidth = math.floor((innerWidth - (summaryGap * math.max(0, visibleCount - 1))) / visibleCount)
    for _, card in ipairs(visibleSummaryCards) do
      card:ClearAllPoints()
      card:SetHeight(compactMode and 32 or 42)
      if prevCard then
        card:SetPoint("TOPLEFT", prevCard, "TOPRIGHT", summaryGap, 0)
      else
        card:SetPoint("TOPLEFT", summary, "TOPLEFT", 0, 0)
      end
      card:SetWidth(cardWidth)
      prevCard = card
    end
    if prevCard then
      prevCard:SetPoint("TOPRIGHT", summary, "TOPRIGHT", 0, 0)
    end

    local y = 0
    local sectionWidth = math.max(compactMode and 250 or 300, content:GetWidth() or innerWidth)
    for _, kind in ipairs(ORDER) do
      local section = frame.sections[kind]
      if section:IsShown() then
        section:ClearAllPoints()
        section:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        section:SetWidth(sectionWidth)
        y = y + (section.currentHeight or 118) + 10
      end
    end
    content:SetHeight(math.max(1, y))
  end

  frame._applyAlpha = function(value)
    local showBackgrounds = value >= 0.3
    ApplyBackdropAlpha(frame, frame._bg, frame._border, value, showBackgrounds)
    ApplyBackdropAlpha(header, header._bg, header._border, value, showBackgrounds)
    ApplyBackdropAlpha(collapseBtn, collapseBtn._bg, collapseBtn._border, value, showBackgrounds)
    ApplyBackdropAlpha(settingsBtn, settingsBtn._bg, settingsBtn._border, value, showBackgrounds)
    ApplyBackdropAlpha(farmBtn, farmBtn._bg, farmBtn._border, value, showBackgrounds)
    ApplyBackdropAlpha(close, close._bg, close._border, value, showBackgrounds)
    ApplyBackdropAlpha(footer, footer._bg, footer._border, value, showBackgrounds)
    for _, kind in ipairs(ORDER) do
      local card = frame.summaryCards[kind]
      local section = frame.sections[kind]
      ApplyBackdropAlpha(card, card._bg, card._border, value, showBackgrounds)
      ApplyBackdropAlpha(section, section._bg, section._border, value, showBackgrounds)
      ApplyBackdropAlpha(section.header, section.header._bg, section.header._border, value, showBackgrounds)
    end
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
    local compactMode = IsCompact(GTUtil.GetSharedCtx())
    if compactMode then
      db.compactWidth = frame:GetWidth()
      db.compactHeight = math.max(collapsedHeight, frame:GetHeight())
    else
      db.width = frame:GetWidth()
      db.height = math.max(collapsedHeight, frame:GetHeight())
    end
    syncContentWidth()
    layout()
    Panels:Refresh(nil, GTUtil.GetSharedCtx())
  end)
  frame.resizeGrip = resizeGrip

  scroll:SetScript("OnSizeChanged", function()
    syncContentWidth()
    layout()
  end)
  frame:SetScript("OnSizeChanged", function()
    syncContentWidth()
    layout()
  end)
  frame:HookScript("OnHide", function()
    hideAuxiliaryPanels(frame)
  end)
  frame:HookScript("OnShow", function()
    C_Timer.After(0, function()
      if not frame or not frame:IsShown() then return end
      syncContentWidth()
      layout()
    end)
  end)

  frame._layout = layout

  applyCollapsed()
  frame._applyAlpha(db.alpha or 0.95)

  self.frame = frame
  return frame
end

function Panels:Refresh(_, ctx)
  local frame = self:Create()
  local db = ensureDB()
  ctx = ctx or GTUtil.GetSharedCtx()
  local compactMode = IsCompact(ctx)
  local showIcons = ctx and ctx.showIcons ~= false
  ApplyModeLayout(frame, compactMode)
  if GTUtil.ShouldHideInInstance() then
    if frame:IsShown() then
      hideAuxiliaryPanels(frame)
      frame:Hide()
    end
    return
  end

  local grandTotal = 0
  local visibleCount = 0

  if not db.collapsed then
    ApplyFrameMode(frame, db, compactMode)
  end

  for _, kind in ipairs(ORDER) do
    local items = GTUtil.BuildListForKind(ctx, kind)
    local total = GTUtil.GetTotalForKind(ctx, kind)
    local section = frame.sections[kind]
    local info = GTUtil.GetKindInfo(kind)
    local enabled = GTUtil.IsKindEnabled(ctx, kind)
    frame.summaryCards[kind]:SetShown(enabled)
    section:SetShown(enabled)

    if enabled then
      grandTotal = grandTotal + total
      visibleCount = visibleCount + 1
      frame.summaryCards[kind].value:SetText(LTUtils.FormatNumberCompact(total))
      section.title:SetText(info.title)
      section.total:SetText(LTUtils.FormatNumberCompact(total))
      section.header:SetHeight(compactMode and 22 or 26)
      if items[1] then
        section.sub:SetText((items[1].name or info.title) .. " leading in bags")
        section.footer:SetText("Top stack: " .. (items[1].name or "") .. " x" .. LTUtils.FormatNumberCompact(items[1].count or 0))
      else
        section.sub:SetText("No materials tracked yet")
        section.footer:SetText("Top stack: -")
      end
      section.sub:SetShown(not compactMode)
      section.footer:SetShown(not compactMode)
    else
      for i = 1, #section.rows do
        section.rows[i]:Hide()
      end
      section.empty:Hide()
    end

    if enabled then
      local startY = compactMode and 36 or 58
      local rowStep = compactMode and 18 or 24
      local maxRows = compactMode and 5 or 8
      local y = startY
      for i = 1, math.min(#items, maxRows) do
        local row = section.rows[i]
        if not row then
          row = createRow(section)
          section.rows[i] = row
        end
        local item = items[i]
        row.itemID = item.itemID
        row.icon:SetTexture(item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        row.name:SetText(item.name or ("Item " .. tostring(item.itemID)))
        row.count:SetText(LTUtils.FormatNumberCompact(item.count or 0))
        applyRowLayout(row, compactMode, showIcons)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", section, "TOPLEFT", 8, -y)
        row:SetPoint("TOPRIGHT", section, "TOPRIGHT", -8, -y)
        row:Show()
        y = y + rowStep
      end
      for i = math.min(#items, maxRows) + 1, #section.rows do
        section.rows[i]:Hide()
      end

      if #items == 0 then
        section.empty:ClearAllPoints()
        section.empty:SetPoint("TOPLEFT", section, "TOPLEFT", 10, compactMode and -40 or -62)
        section.empty:Show()
        y = compactMode and 60 or 88
      else
        section.empty:Hide()
      end

      section.currentHeight = compactMode and math.max(62, y + 8) or math.max(118, y + 30)
      section:SetHeight(section.currentHeight)
    end
  end

  frame.summary:SetShown((not db.collapsed) and visibleCount > 0 and not compactMode)
  frame.footer:SetShown((not db.collapsed) and visibleCount > 0 and not compactMode)
  frame.subtitle:SetShown((not db.collapsed) and not compactMode)
  if frame.title then
    frame.title:SetText("Gather Tracker")
  end
  frame.subtitle:SetText(visibleCount > 0 and "One tracker for lumber, ore, and herbs." or "Enable a material in settings to track it here.")
  frame.footer.value:SetText(LTUtils.FormatNumberCompact(grandTotal))
  if frame._layout then
    frame._layout()
  end
end

function Panels:Show()
  local frame = self:Create()
  local db = ensureDB()
  if GTUtil.ShouldHideInInstance() then
    db.open = true
    return
  end
  frame:Show()
  frame:Raise()
  db.open = true
  self:Refresh(nil, GTUtil.GetSharedCtx())
end

function Panels:Hide()
  local frame = self:Create()
  local db = ensureDB()
  hideAuxiliaryPanels(frame)
  frame:Hide()
  db.open = false
end

function Panels:Toggle()
  local frame = self:Create()
  if frame:IsShown() then
    self:Hide()
  else
    self:Show()
  end
end

function Panels:ShowDefaults()
  self:Show()
end

return Panels
