local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local Sales = NS.DecorAH.Sales or {}
NS.DecorAH.Sales = Sales

local PriceSource = NS.Systems.PriceSource

local recentSales = {}

local processedMails = {}

local itemNameToIDCache = nil

local function BuildNameCache()
  if itemNameToIDCache then return end
  itemNameToIDCache = {}
  local data = NS.Data and NS.Data.Professions
  if type(data) == "table" then
    for _, expansions in pairs(data) do
      for _, list in pairs(expansions) do
        if type(list) == "table" then
          for _, entry in ipairs(list) do
            if entry.title and entry.source and entry.source.itemID then
              itemNameToIDCache[entry.title:lower()] = entry.source.itemID
            end
          end
        end
      end
    end
  end
  local vendors = NS.Data and NS.Data.Vendors
  if type(vendors) == "table" then
    for _, exp in pairs(vendors) do
      for _, zone in pairs(exp or {}) do
        for _, vendor in ipairs(zone or {}) do
          for _, it in ipairs(vendor.items or {}) do
            if it.name and it.itemID then
              itemNameToIDCache[it.name:lower()] = it.itemID
            end
          end
        end
      end
    end
  end
end

local function LookupItemIDByName(name)
  if not name then return nil end
  BuildNameCache()
  return itemNameToIDCache and itemNameToIDCache[name:lower()] or nil
end

local function GetMailHash(subject, money, sender)
  return string.format("%s|%d|%s", subject or "", money or 0, sender or "")
end

local function IsMailProcessed(mailHash)
  return processedMails[mailHash] ~= nil
end

local function MarkMailProcessed(mailHash)
  processedMails[mailHash] = time()

  local cutoff = time() - 3600
  for hash, timestamp in pairs(processedMails) do
    if timestamp < cutoff then
      processedMails[hash] = nil
    end
  end
end

local function ClearProcessedMail()
  processedMails = {}
end

local function IsHousingItem(itemID)
  if not itemID or itemID == 0 then return false end

  local GlobalIndex = NS.Systems.GlobalIndex
  if GlobalIndex then
    if GlobalIndex.Ensure then GlobalIndex:Ensure() end
    if GlobalIndex.byItemID and GlobalIndex.byItemID[itemID] then
      return true
    end
  end

  local _, _, _, _, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(itemID)
  if classID == 15 and subclassID == 5 then return true end

  return false
end

local function db()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.sales = profile.decorAH.sales or {}
  return profile.decorAH
end

local function GetDayKey(timestamp)
  timestamp = timestamp or time()
  local day = math.floor(timestamp / 86400)
  return tostring(day)
end

local function GetWeekKey(timestamp)
  timestamp = timestamp or time()
  local week = math.floor(timestamp / (86400 * 7))
  return tostring(week)
end

local function CleanOldSales()
  local g = db()
  if not g or not g.sales or not g.sales.history then return end

  local cutoffTime = time() - (90 * 86400)
  local history    = g.sales.history
  local write      = 0

  for i = 1, #history do
    local sale = history[i]
    if sale.timestamp and sale.timestamp >= cutoffTime then
      write = write + 1
      history[write] = sale
    end
  end

  for i = write + 1, #history do
    history[i] = nil
  end

  collectgarbage("collect")
end

function Sales.RecordSale(itemID, itemLink, count, gold, buyerName, itemName)
  if not count or not gold then
    return false
  end

  local g = db()
  if not g then
    return false
  end

  g.sales.history = g.sales.history or {}

  itemName = itemName or (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemID)) or "Unknown Item"

  local timestamp = time()
  local dayKey = GetDayKey(timestamp)
  local weekKey = GetWeekKey(timestamp)

  local sale = {
    itemID = itemID,
    itemLink = itemLink,
    name = itemName,
    count = count,
    gold = gold,
    pricePerItem = math.floor(gold / count),
    timestamp = timestamp,
    dayKey = dayKey,
    weekKey = weekKey,
    buyer = buyerName,
  }

  table.insert(g.sales.history, sale)

  g.sales.dailyTotals = g.sales.dailyTotals or {}
  g.sales.dailyTotals[dayKey] = g.sales.dailyTotals[dayKey] or {gold = 0, sales = 0}
  g.sales.dailyTotals[dayKey].gold  = g.sales.dailyTotals[dayKey].gold  + gold
  g.sales.dailyTotals[dayKey].sales = g.sales.dailyTotals[dayKey].sales + 1

  g.sales.weeklyTotals = g.sales.weeklyTotals or {}
  g.sales.weeklyTotals[weekKey] = g.sales.weeklyTotals[weekKey] or {gold = 0, sales = 0}
  g.sales.weeklyTotals[weekKey].gold  = g.sales.weeklyTotals[weekKey].gold  + gold
  g.sales.weeklyTotals[weekKey].sales = g.sales.weeklyTotals[weekKey].sales + 1

  return true
end

function Sales.GetTodaysSales()
  local g = db()
  if not g or not g.sales or not g.sales.history then return {}, 0, 0 end

  local todayKey = GetDayKey()
  local sales = {}
  local totalGold = 0
  local totalSales = 0

  for _, sale in ipairs(g.sales.history) do
    if sale.dayKey == todayKey then
      table.insert(sales, sale)
      totalGold = totalGold + (sale.gold or 0)
      totalSales = totalSales + 1
    end
  end

  table.sort(sales, function(a, b) return a.timestamp > b.timestamp end)

  return sales, totalGold, totalSales
end

function Sales.GetWeeklySales()
  local g = db()
  if not g or not g.sales or not g.sales.history then return {}, 0, 0 end

  local weekKey = GetWeekKey()
  local sales = {}
  local totalGold = 0
  local totalSales = 0

  for _, sale in ipairs(g.sales.history) do
    if sale.weekKey == weekKey then
      table.insert(sales, sale)
      totalGold = totalGold + (sale.gold or 0)
      totalSales = totalSales + 1
    end
  end

  table.sort(sales, function(a, b) return a.timestamp > b.timestamp end)

  return sales, totalGold, totalSales
end

function Sales.GetTodaysSummary()
  local sales, _, _ = Sales.GetTodaysSales()
  return Sales.SummarizeByItem(sales)
end

function Sales.GetWeeklySummary()
  local sales, _, _ = Sales.GetWeeklySales()
  return Sales.SummarizeByItem(sales)
end

function Sales.SummarizeByItem(sales)
  local summary = {}

  for _, sale in ipairs(sales) do
    local itemID = sale.itemID

    if not itemID then
    else
      if not summary[itemID] then
        summary[itemID] = {
          itemID = itemID,
          name = sale.name,
          itemLink = sale.itemLink,
          count = 0,
          gold = 0,
          sales = 0,
        }
      end

      summary[itemID].count = summary[itemID].count + (sale.count or 0)
      summary[itemID].gold = summary[itemID].gold + (sale.gold or 0)
      summary[itemID].sales = summary[itemID].sales + 1
    end
  end

  for itemID, data in pairs(summary) do
    if data.count > 0 then
      data.avgPrice = math.floor(data.gold / data.count)
    else
      data.avgPrice = 0
    end
  end

  return summary
end

function Sales.GetBestSellersToday(limit)
  local summary = Sales.GetTodaysSummary()
  return Sales.SortSummary(summary, "gold", limit)
end

function Sales.GetBestSellersWeek(limit)
  local summary = Sales.GetWeeklySummary()
  return Sales.SortSummary(summary, "gold", limit)
end

function Sales.SortSummary(summary, sortBy, limit)
  sortBy = sortBy or "gold"
  limit = limit or 10

  local sorted = {}
  for _, data in pairs(summary) do
    table.insert(sorted, data)
  end

  table.sort(sorted, function(a, b)
    return (a[sortBy] or 0) > (b[sortBy] or 0)
  end)

  if #sorted > limit then
    local limited = {}
    for i = 1, limit do
      table.insert(limited, sorted[i])
    end
    return limited
  end

  return sorted
end

function Sales.CalculateProfit(itemID, sellPrice)
  if not PriceSource then return 0, 0, false end

  local craftCost = PriceSource.GetCraftCost and PriceSource.GetCraftCost(itemID)

  if not craftCost or craftCost <= 0 then
    return 0, 0, false
  end

  local profit = sellPrice - craftCost
  return profit, craftCost, true
end

function Sales.ScanMailForSales()
  local numInbox = GetInboxNumItems()
  if not numInbox or numInbox == 0 then
    return
  end

  local auctionMail = 0
  for i = 1, numInbox do
    local packageIcon, stationeryIcon, sender, subject, money, CODAmount, daysLeft, hasItem,
          wasRead, wasReturned, textCreated, canReply, isGM = GetInboxHeaderInfo(i)

    if sender == "Auction House" and subject and subject:find("Auction successful") and money and money > 0 then
      local itemName = subject:match("Auction successful:%s*(.+)")
      auctionMail = auctionMail + 1
    end
  end

end

local mailFrame = nil
local mailSnapshot = {}

local TakeMailSnapshot
local DetectAndRecordCollections
local InitMailTracking

TakeMailSnapshot = function()
  local snapshot = {}
  local numItems = GetInboxNumItems()

  for i = 1, numItems do
    local _, _, sender, subject, money, _, _, hasItem =
      GetInboxHeaderInfo(i)

    if sender and subject then
      local isAuctionMail = sender:find("Auction")

      if isAuctionMail and subject:lower():find("success") and money and money > 0 then
        local uniqueKey = sender .. "|" .. subject .. "|" .. money
        if not snapshot[uniqueKey] then
          snapshot[uniqueKey] = {
            money   = money,
            subject = subject,
            sender  = sender,
            count   = 1,
          }
        else
          snapshot[uniqueKey].count = snapshot[uniqueKey].count + 1
        end
      end
    end
  end

  return snapshot
end

DetectAndRecordCollections = function(oldSnapshot, newSnapshot)
  local recordedCount = 0

  for uniqueKey, data in pairs(oldSnapshot) do
    local oldCount = data.count or 1
    local newCount = (newSnapshot[uniqueKey] and newSnapshot[uniqueKey].count) or 0
    local collectedCount = oldCount - newCount

    if collectedCount > 0 then
      local itemName = data.subject:match(":%s*(.+)$") or data.subject

      local itemID = LookupItemIDByName(itemName)

      for _ = 1, collectedCount do
        local success = Sales.RecordSale(itemID, nil, 1, data.money, nil, itemName)
        if success then
          recordedCount = recordedCount + 1
          if NS.UI.DecorAH_SalesUI and NS.UI.DecorAH_SalesUI.RefreshSalesPanel then
            NS.UI.DecorAH_SalesUI.RefreshSalesPanel()
          end
        end
      end
    end
  end
end

InitMailTracking = function()
  if mailFrame then return end
  mailFrame = CreateFrame("Frame")
  mailFrame:RegisterEvent("MAIL_SHOW")
  mailFrame:RegisterEvent("MAIL_INBOX_UPDATE")
  mailFrame:RegisterEvent("MAIL_CLOSED")

  local isMailOpen = false
  local snapshotReady = false

  local pendingUpdate = false

  mailFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "MAIL_SHOW" then
      isMailOpen = true
      snapshotReady = false
      pendingUpdate = false
      C_Timer.After(0.5, function()
        if isMailOpen then
          mailSnapshot = TakeMailSnapshot()
          snapshotReady = true
        end
      end)

    elseif event == "MAIL_INBOX_UPDATE" then
      if not isMailOpen or not snapshotReady then return end
      if not pendingUpdate then
        pendingUpdate = true
        C_Timer.After(0.3, function()
          pendingUpdate = false
          if not isMailOpen or not snapshotReady then return end
          local newSnapshot = TakeMailSnapshot()
          if mailSnapshot then
            DetectAndRecordCollections(mailSnapshot, newSnapshot)
          end
          mailSnapshot = newSnapshot
        end)
      end

    elseif event == "MAIL_CLOSED" then
      isMailOpen = false
      snapshotReady = false
      pendingUpdate = false
      mailSnapshot = {}
    end
  end)
end
function Sales.Initialize()

  itemNameToIDCache = nil

  InitMailTracking()

  CleanOldSales()

  SLASH_HDSALES1 = "/hdsales"
  SlashCmdList["HDSALES"] = function(msg)
    msg = (msg or ""):lower():trim()
    if msg == "status" then
      local snap = 0; for _ in pairs(mailSnapshot) do snap = snap + 1 end
      local g = db()
    else
    end
  end

  SLASH_DAH1 = "/dah"
  SlashCmdList["DAH"] = function(msg)
    msg = (msg or ""):lower():trim()

    if msg == "scan" then
      Sales.ScanMailForSales()
    elseif msg == "clear" then
      Sales.ClearAllSales()
    elseif msg == "show" then
      if NS.UI.DecorAH_SalesUI and NS.UI.DecorAH_SalesUI.ShowSalesPanel then
        NS.UI.DecorAH_SalesUI.ShowSalesPanel()
      end
    elseif msg == "debug" or msg == "db" then
      local g = db()
      if not g then
        return
      end
      if not g.sales or not g.sales.history then
        return
      end
      if #g.sales.history > 0 then
        for i = math.max(1, #g.sales.history - 4), #g.sales.history do
          local sale = g.sales.history[i]
        end
      end
    else
    end
  end

end

function Sales.ClearAllSales()
  local g = db()
  if not g then return end
  g.sales = {
    history = {},
    dailyTotals = {},
    weeklyTotals = {},
  }
end

function Sales.GetStorageSize()
  local g = db()
  if not g or not g.sales or not g.sales.history then return 0 end

  local count = #g.sales.history
  return (count * 100) / 1024
end

function Sales.FormatTimeAgo(timestamp)
  local diff = time() - timestamp

  if diff < 60 then
    return "Just now"
  elseif diff < 3600 then
    return string.format("%dm ago", math.floor(diff / 60))
  elseif diff < 86400 then
    return string.format("%dh ago", math.floor(diff / 3600))
  else
    return string.format("%dd ago", math.floor(diff / 86400))
  end
end

return Sales
