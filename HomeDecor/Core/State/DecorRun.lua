local _, NS = ...

local DecorRun = {}
NS.Systems.DecorRun = DecorRun

local function Inventory(itemID)
  local bags, housing = 0, 0
  if itemID and C_Item and C_Item.GetItemCount then
    local ok, count = pcall(C_Item.GetItemCount, itemID, true, false, true, true)
    if ok then bags = tonumber(count) or 0 end
  end
  local api = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem
  if itemID and api then
    local ok, info = pcall(api, itemID, true)
    if not ok or type(info) ~= "table" then ok, info = pcall(api, itemID) end
    if ok and type(info) == "table" then
      housing = (tonumber(info.totalNumStored or info.quantity) or 0) + (tonumber(info.remainingRedeemable) or 0) + (tonumber(info.totalNumPlaced or info.numPlaced) or 0)
    end
  end
  return bags, housing
end

local function Location(record)
  local map, x, y = tonumber(record.mapID), tonumber(record.mapX), tonumber(record.mapY)
  if map and x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then return map, x, y end
end

local function Restrictions(record)
  local reasons, unknown = {}, false
  local faction = UnitFactionGroup and UnitFactionGroup("player")
  if faction and (record.faction == "Alliance" or record.faction == "Horde") and record.faction ~= faction then reasons[#reasons + 1] = record.faction .. " only" end
  local class = NS.Systems.Housing and NS.Systems.Housing:GetClassRestriction(record)
  if class then
    local name, token
    if UnitClass then name, token = UnitClass("player") end
    local required = tostring(class):lower():gsub("%s", "")
    local classes = { warrior = true, paladin = true, hunter = true, rogue = true, priest = true, deathknight = true, shaman = true, mage = true, warlock = true, monk = true, druid = true, demonhunter = true, evoker = true }
    if token and classes[required] and required ~= token:lower() then reasons[#reasons + 1] = tostring(class) .. " only"
    elseif required ~= tostring(token or ""):lower() and required ~= tostring(name or ""):lower():gsub("%s", "") then unknown = true end
  end
  if record.raceRestriction then unknown = true end
  for _, value in ipairs(NS.Systems.Requirements:Get(record)) do
    if value.met == false then
      reasons[#reasons + 1] = tostring(value.title or "Requirement") .. (value.standing and (" - " .. tostring(value.standing)) or "")
    elseif value.met == nil then
      unknown = true
    end
  end
  return table.concat(reasons, "; "), unknown
end

local function AddCosts(totals, record, quantity)
  local costs = record.costs
  if type(costs) ~= "table" or #costs == 0 then costs = { { currency = record.currency, currencyType = record.currencyType } } end
  local known, complete = false, true
  for _, cost in ipairs(costs) do
    local amount = tonumber(cost.currency)
    local kind = cost.currencytype or cost.currencyType
    if amount and amount >= 0 and (kind == "money" or tonumber(kind) or tonumber(cost.itemID)) then
      local key = cost.itemID and ("item:" .. tostring(cost.itemID)) or tostring(kind)
      local total = totals[key]
      if not total then total = { currency = 0, currencyType = kind, itemID = cost.itemID } totals[key] = total end
      total.currency = total.currency + amount * quantity
      known = true
    else
      complete = false
    end
  end
  return known and complete
end

function DecorRun:CostText(costs)
  local ordered = {}
  for _, cost in pairs(costs or {}) do ordered[#ordered + 1] = cost end
  table.sort(ordered, function(a, b)
    if (a.currencyType == "money") ~= (b.currencyType == "money") then return a.currencyType == "money" end
    return tostring(a.itemID or a.currencyType) < tostring(b.itemID or b.currencyType)
  end)
  return NS.Systems.Cost:Format({ costs = ordered }) or ""
end

function DecorRun:BalanceText(costs)
  local shortages = {}
  for _, cost in pairs(costs or {}) do
    local balance
    if cost.itemID and C_Item and C_Item.GetItemCount then
      balance = C_Item.GetItemCount(tonumber(cost.itemID), false, false, true, false)
    elseif cost.currencyType == "money" and GetMoney then
      balance = GetMoney()
    elseif tonumber(cost.currencyType) and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
      local info = C_CurrencyInfo.GetCurrencyInfo(tonumber(cost.currencyType))
      balance = info and info.quantity
    end
    if tonumber(balance) and balance < cost.currency then
      shortages[#shortages + 1] = { currency = cost.currency - balance, currencyType = cost.currencyType, itemID = cost.itemID }
    end
  end
  table.sort(shortages, function(a, b) return tostring(a.itemID or a.currencyType) < tostring(b.itemID or b.currencyType) end)
  return NS.Systems.Cost:Format({ costs = shortages })
end

function DecorRun:OwnsWaypoint()
  if not self.waypoint or not NS.Systems.Navigation:IsActive(self.waypoint) then return false end
  if C_Map and C_Map.GetUserWaypoint then
    local ok, point = pcall(C_Map.GetUserWaypoint)
    if ok then
      if not point or not point.position or not point.position.GetXY then return false end
      local x, y = point.position:GetXY()
      return tonumber(point.uiMapID) == tonumber(self.waypoint.mapID) and math.abs(x - self.waypoint.mapX) < 0.0001 and math.abs(y - self.waypoint.mapY) < 0.0001
    end
  end
  return true
end

function DecorRun:OpenSource(tab)
  self:End()
  self.sourceMissing, self.navigationError = false, nil
  self.tab, self.entries, self.stops, self.zones, self.excluded = tab, {}, {}, {}, {}
  local source, id
  if tab == "lists" then
    source, id = NS.Systems.Lists:GetActive()
    self.sourceID = id
    for key in pairs(source and source.keys or {}) do
      local record = NS.Systems.Catalog.byID[key]
      if record then self.entries[#self.entries + 1] = { record = record, goal = NS.Systems.Lists:GetQuantity(record, id) } end
    end
  else
    source = NS.Systems.BlueprintList:GetActive()
    self.sourceID = source and source.name
    for _, record in ipairs(source and source.items or {}) do
      local missing = math.max(0, (tonumber(record.needed) or 1) - (tonumber(record.have) or 0))
      if missing > 0 then self.entries[#self.entries + 1] = { record = record, goal = missing } end
    end
  end
  self.sourceName = source and source.name or "No list selected"
  table.sort(self.entries, function(a, b)
    local left, right = tostring(a.record.title or a.record.name or ""), tostring(b.record.title or b.record.name or "")
    if left ~= right then return left < right end
    return tostring(a.record.storageKey or a.record._blueprintKey or "") < tostring(b.record.storageKey or b.record._blueprintKey or "")
  end)
  local groups = {}
  for _, entry in ipairs(self.entries) do
    local record = entry.record
    entry.bags, entry.housing = Inventory(record.itemID)
    entry.gained = 0
    local map, x, y = Location(record)
    if record.sourceType ~= "vendor" and record.sourceType ~= "pvp" then
      entry.reason = "Requires " .. tostring(record.sourceType or "another source")
    elseif not map then
      entry.reason = "Vendor location unavailable"
    end
    if entry.reason then
      self.excluded[#self.excluded + 1] = entry
    else
      local key = table.concat({ tostring(record.sourceID or record.vendorName or record.sourceName or "Vendor"), map, x, y }, ":")
      local stop = groups[key]
      if not stop then
        stop = { key = key, mapID = map, x = x, y = y, record = record, title = record.vendorName or record.sourceName or "Vendor", zone = record.zone or ("Map " .. map), entries = {} }
        groups[key] = stop
        self.stops[#self.stops + 1] = stop
      end
      stop.entries[#stop.entries + 1] = entry
      entry.stop = stop
    end
  end
  local maps = {}
  for _, stop in ipairs(self.stops) do
    if not maps[stop.mapID] then
      maps[stop.mapID] = { mapID = stop.mapID, title = stop.zone, stops = 0 }
      self.zones[#self.zones + 1] = maps[stop.mapID]
    end
    maps[stop.mapID].stops = maps[stop.mapID].stops + 1
  end
  table.sort(self.zones, function(a, b)
    if a.stops ~= b.stops then return a.stops > b.stops end
    if a.title ~= b.title then return a.title < b.title end
    return a.mapID < b.mapID
  end)
  local currentMap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  self.mapID = maps[currentMap] and currentMap or self.zones[1] and self.zones[1].mapID
  self:Refresh()
  self:Reorder()
end

function DecorRun:Remaining(entry)
  local record = entry.record
  local remaining = math.max(0, entry.goal - entry.gained)
  if self.sourceMissing then return remaining end
  if self.tab == "lists" then
    remaining = math.min(remaining, NS.Systems.Lists:GetQuantity(record, self.sourceID))
  else
    local profile = NS.Systems.Database:GetProfile()
    local live = profile and profile.blueprintList and profile.blueprintList[self.sourceID]
    live = live and live[record._blueprintKey]
    remaining = math.min(remaining, live and math.max(0, (tonumber(live.needed) or 1) - (tonumber(live.have) or 0)) or 0)
  end
  return remaining
end

function DecorRun:TrackPurchases()
  if not self.started then return end
  local merchantID
  if MerchantFrame and MerchantFrame:IsShown() and UnitGUID then
    local guid = UnitGUID("npc")
    merchantID = type(guid) == "string" and tonumber(guid:match("^[^-]+%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)%-")) or nil
  end
  for itemID, inventory in pairs(self.inventory or {}) do
    local bags, housing = Inventory(itemID)
    local gained = math.max(inventory.gained, bags - inventory.bags, housing - inventory.housing, 0)
    local extra = gained - inventory.gained
    inventory.gained = gained
    if extra > 0 then
      local entries = {}
      for _, entry in ipairs(inventory.entries) do entries[#entries + 1] = entry end
      table.sort(entries, function(a, b)
        if merchantID then
          local aMerchant, bMerchant = tonumber(a.record.sourceID) == merchantID, tonumber(b.record.sourceID) == merchantID
          if aMerchant ~= bMerchant then return aMerchant end
        end
        local aCurrent, bCurrent = false, false
        for _, entry in ipairs(self.current and self.current.entries or {}) do
          if entry == a then aCurrent = true end
          if entry == b then bCurrent = true end
        end
        if aCurrent ~= bCurrent then return aCurrent end
        local aZone, bZone = a.stop and a.stop.mapID == self.mapID or false, b.stop and b.stop.mapID == self.mapID or false
        if aZone ~= bZone then return aZone end
        return a.order < b.order
      end)
      for _, entry in ipairs(entries) do
        local credit = math.min(extra, math.max(0, entry.goal - entry.gained))
        entry.gained = entry.gained + credit
        extra = extra - credit
      end
    end
  end
  local queue = NS.Systems.ShoppingBuyQueue
  if self.tab == "lists" and not (queue and queue:IsRunning()) then
    for _, entry in ipairs(self.entries or {}) do
      local live = NS.Systems.Lists:GetQuantity(entry.record, self.sourceID)
      local untracked = entry.gained - math.max(0, entry.goal - live)
      if live > 0 and live <= entry.goal and untracked > 0 then NS.Systems.Lists:AdjustQuantity(entry.record, -math.min(live, untracked), self.sourceID) end
    end
  end
end

function DecorRun:Refresh()
  if self.sourceID then
    local source
    if self.tab == "lists" then
      source = not NS.Systems.Lists.Get or NS.Systems.Lists:Get(self.sourceID)
    else
      local profile = NS.Systems.Database:GetProfile()
      source = profile and profile.blueprintList and profile.blueprintList[self.sourceID]
    end
    if not source then self.sourceMissing = true self:End() end
  end
  self:TrackPurchases()
  for _, stop in ipairs(self.stops or {}) do
    stop.remaining, stop.ready, stop.blocked, stop.unknownCosts, stop.unverified, stop.costs = 0, 0, 0, 0, 0, {}
    for _, entry in ipairs(stop.entries) do
      entry.remaining = self:Remaining(entry)
      entry.reason, entry.unknown = Restrictions(entry.record)
      stop.remaining = stop.remaining + entry.remaining
      if entry.remaining > 0 then
        if entry.reason ~= "" then
          stop.blocked = stop.blocked + 1
        else
          stop.ready = stop.ready + 1
          if entry.unknown then stop.unverified = stop.unverified + 1 end
          if not AddCosts(stop.costs, entry.record, entry.remaining) then stop.unknownCosts = stop.unknownCosts + 1 end
        end
      end
    end
  end
  if self.running then
    local current = self.current
    if not current or current.remaining == 0 or current.ready == 0 or current.skipped then
      local ownsWaypoint = self:OwnsWaypoint()
      self.current = nil
      for _, stop in ipairs(self.route or {}) do
        if stop.remaining > 0 and stop.ready > 0 and not stop.skipped then self.current = stop break end
      end
      self.selected = self.current or self.selected
      if ownsWaypoint then
        if self.current then self:Navigate() else NS.Systems.Navigation:Clear() self.waypoint = nil end
      end
    end
  end
end

function DecorRun:Reorder()
  local pool, route = {}, {}
  for _, stop in ipairs(self.stops or {}) do if stop.mapID == self.mapID then pool[#pool + 1] = stop end end
  local position = C_Map and C_Map.GetPlayerMapPosition and self.mapID and C_Map.GetPlayerMapPosition(self.mapID, "player")
  local x, y
  if position then x, y = position:GetXY() end
  while #pool > 0 do
    local best, score = 1, math.huge
    for index, stop in ipairs(pool) do
      local distance = x and math.sqrt((stop.x - x) ^ 2 + (stop.y - y) ^ 2) or 0
      local value = (distance + 0.04) / math.sqrt(math.max(1, stop.ready))
      if stop.ready == 0 or stop.remaining == 0 or stop.skipped then value = value + 100 end
      if value < score or value == score and stop.key < pool[best].key then best, score = index, value end
    end
    local stop = table.remove(pool, best)
    route[#route + 1] = stop
    if stop.ready > 0 and stop.remaining > 0 and not stop.skipped then x, y = stop.x, stop.y end
  end
  self.route = route
  self.selected = self.current or route[1]
end

function DecorRun:SetZone(mapID)
  if self.running then return end
  self.mapID = mapID
  self:Refresh()
  self:Reorder()
end

function DecorRun:Start()
  if self.running then return end
  self.inventory = {}
  for index, entry in ipairs(self.entries or {}) do
    entry.goal = self:Remaining(entry)
    entry.bags, entry.housing = Inventory(entry.record.itemID)
    entry.gained, entry.order = 0, index
    if entry.record.itemID then
      local inventory = self.inventory[entry.record.itemID]
      if not inventory then inventory = { bags = entry.bags, housing = entry.housing, gained = 0, entries = {} } self.inventory[entry.record.itemID] = inventory end
      inventory.entries[#inventory.entries + 1] = entry
    end
  end
  self.started, self.running = true, true
  self:Refresh()
  self:Navigate()
end

function DecorRun:Navigate()
  local stop = self.current
  if not stop then return false end
  if NS.Systems.Navigation:Set(stop.record) then self.waypoint, self.navigationError = stop.record, nil return true end
  self.navigationError = "Waypoint unavailable. Check this vendor's location in the catalog."
  return false
end

function DecorRun:Skip()
  if not self.running or not self.current then return end
  self.current.skipped = true
  self:Refresh()
end

function DecorRun:Resume(stop)
  if not stop or stop.remaining == 0 or stop.ready == 0 then return end
  stop.skipped = nil
  self.current, self.selected = stop, stop
  if self.running then self:Navigate() end
end

function DecorRun:End()
  if self:OwnsWaypoint() then NS.Systems.Navigation:Clear() end
  self.running, self.current, self.waypoint, self.started = false, nil, nil, false
end
