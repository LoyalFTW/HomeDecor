local _, NS = ...

local SourceAdapter = {
  imported = {},
  failed = {},
}
NS.Systems.SourceAdapter = SourceAdapter

function SourceAdapter:QueueCatalogUpdated()
  self.catalogUpdateToken = (self.catalogUpdateToken or 0) + 1
  local token = self.catalogUpdateToken
  local function send()
    if token ~= SourceAdapter.catalogUpdateToken then return end
    NS.SendMessage("HOMEDECOR_CATALOG_UPDATED")
  end
  if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0, send) else send() end
end

local pvpVendorIDs = {
  [254603] = "Alliance",
  [254606] = "Horde",
}

local suppressedItemIDs = {
  [248941] = true,
}

local bundleKinds = {
  HomeDecor_Data_Vendors = {
    Vendors = "vendor",
    Achievements = "achievement",
    Quests = "quest",
  },
  HomeDecor_Data_Drops = {
    Drops = "drop",
    Shops = "shop",
    Treasures = "treasure",
  },
  HomeDecor_Data_Professions = {
    Professions = "profession",
  },
  HomeDecor_Data_Events = {
    Events = "event",
  },
}

local categoryBundles = {
  Achievements = "HomeDecor_Data_Vendors",
  Quests = "HomeDecor_Data_Vendors",
  Vendors = "HomeDecor_Data_Vendors",
  Drops = "HomeDecor_Data_Drops",
  Shops = "HomeDecor_Data_Drops",
  Shop = "HomeDecor_Data_Drops",
  Treasures = "HomeDecor_Data_Drops",
  Professions = "HomeDecor_Data_Professions",
  Events = "HomeDecor_Data_Events",
  PvP = "HomeDecor_Data_Vendors",
}

local sourceBundles = {
  achievement = "HomeDecor_Data_Vendors",
  quest = "HomeDecor_Data_Vendors",
  vendor = "HomeDecor_Data_Vendors",
  drop = "HomeDecor_Data_Drops",
  shop = "HomeDecor_Data_Drops",
  treasure = "HomeDecor_Data_Drops",
  profession = "HomeDecor_Data_Professions",
  event = "HomeDecor_Data_Events",
  pvp = "HomeDecor_Data_Vendors",
}

local function Scalar(value)
  local kind = type(value)
  if kind == "string" or kind == "number" or kind == "boolean" then return value end
  return nil
end

local function SearchText(...)
  local parts = {}
  for index = 1, select("#", ...) do
    local value = select(index, ...)
    if type(value) == "string" and value ~= "" then parts[#parts + 1] = value:lower() end
    if type(value) == "table" then
      for colorIndex = 1, #value do
        local color = value[colorIndex]
        if type(color) == "string" and color ~= "" then parts[#parts + 1] = color:lower() end
      end
    end
  end
  return table.concat(parts, " ")
end

local function Requirement(source)
  if type(source) ~= "table" then return nil end
  local out = {}
  local quest = source.quest
  local achievement = source.achievement
  local reputation = source.reputation or source.rep
  if type(quest) == "table" then
    out.quest = { id = Scalar(quest.id or quest.questID), title = Scalar(quest.title or quest.name) }
  elseif Scalar(quest) then
    out.quest = { id = Scalar(quest) }
  end
  if type(achievement) == "table" then
    out.achievement = { id = Scalar(achievement.id or achievement.achievementID), title = Scalar(achievement.title or achievement.name) }
  elseif Scalar(achievement) then
    out.achievement = { id = Scalar(achievement) }
  end
  if type(reputation) == "table" then
    out.reputation = { name = Scalar(reputation.name or reputation.title or reputation.faction), standing = Scalar(reputation.standing or reputation.level or reputation.rank) }
  elseif Scalar(reputation) then
    out.reputation = Scalar(reputation)
  end
  return next(out) and out or nil
end

local function MapLocation(value)
  if type(value) ~= "string" then return nil end
  local mapID, x, y = value:match("^(%d+):(%d+):(%d+)$")
  mapID, x, y = tonumber(mapID), tonumber(x), tonumber(y)
  if not mapID or not x or not y then return nil end
  x = x / 10000
  y = y / 10000
  if x <= 0 or x >= 1 or y <= 0 or y >= 1 then return nil end
  return mapID, x, y
end

local function DropLocations(source)
  if type(source) ~= "table" then return nil end
  local mobs = source.mobs
  if not mobs and source.mobSet and type(source._mobSets) == "table" then mobs = source._mobSets[source.mobSet] end
  local values = {}
  if type(mobs) == "table" then
    for npcID, mob in pairs(mobs) do
      if type(mob) == "table" and (mob.name or mob.npc) then
        local worldmap = mob.worldmap
        local mapID, mapX, mapY = MapLocation(worldmap)
        values[#values + 1] = { sourceType = "drop", sourceID = tonumber(npcID) or mob.npcID, sourceName = mob.name or mob.npc, zone = mob.zone or source.zone, worldmap = worldmap, mapID = mapID, mapX = mapX, mapY = mapY }
      end
    end
  elseif source.npc or source.name then
    local mapID, mapX, mapY = MapLocation(source.worldmap)
    values[1] = { sourceType = "drop", sourceID = source.npcID or source.id, sourceName = source.npc or source.name, zone = source.zone, worldmap = source.worldmap, mapID = mapID, mapX = mapX, mapY = mapY }
  end
  table.sort(values, function(left, right) return tostring(left.sourceName or "") < tostring(right.sourceName or "") end)
  return #values > 0 and values or nil
end

local function AddLeaf(leaf, context)
  if type(leaf) ~= "table" then return end
  local source = leaf.source or {}
  local itemID = leaf.itemID or source.itemID
  if suppressedItemIDs[tonumber(itemID)] then return end
  local vendor = context.vendor
  local vendorSource = vendor and vendor.source or {}
  local sourceType = source.type or context.sourceType
  local sourceID = source.id or source.npcID or source.questID or source.achievementID
  local requirements = Requirement(leaf.requirements or source.requirements)
  if not sourceID and sourceType == "quest" and requirements and requirements.quest then sourceID = requirements.quest.id end
  if not sourceID and sourceType == "achievement" and requirements and requirements.achievement then sourceID = requirements.achievement.id end
  if vendor then
    sourceType = sourceType or "vendor"
    sourceID = sourceID or vendorSource.id or vendor.npcID
  end
  local worldmap = leaf.worldmap or source.worldmap or (vendor and vendor.worldmap) or vendorSource.worldmap
  local mapID, mapX, mapY = MapLocation(worldmap)
  local record = {
    id = leaf.id,
    decorID = leaf.decorID,
    itemID = itemID,
    title = leaf.title or leaf.name,
    icon = source.icon or leaf.icon,
    category = context.category,
    subcategory = leaf.decorType or leaf.subcategory,
    profession = context.profession,
    expansion = context.expansion,
    zone = leaf.zone or source.zone or (vendor and vendor.zone) or vendorSource.zone or context.zone,
    worldmap = worldmap,
    mapID = mapID,
    mapX = mapX,
    mapY = mapY,
    faction = leaf.faction or source.faction or (vendor and vendor.faction) or vendorSource.faction,
    sourceType = sourceType,
    sourceID = sourceID,
    sourceName = source.name or source.npc or source.encounter or source.title or (vendor and (vendor.title or vendor.name)) or vendorSource.name or vendorSource.npc,
    skillID = leaf.skillID or source.skillID,
    vendorName = vendor and (vendor.title or vendor.name) or source.vendorName,
    requirements = requirements,
    searchText = SearchText(leaf.title, leaf.name, source.name, source.npc, source.encounter, context.category, leaf.decorType, leaf.subcategory, context.profession, context.expansion, leaf.zone, sourceType, source.zone, vendorSource.zone, leaf.faction, source.faction, vendorSource.faction, leaf.class, source.class, leaf.race, source.race, leaf.colors, source.colors),
    budgetCost = leaf.budgetCost or source.budgetCost or source.cost,
    currency = leaf.currency or source.currency,
    currencyType = leaf.currencytype or leaf.currencyType or source.currencytype or source.currencyType,
    costs = leaf.costs or source.costs,
    classRestriction = leaf.class or leaf.classRestriction or source.class or source.classRestriction,
    raceRestriction = leaf.race or leaf.raceRestriction or source.race or source.raceRestriction,
    size = leaf.size or source.size,
    colors = leaf.colors or source.colors,
    note = leaf.note or source.note,
    dyeable = leaf.dyeable == true or source.dyeable == true,
    dropLocations = DropLocations(source),
  }
  record.displayMeta = table.concat({ record.category or "", record.zone or "", record.sourceType or "" }, "  -  ")
  NS.Systems.Catalog:Add(record)
  local vendorID = vendor and tonumber(vendorSource.id or vendor.npcID or vendor.id)
  if vendorID and pvpVendorIDs[vendorID] then
    local pvpRecord = {}
    for key, value in pairs(record) do pvpRecord[key] = value end
    pvpRecord.category = "PvP"
    pvpRecord.sourceType = "pvp"
    pvpRecord.faction = pvpVendorIDs[vendorID]
    NS.Systems.Catalog:Add(pvpRecord)
  end
end

local function Walk(node, context, seen)
  if type(node) ~= "table" or seen[node] then return end
  seen[node] = true
  if node.decorID or node.itemID then
    AddLeaf(node, context)
    return
  end
  if type(node.items) == "table" then
    local nested = {
      category = context.category,
      profession = context.profession,
      expansion = context.expansion,
      zone = context.zone,
      sourceType = context.sourceType,
      vendor = node,
    }
    for index = 1, #node.items do Walk(node.items[index], nested, seen) end
    return
  end
  for key, value in pairs(node) do
    if type(value) == "table" then
      local nested = {
        category = context.category,
        profession = context.profession,
        expansion = context.expansion,
        zone = context.zone,
        sourceType = context.sourceType,
      }
      if type(key) == "string" then
        if context.sourceType == "profession" and context.profession == nil then
          nested.profession = key
        elseif context.expansion == nil then
          nested.expansion = key
        elseif context.zone == nil then
          nested.zone = key
        end
      end
      Walk(value, nested, seen)
    end
  end
end

function SourceAdapter:ImportBundle(name)
  if self.imported[name] then return 0 end
  local registry = _G.HomeDecorDataBundles
  local bundle = registry and registry[name]
  local kinds = bundleKinds[name]
  if type(bundle) ~= "table" or not kinds then return 0 end
  local before = NS.Systems.Catalog:Count()
  for key, sourceType in pairs(kinds) do
    local root = bundle[key]
    if type(root) == "table" then
      Walk(root, { category = key, sourceType = sourceType }, {})
    end
  end
  self.imported[name] = true
  registry[name] = nil
  for key, root in pairs(bundle) do
    if type(root) == "table" then wipe(root) end
    bundle[key] = nil
  end
  local added = NS.Systems.Catalog:Count() - before
  if self.batchLoading then
    self.batchAdded = (self.batchAdded or 0) + added
  else
    NS.Systems.Catalog:Finalize()
    if added > 0 then self:QueueCatalogUpdated() end
  end
  collectgarbage("step", 256)
  return added
end

function SourceAdapter:ImportAvailable()
  self.batchLoading = true
  self.batchAdded = 0
  local added = 0
  for name in pairs(bundleKinds) do
    added = added + self:ImportBundle(name)
  end
  local batchAdded = self.batchAdded or 0
  self.batchLoading = nil
  self.batchAdded = nil
  if batchAdded > 0 then
    NS.Systems.Catalog:Finalize()
    self:QueueCatalogUpdated()
  end
  return added
end

function SourceAdapter:LoadAll()
  local loader = _G.C_AddOns and _G.C_AddOns.LoadAddOn or _G.LoadAddOn
  if not loader then return 0 end
  self.batchLoading = true
  self.batchAdded = 0
  local loaded = 0
  for name in pairs(bundleKinds) do
    if not self.imported[name] and not self.failed[name] then
      local ok, reason = loader(name)
      if ok then loaded = loaded + 1 end
      self:ImportBundle(name)
      if not self.imported[name] then self.failed[name] = reason or true end
    end
  end
  local added = self.batchAdded or 0
  self.batchLoading = nil
  self.batchAdded = nil
  if added > 0 then
    NS.Systems.Catalog:Finalize()
    self:QueueCatalogUpdated()
    if NS.Systems.MapPins then NS.Systems.MapPins:RebuildTrackedIndex() end
    if NS.Systems.VendorIndex then NS.Systems.VendorIndex:Rebuild() end
  end
  return loaded
end

function SourceAdapter:LoadBundle(name)
  if not name or self.imported[name] or self.failed[name] then return 0 end
  local loader = _G.C_AddOns and _G.C_AddOns.LoadAddOn or _G.LoadAddOn
  if not loader then
    self.failed[name] = "loader unavailable"
    return 0
  end
  local _, reason = loader(name)
  local added = self:ImportBundle(name)
  if not self.imported[name] then self.failed[name] = reason or true end
  return added
end

function SourceAdapter:IsBundleFailed(name)
  return self.failed[name] ~= nil
end

function SourceAdapter:EnsureCategory(category, requirement, sourceType)
  local name
  if requirement == "Achievement" or requirement == "Quest" or requirement == "Reputation" then
    name = "HomeDecor_Data_Vendors"
  elseif sourceType and sourceType ~= "All" then
    name = sourceBundles[sourceType]
  elseif category and category ~= "All" then
    name = categoryBundles[category]
  end
  if name then return self:LoadBundle(name) end
  return self:LoadAll()
end

function SourceAdapter:IsCategoryReady(category, requirement, sourceType)
  local name
  if requirement == "Achievement" or requirement == "Quest" or requirement == "Reputation" then
    name = "HomeDecor_Data_Vendors"
  elseif sourceType and sourceType ~= "All" then
    name = sourceBundles[sourceType]
  elseif category and category ~= "All" then
    name = categoryBundles[category]
  end
  if name then return self.imported[name] == true end
  for bundleName in pairs(bundleKinds) do
    if self.imported[bundleName] ~= true then return false end
  end
  return true
end

function SourceAdapter:OnAddonLoaded(name)
  local added = self:ImportBundle(name)
  if added > 0 then self.failed[name] = nil end
  if added > 0 and not self.batchLoading and NS.Systems.MapPins then NS.Systems.MapPins:RebuildTrackedIndex() end
  if added > 0 and not self.batchLoading and NS.Systems.VendorIndex then NS.Systems.VendorIndex:Rebuild() end
  return added
end
