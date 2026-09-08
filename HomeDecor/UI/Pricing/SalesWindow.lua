local _, NS = ...

NS.UI = NS.UI or {}
local SalesWindow = { period = "today", scope = "current" }
NS.UI.SalesWindow = SalesWindow

local ROW_HEIGHT = 42
local ROW_COUNT = 8

local function Controls()
  return NS.UI.Controls
end

local function Font(parent, template, role)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  Controls():TextColor(text, role or "text")
  return text
end

local function Button(parent, label, width, height)
  return Controls():CreateButton(parent, label, width, height)
end

local function Backdrop(frame, background, border)
  Controls():Backdrop(frame, background, border)
end

local function FormatMoney(value)
  local source = NS.Systems.PriceSource
  return source and source.FormatGold and source.FormatGold(value) or tostring(value or 0)
end

local function FormatTime(timestamp)
  local elapsed = math.max(0, time() - (tonumber(timestamp) or time()))
  if elapsed < 60 then return "Just now" end
  if elapsed < 3600 then return tostring(math.floor(elapsed / 60)) .. "m ago" end
  if elapsed < 86400 then return tostring(math.floor(elapsed / 3600)) .. "h ago" end
  return tostring(math.floor(elapsed / 86400)) .. "d ago"
end

function SalesWindow:SetPeriod(period)
  self.period = period == "week" and "week" or "today"
  local frame = self.frame
  if frame then
    Controls():SetButtonSelected(frame.today, self.period == "today")
    Controls():SetButtonSelected(frame.week, self.period == "week")
    Controls():ResetScrollFrame(frame.scroll, false)
  end
  self:Refresh()
end

function SalesWindow:SetScope(scope)
  self.scope = scope == "alts" and "alts" or scope == "account" and "account" or "current"
  local frame = self.frame
  if frame then
    Controls():SetButtonSelected(frame.current, self.scope == "current")
    Controls():SetButtonSelected(frame.alts, self.scope == "alts")
    Controls():SetButtonSelected(frame.account, self.scope == "account")
    Controls():ResetScrollFrame(frame.scroll, false)
  end
  self:Refresh()
end

function SalesWindow:Render()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local rows = self.rows or {}
  frame.content:SetHeight(math.max(1, #rows * ROW_HEIGHT))
  local maximum = math.max(0, frame.content:GetHeight() - frame.scroll:GetHeight())
  if frame.scroll:GetVerticalScroll() > maximum then Controls():SetScrollOffset(frame.scroll, maximum, false) end
  local first = math.max(0, math.floor((frame.scroll:GetVerticalScroll() or 0) / ROW_HEIGHT))
  for rowIndex, row in ipairs(frame.rows) do
    local absolute = first + rowIndex
    local sale = rows[absolute]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetPoint("RIGHT", -2, 0)
    row:SetShown(sale ~= nil)
    if sale then
      row.icon:SetTexture(NS.Systems.ItemResolver:GetIcon(sale.itemID))
      row.name:SetText((sale.name or ("Item " .. tostring(sale.itemID))) .. ((sale.count or 1) > 1 and (" x" .. tostring(sale.count)) or "") .. "  -  " .. (sale.characterName or "Legacy / Unknown"))
      row.time:SetText(FormatTime(sale.timestamp))
      row.gold:SetText(FormatMoney(sale.gold))
    end
  end
  frame.empty:SetShown(#rows == 0)
end

function SalesWindow:Refresh()
  local frame = self.frame
  if not frame or not frame:IsShown() then return end
  local rows, revenue, count = NS.Systems.SalesTracker:Get(self.period, self.scope)
  self.rows = rows
  local currentGold, currentCount, altGold, altCount, accountGold, accountCount = NS.Systems.SalesTracker:GetLifetime()
  frame.revenue:SetText(FormatMoney(revenue))
  frame.sales:SetText(tostring(count) .. (count == 1 and " auction sold" or " auctions sold"))
  frame.currentEarned:SetText(FormatMoney(currentGold) .. "  (" .. tostring(currentCount) .. ")")
  frame.altsEarned:SetText(FormatMoney(altGold) .. "  (" .. tostring(altCount) .. ")")
  frame.accountEarned:SetText(FormatMoney(accountGold) .. "  (" .. tostring(accountCount) .. ")")
  self:Render()
end

function SalesWindow:Create()
  if self.frame then return self.frame end
  local colors = Controls().colors
  local frame = CreateFrame("Frame", "HomeDecorSalesWindow", UIParent, "BackdropTemplate")
  frame:SetSize(700, 510)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(120)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  Backdrop(frame, colors.background, colors.border)
  NS.Systems.Layout:Restore(frame, "salesTracker")
  Controls():MakeMovable(frame, frame, "salesTracker")

  local title = Font(frame, "GameFontNormalLarge", "accent")
  title:SetPoint("TOP", 0, -14)
  title:SetText("Sales Tracker")
  local close = Controls():CreateCloseButton(frame, function() frame:Hide() end)
  close:SetPoint("TOPRIGHT", -10, -9)
  frame.today = Button(frame, "Today", 100, 26)
  frame.today:SetPoint("TOPLEFT", 20, -48)
  frame.week = Button(frame, "This Week", 100, 26)
  frame.week:SetPoint("LEFT", frame.today, "RIGHT", 7, 0)
  frame.today:SetScript("OnClick", function() SalesWindow:SetPeriod("today") end)
  frame.week:SetScript("OnClick", function() SalesWindow:SetPeriod("week") end)
  frame.current = Button(frame, "Character", 100, 26)
  frame.current:SetPoint("TOPRIGHT", -234, -48)
  frame.alts = Button(frame, "Alts", 100, 26)
  frame.alts:SetPoint("LEFT", frame.current, "RIGHT", 7, 0)
  frame.account = Button(frame, "Account", 100, 26)
  frame.account:SetPoint("LEFT", frame.alts, "RIGHT", 7, 0)
  frame.current:SetScript("OnClick", function() SalesWindow:SetScope("current") end)
  frame.alts:SetScript("OnClick", function() SalesWindow:SetScope("alts") end)
  frame.account:SetScript("OnClick", function() SalesWindow:SetScope("account") end)

  local summary = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  summary:SetPoint("TOPLEFT", 20, -84)
  summary:SetPoint("TOPRIGHT", -20, -84)
  summary:SetHeight(116)
  Backdrop(summary, colors.header, colors.border)
  local summaryTitle = Font(summary, "GameFontNormalSmall", "muted")
  summaryTitle:SetPoint("TOPLEFT", 10, -9)
  summaryTitle:SetText("Summary")
  local revenueLabel = Font(summary, "GameFontNormal", "accent")
  revenueLabel:SetPoint("TOPLEFT", 10, -29)
  revenueLabel:SetText("Total Revenue:")
  frame.revenue = Font(summary, "GameFontNormal", "accent")
  frame.revenue:SetPoint("LEFT", revenueLabel, "RIGHT", 6, 0)
  frame.sales = Font(summary, "GameFontNormalSmall", "muted")
  frame.sales:SetPoint("TOPLEFT", 10, -54)
  local currentLabel = Font(summary, "GameFontNormalSmall", "muted")
  currentLabel:SetPoint("TOPLEFT", 250, -29)
  currentLabel:SetText("Character Total:")
  frame.currentEarned = Font(summary, "GameFontNormalSmall", "success")
  frame.currentEarned:SetPoint("TOPRIGHT", -10, -29)
  frame.currentEarned:SetWidth(190)
  frame.currentEarned:SetJustifyH("RIGHT")
  local altsLabel = Font(summary, "GameFontNormalSmall", "muted")
  altsLabel:SetPoint("TOPLEFT", 250, -54)
  altsLabel:SetText("Other Characters:")
  frame.altsEarned = Font(summary, "GameFontNormalSmall", "accent")
  frame.altsEarned:SetPoint("TOPRIGHT", -10, -54)
  frame.altsEarned:SetWidth(190)
  frame.altsEarned:SetJustifyH("RIGHT")
  local accountLabel = Font(summary, "GameFontNormalSmall", "muted")
  accountLabel:SetPoint("TOPLEFT", 250, -79)
  accountLabel:SetText("Account Total:")
  frame.accountEarned = Font(summary, "GameFontNormalSmall", "text")
  frame.accountEarned:SetPoint("TOPRIGHT", -10, -79)
  frame.accountEarned:SetWidth(190)
  frame.accountEarned:SetJustifyH("RIGHT")

  local columns = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  columns:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, -10)
  columns:SetPoint("TOPRIGHT", summary, "BOTTOMRIGHT", 0, -10)
  columns:SetHeight(26)
  Backdrop(columns, colors.panel, colors.border)
  local names = { { "ITEM / CHARACTER", 10, "LEFT", 370 }, { "WHEN", 410, "LEFT", 100 }, { "REVENUE", -12, "RIGHT", 110 } }
  for _, value in ipairs(names) do
    local label = Font(columns, "GameFontNormalSmall", "muted")
    label:SetPoint(value[3], columns, value[3], value[2], 0)
    label:SetWidth(value[4])
    label:SetJustifyH(value[3])
    label:SetText(value[1])
  end
  frame.scroll = Controls():CreateScrollFrame(frame)
  frame.scroll:SetPoint("TOPLEFT", columns, "BOTTOMLEFT", 0, -2)
  frame.scroll:SetPoint("BOTTOMRIGHT", -40, 56)
  frame.content = CreateFrame("Frame", nil, frame.scroll)
  frame.content:SetSize(638, 1)
  Controls():ConfigureScrollFrame(frame.scroll, frame.content, { step = ROW_HEIGHT, onScroll = function() SalesWindow:Render() end })
  frame.rows = {}
  for index = 1, ROW_COUNT do
    local row = CreateFrame("Frame", nil, frame.content, "BackdropTemplate")
    row:SetHeight(ROW_HEIGHT - 2)
    Backdrop(row, colors.row, colors.border)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(28, 28)
    row.icon:SetPoint("LEFT", 7, 0)
    row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    row.name = Font(row, "GameFontNormal", "text")
    row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
    row.name:SetWidth(350)
    row.name:SetJustifyH("LEFT")
    row.name:SetWordWrap(false)
    row.time = Font(row, "GameFontNormalSmall", "muted")
    row.time:SetPoint("LEFT", 410, 0)
    row.time:SetWidth(100)
    row.time:SetJustifyH("LEFT")
    row.gold = Font(row, "GameFontNormal", "accent")
    row.gold:SetPoint("RIGHT", -10, 0)
    row.gold:SetWidth(112)
    row.gold:SetJustifyH("RIGHT")
    Controls():ForwardScrollWheel(row, frame.scroll)
    frame.rows[index] = row
  end
  frame.empty = Font(frame, "GameFontHighlight", "muted")
  frame.empty:SetPoint("CENTER", frame.scroll, "CENTER")
  frame.empty:SetText("No collected auction sales were recorded for this period.")
  local refresh = Button(frame, "Refresh", 100, 28)
  refresh:SetPoint("BOTTOM", 0, 14)
  refresh:SetScript("OnClick", function() SalesWindow:Refresh() end)
  local clear = Button(frame, "Clear Data", 110, 28)
  clear:SetPoint("BOTTOMRIGHT", -20, 14)
  clear:SetScript("OnClick", function() NS.Systems.SalesTracker:Clear() SalesWindow:Refresh() end)
  local hint = Font(frame, "GameFontNormalSmall", "muted")
  hint:SetPoint("BOTTOMLEFT", 20, 21)
  hint:SetText("Sales are recorded when Auction House sale mail is collected.")
  frame:SetScript("OnShow", function() Controls():SetButtonSelected(NS.UI.DecorPricing and NS.UI.DecorPricing.panel and NS.UI.DecorPricing.panel.salesButton, true) SalesWindow:SetPeriod(SalesWindow.period) SalesWindow:SetScope(SalesWindow.scope) end)
  frame:SetScript("OnHide", function() Controls():SetButtonSelected(NS.UI.DecorPricing and NS.UI.DecorPricing.panel and NS.UI.DecorPricing.panel.salesButton, false) end)
  self.frame = frame
  frame:Hide()
  return frame
end

function SalesWindow:Toggle()
  local frame = self:Create()
  Controls():ToggleFrame(frame, function() self:Refresh() end)
end

NS.Systems.ItemResolver:Subscribe(SalesWindow, function()
  if SalesWindow.frame and SalesWindow.frame:IsShown() then SalesWindow:Refresh() end
end)

return SalesWindow
