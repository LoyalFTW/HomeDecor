local _, NS = ...

local Lists = { revision = 0 }
NS.Systems.Lists = Lists

local BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local MAX_IMPORT_ENTRIES = 1000

local function EncodeBase64(value)
  return ((value:gsub(".", function(character)
    local bits = ""
    local byte = character:byte()
    for shift = 8, 1, -1 do
      bits = bits .. (byte % 2 ^ shift - byte % 2 ^ (shift - 1) > 0 and "1" or "0")
    end
    return bits
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(bits)
    if #bits < 6 then return "" end
    local index = 0
    for position = 1, 6 do
      if bits:sub(position, position) == "1" then index = index + 2 ^ (6 - position) end
    end
    return BASE64:sub(index + 1, index + 1)
  end) .. ({ "", "==", "=" })[#value % 3 + 1])
end

local function DecodeBase64(value)
  if type(value) ~= "string" or value == "" or value:find("[^" .. BASE64 .. "=]") then return nil end
  value = value:gsub("=", "")
  return (value:gsub(".", function(character)
    local position = BASE64:find(character, 1, true)
    if not position then return "" end
    local bits = ""
    local number = position - 1
    for shift = 6, 1, -1 do
      bits = bits .. (number % 2 ^ shift - number % 2 ^ (shift - 1) > 0 and "1" or "0")
    end
    return bits
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(bits)
    if #bits ~= 8 then return "" end
    local byte = 0
    for position = 1, 8 do
      if bits:sub(position, position) == "1" then byte = byte + 2 ^ (8 - position) end
    end
    return string.char(byte)
  end))
end

local function EncodeValue(value)
  return tostring(value or ""):gsub("([^%w%-%._~])", function(character)
    return string.format("%%%02X", character:byte())
  end)
end

local function DecodeValue(value)
  return tostring(value or ""):gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

local function NormalizeEntry(entry)
  if type(entry) ~= "table" then return end
  entry.keys = type(entry.keys) == "table" and entry.keys or {}
  entry.quantities = type(entry.quantities) == "table" and entry.quantities or {}
  entry.meta = type(entry.meta) == "table" and entry.meta or {}
  for key, enabled in pairs(entry.keys) do
    if enabled then entry.quantities[key] = math.max(1, tonumber(entry.quantities[key]) or 1) end
  end
end

local function FindRecord(itemID, decorID, npcID)
  itemID = tonumber(itemID)
  decorID = tonumber(decorID)
  npcID = tonumber(npcID)
  local fallback
  for _, record in ipairs((NS.Systems.Catalog and NS.Systems.Catalog.ordered) or {}) do
    local matches = itemID and itemID > 0 and tonumber(record.itemID) == itemID
      or decorID and decorID > 0 and tonumber(record.decorID) == decorID
    if matches then
      fallback = fallback or record
      if npcID and npcID > 0 and tonumber(record.sourceID) == npcID then return record end
    end
  end
  return fallback
end

local function ParseHeader(line, format)
  local meta = {}
  for part in tostring(line or ""):gmatch("[^,]+") do
    local key, value = part:match("^(%w+)=(.*)$")
    if key then meta[key] = format == "HDGVL" and key ~= "desc" and value or DecodeValue(value) end
  end
  return meta
end

local function UniqueName(store, name, exceptID)
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then name = "Imported Shopping List" end
  local taken = {}
  for id, entry in pairs(store.entries or {}) do
    if id ~= exceptID and entry.name then taken[entry.name] = true end
  end
  if not taken[name] then return name end
  local suffix = 2
  while taken[name .. " (" .. suffix .. ")"] do suffix = suffix + 1 end
  return name .. " (" .. suffix .. ")"
end

function Lists:Touch()
  self.revision = self.revision + 1
  NS.SendMessage("HOMEDECOR_LISTS_UPDATED")
end

function Lists:GetStore()
  local profile = NS.Systems.Database:GetProfile()
  local store = profile and profile.lists
  if store then
    store.order = type(store.order) == "table" and store.order or {}
    store.entries = type(store.entries) == "table" and store.entries or {}
    store.nextID = tonumber(store.nextID) or 1
    for _, entry in pairs(store.entries) do NormalizeEntry(entry) end
  end
  return store, profile
end

function Lists:GetActive()
  local store, profile = self:GetStore()
  if not store then return nil end
  local id = profile.ui.activeListID
  local entry = id and store.entries[id]
  if entry then return entry, id end
  id = store.order[1]
  entry = id and store.entries[id]
  profile.ui.activeListID = id
  return entry, id
end

function Lists:Get(id)
  local store = self:GetStore()
  return store and id and store.entries[id] or nil
end

function Lists:SetActive(id)
  local store, profile = self:GetStore()
  if not store or not store.entries[id] then return false end
  profile.ui.activeListID = id
  self:Touch()
  return true
end

function Lists:Create(name)
  local store, profile = self:GetStore()
  if not store then return nil end
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then name = "New Shopping List" end
  local id = "list" .. tostring(store.nextID)
  store.nextID = store.nextID + 1
  store.entries[id] = { name = name, keys = {}, quantities = {}, meta = {} }
  store.order[#store.order + 1] = id
  profile.ui.activeListID = id
  self:Touch()
  return store.entries[id], id
end

function Lists:Rename(name)
  local entry = self:GetActive()
  if not entry then return false end
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if name == "" then return false end
  entry.name = name
  self:Touch()
  return true
end

function Lists:DeleteActive()
  local store, profile = self:GetStore()
  local _, id = self:GetActive()
  if not store or not id then return false end
  store.entries[id] = nil
  for index = #store.order, 1, -1 do
    if store.order[index] == id then table.remove(store.order, index) end
  end
  profile.ui.activeListID = store.order[1]
  self:Touch()
  return true
end

function Lists:Cycle(delta)
  local store, profile = self:GetStore()
  if not store or #store.order == 0 then return nil end
  local _, activeID = self:GetActive()
  local index = 1
  for candidate = 1, #store.order do
    if store.order[candidate] == activeID then index = candidate break end
  end
  index = ((index - 1 + delta) % #store.order) + 1
  profile.ui.activeListID = store.order[index]
  self:Touch()
  return self:GetActive()
end

function Lists:Contains(record, id)
  local entry = id and self:Get(id) or self:GetActive()
  local key = record and record.storageKey
  return entry and key and entry.keys[key] == true or false
end

function Lists:GetQuantity(record, id)
  local entry = id and self:Get(id) or self:GetActive()
  local key = record and record.storageKey
  if not entry or not key or entry.keys[key] ~= true then return 0 end
  NormalizeEntry(entry)
  return math.max(1, tonumber(entry.quantities[key]) or 1)
end

function Lists:SetQuantity(record, quantity, id)
  local entry = id and self:Get(id) or self:GetActive()
  local key = record and record.storageKey
  if not entry or not key then return false end
  NormalizeEntry(entry)
  quantity = math.max(0, math.min(9999, math.floor(tonumber(quantity) or 0)))
  if quantity == 0 then
    entry.keys[key] = nil
    entry.quantities[key] = nil
  else
    entry.keys[key] = true
    entry.quantities[key] = quantity
  end
  self:Touch()
  return true
end

function Lists:AdjustQuantity(record, delta, id)
  local quantity = self:GetQuantity(record, id)
  delta = tonumber(delta) or 0
  if quantity == 0 and delta <= 0 then return false end
  return self:SetQuantity(record, quantity + delta, id)
end

function Lists:GetRecordByItem(itemID, id, sourceID)
  itemID = tonumber(itemID)
  sourceID = tonumber(sourceID)
  local entry = id and self:Get(id) or self:GetActive()
  if not entry or not itemID then return nil end
  local fallback
  for key in pairs(entry.keys) do
    local record = NS.Systems.Catalog.byID[key]
    if record and tonumber(record.itemID) == itemID then
      fallback = fallback or record
      if sourceID and tonumber(record.sourceID) == sourceID then return record, self:GetQuantity(record, id) end
    end
  end
  return fallback, fallback and self:GetQuantity(fallback, id) or 0
end

function Lists:Add(record, id)
  local entry = id and self:Get(id) or self:GetActive()
  if not entry then entry = self:Create("My Shopping List") end
  local key = record and record.storageKey
  if not entry or not key then return false end
  entry.keys[key] = true
  entry.quantities = entry.quantities or {}
  entry.quantities[key] = math.max(1, tonumber(entry.quantities[key]) or 1)
  self:Touch()
  return true
end

function Lists:Remove(record, id)
  local entry = id and self:Get(id) or self:GetActive()
  local key = record and record.storageKey
  if not entry or not key or entry.keys[key] ~= true then return false end
  entry.keys[key] = nil
  if entry.quantities then entry.quantities[key] = nil end
  self:Touch()
  return true
end

function Lists:Import(encoded)
  encoded = tostring(encoded or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if #encoded > 100000 then return nil, "That shopping-list code is too large." end
  local format, payload
  if encoded:sub(1, 8) == "HDGVL:1:" then
    format = "HDGVL"
    payload = DecodeBase64(encoded:sub(9))
  elseif encoded:sub(1, 9) == "HDSHOP:1:" then
    format = "HDSHOP"
    payload = DecodeBase64(encoded:sub(10))
  else
    return nil, "That is not a supported shopping-list code."
  end
  if not payload then return nil, "The shopping-list code could not be decoded." end

  local lines = {}
  for line in payload:gmatch("[^\r\n]+") do lines[#lines + 1] = line end
  if #lines == 0 then return nil, "The shopping-list code is empty." end
  local firstField = lines[1]:match("^([^,]+)")
  local hasHeader = firstField and firstField:match("^%a") ~= nil
  local meta = hasHeader and ParseHeader(lines[1], format) or {}
  local keys, quantities = {}, {}
  local count, total, unresolved = 0, 0, 0
  local firstItem = hasHeader and 2 or 1
  for index = firstItem, math.min(#lines, firstItem + MAX_IMPORT_ENTRIES - 1) do
    local itemID, decorID, npcID, quantity
    if format == "HDSHOP" then
      itemID, decorID, npcID, quantity = lines[index]:match("^(%-?%d+),(%-?%d+),(%-?%d+),(%-?%d+)$")
    else
      itemID, npcID, quantity = lines[index]:match("^(%-?%d+),(%-?%d+),(%-?%d+)$")
      local externalID = tonumber(itemID)
      local direct = FindRecord(externalID, nil, npcID)
      if direct then
        itemID = externalID
      else
        decorID = externalID
        itemID = nil
      end
    end
    quantity = math.max(1, math.min(9999, math.floor(tonumber(quantity) or 1)))
    local record = FindRecord(itemID, decorID, npcID)
    if record and record.storageKey then
      if not keys[record.storageKey] then count = count + 1 end
      keys[record.storageKey] = true
      quantities[record.storageKey] = math.min(9999, (quantities[record.storageKey] or 0) + quantity)
    else
      unresolved = unresolved + 1
    end
  end
  if count == 0 then return nil, "No decor items in that code matched the HomeDecor catalog." end
  for _, quantity in pairs(quantities) do total = total + quantity end

  local store, profile = self:GetStore()
  if not store then return nil, "Shopping lists are not ready yet." end
  local sourceURL = meta.url
  local existingID
  if sourceURL and sourceURL ~= "" then
    for id, entry in pairs(store.entries) do
      if entry.meta and entry.meta.url == sourceURL then existingID = id break end
    end
  end
  local rawName = meta.name or meta.desc or "Imported Shopping List"
  local entry, id
  if existingID then
    id = existingID
    entry = store.entries[id]
    entry.name = UniqueName(store, rawName, id)
    entry.keys = keys
    entry.quantities = quantities
    entry.meta = meta
  else
    entry, id = self:Create(UniqueName(store, rawName))
    entry.keys = keys
    entry.quantities = quantities
    entry.meta = meta
  end
  entry.meta.source = entry.meta.source or (format == "HDGVL" and "HDG compatible" or "HomeDecor")
  entry.meta.format = format
  profile.ui.activeListID = id
  self:Touch()
  return { entry = entry, id = id, count = count, total = total, unresolved = unresolved, replaced = existingID ~= nil, format = format }
end

function Lists:Export(id, compatible)
  local entry = id and self:Get(id) or self:GetActive()
  if not entry then return nil, "Select a shopping list first." end
  NormalizeEntry(entry)
  local meta = entry.meta or {}
  local header = {}
  if compatible then
    header[#header + 1] = "source=HomeDecor"
    header[#header + 1] = "desc=" .. EncodeValue(entry.name)
  else
    header[#header + 1] = "source=" .. EncodeValue(meta.source or "HomeDecor")
    header[#header + 1] = "name=" .. EncodeValue(entry.name)
  end
  if meta.url and meta.url ~= "" then header[#header + 1] = "url=" .. (compatible and tostring(meta.url) or EncodeValue(meta.url)) end
  if meta.author and meta.author ~= "" then header[#header + 1] = "author=" .. (compatible and tostring(meta.author) or EncodeValue(meta.author)) end
  local exportDate = meta.date or (date and date("%Y-%m-%d") or "")
  header[#header + 1] = "date=" .. (compatible and tostring(exportDate) or EncodeValue(exportDate))
  local lines = { table.concat(header, ",") }
  local records = {}
  for key in pairs(entry.keys) do
    local record = NS.Systems.Catalog.byID[key]
    if record then records[#records + 1] = record end
  end
  table.sort(records, function(left, right)
    return tostring(left.title or left.itemID or left.decorID or "") < tostring(right.title or right.itemID or right.decorID or "")
  end)
  for _, record in ipairs(records) do
    local quantity = math.max(1, tonumber(entry.quantities[record.storageKey]) or 1)
    local itemID = tonumber(record.itemID) or 0
    local decorID = tonumber(record.decorID) or 0
    local sourceID = tonumber(record.sourceID) or 0
    local npcID = record.sourceType == "vendor" and sourceID or 0
    if compatible then
      local externalID = itemID > 0 and itemID or decorID
      if externalID > 0 then lines[#lines + 1] = table.concat({ externalID, npcID, quantity }, ",") end
    elseif itemID > 0 or decorID > 0 then
      lines[#lines + 1] = table.concat({ itemID, decorID, sourceID, quantity }, ",")
    end
  end
  if #lines == 1 then return nil, "That shopping list has no exportable decor." end
  return (compatible and "HDGVL:1:" or "HDSHOP:1:") .. EncodeBase64(table.concat(lines, "\n"))
end

function Lists:Toggle(record, id)
  if self:Contains(record, id) then return self:Remove(record, id) and false end
  return self:Add(record, id)
end

function Lists:Count()
  local entry = self:GetActive()
  if not entry then return 0 end
  local count = 0
  for key in pairs(entry.keys) do
    if NS.Systems.Catalog.byID[key] then count = count + 1 end
  end
  return count
end

function Lists:GetTotalQuantity(id)
  local entry = id and self:Get(id) or self:GetActive()
  if not entry then return 0 end
  NormalizeEntry(entry)
  local total = 0
  for key in pairs(entry.keys) do
    if NS.Systems.Catalog.byID[key] then total = total + math.max(1, tonumber(entry.quantities[key]) or 1) end
  end
  return total
end

function Lists:ForRange(offset, limit, consume)
  local entry = self:GetActive()
  if not entry then return 0 end
  local matched, emitted = 0, 0
  for key in pairs(entry.keys) do
    local record = NS.Systems.Catalog.byID[key]
    if record then
      matched = matched + 1
      if matched > offset then
        emitted = emitted + 1
        if consume(record, matched) == false or emitted >= limit then break end
      end
    end
  end
  return emitted
end

function Lists:ForRangeSearch(offset, limit, search, consume)
  local entry = self:GetActive()
  if not entry then return 0 end
  search = type(search) == "string" and search:lower():gsub("^%s+", ""):gsub("%s+$", "") or ""
  if search == "" then return self:ForRange(offset, limit, consume) end
  local matched, emitted = 0, 0
  for key in pairs(entry.keys) do
    local record = NS.Systems.Catalog.byID[key]
    if record then
      local static = record.searchText or ""
      local name = NS.Systems.Housing:GetSearchName(record)
      if static:find(search, 1, true) or name:find(search, 1, true) then
        matched = matched + 1
        if matched > offset then
          emitted = emitted + 1
          if consume(record, matched) == false or emitted >= limit then break end
        end
      end
    end
  end
  return emitted
end

function Lists:CountSearch(search)
  local count = 0
  self:ForRangeSearch(0, math.huge, search, function()
    count = count + 1
  end)
  return count
end
