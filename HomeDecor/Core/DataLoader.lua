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
    mergeKeys = { "Drops" },
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
  self:EnsureProfessions()
  self:EnsureEvents()
  self:EnsureTrainers()
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

return Loader
