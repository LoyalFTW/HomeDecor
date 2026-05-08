local ADDON, NS = ...

NS.UI = NS.UI or {}

local MapPopup = NS.UI.MapPopup or {}
NS.UI.MapPopup = MapPopup
local L = NS.L

local Util = NS.UI.MapPopupUtil or {}
NS.UI.MapPopupUtil = Util
MapPopup.Util = Util

local C_Item = _G.C_Item
local GetItemInfo = _G.GetItemInfo
local DataLoader = NS.Systems and NS.Systems.DataLoader
local NPCNames = NS.Systems and NS.Systems.NPCNames

local vendorItemsCache = Util._vendorItemsCache or {}
Util._vendorItemsCache = vendorItemsCache
Util._vendorItemsCacheBuilt = Util._vendorItemsCacheBuilt or false

function Util.Clamp(value, min, max)
  if value < min then return min end
  if value > max then return max end
  return value
end

function Util.GetItemData(itemID)
  if not itemID then return nil end

  local name, link, quality, _, _, _, _, _, _, icon = GetItemInfo(itemID)
  if not name then
    C_Item.RequestLoadItemDataByID(itemID)
    return nil
  end

  return {
    id = itemID,
    name = name,
    link = link,
    quality = quality,
    icon = icon
  }
end

function Util.GetQualityColor(quality)
  if not quality then return 1, 1, 1 end

  local color = _G.ITEM_QUALITY_COLORS[quality]
  return color and color.r or 1, color and color.g or 1, color and color.b or 1
end

function Util.IsCollected(decorID)
  if not decorID then return false end

  local Collection = NS.Systems and NS.Systems.Collection
  if not Collection or not Collection.IsCollected then return false end

  local itemObj = { decorID = decorID }
  return Collection:IsCollected(itemObj) or false
end

function Util.GetVendorName(vendorID)
  if not vendorID then return L["VENDOR"] end

  if NPCNames and NPCNames.Get then
    return NPCNames.Get(vendorID) or ("Vendor #" .. vendorID)
  end

  return "Vendor #" .. vendorID
end

local function BuildVendorItemsCache()
  if Util._vendorItemsCacheBuilt then
    return
  end

  if DataLoader and DataLoader.EnsureVendors then
    DataLoader:EnsureVendors()
  end
  if DataLoader and DataLoader.EnsureEvents then
    DataLoader:EnsureEvents()
  end

  local function extractFromList(vendorList)
    if type(vendorList) ~= "table" then return end
    for vendorIndex = 1, #vendorList do
      local vendor = vendorList[vendorIndex]
      local source = vendor and vendor.source
      local vendorID = tonumber(source and source.id)
      if vendorID and type(vendor.items) == "table" then
        local items = vendorItemsCache[vendorID]
        local seenItemIDs = {}
        if not items then
          items = {}
          vendorItemsCache[vendorID] = items
        else
          for itemIndex = 1, #items do
            local cachedItem = items[itemIndex]
            if cachedItem and cachedItem.itemID then
              seenItemIDs[cachedItem.itemID] = true
            end
          end
        end

        for itemIndex = 1, #vendor.items do
          local item = vendor.items[itemIndex]
          if item and item.source and item.source.itemID then
            local itemID = tonumber(item.source.itemID)
            if itemID and not seenItemIDs[itemID] then
              seenItemIDs[itemID] = true
              items[#items + 1] = {
                itemID = itemID,
                decorID = item.decorID,
                title = item.title,
                source = item.source or {},
                requirements = item.requirements,
                navVendor = vendor,
              }
            end
          end
        end
      end
    end
  end

  local Vendors = NS.Data and NS.Data.Vendors
  if type(Vendors) == "table" then
    for _, regions in pairs(Vendors) do
      if type(regions) == "table" then
        for _, vendorList in pairs(regions) do
          extractFromList(vendorList)
        end
      end
    end
  end

  local Events = NS.Data and NS.Data.Events
  if type(Events) == "table" then
    for _, eventGroup in pairs(Events) do
      if type(eventGroup) == "table" then
        for _, ev in pairs(eventGroup) do
          if type(ev) == "table" then
            extractFromList({ ev })
          end
        end
      end
    end
  end

  Util._vendorItemsCacheBuilt = true
end

function Util.GetVendorItems(vendorID)
  if not vendorID then return {} end
  BuildVendorItemsCache()
  return vendorItemsCache[tonumber(vendorID)] or {}
end

function Util.ClearVendorItemsCache()
  for key in pairs(vendorItemsCache) do
    vendorItemsCache[key] = nil
  end
  Util._vendorItemsCacheBuilt = false
end

function Util.VendorKey(vendorID)
  return "vendor:" .. tostring(vendorID)
end

return Util
