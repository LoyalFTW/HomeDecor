local ADDON, NS = ...

NS.Systems = NS.Systems or {}

local Availability = {}
NS.Systems.CatalogAvailability = Availability

local cache = {}
local lastReadyState = false

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

local function HasUsableCatalogInfo(info)
  if type(info) ~= "table" then return false end

  local name = info.name
  if type(name) ~= "string" or name == "" then return false end

  local icon = info.iconTexture or info.iconFileID or info.icon
  local iconNum = tonumber(icon)
  if icon == nil or iconNum == nil or iconNum == 0 then return false end
  if QUESTION_MARK_ICON_IDS[iconNum] then return false end

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

function Availability:IsDecorAvailable(decorID)
  decorID = tonumber(decorID)
  if not decorID then return true end

  if not HasCatalogAPI() or not CatalogIsReady() then
    return true
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

local function InvalidateCatalogConsumers()
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

  local MapPinsData = Systems.MapPinsData
  if MapPinsData and MapPinsData.mapIndex then
    wipe(MapPinsData.mapIndex)
  end
  if MapPinsData and MapPinsData.zoneToContinent then
    wipe(MapPinsData.zoneToContinent)
  end
  if MapPinsData then
    MapPinsData.worldIndexBuilt = false
  end
  local MapPins = Systems.MapPins
  if MapPins then
    if MapPins.RefreshCurrentZone then MapPins:RefreshCurrentZone() end
    if MapPins.RefreshWorldMap then MapPins:RefreshWorldMap() end
  end

  local MapPopupUtil = NS.UI and NS.UI.MapPopupUtil
  if MapPopupUtil and MapPopupUtil.InvalidateVendorItemsCache then
    MapPopupUtil:InvalidateVendorItemsCache()
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
