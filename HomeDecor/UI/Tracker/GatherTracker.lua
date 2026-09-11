local _, NS = ...

local GatherTracker = NS.UI.GatherTracker
local Shared = NS.UI.GatherTrackerShared
local Controls = Shared.Controls
local Label = Shared.Label
local Compact = Shared.Compact
local TimeText = Shared.TimeText
local KindLabel = Shared.KindLabel

local ROW_HEIGHT = 38
local ROW_POOL = 15

local SCOPE_OPTIONS = {
  { label = "All Characters", value = "account" },
  { label = "Current Character", value = "character" },
}

local KIND_OPTIONS = {
  { label = "All Materials", value = "all" },
  { label = "Lumber", value = "lumber" },
  { label = "Ore", value = "ore" },
  { label = "Herbs", value = "herb" },
}

local SORT_OPTIONS = {
  { label = "Count: High", value = "countDesc" },
  { label = "Session: High", value = "gainedDesc" },
  { label = "Rate: High", value = "rateDesc" },
  { label = "Goal: Nearest", value = "goalAsc" },
  { label = "Name: A to Z", value = "nameAsc" },
}

local function OptionLabel(options, value)
  for _, option in ipairs(options) do if option.value == value then return option.label end end
  return tostring(value or "")
end

function GatherTracker:GetSettings()
  return NS.Systems.GatherTracker:GetSettings()
end

function GatherTracker:BuildModel()
  local system = NS.Systems.GatherTracker
  local state = system:GetState()
  local settings = self:GetSettings()
  local model = self.model or {}
  wipe(model)
  self.model = model
  local pool = self.modelPool or {}
  self.modelPool = pool
  local search = tostring(settings.search or ""):lower()
  for key, item in pairs(state.items or {}) do
    local itemID = tonumber(item.itemID or key)
    if itemID then
      local name = NS.Systems.ItemResolver:GetName(itemID, item.name or ("Item " .. itemID))
      local searchName = item.searchName
      if not searchName or item.name ~= name then searchName = name:lower() item.name = name item.searchName = searchName end
      local enabled = item.kind == "lumber" and settings.trackLumber or item.kind == "ore" and settings.trackOre or item.kind == "herb" and settings.trackHerbs
      local kindMatch = enabled and (settings.kind == "all" or item.kind == settings.kind)
      local searchMatch = search == "" or searchName:find(search, 1, true)
      local count = system:GetCount(itemID, settings.scope)
      if kindMatch and searchMatch and (not settings.hideZero or count > 0) then
        local position = #model + 1
        local row = pool[position]
        if not row then row = {} pool[position] = row end
        row.itemID = itemID
        row.name = name
        row.searchName = searchName
        row.icon = item.icon or NS.Systems.ItemResolver:GetIcon(itemID)
        row.kind = item.kind
        row.count = count
        row.gained = system:GetSessionGain(itemID)
        row.rate = system:GetRate(itemID)
        row.goal = tonumber(state.goals[tostring(itemID)]) or 0
        row.remaining = row.goal > 0 and math.max(0, row.goal - row.count) or math.huge
        model[position] = row
      end
    end
  end
  local sort = settings.sort or "countDesc"
  table.sort(model, function(left, right)
    if sort == "nameAsc" then return left.searchName < right.searchName end
    local keyName = sort:match("^(.-)Asc$") or sort:match("^(.-)Desc$") or "count"
    if keyName == "goal" then keyName = "remaining" end
    local a, b = tonumber(left[keyName]) or 0, tonumber(right[keyName]) or 0
    if a == b then return left.name < right.name end
    return sort:sub(-3) == "Asc" and a < b or a > b
  end)
end

function GatherTracker:CreateRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  Controls():Backdrop(row, Controls().colors.row)
  Controls():ApplyHover(row, Controls().colors.row)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(26, 26)
  row.icon:SetPoint("LEFT", 6, 0)
  row.name = Label(row, "GameFontNormalSmall", "text")
  row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -3)
  row.name:SetPoint("TOPRIGHT", -218, -3)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.kind = Label(row, "GameFontDisableSmall", "muted")
  row.kind:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMRIGHT", 7, 3)
  row.count = Label(row, "GameFontNormal", "accent")
  row.count:SetPoint("RIGHT", -173, 0)
  row.count:SetWidth(38)
  row.count:SetJustifyH("RIGHT")
  row.gained = Label(row, "GameFontNormalSmall", "success")
  row.gained:SetPoint("RIGHT", -130, 0)
  row.gained:SetWidth(38)
  row.gained:SetJustifyH("RIGHT")
  row.rate = Label(row, "GameFontDisableSmall", "muted")
  row.rate:SetPoint("RIGHT", -80, 0)
  row.rate:SetWidth(45)
  row.rate:SetJustifyH("RIGHT")
  row.goal = Label(row, "GameFontNormalSmall", "text")
  row.goal:SetPoint("RIGHT", -24, 0)
  row.goal:SetWidth(30)
  row.goal:SetJustifyH("RIGHT")
  row.minus = Controls():CreateButton(row, "-", 20, 20)
  row.minus:SetSize(18, 18)
  row.minus:SetPoint("RIGHT", row.goal, "LEFT", -2, 0)
  row.plus = Controls():CreateButton(row, "+", 20, 20)
  row.plus:SetSize(18, 18)
  row.plus:SetPoint("RIGHT", -4, 0)
  row.minus:SetScript("OnClick", function(self)
    local data = self:GetParent().data
    if data then NS.Systems.GatherTracker:SetGoal(data.itemID, math.max(0, data.goal - 10)) end
  end)
  row.plus:SetScript("OnClick", function(self)
    local data = self:GetParent().data
    if data then NS.Systems.GatherTracker:SetGoal(data.itemID, data.goal + 10) end
  end)
  row:SetScript("OnClick", function(self)
    if not self.data then return end
    if HandleModifiedItemClick then HandleModifiedItemClick("item:" .. self.data.itemID) end
  end)
  row:SetScript("OnEnter", function(self)
    if not self.data or not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(self.data.itemID)
    GameTooltip:AddDoubleLine("Tracked", KindLabel(self.data.kind), 0.65, 0.62, 0.56, 1, 0.76, 0.08)
    GameTooltip:AddDoubleLine("Session gained", Compact(self.data.gained), 0.65, 0.62, 0.56, 0.36, 0.92, 0.52)
    GameTooltip:AddDoubleLine("Per hour", Compact(self.data.rate), 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  Controls():ForwardScrollWheel(row, scroll)
  Controls():ForwardScrollWheel(row.minus, scroll)
  Controls():ForwardScrollWheel(row.plus, scroll)
  return row
end

function GatherTracker:RenderRows()
  local frame = self.frame
  local model = self.model or {}
  local first = math.max(1, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT) + 1)
  for index, row in ipairs(frame.rows) do
    local absolute = first + index - 1
    local data = model[absolute]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((absolute - 1) * ROW_HEIGHT))
    row.data = data
    row:SetShown(data ~= nil)
    if data then
      row.icon:SetTexture(data.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
      row.name:SetText(data.name)
      row.kind:SetText(KindLabel(data.kind))
      row.count:SetText(Compact(data.count))
      row.gained:SetText(data.gained > 0 and ("+" .. Compact(data.gained)) or "--")
      row.rate:SetText(data.rate > 0 and (Compact(data.rate) .. "/h") or "--")
      row.goal:SetText(data.goal > 0 and Compact(data.goal) or "--")
    end
  end
end

function GatherTracker:Refresh(resetScroll)
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  if resetScroll then Controls():ResetScrollFrame(frame.scroll, false) end
  self:BuildModel()
  local settings = self:GetSettings()
  local system = NS.Systems.GatherTracker
  local total, gained, rate = 0, 0, 0
  for _, row in ipairs(self.model) do total = total + row.count gained = gained + row.gained rate = rate + row.rate end
  frame.totalValue:SetText(Compact(total))
  frame.gainedValue:SetText(Compact(gained))
  frame.rateValue:SetText(Compact(rate) .. "/h")
  frame.timeValue:SetText(TimeText(system:GetSessionElapsed()))
  frame.scopeButton:SetText(OptionLabel(SCOPE_OPTIONS, settings.scope))
  frame.kindButton:SetText(OptionLabel(KIND_OPTIONS, settings.kind))
  frame.sortButton:SetText(OptionLabel(SORT_OPTIONS, settings.sort))
  frame.hideZero:SetChecked(settings.hideZero == true)
  local session = system:GetState().session
  local hasProgress = system:GetSessionElapsed() > 0 or next(session.gained or {}) ~= nil
  frame.sessionButton:SetText(session.active and "Stop Session" or (hasProgress and "Resume Session" or "Start Session"))
  Controls():SetButtonSelected(frame.sessionButton, system:GetState().session.active)
  frame.resultCount:SetText(#self.model .. " materials")
  frame.content:SetHeight(math.max(1, #self.model * ROW_HEIGHT))
  frame.empty:SetShown(#self.model == 0)
  Controls():SyncScrollFrame(frame.scroll)
  self:RenderRows()
end

function GatherTracker:Create()
  if self.frame then return self.frame end
  local frame = CreateFrame("Frame", "HomeDecorGatherTracker", UIParent, "BackdropTemplate")
  frame:Hide()
  frame:SetSize(410, 500)
  frame:SetPoint("RIGHT", -34, 0)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(100)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.Systems.Layout:Restore(frame, "gatherTracker")
  Controls():Backdrop(frame, Controls().colors.background)
  Controls():MakeMovable(frame, frame, "gatherTracker")
  local title = Label(frame, "GameFontNormal", "accent")
  title:SetPoint("TOPLEFT", 10, -8)
  title:SetText("Gather Tracker")
  frame.titleText = title
  frame.resultCount = Label(frame, "GameFontHighlightSmall", "muted")
  frame.resultCount:SetPoint("TOPRIGHT", -82, -10)
  local close = Controls():CreateCloseButton(frame, function() frame:Hide() end, 20, 20)
  close:SetPoint("TOPRIGHT", -6, -5)
  local settingsButton = Controls():CreateButton(frame, "", 20, 20)
  settingsButton:SetPoint("TOPRIGHT", close, "TOPLEFT", -4, 0)
  settingsButton.icon = settingsButton:CreateTexture(nil, "ARTWORK")
  settingsButton.icon:SetPoint("TOPLEFT", 2, -2)
  settingsButton.icon:SetPoint("BOTTOMRIGHT", -2, 2)
  settingsButton.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  local minimize = Controls():CreateButton(frame, "-", 20, 20)
  minimize:SetPoint("TOPRIGHT", settingsButton, "TOPLEFT", -4, 0)
  local toolbar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  toolbar:SetPoint("TOPLEFT", 7, -33)
  toolbar:SetPoint("TOPRIGHT", -7, -33)
  toolbar:SetHeight(30)
  Controls():Backdrop(toolbar, Controls().colors.header)
  frame.search = Controls():CreateSearchBox(toolbar, {
    height = 22,
    placeholder = "Search materials",
    text = self:GetSettings().search or "",
    onChanged = function(self) GatherTracker:GetSettings().search = self:GetText() or "" GatherTracker:Refresh(true) end,
  })
  frame.search:SetPoint("TOPLEFT", 5, -4)
  frame.scopeButton = Controls():CreateButton(toolbar, "", 102, 22)
  frame.scopeButton:SetPoint("TOPRIGHT", -92, -4)
  frame.kindButton = Controls():CreateButton(toolbar, "", 82, 22)
  frame.kindButton:SetPoint("TOPRIGHT", -5, -4)
  frame.search:SetPoint("BOTTOMRIGHT", frame.scopeButton, "BOTTOMLEFT", -5, 0)
  local metrics = CreateFrame("Frame", nil, frame)
  metrics:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -5)
  metrics:SetPoint("TOPRIGHT", toolbar, "BOTTOMRIGHT", 0, -5)
  metrics:SetHeight(38)
  local metricLabels = { "TOTAL", "SESSION", "PER HOUR", "TIME" }
  local valueKeys = { "totalValue", "gainedValue", "rateValue", "timeValue" }
  frame.metricCards = {}
  for index, text in ipairs(metricLabels) do
    local card = CreateFrame("Frame", nil, metrics, "BackdropTemplate")
    card:SetPoint("TOP", 0, 0)
    card:SetPoint("BOTTOM", 0, 0)
    Controls():Backdrop(card, Controls().colors.panel)
    local label = Label(card, "GameFontDisableSmall", "muted")
    label:SetPoint("TOPLEFT", 7, -4)
    label:SetText(text)
    frame[valueKeys[index]] = Label(card, "GameFontNormalSmall", index == 2 and "success" or "accent")
    frame[valueKeys[index]]:SetPoint("BOTTOMLEFT", 7, 5)
    frame.metricCards[index] = card
  end
  local columns = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  columns:SetPoint("TOPLEFT", metrics, "BOTTOMLEFT", 0, -5)
  columns:SetPoint("TOPRIGHT", metrics, "BOTTOMRIGHT", -17, -5)
  columns:SetHeight(21)
  Controls():Backdrop(columns, Controls().colors.panel)
  local materialHeader = Label(columns, "GameFontDisableSmall", "muted")
  materialHeader:SetPoint("LEFT", 39, 0)
  materialHeader:SetText("MATERIAL")
  local countHeader = Label(columns, "GameFontDisableSmall", "muted")
  countHeader:SetPoint("RIGHT", -173, 0)
  countHeader:SetWidth(38)
  countHeader:SetJustifyH("RIGHT")
  countHeader:SetText("COUNT")
  local gainHeader = Label(columns, "GameFontDisableSmall", "muted")
  gainHeader:SetPoint("RIGHT", -130, 0)
  gainHeader:SetWidth(38)
  gainHeader:SetJustifyH("RIGHT")
  gainHeader:SetText("GAIN")
  local rateHeader = Label(columns, "GameFontDisableSmall", "muted")
  rateHeader:SetPoint("RIGHT", -80, 0)
  rateHeader:SetWidth(45)
  rateHeader:SetJustifyH("RIGHT")
  rateHeader:SetText("RATE")
  local goalHeader = Label(columns, "GameFontDisableSmall", "muted")
  goalHeader:SetPoint("RIGHT", -4, 0)
  goalHeader:SetWidth(70)
  goalHeader:SetJustifyH("CENTER")
  goalHeader:SetText("GOAL")
  frame.scroll = Controls():CreateScrollFrame(frame)
  frame.scroll:SetPoint("TOPLEFT", columns, "BOTTOMLEFT", 0, -4)
  frame.scroll:SetPoint("BOTTOMRIGHT", -22, 43)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(370, 1)
  Controls():ConfigureScrollFrame(frame.scroll, frame.content, { step = ROW_HEIGHT, barInset = -18, onScroll = function() GatherTracker:RenderRows() end })
  frame.rows = {}
  for index = 1, ROW_POOL do frame.rows[index] = self:CreateRow(frame.content, frame.scroll) end
  frame.empty = Label(frame, "GameFontNormalSmall", "muted")
  frame.empty:SetPoint("CENTER", frame.scroll)
  frame.empty:SetText("No gathering materials match these filters.")
  local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  footer:SetPoint("BOTTOMLEFT", 7, 7)
  footer:SetPoint("BOTTOMRIGHT", -7, 7)
  footer:SetHeight(31)
  Controls():Backdrop(footer, Controls().colors.header)
  frame.sessionButton = Controls():CreateButton(footer, "Start Session", 104, 22)
  frame.sessionButton:SetPoint("LEFT", 5, 0)
  frame.farmButton = Controls():CreateButton(footer, "Farm", 54, 22)
  frame.farmButton:SetPoint("LEFT", frame.sessionButton, "RIGHT", 5, 0)
  frame.resetButton = Controls():CreateButton(footer, "Reset", 58, 22)
  frame.resetButton:SetPoint("LEFT", frame.farmButton, "RIGHT", 5, 0)
  frame.scanButton = Controls():CreateButton(footer, "Rescan", 68, 22)
  frame.scanButton:SetPoint("RIGHT", -5, 0)
  local options = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  options:SetSize(224, 200)
  options:SetPoint("TOPRIGHT", settingsButton, "BOTTOMRIGHT", 0, -4)
  options:SetFrameLevel(frame:GetFrameLevel() + 20)
  Controls():Backdrop(options, Controls().colors.background)
  local optionsTitle = Label(options, "GameFontNormalSmall", "accent")
  optionsTitle:SetPoint("TOPLEFT", 10, -9)
  optionsTitle:SetText("Gather Tracker Options")
  local function CreateOption(label, key, y)
    local check = Controls():CreateCheckButton(options, label)
    check:SetPoint("TOPLEFT", 8, y)
    Controls():TextColor(check.label, "text")
    check:SetScript("OnClick", function(self) GatherTracker:GetSettings()[key] = self:GetChecked() == true GatherTracker:Refresh(true) GatherTracker:RefreshFarmer() end)
    return check
  end
  frame.trackLumber = CreateOption("Track lumber", "trackLumber", -25)
  frame.trackOre = CreateOption("Track ore", "trackOre", -47)
  frame.trackHerbs = CreateOption("Track herbs", "trackHerbs", -69)
  frame.hideZero = CreateOption("Hide materials with zero", "hideZero", -91)
  frame.autoStart = CreateOption("Auto-start on first gain", "autoFarm", -113)
  frame.hudEnabled = CreateOption("Show minimap farming HUD", "hudEnabled", -135)
  frame.sortButton = Controls():CreateButton(options, "", 204, 24)
  frame.sortButton:SetPoint("BOTTOM", 0, 8)
  options:SetScript("OnShow", function()
    local settings = GatherTracker:GetSettings()
    frame.trackLumber:SetChecked(settings.trackLumber)
    frame.trackOre:SetChecked(settings.trackOre)
    frame.trackHerbs:SetChecked(settings.trackHerbs)
    frame.hideZero:SetChecked(settings.hideZero)
    frame.autoStart:SetChecked(settings.autoFarm)
    frame.hudEnabled:SetChecked(settings.hudEnabled)
  end)
  Controls():SetTransientAnchor(options, settingsButton)
  Controls():RegisterTransientPopup(options)
  options:Hide()
  settingsButton:SetScript("OnClick", function() Controls():ToggleFrame(options) end)
  frame.scopeButton:SetScript("OnClick", function(self) NS.UI.Dropdown:Show(self, SCOPE_OPTIONS, GatherTracker:GetSettings().scope, function(value) GatherTracker:GetSettings().scope = value GatherTracker:Refresh(true) end) end)
  frame.kindButton:SetScript("OnClick", function(self) NS.UI.Dropdown:Show(self, KIND_OPTIONS, GatherTracker:GetSettings().kind, function(value) GatherTracker:GetSettings().kind = value GatherTracker:Refresh(true) end) end)
  frame.sortButton:SetScript("OnClick", function(self) NS.UI.Dropdown:Show(self, SORT_OPTIONS, GatherTracker:GetSettings().sort, function(value) GatherTracker:GetSettings().sort = value GatherTracker:Refresh(true) end) end)
  frame.sessionButton:SetScript("OnClick", function() if NS.Systems.GatherTracker:GetState().session.active then NS.Systems.GatherTracker:StopSession() else NS.Systems.GatherTracker:StartSession() GatherTracker:ShowFarmer() end end)
  frame.farmButton:SetScript("OnClick", function() GatherTracker:ToggleFarmer() end)
  frame.resetButton:SetScript("OnClick", function() NS.Systems.GatherTracker:ResetSession() end)
  frame.scanButton:SetScript("OnClick", function() NS.Systems.GatherTracker:ScanBags() end)
  frame:SetScript("OnShow", function(self)
    if NS.UI.CatalogView and NS.UI.CatalogView.frame then Controls():SetButtonSelected(NS.UI.CatalogView.frame.gatherButton, true) end
    NS.Systems.GatherTracker:ScanBags()
    self._tick = 0
    GatherTracker:Refresh(true)
  end)
  frame:SetScript("OnHide", function(self)
    if NS.UI.CatalogView and NS.UI.CatalogView.frame then Controls():SetButtonSelected(NS.UI.CatalogView.frame.gatherButton, false) end
    Controls():CloseTransientPopups()
    self.search:ClearFocus()
  end)
  frame:SetScript("OnUpdate", function(self, elapsed) self._tick = (self._tick or 0) + elapsed if self._tick >= 1 then self._tick = 0 if NS.Systems.GatherTracker:GetState().session.active then GatherTracker:Refresh(false) end end end)
  local grip = Controls():CreateResizeGrip(frame, 18)
  grip:SetPoint("BOTTOMRIGHT", -1, 1)
  frame.resizeGrip = grip
  local function Layout()
    local available = math.max(320, metrics:GetWidth())
    local cardWidth = math.floor((available - 9) / 4)
    for index, card in ipairs(frame.metricCards) do
      card:ClearAllPoints()
      card:SetPoint("TOP", 0, 0)
      card:SetPoint("BOTTOM", 0, 0)
      if index == 1 then card:SetPoint("LEFT", 0, 0) else card:SetPoint("LEFT", frame.metricCards[index - 1], "RIGHT", 3, 0) end
      if index == 4 then card:SetPoint("RIGHT", 0, 0) else card:SetWidth(cardWidth) end
    end
    frame.content:SetWidth(math.max(1, frame.scroll:GetWidth() - 2))
    GatherTracker:RenderRows()
  end
  self.frame = frame
  Controls():MakeResizable(frame, grip, {
    key = "gatherTrackerSize",
    minWidth = 370,
    minHeight = 330,
    maxWidth = 620,
    maxHeight = 820,
    onChanged = Layout,
  })
  minimize:SetScript("OnClick", function() frame:Hide() GatherTracker:ShowFarmer() end)
  frame:HookScript("OnSizeChanged", Layout)
  frame:HookScript("OnShow", Layout)
  Layout()
  self.frame = frame
  return frame
end

function GatherTracker:Toggle()
  local frame = self:Create()
  Controls():ToggleFrame(frame)
end

NS.OnMessage("HOMEDECOR_GATHER_UPDATED", function()
  if GatherTracker.frame and GatherTracker.frame:IsShown() then GatherTracker:Refresh(false) end
  local settings = GatherTracker:GetSettings()
  if settings.autoFarm and not settings.farmerDismissed and NS.Systems.GatherTracker:GetState().session.active and (not GatherTracker.farmer or not GatherTracker.farmer:IsShown()) then GatherTracker:ShowFarmer() else GatherTracker:RefreshFarmer() end
end)

NS.Systems.ItemResolver:Subscribe(GatherTracker, function()
  if GatherTracker.frame and GatherTracker.frame:IsShown() then GatherTracker:Refresh(false) end
  GatherTracker:RefreshFarmer()
end)

NS.SafeRegisterEvent(GatherTracker, "PLAYER_LOGIN", function()
  C_Timer.After(1.2, function()
    local settings = GatherTracker:GetSettings()
    if not settings.farmerOpen and not settings.hudEnabled then return end
    GatherTracker:Create()
    if settings.farmerOpen then GatherTracker:ShowFarmer() else GatherTracker:RefreshHUD() end
  end)
end)

return GatherTracker
