local _, NS = ...

local Housing = {}
NS.Systems.Housing = Housing

local displayCache = {}
local displayOrder = {}
local displayHead = 1
local displaySize = 0
local DISPLAY_CAPACITY = 128
local searchNames = {}
local dyeable = {}
local categoryNames = {}
local catalogEntryType = 1
local catalogDiscoveryAttempted = false
local vendorClasses = {
  [103693] = "Hunter",
  [105986] = "Rogue",
  [112318] = "Shaman",
  [112323] = "Druid",
  [93550] = "Death Knight",
  [100196] = "Paladin",
  [112338] = "Monk",
  [112392] = "Warrior",
  [112401] = "Priest",
  [112407] = "Demon Hunter",
  [112434] = "Warlock",
  [112440] = "Mage",
}

local function Accessible(value)
  if value == nil then return false end
  if issecretvalue and issecretvalue(value) then return false end
  if canaccessvalue and not canaccessvalue(value) then return false end
  return true
end

local function Normalize(value)
  if type(value) ~= "string" then return "" end
  return value:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function OwnedFromInfo(info)
  if not info then return nil end
  if type(info.isOwned) == "boolean" then return info.isOwned end
  if type(info.isCollected) == "boolean" then return info.isCollected end
  return (tonumber(info.totalNumStored or info.quantity) or 0) + (tonumber(info.remainingRedeemable) or 0) + (tonumber(info.totalNumPlaced or info.numPlaced) or 0) > 0
end

local function TryRecord(entryType, decorID)
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogEntryInfoByRecordID
  if not api or type(entryType) ~= "number" or not decorID then return nil end
  local ok, info = pcall(api, entryType, decorID, true)
  if ok and type(info) == "table" then return info end
  ok, info = pcall(api, entryType, decorID)
  if ok and type(info) == "table" then return info end
  ok, info = pcall(api, entryType, decorID, false)
  if ok and type(info) == "table" then return info end
  return nil
end

local function TryItem(itemID)
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogEntryInfoByItem
  if not api or not itemID then return nil end
  local ok, info = pcall(api, itemID, true)
  if ok and type(info) == "table" then return info end
  ok, info = pcall(api, itemID)
  if ok and type(info) == "table" then return info end
  return nil
end

local function PutDisplay(key, title, icon, owned)
  if displayCache[key] then
    displayCache[key].title = title
    displayCache[key].icon = icon
    displayCache[key].owned = owned
    return
  end
  if displaySize >= DISPLAY_CAPACITY then
    local expired = displayOrder[displayHead]
    displayCache[expired] = nil
    displayOrder[displayHead] = key
    displayHead = displayHead + 1
    if displayHead > DISPLAY_CAPACITY then displayHead = 1 end
  else
    displaySize = displaySize + 1
    displayOrder[displaySize] = key
  end
  displayCache[key] = { title = title, icon = icon, owned = owned }
end

function Housing:GetEntry(record)
  NS.Systems.Diagnostics:Mark("Housing:GetEntry")
  if not record then return nil end
  local decorID = tonumber(record.decorID)
  local itemID = tonumber(record.itemID)
  if catalogEntryType and decorID then
    local info = TryRecord(catalogEntryType, decorID)
    if info then return info end
  end
  local enum = _G.Enum and _G.Enum.HousingCatalogEntryType
  local preferred = enum and tonumber(enum.Decor)
  if preferred and preferred ~= catalogEntryType and decorID then
    local info = TryRecord(preferred, decorID)
    if info then
      catalogEntryType = preferred
      return info
    end
  end
  local itemInfo = TryItem(itemID)
  if itemInfo then
    if type(itemInfo.entryType) == "number" then catalogEntryType = itemInfo.entryType end
    return itemInfo
  end
  if decorID and enum and not catalogDiscoveryAttempted then
    catalogDiscoveryAttempted = true
    for _, entryType in pairs(enum) do
      if type(entryType) == "number" and entryType ~= catalogEntryType and entryType ~= preferred then
        local info = TryRecord(entryType, decorID)
        if info then
          catalogEntryType = entryType
          return info
        end
      end
    end
  end
  if decorID and not catalogDiscoveryAttempted then
    catalogDiscoveryAttempted = true
    for entryType = 0, 30 do
      if entryType ~= catalogEntryType and entryType ~= preferred then
        local info = TryRecord(entryType, decorID)
        if info then
          catalogEntryType = entryType
          return info
        end
      end
    end
  end
  return nil
end

function Housing:GetDisplay(record)
  local key = record and record.decorID
  local decorID = tonumber(key)
  local catalogRecord = record and record.storageKey ~= nil
  if catalogRecord and type(record.title) == "string" and record.title ~= "" and record.title ~= "UNKNOWN" and record.icon and tonumber(record.icon) ~= 0 and tonumber(record.icon) ~= 134400 then
    local owned = NS.Systems.Collection and NS.Systems.Collection:GetOwned(record)
    return record.title, record.icon, owned
  end
  local cached = key and displayCache[key]
  if cached then
    local owned = cached.owned
    if catalogRecord and NS.Systems.Collection then owned = NS.Systems.Collection:GetOwned(record) end
    return cached.title, cached.icon, owned
  end
  local info = self:GetEntry(record)
  local title = record.title or (info and info.name)
  local icon = (info and (info.iconTexture or info.iconFileID)) or record.icon
  if not Accessible(title) then title = nil end
  if not Accessible(icon) then icon = nil end
  if title == "" or title == "UNKNOWN" then title = nil end
  if tonumber(icon) == 0 or tonumber(icon) == 134400 then icon = nil end
  local owned = OwnedFromInfo(info)
  if not title and record.itemID and NS.Systems.ItemResolver then title = NS.Systems.ItemResolver:GetName(record.itemID, decorID and ("Decor #" .. tostring(decorID)) or nil) end
  if not icon and record.itemID and NS.Systems.ItemResolver then icon = NS.Systems.ItemResolver:GetIcon(record.itemID) end
  if not title or title == "" then title = "Decor #" .. tostring(record.decorID or record.itemID or "?") end
  if not icon then icon = "Interface\\Icons\\INV_Misc_QuestionMark" end
  if catalogRecord then
    if type(title) == "string" and title ~= "Loading..." and not title:match("^Decor #") then record.title = title end
    if icon ~= "Interface\\Icons\\INV_Misc_QuestionMark" then record.icon = icon end
  end
  if key and title ~= "Loading..." and not tostring(title):match("^Decor #") then
    PutDisplay(key, title, icon, owned)
    if searchNames[key] == nil then
      local normalized = Normalize(title)
      searchNames[key] = normalized ~= "" and normalized or false
    end
    if dyeable[key] == nil then dyeable[key] = record.dyeable == true or (info and info.canCustomize == true) or false end
  end
  return title, icon, owned
end

function Housing:GetCatalogDisplay(record)
  if not record then return "Unknown Decor", "Interface\\Icons\\INV_Misc_QuestionMark", false end
  local title, icon = self:GetDisplay(record)
  return title, icon, NS.Systems.Collection:IsOwned(record)
end

function Housing:GetCategoryNames(record)
  if not record then return nil, nil end
  local key = tonumber(record.decorID)
  local cached = key and categoryNames[key]
  if cached then return cached.category, cached.subcategory end
  local info = self:GetEntry(record)
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogCategoryAndSubcategoryNames
  if info and type(info.subcategoryIDs) == "table" and api then
    for index = 1, #info.subcategoryIDs do
      local ok, category, subcategory = pcall(api, info.subcategoryIDs[index])
      if ok and Accessible(category) and Accessible(subcategory) and (category ~= "" or subcategory ~= "") then
        local result = { category = category ~= "" and tostring(category) or nil, subcategory = subcategory ~= "" and tostring(subcategory) or nil }
        if key then categoryNames[key] = result end
        return result.category, result.subcategory
      end
    end
  end
  local subcategory = record.subcategory and tostring(record.subcategory) or nil
  local category = subcategory == "Food and Drink" and "Accents" or nil
  return category, subcategory
end

function Housing:GetCategoryPath(record)
  local category, subcategory = self:GetCategoryNames(record)
  if category and subcategory then
    if subcategory:lower():find(category:lower(), 1, true) then return subcategory end
    return category .. " -> " .. subcategory
  end
  return subcategory or category
end

function Housing:GetOwned(record)
  local key = record and record.decorID
  local cached = key and displayCache[key]
  if cached and cached.owned ~= nil then return cached.owned == true end
  return OwnedFromInfo(self:GetEntry(record))
end

function Housing:GetSearchName(record)
  local key = record and record.decorID
  if not record then return "" end
  if type(record.title) == "string" and record.title ~= "" and record.title ~= "Loading..." then return Normalize(record.title) end
  if not key then return Normalize(record.title) end
  if searchNames[key] ~= nil then return searchNames[key] or "" end
  local cached = displayCache[key]
  local name = record.title or (cached and cached.title)
  if not name then
    local info = self:GetEntry(record)
    name = record.title or (info and info.name)
  end
  if not name and record.itemID and NS.Systems.ItemResolver then
    local resolved = NS.Systems.ItemResolver:GetName(record.itemID)
    if resolved ~= "Loading..." and resolved ~= "Unknown Item" then name = resolved end
  end
  local normalized = Normalize(name)
  if normalized ~= "" then
    if record.storageKey and type(name) == "string" then record.title = name else searchNames[key] = normalized end
  end
  return normalized
end

function Housing:IsDyeable(record)
  if not record then return false end
  local key = record.decorID
  if key and dyeable[key] ~= nil then return dyeable[key] end
  local info = self:GetEntry(record)
  local value = record.dyeable == true or (info and info.canCustomize == true) or false
  if key then dyeable[key] = value end
  return value
end

function Housing:GetDyeableLabel(record)
  local class = self:GetClassRestriction(record)
  local canDye = self:IsDyeable(record)
  if canDye and class then return "Dyeable - " .. class end
  if canDye then return "Dyeable" end
  return class
end

function Housing:GetCatalogDyeableLabel(record)
  if record and record.displayDyeable ~= nil then return record.displayDyeable or nil end
  local class = self:GetClassRestriction(record)
  local value
  if record and record.dyeable == true and class then value = "Dyeable - " .. class
  elseif record and record.dyeable == true then value = "Dyeable"
  else value = class end
  if record then record.displayDyeable = value or false end
  return value
end

function Housing:GetClassRestriction(record)
  if not record then return nil end
  return record.classRestriction or vendorClasses[tonumber(record.sourceID)]
end

function Housing:Clear()
  wipe(displayCache)
  wipe(displayOrder)
  wipe(searchNames)
  wipe(dyeable)
  wipe(categoryNames)
  displayHead = 1
  displaySize = 0
  catalogEntryType = 1
  catalogDiscoveryAttempted = false
end

function Housing:InvalidateOwnership()
  for _, display in pairs(displayCache) do display.owned = nil end
end

function Housing:GetCacheSize()
  return displaySize
end
