local _, NS = ...

local Collection = { owned = {}, revision = 0, snapshotReady = false, loading = false, generation = 0, hasSnapshot = false }
NS.Systems.Collection = Collection

local itemOwnership = {}
local itemOrder = {}
local itemHead = 1
local itemSize = 0
local ITEM_CAPACITY = 256

local function Invoke(object, method, ...)
  local callback = object and object[method]
  if type(callback) ~= "function" then return false end
  return pcall(callback, object, ...)
end

local function PutItemOwnership(itemID, total, placed, stored)
  if itemOwnership[itemID] then
    itemOwnership[itemID].total = total
    itemOwnership[itemID].placed = placed
    itemOwnership[itemID].stored = stored
    return
  end
  if itemSize >= ITEM_CAPACITY then
    local expired = itemOrder[itemHead]
    itemOwnership[expired] = nil
    itemOrder[itemHead] = itemID
    itemHead = itemHead + 1
    if itemHead > ITEM_CAPACITY then itemHead = 1 end
  else
    itemSize = itemSize + 1
    itemOrder[itemSize] = itemID
  end
  itemOwnership[itemID] = { total = total, placed = placed, stored = stored }
end

function Collection:GetBreakdownByItem(itemID)
  itemID = tonumber(itemID)
  if not itemID then return nil end
  local cached = itemOwnership[itemID]
  if cached then return cached.total, cached.placed, cached.stored end
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogEntryInfoByItem
  if type(api) ~= "function" then return nil end
  local ok, info = pcall(api, itemID, true)
  if not ok or type(info) ~= "table" then
    ok, info = pcall(api, itemID)
  end
  if not ok or type(info) ~= "table" then return nil end
  local stored = (tonumber(info.totalNumStored or info.quantity) or 0) + (tonumber(info.remainingRedeemable) or 0)
  local placed = tonumber(info.totalNumPlaced or info.numPlaced) or 0
  local total = stored + placed
  if type(info.isOwned) == "boolean" and info.isOwned and total == 0 then total = 1 end
  if type(info.isCollected) == "boolean" and info.isCollected and total == 0 then total = 1 end
  PutItemOwnership(itemID, total, placed, stored)
  return total, placed, stored
end

function Collection:IsItemOwned(itemID)
  local total = self:GetBreakdownByItem(itemID)
  if total == nil then return nil end
  return total > 0
end

function Collection:ClearItemOwnership()
  wipe(itemOwnership)
  wipe(itemOrder)
  itemHead = 1
  itemSize = 0
end

function Collection:RequestSnapshot()
  if self.snapshotReady or self.loading then return self.snapshotReady end
  local api = _G.C_HousingCatalog and _G.C_HousingCatalog.CreateCatalogSearcher
  if type(api) ~= "function" then return false end
  local ok, searcher = pcall(api)
  if not ok or not searcher then return false end
  self.loading = true
  self.generation = self.generation + 1
  local generation = self.generation
  self.searcher = searcher
  Invoke(searcher, "SetAutoUpdateOnParamChanges", false)
  Invoke(searcher, "SetStoredOnly", false)
  Invoke(searcher, "SetBaseVariantOnly", true)
  local editorMode = _G.Enum and _G.Enum.HouseEditorMode and _G.Enum.HouseEditorMode.BasicDecor
  if editorMode then Invoke(searcher, "SetEditorModeContext", editorMode) end
  Invoke(searcher, "SetCustomizableOnly", false)
  Invoke(searcher, "SetAllowedIndoors", true)
  Invoke(searcher, "SetAllowedOutdoors", true)
  Invoke(searcher, "SetCollected", true)
  Invoke(searcher, "SetUncollected", false)
  Invoke(searcher, "SetFirstAcquisitionBonusOnly", false)
  local constants = _G.Constants and _G.Constants.HousingCatalogConsts
  Invoke(searcher, "SetFilteredCategoryID", constants and constants.HOUSING_CATALOG_ALL_CATEGORY_ID)
  Invoke(searcher, "SetFilteredSubcategoryID", nil)
  local tagGroups = _G.C_HousingCatalog and _G.C_HousingCatalog.GetAllFilterTagGroups
  if type(tagGroups) == "function" then
    local tagsOK, groups = pcall(tagGroups)
    if tagsOK and type(groups) == "table" then
      for _, group in ipairs(groups) do
        if group and group.groupID then Invoke(searcher, "SetAllInFilterTagGroup", group.groupID, true) end
      end
    end
  end
  Invoke(searcher, "SetDistinctPerRecordID", true)
  Invoke(searcher, "SetAutoUpdateOnParamChanges", true)
  self.resultVersion = 0
  self.retryCount = 0
  self.retryScheduled = false
  local function CommitResults()
    if generation ~= Collection.generation or not Collection.loading then return end
    local results
    local resultOK, value = Invoke(searcher, "GetCatalogSearchResults")
    if resultOK and type(value) == "table" then results = value end
    if not results or #results == 0 then
      if Collection.retryScheduled then return end
      Collection.retryCount = (Collection.retryCount or 0) + 1
      if Collection.retryCount <= 6 and _G.C_Timer and _G.C_Timer.After then
        Collection.retryScheduled = true
        _G.C_Timer.After(0.5, function()
          if generation ~= Collection.generation or not Collection.loading then return end
          Collection.retryScheduled = false
          Invoke(searcher, "RunSearch")
          _G.C_Timer.After(0.35, CommitResults)
        end)
        return
      end
      results = {}
    end
    local nextOwned = {}
    local decorType = _G.Enum and _G.Enum.HousingCatalogEntryType and _G.Enum.HousingCatalogEntryType.Decor or 1
    local isSecret = _G.issecretvalue
    for index = 1, #results do
      local entry = results[index]
      if type(entry) == "table" then
        local entryType = entry.entryType
        local recordID = entry.recordID
        local safe = not isSecret or (not isSecret(entryType) and not isSecret(recordID))
        if safe and type(entryType) == "number" and entryType == decorType and type(recordID) == "number" and recordID > 0 then
          nextOwned[recordID] = true
        end
      end
    end
    wipe(Collection.owned)
    for recordID in pairs(nextOwned) do Collection.owned[recordID] = true end
    Invoke(searcher, "SetResultsUpdatedCallback", nil)
    Collection.snapshotReady = true
    Collection.hasSnapshot = true
    Collection.loading = false
    Collection.retryScheduled = false
    Collection.searcher = nil
    Collection.revision = Collection.revision + 1
    NS.SendMessage("HOMEDECOR_COLLECTION_UPDATED")
  end
  local callbackSet = Invoke(searcher, "SetResultsUpdatedCallback", function()
    if generation ~= Collection.generation then return end
    Collection.resultVersion = (Collection.resultVersion or 0) + 1
    local version = Collection.resultVersion
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0.35, function()
        if generation == Collection.generation and version == Collection.resultVersion then CommitResults() end
      end)
    else
      CommitResults()
    end
  end)
  if not callbackSet then
    self.loading = false
    self.searcher = nil
    return false
  end
  local started = Invoke(searcher, "RunSearch")
  if not started then
    self.loading = false
    self.searcher = nil
    return false
  end
  return false
end

function Collection:GetOwned(record)
  local key = record and record.decorID
  if not key then return nil end
  key = tonumber(key)
  if not self.snapshotReady then
    self:RequestSnapshot()
    if self.hasSnapshot then return self.owned[key] == true end
    return nil
  end
  return self.owned[key] == true
end

function Collection:IsOwned(record)
  return self:GetOwned(record) == true
end

function Collection:Invalidate(decorID)
  if self.searcher then Invoke(self.searcher, "SetResultsUpdatedCallback", nil) end
  self.snapshotReady = false
  self.loading = false
  self.retryScheduled = false
  self.searcher = nil
  self.generation = self.generation + 1
  self.revision = self.revision + 1
  self:ClearItemOwnership()
end

function Collection:GetCacheSize()
  local count = 0
  for _ in pairs(self.owned) do count = count + 1 end
  return count
end
