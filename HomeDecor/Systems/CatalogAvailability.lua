local ADDON, NS = ...

NS.Systems = NS.Systems or {}

local Availability = {}
NS.Systems.CatalogAvailability = Availability

local cache = {}
local lastReadyState = false
local searchResultIDs = nil
local searchResultsReady = false
local InvalidateCatalogConsumers

local function HasCatalogAPI()
  return _G.C_HousingCatalog and _G.C_HousingCatalog.GetCatalogEntryInfoByRecordID
end

local function CatalogIsReady()
  local HB = NS.Systems and NS.Systems.HousingBootstrap
  return not HB or HB.ready == true
end

local QUESTION_MARK_ICON_IDS = {
  [134400] = true, 
}

local function IconLooksUsable(icon)
  local iconNum = tonumber(icon)
  if icon == nil or iconNum == nil or iconNum == 0 then return false end
  if QUESTION_MARK_ICON_IDS[iconNum] then return false end

  local TextureAPI = _G.C_Texture
  if TextureAPI and TextureAPI.GetFilenameFromFileDataID then
    local ok, filename = pcall(TextureAPI.GetFilenameFromFileDataID, iconNum)
    if ok and (filename == nil or filename == "") then return false end
  end

  return true
end

local function HasUsableCatalogInfo(info)
  if type(info) ~= "table" then return false end

  local name = info.name
  if type(name) ~= "string" or name == "" then return false end

  local icon = info.iconTexture or info.iconFileID or info.icon
  if not IconLooksUsable(icon) then return false end

  return true
end

local function QueryCatalog(decorID)
  if not HasCatalogAPI() then return nil end

  local api = _G.C_HousingCatalog.GetCatalogEntryInfoByRecordID
  local ok, info = pcall(api, 1, decorID, true)
  if ok and HasUsableCatalogInfo(info) then return true end

  ok, info = pcall(api, 1, decorID, false)
  if ok and HasUsableCatalogInfo(info) then return true end

  return false
end

local function ExtractDecorID(result)
  if type(result) == "number" then return tonumber(result) end
  if type(result) ~= "table" then return nil end

  return tonumber(result.decorID or result.decorId or result.recordID or result.recordId
    or result.entryID or result.entryId or result.id)
end

local function AddSearchResult(ids, result)
  local decorID = ExtractDecorID(result)
  if not decorID then return 0 end
  ids[decorID] = true
  return 1
end

local function AddSearchResultTable(ids, results)
  if type(results) ~= "table" then return 0 end

  local added = 0
  for _, result in ipairs(results) do
    added = added + AddSearchResult(ids, result)
  end
  for key, result in pairs(results) do
    if type(key) ~= "number" then
      added = added + AddSearchResult(ids, result)
    end
  end
  return added
end

local function TrySearchResultTables(searcher, ids)
  local added = 0
  for _, methodName in ipairs({ "GetResults", "GetSearchResults", "GetResultList" }) do
    local method = searcher and searcher[methodName]
    if type(method) == "function" then
      local ok, results = pcall(method, searcher)
      if ok then
        added = added + AddSearchResultTable(ids, results)
      end
    end
  end

  added = added + AddSearchResultTable(ids, searcher and searcher.results)
  added = added + AddSearchResultTable(ids, searcher and searcher.searchResults)
  return added
end

local function TryIndexedSearchResults(searcher, ids)
  local count
  for _, methodName in ipairs({ "GetNumResults", "GetResultCount", "GetNumSearchResults" }) do
    local method = searcher and searcher[methodName]
    if type(method) == "function" then
      local ok, value = pcall(method, searcher)
      value = ok and tonumber(value)
      if value and value > 0 then
        count = value
        break
      end
    end
  end
  if not count then return 0 end

  local added = 0
  for _, methodName in ipairs({ "GetResult", "GetSearchResult", "GetResultAtIndex" }) do
    local method = searcher and searcher[methodName]
    if type(method) == "function" then
      for i = 1, count do
        local ok, result = pcall(method, searcher, i)
        if ok then added = added + AddSearchResult(ids, result) end
      end
      for i = 0, count - 1 do
        local ok, result = pcall(method, searcher, i)
        if ok then added = added + AddSearchResult(ids, result) end
      end
    end
  end

  return added
end

local function BuildSearchResultSet(searcher)
  if not searcher then return nil end

  local ids = {}
  local added = TrySearchResultTables(searcher, ids) + TryIndexedSearchResults(searcher, ids)
  if added <= 0 then return nil end
  return ids
end

function Availability:OnCatalogSearchReady(searcher)
  local ids = BuildSearchResultSet(searcher)
  if ids then
    searchResultIDs = ids
    searchResultsReady = true
  end
  self:ClearCache()
  InvalidateCatalogConsumers()
end

function Availability:IsDecorAvailable(decorID)
  decorID = tonumber(decorID)
  if not decorID then return true end

  if not HasCatalogAPI() then
    return true
  end

  if searchResultsReady and searchResultIDs then
    return searchResultIDs[decorID] == true
  end

  local cached = cache[decorID]
  if cached ~= nil then return cached end

  cached = QueryCatalog(decorID)
  cache[decorID] = cached
  return cached
end

function Availability:ShouldShowItem(it)
  if type(it) ~= "table" then return true end
  return self:IsDecorAvailable(it.decorID)
end

function Availability:ClearCache()
  wipe(cache)
end

function InvalidateCatalogConsumers()
  local Systems = NS.Systems or {}
  if Systems.DecorIndex and Systems.DecorIndex.Invalidate then
    Systems.DecorIndex:Invalidate(false)
  end
  if Systems.GlobalIndex and Systems.GlobalIndex.Invalidate then
    Systems.GlobalIndex:Invalidate(false)
  end

  local View = NS.UI and NS.UI.Viewer
  if View then
    View._renderDataEpoch = (View._renderDataEpoch or 0) + 1
    if View.instance and View.instance.RequestRender then
      View.instance:RequestRender(true)
    end
  end
  if NS.UI and NS.UI.Layout and NS.UI.Layout.Render then
    NS.UI.Layout:Render()
  end

  local MapPopupUtil = NS.UI and NS.UI.MapPopupUtil
  if MapPopupUtil and MapPopupUtil.InvalidateVendorItemsCache then
    MapPopupUtil:InvalidateVendorItemsCache()
  end

  local MapTracker = Systems.MapTracker
  if MapTracker and MapTracker.ClearCaches then
    MapTracker:ClearCaches()
    if MapTracker.QueueUpdate then MapTracker:QueueUpdate(0.1, true) end
  end

  local MapPinsData = Systems.MapPinsData
  if MapPinsData and MapPinsData.Invalidate then
    MapPinsData:Invalidate()
  end

  local MapPins = Systems.MapPins
  if MapPins then
    if MapPins.RefreshCurrentZone then MapPins:RefreshCurrentZone() end
    if MapPins.RefreshWorldMap then MapPins:RefreshWorldMap() end
  end
end

local function CheckReady()
  local ready = CatalogIsReady()
  if ready and not lastReadyState then
    lastReadyState = true
    Availability:ClearCache()
    InvalidateCatalogConsumers()
  elseif not ready then
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0.5, CheckReady)
    end
  end
end

NS.RegisterEvent(Availability, "PLAYER_ENTERING_WORLD", function()
  Availability:ClearCache()
  lastReadyState = CatalogIsReady()
  CheckReady()
end)

NS.RegisterEvent(Availability, "PLAYER_LOGIN", function()
  CheckReady()
end)

return Availability
