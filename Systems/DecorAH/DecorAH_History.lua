local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local History = NS.DecorAH.History or {}
NS.DecorAH.History = History

local MAX_HISTORY_DAYS = 30
local MAX_SNAPSHOTS_PER_DAY = 4

local function db()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.history = profile.decorAH.history or {}
  return profile.decorAH
end

local function GetDayKey()
  local day = math.floor(time() / 86400)
  return tostring(day)
end

local function CleanOldHistory()
  local g = db()
  if not g or not g.history then return end

  local currentDay = math.floor(time() / 86400)
  local cutoffDay = currentDay - MAX_HISTORY_DAYS

  for dayKey, _ in pairs(g.history) do
    local day = tonumber(dayKey)
    if day and day < cutoffDay then
      g.history[dayKey] = nil
    end
  end
end

function History.RecordSnapshot(itemID, profit, cost, sell, margin)
  if not itemID then return false end
  local g = db()
  if not g then return false end

  local dayKey = GetDayKey()
  g.history[dayKey] = g.history[dayKey] or {}
  g.history[dayKey][itemID] = g.history[dayKey][itemID] or {}

  local snapshots = g.history[dayKey][itemID]

  if #snapshots >= MAX_SNAPSHOTS_PER_DAY then
    table.remove(snapshots, 1)
  end

  table.insert(snapshots, {
    time = time(),
    profit = profit or 0,
    cost = cost or 0,
    sell = sell or 0,
    margin = margin or 0,
  })

  CleanOldHistory()
  return true
end

function History.RecordBulkSnapshot(dataRows)
  if not dataRows or type(dataRows) ~= "table" then return end

  for _, row in ipairs(dataRows) do
    if row.itemID and row.profit then
      History.RecordSnapshot(
        row.itemID,
        row.profit,
        row.cost,
        row.sell,
        row.margin
      )
    end
  end
end

function History.GetHistory(itemID, days)
  if not itemID then return {} end
  local g = db()
  if not g or not g.history then return {} end

  days = days or 7
  local currentDay = math.floor(time() / 86400)
  local startDay = currentDay - days

  local history = {}

  for day = startDay, currentDay do
    local dayKey = tostring(day)
    local dayData = g.history[dayKey]

    if dayData and dayData[itemID] then
      for _, snapshot in ipairs(dayData[itemID]) do
        table.insert(history, snapshot)
      end
    end
  end

  table.sort(history, function(a, b) return a.time < b.time end)

  return history
end

function History.GetAverageProfit(itemID, days)
  local history = History.GetHistory(itemID, days)

  if #history == 0 then
    return nil, nil, nil
  end

  local total = 0
  local min = math.huge
  local max = -math.huge

  for _, snapshot in ipairs(history) do
    local profit = snapshot.profit or 0
    total = total + profit
    if profit < min then min = profit end
    if profit > max then max = profit end
  end

  local avg = total / #history

  return avg, min, max
end

function History.GetProfitTrend(itemID, days)
  local history = History.GetHistory(itemID, days)

  if #history < 2 then
    return nil
  end

  local midpoint = math.floor(#history / 2)

  local firstHalfTotal = 0
  for i = 1, midpoint do
    firstHalfTotal = firstHalfTotal + (history[i].profit or 0)
  end
  local firstHalfAvg = firstHalfTotal / midpoint

  local secondHalfTotal = 0
  for i = midpoint + 1, #history do
    secondHalfTotal = secondHalfTotal + (history[i].profit or 0)
  end
  local secondHalfAvg = secondHalfTotal / (#history - midpoint)

  local diff = secondHalfAvg - firstHalfAvg
  local threshold = firstHalfAvg * 0.1

  if diff > threshold then
    return "increasing"
  elseif diff < -threshold then
    return "decreasing"
  else
    return "stable"
  end
end

function History.ClearHistory()
  local g = db()
  if not g then return end
  g.history = {}
end

function History.GetStorageSize()
  local g = db()
  if not g or not g.history then return 0 end

  local count = 0
  for _, dayData in pairs(g.history) do
    for _, itemSnapshots in pairs(dayData) do
      count = count + #itemSnapshots
    end
  end

  return (count * 50) / 1024
end

return GH
