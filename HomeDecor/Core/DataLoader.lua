local ADDON, NS = ...

NS.Systems = NS.Systems or {}
NS.Data = NS.Data or {}

local Loader = {}
NS.Systems.DataLoader = Loader

local C_AddOns = _G.C_AddOns
local BundleRegistry = _G.HomeDecorDataBundles or {}
_G.HomeDecorDataBundles = BundleRegistry
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local type = type
local tinsert = table.insert

local bundles = {
  Vendors = {
    addon = "HomeDecor_Data_Vendors",
    mergeKeys = { "Vendors" },
  },
  Achievements = {
    addon = "HomeDecor_Data_Vendors",
    mergeKeys = { "Vendors" },
  },
  Quests = {
    addon = "HomeDecor_Data_Vendors",
    mergeKeys = { "Vendors" },
  },
  Drops = {
    addon = "HomeDecor_Data_Drops",
    mergeKeys = { "Drops", "Shops", "Treasures" },
  },
  Shops = {
    addon = "HomeDecor_Data_Drops",
    mergeKeys = { "Drops", "Shops", "Treasures" },
  },
  Treasures = {
    addon = "HomeDecor_Data_Drops",
    mergeKeys = { "Drops", "Shops", "Treasures" },
  },
  Professions = {
    addon = "HomeDecor_Data_Professions",
    mergeKeys = { "Professions", "Prof_Reagents" },
  },
  Prof_Reagents = {
    addon = "HomeDecor_Data_Professions",
    mergeKeys = { "Professions", "Prof_Reagents" },
  },
  Events = {
    addon = "HomeDecor_Data_Events",
    mergeKeys = { "Events" },
  },
  Trainers = {
    addon = "HomeDecor_Data_Trainers",
    mergeKeys = { "Trainers" },
  },
}

local state = {}
local warmupRunning = false
local warmupDone = false
local warmupCallbacks = {}

local function IsLoaded(addonName)
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded(addonName)
  end
  if _G.IsAddOnLoaded then
    return _G.IsAddOnLoaded(addonName)
  end
  return false
end

local function LoadAddon(addonName)
  if C_AddOns and C_AddOns.LoadAddOn then
    return C_AddOns.LoadAddOn(addonName)
  end
  if _G.LoadAddOn then
    return _G.LoadAddOn(addonName)
  end
  return false, "NO_LOADER"
end

local function MergeBundle(def)
  local payload = BundleRegistry[def.addon]
  if type(payload) ~= "table" then
    return false, "NO_PAYLOAD"
  end

  for i = 1, #def.mergeKeys do
    local key = def.mergeKeys[i]
    local value = payload[key]
    if value ~= nil then
      rawset(NS.Data, key, value)
    end
  end

  for i = 1, #def.mergeKeys do
    if def.mergeKeys[i] == "Events" then
      local Events = NS.Systems and NS.Systems.Events
      if Events and Events.Invalidate then
        Events:Invalidate()
      end
      break
    end
  end

  return true
end

function Loader:EnsureBundle(key)
  local def = bundles[key]
  if not def then return false, "UNKNOWN_BUNDLE" end

  local addonName = def.addon
  local st = state[addonName]
  if st and st.loaded then
    return true
  end
  if st and st.failed then
    return false, st.reason
  end

  if not IsLoaded(addonName) then
    local ok, reason = LoadAddon(addonName)
    if not ok then
      state[addonName] = { failed = true, reason = reason or "LOAD_FAILED" }
      return false, reason
    end
  end

  local merged, reason = MergeBundle(def)
  if not merged then
    state[addonName] = { failed = true, reason = reason or "MERGE_FAILED" }
    return false, reason
  end

  state[addonName] = { loaded = true }
  return true
end

function Loader:EnsureVendors()
  return self:EnsureBundle("Vendors")
end

function Loader:EnsureDerivedRequirements()
  local ok, reason = self:EnsureVendors()
  if not ok then
    return false, reason
  end

  if rawget(NS.Data, "_derivedRequirementsBuilt") then
    return true
  end

  local builder = NS.Systems and NS.Systems.BuildDerivedRequirements
  if type(builder) == "function" then
    builder(false)
  else
    rawset(NS.Data, "Achievements", rawget(NS.Data, "Achievements") or {})
    rawset(NS.Data, "Quests", rawget(NS.Data, "Quests") or {})
    rawset(NS.Data, "_derivedRequirementsBuilt", true)
  end

  return true
end

function Loader:EnsureDrops()
  return self:EnsureBundle("Drops")
end

function Loader:EnsureShops()
  return self:EnsureBundle("Shops")
end

function Loader:EnsureTreasures()
  return self:EnsureBundle("Treasures")
end

function Loader:EnsureProfessions()
  return self:EnsureBundle("Professions")
end

function Loader:EnsureEvents()
  return self:EnsureBundle("Events")
end

function Loader:EnsureTrainers()
  return self:EnsureBundle("Trainers")
end

function Loader:EnsureAllCatalogData()
  self:EnsureVendors()
  self:EnsureDerivedRequirements()
  self:EnsureDrops()
  self:EnsureShops()
  self:EnsureTreasures()
  self:EnsureProfessions()
  self:EnsureEvents()
  self:EnsureTrainers()
  warmupDone = true
end

function Loader:IsCatalogWarm()
  if warmupDone then return true end
  local function done(addonName)
    local st = state[addonName]
    return st and (st.loaded or st.failed)
  end
  if not done("HomeDecor_Data_Vendors") then return false end
  if not rawget(NS.Data, "_derivedRequirementsBuilt") then return false end
  if not done("HomeDecor_Data_Drops") then return false end
  if not done("HomeDecor_Data_Professions") then return false end
  if not done("HomeDecor_Data_Events") then return false end
  if not done("HomeDecor_Data_Trainers") then return false end
  warmupDone = true
  return true
end

function Loader:WarmCatalogData(callback)
  if type(callback) == "function" then
    tinsert(warmupCallbacks, callback)
  end
  if self:IsCatalogWarm() then
    local callbacks = warmupCallbacks
    warmupCallbacks = {}
    for i = 1, #callbacks do pcall(callbacks[i]) end
    return true
  end
  if warmupRunning then return false end
  warmupRunning = true

  local steps = {
    function() Loader:EnsureVendors() end,
    function() Loader:EnsureDerivedRequirements() end,
    function() Loader:EnsureDrops() end,
    function() Loader:EnsureProfessions() end,
    function() Loader:EnsureEvents() end,
    function() Loader:EnsureTrainers() end,
  }

  local index = 0
  local function runNext()
    index = index + 1
    local step = steps[index]
    if step then
      pcall(step)
      if _G.C_Timer and _G.C_Timer.After then
        _G.C_Timer.After(0.08, runNext)
      else
        runNext()
      end
      return
    end

    warmupRunning = false
    warmupDone = true
    local callbacks = warmupCallbacks
    warmupCallbacks = {}
    for i = 1, #callbacks do pcall(callbacks[i]) end
  end

  if _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0.01, runNext)
  else
    runNext()
  end
  return false
end

function Loader:EnsureForCategory(category)
  if category == "Vendors" or category == "PvP" then
    return self:EnsureVendors()
  end
  if category == "Achievements" or category == "Quests" then
    return self:EnsureDerivedRequirements()
  end
  if category == "Drops" then
    return self:EnsureDrops()
  end
  if category == "Shop" or category == "Shops" then
    return self:EnsureShops()
  end
  if category == "Treasures" then
    return self:EnsureTreasures()
  end
  if category == "Professions" then
    return self:EnsureProfessions()
  end
  if category == "Events" then
    return self:EnsureEvents()
  end
  if category == "Search" or category == "Saved Items" then
    return self:EnsureAllCatalogData()
  end
  return true
end

setmetatable(NS.Data, {
  __index = function(tbl, key)
    local def = bundles[key]
    if def then
      if key == "Achievements" or key == "Quests" then
        Loader:EnsureDerivedRequirements()
      else
        Loader:EnsureBundle(key)
      end
      return rawget(tbl, key)
    end
    return nil
  end,
})

if NS.RegisterEvent then
  NS.RegisterEvent(Loader, "PLAYER_ENTERING_WORLD", function()
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(2.0, function()
        if Loader and Loader.WarmCatalogData then
          Loader:WarmCatalogData()
        end
      end)
    end
  end)
end

return Loader
