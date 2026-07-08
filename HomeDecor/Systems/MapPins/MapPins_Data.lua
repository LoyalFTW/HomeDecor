local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local MapPins = NS.Systems.MapPins or {}
NS.Systems.MapPins = MapPins
local L = NS.L

local D = NS.Systems.MapPinsData or {}
NS.Systems.MapPinsData = D
MapPins.Data = D

local pairs = pairs
local tonumber = tonumber
local pcall = pcall
local strtrim = strtrim
local type = type
local wipe = wipe or function(t) for k in pairs(t) do t[k] = nil end end
local C_Map = C_Map
local NPCNames = NS.Systems and NS.Systems.NPCNames
local U = NS.Systems.MapPinsUtil

local function CleanText(text)
  if type(text) ~= "string" then return nil end

  local ok, cleaned = pcall(function(value)
    if strtrim then
      value = strtrim(value)
    else
      value = value:gsub("^%s+", ""):gsub("%s+$", "")
    end
    if value == "" then return nil end
    return value
  end, text)

  if not ok then return nil end
  return cleaned
end

local function IsDecorAvailable(item)
  local Availability = NS.Systems and NS.Systems.CatalogAvailability
  return not Availability or not Availability.ShouldShowItem or Availability:ShouldShowItem(item)
end

local function VendorHasVisibleItems(vendor)
  if type(vendor) ~= "table" or type(vendor.items) ~= "table" then return false end
  for itemIndex = 1, #vendor.items do
    if IsDecorAvailable(vendor.items[itemIndex]) then
      return true
    end
  end
  return false
end

local function FindVendorByID(vendorID)
  vendorID = tonumber(vendorID)
  if not vendorID then return nil end
  local Vendors = NS.Data and NS.Data.Vendors
  if type(Vendors) ~= "table" then return nil end
  for _, regions in pairs(Vendors) do
    if type(regions) == "table" then
      for _, vendorList in pairs(regions) do
        if type(vendorList) == "table" then
          for vendorIndex = 1, #vendorList do
            local vendor = vendorList[vendorIndex]
            local source = vendor and vendor.source
            local id = tonumber(source and (source.id or source.npcID or source.npcId) or vendor.npcID or vendor.id)
            if id == vendorID then
              return vendor
            end
          end
        end
      end
    end
  end
end

D.mapIndex = D.mapIndex or {}
D.zoneToContinent = D.zoneToContinent or {}
D.SPECIAL_ZONES = { [2352] = true, [2351] = true }
D.CONTINENT_IDS = {
  [619] = true, [875] = true, [876] = true, [1978] = true, [2274] = true,
  [13] = true, [12] = true, [101] = true, [113] = true, [948] = true,
  [905] = true, [424] = true, [572] = true, [2537] = true,
}

D.continentZoneBadgesOnParent = {
  [2537] = 13,
}

D.continentZoneBadgeExclusionsOnParent = {
  [2537] = {
    [13] = {
      [2405] = true,
      [15958] = true,
      [2444] = true,
      [2694] = true,
      [2576] = true,
      [2413] = true,
    },
  },
}

local function AddCompactEntries(targetIndex, entries, allowMissingVendor)
  if type(entries) ~= "table" then return end
  for entryIndex = 1, #entries do
    local entry = entries[entryIndex]
    local mapID = tonumber(entry and entry.mapID)
    local vendorID = tonumber(entry and entry.id)
    if mapID and vendorID and entry.x and entry.y then
      local vendor = FindVendorByID(vendorID)
      if vendor then
        if not VendorHasVisibleItems(vendor) then
          vendorID = nil
        end
      elseif not allowMissingVendor then
        vendorID = nil
      end
    end
    if mapID and vendorID and entry.x and entry.y then
      local vendorList = targetIndex[mapID]
      if not vendorList then
        vendorList = {}
        targetIndex[mapID] = vendorList
      end
      vendorList[#vendorList + 1] = {
        id = vendorID,
        mapID = mapID,
        x = entry.x,
        y = entry.y,
        zone = entry.zone,
        faction = entry.faction,
        isEvent = entry.isEvent or nil,
        eventRef = entry.eventRef or nil,
      }
    end
  end
end

local function BuildIndexFromCompactData()
  local DataLoader = NS.Systems and NS.Systems.DataLoader
  if DataLoader and DataLoader.EnsureVendors then
    pcall(function() DataLoader:EnsureVendors() end)
  end

  local compactIndex = NS.Data and NS.Data.MapPinVendors
  if type(compactIndex) ~= "table" then
    return false
  end

  for mapID, entries in pairs(compactIndex) do
    local numericMapID = tonumber(mapID)
    if numericMapID then
      AddCompactEntries(D.mapIndex, entries, false)
    end
  end

  local compactEvents = NS.Data and NS.Data.MapPinEvents
  if type(compactEvents) == "table" then
    for mapID, entries in pairs(compactEvents) do
      local numericMapID = tonumber(mapID)
      if numericMapID then
        AddCompactEntries(D.mapIndex, entries, true)
      end
    end
  end

  return true
end

local function BuildIndexFromLoadedCatalog()
  local Vendors = NS.Data and NS.Data.Vendors
  if type(Vendors) ~= "table" then return end

  local parseWorldmap = U and U.ParseWorldmap
  if not parseWorldmap then return end

  local seenVendorsByMap = {}

  local function indexVendorList(vendorList, isEvent, eventRef)
    if type(vendorList) ~= "table" then return end
    for vendorIndex = 1, #vendorList do
      local vendor = vendorList[vendorIndex]
      local source = vendor and vendor.source
      local id = source and source.id
      local zone = source and source.zone
      local faction = source and source.faction
      local mapID, x, y = parseWorldmap(source and source.worldmap)
      if mapID and id and VendorHasVisibleItems(vendor) then
        local seenInMap = seenVendorsByMap[mapID]
        if not seenInMap then
          seenInMap = {}
          seenVendorsByMap[mapID] = seenInMap
        end
        local vendorID = tonumber(id)
        if not seenInMap[vendorID] then
          seenInMap[vendorID] = true
          local mapVendors = D.mapIndex[mapID]
          if not mapVendors then mapVendors = {}; D.mapIndex[mapID] = mapVendors end
          mapVendors[#mapVendors + 1] = {
            id = vendorID, mapID = mapID, x = x, y = y,
            zone = zone, faction = faction,
            isEvent = isEvent or nil,
            eventRef = eventRef or nil,
          }
        end
      end
    end
  end

  for regionKey, regions in pairs(Vendors) do
    if type(regions) == "table" then
      for listKey, vendorList in pairs(regions) do
        indexVendorList(vendorList, false, nil)
      end
    end
  end

  local Events = NS.Data and NS.Data.Events
  if type(Events) == "table" then
    for groupKey, eventGroup in pairs(Events) do
      if type(eventGroup) == "table" then
        for _, ev in pairs(eventGroup) do
          if type(ev) == "table" then
            local source = ev.source
            local id = source and source.id
            local zone = source and source.zone
            local faction = source and source.faction
            local mapID, x, y = parseWorldmap(source and source.worldmap)
            if mapID and id then
              local seenInMap = seenVendorsByMap[mapID]
              if not seenInMap then
                seenInMap = {}
                seenVendorsByMap[mapID] = seenInMap
              end
              local vendorID = tonumber(id)
              if not seenInMap[vendorID] then
                seenInMap[vendorID] = true
                local mapVendors = D.mapIndex[mapID]
                if not mapVendors then mapVendors = {}; D.mapIndex[mapID] = mapVendors end
                mapVendors[#mapVendors + 1] = {
                  id = vendorID, mapID = mapID, x = x, y = y,
                  zone = zone, faction = faction,
                  isEvent = true,
                  eventRef = ev,
                }
              end
            end
          end
        end
      end
    end
  end
end

local function ResolveContinentForMap(mapID)
  if not (C_Map and C_Map.GetMapInfo) then
    return nil
  end

  local currentMapID = mapID
  for iterCount = 1, 10 do
    local info = C_Map.GetMapInfo(currentMapID)
    if not info then break end
    if info.parentMapID and D.CONTINENT_IDS[info.parentMapID] then
      return info.parentMapID
    end
    if D.SPECIAL_ZONES[mapID] or not info.parentMapID or info.parentMapID == 0 or info.parentMapID == currentMapID then
      break
    end
    currentMapID = info.parentMapID
  end

  return nil
end

function D.BuildIndex()
  wipe(D.mapIndex)
  wipe(D.zoneToContinent)
  D.worldIndexBuilt = false

  if BuildIndexFromCompactData() then
    return
  end

  BuildIndexFromLoadedCatalog()
end

function D.EnsureBaseIndex()
  if next(D.mapIndex) == nil then
    D.BuildIndex()
  end
end

function D.EnsureWorldIndex()
  D.EnsureBaseIndex()
  if D.worldIndexBuilt then return end
  if C_Map and C_Map.GetMapInfo then
    for mapID in pairs(D.mapIndex) do
      if D.zoneToContinent[mapID] == nil then
        D.zoneToContinent[mapID] = ResolveContinentForMap(mapID) or false
      end
    end
  end
  D.worldIndexBuilt = true
end

function D.GetVendorsForMap(mapID)
  mapID = tonumber(mapID)
  if not mapID then return nil end
  D.EnsureBaseIndex()
  return D.mapIndex[mapID]
end

function D.GetZoneCenterOnMap(zoneMapID, parentMapID)
  if not C_Map or not C_Map.GetMapRectOnMap then return nil end
  local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(zoneMapID, parentMapID)
  if minX and maxX and minY and maxY then
    return { x = (minX + maxX) / 2, y = (minY + maxY) / 2 }
  end
  return nil
end

function D.CountVendorsInZone(zoneMapID)
  local list = D.GetVendorsForMap(zoneMapID)
  return list and #list or 0
end

function D.ResolveNamesFor(vendorList)
  if not vendorList then return end
  if NPCNames and NPCNames.PrefetchMany then
    local ids = {}
    for vendorIndex = 1, #vendorList do
      local vendor = vendorList[vendorIndex]
      if vendor and vendor.id then
        ids[#ids + 1] = vendor.id
      end
    end
    if #ids > 0 then
      NPCNames.PrefetchMany(ids)
    end
  end
  for vendorIndex = 1, #vendorList do
    local vendor = vendorList[vendorIndex]
    if vendor then
      local name = CleanText(vendor.name)
      if not name and NPCNames and NPCNames.Get then
        name = CleanText(NPCNames.Get(vendor.id))
      end
      if not name then
        name = (L["VENDOR_PREFIX"] or "Vendor ") .. tostring(vendor.id or "")
      end
      vendor.name = name
    end
  end
end

return D
