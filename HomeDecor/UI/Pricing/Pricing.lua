local _, NS = ...

NS.UI = NS.UI or {}
local Pricing = {}
NS.UI.DecorPricing = Pricing

local ROW_HEIGHT = 34
local ROW_COUNT = 15
local SCAN_FRAME_BUDGET = 2
local SCAN_MAX_PER_FRAME = 4

local COLUMNS = {
  { key = "name", label = "NAME", width = 184, flex = true, align = "LEFT" },
  { key = "profession", label = "PROFESSION", width = 82, align = "LEFT" },
  { key = "expansion", label = "EXPANSION", width = 78, align = "LEFT" },
  { key = "crafter", label = "CRAFT", width = 66, align = "LEFT" },
  { key = "lumber", label = "LUMBER", width = 70, align = "LEFT" },
  { key = "cost", label = "COST", width = 62, align = "RIGHT" },
  { key = "sell", label = "SELL", width = 62, align = "RIGHT" },
  { key = "profit", label = "PROFIT", width = 66, align = "RIGHT" },
  { key = "ppl", label = "PER LBR", width = 64, align = "RIGHT" },
  { key = "margin", label = "%", width = 38, align = "RIGHT" },
}

local function Controls()
  return NS.UI and NS.UI.Controls
end

local function Colors()
  return (Controls() and Controls().colors) or {}
end

local function Backdrop(frame, background, border)
  local controls = Controls()
  if controls and controls.Backdrop then controls:Backdrop(frame, background, border) end
end

local function TextColor(text, role, alpha)
  local controls = Controls()
  if controls and controls.TextColor then controls:TextColor(text, role, alpha) end
end

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  TextColor(text, role or "text")
  return text
end

local function Button(parent, label, width, height)
  local controls = Controls()
  if controls and controls.CreateButton then return controls:CreateButton(parent, label, width or 100, height or 26) end
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetSize(width or 100, height or 26)
  button:SetText(label or "")
  return button
end

local function PriceSource()
  return NS.Systems and NS.Systems.PriceSource
end

local function sourceLabel()
  local source = PriceSource()
  local preferred = source and source.GetPreferredSource and source.GetPreferredSource()
  if preferred then return preferred end
  local available = source and source.GetAvailableSources and source.GetAvailableSources() or {}
  if #available == 0 then return "No provider" end
  return #available == 1 and available[1] or "Automatic"
end

local function sourceOptions()
  local source = PriceSource()
  local options = { { value = "auto", label = "Automatic" } }
  for _, name in ipairs(source and source.GetAvailableSources and source.GetAvailableSources() or {}) do
    options[#options + 1] = { value = name, label = name }
  end
  return options
end

local function formatPrice(value)
  if value == nil then return "--" end
  local source = PriceSource()
  return source and source.FormatGold and source.FormatGold(value) or tostring(value)
end

local function formatAge(timestamp)
  if not timestamp then return nil end
  local elapsed = math.max(0, time() - timestamp)
  if elapsed < 60 then return "just now" end
  if elapsed < 3600 then return tostring(math.floor(elapsed / 60)) .. "m ago" end
  if elapsed < 86400 then return tostring(math.floor(elapsed / 3600)) .. "h ago" end
  return tostring(math.floor(elapsed / 86400)) .. "d ago"
end

local function itemName(itemID, fallback)
  return NS.Systems.ItemResolver:GetName(itemID, fallback)
end

local function itemIcon(itemID)
  return NS.Systems.ItemResolver:GetIcon(itemID)
end

local function setMoney(text, value, role)
  text:SetText(value ~= nil and formatPrice(value) or "--")
  TextColor(text, role or (value ~= nil and "text" or "muted"))
end

local function getReagents(entry)
  return NS.Systems.MarketData:GetReagents(entry)
end

local function createMetric(parent, label)
  local colors = Colors()
  local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  card:SetHeight(56)
  Backdrop(card, colors.panel, colors.border)
  card.label = Font(card, "GameFontNormalSmall", "muted")
  card.label:SetPoint("TOPLEFT", 12, -9)
  card.label:SetText(label)
  card.value = Font(card, "GameFontNormalLarge", "accent")
  card.value:SetPoint("BOTTOMLEFT", 12, 9)
  card.value:SetPoint("RIGHT", -10, 0)
  card.value:SetJustifyH("LEFT")
  card.value:SetText("--")
  return card
end

local function createCheck(parent, label)
  local button = Controls():CreateCheckButton(parent, label)
  button:SetSize(24, 24)
  TextColor(button.label, "text")
  return button
end

local function createRow(parent)
  local colors = Colors()
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  Backdrop(row, colors.row, colors.border)
  if Controls() and Controls().ApplyHover then Controls():ApplyHover(row, colors.row, colors.hover) end
  row.favorite = NS.UI.FavoriteStar:Create(row, 18, function() Pricing:RefreshView() end)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(25, 25)
  row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  row.cells = {}
  for _, column in ipairs(COLUMNS) do
    local text = Font(row, column.key == "name" and "GameFontNormal" or "GameFontNormalSmall", column.key == "name" and "text" or "muted")
    text:SetJustifyH(column.align)
    text:SetWordWrap(false)
    row.cells[column.key] = text
  end
  row:SetScript("OnEnter", function(self)
    if not self.entry or not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(self.entry.itemID)
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Recipe profit", formatPrice(self.entry.profit), 1, 0.76, 0.08, 0.36, 0.92, 0.52)
    if self.entry.crafter and self.entry.crafter ~= "-" then GameTooltip:AddDoubleLine("Crafters", self.entry.crafter, 0.64, 0.62, 0.56, 0.93, 0.91, 0.85) end
    if self.entry.missingPrices > 0 then GameTooltip:AddLine(tostring(self.entry.missingPrices) .. " material price(s) unavailable", 1, 0.38, 0.38) end
    local history = NS.Systems.MarketHistory and NS.Systems.MarketHistory:GetStats(self.entry.itemID, 7)
    if history then
      GameTooltip:AddDoubleLine("7-day average", formatPrice(history.average), 0.64, 0.62, 0.56, 0.93, 0.91, 0.85)
      GameTooltip:AddDoubleLine("Profit trend", string.format("%+.1f%%", history.trend), 0.64, 0.62, 0.56, history.trend >= 0 and 0.36 or 1, history.trend >= 0 and 0.92 or 0.38, history.trend >= 0 and 0.52 or 0.38)
    end
    GameTooltip:AddLine("Left click to inspect | Right click to queue", 0.64, 0.62, 0.56)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  row:SetScript("OnClick", function(self, mouseButton)
    if not self.entry then return end
    Pricing.selected = self.entry
    if mouseButton == "RightButton" then Pricing:AddToQueue(self.entry, 1) end
    Pricing:UpdateInspector()
    Pricing:Render()
  end)
  row:Hide()
  return row
end

function Pricing:GetSettings()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.decorPricing = profile.decorPricing or {}
  local settings = profile.decorPricing
  settings.profession = settings.profession or "All"
  settings.expansion = settings.expansion or "All"
  settings.lumber = settings.lumber or "All"
  settings.search = settings.search or ""
  settings.sort = settings.sort or "profitDesc"
  if not settings.sortColumn then
    local legacy = {
      name = { "name", true },
      costAsc = { "cost", true },
      sellDesc = { "sell", false },
      marginDesc = { "margin", false },
      pplDesc = { "ppl", false },
      profitDesc = { "profit", false },
    }
    local sort = legacy[settings.sort] or legacy.profitDesc
    settings.sortColumn = sort[1]
    settings.sortAscending = sort[2]
  end
  settings.queue = settings.queue or {}
  settings.queueItems = settings.queueItems or {}
  return settings
end

function Pricing:GetQueueSize()
  local queue = NS.Systems.CraftingQueue
  return queue and queue:GetSize() or 0
end

function Pricing:AddToQueue(entry, quantity)
  if not entry then return end
  NS.Systems.CraftingQueue:Add(entry, quantity, getReagents(entry.entry))
  self:UpdateMetrics()
  self:UpdateQueueButton()
  if NS.UI.QueueWindow then NS.UI.QueueWindow:Refresh() end
end

function Pricing:UpdateQueueButton()
  if not self.panel then return end
  self.panel.queueButton:SetText("Queue (" .. tostring(self:GetQueueSize()) .. ")")
  local window = NS.UI.QueueWindow and NS.UI.QueueWindow.frame
  if Controls() then Controls():SetButtonSelected(self.panel.queueButton, window and window:IsShown() or false) end
end

function Pricing:FindEntryByItemID(itemID)
  itemID = tonumber(itemID)
  return itemID and self.entryByItemID and self.entryByItemID[itemID] or nil
end

function Pricing:UpdateSortHeaders()
  local frame = self.panel
  if not frame or not frame.columnHeaders then return end
  local settings = self:GetSettings()
  for _, column in ipairs(COLUMNS) do
    local header = frame.columnHeaders[column.key]
    local active = settings.sortColumn == column.key
    header.label:SetText(column.label .. (active and (settings.sortAscending and "  ^" or "  v") or ""))
    TextColor(header.label, active and "accent" or "muted")
  end
  if frame.sortButton then
    local label = settings.sortColumn
    for _, column in ipairs(COLUMNS) do if column.key == settings.sortColumn then label = column.label break end end
    frame.sortButton:SetText(label .. (settings.sortAscending and ": Low" or ": High"))
  end
end

function Pricing:SetSortColumn(key, ascending)
  local settings = self:GetSettings()
  if settings.sortColumn == key and ascending == nil then
    settings.sortAscending = not settings.sortAscending
  else
    settings.sortColumn = key
    if ascending ~= nil then
      settings.sortAscending = ascending
    else
      settings.sortAscending = key == "name" or key == "profession" or key == "crafter" or key == "lumber"
    end
  end
  settings.sort = nil
  self:UpdateSortHeaders()
  if self.panel and self.panel.sortButton then
    local label = key
    for _, column in ipairs(COLUMNS) do if column.key == key then label = column.label break end end
    self.panel.sortButton:SetText(label .. (settings.sortAscending and ": Low" or ": High"))
    Controls():ResetScrollFrame(self.panel.scroll, false)
  end
  self:RefreshView()
end

function Pricing:BuildCandidates()
  return NS.Systems.MarketData:BuildCandidates()
end

function Pricing:PriceCandidate(candidate, result)
  return NS.Systems.MarketData:Price(candidate, result)
end

function Pricing:UpdateHeader()
  local frame = self.panel
  if not frame then return end
  local source = PriceSource()
  local available = source and source.GetAvailableSources and source.GetAvailableSources() or {}
  frame.source:SetText("Price source: " .. sourceLabel())
  frame.sourceButton:SetText(sourceLabel())
  if #available == 0 then
    frame.providerStatus:SetText("Install Auctionator or TradeSkillMaster to calculate recipe profit.")
    TextColor(frame.providerStatus, "danger")
  else
    local scanAge = source and source.GetLastAuctionatorScanTime and formatAge(source.GetLastAuctionatorScanTime())
    frame.providerStatus:SetText("Connected: " .. table.concat(available, " + ") .. (scanAge and ("  |  scan " .. scanAge) or ""))
    TextColor(frame.providerStatus, "success")
  end
end

function Pricing:UpdateMetrics()
  local frame = self.panel
  if not frame then return end
  local priced = 0
  local profits = {}
  local best
  local queueValue = 0
  local settings = self:GetSettings()
  for _, entry in ipairs(self.entries or {}) do
    if entry.profit ~= nil and entry.missingPrices == 0 then
      priced = priced + 1
      profits[#profits + 1] = entry.profit
      if not best or entry.profit > best then best = entry.profit end
    end
    local quantity = tonumber(settings.queue[tostring(entry.itemID)]) or 0
    if quantity > 0 and entry.cost then queueValue = queueValue + entry.cost * quantity end
  end
  table.sort(profits)
  local median
  if #profits > 0 then
    local middle = math.floor((#profits + 1) / 2)
    median = #profits % 2 == 0 and math.floor((profits[middle] + profits[middle + 1]) / 2) or profits[middle]
  end
  frame.metrics[1].value:SetText(tostring(priced) .. " / " .. tostring(#(self.entries or {})))
  frame.metrics[2].value:SetText(formatPrice(best))
  frame.metrics[3].value:SetText(formatPrice(median))
  frame.metrics[4].value:SetText(formatPrice(queueValue > 0 and queueValue or nil))
end

function Pricing:BuildView()
  if self.view and not self.viewDirty then return end
  local settings = self:GetSettings()
  if not settings then return end
  local query = tostring(settings.search or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local view = self.view or {}
  local favorites = {}
  local count = 0
  for _, entry in ipairs(self.entries or {}) do
    local queued = (tonumber(settings.queue[tostring(entry.itemID)]) or 0) > 0
    local favorite = NS.Systems.Favorites:IsFavorite(entry.entry)
    favorites[entry] = favorite
    local knowledgeMatch = (not settings.knownOnly and not settings.altsOnly)
      or (settings.knownOnly and entry.known == true)
      or (settings.altsOnly and entry.altKnown == true)
    local include = (settings.profession == "All" or entry.profession == settings.profession)
      and (settings.expansion == "All" or entry.expansion == settings.expansion)
      and (settings.lumber == "All" or entry.lumber == settings.lumber)
      and (query == "" or entry.searchName:find(query, 1, true) or tostring(entry.itemID):find(query, 1, true) or tostring(entry.profession):lower():find(query, 1, true) or tostring(entry.expansion):lower():find(query, 1, true))
      and knowledgeMatch
      and (not settings.favoritesOnly or favorite)
      and (not settings.profitableOnly or (entry.profit and entry.profit > 0))
      and (not self.queueOnly or queued)
    if include then
      count = count + 1
      view[count] = entry
    end
  end
  for index = count + 1, #view do view[index] = nil end
  local key = settings.sortColumn or "profit"
  local ascending = settings.sortAscending == true
  table.sort(view, function(a, b)
    if favorites[a] ~= favorites[b] then return favorites[a] == true end
    local av = a[key]
    local bv = b[key]
    if av == nil and bv == nil then return (a.name or "") < (b.name or "") end
    if av == nil then return false end
    if bv == nil then return true end
    if type(av) == "string" then av = av:lower() end
    if type(bv) == "string" then bv = bv:lower() end
    if av == bv then return (a.name or "") < (b.name or "") end
    if ascending then return av < bv end
    return av > bv
  end)
  self.view = view
  self.viewDirty = nil
end

function Pricing:RefreshView()
  self.viewDirty = true
  self:Render()
end

function Pricing:LayoutTable()
  local frame = self.panel
  if not frame then return end
  local width = math.max(680, frame.scroll:GetWidth() or frame.listPanel:GetWidth() or 780)
  local fixed = 56
  for _, column in ipairs(COLUMNS) do if not column.flex then fixed = fixed + column.width end end
  local flexible = math.max(132, width - fixed - 10)
  local x = 58
  for _, column in ipairs(COLUMNS) do
    column.currentWidth = column.flex and flexible or column.width
    column.x = x
    local header = frame.columnHeaders[column.key]
    header:ClearAllPoints()
    header:SetPoint("LEFT", frame.columns, "LEFT", x, 0)
    header:SetWidth(column.currentWidth - 5)
    x = x + column.currentWidth
  end
  for _, row in ipairs(frame.rows) do
    row.favorite:ClearAllPoints()
    row.favorite:SetPoint("LEFT", row, "LEFT", 5, 0)
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", row, "LEFT", 28, 0)
    for _, column in ipairs(COLUMNS) do
      local cell = row.cells[column.key]
      cell:ClearAllPoints()
      cell:SetPoint("LEFT", row, "LEFT", column.x, 0)
      cell:SetWidth(column.currentWidth - 5)
    end
  end
end

function Pricing:Render()
  local frame = self.panel
  if not frame or not frame:IsShown() then return end
  self:BuildView()
  local view = self.view or {}
  frame.resultCount:SetText(tostring(#view) .. " / " .. tostring(#(self.entries or {})) .. " recipes")
  frame.content:SetHeight(math.max(1, #view * ROW_HEIGHT))
  local maxScroll = math.max(0, frame.content:GetHeight() - frame.scroll:GetHeight())
  if frame.scroll:GetVerticalScroll() > maxScroll then Controls():SetScrollOffset(frame.scroll, maxScroll, false) end
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  local rowWidth = math.max(1, (frame.content:GetWidth() or frame.scroll:GetWidth() or 1) - 2)
  for rowIndex, row in ipairs(frame.rows) do
    local absolute = first + rowIndex
    local entry = view[absolute]
    row.entry = entry
    row.favorite:SetRecord(entry and entry.entry or nil)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetSize(rowWidth, ROW_HEIGHT - 2)
    row:SetShown(entry ~= nil)
    if entry then
      row.icon:SetTexture(itemIcon(entry.itemID))
      row.cells.name:SetText(entry.name)
      row.cells.profession:SetText(entry.profession)
      row.cells.expansion:SetText(entry.expansion)
      row.cells.crafter:SetText(entry.crafter)
      row.cells.lumber:SetText(entry.lumber)
      setMoney(row.cells.cost, entry.cost)
      setMoney(row.cells.sell, entry.sell, entry.sell and "accent" or "muted")
      setMoney(row.cells.profit, entry.profit, entry.profit and entry.profit >= 0 and "success" or entry.profit and "danger" or "muted")
      setMoney(row.cells.ppl, entry.ppl, entry.ppl and entry.ppl >= 0 and "success" or entry.ppl and "danger" or "muted")
      row.cells.margin:SetText(entry.margin and string.format("%.0f%%", entry.margin) or "--")
      TextColor(row.cells.margin, entry.margin and entry.margin >= 0 and "success" or entry.margin and "danger" or "muted")
      local colors = Colors()
      if row.SetBackdropColor then
        local color = entry == self.selected and colors.hover or colors.row
        row:SetBackdropColor(color[1], color[2], color[3], color[4])
      end
    end
  end
  frame.empty:SetShown(#view == 0 and not self.scanning)
end

function Pricing:UpdateInspector()
  local frame = self.panel
  if not frame then return end
  local entry = self.selected
  frame.inspectorFavorite:SetRecord(entry and entry.entry or nil)
  frame.inspectorEmpty:SetShown(entry == nil)
  frame.inspectorBody:SetShown(entry ~= nil)
  if not entry then return end
  frame.inspectIcon:SetTexture(itemIcon(entry.itemID))
  frame.inspectName:SetText(entry.name)
  frame.inspectMeta:SetText(entry.profession .. "  |  " .. entry.expansion .. "\nItem " .. tostring(entry.itemID))
  local settings = self:GetSettings()
  local quantity = tonumber(settings.queue[tostring(entry.itemID)]) or 0
  frame.queueQty:SetText(tostring(quantity))
  frame.addQueue:SetText(quantity > 0 and "Add Another" or "Add to Queue")
  local reagents = getReagents(entry.entry)
  local source = PriceSource()
  for index, materialRow in ipairs(frame.materialRows) do
    local reagent = reagents[index]
    materialRow:SetShown(reagent ~= nil)
    if reagent then
      local reagentID = tonumber(reagent.itemID)
      local quantity = tonumber(reagent.count or reagent.qty or reagent.amount) or 1
      local price = source and source.GetItemPrice and source.GetItemPrice(reagentID)
      local subtotal = price and price * quantity or nil
      materialRow.icon:SetTexture(itemIcon(reagentID))
      materialRow.name:SetText(tostring(quantity) .. "x " .. itemName(reagentID))
      materialRow.price:SetText(subtotal and formatPrice(subtotal) or "No price")
      TextColor(materialRow.price, subtotal and "text" or "danger")
    end
  end
  frame.materialContent:SetHeight(math.max(1, math.min(#reagents, #frame.materialRows) * 27))
  Controls():ResetScrollFrame(frame.materialScroll, false)
  if entry.noSchematic then
    frame.materialStatus:SetText("Open this profession once to load its recipe materials.")
    TextColor(frame.materialStatus, "danger")
  elseif entry.missingPrices > 0 then
    frame.materialStatus:SetText(tostring(entry.missingPrices) .. " unpriced material(s) excluded")
    TextColor(frame.materialStatus, "danger")
  else
    frame.materialStatus:SetText(tostring(#reagents) .. " priced materials")
    TextColor(frame.materialStatus, "success")
  end
  setMoney(frame.inspectCost, entry.cost)
  setMoney(frame.inspectSell, entry.sell, entry.sell and "accent" or "muted")
  setMoney(frame.inspectProfit, entry.profit, entry.profit and entry.profit >= 0 and "success" or entry.profit and "danger" or "muted")
  frame.inspectMargin:SetText(entry.margin and string.format("%.1f%%", entry.margin) or "--")
  TextColor(frame.inspectMargin, entry.margin and entry.margin >= 0 and "success" or entry.margin and "danger" or "muted")
  local history = NS.Systems.MarketHistory and NS.Systems.MarketHistory:GetStats(entry.itemID, 7)
  if history then
    frame.inspectTrend:SetText("7d " .. formatPrice(history.average) .. "  " .. string.format("%+.1f%%", history.trend))
    TextColor(frame.inspectTrend, history.trend >= 0 and "success" or "danger")
  else
    frame.inspectTrend:SetText("")
    TextColor(frame.inspectTrend, "muted")
  end
end

function Pricing:ExportQueue()
  local settings = self:GetSettings()
  local lines = { "HomeDecor crafting queue" }
  local materialTotals = {}
  local itemCount = 0
  for _, entry in ipairs(self.entries or {}) do
    local quantity = tonumber(settings.queue[tostring(entry.itemID)]) or 0
    if quantity > 0 then
      itemCount = itemCount + 1
      lines[#lines + 1] = tostring(quantity) .. "x " .. entry.name
      for _, reagent in ipairs(getReagents(entry.entry)) do
        local reagentID = tonumber(reagent.itemID)
        local reagentCount = tonumber(reagent.count or reagent.qty or reagent.amount) or 1
        materialTotals[reagentID] = (materialTotals[reagentID] or 0) + reagentCount * quantity
      end
    end
  end
  if itemCount == 0 and self.selected then
    lines[1] = "HomeDecor recipe"
    lines[#lines + 1] = "1x " .. self.selected.name
    for _, reagent in ipairs(getReagents(self.selected.entry)) do
      local reagentID = tonumber(reagent.itemID)
      materialTotals[reagentID] = tonumber(reagent.count or reagent.qty or reagent.amount) or 1
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "Materials"
  local materialLines = {}
  for reagentID, quantity in pairs(materialTotals) do materialLines[#materialLines + 1] = tostring(quantity) .. "x " .. itemName(reagentID) end
  table.sort(materialLines)
  for _, line in ipairs(materialLines) do lines[#lines + 1] = line end
  local popup = self.panel.exportPopup
  popup.edit:SetText(table.concat(lines, "\n"))
  popup:Show()
  popup.edit:SetFocus()
  popup.edit:HighlightText()
end

function Pricing:StartScan(force)
  local frame = self.panel
  if not frame or (self.scanning and not force) then return end
  local source = PriceSource()
  if not source then return end
  if force and source.FlushPriceCache then source.FlushPriceCache() end
  if force and NS.Systems.MarketData.InvalidatePrices then NS.Systems.MarketData:InvalidatePrices() end
  self.scanToken = (self.scanToken or 0) + 1
  self.invalidated = false
  local token = self.scanToken
  local candidates = self:BuildCandidates()
  local entries = self.entries or {}
  local byItemID = self.entryByItemID or {}
  local pending = {}
  wipe(byItemID)
  for position = 1, #candidates do
    local candidate = candidates[position]
    local cached = NS.Systems.MarketData:GetCachedPrice(candidate)
    local entry = cached
    if not cached then
      entry = entries[position]
      if not entry then entry = {} end
      pending[#pending + 1] = { candidate = candidate, position = position }
    end
    entries[position] = entry
    if not cached and entry.entry ~= candidate.entry then
      wipe(entry)
      entry.entry = candidate.entry
      entry.itemID = candidate.itemID
      entry.skillID = candidate.skillID
      entry.name = candidate.entry.title or ("Item " .. tostring(candidate.itemID))
      entry.searchName = entry.name:lower()
      entry.profession = candidate.profession
      entry.expansion = candidate.expansion
      entry.crafter = "-"
      local knowledge = NS.Systems.RecipeKnowledge
      local crafters, altKnown = {}, false
      if knowledge and candidate.skillID then crafters, altKnown = knowledge:GetCrafters(candidate.skillID) end
      entry.crafter = #crafters > 0 and table.concat(crafters, ", ") or "-"
      entry.known = knowledge and knowledge:IsCurrentKnown(candidate.skillID) or false
      entry.altKnown = altKnown == true
      entry.lumber = "-"
      entry.lumberCount = 0
      entry.missingPrices = 0
      entry.noSchematic = true
    end
    byItemID[candidate.itemID] = entry
  end
  for position = #candidates + 1, #entries do entries[position] = nil end
  self.entries = entries
  self.entryByItemID = byItemID
  self.viewDirty = true
  self.scanning = #pending > 0
  frame.refreshButton:SetEnabled(#pending == 0)
  frame.progress:SetText(#pending > 0 and ("Recipes ready. Finishing " .. tostring(#pending) .. " cached lookups...") or "Cached recipe prices ready")
  self:UpdateMetrics()
  self:Render()
  local index = 1
  local function step()
    if token ~= self.scanToken then return end
    local started = debugprofilestop and debugprofilestop()
    local processed = 0
    local last = index - 1
    while index <= #pending do
      local work = pending[index]
      entries[work.position] = self:PriceCandidate(work.candidate, entries[work.position])
      last = index
      index = index + 1
      processed = processed + 1
      if processed >= SCAN_MAX_PER_FRAME then break end
      if started and debugprofilestop() - started >= SCAN_FRAME_BUDGET then break end
    end
    frame.progress:SetText("Finishing cached prices... " .. tostring(last) .. " / " .. tostring(#pending))
    if index <= #pending then C_Timer.After(0, step) return end
    for position = #candidates + 1, #entries do entries[position] = nil end
    self.entries = entries
    byItemID = self.entryByItemID or {}
    wipe(byItemID)
    for _, entry in ipairs(entries) do byItemID[entry.itemID] = entry end
    self.entryByItemID = byItemID
    self.viewDirty = true
    local settings = self:GetSettings()
    for _, entry in ipairs(entries) do
      if (tonumber(settings.queue[tostring(entry.itemID)]) or 0) > 0 then NS.Systems.CraftingQueue:Add(entry, 0, getReagents(entry.entry)) end
    end
    self.scanning = false
    self.lastRefresh = time()
    frame.refreshButton:SetEnabled(true)
    frame.progress:SetText(#candidates > 0 and "Cached recipe prices ready" or "No profession decor recipes were found")
    self:UpdateHeader()
    self:UpdateMetrics()
    self:UpdateInspector()
    self:Render()
    local controls = Controls()
    if controls and controls.CollectGarbageIncrementally then controls:CollectGarbageIncrementally() end
  end
  step()
end

function Pricing:QueueScan(force)
  if not self.panel or not self.panel:IsShown() or (self.scanning and not force) then return end
  self.scanRequestToken = (self.scanRequestToken or 0) + 1
  local token = self.scanRequestToken
  self.panel.progress:SetText("Loading saved recipe list...")
  C_Timer.After(0, function()
    if token == Pricing.scanRequestToken and Pricing.panel and Pricing.panel:IsShown() then Pricing:StartScan(force == true) end
  end)
end

function Pricing:OnPriceDatabaseUpdated()
  self.invalidated = true
  if NS.Systems.MarketData.InvalidatePrices then NS.Systems.MarketData:InvalidatePrices() end
  NS.Systems.MarketData:WarmPrices()
  if self.panel and self.panel:IsShown() then self:QueueScan(false) end
end

function Pricing:InvalidateRecipeData()
  NS.Systems.MarketData:InvalidateRecipes()
  NS.Systems.MarketData:InvalidatePrices()
  self.invalidated = true
end

function Pricing:Layout()
  local frame = self.panel
  if not frame then return end
  local available = math.max(840, (frame:GetWidth() or 1100) - 32)
  local gap = 10
  local metricWidth = math.floor((available - gap * 3) / 4)
  for index, card in ipairs(frame.metrics) do
    card:ClearAllPoints()
    card:SetWidth(metricWidth)
    card:SetPoint("TOPLEFT", frame, "TOPLEFT", 16 + (index - 1) * (metricWidth + gap), -80)
  end
  local inspectorWidth = available >= 980 and 284 or 248
  frame.inspector:SetWidth(inspectorWidth)
  frame.content:SetWidth(math.max(1, (frame.scroll:GetWidth() or 760) - 2))
  self:LayoutTable()
end

function Pricing:Create(parent)
  if self.panel then
    self.panel:SetParent(parent)
    self.panel:ClearAllPoints()
    self.panel:SetAllPoints(parent)
    return self.panel
  end
  local colors = Colors()
  local frame = CreateFrame("Frame", "HomeDecorPricingPanel", parent, "BackdropTemplate")
  frame:SetAllPoints(parent)
  Backdrop(frame, colors.background, colors.border)

  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(60)
  Backdrop(header, colors.header, colors.border)
  frame.title = Font(header, "GameFontNormalLarge", "accent")
  frame.title:SetPoint("TOPLEFT", 14, -10)
  frame.title:SetText("Decor Crafting Market")
  frame.subtitle = Font(header, "GameFontNormalSmall", "muted")
  frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
  frame.subtitle:SetText("Recipe costs, live sell prices, profit margins, and lumber efficiency")
  frame.source = Font(header, "GameFontNormalSmall", "text")
  frame.source:SetPoint("TOPRIGHT", -14, -11)
  frame.providerStatus = Font(header, "GameFontNormalSmall", "muted")
  frame.providerStatus:SetPoint("TOPRIGHT", frame.source, "BOTTOMRIGHT", 0, -5)

  frame.metrics = {
    createMetric(frame, "COMPLETE PRICING"),
    createMetric(frame, "BEST PROFIT"),
    createMetric(frame, "MEDIAN PROFIT"),
    createMetric(frame, "QUEUE MATERIAL COST"),
  }

  local toolbar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  toolbar:SetPoint("TOPLEFT", 8, -144)
  toolbar:SetPoint("TOPRIGHT", -8, -144)
  toolbar:SetHeight(66)
  Backdrop(toolbar, colors.header, colors.border)
  frame.professionButton = Button(toolbar, "Profession: All", 148)
  frame.professionButton:SetPoint("TOPLEFT", 8, -6)
  frame.expansionButton = Button(toolbar, "Expansion: All", 150)
  frame.expansionButton:SetPoint("LEFT", frame.professionButton, "RIGHT", 7, 0)
  frame.lumberButton = Button(toolbar, "Lumber: All", 126)
  frame.lumberButton:SetPoint("LEFT", frame.expansionButton, "RIGHT", 7, 0)
  frame.sourceButton = Button(toolbar, "Automatic", 108)
  frame.sourceButton:SetPoint("LEFT", frame.lumberButton, "RIGHT", 7, 0)
  frame.refreshButton = Button(toolbar, "Refresh", 92)
  frame.refreshButton:SetPoint("TOPRIGHT", -8, -6)
  frame.queueButton = Button(toolbar, "Queue (0)", 96)
  frame.queueButton:SetPoint("RIGHT", frame.refreshButton, "LEFT", -7, 0)
  frame.salesButton = Button(toolbar, "Sales", 78)
  frame.salesButton:SetPoint("RIGHT", frame.queueButton, "LEFT", -7, 0)

  frame.search = Controls():CreateSearchBox(toolbar, {
    height = 25,
    placeholder = "Search recipe, profession, expansion, or item ID",
    background = colors.background,
    border = colors.border,
    placeholderColor = "muted",
    onChanged = function(self)
      local settings = Pricing:GetSettings()
      if settings then settings.search = self:GetText() or "" end
      Pricing.searchToken = (Pricing.searchToken or 0) + 1
      local token = Pricing.searchToken
      C_Timer.After(0.12, function()
        if token == Pricing.searchToken then Controls():ResetScrollFrame(frame.scroll, false) Pricing:RefreshView() end
      end)
    end,
  })
  frame.search:SetPoint("BOTTOMLEFT", 8, 6)
  frame.search:SetSize(290, 25)
  frame.searchHint = frame.search.placeholder
  frame.knownOnly = createCheck(toolbar, "Known")
  frame.knownOnly:SetPoint("LEFT", frame.search, "RIGHT", 9, 0)
  frame.profitableOnly = createCheck(toolbar, "Profitable")
  frame.profitableOnly:SetPoint("LEFT", frame.knownOnly.label, "RIGHT", 10, 0)
  frame.favoritesOnly = createCheck(toolbar, "Saved")
  frame.favoritesOnly:SetPoint("LEFT", frame.profitableOnly.label, "RIGHT", 10, 0)
  frame.altsOnly = createCheck(toolbar, "Alts")
  frame.altsOnly:SetPoint("LEFT", frame.favoritesOnly.label, "RIGHT", 10, 0)
  frame.sortButton = Button(toolbar, "Profit: High", 112)
  frame.sortButton:SetPoint("LEFT", frame.altsOnly.label, "RIGHT", 12, 0)
  frame.resultCount = Font(toolbar, "GameFontNormalSmall", "muted")
  frame.resultCount:SetPoint("BOTTOMRIGHT", -12, 12)

  frame.listPanel = CreateFrame("Frame", nil, frame)
  frame.listPanel:SetPoint("TOPLEFT", 8, -218)
  frame.listPanel:SetPoint("BOTTOMRIGHT", -304, 34)
  frame.columns = CreateFrame("Frame", nil, frame.listPanel, "BackdropTemplate")
  frame.columns:SetPoint("TOPLEFT")
  frame.columns:SetPoint("TOPRIGHT")
  frame.columns:SetHeight(26)
  Backdrop(frame.columns, colors.panel, colors.border)
  frame.columnHeaders = {}
  for _, column in ipairs(COLUMNS) do
    local key = column.key
    local button = CreateFrame("Button", nil, frame.columns)
    button:SetHeight(24)
    button.label = Font(button, "GameFontNormalSmall", "muted")
    button.label:SetPoint("LEFT")
    button.label:SetPoint("RIGHT")
    button.label:SetJustifyH(column.align)
    button:SetScript("OnClick", function() Pricing:SetSortColumn(key) end)
    button:SetScript("OnEnter", function(self) TextColor(self.label, "accent") end)
    button:SetScript("OnLeave", function(self) TextColor(self.label, Pricing:GetSettings().sortColumn == key and "accent" or "muted") end)
    frame.columnHeaders[key] = button
  end
  frame.scroll = Controls():CreateScrollFrame(frame.listPanel)
  frame.scroll:SetPoint("TOPLEFT", frame.columns, "BOTTOMLEFT", 0, -2)
  frame.scroll:SetPoint("BOTTOMRIGHT", -20, 0)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(760, 1)
  Controls():ConfigureScrollFrame(frame.scroll, frame.content, { step = ROW_HEIGHT, barInset = -18, onScroll = function() Pricing:Render() end })
  frame.rows = {}
  for index = 1, ROW_COUNT do
    frame.rows[index] = createRow(frame.content)
    Controls():ForwardScrollWheel(frame.rows[index], frame.scroll)
  end
  frame.empty = Font(frame.listPanel, "GameFontHighlight", "muted")
  frame.empty:SetPoint("CENTER", frame.scroll, "CENTER")
  frame.empty:SetWidth(420)
  frame.empty:SetJustifyH("CENTER")
  frame.empty:SetText("No recipes match the current filters.")
  frame.empty:Hide()

  frame.inspector = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.inspector:SetPoint("TOPRIGHT", -8, -218)
  frame.inspector:SetPoint("BOTTOMRIGHT", -8, 34)
  Backdrop(frame.inspector, colors.header, colors.border)
  frame.inspectorTitle = Font(frame.inspector, "GameFontNormal", "accent")
  frame.inspectorTitle:SetPoint("TOPLEFT", 12, -11)
  frame.inspectorTitle:SetText("Selected Item")
  frame.inspectorFavorite = NS.UI.FavoriteStar:Create(frame.inspector, 19, function() Pricing:RefreshView() end)
  frame.inspectorFavorite:SetPoint("TOPRIGHT", -10, -8)
  frame.inspectorEmpty = Font(frame.inspector, "GameFontNormalSmall", "muted")
  frame.inspectorEmpty:SetPoint("TOPLEFT", 14, -48)
  frame.inspectorEmpty:SetPoint("RIGHT", -14, 0)
  frame.inspectorEmpty:SetJustifyH("LEFT")
  frame.inspectorEmpty:SetText("Select a recipe to inspect its materials, pricing, and queue actions.")
  frame.inspectorBody = CreateFrame("Frame", nil, frame.inspector)
  frame.inspectorBody:SetPoint("TOPLEFT", 10, -38)
  frame.inspectorBody:SetPoint("BOTTOMRIGHT", -10, 10)
  frame.inspectIcon = frame.inspectorBody:CreateTexture(nil, "ARTWORK")
  frame.inspectIcon:SetSize(42, 42)
  frame.inspectIcon:SetPoint("TOPLEFT")
  frame.inspectIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  frame.inspectName = Font(frame.inspectorBody, "GameFontNormal", "accent")
  frame.inspectName:SetPoint("TOPLEFT", frame.inspectIcon, "TOPRIGHT", 9, -1)
  frame.inspectName:SetPoint("RIGHT", -2, 0)
  frame.inspectName:SetJustifyH("LEFT")
  frame.inspectName:SetWordWrap(true)
  frame.inspectMeta = Font(frame.inspectorBody, "GameFontNormalSmall", "muted")
  frame.inspectMeta:SetPoint("TOPLEFT", frame.inspectName, "BOTTOMLEFT", 0, -4)
  frame.inspectMeta:SetPoint("RIGHT", -2, 0)
  frame.inspectMeta:SetJustifyH("LEFT")
  frame.materialTitle = Font(frame.inspectorBody, "GameFontNormal", "accent")
  frame.materialTitle:SetPoint("TOPLEFT", 0, -62)
  frame.materialTitle:SetText("Materials")
  frame.materialStatus = Font(frame.inspectorBody, "GameFontNormalSmall", "muted")
  frame.materialStatus:SetPoint("TOPRIGHT", 0, -64)
  frame.materialScroll = Controls():CreateScrollFrame(frame.inspectorBody)
  frame.materialScroll:SetPoint("TOPLEFT", 0, -82)
  frame.materialScroll:SetPoint("RIGHT", -18, 0)
  frame.materialContent = CreateFrame("Frame", nil, frame.materialScroll)
  frame.materialContent:SetSize(240, 324)
  Controls():ConfigureScrollFrame(frame.materialScroll, frame.materialContent, { step = 54 })
  frame.materialRows = {}
  for index = 1, 12 do
    local row = CreateFrame("Frame", nil, frame.materialContent)
    row:SetPoint("TOPLEFT", 0, -((index - 1) * 27))
    row:SetPoint("TOPRIGHT", 0, -((index - 1) * 27))
    row:SetHeight(25)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(21, 21)
    row.icon:SetPoint("LEFT", 1, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    row.name = Font(row, "GameFontNormalSmall", "text")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
    row.name:SetPoint("RIGHT", -78, 0)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.price = Font(row, "GameFontNormalSmall", "muted")
    row.price:SetPoint("RIGHT", -1, 0)
    row.price:SetWidth(74)
    row.price:SetJustifyH("RIGHT")
    Controls():ForwardScrollWheel(row, frame.materialScroll)
    frame.materialRows[index] = row
  end
  local estimate = CreateFrame("Frame", nil, frame.inspectorBody, "BackdropTemplate")
  estimate:SetPoint("BOTTOMLEFT", 0, 70)
  estimate:SetPoint("BOTTOMRIGHT", 0, 70)
  estimate:SetHeight(98)
  frame.materialScroll:SetPoint("BOTTOM", estimate, "TOP", 0, 8)
  Backdrop(estimate, colors.panel, colors.border)
  local estimateTitle = Font(estimate, "GameFontNormal", "accent")
  estimateTitle:SetPoint("TOPLEFT", 9, -8)
  estimateTitle:SetText("Estimated Profit")
  frame.inspectTrend = Font(estimate, "GameFontNormalSmall", "muted")
  frame.inspectTrend:SetPoint("TOPRIGHT", -9, -9)
  local labels = { "Cost", "Sell", "Profit", "Margin" }
  local values = {}
  for index, label in ipairs(labels) do
    local left = Font(estimate, "GameFontNormalSmall", "muted")
    left:SetPoint("TOPLEFT", 9, -28 - (index - 1) * 16)
    left:SetText(label)
    local right = Font(estimate, "GameFontNormalSmall", "text")
    right:SetPoint("TOPRIGHT", -9, -28 - (index - 1) * 16)
    right:SetJustifyH("RIGHT")
    values[index] = right
  end
  frame.inspectCost, frame.inspectSell, frame.inspectProfit, frame.inspectMargin = values[1], values[2], values[3], values[4]
  frame.minusQueue = Button(frame.inspectorBody, "-", 28)
  frame.minusQueue:SetPoint("BOTTOMLEFT", 0, 35)
  frame.queueQty = Font(frame.inspectorBody, "GameFontNormal", "accent")
  frame.queueQty:SetPoint("LEFT", frame.minusQueue, "RIGHT", 10, 0)
  frame.queueQty:SetWidth(28)
  frame.queueQty:SetJustifyH("CENTER")
  frame.plusQueue = Button(frame.inspectorBody, "+", 28)
  frame.plusQueue:SetPoint("LEFT", frame.queueQty, "RIGHT", 10, 0)
  frame.addQueue = Button(frame.inspectorBody, "Add to Queue", 112)
  frame.addQueue:SetPoint("BOTTOMRIGHT", 0, 35)
  frame.exportButton = Button(frame.inspectorBody, "Export", 112)
  frame.exportButton:SetPoint("BOTTOMRIGHT", 0, 0)
  frame.clearQueue = Button(frame.inspectorBody, "Clear Queue", 112)
  frame.clearQueue:SetPoint("RIGHT", frame.exportButton, "LEFT", -7, 0)
  frame.materialScroll:HookScript("OnSizeChanged", function(self)
    frame.materialContent:SetWidth(math.max(1, (self:GetWidth() or 1) - 2))
  end)

  frame.progress = Font(frame, "GameFontNormalSmall", "muted")
  frame.progress:SetPoint("BOTTOMLEFT", 14, 13)
  frame.progress:SetText("Recipe prices have not been loaded yet")

  frame.exportPopup = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.exportPopup:SetSize(500, 330)
  frame.exportPopup:SetPoint("CENTER")
  frame.exportPopup:SetFrameStrata("DIALOG")
  frame.exportPopup:SetFrameLevel(150)
  Backdrop(frame.exportPopup, colors.header, colors.border)
  local exportTitle = Font(frame.exportPopup, "GameFontNormalLarge", "accent")
  exportTitle:SetPoint("TOPLEFT", 14, -13)
  exportTitle:SetText("Export Crafting List")
  local exportHint = Font(frame.exportPopup, "GameFontNormalSmall", "muted")
  exportHint:SetPoint("TOPLEFT", exportTitle, "BOTTOMLEFT", 0, -6)
  exportHint:SetText("Press Ctrl+C to copy the selected text.")
  frame.exportPopup.edit = CreateFrame("EditBox", nil, frame.exportPopup, "BackdropTemplate")
  frame.exportPopup.edit:SetPoint("TOPLEFT", 14, -62)
  frame.exportPopup.edit:SetPoint("BOTTOMRIGHT", -14, 46)
  frame.exportPopup.edit:SetMultiLine(true)
  frame.exportPopup.edit:SetAutoFocus(false)
  frame.exportPopup.edit:SetFontObject(GameFontHighlightSmall)
  frame.exportPopup.edit:SetTextInsets(8, 8, 8, 8)
  Backdrop(frame.exportPopup.edit, colors.background, colors.border)
  local closeExport = Button(frame.exportPopup, "Close", 90)
  closeExport:SetPoint("BOTTOMRIGHT", -14, 12)
  closeExport:SetScript("OnClick", function() frame.exportPopup:Hide() end)
  frame.exportPopup.edit:SetScript("OnEscapePressed", function() frame.exportPopup:Hide() end)
  frame.exportPopup:Hide()


  local function showOptions(anchor, field, prefix, options)
    local settings = Pricing:GetSettings()
    NS.UI.Dropdown:Show(anchor, options, settings[field], function(value)
      settings[field] = value
      anchor:SetText(prefix .. value)
      Controls():ResetScrollFrame(frame.scroll, false)
      Pricing:RefreshView()
    end)
  end
  frame.professionButton:SetScript("OnClick", function(self) showOptions(self, "profession", "Profession: ", Pricing.professionOptions or { "All" }) end)
  frame.expansionButton:SetScript("OnClick", function(self) showOptions(self, "expansion", "Expansion: ", Pricing.expansionOptions or { "All" }) end)
  frame.lumberButton:SetScript("OnClick", function(self) showOptions(self, "lumber", "Lumber: ", Pricing.lumberOptions or { "All" }) end)
  frame.sourceButton:SetScript("OnClick", function(self)
    local source = PriceSource()
    NS.UI.Dropdown:Show(self, sourceOptions(), source.GetPreferredSource() or "auto", function(value)
      source.SetPreferredSource(value == "auto" and nil or value)
      Pricing:UpdateHeader()
      Pricing:QueueScan(false)
    end)
  end)
  frame.sortButton:SetScript("OnClick", function(self)
    local options = {
      { value = "profitDesc", label = "Profit: High" },
      { value = "marginDesc", label = "Margin: High" },
      { value = "pplDesc", label = "Per Lumber" },
      { value = "sellDesc", label = "Sell: High" },
      { value = "costAsc", label = "Cost: Low" },
      { value = "name", label = "Name" },
    }
    local settings = Pricing:GetSettings()
    NS.UI.Dropdown:Show(self, options, settings.sort, function(value)
      settings.sort = value
      local sorts = {
        profitDesc = { "profit", false },
        marginDesc = { "margin", false },
        pplDesc = { "ppl", false },
        sellDesc = { "sell", false },
        costAsc = { "cost", true },
        name = { "name", true },
      }
      local selectedSort = sorts[value] or sorts.profitDesc
      settings.sortColumn = selectedSort[1]
      settings.sortAscending = selectedSort[2]
      for _, option in ipairs(options) do if option.value == value then self:SetText(option.label) end end
      Pricing:UpdateSortHeaders()
      Controls():ResetScrollFrame(frame.scroll, false)
      Pricing:RefreshView()
    end)
  end)
  frame.knownOnly:SetScript("OnClick", function(self) Pricing:GetSettings().knownOnly = self:GetChecked() == true Pricing:RefreshView() end)
  frame.profitableOnly:SetScript("OnClick", function(self) Pricing:GetSettings().profitableOnly = self:GetChecked() == true Pricing:RefreshView() end)
  frame.favoritesOnly:SetScript("OnClick", function(self) Pricing:GetSettings().favoritesOnly = self:GetChecked() == true Pricing:RefreshView() end)
  frame.altsOnly:SetScript("OnClick", function(self) Pricing:GetSettings().altsOnly = self:GetChecked() == true Pricing:RefreshView() end)
  frame.refreshButton:SetScript("OnClick", function() Pricing:QueueScan(true) end)
  frame.queueButton:SetScript("OnClick", function() NS.UI.QueueWindow:Toggle() end)
  frame.salesButton:SetScript("OnClick", function() NS.UI.SalesWindow:Toggle() end)
  frame.minusQueue:SetScript("OnClick", function() Pricing:AddToQueue(Pricing.selected, -1) Pricing:UpdateInspector() Pricing:Render() end)
  frame.plusQueue:SetScript("OnClick", function() Pricing:AddToQueue(Pricing.selected, 1) Pricing:UpdateInspector() Pricing:Render() end)
  frame.addQueue:SetScript("OnClick", function() Pricing:AddToQueue(Pricing.selected, 1) Pricing:UpdateInspector() Pricing:Render() end)
  frame.clearQueue:SetScript("OnClick", function() NS.Systems.CraftingQueue:Clear() Pricing:UpdateInspector() Pricing:UpdateMetrics() Pricing:UpdateQueueButton() Pricing:Render() if NS.UI.QueueWindow then NS.UI.QueueWindow:Refresh() end end)
  frame.exportButton:SetScript("OnClick", function() Pricing:ExportQueue() end)

  frame:SetScript("OnShow", function()
    local settings = Pricing:GetSettings()
    frame.search:SetText(settings.search or "")
    frame.knownOnly:SetChecked(settings.knownOnly == true)
    frame.profitableOnly:SetChecked(settings.profitableOnly == true)
    frame.favoritesOnly:SetChecked(settings.favoritesOnly == true)
    frame.altsOnly:SetChecked(settings.altsOnly == true)
    frame.professionButton:SetText("Profession: " .. settings.profession)
    frame.expansionButton:SetText("Expansion: " .. settings.expansion)
    frame.lumberButton:SetText("Lumber: " .. settings.lumber)
    Pricing:UpdateHeader()
    Pricing:UpdateQueueButton()
    Pricing:UpdateSortHeaders()
    Pricing:UpdateInspector()
    if Pricing.invalidated or not Pricing.entries or not Pricing.lastRefresh then Pricing:QueueScan(false) else Pricing:Render() end
  end)
  frame:SetScript("OnHide", function()
    Pricing.searchToken = (Pricing.searchToken or 0) + 1
    Pricing.scanRequestToken = (Pricing.scanRequestToken or 0) + 1
    Pricing.selected = nil
    Pricing.view = nil
    Pricing.viewDirty = true
    for _, row in ipairs(frame.rows) do
      row.entry = nil
      row:Hide()
    end
    for _, row in ipairs(frame.materialRows) do
      row.icon:SetTexture(nil)
      row.name:SetText("")
      row.price:SetText("")
      row:Hide()
    end
    frame.inspectIcon:SetTexture(nil)
    frame.exportPopup:Hide()
    if Controls() and Controls().CloseTransientPopups then Controls():CloseTransientPopups() end
    if Controls() and Controls().CollectGarbageIncrementally then Controls():CollectGarbageIncrementally() end
  end)
  frame:SetScript("OnSizeChanged", function() Pricing:Layout() Pricing:Render() end)
  frame.scroll:SetScript("OnSizeChanged", function(self) frame.content:SetWidth(math.max(1, (self:GetWidth() or 1) - 2)) Pricing:LayoutTable() Pricing:Render() end)

  self.panel = frame
  NS.Systems.ItemResolver:Subscribe(self, function(_, loadedItemID, loadedName)
    local changed = false
    local entry = Pricing.entryByItemID and Pricing.entryByItemID[loadedItemID]
    if entry and loadedName ~= entry.name then
      entry.name = loadedName
      entry.searchName = loadedName:lower()
      changed = true
    end
    if Pricing.selected then
      for _, reagent in ipairs(getReagents(Pricing.selected.entry)) do
        if tonumber(reagent.itemID) == loadedItemID then changed = true break end
      end
    end
    if changed and not Pricing.itemRefreshPending then
      Pricing.itemRefreshPending = true
      C_Timer.After(0.1, function()
        Pricing.itemRefreshPending = nil
        Pricing:UpdateInspector()
        Pricing:RefreshView()
        if NS.UI.QueueWindow then NS.UI.QueueWindow:Refresh() end
      end)
    end
  end)
  local professions, expansions = {}, {}
  for _, candidate in ipairs(self:BuildCandidates()) do
    professions[candidate.profession] = true
    expansions[candidate.expansion] = true
  end
  local professionValues = {}
  local expansionValues = {}
  local lumberValues = {}
  for value in pairs(professions) do professionValues[#professionValues + 1] = value end
  for value in pairs(expansions) do expansionValues[#expansionValues + 1] = value end
  for _, value in pairs(NS.Systems.MarketData:GetLumberNames()) do lumberValues[#lumberValues + 1] = value end
  table.sort(professionValues)
  table.sort(expansionValues)
  table.sort(lumberValues)
  self.professionOptions = { "All" }
  self.expansionOptions = { "All" }
  self.lumberOptions = { "All" }
  for _, value in ipairs(professionValues) do self.professionOptions[#self.professionOptions + 1] = value end
  for _, value in ipairs(expansionValues) do self.expansionOptions[#self.expansionOptions + 1] = value end
  for _, value in ipairs(lumberValues) do self.lumberOptions[#self.lumberOptions + 1] = value end
  self:Layout()
  self:UpdateSortHeaders()
  self:UpdateHeader()
  self:UpdateInspector()
  self:UpdateQueueButton()
  if NS.Systems.AuctionScan and NS.Systems.AuctionScan.InitializeScanTracking then NS.Systems.AuctionScan.InitializeScanTracking() end
  return frame
end

function Pricing:Refresh(force)
  if not self.panel then return end
  self:UpdateHeader()
  if force or self.invalidated or not self.entries or not self.lastRefresh then self:QueueScan(force == true) else self:UpdateMetrics() self:Render() end
end

function Pricing:Toggle()
  if NS.UI and NS.UI.CatalogView then NS.UI.CatalogView:Open("pricing") end
end

NS.OnMessage("HOMEDECOR_ALT_PROFESSIONS_UPDATED", function()
  Pricing:InvalidateRecipeData()
  NS.Systems.MarketData:WarmPrices()
  if Pricing.panel and Pricing.panel:IsShown() then Pricing:QueueScan(false) end
end)

return Pricing
