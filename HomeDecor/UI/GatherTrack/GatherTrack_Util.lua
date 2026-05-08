local ADDON, NS = ...

NS.GT = NS.GT or {}
NS.GT.Utils = {}
local Utils = NS.GT.Utils

local unpack = _G.unpack or table.unpack
local math_floor = math.floor
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower

local ITEM_CLASS_TRADEGOODS = (Enum and Enum.ItemClass and Enum.ItemClass.Tradegoods) or 7
local ITEM_SUBCLASS_METAL_STONE = (Enum and Enum.ItemTradegoodsSubclass and Enum.ItemTradegoodsSubclass.MetalAndStone) or 7
local ITEM_SUBCLASS_HERB = (Enum and Enum.ItemTradegoodsSubclass and Enum.ItemTradegoodsSubclass.Herb) or 9
local KNOWN_LUMBER_IDS = {
  [242691] = true, -- Olemba
  [245586] = true, -- Ironwood
  [248012] = true, -- Dornic Fir
  [251762] = true, -- Coldwind
  [251763] = true, -- Bamboo
  [251764] = true, -- Ashwood
  [251766] = true, -- Shadowmoon
  [251767] = true, -- Fel-Touched
  [251768] = true, -- Darkpine
  [251772] = true, -- Arden
  [251773] = true, -- Dragonpine
  [256963] = true, -- Thalassian
}
local KNOWN_LUMBER_NAMES = {
  [242691] = "Olemba",
  [245586] = "Ironwood",
  [248012] = "Dornic Fir",
  [251762] = "Coldwind",
  [251763] = "Bamboo",
  [251764] = "Ashwood",
  [251766] = "Shadowmoon",
  [251767] = "Fel-Touched",
  [251768] = "Darkpine",
  [251772] = "Arden",
  [251773] = "Dragonpine",
  [256963] = "Thalassian",
}

function Utils.GetTheme()
  return NS.UI and NS.UI.Theme and NS.UI.Theme.colors or {}
end

function Utils.CreateBackdrop(frame, bgColor, borderColor)
  if not frame then return end
  frame:SetBackdrop({
    bgFile = "Interface/Buttons/WHITE8x8",
    edgeFile = "Interface/Buttons/WHITE8x8",
    edgeSize = 1,
  })
  if bgColor then frame:SetBackdropColor(unpack(bgColor)) end
  if borderColor then frame:SetBackdropBorderColor(unpack(borderColor)) end
end

function Utils.Clamp(value, min, max)
  value = tonumber(value) or min
  if value < min then return min end
  if value > max then return max end
  return value
end

function Utils.SafeLower(str)
  return type(str) == "string" and string_lower(str) or ""
end

function Utils.IsLumberName(name)
  local lowerName = Utils.SafeLower(name)
  if lowerName == "" then return false end
  return lowerName:find("lumber", 1, true)
      or lowerName:find("timber", 1, true)
      or lowerName:find("plank", 1, true)
end

function Utils.GetKnownLumberIDs()
  return KNOWN_LUMBER_IDS
end

function Utils.SeedKnownLumberIDs(target)
  if type(target) ~= "table" then return target end
  for itemID in pairs(KNOWN_LUMBER_IDS) do
    target[itemID] = true
  end
  return target
end

function Utils.IsKnownLumberID(itemID)
  return itemID and KNOWN_LUMBER_IDS[itemID] or false
end

function Utils.GetKnownLumberName(itemID)
  return itemID and KNOWN_LUMBER_NAMES[itemID] or nil
end

function Utils.GetTrackedGatheringKind(name, classID, subclassID, itemID)
  if Utils.IsKnownLumberID(itemID) then
    return "lumber"
  end
  if Utils.IsLumberName(name) then
    return "lumber"
  end

  if classID == ITEM_CLASS_TRADEGOODS then
    if subclassID == ITEM_SUBCLASS_METAL_STONE then
      return "ore"
    end
    if subclassID == ITEM_SUBCLASS_HERB then
      return "herb"
    end
  end

  local lowerName = Utils.SafeLower(name)
  if lowerName == "" then
    return nil
  end

  if lowerName:find("%f[%a]ore%f[%A]") then
    return "ore"
  end
  if lowerName:find("%f[%a]herb%f[%A]") then
    return "herb"
  end

  return nil
end

function Utils.IsTrackedGatheringItem(name, classID, subclassID)
  return Utils.GetTrackedGatheringKind(name, classID, subclassID) ~= nil
end

function Utils.IsGatheringKindEnabled(kind, settings)
  if kind == "lumber" then
    return not settings or settings.trackLumber ~= false
  end
  if kind == "ore" then
    return settings and settings.trackOre and true or false
  end
  if kind == "herb" then
    return settings and settings.trackHerbs and true or false
  end
  return false
end

function Utils.FormatNumber(num)
  num = tonumber(num) or 0
  if num >= 10000 then
    return string_format("%.1fk", num / 1000)
  elseif num >= 1000 then
    local formatted = tostring(num)
    local k
    while true do
      formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
      if k == 0 then break end
    end
    return formatted
  else
    return tostring(math_floor(num))
  end
end

function Utils.FormatNumberCompact(num)
  num = tonumber(num) or 0
  if num >= 1000 then
    return string_format("%.1fk", num / 1000)
  else
    return tostring(math_floor(num))
  end
end

function Utils.Wipe(tbl)
  if not tbl then return end
  for k in pairs(tbl) do tbl[k] = nil end
end

function Utils.GetDB()
  local addon = NS.Addon
  local prof = addon and addon.db and addon.db.profile
  return prof and prof.gatherTrack or {}
end

function Utils.FormatTime(seconds)
  seconds = tonumber(seconds) or 0
  local minutes = math_floor(seconds / 60)
  local secs = math_floor(seconds % 60)
  return string_format("%d:%02d", minutes, secs)
end

function Utils.GetTime()
  return (time or GetTime)()
end

return Utils
