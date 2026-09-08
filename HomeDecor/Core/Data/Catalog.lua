local _, NS = ...

local Catalog = {
  byID = {},
  ordered = {},
  categories = {},
  byIdentity = {},
  revision = 0,
}
NS.Systems.Catalog = Catalog

local function CopyRecord(source)
  return {
    id = source.id,
    decorID = source.decorID,
    itemID = source.itemID,
    title = source.title,
    icon = source.icon,
    category = source.category,
    subcategory = source.subcategory,
    profession = source.profession,
    expansion = source.expansion,
    zone = source.zone,
    worldmap = source.worldmap,
    mapID = source.mapID,
    mapX = source.mapX,
    mapY = source.mapY,
    faction = source.faction,
    sourceType = source.sourceType,
    sourceID = source.sourceID,
    sourceName = source.sourceName,
    skillID = source.skillID,
    vendorName = source.vendorName,
    requirements = source.requirements,
    metadata = source.metadata,
    searchText = source.searchText,
    budgetCost = source.budgetCost,
    currency = source.currency,
    currencyType = source.currencyType,
    costs = source.costs,
    classRestriction = source.classRestriction,
    raceRestriction = source.raceRestriction,
    size = source.size,
    colors = source.colors,
    note = source.note,
    dyeable = source.dyeable,
    storageKey = source.storageKey,
    displayMeta = source.displayMeta,
    favoriteKey = source.favoriteKey,
    displayDyeable = source.displayDyeable,
    alternateSources = source.alternateSources,
    dropLocations = source.dropLocations,
  }
end

local function DistinctSource(left, right)
  local fields = { "sourceType", "sourceID", "sourceName", "vendorName", "zone", "worldmap" }
  for index = 1, #fields do
    local field = fields[index]
    if left[field] ~= nil and right[field] ~= nil and tostring(left[field]) ~= tostring(right[field]) then return true end
  end
  return false
end

local function RecordKey(record)
  local id = tonumber(record.decorID) or tonumber(record.itemID) or tonumber(record.id)
  if not id then return nil end
  return table.concat({ tostring(id), tostring(record.sourceType or ""), tostring(record.sourceID or "") }, ":")
end

local function IdentityKey(record)
  local decorID = tonumber(record and record.decorID)
  if decorID then return "d:" .. tostring(decorID) end
  local itemID = tonumber(record and record.itemID)
  if itemID then return "i:" .. tostring(itemID) end
end

function Catalog:Reset()
  wipe(self.byID)
  wipe(self.ordered)
  wipe(self.categories)
  wipe(self.byIdentity)
  self.revision = self.revision + 1
end

function Catalog:Add(source)
  if type(source) ~= "table" then return nil end
  local key = RecordKey(source)
  if not key then return nil end
  local record = CopyRecord(source)
  local current = self.byID[key]
  if current then
    if DistinctSource(current, record) then
      current.alternateSources = current.alternateSources or {}
      local unique = true
      for index = 1, #current.alternateSources do
        if not DistinctSource(current.alternateSources[index], record) then unique = false break end
      end
      if unique then current.alternateSources[#current.alternateSources + 1] = record end
    end
    for field, value in pairs(record) do
      if current[field] == nil and value ~= nil then current[field] = value end
    end
    return current
  end
  self.byID[key] = record
  record.storageKey = key
  record.favoriteKey = record.itemID and ("item:" .. tostring(record.itemID)) or record.decorID and ("decor:" .. tostring(record.decorID)) or nil
  self.ordered[#self.ordered + 1] = record
  local category = record.category or "Uncategorized"
  local bucket = self.categories[category]
  if not bucket then
    bucket = {}
    self.categories[category] = bucket
  end
  bucket[#bucket + 1] = record
  self.revision = self.revision + 1
  return record
end

function Catalog:Count()
  return #self.ordered
end

function Catalog:Finalize()
  wipe(self.byIdentity)
  for index = 1, #self.ordered do
    local record = self.ordered[index]
    local key = IdentityKey(record)
    if key then
      self.byIdentity[key] = self.byIdentity[key] or {}
      self.byIdentity[key][#self.byIdentity[key] + 1] = record
    end
  end
  self:Sort(NS.Systems.QueryState and NS.Systems.QueryState:GetSort() or "name")
end

function Catalog:GetMatches(record)
  local key = IdentityKey(record)
  if key and self.byIdentity[key] then return self.byIdentity[key] end
  return record and { record } or {}
end

function Catalog:Sort(mode)
  local sizeOrder = { Tiny = 1, Small = 2, Medium = 3, Large = 4, Huge = 5 }
  local keys = {}
  local function Name(record)
    local resolved = NS.Systems.Housing and NS.Systems.Housing:GetSearchName(record) or ""
    if resolved ~= "" then return resolved end
    return tostring(record.title or record.searchText or record.decorID or record.itemID or ""):lower()
  end
  for index = 1, #self.ordered do
    local record = self.ordered[index]
    local category, subcategory
    if (mode == "category" or mode == "category_desc" or mode == "subcategory" or mode == "subcategory_desc") and NS.Systems.Housing then
      category, subcategory = NS.Systems.Housing:GetCategoryNames(record)
    end
    keys[record] = {
      name = Name(record),
      category = tostring(category or subcategory or record.subcategory or ""):lower(),
      subcategory = tostring(subcategory or record.subcategory or ""):lower(),
      source = table.concat({ tostring(record.sourceType or ""), tostring(record.sourceName or record.vendorName or ""), tostring(record.zone or "") }, "\031"):lower(),
      id = tonumber(record.decorID or record.itemID or record.id) or 0,
      budget = tonumber(record.budgetCost) or math.huge,
      size = sizeOrder[record.size] or math.huge,
    }
  end
  table.sort(self.ordered, function(a, b)
    local left, right = keys[a], keys[b]
    local field = (mode == "category" or mode == "category_desc") and "category"
      or (mode == "subcategory" or mode == "subcategory_desc") and "subcategory"
      or (mode == "source" or mode == "source_desc") and "source"
      or mode == "budget" and "budget"
      or mode == "size" and "size"
      or "name"
    local leftValue, rightValue = left[field], right[field]
    if leftValue ~= rightValue then
      local descending = mode == "name_desc" or mode == "category_desc" or mode == "subcategory_desc" or mode == "source_desc"
      if descending then return leftValue > rightValue end
      return leftValue < rightValue
    end
    if left.name ~= right.name then return left.name < right.name end
    return left.id < right.id
  end)
  self.revision = self.revision + 1
end
