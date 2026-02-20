local ADDON, NS = ...
NS.Systems = NS.Systems or {}
local PS = {}
NS.Systems.PriceSource = PS

local function db()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.decorAH = profile.decorAH or {}
  profile.decorAH.preferredSource = profile.decorAH.preferredSource or nil
  return profile.decorAH
end

local _tsmCache  = {}
local _atrCache  = {}
local _cacheTime = 0
local CACHE_TTL  = 120

local function IsCacheStale()
  return (time() - _cacheTime) > CACHE_TTL
end

function PS.FlushPriceCache()
  _tsmCache  = {}
  _atrCache  = {}
  _cacheTime = time()
end

local function GetTSMPrice(itemID)
  if not itemID then return nil end
  if not TSM_API or type(TSM_API.GetCustomPriceValue) ~= "function" then return nil end

  if _tsmCache[itemID] ~= nil then
    return _tsmCache[itemID] or nil
  end

  local ok, price = pcall(TSM_API.GetCustomPriceValue, "DBMarket", "i:" .. tostring(itemID))
  local result = (ok and price and type(price) == "number" and price > 0) and price or false
  _tsmCache[itemID] = result
  return result or nil
end

local function GetAuctionatorPrice(itemID)
  if not itemID then return nil end
  if not Auctionator or not Auctionator.API or not Auctionator.API.v1 then return nil end
  local getPrice = Auctionator.API.v1.GetAuctionPriceByItemID
  if type(getPrice) ~= "function" then return nil end

  if _atrCache[itemID] ~= nil then
    return _atrCache[itemID] or nil
  end

  local ok, price = pcall(getPrice, ADDON, itemID)
  local result = (ok and price and type(price) == "number" and price > 0) and price or false
  _atrCache[itemID] = result
  return result or nil
end

function PS.GetItemPrice(itemID, forceSource)
  if not itemID then return nil, nil end
  itemID = tonumber(itemID)
  if not itemID or itemID <= 0 then return nil, nil end

  if IsCacheStale() then PS.FlushPriceCache() end

  local preferred = (forceSource == nil) and (db() and db().preferredSource) or forceSource

  if preferred == "TSM" then
    local p = GetTSMPrice(itemID)
    if p then return p, "TSM" end
    return nil, nil
  end
  if preferred == "Auctionator" then
    local p = GetAuctionatorPrice(itemID)
    if p then return p, "Auctionator" end
    return nil, nil
  end

  local p = GetTSMPrice(itemID)
  if p then return p, "TSM" end
  p = GetAuctionatorPrice(itemID)
  if p then return p, "Auctionator" end
  return nil, nil
end

function PS.IsTSMAvailable()
  return (TSM_API and type(TSM_API.GetCustomPriceValue) == "function") and true or false
end

function PS.IsAuctionatorAvailable()
  if not Auctionator or not Auctionator.API or not Auctionator.API.v1 then return false end
  return type(Auctionator.API.v1.GetAuctionPriceByItemID) == "function"
end

function PS.GetAvailableSources()
  local out = {}
  if PS.IsTSMAvailable()    then out[#out + 1] = "TSM"        end
  if PS.IsAuctionatorAvailable() then out[#out + 1] = "Auctionator" end
  return out
end

function PS.GetPreferredSource()
  local g = db()
  return (g and g.preferredSource) or nil
end

function PS.SetPreferredSource(name)
  local g = db()
  if g then
    g.preferredSource = (name == "TSM" or name == "Auctionator") and name or nil
  end
end

function PS.AutoDetectSource()
  local current = PS.GetPreferredSource()
  if current then return current end

  if PS.IsAuctionatorAvailable() then
    PS.SetPreferredSource("Auctionator")
    return "Auctionator"
  elseif PS.IsTSMAvailable() then
    PS.SetPreferredSource("TSM")
    return "TSM"
  end

  return nil
end

function PS.GetLastAuctionatorScanTime()
  local g = db()
  return g and g.lastAuctionatorScan or nil
end

function PS.SetLastAuctionatorScanTime(timestamp)
  local g = db()
  if g then g.lastAuctionatorScan = timestamp or time() end
end

function PS.FormatGold(copper, full)
  if not copper or copper == 0 then return "0" end

  local isNegative = copper < 0
  local absCopper  = math.abs(copper)
  local prefix     = isNegative and "-" or ""

  if full then
    local g = math.floor(absCopper / 10000)
    local s = math.floor((absCopper % 10000) / 100)
    local c = absCopper % 100
    if g > 0 then return prefix .. ("%d.%02d.%02dg"):format(g, s, c) end
    if s > 0 then return prefix .. ("%d.%02ds"):format(s, c) end
    return prefix .. ("%dc"):format(c)
  end

  local g = absCopper / 10000
  if g >= 1000 then return prefix .. ("%.1fk"):format(g / 1000) end
  if g >= 1    then return prefix .. ("%.1fg"):format(g) end
  if absCopper >= 100 then return prefix .. ("%.0fs"):format(absCopper / 100) end
  return prefix .. ("%dc"):format(absCopper)
end

local tsmFrame = CreateFrame("Frame")
tsmFrame:RegisterEvent("ADDON_LOADED")
tsmFrame:SetScript("OnEvent", function(self, _, addonName)
  if addonName == "TradeSkillMaster" or addonName == "TSM_AppHelper" then
    PS.FlushPriceCache()
    self:UnregisterEvent("ADDON_LOADED")
  end
end)

return PS
