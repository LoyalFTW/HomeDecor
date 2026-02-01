local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local Collection = NS.Systems.Collection or {}
NS.Systems.Collection = Collection

Collection.State = Collection.State or {
  COLLECTED = "COLLECTED",
  NOT_COLLECTED = "NOT_COLLECTED",
}

local cache = Collection._decorCache or {}
Collection._decorCache = cache

local listeners = Collection._listeners or {}
Collection._listeners = listeners

local function Fire(decorID)
  for i = 1, #listeners do
    local fn = listeners[i]
    if fn then
      local ok, err = pcall(fn, decorID)
      if not ok then end
    end
  end
end

function Collection:RegisterListener(fn)
  if type(fn) ~= "function" then return end
  listeners[#listeners + 1] = fn
end

function Collection:ClearCache(decorID)
  if decorID then
    cache[decorID] = nil
    Fire(decorID)
    return
  end
  if wipe then
    wipe(cache)
  else
    for k in pairs(cache) do cache[k] = nil end
  end
  Fire(-1)
end

local function ReadOwned(info)
  if not info then return nil end

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

  if type(info.firstAcquisitionBonus) == "number" and info.firstAcquisitionBonus >= 0 then
    return info.firstAcquisitionBonus == 0
  end

  return nil
end

local function IsOwnedViaCatalog(decorID)
  if not decorID then return nil end
  if not C_HousingCatalog or not C_HousingCatalog.GetCatalogEntryInfoByRecordID then return nil end

  local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
  return ReadOwned(info)
end

function Collection:IsDecorCollected(decorID)
  if not decorID then return false end

  local v = cache[decorID]
  if v ~= nil then return v and true or false end

  local owned = IsOwnedViaCatalog(decorID)
  if owned ~= nil then
    cache[decorID] = owned and true or false
    return cache[decorID]
  end

  cache[decorID] = false
  return false
end

function Collection:IsCollected(it)
  if not it then return false end

  local decorID = it.decorID
  if decorID then
    return self:IsDecorCollected(decorID)
  end

  local src = it.source or {}
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
  if self:IsCollected(it) then
    return Collection.State.COLLECTED
  end
  return Collection.State.NOT_COLLECTED
end

local function EnsureEvents()
  if Collection._eventFrame then return end

  local f = CreateFrame("Frame")
  Collection._eventFrame = f

  if f.RegisterEvent then
    f:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
  end

  f:SetScript("OnEvent", function(_, event, decorID)
    if event == "HOUSE_DECOR_ADDED_TO_CHEST" then
      if decorID then
        cache[decorID] = nil
        Fire(decorID)
      else
        if wipe then wipe(cache) else for k in pairs(cache) do cache[k] = nil end end
        Fire(-1)
      end
      return
    end

    if event == "PLAYER_ENTERING_WORLD" then
      if wipe then wipe(cache) else for k in pairs(cache) do cache[k] = nil end end
      Fire(-1)
      return
    end
  end)
end

EnsureEvents()

return Collection
