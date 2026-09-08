local _, NS = ...

NS.UI = NS.UI or {}
local TrackerData = {}
NS.UI.TrackerData = TrackerData

local validTabs = { area = true, favorites = true, lists = true, blueprints = true }

function TrackerData:GetTab()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return "area" end
  if profile.ui.trackerAreaDefaultApplied ~= true then
    profile.ui.trackerTab = "area"
    profile.ui.trackerAreaDefaultApplied = true
  end
  return validTabs[profile.ui.trackerTab] and profile.ui.trackerTab or "area"
end

function TrackerData:SetTab(tab)
  local profile = NS.Systems.Database:GetProfile()
  if not profile or not validTabs[tab] then return false end
  profile.ui.trackerTab = tab
  return true
end

function TrackerData:GetCurrentArea()
  local mapID
  if C_Map and C_Map.GetBestMapForUnit then
    local ok, value = pcall(C_Map.GetBestMapForUnit, "player")
    if ok then mapID = tonumber(value) end
  end
  local maps = {}
  local name = GetRealZoneText and GetRealZoneText() or ""
  local current = mapID
  for _ = 1, 8 do
    if not current or maps[current] then break end
    maps[current] = true
    if not C_Map or not C_Map.GetMapInfo then break end
    local ok, info = pcall(C_Map.GetMapInfo, current)
    if not ok or type(info) ~= "table" then break end
    if current == mapID and type(info.name) == "string" and info.name ~= "" then name = info.name end
    local parent = tonumber(info.parentMapID)
    if not parent then break end
    local parentOK, parentInfo = pcall(C_Map.GetMapInfo, parent)
    if not parentOK or type(parentInfo) ~= "table" then break end
    local continent = Enum and Enum.UIMapType and Enum.UIMapType.Continent
    if continent and parentInfo.mapType == continent then break end
    current = parent
  end
  if type(name) ~= "string" or name == "" then name = "Current Area" end
  return name, mapID, maps
end

function TrackerData:GetAreaKey(record)
  local sourceID = tonumber(record and record.sourceID)
  if record and record.sourceType == "vendor" then return "vendor:" .. tostring(sourceID or record.vendorName or "unknown") end
  return "source:" .. tostring(record and record.sourceType or "other") .. ":" .. tostring(sourceID or "")
end

function TrackerData:IsComplete(record, tab)
  if tab == "lists" then
    return false
  end
  if tab == "blueprints" then
    local needed = math.max(1, tonumber(record and record.needed) or 1)
    local have = math.max(0, tonumber(record and record.have) or 0)
    if record and record.itemID and C_Item and C_Item.GetItemCount then
      local ok, count = pcall(C_Item.GetItemCount, record.itemID, true, false, true, true)
      if ok and tonumber(count) then have = math.max(0, tonumber(count)) end
    end
    return have >= needed
  end
  return NS.Systems.Collection:IsOwned(record)
end

return TrackerData
