local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local Collection = NS.Systems.Collection or {}
NS.Systems.Collection = Collection

Collection.State = Collection.State or {
  COLLECTED = "COLLECTED",
  NOT_COLLECTED = "NOT_COLLECTED",
}

local cacheDecor = Collection._decorCache or {}
Collection._decorCache = cacheDecor

local cacheItem = Collection._itemCache or {}
Collection._itemCache = cacheItem

local listeners = Collection._listeners or {}
Collection._listeners = listeners

local function Fire(id)
  for i = 1, #listeners do
    local fn = listeners[i]
    if fn then pcall(fn, id) end
  end
end

function Collection:RegisterListener(fn)
  if type(fn) ~= "function" then return end
  listeners[#listeners + 1] = fn
end

local function wipeTable(t)
  if wipe then
    wipe(t)
  else
    for k in pairs(t) do t[k] = nil end
  end
end

function Collection:ClearCache(id)
  if id then
    cacheDecor[id] = nil
    cacheItem[id] = nil
    Fire(id)
    return
  end
  wipeTable(cacheDecor)
  wipeTable(cacheItem)
  Fire(-1)
end

local function TotalOwnedFromInfo(info)
  if type(info) ~= "table" then return nil end
  local qty = info.quantity
  local redeem = info.remainingRedeemable
  local placed = info.numPlaced
  if type(qty) ~= "number" then qty = 0 end
  if type(redeem) ~= "number" then redeem = 0 end
  if type(placed) ~= "number" then placed = 0 end
  return qty + redeem + placed
end

local function IsOwnedViaItem(itemID)
  if not itemID then return nil end
  if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByItem) then return nil end
  local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByItem, itemID, true)
  if not ok or not info then return nil end
  local total = TotalOwnedFromInfo(info)
  if total == nil then return nil end
  return total > 0
end

local function IsOwnedViaRecord(decorID)
  if not decorID then return nil end
  if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then return nil end
  local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByRecordID, 1, decorID, true)
  if not ok or not info then return nil end
  local total = TotalOwnedFromInfo(info)
  if total ~= nil then return total > 0 end

  if type(info.isOwned) == "boolean" then return info.isOwned end
  if type(info.isCollected) == "boolean" then return info.isCollected end
  if type(info.owned) == "boolean" then return info.owned end

  local ownedInfo = info.ownedInfo or info.ownedData or info.ownedStatus
  if type(ownedInfo) == "table" then
    if type(ownedInfo.isOwned) == "boolean" then return ownedInfo.isOwned end
    if type(ownedInfo.isCollected) == "boolean" then return ownedInfo.isCollected end
    if type(ownedInfo.owned) == "boolean" then return ownedInfo.owned end
    if type(ownedInfo.count) == "number" then return ownedInfo.count > 0 end
    if type(ownedInfo.ownedCount) == "number" then return ownedInfo.ownedCount > 0 end
  end

  if type(info.ownedCount) == "number" then return info.ownedCount > 0 end
  if type(info.countOwned) == "number" then return info.countOwned > 0 end

  return nil
end

function Collection:IsItemCollected(itemID)
  if not itemID then return false end

  local v = cacheItem[itemID]
  if v ~= nil then return v and true or false end

  local owned = IsOwnedViaItem(itemID)
  if owned == nil then return false end

  cacheItem[itemID] = owned and true or false
  return cacheItem[itemID]
end

function Collection:IsDecorCollected(decorID)
  if not decorID then return false end

  local v = cacheDecor[decorID]
  if v ~= nil then return v and true or false end

  local owned = IsOwnedViaRecord(decorID)
  if owned == nil then return false end

  cacheDecor[decorID] = owned and true or false
  return cacheDecor[decorID]
end

function Collection:IsCollected(it)
  if not it then return false end

  local src = it.source or {}
  local itemID = src.itemID
  if itemID then
    return self:IsItemCollected(itemID)
  end

  local decorID = it.decorID
  if decorID then
    return self:IsDecorCollected(decorID)
  end

  local st = src.type

  if st == "achievement" and src.id and GetAchievementInfo then
    local ok = select(4, GetAchievementInfo(src.id))
    return ok and true or false
  end

  if st == "quest" and src.id and C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
    return C_QuestLog.IsQuestFlaggedCompleted(src.id) and true or false
  end

  return false
end

function Collection:GetState(it)
  return self:IsCollected(it) and Collection.State.COLLECTED or Collection.State.NOT_COLLECTED
end

local function EnsureEvents()
  if Collection._eventFrame then return end

  local f = CreateFrame("Frame")
  Collection._eventFrame = f

  f:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:RegisterEvent("HOUSING_STORAGE_UPDATED")
  f:RegisterEvent("HOUSING_STORAGE_ENTRY_UPDATED")

  f:SetScript("OnEvent", function(_, event, id)
    if event == "HOUSE_DECOR_ADDED_TO_CHEST" then
      if id then
        cacheDecor[id] = nil
        cacheItem[id] = nil
        Fire(id)
      else
        wipeTable(cacheDecor)
        wipeTable(cacheItem)
        Fire(-1)
      end
      return
    end

    wipeTable(cacheDecor)
    wipeTable(cacheItem)
    Fire(-1)
  end)
end

EnsureEvents()

return Collection
