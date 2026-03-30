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

function Utils.GetTrackedGatheringKind(name, classID, subclassID)
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
