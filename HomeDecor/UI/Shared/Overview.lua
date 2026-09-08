local _, NS = ...

NS.UI = NS.UI or {}
local Statistics = {}
NS.UI.Overview = Statistics
NS.UI.Statistics = Statistics

local ROW_HEIGHT = 32
local ROW_COUNT = 14

local SOURCE_DEFINITIONS = {
  { key = "achievements", label = "Achievements", sourceType = "achievement", requirement = "Achievement" },
  { key = "quests", label = "Quests", sourceType = "quest", requirement = "Quest" },
  { key = "vendors", label = "Vendors", sourceType = "vendor" },
  { key = "drops", label = "Drops / Encounters", sourceType = "drop" },
  { key = "treasures", label = "Treasures", sourceType = "treasure" },
  { key = "shop", label = "Shop", sourceType = "shop" },
  { key = "professions", label = "Professions", sourceType = "profession" },
  { key = "pvp", label = "PvP", sourceType = "pvp" },
}

local function Controls()
  return NS.UI and NS.UI.Controls
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

local function FormatNumber(value)
  value = tonumber(value) or 0
  if value >= 1000000 then return string.format("%.1fm", value / 1000000) end
  if value >= 1000 then return string.format("%.1fk", value / 1000) end
  return tostring(math.floor(value + 0.5))
end

local function FormatMoney(value)
  value = tonumber(value) or 0
  if GetCoinTextureString then return GetCoinTextureString(math.floor(value + 0.5)) end
  return FormatNumber(value / 10000) .. "g"
end

local function Percent(owned, total)
  return total > 0 and math.floor(owned / total * 100 + 0.5) or 0
end

local function RecordKey(record)
  return tostring(record.decorID or record.itemID or record.id or record.storageKey or "")
end

local function MatchesSource(record, definition)
  if tostring(record.sourceType or ""):lower() == definition.sourceType then return true end
  local requirements = record.requirements
  if definition.requirement == "Achievement" and type(requirements) == "table" and requirements.achievement then return true end
  if definition.requirement == "Quest" and type(requirements) == "table" and requirements.quest then return true end
  return false
end

local function AddUnique(group, key, owned)
  if group.seen[key] then return end
  group.seen[key] = true
  group.total = group.total + 1
  if owned then group.owned = group.owned + 1 end
end

local function CreateProgress(parent, height)
  local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
  bar:SetHeight(height or 12)
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0)
  Backdrop(bar, Colors().background, Colors().border)
  local fill = bar:CreateTexture(nil, "ARTWORK")
  fill:SetAllPoints()
  fill:SetAtlas("housing-dashboard-fillbar-fill")
  bar:SetStatusBarTexture(fill)
  return bar
end

local function CreateCard(parent, title)
  local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Backdrop(card, Colors().header, Colors().border)
  card.title = Font(card, "GameFontNormal", "accent")
  card.title:SetPoint("TOPLEFT", 11, -10)
  card.title:SetText(title)
  card.line = card:CreateTexture(nil, "ARTWORK")
  card.line:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -7)
  card.line:SetPoint("TOPRIGHT", -10, -31)
  card.line:SetHeight(1)
  card.line:SetColorTexture(Colors().border[1], Colors().border[2], Colors().border[3], 0.75)
  return card
end

local function CreateMetric(parent, label, role, onClick)
  local card = CreateFrame(onClick and "Button" or "Frame", nil, parent, "BackdropTemplate")
  Backdrop(card, Colors().panel, Colors().border)
  if onClick then
    Controls():ApplyHover(card, Colors().panel, Colors().hover)
    card:SetScript("OnClick", onClick)
  end
  card.label = Font(card, "GameFontNormalSmall", "muted")
  card.label:SetPoint("TOPLEFT", 10, -8)
  card.label:SetText(label)
  card.value = Font(card, "GameFontNormalLarge", role or "accent")
  card.value:SetPoint("BOTTOMLEFT", 10, 8)
  card.value:SetPoint("RIGHT", -8, 0)
  card.value:SetJustifyH("LEFT")
  return card
end

local function CreateStatLine(parent, label, y, role)
  local left = Font(parent, "GameFontNormalSmall", "muted")
  left:SetPoint("TOPLEFT", 11, y)
  left:SetText(label)
  local right = Font(parent, "GameFontNormalSmall", role or "text")
  right:SetPoint("TOPRIGHT", -11, y)
  right:SetPoint("LEFT", left, "RIGHT", 8, 0)
  right:SetJustifyH("RIGHT")
  right:SetWordWrap(false)
  return right
end

local function SetHeader(button, label, active, descending)
  button:SetText(active and (label .. (descending and "  v" or "  ^")) or label)
  Controls():SetButtonSelected(button, active)
end

function Statistics:GetSettings()
  local profile = NS.Systems.Database:GetProfile()
  profile.statistics = profile.statistics or { view = "sources", sort = { key = "percent", header = "percentText", descending = true } }
  profile.statistics.view = profile.statistics.view == "expansions" and "expansions" or profile.statistics.view == "professions" and "professions" or "sources"
  if type(profile.statistics.sort) ~= "table" then profile.statistics.sort = { key = "percent", header = "percentText", descending = true } end
  profile.statistics.sort.key = profile.statistics.sort.key or "percent"
  profile.statistics.sort.descending = profile.statistics.sort.descending ~= false
  return profile.statistics
end

function Statistics:BuildModel()
  local model = { total = 0, owned = 0, unresolved = 0, favorites = 0, tracked = 0, sources = {}, professions = {}, expansions = {} }
  local overall = {}
  local favoriteSeen = {}
  local trackedSeen = {}
  local sourceGroups = {}
  local professionGroups = {}
  local expansionGroups = {}
  for _, definition in ipairs(SOURCE_DEFINITIONS) do
    sourceGroups[definition.key] = { label = definition.label, owned = 0, total = 0, seen = {}, query = { sourceType = not definition.requirement and definition.sourceType or nil, requirement = definition.requirement } }
  end
  for _, record in ipairs(NS.Systems.Catalog.ordered or {}) do
    local key = RecordKey(record)
    local ownedState = NS.Systems.Collection:GetOwned(record)
    local owned = ownedState == true
    if key ~= "" and not overall[key] then
      overall[key] = true
      model.total = model.total + 1
      if owned then model.owned = model.owned + 1 end
      if ownedState == nil then model.unresolved = model.unresolved + 1 end
    end
    if key ~= "" and not favoriteSeen[key] and NS.Systems.Favorites:IsFavorite(record) then
      favoriteSeen[key] = true
      model.favorites = model.favorites + 1
    end
    if key ~= "" and not trackedSeen[key] and NS.Systems.Tracker:IsTracked(record) then
      trackedSeen[key] = true
      model.tracked = model.tracked + 1
    end
    for _, definition in ipairs(SOURCE_DEFINITIONS) do
      if MatchesSource(record, definition) then AddUnique(sourceGroups[definition.key], key, owned) end
    end
    if record.sourceType == "profession" and record.profession then
      local profession = tostring(record.profession)
      local professionGroup = professionGroups[profession]
      if not professionGroup then
        professionGroup = { label = profession, owned = 0, total = 0, seen = {}, query = { profession = profession, sourceType = "profession" } }
        professionGroups[profession] = professionGroup
      end
      AddUnique(professionGroup, key, owned)
    end
    local expansion = tostring(record.expansion or "Unknown")
    local group = expansionGroups[expansion]
    if not group then
      group = { label = expansion, owned = 0, total = 0, seen = {}, query = { expansion = expansion } }
      expansionGroups[expansion] = group
    end
    AddUnique(group, key, owned)
  end
  for _, definition in ipairs(SOURCE_DEFINITIONS) do
    local group = sourceGroups[definition.key]
    group.percent = Percent(group.owned, group.total)
    group.seen = nil
    model.sources[#model.sources + 1] = group
  end
  for _, group in pairs(expansionGroups) do
    group.percent = Percent(group.owned, group.total)
    group.seen = nil
    model.expansions[#model.expansions + 1] = group
  end
  for _, group in pairs(professionGroups) do
    group.percent = Percent(group.owned, group.total)
    group.seen = nil
    model.professions[#model.professions + 1] = group
  end
  model.missing = math.max(0, model.total - model.owned)
  model.percent = Percent(model.owned, model.total)
  model.catalogRevision = NS.Systems.Catalog.revision
  model.collectionRevision = NS.Systems.Collection.revision
  self.model = model
  self.sortedRows = nil
  self.sortedRowsKey = nil
  self.sortedRowsModel = nil
  return model
end

function Statistics:GetRows()
  local settings = self:GetSettings()
  local cacheKey = table.concat({ settings.view, settings.sort.key, settings.sort.descending and "1" or "0" }, ":")
  if self.sortedRowsModel == self.model and self.sortedRowsKey == cacheKey and self.sortedRows then return self.sortedRows end
  local source = settings.view == "expansions" and self.model.expansions or settings.view == "professions" and self.model.professions or self.model.sources
  local rows = {}
  for index = 1, #source do
    if type(source[index]) == "table" then rows[#rows + 1] = source[index] end
  end
  local sort = settings.sort
  local function ComesBefore(left, right)
    if not left then return false end
    if not right then return true end
    local leftLabel = tostring(left.label or "")
    local rightLabel = tostring(right.label or "")
    local a = sort.key == "name" and leftLabel:lower() or tonumber(left[sort.key]) or 0
    local b = sort.key == "name" and rightLabel:lower() or tonumber(right[sort.key]) or 0
    if a == b then return leftLabel < rightLabel end
    return sort.descending and a > b or a < b
  end
  for index = 2, #rows do
    local value = rows[index]
    local cursor = index - 1
    while cursor >= 1 and ComesBefore(value, rows[cursor]) do
      rows[cursor + 1] = rows[cursor]
      cursor = cursor - 1
    end
    rows[cursor + 1] = value
  end
  self.sortedRows = rows
  self.sortedRowsKey = cacheKey
  self.sortedRowsModel = self.model
  return rows
end

function Statistics:SetSort(key, header)
  local sort = self:GetSettings().sort
  if sort.key == key then
    sort.descending = not sort.descending
  else
    sort.key = key
    sort.descending = key ~= "name"
  end
  sort.header = header
  Controls():ResetScrollFrame(self.panel.breakdownScroll, false)
  self:RenderBreakdown()
end

function Statistics:OpenCatalog(query, ownership, route)
  NS.Systems.QueryState:ResetFilters()
  NS.Systems.QueryState:SetOwnership(ownership or "All")
  if query then
    if query.expansion then NS.Systems.QueryState:SetFilter("expansion", query.expansion) end
    if query.profession then NS.Systems.QueryState:SetFilter("profession", query.profession) end
    if query.sourceType then NS.Systems.QueryState:SetFilter("sourceType", query.sourceType) end
    if query.requirement then NS.Systems.QueryState:SetFilter("requirement", query.requirement) end
  end
  NS.UI.CatalogView:Open(route or "catalog")
end

function Statistics:CreateBreakdownRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  Backdrop(row, Colors().row, { 0.16, 0.14, 0.07, 0.72 })
  Controls():ApplyHover(row, Colors().row, Colors().hover)
  row.name = Font(row, "GameFontNormalSmall", "text")
  row.name:SetPoint("LEFT", 8, 0)
  row.name:SetWidth(160)
  row.name:SetJustifyH("LEFT")
  row.name:SetWordWrap(false)
  row.bar = CreateProgress(row, 10)
  row.bar:SetPoint("LEFT", row.name, "RIGHT", 8, 0)
  row.owned = Font(row, "GameFontNormalSmall", "success")
  row.total = Font(row, "GameFontNormalSmall", "muted")
  row.percent = Font(row, "GameFontNormalSmall", "accent")
  row:SetScript("OnClick", function(self) if self.entry then Statistics:OpenCatalog(self.entry.query) end end)
  Controls():ForwardScrollWheel(row, scroll)
  row:Hide()
  return row
end

function Statistics:LayoutBreakdownRows()
  local frame = self.panel
  if not frame then return end
  local width = math.max(320, frame.breakdownScroll:GetWidth() or 600)
  local compact = width < 520
  local nameWidth = math.max(105, math.floor(width * (compact and 0.31 or 0.29)))
  local numberWidth = compact and 46 or 58
  local percentWidth = compact and 43 or 54
  local barWidth = math.max(75, width - nameWidth - numberWidth * 2 - percentWidth - 20)
  local columns = {
    { key = "name", x = 0, width = nameWidth },
    { key = "percent", x = nameWidth, width = barWidth },
    { key = "owned", x = nameWidth + barWidth, width = numberWidth },
    { key = "total", x = nameWidth + barWidth + numberWidth, width = numberWidth },
    { key = "percentText", x = nameWidth + barWidth + numberWidth * 2, width = percentWidth },
  }
  frame.breakdownLayout = columns
  for _, definition in ipairs({ { "name", "CATEGORY" }, { "percent", "PROGRESS" }, { "owned", "OWNED" }, { "total", "TOTAL" }, { "percentText", "%" } }) do
    local column
    for _, value in ipairs(columns) do if value.key == definition[1] then column = value break end end
    local header = frame.breakdownHeaders[definition[1]]
    header:ClearAllPoints()
    header:SetPoint("LEFT", frame.breakdownColumns, "LEFT", column.x, 0)
    header:SetWidth(column.width - 3)
  end
  for _, row in ipairs(frame.breakdownRows) do
    row.name:SetWidth(nameWidth - 12)
    row.bar:ClearAllPoints()
    row.bar:SetPoint("LEFT", row, "LEFT", nameWidth + 5, 0)
    row.bar:SetWidth(barWidth - 10)
    for key, text in pairs({ owned = row.owned, total = row.total, percentText = row.percent }) do
      local column
      for _, value in ipairs(columns) do if value.key == key then column = value break end end
      text:ClearAllPoints()
      text:SetPoint("LEFT", row, "LEFT", column.x + 3, 0)
      text:SetWidth(column.width - 6)
      text:SetJustifyH("RIGHT")
    end
  end
end

function Statistics:RenderBreakdown()
  local frame = self.panel
  if not frame or not frame:IsShown() or not self.model then return end
  local settings = self:GetSettings()
  local rows = self:GetRows()
  Controls():SetButtonSelected(frame.sourcesTab, settings.view == "sources")
  Controls():SetButtonSelected(frame.professionsTab, settings.view == "professions")
  Controls():SetButtonSelected(frame.expansionsTab, settings.view == "expansions")
  local labels = { name = "CATEGORY", percent = "PROGRESS", owned = "OWNED", total = "TOTAL", percentText = "%" }
  for key, button in pairs(frame.breakdownHeaders) do
    local sortKey = key == "percentText" and "percent" or key
    local active = settings.sort.header and settings.sort.header == key or not settings.sort.header and settings.sort.key == sortKey
    SetHeader(button, labels[key], active, settings.sort.descending)
  end
  frame.breakdownContent:SetHeight(math.max(1, #rows * ROW_HEIGHT))
  local first = math.max(0, math.floor((frame.breakdownScroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  local width = math.max(1, (frame.breakdownContent:GetWidth() or frame.breakdownScroll:GetWidth() or 1) - 2)
  for rowIndex, row in ipairs(frame.breakdownRows) do
    local absolute = first + rowIndex
    local entry = rows[absolute]
    row.entry = entry
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetSize(width, ROW_HEIGHT - 2)
    row:SetShown(entry ~= nil)
    if entry then
      row.name:SetText(entry.label)
      row.bar:SetMinMaxValues(0, math.max(1, entry.total))
      row.bar:SetValue(entry.owned)
      row.owned:SetText(FormatNumber(entry.owned))
      row.total:SetText(FormatNumber(entry.total))
      row.percent:SetText(tostring(entry.percent) .. "%")
    end
  end
  frame.breakdownEmpty:SetShown(#rows == 0)
  frame.breakdownCount:SetText(tostring(#rows) .. (settings.view == "sources" and " sources" or settings.view == "professions" and " professions" or " expansions"))
  Controls():SyncScrollFrame(frame.breakdownScroll)
end

function Statistics:RefreshEndeavors()
  local frame = self.panel
  local system = NS.Systems.Endeavors
  local state = system and system:GetState() or {}
  local info = state.info or {}
  local house = system and system:GetSelectedHouse()
  frame.houseButton:SetText(house and (house.houseName or house.neighborhoodName) or "Select House")
  frame.seasonValue:SetText(info.title or "No active endeavor")
  frame.daysValue:SetText((info.daysRemaining or 0) > 0 and (tostring(info.daysRemaining) .. " days") or "--")
  local coupons, icon = 0, 134400
  if system then coupons, icon = system:GetCouponInfo() end
  frame.couponIcon:SetTexture(icon)
  frame.couponsValue:SetText(FormatNumber(coupons))
  frame.houseXPValue:SetText(FormatNumber(system and system:GetAvailableHouseXP() or 0))
  frame.endeavorBar:SetMinMaxValues(0, math.max(1, tonumber(info.maximumProgress) or 1))
  frame.endeavorBar:SetValue(tonumber(info.currentProgress) or 0)
  frame.endeavorProgress:SetText(FormatNumber(info.currentProgress) .. " / " .. FormatNumber(info.maximumProgress) .. "  (" .. tostring(Percent(tonumber(info.currentProgress) or 0, tonumber(info.maximumProgress) or 0)) .. "%)")
end

function Statistics:RefreshCrafting()
  local frame = self.panel
  local sales = NS.Systems.SalesTracker
  local currentGold, currentCount, altGold, altCount, accountGold, accountCount = 0, 0, 0, 0, 0, 0
  if sales then currentGold, currentCount, altGold, altCount, accountGold, accountCount = sales:GetLifetime() end
  local rows, todayGold, todayCount = {}, 0, 0
  if sales then rows, todayGold, todayCount = sales:Get("day", "current") end
  frame.characterValue:SetText(FormatMoney(currentGold) .. "  (" .. tostring(currentCount) .. ")")
  frame.altsValue:SetText(FormatMoney(altGold) .. "  (" .. tostring(altCount) .. ")")
  frame.accountValue:SetText(FormatMoney(accountGold) .. "  (" .. tostring(accountCount) .. ")")
  frame.todayValue:SetText(FormatMoney(todayGold) .. "  (" .. tostring(todayCount) .. ")")
end

function Statistics:Refresh()
  local frame = self.panel
  if not frame or not frame:IsShown() then return end
  local model = self.model
  if not model or model.catalogRevision ~= NS.Systems.Catalog.revision or model.collectionRevision ~= NS.Systems.Collection.revision then model = self:BuildModel() end
  frame.overallPercent:SetText(tostring(model.percent) .. "%")
  frame.overallText:SetText(FormatNumber(model.owned) .. " / " .. FormatNumber(model.total) .. " unique decor collected")
  frame.overallBar:SetMinMaxValues(0, math.max(1, model.total))
  frame.overallBar:SetValue(model.owned)
  frame.metrics[1].value:SetText(FormatNumber(model.owned))
  frame.metrics[2].value:SetText(FormatNumber(model.missing))
  frame.metrics[3].value:SetText(FormatNumber(model.favorites))
  frame.metrics[4].value:SetText(FormatNumber(model.tracked))
  if model.unresolved > 0 then
    frame.status:SetText("Loading collection  " .. FormatNumber(model.total - model.unresolved) .. " / " .. FormatNumber(model.total))
  else
    frame.status:SetText("Catalog " .. FormatNumber(model.total) .. "  |  Collection refreshed")
  end
  self:RenderBreakdown()
  self:RefreshEndeavors()
  self:RefreshCrafting()
end

function Statistics:Layout()
  local frame = self.panel
  if not frame then return end
  local width = math.max(620, frame:GetWidth() or 1000)
  local inner = width - 24
  local metricGap = 8
  local metricWidth = math.floor((inner - metricGap * 3) / 4)
  for index, metric in ipairs(frame.metrics) do
    metric:ClearAllPoints()
    metric:SetPoint("TOPLEFT", frame, "TOPLEFT", 12 + (index - 1) * (metricWidth + metricGap), -174)
    metric:SetSize(metricWidth, 58)
  end
  local rightWidth = math.max(300, math.min(430, math.floor(inner * 0.41)))
  frame.rightColumn:SetWidth(rightWidth)
  frame.breakdownCard:ClearAllPoints()
  frame.breakdownCard:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -240)
  frame.breakdownCard:SetPoint("BOTTOMRIGHT", frame.rightColumn, "BOTTOMLEFT", -8, 0)
  frame.breakdownContent:SetWidth(math.max(1, (frame.breakdownScroll:GetWidth() or 550) - 2))
  self:LayoutBreakdownRows()
end

function Statistics:Create(parent)
  if self.panel then
    self.panel:SetParent(parent)
    self.panel:ClearAllPoints()
    self.panel:SetAllPoints(parent)
    return self.panel
  end
  local frame = CreateFrame("Frame", "HomeDecorStatisticsPanel", parent, "BackdropTemplate")
  frame:SetAllPoints(parent)
  Backdrop(frame, Colors().background, Colors().border)

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(58)
  Backdrop(header, Colors().header, Colors().border)
  frame.title = Font(header, "GameFontNormalLarge", "accent")
  frame.title:SetPoint("TOPLEFT", 14, -10)
  frame.title:SetText("Statistics")
  frame.subtitle = Font(header, "GameFontNormalSmall", "muted")
  frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
  frame.subtitle:SetText("Your collection, endeavors, crafting queue, and sales at a glance")
  frame.refreshButton = Button(header, "Refresh", 90, 25)
  frame.refreshButton:SetPoint("TOPRIGHT", -10, -10)
  frame.status = Font(header, "GameFontNormalSmall", "muted")
  frame.status:SetPoint("RIGHT", frame.refreshButton, "LEFT", -12, 0)

  local overall = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  overall:SetPoint("TOPLEFT", 8, -74)
  overall:SetPoint("TOPRIGHT", -8, -74)
  overall:SetHeight(90)
  Backdrop(overall, Colors().header, Colors().border)
  frame.overallPercent = Font(overall, "GameFontNormalHuge", "accent")
  frame.overallPercent:SetPoint("TOPLEFT", 14, -11)
  frame.overallText = Font(overall, "GameFontNormal", "muted")
  frame.overallText:SetPoint("LEFT", frame.overallPercent, "RIGHT", 14, 1)
  frame.overallBar = CreateProgress(overall, 18)
  frame.overallBar:SetPoint("BOTTOMLEFT", 14, 13)
  frame.overallBar:SetPoint("BOTTOMRIGHT", -14, 13)

  frame.metrics = {
    CreateMetric(frame, "COLLECTED", "success", function() Statistics:OpenCatalog(nil, "Owned") end),
    CreateMetric(frame, "MISSING", "accent", function() Statistics:OpenCatalog(nil, "Missing") end),
    CreateMetric(frame, "FAVORITES", "accent", function() Statistics:OpenCatalog(nil, nil, "favorites") end),
    CreateMetric(frame, "TRACKED", "text", function() Statistics:OpenCatalog(nil, nil, "tracked") end),
  }

  frame.breakdownCard = CreateCard(frame, "Collection Breakdown")
  frame.breakdownCard:SetPoint("TOPLEFT", 8, -240)
  frame.breakdownCard:SetPoint("BOTTOMLEFT", 8, 8)
  frame.sourcesTab = Button(frame.breakdownCard, "Sources", 82, 23)
  frame.sourcesTab:SetPoint("TOPRIGHT", -204, -7)
  frame.professionsTab = Button(frame.breakdownCard, "Professions", 96, 23)
  frame.professionsTab:SetPoint("LEFT", frame.sourcesTab, "RIGHT", 6, 0)
  frame.expansionsTab = Button(frame.breakdownCard, "Expansions", 90, 23)
  frame.expansionsTab:SetPoint("LEFT", frame.professionsTab, "RIGHT", 6, 0)
  frame.breakdownColumns = CreateFrame("Frame", nil, frame.breakdownCard, "BackdropTemplate")
  frame.breakdownColumns:SetPoint("TOPLEFT", 0, -40)
  frame.breakdownColumns:SetPoint("TOPRIGHT")
  frame.breakdownColumns:SetHeight(25)
  Backdrop(frame.breakdownColumns, Colors().panel, Colors().border)
  frame.breakdownHeaders = {}
  for _, definition in ipairs({ { "name", "CATEGORY" }, { "percent", "PROGRESS" }, { "owned", "OWNED" }, { "total", "TOTAL" }, { "percentText", "%" } }) do
    local button = Button(frame.breakdownColumns, definition[2], 70, 21)
    local sortKey = definition[1] == "percentText" and "percent" or definition[1]
    button:SetScript("OnClick", function() Statistics:SetSort(sortKey, definition[1]) end)
    frame.breakdownHeaders[definition[1]] = button
  end
  frame.breakdownCount = Font(frame.breakdownCard, "GameFontNormalSmall", "muted")
  frame.breakdownCount:SetPoint("BOTTOMLEFT", 8, 6)
  frame.breakdownScroll = Controls():CreateScrollFrame(frame.breakdownCard)
  frame.breakdownScroll:SetPoint("TOPLEFT", frame.breakdownColumns, "BOTTOMLEFT", 0, -2)
  frame.breakdownScroll:SetPoint("BOTTOMRIGHT", -18, 22)
  frame.breakdownContent = CreateFrame("Frame", nil, frame.breakdownScroll)
  frame.breakdownContent:SetSize(540, 1)
  Controls():ConfigureScrollFrame(frame.breakdownScroll, frame.breakdownContent, { step = ROW_HEIGHT, onScroll = function() Statistics:RenderBreakdown() end })
  frame.breakdownRows = {}
  for index = 1, ROW_COUNT do frame.breakdownRows[index] = self:CreateBreakdownRow(frame.breakdownContent, frame.breakdownScroll) end
  frame.breakdownEmpty = Font(frame.breakdownCard, "GameFontNormalSmall", "muted")
  frame.breakdownEmpty:SetPoint("CENTER", frame.breakdownScroll)
  frame.breakdownEmpty:SetText("No collection statistics are available.")
  frame.breakdownEmpty:Hide()

  frame.rightColumn = CreateFrame("Frame", nil, frame)
  frame.rightColumn:SetPoint("TOPRIGHT", -8, -240)
  frame.rightColumn:SetPoint("BOTTOMRIGHT", -8, 8)
  frame.rightColumn:SetWidth(360)
  frame.endeavorsCard = CreateCard(frame.rightColumn, "Endeavors")
  frame.endeavorsCard:SetPoint("TOPLEFT")
  frame.endeavorsCard:SetPoint("TOPRIGHT")
  frame.endeavorsCard:SetHeight(202)
  frame.houseButton = Button(frame.endeavorsCard, "Select House", 150, 23)
  frame.houseButton:SetPoint("TOPRIGHT", -9, -7)
  frame.seasonValue = CreateStatLine(frame.endeavorsCard, "Season", -43, "accent")
  frame.daysValue = CreateStatLine(frame.endeavorsCard, "Days Remaining", -64)
  frame.couponsValue = CreateStatLine(frame.endeavorsCard, "Community Coupons", -85, "accent")
  frame.couponIcon = frame.endeavorsCard:CreateTexture(nil, "OVERLAY")
  frame.couponIcon:SetSize(14, 14)
  frame.couponIcon:SetPoint("RIGHT", frame.couponsValue, "LEFT", -4, 0)
  frame.houseXPValue = CreateStatLine(frame.endeavorsCard, "Available House XP", -106, "success")
  frame.endeavorBar = CreateProgress(frame.endeavorsCard, 14)
  frame.endeavorBar:SetPoint("BOTTOMLEFT", 11, 30)
  frame.endeavorBar:SetPoint("BOTTOMRIGHT", -11, 30)
  frame.endeavorProgress = Font(frame.endeavorsCard, "GameFontNormalSmall", "muted")
  frame.endeavorProgress:SetPoint("BOTTOMRIGHT", -11, 10)

  frame.craftingCard = CreateCard(frame.rightColumn, "Decor Sales Earnings")
  frame.craftingCard:SetPoint("TOPLEFT", frame.endeavorsCard, "BOTTOMLEFT", 0, -8)
  frame.craftingCard:SetPoint("BOTTOMRIGHT")
  frame.characterValue = CreateStatLine(frame.craftingCard, "This Character", -48, "success")
  frame.altsValue = CreateStatLine(frame.craftingCard, "Other Characters", -76, "accent")
  frame.accountValue = CreateStatLine(frame.craftingCard, "Account Total", -104, "text")
  frame.todayValue = CreateStatLine(frame.craftingCard, "Character Today", -142, "accent")

  frame.sourcesTab:SetScript("OnClick", function()
    Statistics:GetSettings().view = "sources"
    Controls():ResetScrollFrame(frame.breakdownScroll, false)
    Statistics:RenderBreakdown()
  end)
  frame.expansionsTab:SetScript("OnClick", function()
    Statistics:GetSettings().view = "expansions"
    Controls():ResetScrollFrame(frame.breakdownScroll, false)
    Statistics:RenderBreakdown()
  end)
  frame.professionsTab:SetScript("OnClick", function()
    Statistics:GetSettings().view = "professions"
    Controls():ResetScrollFrame(frame.breakdownScroll, false)
    Statistics:RenderBreakdown()
  end)
  frame.houseButton:SetScript("OnClick", function(self)
    local system = NS.Systems.Endeavors
    local options = {}
    for index, house in ipairs(system and system:GetHouses() or {}) do
      options[#options + 1] = { value = index, label = house.houseName or house.neighborhoodName or ("House " .. index) }
    end
    if #options == 0 then options[1] = { value = 0, label = "Refresh house list" } end
    NS.UI.Dropdown:Show(self, options, system and system:GetSelectedHouseIndex() or 0, function(index)
      if index == 0 then system:RequestHouseList() else system:SelectHouse(index) end
    end)
  end)
  frame.refreshButton:SetScript("OnClick", function()
    NS.Systems.Collection:Invalidate()
    local system = NS.Systems.Endeavors
    if system then system:Fetch(true) system:RequestActivityLog() end
    Statistics:Refresh()
  end)
  frame:SetScript("OnShow", function()
    local system = NS.Systems.Endeavors
    if system then
      if #system:GetHouses() == 0 then system:RequestHouseList() end
      system:Fetch()
    end
    Statistics:Refresh()
  end)
  frame:SetScript("OnHide", function()
    Controls():CloseTransientPopups()
    for _, row in ipairs(frame.breakdownRows) do row.entry = nil end
    Controls():CollectGarbageIncrementally()
  end)
  frame:SetScript("OnSizeChanged", function() Statistics:Layout() Statistics:RenderBreakdown() end)
  frame.breakdownScroll:HookScript("OnSizeChanged", function(self)
    frame.breakdownContent:SetWidth(math.max(1, (self:GetWidth() or 1) - 2))
    Statistics:LayoutBreakdownRows()
    Statistics:RenderBreakdown()
  end)

  self.panel = frame
  self.frame = frame
  self:Layout()
  self:Refresh()
  return frame
end

function Statistics:Toggle()
  if NS.UI.CatalogView then NS.UI.CatalogView:Open("statistics") end
end

NS.OnMessage("HOMEDECOR_ENDEAVORS_UPDATED", function()
  if Statistics.panel and Statistics.panel:IsShown() then Statistics:RefreshEndeavors() end
end)

NS.OnMessage("HOMEDECOR_SALES_UPDATED", function()
  if Statistics.panel and Statistics.panel:IsShown() then Statistics:RefreshCrafting() end
end)

return Statistics
