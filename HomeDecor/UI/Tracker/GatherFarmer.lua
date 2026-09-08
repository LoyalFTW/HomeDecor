local _, NS = ...

local GatherTracker = NS.UI.GatherTracker
local Shared = NS.UI.GatherTrackerShared
local Controls = Shared.Controls
local Label = Shared.Label
local Compact = Shared.Compact
local TimeText = Shared.TimeText
local KIND_ORDER = Shared.kindOrder
local KIND_INFO = Shared.kindInfo

function GatherTracker:RefreshFarmer()
  local frame = self.farmer
  if not frame or not frame:IsShown() then self:RefreshHUD() return end
  local system = NS.Systems.GatherTracker
  local state = system:GetState()
  local visible = 0
  local statsByKind = {}
  for _, kind in ipairs(KIND_ORDER) do
    local card = frame.cards[kind]
    local enabled = system:IsKindEnabled(kind)
    card:SetShown(enabled)
    if enabled then
      visible = visible + 1
      local stats = system:GetKindStats(kind)
      statsByKind[kind] = stats
      card.stats = stats
      card.icon:SetTexture(stats.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
      card.name:SetText(stats.name or ("Waiting for " .. KIND_INFO[kind].label:lower()))
      card.meta:SetText("Session: " .. Compact(stats.sessionCount) .. "   Bags: " .. Compact(stats.bagCount) .. "   " .. Compact(stats.rate) .. "/h")
      card.mode:SetText(stats.automatic and "AUTO" or "PINNED")
    else
      card.stats = nil
    end
  end
  frame.time:SetText(TimeText(system:GetSessionElapsed()))
  local hasProgress = system:GetSessionElapsed() > 0 or next(state.session.gained or {}) ~= nil
  frame.startButton:SetText(state.session.active and "Stop" or (hasProgress and "Resume" or "Start"))
  Controls():SetButtonSelected(frame.startButton, state.session.active)
  local fitSignature = tostring(visible) .. ":" .. tostring(GatherTracker:GetSettings().farmerCompact)
  if frame._fitSignature ~= fitSignature then
    frame._fitSignature = fitSignature
    if frame.FitToRows then frame:FitToRows(visible) end
  end
  if frame.LayoutCards then frame:LayoutCards() end
  self:RefreshHUD(statsByKind)
end

function GatherTracker:CreateFarmer()
  if self.farmer then return self.farmer end
  local frame = CreateFrame("Frame", "HomeDecorGatherFarmer", UIParent, "BackdropTemplate")
  frame:Hide()
  frame:SetSize(270, 180)
  frame:SetPoint("CENTER", 0, -180)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(120)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.Systems.Layout:Restore(frame, "gatherFarmer")
  Controls():Backdrop(frame, Controls().colors.background)
  Controls():MakeMovable(frame, frame, "gatherFarmer")
  local title = Label(frame, "GameFontNormal", "accent")
  title:SetPoint("TOPLEFT", 9, -8)
  title:SetText("Gather Farmer")
  frame.time = Label(frame, "GameFontNormalSmall", "accent")
  frame.time:SetPoint("TOPRIGHT", -78, -9)
  frame.time:SetText("0:00")
  local close = Controls():CreateCloseButton(frame, function() GatherTracker:GetSettings().farmerDismissed = true frame:Hide() end, 18, 18)
  close:SetPoint("TOPRIGHT", -5, -5)
  local settingsButton = Controls():CreateButton(frame, "", 18, 18)
  settingsButton:SetPoint("TOPRIGHT", close, "TOPLEFT", -3, 0)
  settingsButton.icon = settingsButton:CreateTexture(nil, "ARTWORK")
  settingsButton.icon:SetPoint("TOPLEFT", 2, -2)
  settingsButton.icon:SetPoint("BOTTOMRIGHT", -2, 2)
  settingsButton.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  local minimize = Controls():CreateButton(frame, "-", 18, 18)
  minimize:SetPoint("TOPRIGHT", settingsButton, "TOPLEFT", -3, 0)
  frame.content = CreateFrame("Frame", nil, frame)
  frame.content:SetPoint("TOPLEFT", 6, -32)
  frame.content:SetPoint("TOPRIGHT", -6, -32)
  frame.content:SetPoint("BOTTOM", 0, 38)
  frame.cards = {}
  for _, kind in ipairs(KIND_ORDER) do
    local card = CreateFrame("Button", nil, frame.content, "BackdropTemplate")
    card:SetHeight(36)
    Controls():Backdrop(card, Controls().colors.row)
    Controls():ApplyHover(card, Controls().colors.row)
    card.kind = kind
    card.icon = card:CreateTexture(nil, "ARTWORK")
    card.icon:SetSize(26, 26)
    card.icon:SetPoint("LEFT", 6, 0)
    card.name = Label(card, "GameFontNormalSmall", "text")
    card.name:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 7, -1)
    card.name:SetPoint("TOPRIGHT", -43, -1)
    card.name:SetHeight(13)
    card.name:SetJustifyH("LEFT")
    card.name:SetJustifyV("TOP")
    card.name:SetWordWrap(false)
    card.meta = Label(card, "GameFontHighlightSmall", "text")
    card.meta:SetPoint("BOTTOMLEFT", card.icon, "BOTTOMRIGHT", 7, 1)
    card.meta:SetPoint("BOTTOMRIGHT", -5, 1)
    card.meta:SetHeight(12)
    card.meta:SetJustifyH("LEFT")
    card.meta:SetJustifyV("BOTTOM")
    card.meta:SetWordWrap(false)
    card.mode = Label(card, "GameFontNormalSmall", "accent")
    card.mode:SetPoint("TOPRIGHT", -5, -3)
    card:SetScript("OnClick", function(self)
      local settings = GatherTracker:GetSettings()
      local current = tonumber(settings.focusByKind[self.kind]) or 0
      NS.UI.Dropdown:Show(self, NS.Systems.GatherTracker:GetKindOptions(self.kind), current, function(value) NS.Systems.GatherTracker:SetFocusItem(self.kind, tonumber(value) or 0) end)
    end)
    card:SetScript("OnEnter", function(self)
      if not self.stats or not self.stats.itemID or not GameTooltip then return end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetItemByID(self.stats.itemID)
      GameTooltip:AddDoubleLine("Session", Compact(self.stats.sessionCount), 0.65, 0.62, 0.56, 1, 1, 1)
      GameTooltip:AddDoubleLine("Bags", Compact(self.stats.bagCount), 0.65, 0.62, 0.56, 1, 1, 1)
      GameTooltip:AddDoubleLine("Overall", Compact(self.stats.overallCount), 0.65, 0.62, 0.56, 1, 1, 1)
      GameTooltip:AddDoubleLine("Per hour", Compact(self.stats.rate), 0.65, 0.62, 0.56, 1, 1, 1)
      GameTooltip:AddLine("Click to follow a specific material or the latest gathered item.", 0.65, 0.62, 0.56, true)
      GameTooltip:Show()
    end)
    card:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
    frame.cards[kind] = card
  end
  local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  footer:SetPoint("BOTTOMLEFT", 6, 6)
  footer:SetPoint("BOTTOMRIGHT", -6, 6)
  footer:SetHeight(26)
  Controls():Backdrop(footer, Controls().colors.header)
  frame.startButton = Controls():CreateButton(footer, "Start", 72, 20)
  frame.startButton:SetPoint("LEFT", 3, 0)
  frame.resetButton = Controls():CreateButton(footer, "Reset", 54, 20)
  frame.resetButton:SetPoint("LEFT", frame.startButton, "RIGHT", 4, 0)
  frame.trackerButton = Controls():CreateButton(footer, "Tracker", 64, 20)
  frame.trackerButton:SetPoint("RIGHT", -20, 0)
  function frame:FitToRows(count)
    count = math.max(0, tonumber(count) or 0)
    local compact = GatherTracker:GetSettings().farmerCompact
    local rowHeight = compact and 25 or 36
    local targetHeight = 70 + (count * rowHeight) + (math.max(0, count - 1) * 3)
    targetHeight = math.max(70, targetHeight)
    if self.SetResizeBounds then self:SetResizeBounds(240, targetHeight, 430, 300) end
    self._hdExpandedHeight = targetHeight
    if not self._hdMinimized then self:SetHeight(targetHeight) end
    NS.Systems.Settings:SetValue("gatherFarmerSize", { width = self:GetWidth(), height = targetHeight })
  end
  function frame:LayoutCards()
    local compact = GatherTracker:GetSettings().farmerCompact
    local shown = {}
    for _, kind in ipairs(KIND_ORDER) do if self.cards[kind]:IsShown() then shown[#shown + 1] = self.cards[kind] end end
    local count = #shown
    if count == 0 then return end
    local gap = 3
    local minimum = compact and 25 or 34
    local maximum = compact and 28 or 40
    local height = math.min(maximum, math.max(minimum, math.floor((self.content:GetHeight() - ((count - 1) * gap)) / count)))
    for index, card in ipairs(shown) do
      card:ClearAllPoints()
      card:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -((index - 1) * (height + gap)))
      card:SetPoint("TOPRIGHT", self.content, "TOPRIGHT", 0, -((index - 1) * (height + gap)))
      card:SetHeight(height)
      card.icon:SetShown(not compact)
      card.mode:SetShown(not compact)
      card.name:ClearAllPoints()
      card.meta:ClearAllPoints()
      if compact then
        card.name:SetPoint("TOPLEFT", 7, -1)
        card.name:SetPoint("TOPRIGHT", -5, -1)
        card.meta:SetPoint("BOTTOMLEFT", 7, 1)
        card.meta:SetPoint("BOTTOMRIGHT", -5, 1)
      else
        card.name:SetPoint("TOPLEFT", card.icon, "TOPRIGHT", 7, -1)
        card.name:SetPoint("TOPRIGHT", -43, -1)
        card.meta:SetPoint("BOTTOMLEFT", card.icon, "BOTTOMRIGHT", 7, 1)
        card.meta:SetPoint("BOTTOMRIGHT", -5, 1)
      end
    end
  end
  frame.startButton:SetScript("OnClick", function() if NS.Systems.GatherTracker:GetState().session.active then NS.Systems.GatherTracker:StopSession() else NS.Systems.GatherTracker:StartSession() end end)
  frame.resetButton:SetScript("OnClick", function() NS.Systems.GatherTracker:ResetSession() end)
  frame.trackerButton:SetScript("OnClick", function() GatherTracker:GetSettings().farmerDismissed = true frame:Hide() GatherTracker:Create():Show() end)
  local options = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  options:SetSize(222, 210)
  options:SetPoint("TOPRIGHT", settingsButton, "BOTTOMRIGHT", 0, -4)
  options:SetFrameLevel(frame:GetFrameLevel() + 20)
  Controls():Backdrop(options, Controls().colors.background)
  local optionsTitle = Label(options, "GameFontNormalSmall", "accent")
  optionsTitle:SetPoint("TOPLEFT", 10, -9)
  optionsTitle:SetText("Farmer Options")
  local checks = {}
  local function Option(label, key, y, changed)
    local check = Controls():CreateCheckButton(options, label)
    check:SetPoint("TOPLEFT", 8, y)
    Controls():TextColor(check.label, "text")
    check:SetScript("OnClick", function(self)
      GatherTracker:GetSettings()[key] = self:GetChecked() == true
      if changed then changed() end
      if GatherTracker.frame and GatherTracker.frame:IsShown() then GatherTracker:Refresh(true) end
      GatherTracker:RefreshFarmer()
    end)
    checks[key] = check
  end
  Option("Track lumber", "trackLumber", -25)
  Option("Track ore", "trackOre", -47)
  Option("Track herbs", "trackHerbs", -69)
  Option("Auto-start when gathering", "autoFarm", -91)
  Option("Compact rows without icons", "farmerCompact", -113, function()
    frame._fitSignature = nil
  end)
  Option("Show minimap farming HUD", "hudEnabled", -135)
  Option("Lock HUD position", "hudLocked", -157, function() GatherTracker:ApplyHUDLock() end)
  local hudSmaller = Controls():CreateButton(options, "HUD Smaller", 98, 22)
  hudSmaller:SetPoint("BOTTOMLEFT", 8, 7)
  hudSmaller:SetScript("OnClick", function()
    local settings = GatherTracker:GetSettings()
    settings.hudSize = math.max(280, settings.hudSize - 40)
    GatherTracker:ApplyHUDSize()
    GatherTracker:RefreshHUD()
  end)
  local hudLarger = Controls():CreateButton(options, "HUD Larger", 98, 22)
  hudLarger:SetPoint("BOTTOMRIGHT", -8, 7)
  hudLarger:SetScript("OnClick", function()
    local settings = GatherTracker:GetSettings()
    settings.hudSize = math.min(620, settings.hudSize + 40)
    GatherTracker:ApplyHUDSize()
    GatherTracker:RefreshHUD()
  end)
  options:SetScript("OnShow", function() local settings = GatherTracker:GetSettings() for key, check in pairs(checks) do check:SetChecked(settings[key] == true) end end)
  Controls():SetTransientAnchor(options, settingsButton)
  Controls():RegisterTransientPopup(options)
  options:Hide()
  settingsButton:SetScript("OnClick", function() Controls():ToggleFrame(options) end)
  NS.SafeRegisterEvent(frame, "PLAYER_LOGOUT", function() frame._loggingOut = true end)
  frame:SetScript("OnShow", function() GatherTracker:GetSettings().farmerOpen = true frame._tick = 0 GatherTracker:RefreshFarmer() end)
  frame:SetScript("OnHide", function() if not frame._loggingOut then GatherTracker:GetSettings().farmerOpen = false end Controls():CloseTransientPopups() end)
  frame:SetScript("OnUpdate", function(self, elapsed)
    if not NS.Systems.GatherTracker:GetState().session.active then return end
    self._tick = (self._tick or 0) + elapsed
    if self._tick >= 1 then self._tick = 0 GatherTracker:RefreshFarmer() end
  end)
  local grip = Controls():CreateResizeGrip(frame, 16)
  grip:SetPoint("BOTTOMRIGHT", -1, 1)
  frame.resizeGrip = grip
  Controls():MakeResizable(frame, grip, { key = "gatherFarmerSize", minWidth = 240, minHeight = 70, maxWidth = 430, maxHeight = 300, onChanged = function() frame:LayoutCards() end })
  Controls():MakeMinimizable(frame, minimize, { key = "gatherFarmerMinimized", height = 28, regions = { frame.content, footer, grip }, expandedHeight = 180, onChanged = function() Controls():CloseTransientPopups() frame:LayoutCards() end })
  frame:HookScript("OnSizeChanged", function() frame:LayoutCards() end)
  self.farmer = frame
  return frame
end

function GatherTracker:ShowFarmer()
  local frame = self:CreateFarmer()
  self:GetSettings().farmerDismissed = false
  frame:Show()
  frame:Raise()
  self:RefreshFarmer()
end

function GatherTracker:ToggleFarmer()
  local frame = self:CreateFarmer()
  if frame:IsShown() then self:GetSettings().farmerDismissed = true frame:Hide() else self:ShowFarmer() end
end

return GatherTracker
