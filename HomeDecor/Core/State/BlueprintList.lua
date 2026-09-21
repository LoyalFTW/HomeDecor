local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local BlueprintList = { revision = 0, refreshed = {}, dirty = {}, requested = {}, generation = 0 }
NS.Systems.BlueprintList = BlueprintList

local wipe = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end

local _listeners = setmetatable({}, { __mode = "k" })

function BlueprintList:RegisterListener(owner, fn)
  if owner and type(fn) == "function" then _listeners[owner] = fn end
end

function BlueprintList:UnregisterListener(owner)
  _listeners[owner] = nil
end

local function notify()
  BlueprintList.revision = BlueprintList.revision + 1
  for owner, fn in pairs(_listeners) do pcall(fn, owner) end
end

--- Storage shape: profile.blueprintList[categoryName][itemKey] = entry
--- Each saved blueprint gets its own category, named after the blueprint.
--- v1 stored a flat itemKey -> entry map instead; bump the version to drop
--- any leftover v1 data rather than trying to reinterpret its shape.
local DATA_VERSION = 2

local function db()
  local p = NS.Systems.Database:GetProfile()
  if not p then return nil end
  if p.blueprintListVersion ~= DATA_VERSION then
    p.blueprintList = {}
    p.blueprintListVersion = DATA_VERSION
  end
  p.blueprintList = p.blueprintList or {}
  return p.blueprintList
end

local function ensureProfile(self)
  local profile = NS.Systems.Database:GetProfile()
  if self.profile ~= profile then
    self.profile = profile
    self.refreshed = {}
    self.dirty = {}
    self.requested = {}
    self.generation = 0
    self.pendingRefresh = nil
  end
  return profile
end

local function resolveKey(itemID, decorID)
  itemID = tonumber(itemID)
  decorID = tonumber(decorID)
  if itemID and itemID > 0 then return "item:" .. itemID end
  if decorID and decorID > 0 then return "decor:" .. decorID end
  return nil
end

local function catalogItem(decorID)
  decorID = tonumber(decorID)
  if not decorID then return nil end

  -- Same fresh, direct catalog walk Saved Items uses (attaches live vendor
  -- context inline) rather than GlobalIndex's cached byItemID table, which
  -- doesn't reliably carry vendor location data through to this list.
  local search = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Search
  if search and search.FindByDecorID then
    local found = search.FindByDecorID(decorID)
    if found then return found end
  end

  local GI = NS.Systems and NS.Systems.GlobalIndex
  if GI and GI.Ensure then GI:Ensure() end
  local found = GI and GI.byItemID and GI.byItemID[decorID]
  if found then return found end
  local Catalog = NS.Systems and NS.Systems.Catalog
  for _, record in ipairs((Catalog and Catalog.ordered) or {}) do
    if tonumber(record.decorID) == decorID then return record end
  end
end

local function buildBaseEntry(reqItem, resolvedSource)
  local itemID = tonumber(reqItem.itemID)
  local decorID = (tonumber(reqItem.contentType) == 3) and tonumber(reqItem.recordID) or nil
  local source = resolvedSource or (decorID and catalogItem(decorID))
  local entry = {
    itemID = itemID or source and source.itemID,
    decorID = decorID or source and source.decorID,
    title = source and source.title,
    icon = source and source.icon,
    category = source and source.category,
    subcategory = source and source.subcategory,
    profession = source and source.profession,
    expansion = source and source.expansion,
    zone = source and source.zone,
    faction = source and source.faction,
    sourceType = source and source.sourceType,
    sourceID = source and source.sourceID,
    sourceName = source and source.sourceName,
    vendorName = source and source.vendorName,
    skillID = source and source.skillID,
    worldmap = source and source.worldmap,
    mapID = source and source.mapID,
    mapX = source and source.mapX,
    mapY = source and source.mapY,
    requirements = source and source.requirements,
    budgetCost = source and source.budgetCost,
    currency = source and source.currency,
    currencyType = source and source.currencyType,
    costs = source and source.costs,
  }
  if not entry.title or entry.title == "" then
    entry.title = reqItem.name
  end

  return entry, resolveKey(itemID, decorID)
end

--- Adds every missing, non-locked requirement from a blueprint's requirements
--- table (Systems/Blueprints.lua requirementsFromInfo shape) into its own
--- category, named after the blueprint. Re-saving the same blueprint refreshes
--- the needed/have counts for that category instead of double-counting.
function BlueprintList:AddMissing(req, blueprintName, blueprintCode, houseGUID, authoritative)
  local d = db()
  if not d or not req then return 0 end
  blueprintName = (type(blueprintName) == "string" and blueprintName ~= "") and blueprintName or "Blueprint"
  local profile = ensureProfile(self)
  profile.blueprintListCodes = type(profile.blueprintListCodes) == "table" and profile.blueprintListCodes or {}
  profile.blueprintListHouseGUIDs = type(profile.blueprintListHouseGUIDs) == "table" and profile.blueprintListHouseGUIDs or {}
  if type(blueprintCode) == "string" and blueprintCode ~= "" then
    profile.blueprintListCodes[blueprintName] = blueprintCode
    profile.blueprintListHouseGUIDs[blueprintName] = houseGUID
  end
  local context = blueprintCode and (blueprintCode .. ":" .. tostring(houseGUID or ""))
  if not authoritative and context then self.dirty[context] = true end

  -- Batch-resolve every missing decor item's catalog data (with vendor
  -- context attached) in a single catalog walk, instead of one full walk
  -- per item -- blueprints can have hundreds of missing items.
  local neededDecorIDs = {}
  for _, reqItem in ipairs(req.items or {}) do
    local missing = tonumber(reqItem.missing) or 0
    if missing > 0 and not reqItem.invalid and tonumber(reqItem.contentType) == 3 then
      local decorID = tonumber(reqItem.recordID)
      if decorID then neededDecorIDs[decorID] = true end
    end
  end

  local resolved = {}
  local search = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Search
  if search and search.FindManyByDecorID and next(neededDecorIDs) then
    resolved = search.FindManyByDecorID(neededDecorIDs)
  end
  for decorID in pairs(neededDecorIDs) do
    resolved[decorID] = resolved[decorID] or catalogItem(decorID)
  end

  local category = {}
  local touched = 0
  for _, reqItem in ipairs(req.items or {}) do
    local missing = tonumber(reqItem.missing) or 0
    if missing > 0 and not reqItem.invalid then
      local decorID = (tonumber(reqItem.contentType) == 3) and tonumber(reqItem.recordID) or nil
      local entry, key = buildBaseEntry(reqItem, decorID and resolved[decorID])
      if key then
        entry.needed = tonumber(reqItem.needed) or missing + (tonumber(reqItem.have) or 0)
        entry.have = tonumber(reqItem.have) or 0
        entry.kind = reqItem.kind
        category[key] = entry
        touched = touched + 1
      end
    end
  end

  d[blueprintName] = category
  notify()
  return touched
end

function BlueprintList:GetBlueprintCode(name)
  local profile = NS.Systems.Database:GetProfile()
  if not profile or not name then return nil end
  local codes = profile.blueprintListCodes
  local code = type(codes) == "table" and codes[name]
  if code then return code end
  local blueprints = NS.Systems.Blueprints
  if not blueprints or not blueprints.GetSaved then return nil end
  for _, rec in ipairs(blueprints:GetSaved() or {}) do
    if rec.name == name then return rec.code end
  end
end

function BlueprintList:GetHouseGUID(name)
  local profile = NS.Systems.Database:GetProfile()
  local contexts = profile and profile.blueprintListHouseGUIDs
  return type(contexts) == "table" and contexts[name] or nil
end

function BlueprintList:OnRequestStarted(code, houseGUID)
  ensureProfile(self)
  if code then self.requested[code .. ":" .. tostring(houseGUID or "")] = self.generation end
end

function BlueprintList:RefreshActive()
  ensureProfile(self)
  local active = self:GetActive()
  local code = active and self:GetBlueprintCode(active.name)
  local houseGUID = active and self:GetHouseGUID(active.name)
  local context = code and (code .. ":" .. tostring(houseGUID or ""))
  local blueprints = NS.Systems.Blueprints
  local rec = code and blueprints and blueprints:GetByCode(code)
  if not rec then return end
  if self.refreshed[context] and not self.dirty[context] then return end
  if rec.status == "checking" or blueprints.fitQueue then
    self.pendingRefresh = true
    return
  end
  if houseGUID then
    blueprints:RequestHouseFit(rec.id, houseGUID)
  else
    blueprints:RequestContents(rec.id)
  end
end

function BlueprintList:OnStorageChanged()
  local profile = ensureProfile(self)
  self.generation = self.generation + 1
  local d = profile and profile.blueprintList
  if type(d) ~= "table" then return end
  for name in pairs(d) do
    local code = self:GetBlueprintCode(name)
    if code then self.dirty[code .. ":" .. tostring(self:GetHouseGUID(name) or "")] = true end
  end
  local panel = NS.UI and NS.UI.TrackerPanel
  local trackerData = NS.UI and NS.UI.TrackerData
  if not (panel and panel.frame and panel.frame:IsShown() and trackerData and trackerData:GetTab() == "blueprints") then return end
  if self.refreshQueued then return end
  self.refreshQueued = true
  local function refresh()
    BlueprintList.refreshQueued = false
    if panel and panel.frame and panel.frame:IsShown() and trackerData and trackerData:GetTab() == "blueprints" then
      BlueprintList:RefreshActive()
    end
  end
  if _G.C_Timer and _G.C_Timer.After then _G.C_Timer.After(0.5, refresh) else refresh() end
end

function BlueprintList:OnBlueprintUpdated(rec, fit)
  local requirements = fit and fit.requirements or rec and rec.requirements
  if not rec or not rec.code or not requirements then return end
  local houseGUID = fit and fit.houseGUID
  local context = rec.code .. ":" .. tostring(houseGUID or "")
  local profile = ensureProfile(self)
  local d = profile and profile.blueprintList
  if type(d) ~= "table" then return end
  local names = {}
  for name in pairs(d) do
    if self:GetBlueprintCode(name) == rec.code and self:GetHouseGUID(name) == houseGUID then names[#names + 1] = name end
  end
  for _, name in ipairs(names) do self:AddMissing(requirements, name, rec.code, houseGUID, true) end
  self.refreshed[context] = true
  if self.requested[context] == self.generation then
    self.dirty[context] = nil
  elseif self.dirty[context] then
    if fit then
      self.pendingRefresh = true
    elseif _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(0, function() BlueprintList:RefreshActive() end)
    else
      self:RefreshActive()
    end
  end
end

function BlueprintList:RetryPending()
  if not self.pendingRefresh then return end
  self.pendingRefresh = nil
  self:RefreshActive()
end

function BlueprintList:Remove(categoryName, key)
  local d = db()
  local category = d and categoryName and d[categoryName]
  if not category or not key or not category[key] then return end
  category[key] = nil
  if not next(category) then
    self:RemoveCategory(categoryName)
  else
    notify()
  end
end

function BlueprintList:RemoveCategory(categoryName)
  local d = db()
  if not d or not categoryName or not d[categoryName] then return end
  d[categoryName] = nil
  local profile = NS.Systems.Database:GetProfile()
  if profile and type(profile.blueprintListCodes) == "table" then profile.blueprintListCodes[categoryName] = nil end
  if profile and type(profile.blueprintListHouseGUIDs) == "table" then profile.blueprintListHouseGUIDs[categoryName] = nil end
  notify()
end

function BlueprintList:Clear()
  local d = db()
  if not d or not next(d) then return end
  wipe(d)
  local profile = NS.Systems.Database:GetProfile()
  if profile then
    profile.blueprintListCodes = {}
    profile.blueprintListHouseGUIDs = {}
  end
  notify()
end

function BlueprintList:Count(search)
  local active = self:GetActive()
  if not active then return 0 end
  search = tostring(search or ""):lower()
  local n = 0
  for _, entry in ipairs(active.items) do
    local title = tostring(entry.title or entry.name or ""):lower()
    if search == "" or title:find(search, 1, true) then n = n + 1 end
  end
  return n
end

--- Returns { { category = categoryName, entry = entry }, ... } for every
--- saved-blueprint category that still needs this item, e.g. for surfacing
--- "this vendor sells something on your blueprint list" elsewhere in the UI.
function BlueprintList:FindByItemID(itemID)
  itemID = tonumber(itemID)
  if not itemID then return {} end
  local key = resolveKey(itemID, nil)
  local d = db()
  if not d or not key then return {} end

  local out = {}
  for categoryName, category in pairs(d) do
    local entry = category[key]
    if entry then
      out[#out + 1] = { category = categoryName, entry = entry }
    end
  end
  return out
end

local function itemSortGroup(it)
  if it.kind == "Dyes" then return 1 end
  local st = it.sourceType or (it.source and it.source.type)
  if st == "profession" then return 2 end
  return 3
end

local function itemZone(it)
  return it.zone
    or (it.source and it.source.zone)
    or (it._navVendor and it._navVendor.zone)
    or (it.vendor and it.vendor.zone)
    or ""
end

--- Returns { { name = categoryName, items = { entry, ... } }, ... } sorted by
--- category name. Items within a category are sorted Dyes first, then
--- profession-sourced (crafted) items, then everything else grouped by
--- zone, and alphabetically by title within each group.
function BlueprintList:GetCategories()
  local d = db()
  if not d then return {} end

  local out = {}
  for categoryName, category in pairs(d) do
    local items = {}
    for key, entry in pairs(category) do
      entry._blueprintKey = key
      entry._blueprintCategory = categoryName
      items[#items + 1] = entry
    end
    table.sort(items, function(a, b)
      local ga, gb = itemSortGroup(a), itemSortGroup(b)
      if ga ~= gb then return ga < gb end

      if ga == 3 then
        local za, zb = itemZone(a), itemZone(b)
        if za ~= zb then return za < zb end
      end

      local an, bn = tostring(a.title or ""), tostring(b.title or "")
      if an == bn then
        return tostring(a._blueprintKey) < tostring(b._blueprintKey)
      end
      return an < bn
    end)
    out[#out + 1] = { name = categoryName, items = items }
  end

  table.sort(out, function(a, b) return tostring(a.name) < tostring(b.name) end)
  return out
end

function BlueprintList:GetActive()
  local categories = self:GetCategories()
  if #categories == 0 then return nil end
  local profile = NS.Systems.Database:GetProfile()
  local active = profile and profile.blueprintListActive
  for _, category in ipairs(categories) do
    if category.name == active then
      local layout = NS.Systems.Architect and NS.Systems.Architect:FindLayoutByName(category.name)
      if not layout and NS.Systems.Blueprints and NS.Systems.Architect then
        for _, blueprint in ipairs(NS.Systems.Blueprints:GetSaved() or {}) do
          if blueprint.name == category.name then
            for _, candidate in ipairs((NS.Systems.Architect:GetDB() or {}).layouts or {}) do
              if candidate.blueprintCode == blueprint.code then layout = candidate break end
            end
            break
          end
        end
      end
      category.layoutID = layout and layout.id
      return category
    end
  end
  if profile then profile.blueprintListActive = categories[1].name end
  local layout = NS.Systems.Architect and NS.Systems.Architect:FindLayoutByName(categories[1].name)
  if not layout and NS.Systems.Blueprints and NS.Systems.Architect then
    for _, blueprint in ipairs(NS.Systems.Blueprints:GetSaved() or {}) do
      if blueprint.name == categories[1].name then
        for _, candidate in ipairs((NS.Systems.Architect:GetDB() or {}).layouts or {}) do
          if candidate.blueprintCode == blueprint.code then layout = candidate break end
        end
        break
      end
    end
  end
  categories[1].layoutID = layout and layout.id
  return categories[1]
end

function BlueprintList:Cycle(delta)
  local categories = self:GetCategories()
  if #categories == 0 then return nil end
  local current = self:GetActive()
  local index = 1
  for i, category in ipairs(categories) do
    if current and category.name == current.name then index = i break end
  end
  index = ((index - 1 + (tonumber(delta) or 1)) % #categories) + 1
  local profile = NS.Systems.Database:GetProfile()
  if profile then profile.blueprintListActive = categories[index].name end
  self:RefreshActive()
  return self:GetActive()
end

function BlueprintList:SetActive(name)
  local d = db()
  if not d or not name or not d[name] then return false end
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return false end
  profile.blueprintListActive = name
  notify()
  self:RefreshActive()
  return true
end

function BlueprintList:RenameActive(name)
  local active = self:GetActive()
  local d = db()
  name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
  if not active or not d or name == "" then return false end
  local oldName = active.name
  if oldName == name then return true end
  if d[name] then return false end
  local layout = active.layoutID and NS.Systems.Architect and NS.Systems.Architect:FindLayoutByID(active.layoutID) or NS.Systems.Architect and NS.Systems.Architect:FindLayoutByName(oldName)
  d[name] = d[oldName]
  d[oldName] = nil
  local profile = NS.Systems.Database:GetProfile()
  if profile and type(profile.blueprintListCodes) == "table" then
    profile.blueprintListCodes[name] = profile.blueprintListCodes[oldName]
    profile.blueprintListCodes[oldName] = nil
  end
  if profile and type(profile.blueprintListHouseGUIDs) == "table" then
    profile.blueprintListHouseGUIDs[name] = profile.blueprintListHouseGUIDs[oldName]
    profile.blueprintListHouseGUIDs[oldName] = nil
  end
  if profile then profile.blueprintListActive = name end
  if layout and NS.Systems.Architect then NS.Systems.Architect:RenameLayout(layout.id, name) end
  local blueprints = NS.Systems.Blueprints
  if blueprints and blueprints.GetSaved then
    for _, blueprint in ipairs(blueprints:GetSaved() or {}) do
      if blueprint.name == oldName or layout and layout.blueprintCode and blueprint.code == layout.blueprintCode then blueprint.name = name end
    end
  end
  notify()
  return true
end

function BlueprintList:DeleteActive()
  local active = self:GetActive()
  if not active then return false end
  self:RemoveCategory(active.name)
  local profile = NS.Systems.Database:GetProfile()
  if profile then profile.blueprintListActive = nil end
  return true
end

function BlueprintList:ForRange(offset, limit, search, consume)
  local active = self:GetActive()
  if not active or type(consume) ~= "function" then return 0 end
  offset = math.max(0, tonumber(offset) or 0)
  limit = math.max(0, tonumber(limit) or #active.items)
  search = tostring(search or ""):lower()
  local filtered = {}
  for _, entry in ipairs(active.items) do
    local title = tostring(entry.title or entry.name or ""):lower()
    if search == "" or title:find(search, 1, true) then filtered[#filtered + 1] = entry end
  end
  local last = math.min(#filtered, offset + limit)
  for index = offset + 1, last do
    local entry = filtered[index]
    local needed = math.max(1, tonumber(entry.needed) or 1)
    consume(entry, index, needed, (tonumber(entry.have) or 0) >= needed)
  end
  return #filtered
end

return BlueprintList
