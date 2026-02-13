local ADDON, NS = ...
NS.UI = NS.UI or {}

local AW = {}
NS.UI.LumberTrackAccountWide = AW

local function GetCharacterKey()
  local name = UnitName("player") or "Unknown"
  local realm = GetRealmName() or "Unknown"
  return name .. " - " .. realm
end

local function GetAccountDB()
  local addon = NS.Addon
  if not addon or not addon.db then return nil end

  if not addon.db.global then
    addon.db.global = {}
  end
  
  if not addon.db.global.lumberTrackAccount then
    addon.db.global.lumberTrackAccount = {
      characterData = {},
      accountWide = false,
    }
  end
  
  return addon.db.global.lumberTrackAccount
end

function AW:GetCharacterKey()
  return GetCharacterKey()
end

function AW:IsEnabled()
  local db = GetAccountDB()
  return db and db.accountWide or false
end

function AW:SetEnabled(enabled)
  local db = GetAccountDB()
  if db then
    db.accountWide = enabled and true or false
  end
end

function AW:SaveCharacterLumber(counts)
  if not counts then return end
  
  local db = GetAccountDB()
  if not db then return end
  
  local charKey = GetCharacterKey()
  if not db.characterData[charKey] then
    db.characterData[charKey] = {}
  end

  for itemID, count in pairs(counts) do
    db.characterData[charKey][itemID] = tonumber(count) or 0
  end

  for itemID, count in pairs(db.characterData[charKey]) do
    if count <= 0 then
      db.characterData[charKey][itemID] = nil
    end
  end
end

function AW:GetAggregatedCounts()
  local db = GetAccountDB()
  if not db or not self:IsEnabled() then return nil end
  
  local aggregated = {}
  
  for charKey, charCounts in pairs(db.characterData or {}) do
    for itemID, count in pairs(charCounts) do
      aggregated[itemID] = (aggregated[itemID] or 0) + (tonumber(count) or 0)
    end
  end
  
  return aggregated
end

function AW:GetCharacterBreakdown(itemID)
  local db = GetAccountDB()
  if not db or not itemID then return {} end
  
  local breakdown = {}
  
  for charKey, charCounts in pairs(db.characterData or {}) do
    local count = tonumber(charCounts[itemID]) or 0
    if count > 0 then
      breakdown[#breakdown + 1] = {
        character = charKey,
        count = count
      }
    end
  end

  table.sort(breakdown, function(a, b)
    if a.count ~= b.count then
      return a.count > b.count
    end
    return a.character < b.character
  end)
  
  return breakdown
end

function AW:GetCurrentCharacterCount(itemID)
  local db = GetAccountDB()
  if not db or not itemID then return 0 end
  
  local charKey = GetCharacterKey()
  local charData = db.characterData[charKey]
  
  if not charData then return 0 end
  return tonumber(charData[itemID]) or 0
end

function AW:GetTotalCount(counts)
  if not self:IsEnabled() then
    local total = 0
    for id, count in pairs(counts or {}) do
      total = total + (tonumber(count) or 0)
    end
    return total
  end

  local aggregated = self:GetAggregatedCounts()
  if not aggregated then return 0 end

  local total = 0
  for id, count in pairs(aggregated) do
    total = total + (tonumber(count) or 0)
  end
  return total
end

function AW:CleanupOldData(maxCharacters)
  maxCharacters = maxCharacters or 50
  local db = GetAccountDB()
  if not db then return end
  
  local charCount = 0
  for k in pairs(db.characterData or {}) do
    charCount = charCount + 1
  end

  if charCount <= maxCharacters then return end

  local currentKey = GetCharacterKey()
  local toRemove = {}

  for charKey in pairs(db.characterData) do
    if charKey ~= currentKey then
      toRemove[#toRemove + 1] = charKey
    end
  end

  local removeCount = charCount - maxCharacters
  for i = 1, math.min(removeCount, #toRemove) do
    db.characterData[toRemove[i]] = nil
  end
end

return AW
