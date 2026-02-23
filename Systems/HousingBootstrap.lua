local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local HB = {}
NS.Systems.HousingBootstrap = HB

HB.ready = false
local searcher    = nil
local retryTimer  = nil
local timeoutTimer = nil
local retryCount   = 0
local maxRetries   = 6

local function CancelTimers()
  if retryTimer  then retryTimer:Cancel()   retryTimer  = nil end
  if timeoutTimer then timeoutTimer:Cancel() timeoutTimer = nil end
end

local function MarkReady()
  HB.ready = true
  CancelTimers()
end

local function TryWarmCatalog()
  if HB.ready then return end
  retryCount = retryCount + 1
  if retryCount > maxRetries then return end

  if not (C_HousingCatalog and C_HousingCatalog.CreateCatalogSearcher) then
    retryTimer = C_Timer.NewTimer(1.0, TryWarmCatalog)
    return
  end

  local searcher = C_HousingCatalog.CreateCatalogSearcher()
  if not searcher then
    retryTimer = C_Timer.NewTimer(1.0, TryWarmCatalog)
    return
  end

  searcher = searcher

  if searcher.SetOwnedOnly then searcher:SetOwnedOnly(false) end
  if searcher.SetCollected then searcher:SetCollected(true) end
  if searcher.SetUncollected then searcher:SetUncollected(true) end
  if searcher.SetAutoUpdateOnParamChanges then searcher:SetAutoUpdateOnParamChanges(false) end

  if searcher.SetResultsUpdatedCallback then
    searcher:SetResultsUpdatedCallback(MarkReady)
  end

  if searcher.RunSearch then
    searcher:RunSearch()
  end

  timeoutTimer = C_Timer.NewTimer(5.0, function()
    if HB.ready then return end
    searcher = nil
    retryTimer = C_Timer.NewTimer(1.0, TryWarmCatalog)
  end)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(_, event)
  if HB.ready then return end
  C_Timer.After(0, TryWarmCatalog)
end)

return HB
