local _, NS = ...

NS.UI = NS.UI or {}
local EndeavorsUI = {}
NS.UI.Endeavors = EndeavorsUI

local TASK_ROW_HEIGHT = 34
local TASK_ROW_COUNT = 15
local DETAIL_ROW_HEIGHT = 25
local DETAIL_ROW_COUNT = 18

local TASK_COLUMNS = {
  { key = "tracked", label = "TRACK", width = 48, align = "CENTER" },
  { key = "name", label = "TASK", width = 180, flex = true, align = "LEFT" },
  { key = "progress", label = "PROGRESS", width = 92, align = "RIGHT" },
  { key = "points", label = "XP", width = 62, align = "RIGHT" },
  { key = "coupons", label = "COUPONS", width = 72, align = "RIGHT" },
  { key = "nextContribution", label = "NEXT", width = 66, align = "RIGHT" },
  { key = "accountCompletions", label = "DONE", width = 54, align = "RIGHT" },
}

local DETAIL_COLUMNS = {
  activity = {
    { key = "time", label = "TIME", width = 52, align = "LEFT" },
    { key = "player", label = "PLAYER", width = 90, align = "LEFT" },
    { key = "task", label = "TASK", width = 120, flex = true, align = "LEFT" },
    { key = "amount", label = "PTS", width = 52, align = "RIGHT" },
  },
  leaderboard = {
    { key = "rank", label = "RANK", width = 52, align = "CENTER" },
    { key = "player", label = "PLAYER", width = 140, flex = true, align = "LEFT" },
    { key = "amount", label = "CONTRIBUTION", width = 96, align = "RIGHT" },
  },
  coupons = {
    { key = "time", label = "TIME", width = 52, align = "LEFT" },
    { key = "player", label = "CHARACTER", width = 86, align = "LEFT" },
    { key = "task", label = "TASK", width = 110, flex = true, align = "LEFT" },
    { key = "amount", label = "GAIN", width = 52, align = "RIGHT" },
  },
}

local function Controls()
  return NS.UI and NS.UI.Controls
end

local function System()
  return NS.Systems and NS.Systems.Endeavors
end

local function Colors()
  return Controls().colors
end

local function Backdrop(frame, background, border)
  Controls():Backdrop(frame, background, border)
end

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
  Controls():TextColor(text, role or "text")
  return text
end

local function Button(parent, label, width, height)
  return Controls():CreateButton(parent, label, width or 90, height or 24)
end

local function Metric(parent, label)
  local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  card:SetHeight(54)
  Backdrop(card, Colors().panel, Colors().border)
  card.label = Font(card, "GameFontNormalSmall", "muted")
  card.label:SetPoint("TOPLEFT", 11, -8)
  card.label:SetText(label)
  card.value = Font(card, "GameFontNormalLarge", "accent")
  card.value:SetPoint("BOTTOMLEFT", 11, 8)
  card.value:SetPoint("RIGHT", -8, 0)
  card.value:SetJustifyH("LEFT")
  card.value:SetText("--")
  return card
end

local function FormatNumber(value)
  value = tonumber(value) or 0
  if value >= 1000000 then return string.format("%.1fm", value / 1000000) end
  if value >= 1000 then return string.format("%.1fk", value / 1000) end
  return tostring(math.floor(value + 0.5))
end

local function FormatAgo(timestamp)
  local elapsed = math.max(0, time() - (tonumber(timestamp) or time()))
  if elapsed < 60 then return "<1m" end
  if elapsed < 3600 then return tostring(math.floor(elapsed / 60)) .. "m" end
  if elapsed < 86400 then return tostring(math.floor(elapsed / 3600)) .. "h" end
  return tostring(math.floor(elapsed / 86400)) .. "d"
end

local function SortValue(value)
  if type(value) == "boolean" then return value and 1 or 0 end
  if type(value) == "string" then return value:lower() end
  return tonumber(value) or 0
end

local function SortRows(rows, key, descending, getter)
  table.sort(rows, function(a, b)
    local left = SortValue(getter(a, key))
    local right = SortValue(getter(b, key))
    if left == right then
      local leftName = tostring(a.name or a.taskName or a.playerName or ""):lower()
      local rightName = tostring(b.name or b.taskName or b.playerName or ""):lower()
      if leftName == rightName then return (tonumber(a.id or a.taskID) or 0) < (tonumber(b.id or b.taskID) or 0) end
      return leftName < rightName
    end
    if descending then return left > right end
    return left < right
  end)
end

local function SetHeaderLabel(button, label, active, descending)
  button:SetText(active and (label .. (descending and "  v" or "  ^")) or label)
  Controls():SetButtonSelected(button, active)
end

local function CreateProgressBar(parent)
  local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
  bar:SetHeight(22)
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0)
  Backdrop(bar, Colors().background, Colors().accent)
  local fill = bar:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints()
  fill:SetAtlas("housing-dashboard-fillbar-fill")
  bar:SetStatusBarTexture(fill)
  bar.text = Font(bar, "GameFontNormalSmall", "text")
  bar.text:SetPoint("CENTER")
  bar.markers = {}
  for index = 1, 6 do
    local marker = CreateFrame("Frame", nil, bar)
    marker:SetSize(22, 28)
    marker:SetPoint("CENTER", bar, "LEFT", index * 40, 0)
    marker:SetFrameLevel(bar:GetFrameLevel() + 3)
    marker.incomplete = marker:CreateTexture(nil, "OVERLAY")
    marker.incomplete:SetSize(20, 20)
    marker.incomplete:SetPoint("CENTER")
    marker.incomplete:SetAtlas("housing-dashboard-fillbar-pip-incomplete")
    marker.complete = marker:CreateTexture(nil, "OVERLAY")
    marker.complete:SetSize(20, 20)
    marker.complete:SetPoint("CENTER")
    marker.complete:SetAtlas("housing-dashboard-fillbar-pip-complete")
    marker.tick = marker:CreateTexture(nil, "ARTWORK")
    marker.tick:SetSize(2, 27)
    marker.tick:SetPoint("CENTER")
    marker.check = marker:CreateTexture(nil, "OVERLAY")
    marker.check:SetSize(13, 13)
    marker.check:SetPoint("CENTER", 5, -5)
    marker.check:SetAtlas("housing-dashboard-small-checkmark")
    marker.reward = marker:CreateTexture(nil, "OVERLAY")
    marker.reward:SetSize(26, 26)
    marker.reward:SetPoint("CENTER")
    marker.reward:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    marker:Hide()
    bar.markers[index] = marker
  end
  return bar
end

local function CreateTaskRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(TASK_ROW_HEIGHT - 2)
  Backdrop(row, Colors().row, { 0.16, 0.14, 0.07, 0.7 })
  Controls():ApplyHover(row, Colors().row, Colors().hover)
  row.state = row:CreateTexture(nil, "ARTWORK")
  row.state:SetPoint("TOPLEFT")
  row.state:SetPoint("BOTTOMLEFT")
  row.state:SetWidth(2)
  row.track = Button(row, "T", 24, 20)
  row.track:SetPoint("LEFT", 9, 0)
  row.cells = {}
  for _, column in ipairs(TASK_COLUMNS) do
    if column.key ~= "tracked" then
      local text = Font(row, column.key == "name" and "GameFontNormal" or "GameFontNormalSmall", column.key == "name" and "text" or "muted")
      text:SetJustifyH(column.align)
      text:SetWordWrap(false)
      row.cells[column.key] = text
    end
  end
  row.couponIcon = row:CreateTexture(nil, "OVERLAY")
  row.couponIcon:SetSize(14, 14)
  row.couponIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  row.track:SetScript("OnClick", function()
    if row.task then System():TrackTask(row.task.id, not row.task.tracked) end
  end)
  row:SetScript("OnEnter", function(self)
    if not self.task or not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.task.name or "Endeavor task", 1, 0.76, 0.08)
    if self.task.description ~= "" then GameTooltip:AddLine(self.task.description, 0.93, 0.91, 0.85, true) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Account completions", tostring(self.task.accountCompletions or 0), 0.64, 0.62, 0.56, 1, 1, 1)
    GameTooltip:AddDoubleLine("Character completions", tostring(self.task.playerCompletions or 0), 0.64, 0.62, 0.56, 1, 1, 1)
    GameTooltip:AddLine(self.task.repeatable and "Repeatable" or "One-time", 0.64, 0.62, 0.56)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  Controls():ForwardScrollWheel(row, scroll)
  Controls():ForwardScrollWheel(row.track, scroll)
  row:Hide()
  return row
end

local function CreateDetailRow(parent, scroll)
  local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  row:SetHeight(DETAIL_ROW_HEIGHT - 2)
  Backdrop(row, Colors().row, { 0.15, 0.13, 0.06, 0.65 })
  row.cells = {}
  for _, key in ipairs({ "time", "rank", "player", "task", "amount" }) do
    local text = Font(row, "GameFontNormalSmall", key == "amount" and "success" or "text")
    text:SetWordWrap(false)
    row.cells[key] = text
  end
  Controls():ForwardScrollWheel(row, scroll)
  row:Hide()
  return row
end

function EndeavorsUI:GetSettings()
  return System():GetSettings()
end

function EndeavorsUI:SetTaskSort(key)
  local sort = self:GetSettings().sort
  if sort.key == key then sort.descending = not sort.descending else sort.key = key sort.descending = key ~= "name" and key ~= "default" end
  Controls():ResetScrollFrame(self.panel.taskScroll, false)
  self:RenderTasks()
end

function EndeavorsUI:SetDetailSort(key)
  local field = self.detailTab == "activity" and "activitySort" or self.detailTab == "leaderboard" and "leaderboardSort" or "couponSort"
  local sort = self:GetSettings()[field]
  if sort.key == key then sort.descending = not sort.descending else sort.key = key sort.descending = key ~= "player" and key ~= "task" end
  Controls():ResetScrollFrame(self.panel.detailScroll, false)
  self:RenderDetails()
end

function EndeavorsUI:LayoutColumns()
  local frame = self.panel
  if not frame then return end
  local taskWidth = math.max(600, frame.taskScroll:GetWidth() or 700)
  local fixed = 8
  for _, column in ipairs(TASK_COLUMNS) do if not column.flex then fixed = fixed + column.width end end
  local flexible = math.max(150, taskWidth - fixed)
  local x = 0
  for _, column in ipairs(TASK_COLUMNS) do
    column.currentWidth = column.flex and flexible or column.width
    column.x = x
    local header = frame.taskHeaders[column.key]
    header:ClearAllPoints()
    header:SetPoint("LEFT", frame.taskColumns, "LEFT", x, 0)
    header:SetWidth(column.currentWidth - 3)
    x = x + column.currentWidth
  end
  for _, row in ipairs(frame.taskRows) do
    for _, column in ipairs(TASK_COLUMNS) do
      if column.key ~= "tracked" then
        local cell = row.cells[column.key]
        cell:ClearAllPoints()
        cell:SetPoint("LEFT", row, "LEFT", column.x + 4, 0)
        cell:SetWidth(column.currentWidth - 8)
      end
    end
    local couponColumn
    for _, column in ipairs(TASK_COLUMNS) do if column.key == "coupons" then couponColumn = column break end end
    if couponColumn then
      row.couponIcon:ClearAllPoints()
      row.couponIcon:SetPoint("LEFT", row, "LEFT", couponColumn.x + 5, 0)
      row.cells.coupons:ClearAllPoints()
      row.cells.coupons:SetPoint("LEFT", row.couponIcon, "RIGHT", 3, 0)
      row.cells.coupons:SetWidth(couponColumn.currentWidth - 24)
    end
  end
  local detailColumns = DETAIL_COLUMNS[self.detailTab or "activity"]
  local detailWidth = math.max(260, frame.detailScroll:GetWidth() or 300)
  fixed = 4
  for _, column in ipairs(detailColumns) do if not column.flex then fixed = fixed + column.width end end
  flexible = math.max(90, detailWidth - fixed)
  x = 0
  for _, header in pairs(frame.detailHeaders) do header:Hide() end
  for _, column in ipairs(detailColumns) do
    column.currentWidth = column.flex and flexible or column.width
    column.x = x
    local header = frame.detailHeaders[column.key]
    header:ClearAllPoints()
    header:SetPoint("LEFT", frame.detailColumns, "LEFT", x, 0)
    header:SetWidth(column.currentWidth - 3)
    header:Show()
    x = x + column.currentWidth
  end
  for _, row in ipairs(frame.detailRows) do
    for _, cell in pairs(row.cells) do cell:Hide() end
    for _, column in ipairs(detailColumns) do
      local cell = row.cells[column.key]
      cell:ClearAllPoints()
      cell:SetPoint("LEFT", row, "LEFT", column.x + 4, 0)
      cell:SetWidth(column.currentWidth - 8)
      cell:SetJustifyH(column.align)
    end
  end
end

function EndeavorsUI:BuildTaskView()
  local settings = self:GetSettings()
  local query = tostring(self.panel.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local filter = self.taskFilter or "all"
  local view = self.taskView or {}
  local count = 0
  for _, task in ipairs(System():GetTasks() or {}) do
    local include = (query == "" or tostring(task.name):lower():find(query, 1, true) or tostring(task.description):lower():find(query, 1, true))
      and (filter == "all" or filter == "tracked" and task.tracked or filter == "complete" and task.completed or filter == "progress" and task.inProgress and not task.completed or filter == "available" and not task.completed)
    if include then count = count + 1 view[count] = task end
  end
  for index = count + 1, #view do view[index] = nil end
  local sort = settings.sort
  SortRows(view, sort.key, sort.descending, function(task, key)
    if key == "default" then return task.sortOrder end
    return task[key]
  end)
  self.taskView = view
  return view
end

function EndeavorsUI:RenderTasks()
  local frame = self.panel
  if not frame or not frame:IsShown() then return end
  local view = self:BuildTaskView()
  local sort = self:GetSettings().sort
  for _, column in ipairs(TASK_COLUMNS) do SetHeaderLabel(frame.taskHeaders[column.key], column.label, sort.key == column.key, sort.descending) end
  frame.taskCount:SetText(tostring(#view) .. " tasks")
  frame.taskContent:SetHeight(math.max(1, #view * TASK_ROW_HEIGHT))
  local first = math.max(0, math.floor((frame.taskScroll:GetVerticalScroll() or 0) / TASK_ROW_HEIGHT))
  local width = math.max(1, (frame.taskContent:GetWidth() or frame.taskScroll:GetWidth() or 1) - 2)
  local _, couponIcon = System():GetCouponInfo()
  for rowIndex, row in ipairs(frame.taskRows) do
    local absolute = first + rowIndex
    local task = view[absolute]
    row.task = task
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * TASK_ROW_HEIGHT))
    row:SetSize(width, TASK_ROW_HEIGHT - 2)
    row:SetShown(task ~= nil)
    if task then
      Controls():SetButtonSelected(row.track, task.tracked)
      row.track:SetText(task.tracked and "T" or "")
      local stateColor = task.completed and Colors().success or task.inProgress and Colors().accent or Colors().muted
      row.state:SetColorTexture(stateColor[1], stateColor[2], stateColor[3], (task.completed or task.inProgress) and 1 or 0.45)
      row.cells.name:SetText(task.name)
      row.cells.progress:SetText(task.completed and "Complete" or string.format("%d / %d", task.current or 0, task.maximum or 1))
      Controls():TextColor(row.cells.progress, task.completed and "success" or task.inProgress and "accent" or "muted")
      row.cells.points:SetText(FormatNumber(task.points))
      row.cells.coupons:SetText(task.coupons > 0 and tostring(task.coupons) or "--")
      row.couponIcon:SetTexture(couponIcon)
      row.couponIcon:SetShown(task.coupons > 0)
      row.cells.nextContribution:SetText(FormatNumber(task.nextContribution))
      row.cells.accountCompletions:SetText(tostring(task.accountCompletions or 0))
      Controls():TextColor(row.cells.name, task.completed and "muted" or "text")
      Controls():TextColor(row.cells.points, "success")
      Controls():TextColor(row.cells.coupons, "accent")
      Controls():TextColor(row.cells.nextContribution, task.nextContribution > 0 and "text" or "muted")
    end
  end
  frame.taskEmpty:SetShown(#view == 0)
  Controls():SyncScrollFrame(frame.taskScroll)
end

function EndeavorsUI:BuildDetailView()
  local settings = self:GetSettings()
  local tab = self.detailTab or "activity"
  local source = tab == "activity" and System():GetActivity() or tab == "leaderboard" and System():GetLeaderboard() or System():GetCouponGains()
  local view = self.detailView or {}
  local count = 0
  for _, entry in ipairs(source or {}) do count = count + 1 view[count] = entry end
  for index = count + 1, #view do view[index] = nil end
  local sort = tab == "activity" and settings.activitySort or tab == "leaderboard" and settings.leaderboardSort or settings.couponSort
  SortRows(view, sort.key, sort.descending, function(entry, key)
    if key == "time" then return entry.completionTime or entry.timestamp end
    if key == "player" then return entry.playerName or entry.character or entry.name end
    if key == "task" then return entry.taskName end
    if key == "rank" then return entry.rank end
    if key == "amount" then return entry.amount end
    return entry[key]
  end)
  self.detailView = view
  return view, sort
end

function EndeavorsUI:RenderDetails()
  local frame = self.panel
  if not frame or not frame:IsShown() then return end
  local tab = self.detailTab or "activity"
  local view, sort = self:BuildDetailView()
  for key, button in pairs(frame.detailTabs) do Controls():SetButtonSelected(button, key == tab) end
  self:LayoutColumns()
  for _, column in ipairs(DETAIL_COLUMNS[tab]) do SetHeaderLabel(frame.detailHeaders[column.key], column.label, sort.key == column.key, sort.descending) end
  frame.detailContent:SetHeight(math.max(1, #view * DETAIL_ROW_HEIGHT))
  local first = math.max(0, math.floor((frame.detailScroll:GetVerticalScroll() or 0) / DETAIL_ROW_HEIGHT))
  local width = math.max(1, (frame.detailContent:GetWidth() or frame.detailScroll:GetWidth() or 1) - 2)
  local player = UnitName and UnitName("player") or ""
  for rowIndex, row in ipairs(frame.detailRows) do
    local absolute = first + rowIndex
    local entry = view[absolute]
    row.entry = entry
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * DETAIL_ROW_HEIGHT))
    row:SetSize(width, DETAIL_ROW_HEIGHT - 2)
    row:SetShown(entry ~= nil)
    if entry then
      for _, cell in pairs(row.cells) do cell:SetText("") end
      if tab == "activity" then
        row.cells.time:SetText(FormatAgo(entry.completionTime))
        row.cells.player:SetText(entry.playerName or "Unknown")
        row.cells.task:SetText(entry.taskName or "Unknown task")
        row.cells.amount:SetText((tonumber(entry.amount) or 0) > 0 and FormatNumber(entry.amount) or "--")
        Controls():TextColor(row.cells.player, entry.playerName == player and "success" or "text")
        Controls():TextColor(row.cells.amount, (tonumber(entry.amount) or 0) > 0 and "success" or "muted")
      elseif tab == "leaderboard" then
        row.cells.rank:SetText("#" .. tostring(entry.rank or absolute))
        row.cells.player:SetText(entry.name or "Unknown")
        row.cells.amount:SetText(FormatNumber(entry.amount))
        Controls():TextColor(row.cells.player, entry.isPlayer and "success" or entry.isMyCharacter and "accent" or "text")
      else
        row.cells.time:SetText(FormatAgo(entry.timestamp))
        row.cells.player:SetText(entry.character or "")
        row.cells.task:SetText(entry.taskName or "Unknown task")
        row.cells.amount:SetText("+" .. FormatNumber(entry.amount))
      end
      for _, column in ipairs(DETAIL_COLUMNS[tab]) do row.cells[column.key]:Show() end
    end
  end
  frame.detailEmpty:SetShown(#view == 0)
  frame.detailEmpty:SetText(tab == "activity" and "No neighborhood activity has loaded yet." or tab == "leaderboard" and "No contribution rankings are available." or "Coupon gains will appear after completing endeavor tasks.")
  Controls():SyncScrollFrame(frame.detailScroll)
end

function EndeavorsUI:RenderHeader()
  local frame = self.panel
  local state = System():GetState()
  local info = state.info or {}
  local houses = System():GetHouses()
  local selected = System():GetSelectedHouseIndex()
  local house = houses[selected]
  frame.title:SetText(info.title or "Neighborhood Endeavors")
  frame.subtitle:SetText(info.description ~= "" and info.description or "Track neighborhood progress, tasks, rewards, and community contributions")
  frame.days:SetText((info.daysRemaining or 0) > 0 and (tostring(info.daysRemaining) .. " days remaining") or "")
  frame.houseButton:SetText(house and (house.houseName or house.neighborhoodName or ("House " .. selected)) or "Select House")
  frame.activeButton:SetText(System():IsSelectedHouseActive() and "Active Endeavor" or "Set Active")
  Controls():SetButtonSelected(frame.activeButton, System():IsSelectedHouseActive())
  local current = tonumber(info.currentProgress) or 0
  local maximum = math.max(1, tonumber(info.maximumProgress) or 1)
  local width = math.max(1, frame.progress:GetWidth() or 400)
  frame.progress:SetMinMaxValues(0, maximum)
  frame.progress:SetValue(math.min(maximum, current))
  frame.progress.text:SetText(FormatNumber(current) .. " / " .. FormatNumber(maximum) .. "  (" .. string.format("%.0f%%", current / maximum * 100) .. ")")
  local couponQuantity, couponIcon = System():GetCouponInfo()
  local milestones = info.milestones or {}
  for index, marker in ipairs(frame.progress.markers) do
    local milestone = milestones[index]
    marker:SetShown(milestone ~= nil)
    if milestone then
      local final = index == #milestones
      marker:ClearAllPoints()
      marker:SetPoint("CENTER", frame.progress, final and "RIGHT" or "LEFT", final and 12 or width * math.min(1, milestone.threshold / maximum), 0)
      marker.reward:SetTexture(couponIcon)
      marker.reward:SetShown(final)
      marker.incomplete:SetShown(not final and not milestone.reached)
      marker.complete:SetShown(not final and milestone.reached)
      marker.check:SetShown(milestone.reached)
      marker.tick:SetShown(not final)
      marker.tick:SetAtlas(milestone.reached and "housing-dashboard-initiatives-fillbar-tickbar-complete" or "housing-dashboard-initiatives-fillbar-tickbar-incomplete")
    end
  end
  local contribution = tonumber(info.playerContribution) or 0
  local availableXP = System():GetAvailableHouseXP()
  frame.couponIcon:SetTexture(couponIcon)
  frame.couponText:SetText(FormatNumber(couponQuantity) .. " Coupons")
  frame.contributionText:SetText(FormatNumber(contribution) .. " contribution")
  frame.houseXPText:SetText(FormatNumber(availableXP) .. " available house XP")
  frame.statsXP:SetText(FormatNumber(availableXP))
  frame.statsContribution:SetText(FormatNumber(contribution))
  frame.statsSeason:SetText(string.format("%.0f%%", current / maximum * 100))
  frame.status:SetText(state.status == "loading" and "Loading endeavor data..." or state.status == "locked" and ("Requires level " .. tostring(System():GetRequiredLevel() or "?")) or state.status == "disabled" and "Neighborhood endeavors are currently disabled." or state.status == "unsupported" and "The neighborhood initiative API is unavailable." or state.status == "unavailable" and "No active endeavor data is available for this house." or "Live neighborhood data")
  Controls():TextColor(frame.status, state.status == "ready" and "success" or state.status == "loading" and "accent" or "muted")
end

function EndeavorsUI:Refresh()
  if not self.panel or not self.panel:IsShown() then return end
  self:RenderHeader()
  self:RenderTasks()
  self:RenderDetails()
end

function EndeavorsUI:Layout()
  local frame = self.panel
  if not frame then return end
  local available = math.max(820, (frame:GetWidth() or 1080) - 24)
  local detailWidth = math.max(300, math.min(390, math.floor(available * 0.34)))
  frame.detailPanel:SetWidth(detailWidth)
  frame.taskPanel:ClearAllPoints()
  frame.taskPanel:SetPoint("TOPLEFT", 8, -190)
  frame.taskPanel:SetPoint("BOTTOMRIGHT", frame.detailPanel, "BOTTOMLEFT", -8, 0)
  frame.taskContent:SetWidth(math.max(1, (frame.taskScroll:GetWidth() or 680) - 2))
  frame.detailContent:SetWidth(math.max(1, (frame.detailScroll:GetWidth() or 320) - 2))
  self:LayoutColumns()
end

function EndeavorsUI:Create(parent)
  if self.panel then
    self.panel:SetParent(parent)
    self.panel:ClearAllPoints()
    self.panel:SetAllPoints(parent)
    return self.panel
  end
  local frame = CreateFrame("Frame", "HomeDecorEndeavorsPanel", parent, "BackdropTemplate")
  frame:SetAllPoints(parent)
  Backdrop(frame, Colors().background, Colors().border)

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(126)
  Backdrop(header, Colors().header, Colors().border)
  frame.title = Font(header, "GameFontNormalLarge", "accent")
  frame.title:SetPoint("TOPLEFT", 14, -10)
  frame.subtitle = Font(header, "GameFontNormalSmall", "muted")
  frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
  frame.subtitle:SetPoint("RIGHT", -330, 0)
  frame.subtitle:SetWordWrap(false)
  frame.days = Font(header, "GameFontNormalSmall", "muted")
  frame.days:SetPoint("TOPRIGHT", -14, -11)
  frame.houseButton = Button(header, "Select House", 180, 24)
  frame.houseButton:SetPoint("BOTTOMLEFT", 12, 10)
  frame.activeButton = Button(header, "Set Active", 96, 24)
  frame.activeButton:SetPoint("BOTTOMRIGHT", -12, 10)

  frame.progress = CreateProgressBar(header)
  frame.progress:SetPoint("TOPLEFT", 12, -48)
  frame.progress:SetPoint("TOPRIGHT", -28, -48)
  frame.couponIcon = header:CreateTexture(nil, "OVERLAY")
  frame.couponIcon:SetSize(16, 16)
  frame.couponIcon:SetPoint("LEFT", frame.houseButton, "RIGHT", 12, 0)
  frame.couponText = Font(header, "GameFontNormalSmall", "accent")
  frame.couponText:SetPoint("LEFT", frame.couponIcon, "RIGHT", 4, 0)
  frame.contributionText = Font(header, "GameFontNormalSmall", "success")
  frame.contributionText:SetPoint("LEFT", frame.couponText, "RIGHT", 14, 0)
  frame.houseXPText = Font(header, "GameFontNormalSmall", "muted")
  frame.houseXPText:SetPoint("LEFT", frame.contributionText, "RIGHT", 14, 0)

  local toolbar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  toolbar:SetPoint("TOPLEFT", 8, -142)
  toolbar:SetPoint("TOPRIGHT", -8, -142)
  toolbar:SetHeight(42)
  Backdrop(toolbar, Colors().header, Colors().border)
  frame.search = Controls():CreateSearchBox(toolbar, {
    height = 25,
    placeholder = "Search endeavor tasks",
    background = Colors().background,
    border = Colors().border,
    placeholderColor = "muted",
    onChanged = function()
      Controls():ResetScrollFrame(frame.taskScroll, false)
      EndeavorsUI:RenderTasks()
    end,
  })
  frame.search:SetPoint("LEFT", 8, 0)
  frame.search:SetSize(280, 25)
  frame.searchHint = frame.search.placeholder
  frame.filterButton = Button(toolbar, "Status: All", 126, 25)
  frame.filterButton:SetPoint("LEFT", frame.search, "RIGHT", 7, 0)
  frame.refreshButton = Button(toolbar, "Refresh", 88, 25)
  frame.refreshButton:SetPoint("RIGHT", -8, 0)
  frame.status = Font(toolbar, "GameFontNormalSmall", "muted")
  frame.status:SetPoint("RIGHT", frame.refreshButton, "LEFT", -12, 0)

  local taskPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  taskPanel:SetPoint("TOPLEFT", 8, -190)
  taskPanel:SetPoint("BOTTOMRIGHT", -354, 8)
  Backdrop(taskPanel, Colors().header, Colors().border)
  frame.taskPanel = taskPanel
  frame.taskColumns = CreateFrame("Frame", nil, taskPanel, "BackdropTemplate")
  frame.taskColumns:SetPoint("TOPLEFT")
  frame.taskColumns:SetPoint("TOPRIGHT")
  frame.taskColumns:SetHeight(26)
  Backdrop(frame.taskColumns, Colors().panel, Colors().border)
  frame.taskHeaders = {}
  for _, column in ipairs(TASK_COLUMNS) do
    local button = Button(frame.taskColumns, column.label, column.width, 22)
    button:SetScript("OnClick", function() EndeavorsUI:SetTaskSort(column.key) end)
    frame.taskHeaders[column.key] = button
  end
  frame.taskCount = Font(taskPanel, "GameFontNormalSmall", "muted")
  frame.taskCount:SetPoint("BOTTOMLEFT", 8, 6)
  frame.taskScroll = Controls():CreateScrollFrame(taskPanel)
  frame.taskScroll:SetPoint("TOPLEFT", frame.taskColumns, "BOTTOMLEFT", 0, -2)
  frame.taskScroll:SetPoint("BOTTOMRIGHT", -18, 22)
  frame.taskContent = CreateFrame("Frame", nil, frame.taskScroll)
  frame.taskContent:SetSize(650, 1)
  Controls():ConfigureScrollFrame(frame.taskScroll, frame.taskContent, { step = TASK_ROW_HEIGHT, onScroll = function() EndeavorsUI:RenderTasks() end })
  frame.taskRows = {}
  for index = 1, TASK_ROW_COUNT do frame.taskRows[index] = CreateTaskRow(frame.taskContent, frame.taskScroll) end
  frame.taskEmpty = Font(taskPanel, "GameFontHighlight", "muted")
  frame.taskEmpty:SetPoint("CENTER", frame.taskScroll)
  frame.taskEmpty:SetText("No endeavor tasks match these filters.")
  frame.taskEmpty:Hide()

  frame.detailPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.detailPanel:SetPoint("TOPRIGHT", -8, -190)
  frame.detailPanel:SetPoint("BOTTOMRIGHT", -8, 8)
  Backdrop(frame.detailPanel, Colors().header, Colors().border)
  frame.statsTitle = Font(frame.detailPanel, "GameFontNormalSmall", "accent")
  frame.statsTitle:SetPoint("TOPLEFT", 9, -9)
  frame.statsTitle:SetText("MY STATS")
  frame.statsXPLabel = Font(frame.detailPanel, "GameFontNormalSmall", "muted")
  frame.statsXPLabel:SetPoint("TOPLEFT", 9, -30)
  frame.statsXPLabel:SetText("Available House XP")
  frame.statsXP = Font(frame.detailPanel, "GameFontNormalSmall", "success")
  frame.statsXP:SetPoint("TOPRIGHT", -9, -30)
  frame.statsContributionLabel = Font(frame.detailPanel, "GameFontNormalSmall", "muted")
  frame.statsContributionLabel:SetPoint("TOPLEFT", 9, -51)
  frame.statsContributionLabel:SetText("Your Contribution")
  frame.statsContribution = Font(frame.detailPanel, "GameFontNormalSmall", "text")
  frame.statsContribution:SetPoint("TOPRIGHT", -9, -51)
  frame.statsSeasonLabel = Font(frame.detailPanel, "GameFontNormalSmall", "muted")
  frame.statsSeasonLabel:SetPoint("TOPLEFT", 9, -72)
  frame.statsSeasonLabel:SetText("Season Progress")
  frame.statsSeason = Font(frame.detailPanel, "GameFontNormalSmall", "accent")
  frame.statsSeason:SetPoint("TOPRIGHT", -9, -72)
  frame.statsLine = frame.detailPanel:CreateTexture(nil, "ARTWORK")
  frame.statsLine:SetPoint("TOPLEFT", 8, -92)
  frame.statsLine:SetPoint("TOPRIGHT", -8, -92)
  frame.statsLine:SetHeight(1)
  frame.statsLine:SetColorTexture(Colors().border[1], Colors().border[2], Colors().border[3], 0.7)
  frame.detailTabs = {}
  local previous
  for _, tab in ipairs({ { "activity", "Activity" }, { "leaderboard", "Leaderboard" }, { "coupons", "Coupons" } }) do
    local button = Button(frame.detailPanel, tab[2], tab[1] == "leaderboard" and 104 or 78, 24)
    if previous then button:SetPoint("LEFT", previous, "RIGHT", 5, 0) else button:SetPoint("TOPLEFT", 7, -101) end
    button:SetScript("OnClick", function()
      EndeavorsUI.detailTab = tab[1]
      Controls():ResetScrollFrame(frame.detailScroll, false)
      EndeavorsUI:RenderDetails()
    end)
    frame.detailTabs[tab[1]] = button
    previous = button
  end
  frame.detailColumns = CreateFrame("Frame", nil, frame.detailPanel, "BackdropTemplate")
  frame.detailColumns:SetPoint("TOPLEFT", 0, -132)
  frame.detailColumns:SetPoint("TOPRIGHT")
  frame.detailColumns:SetHeight(26)
  Backdrop(frame.detailColumns, Colors().panel, Colors().border)
  frame.detailHeaders = {}
  for _, key in ipairs({ "time", "rank", "player", "task", "amount" }) do
    local button = Button(frame.detailColumns, key:upper(), 60, 22)
    button:SetScript("OnClick", function() EndeavorsUI:SetDetailSort(key) end)
    frame.detailHeaders[key] = button
  end
  frame.detailScroll = Controls():CreateScrollFrame(frame.detailPanel)
  frame.detailScroll:SetPoint("TOPLEFT", frame.detailColumns, "BOTTOMLEFT", 0, -2)
  frame.detailScroll:SetPoint("BOTTOMRIGHT", -18, 0)
  frame.detailContent = CreateFrame("Frame", nil, frame.detailScroll)
  frame.detailContent:SetSize(300, 1)
  Controls():ConfigureScrollFrame(frame.detailScroll, frame.detailContent, { step = DETAIL_ROW_HEIGHT, onScroll = function() EndeavorsUI:RenderDetails() end })
  frame.detailRows = {}
  for index = 1, DETAIL_ROW_COUNT do frame.detailRows[index] = CreateDetailRow(frame.detailContent, frame.detailScroll) end
  frame.detailEmpty = Font(frame.detailPanel, "GameFontNormalSmall", "muted")
  frame.detailEmpty:SetPoint("CENTER", frame.detailScroll)
  frame.detailEmpty:SetWidth(240)
  frame.detailEmpty:SetJustifyH("CENTER")
  frame.detailEmpty:Hide()

  frame.houseButton:SetScript("OnClick", function(self)
    local options = {}
    local active = System():GetActiveNeighborhoodGUID()
    for index, house in ipairs(System():GetHouses()) do
      local label = house.houseName or house.neighborhoodName or ("House " .. index)
      if active and house.neighborhoodGUID == active then label = label .. "  (Active)" end
      options[#options + 1] = { value = index, label = label }
    end
    if #options == 0 then options[1] = { value = 0, label = "Refresh house list" } end
    NS.UI.Dropdown:Show(self, options, System():GetSelectedHouseIndex(), function(index)
      if index == 0 then System():RequestHouseList() else System():SelectHouse(index) end
    end)
  end)
  frame.activeButton:SetScript("OnClick", function() System():SetSelectedHouseActive() end)
  frame.filterButton:SetScript("OnClick", function(self)
    local options = {
      { value = "all", label = "All Tasks" },
      { value = "available", label = "Available" },
      { value = "progress", label = "In Progress" },
      { value = "complete", label = "Completed" },
      { value = "tracked", label = "Tracked" },
    }
    NS.UI.Dropdown:Show(self, options, EndeavorsUI.taskFilter or "all", function(value)
      EndeavorsUI.taskFilter = value
      local labels = { all = "All", available = "Available", progress = "In Progress", complete = "Completed", tracked = "Tracked" }
      self:SetText("Status: " .. labels[value])
      Controls():ResetScrollFrame(frame.taskScroll, false)
      EndeavorsUI:RenderTasks()
    end)
  end)
  frame.refreshButton:SetScript("OnClick", function()
    System():RequestHouseList()
    System():Fetch(true)
    System():RequestActivityLog()
  end)
  frame:SetScript("OnShow", function()
    if #System():GetHouses() == 0 then System():RequestHouseList() end
    System():Fetch()
    System():RequestActivityLog()
    EndeavorsUI:Refresh()
  end)
  frame:SetScript("OnHide", function()
    Controls():CloseTransientPopups()
    for _, row in ipairs(frame.taskRows) do row.task = nil end
    for _, row in ipairs(frame.detailRows) do row.entry = nil end
    EndeavorsUI.taskView = nil
    EndeavorsUI.detailView = nil
    Controls():CollectGarbageIncrementally()
  end)
  frame:SetScript("OnSizeChanged", function() EndeavorsUI:Layout() EndeavorsUI:Refresh() end)
  frame.taskScroll:HookScript("OnSizeChanged", function(self) frame.taskContent:SetWidth(math.max(1, (self:GetWidth() or 1) - 2)) EndeavorsUI:LayoutColumns() EndeavorsUI:RenderTasks() end)
  frame.detailScroll:HookScript("OnSizeChanged", function(self) frame.detailContent:SetWidth(math.max(1, (self:GetWidth() or 1) - 2)) EndeavorsUI:LayoutColumns() EndeavorsUI:RenderDetails() end)

  self.panel = frame
  self.detailTab = "activity"
  self.taskFilter = "all"
  if #System():GetHouses() == 0 then System():RequestHouseList() end
  System():Fetch()
  System():RequestActivityLog()
  self:Layout()
  self:Refresh()
  return frame
end

function EndeavorsUI:Toggle()
  if NS.UI.CatalogView then NS.UI.CatalogView:Open("endeavors") end
end

NS.OnMessage("HOMEDECOR_ENDEAVORS_UPDATED", function()
  if EndeavorsUI.panel and EndeavorsUI.panel:IsShown() then EndeavorsUI:Refresh() end
end)

return EndeavorsUI
