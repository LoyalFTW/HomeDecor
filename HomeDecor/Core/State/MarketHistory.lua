local _, NS = ...

local MarketHistory = {}
NS.Systems.MarketHistory = MarketHistory

local RETENTION_DAYS = 30
local STRIDE = 5

local function State()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.decorPricing = profile.decorPricing or {}
  profile.decorPricing.marketHistory = profile.decorPricing.marketHistory or {}
  return profile.decorPricing.marketHistory
end

local function Day(timestamp)
  return math.floor((timestamp or time()) / 86400)
end

local function Normalize(history, cutoff)
  if type(history) ~= "table" then return {} end
  if type(history[1]) ~= "table" and #history % STRIDE == 0 then
    local valid = true
    for index = 1, #history, STRIDE do
      local day = tonumber(history[index])
      if not day or day < cutoff then valid = false break end
    end
    if valid then return history end
  end
  local flat = {}
  if type(history[1]) == "table" then
    for index = 1, #history do
      local snapshot = history[index]
      local day = type(snapshot) == "table" and tonumber(snapshot[1])
      if day and day >= cutoff then
        flat[#flat + 1] = day
        flat[#flat + 1] = snapshot[2] ~= nil and snapshot[2] or false
        flat[#flat + 1] = snapshot[3] ~= nil and snapshot[3] or false
        flat[#flat + 1] = snapshot[4] ~= nil and snapshot[4] or false
        flat[#flat + 1] = snapshot[5] ~= nil and snapshot[5] or false
      end
    end
  else
    for index = 1, #history, STRIDE do
      local day = tonumber(history[index])
      if day and day >= cutoff then
        for offset = 0, STRIDE - 1 do
          local value = history[index + offset]
          flat[#flat + 1] = value ~= nil and value or false
        end
      end
    end
  end
  return flat
end

function MarketHistory:Compact()
  local state = State()
  if not state then return end
  local cutoff = Day() - RETENTION_DAYS
  for key, history in pairs(state) do
    local flat = Normalize(history, cutoff)
    state[key] = #flat > 0 and flat or nil
  end
end

function MarketHistory:Record(entries)
  local state = State()
  if not state then return end
  local today = Day()
  local cutoff = today - RETENTION_DAYS
  for _, entry in ipairs(entries or {}) do
    if entry.itemID and entry.profit ~= nil then
      local key = tostring(entry.itemID)
      local history = Normalize(state[key], cutoff)
      local start = #history - STRIDE + 1
      if start >= 1 and history[start] == today then
        history[start + 1] = entry.cost ~= nil and entry.cost or false
        history[start + 2] = entry.sell ~= nil and entry.sell or false
        history[start + 3] = entry.profit ~= nil and entry.profit or false
        history[start + 4] = entry.margin ~= nil and entry.margin or false
      else
        history[#history + 1] = today
        history[#history + 1] = entry.cost ~= nil and entry.cost or false
        history[#history + 1] = entry.sell ~= nil and entry.sell or false
        history[#history + 1] = entry.profit ~= nil and entry.profit or false
        history[#history + 1] = entry.margin ~= nil and entry.margin or false
      end
      state[key] = history
    end
  end
end

function MarketHistory:GetStats(itemID, days)
  local state = State()
  local history = state and state[tostring(itemID)] or nil
  if not history or #history == 0 then return nil end
  local cutoff = Day() - (tonumber(days) or 7)
  local count = 0
  local total = 0
  local first
  local last
  local low
  local high
  history = Normalize(history, Day() - RETENTION_DAYS)
  state[tostring(itemID)] = history
  for index = 1, #history, STRIDE do
    if history[index] >= cutoff and type(history[index + 3]) == "number" then
      local profit = history[index + 3]
      count = count + 1
      total = total + profit
      first = first or profit
      last = profit
      low = not low and profit or math.min(low, profit)
      high = not high and profit or math.max(high, profit)
    end
  end
  if count == 0 then return nil end
  local trend = first and first ~= 0 and last and ((last - first) / math.abs(first) * 100) or 0
  return { average = total / count, trend = trend, low = low, high = high, samples = count }
end

function MarketHistory:Clear()
  local state = State()
  if state then wipe(state) end
end

return MarketHistory
