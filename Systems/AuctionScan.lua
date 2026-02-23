local ADDON, NS = ...
NS.Systems = NS.Systems or {}
local AS = {}
NS.Systems.AuctionScan = AS

local function GetPriceSource()
  return NS.Systems.PriceSource
end

function AS.IsAuctionatorAvailable()
  return Auctionator ~= nil
end

function AS.CanShowScanInfo()
  if not C_AuctionHouse then return false end
  if type(C_AuctionHouse.IsAuctionHouseOpen) ~= "function" then return false end
  return C_AuctionHouse.IsAuctionHouseOpen() and AS.IsAuctionatorAvailable()
end

function AS.HasAuctionatorData()
  if not Auctionator then return false end
  local api = Auctionator.API and Auctionator.API.v1
  if not api or type(api.GetAuctionPriceByItemID) ~= "function" then return false end
  local testItems = { 2589, 2592, 2318 }
  for _, itemID in ipairs(testItems) do
    local ok, price = pcall(api.GetAuctionPriceByItemID, ADDON, itemID)
    if ok and price and price > 0 then return true end
  end
  return false
end

local debounceTimer = nil

local function OnDBUpdated()
  if debounceTimer then
    debounceTimer:Cancel()
    debounceTimer = nil
  end

  debounceTimer = C_Timer.NewTimer(0.3, function()
    debounceTimer = nil

    local PS = GetPriceSource()
    if PS then
      if PS.SetLastAuctionatorScanTime then PS.SetLastAuctionatorScanTime(time()) end
      if PS.FlushPriceCache           then PS.FlushPriceCache() end
    end

    local DH = NS.UI and NS.UI.DecorAH
    if DH then
      if DH._updateScanTime then DH._updateScanTime() end
      if DH._invalidate     then DH._invalidate() end
      if DH._refreshTable and DH.frame and DH.frame:IsShown() then
        DH._refreshTable()
      end
    end
  end)
end

local isRegistered = false

local function TryRegister()
  if isRegistered then return end
  local api = Auctionator and Auctionator.API and Auctionator.API.v1
  if not api or type(api.RegisterForDBUpdate) ~= "function" then return end

  local ok, err = pcall(api.RegisterForDBUpdate, ADDON, OnDBUpdated)
  if ok then
    isRegistered = true
  end
end

function AS.InitializeScanTracking()
  C_Timer.After(0, TryRegister)
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(_, _, addonName)
  if addonName == "Auctionator" then
    C_Timer.After(0.5, TryRegister)
  end
end)

return AS
