local _, NS = ...

local SalesTracker = {}
NS.Systems.SalesTracker = SalesTracker

local nameIndex
local snapshot = {}
local mailOpen = false
local snapshotReady = false
local updateToken = 0

local function CharacterInfo()
  local name, realm
  if UnitFullName then name, realm = UnitFullName("player") end
  name = type(name) == "string" and name or UnitName("player") or "Unknown"
  realm = type(realm) == "string" and realm ~= "" and realm or GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName and GetRealmName() or "Unknown"
  return name .. "-" .. realm, name
end

local function EnsureTotals(state)
  state.totals = type(state.totals) == "table" and state.totals or {}
  state.totals.characters = type(state.totals.characters) == "table" and state.totals.characters or {}
  if state.totals.migrated then return end
  wipe(state.totals.characters)
  for _, sale in ipairs(state.history or {}) do
    local key = type(sale.characterKey) == "string" and sale.characterKey or "legacy"
    local name = type(sale.characterName) == "string" and sale.characterName or "Legacy / Unknown"
    sale.characterKey = key
    sale.characterName = name
    local total = state.totals.characters[key]
    if not total then
      total = { name = name, gold = 0, count = 0 }
      state.totals.characters[key] = total
    end
    total.gold = total.gold + (tonumber(sale.gold) or 0)
    total.count = total.count + 1
  end
  state.totals.migrated = true
end

local function State()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.decorPricing = profile.decorPricing or {}
  profile.decorPricing.sales = profile.decorPricing.sales or { history = {} }
  profile.decorPricing.sales.history = profile.decorPricing.sales.history or {}
  EnsureTotals(profile.decorPricing.sales)
  return profile.decorPricing.sales
end

local function Accessible(value)
  if value == nil then return false end
  if issecretvalue and issecretvalue(value) then return false end
  if canaccessvalue and not canaccessvalue(value) then return false end
  return true
end

local function BuildNameIndex()
  if nameIndex then return nameIndex end
  nameIndex = {}
  for _, record in ipairs(NS.Systems.Catalog and NS.Systems.Catalog.ordered or {}) do
    local itemID = tonumber(record.itemID)
    local title = record.title
    if itemID and type(title) == "string" then
      title = title:lower():gsub("^%s+", ""):gsub("%s+$", "")
      if title ~= "" then nameIndex[title] = itemID end
    end
  end
  return nameIndex
end

local function DayKey(timestamp)
  return tostring(math.floor((timestamp or time()) / 86400))
end

local function WeekKey(timestamp)
  return tostring(math.floor((timestamp or time()) / 604800))
end

function SalesTracker:Record(itemID, name, count, gold)
  itemID = tonumber(itemID)
  count = math.max(1, tonumber(count) or 1)
  gold = tonumber(gold)
  if not itemID or not gold or gold <= 0 then return false end
  local state = State()
  local timestamp = time()
  local characterKey, characterName = CharacterInfo()
  state.history[#state.history + 1] = {
    itemID = itemID,
    name = name,
    count = count,
    gold = gold,
    timestamp = timestamp,
    dayKey = DayKey(timestamp),
    weekKey = WeekKey(timestamp),
    characterKey = characterKey,
    characterName = characterName,
  }
  local total = state.totals.characters[characterKey]
  if not total then
    total = { name = characterName, gold = 0, count = 0 }
    state.totals.characters[characterKey] = total
  end
  total.gold = total.gold + gold
  total.count = total.count + 1
  self:Prune()
  NS.SendMessage("HOMEDECOR_SALES_UPDATED")
  if NS.UI and NS.UI.SalesWindow then NS.UI.SalesWindow:Refresh() end
  return true
end

function SalesTracker:Prune()
  local state = State()
  if not state then return end
  local cutoff = time() - 7776000
  local write = 0
  for index = 1, #state.history do
    local sale = state.history[index]
    if tonumber(sale.timestamp) and sale.timestamp >= cutoff then
      write = write + 1
      state.history[write] = sale
    end
  end
  for index = write + 1, #state.history do state.history[index] = nil end
end

function SalesTracker:Get(period, scope)
  local state = State()
  local characterKey = CharacterInfo()
  local key = period == "week" and WeekKey() or DayKey()
  local field = period == "week" and "weekKey" or "dayKey"
  local rows = {}
  local revenue = 0
  local count = 0
  for _, sale in ipairs(state and state.history or {}) do
    local inScope = scope == "account" or scope == "alts" and sale.characterKey ~= characterKey or (scope == nil or scope == "current") and sale.characterKey == characterKey
    if sale[field] == key and inScope then
      rows[#rows + 1] = sale
      revenue = revenue + (tonumber(sale.gold) or 0)
      count = count + 1
    end
  end
  table.sort(rows, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
  return rows, revenue, count
end

function SalesTracker:GetLifetime()
  local state = State()
  local characterKey = CharacterInfo()
  local currentGold, currentCount, altGold, altCount = 0, 0, 0, 0
  for key, total in pairs(state and state.totals and state.totals.characters or {}) do
    if key == characterKey then
      currentGold = currentGold + (tonumber(total.gold) or 0)
      currentCount = currentCount + (tonumber(total.count) or 0)
    else
      altGold = altGold + (tonumber(total.gold) or 0)
      altCount = altCount + (tonumber(total.count) or 0)
    end
  end
  return currentGold, currentCount, altGold, altCount, currentGold + altGold, currentCount + altCount
end

function SalesTracker:GetCharacterName()
  local _, name = CharacterInfo()
  return name
end

function SalesTracker:Clear()
  local state = State()
  if state then
    wipe(state.history)
    wipe(state.totals.characters)
  end
  NS.SendMessage("HOMEDECOR_SALES_UPDATED")
end

local function TakeSnapshot()
  local result = {}
  local count = GetInboxNumItems and GetInboxNumItems() or 0
  for index = 1, count do
    local _, _, sender, subject, money = GetInboxHeaderInfo(index)
    local invoiceType, invoiceItem
    if GetInboxInvoiceInfo then invoiceType, invoiceItem = GetInboxInvoiceInfo(index) end
    local invoiceSale = Accessible(invoiceType) and Accessible(invoiceItem) and type(invoiceType) == "string" and invoiceType == "seller" and type(invoiceItem) == "string"
    local subjectSale = Accessible(sender) and Accessible(subject) and type(sender) == "string" and type(subject) == "string" and sender:lower():find("auction", 1, true) and subject:lower():find("success", 1, true)
    if Accessible(money) and type(money) == "number" and money > 0 and (invoiceSale or subjectSale) then
        local itemName = invoiceSale and invoiceItem or (subject:match(":%s*(.+)$") or subject)
        itemName = itemName:gsub("^%s+", ""):gsub("%s+$", "")
        local safeSender = Accessible(sender) and type(sender) == "string" and sender or ""
        local safeSubject = Accessible(subject) and type(subject) == "string" and subject or ""
        local key = safeSender .. "|" .. safeSubject .. "|" .. itemName .. "|" .. tostring(money)
        local value = result[key]
        if value then value.count = value.count + 1 else result[key] = { itemName = itemName, money = money, count = 1 } end
    end
  end
  return result
end

local function DetectSales(previous, current)
  local index = BuildNameIndex()
  for key, value in pairs(previous) do
    local removed = (value.count or 1) - (current[key] and current[key].count or 0)
    if removed > 0 then
      local name = value.itemName
      local normalized = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
      local itemID = index[normalized]
      if itemID then
        for _ = 1, removed do SalesTracker:Record(itemID, name, 1, value.money) end
      end
    end
  end
end

NS.RegisterEvent(SalesTracker, "MAIL_SHOW", function()
  mailOpen = true
  snapshotReady = false
  C_Timer.After(0.5, function()
    if mailOpen then snapshot = TakeSnapshot() snapshotReady = true end
  end)
end)

NS.RegisterEvent(SalesTracker, "MAIL_INBOX_UPDATE", function()
  if not mailOpen or not snapshotReady then return end
  updateToken = updateToken + 1
  local token = updateToken
  C_Timer.After(0.25, function()
    if token ~= updateToken or not mailOpen or not snapshotReady then return end
    local current = TakeSnapshot()
    DetectSales(snapshot, current)
    snapshot = current
  end)
end)

NS.RegisterEvent(SalesTracker, "MAIL_CLOSED", function()
  mailOpen = false
  snapshotReady = false
  updateToken = updateToken + 1
  wipe(snapshot)
end)

NS.Systems.ItemResolver:Subscribe(SalesTracker, function(_, itemID, name)
  if nameIndex and type(name) == "string" then
    name = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if name ~= "" then nameIndex[name] = itemID end
  end
end)

return SalesTracker
