local ADDON, NS = ...
NS.DecorAH = NS.DecorAH or {}
local Queue = NS.DecorAH.Queue or {}
NS.DecorAH.Queue = Queue

local PriceSource = NS.Systems.PriceSource

local function db()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.queue = profile.decorAH.queue or {}
  return profile.decorAH
end

function Queue.AddToQueue(itemID, name, count, profit, materials)
  if not itemID or not name then return false end

  local g = db()
  if not g then return false end

  for i, entry in ipairs(g.queue) do
    if entry.itemID == itemID then
      entry.count = (entry.count or 1) + (count or 1)
      return true
    end
  end

  table.insert(g.queue, {
    itemID = itemID,
    name = name,
    count = count or 1,
    profit = profit or 0,
    materials = materials or {},
  })

  return true
end

function Queue.RemoveFromQueue(index)
  local g = db()
  if not g or not g.queue then return false end

  if index > 0 and index <= #g.queue then
    table.remove(g.queue, index)
    return true
  end

  return false
end

function Queue.ClearQueue()
  local g = db()
  if not g then return end
  g.queue = {}
end

function Queue.GetQueue()
  local g = db()
  if not g or not g.queue then return {} end
  return g.queue
end

function Queue.UpdateCount(index, newCount)
  local g = db()
  if not g or not g.queue then return false end

  if index > 0 and index <= #g.queue then
    g.queue[index].count = math.max(1, newCount or 1)
    return true
  end

  return false
end

function Queue.GetTotalMaterials()
  local totals = {}
  local g = db()
  if not g or not g.queue then return totals end

  for _, entry in ipairs(g.queue) do
    local count = entry.count or 1
    for _, mat in ipairs(entry.materials or {}) do
      local matID = mat.itemID or mat.id
      local matCount = (mat.count or mat.qty or mat.amount or 1) * count
      totals[matID] = (totals[matID] or 0) + matCount
    end
  end

  return totals
end

function Queue.GetTotalProfit()
  local total = 0
  local g = db()
  if not g or not g.queue then return total end

  for _, entry in ipairs(g.queue) do
    local count = entry.count or 1
    local profit = entry.profit or 0
    total = total + (profit * count)
  end

  return total
end

function Queue.GetTotalCost()
  local totals = Queue.GetTotalMaterials()
  local cost = 0

  for itemID, count in pairs(totals) do
    local price = PriceSource and PriceSource.GetItemPrice(itemID) or 0
    if price and price > 0 then
      cost = cost + (price * count)
    end
  end

  return cost
end

function Queue.GetQueueSize()
  local g = db()
  if not g or not g.queue then return 0 end
  local total = 0
  for _, entry in ipairs(g.queue) do
    total = total + (entry.count or 1)
  end
  return total
end

return Queue
