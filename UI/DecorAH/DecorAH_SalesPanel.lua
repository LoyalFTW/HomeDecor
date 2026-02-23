local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}
local SalesPanel = NS.UI.DecorAH_SalesUI or {}
NS.UI.DecorAH_SalesUI    = SalesPanel
NS.UI.DecorAH_SalesPanel = SalesPanel

local C           = NS.UI.Controls
local Theme       = NS.UI.Theme
local T           = (Theme and Theme.colors) or {}
local PriceSource = NS.Systems and NS.Systems.PriceSource

local Sales = nil
local function EnsureSales()
  if not Sales then Sales = NS.DecorAH and NS.DecorAH.Sales end
end

local salesFrame  = nil
local currentView = "today"
local rowPool     = {}
local activeRows  = {}

local function Backdrop(f, bg, border)
  if C and C.Backdrop then C:Backdrop(f, bg or T.panel, border or T.border) end
end

local function NewFS(parent, template)
  return parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
end

local function FormatGold(copper)
  if PriceSource and PriceSource.FormatGold then
    return PriceSource.FormatGold(copper)
  end
  return GetCoinTextureString(copper or 0)
end

local function CreateSalesPanel(parent)
  local frame = CreateFrame("Frame", "HomeDecorDecorAH_SalesPanel", parent or UIParent, "BackdropTemplate")
  frame:SetSize(700, 500)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  Backdrop(frame, T.bg, T.border)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
  frame:Hide()

  local title = NewFS(frame, "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -15)
  title:SetText(L["DECOR_AH_SALES_TRACKER"])
  title:SetTextColor(unpack(T.accent or { 0.9, 0.72, 0.18, 1 }))
  frame.title = title

  local closeBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
  closeBtn:SetSize(26, 26)
  closeBtn:SetPoint("TOPRIGHT", -10, -10)
  Backdrop(closeBtn, T.panel, T.border)
  if C and C.ApplyHover then C:ApplyHover(closeBtn, T.panel, T.hover) end
  local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
  closeIcon:SetSize(14, 14)
  closeIcon:SetPoint("CENTER")
  closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
  closeIcon:SetVertexColor(1, 0.82, 0.2, 1)
  closeBtn:SetScript("OnClick", function() frame:Hide() end)

  local todayBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
  todayBtn:SetSize(100, 25)
  todayBtn:SetPoint("TOPLEFT", 20, -45)
  Backdrop(todayBtn, T.panel, T.border)
  if C and C.ApplyHover then C:ApplyHover(todayBtn, T.panel, T.hover) end
  local todayText = NewFS(todayBtn, "GameFontNormal")
  todayText:SetPoint("CENTER")
  todayText:SetText(L["DECOR_AH_TODAY"])
  todayText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  todayBtn:SetScript("OnClick", function()
    currentView = "today"
    SalesPanel.Refresh()
  end)
  frame.todayBtn = todayBtn

  local weekBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
  weekBtn:SetSize(100, 25)
  weekBtn:SetPoint("LEFT", todayBtn, "RIGHT", 5, 0)
  Backdrop(weekBtn, T.panel, T.border)
  if C and C.ApplyHover then C:ApplyHover(weekBtn, T.panel, T.hover) end
  local weekText = NewFS(weekBtn, "GameFontNormal")
  weekText:SetPoint("CENTER")
  weekText:SetText(L["DECOR_AH_THIS_WEEK"])
  weekText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  weekBtn:SetScript("OnClick", function()
    currentView = "week"
    SalesPanel.Refresh()
  end)
  frame.weekBtn = weekBtn

  local summaryFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  summaryFrame:SetSize(660, 80)
  summaryFrame:SetPoint("TOP", 0, -80)
  Backdrop(summaryFrame, T.panel, nil)
  frame.summaryFrame = summaryFrame

  local summaryTitle = NewFS(summaryFrame, "GameFontNormal")
  summaryTitle:SetPoint("TOPLEFT", 10, -10)
  summaryTitle:SetText(L["DECOR_AH_SUMMARY_COLON"])
  summaryTitle:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

  local summaryGold = NewFS(summaryFrame, "GameFontNormalLarge")
  summaryGold:SetPoint("TOPLEFT", 10, -30)
  summaryGold:SetTextColor(1, 0.82, 0)
  frame.summaryGold = summaryGold

  local summarySales = NewFS(summaryFrame, "GameFontNormal")
  summarySales:SetPoint("TOPLEFT", 10, -55)
  summarySales:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))
  frame.summarySales = summarySales

  local summaryProfit = NewFS(summaryFrame, "GameFontNormal")
  summaryProfit:SetPoint("TOPRIGHT", -10, -30)
  summaryProfit:SetJustifyH("RIGHT")
  summaryProfit:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  frame.summaryProfit = summaryProfit

  local scrollFrame = CreateFrame("ScrollFrame", "HomeDecorSalesScrollFrame", frame, "ScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT",     20, -170)
  scrollFrame:SetPoint("BOTTOMRIGHT", -40, 40)

  local scrollChild = CreateFrame("Frame", nil, scrollFrame)
  scrollChild:SetSize(640, 1)
  scrollFrame:SetScrollChild(scrollChild)
  frame.scrollChild = scrollChild

  if C and C.SkinScrollFrame then C:SkinScrollFrame(scrollFrame) end

  local refreshBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
  refreshBtn:SetSize(100, 25)
  refreshBtn:SetPoint("BOTTOM", 0, 10)
  Backdrop(refreshBtn, T.panel, T.border)
  if C and C.ApplyHover then C:ApplyHover(refreshBtn, T.panel, T.hover) end
  local refreshText = NewFS(refreshBtn, "GameFontNormal")
  refreshText:SetPoint("CENTER")
  refreshText:SetText(L["DECOR_AH_REFRESH"])
  refreshText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))
  refreshBtn:SetScript("OnClick", function() SalesPanel.Refresh() end)

  local clearBtn = CreateFrame("Button", nil, frame, "BackdropTemplate")
  clearBtn:SetSize(100, 25)
  clearBtn:SetPoint("BOTTOMRIGHT", -20, 10)
  Backdrop(clearBtn, T.panel, T.border)
  if C and C.ApplyHover then C:ApplyHover(clearBtn, T.panel, T.hover) end
  local clearText = NewFS(clearBtn, "GameFontNormal")
  clearText:SetPoint("CENTER")
  clearText:SetText(L["DECOR_AH_CLEAR_DATA"])
  clearText:SetTextColor(unpack(T.danger or { 0.80, 0.28, 0.28, 1 }))
  clearBtn:SetScript("OnClick", function()
    StaticPopup_Show("HOMEDECOR_CLEAR_SALES")
  end)

  return frame
end

local function AcquireRow(parent)
  local row = table.remove(rowPool)
  if not row then
    row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(620, 30)
    Backdrop(row, T.row, nil)

    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(24, 24)
    row.icon:SetPoint("LEFT", 5, 0)

    row.nameBtn = CreateFrame("Button", nil, row)
    row.nameBtn:SetSize(200, 24)
    row.nameBtn:SetPoint("LEFT", row.icon, "RIGHT", 5, 0)

    row.nameText = NewFS(row.nameBtn, "GameFontNormal")
    row.nameText:SetPoint("LEFT")
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.nameText:SetTextColor(unpack(T.text or { 0.92, 0.92, 0.92, 1 }))

    row.qtyText = NewFS(row, "GameFontNormal")
    row.qtyText:SetPoint("LEFT", row.nameBtn, "RIGHT", 10, 0)
    row.qtyText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

    row.goldText = NewFS(row, "GameFontNormal")
    row.goldText:SetPoint("RIGHT", -180, 0)
    row.goldText:SetJustifyH("RIGHT")

    row.avgText = NewFS(row, "GameFontNormalSmall")
    row.avgText:SetPoint("RIGHT", -80, 0)
    row.avgText:SetJustifyH("RIGHT")
    row.avgText:SetTextColor(unpack(T.textMuted or { 0.65, 0.65, 0.68, 1 }))

    row.timeText = NewFS(row, "GameFontNormalSmall")
    row.timeText:SetPoint("RIGHT", -5, 0)
    row.timeText:SetJustifyH("RIGHT")
    row.timeText:SetTextColor(unpack(T.placeholder or { 0.52, 0.52, 0.55, 1 }))
  end

  row:SetParent(parent)
  row:Show()
  table.insert(activeRows, row)
  return row
end

local function ReleaseAllRows()
  for _, row in ipairs(activeRows) do
    row:Hide()
    row:ClearAllPoints()
    row.nameBtn:SetScript("OnEnter", nil)
    row.nameBtn:SetScript("OnLeave", nil)
  end
  for i = 1, #activeRows do
    rowPool[#rowPool + 1] = activeRows[i]
    activeRows[i] = nil
  end
end

local function PopulateRow(row, yOffset, data)
  row:ClearAllPoints()
  row:SetPoint("TOPLEFT", 10, yOffset)

  local tex = C_Item.GetItemIconByID(data.itemID)
  row.icon:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")

  row.nameText:SetText(data.name or L["UNKNOWN"])

  if data.itemLink then
    row.nameBtn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetHyperlink(data.itemLink)
      GameTooltip:Show()
    end)
    row.nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  end

  row.qtyText:SetText(string.format("x%d", data.count or 0))
  row.goldText:SetText(FormatGold(data.gold))

  local avgPrice = data.avgPrice
    or (data.count and data.count > 0 and math.floor((data.gold or 0) / data.count))
    or 0
  row.avgText:SetText(FormatGold(avgPrice) .. " ea")

  if data.timestamp and Sales and Sales.FormatTimeAgo then
    row.timeText:SetText(Sales.FormatTimeAgo(data.timestamp))
    row.timeText:Show()
  else
    row.timeText:Hide()
  end
end

function SalesPanel.Refresh()
  if not salesFrame or not salesFrame:IsVisible() then return end
  EnsureSales()
  if not Sales then return end

  salesFrame.todayBtn:SetEnabled(currentView ~= "today")
  salesFrame.weekBtn:SetEnabled(currentView ~= "week")

  local sales, totalGold, totalSales, summary
  if currentView == "today" then
    sales, totalGold, totalSales = Sales.GetTodaysSales()
    summary = Sales.GetTodaysSummary()
  else
    sales, totalGold, totalSales = Sales.GetWeeklySales()
    summary = Sales.GetWeeklySummary()
  end

  salesFrame.summaryGold:SetText(L["DECOR_AH_TOTAL_REVENUE"] .. FormatGold(totalGold))
  salesFrame.summarySales:SetText(string.format("%d auctions sold", totalSales))

  local totalProfit, profitableItems = 0, 0
  if Sales.CalculateProfit then
    for itemID, data in pairs(summary) do
      local profit, _, hasData = Sales.CalculateProfit(itemID, data.avgPrice)
      if hasData then
        totalProfit     = totalProfit + (profit * data.count)
        profitableItems = profitableItems + 1
      end
    end
  end

  if profitableItems > 0 then
    local color = totalProfit >= 0 and "|cff00ff00" or "|cffff0000"
    salesFrame.summaryProfit:SetText(L["DECOR_AH_EST_PROFIT"] .. color .. FormatGold(totalProfit) .. "|r")
  else
    salesFrame.summaryProfit:SetText(L["DECOR_AH_EST_PROFIT_NA"])
  end

  ReleaseAllRows()
  local scrollChild = salesFrame.scrollChild
  local yOffset = -10

  for _, sale in ipairs(sales) do
    local row = AcquireRow(scrollChild)
    PopulateRow(row, yOffset, {
      itemID    = sale.itemID,
      name      = sale.name,
      itemLink  = sale.itemLink,
      count     = sale.count or 1,
      gold      = sale.gold  or 0,
      avgPrice  = sale.pricePerItem
        or (sale.count and sale.count > 0 and math.floor((sale.gold or 0) / sale.count))
        or 0,
      timestamp = sale.timestamp,
    })
    yOffset = yOffset - 35
  end

  salesFrame.scrollChild:SetHeight(math.max(1, #activeRows * 35 + 20))
end

SalesPanel.RefreshSalesPanel = SalesPanel.Refresh

function SalesPanel.Show()
  EnsureSales()
  if not Sales then
    return
  end
  if not salesFrame then salesFrame = CreateSalesPanel(UIParent) end
  salesFrame:Show()
  SalesPanel.Refresh()
end

function SalesPanel.Hide()
  if salesFrame then salesFrame:Hide() end
end

function SalesPanel.Toggle()
  EnsureSales()
  if not Sales then
    return
  end
  if not salesFrame then salesFrame = CreateSalesPanel(UIParent) end
  if salesFrame:IsShown() then
    salesFrame:Hide()
  else
    salesFrame:Show()
    SalesPanel.Refresh()
  end
end

SalesPanel.ShowSalesPanel   = SalesPanel.Show
SalesPanel.HideSalesPanel   = SalesPanel.Hide
SalesPanel.ToggleSalesPanel = SalesPanel.Toggle

function SalesPanel.Initialize()
  if StaticPopupDialogs["HOMEDECOR_CLEAR_SALES"] then return end
  StaticPopupDialogs["HOMEDECOR_CLEAR_SALES"] = {
    text          = "Clear all sales tracking data?\n\nThis cannot be undone.",
    button1       = "Clear",
    button2       = "Cancel",
    OnAccept      = function()
      EnsureSales()
      if Sales and Sales.ClearAllSales then Sales.ClearAllSales() end
      SalesPanel.Refresh()
    end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
  }
end

return SalesPanel
