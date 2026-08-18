local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local BlueprintList = {}
NS.Systems.BlueprintList = BlueprintList

local wipe = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end

local _listeners = {}

function BlueprintList:RegisterListener(fn)
  if type(fn) == "function" then
    _listeners[#_listeners + 1] = fn
  end
end

local function notify()
  for i = 1, #_listeners do
    pcall(_listeners[i])
  end
end

local DATA_VERSION = 2

local function db()
  local p = NS.db and NS.db.profile
  if not p then return nil end
  if p.blueprintListVersion ~= DATA_VERSION then
    p.blueprintList = {}
    p.blueprintListVersion = DATA_VERSION
  end
  p.blueprintList = p.blueprintList or {}
  return p.blueprintList
end

local function resolveKey(itemID, decorID)
  itemID = tonumber(itemID)
  decorID = tonumber(decorID)
  if itemID and itemID > 0 then return "item:" .. itemID end
  if decorID and decorID > 0 then return "decor:" .. decorID end
  return nil
end

local function shallowCopy(t)
  local out = {}
  for k, v in pairs(t) do out[k] = v end
  return out
end

local function catalogItem(decorID)
  decorID = tonumber(decorID)
  if not decorID then return nil end

  local search = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Search
  if search and search.FindByDecorID then
    local found = search.FindByDecorID(decorID)
    if found then return found end
  end

  local GI = NS.Systems and NS.Systems.GlobalIndex
  if GI and GI.Ensure then GI:Ensure() end
  return GI and GI.byItemID and GI.byItemID[decorID]
end

local function buildBaseEntry(reqItem, resolvedSource)
  local itemID = tonumber(reqItem.itemID)
  local decorID = (tonumber(reqItem.contentType) == 3) and tonumber(reqItem.recordID) or nil
  local source = resolvedSource or (decorID and catalogItem(decorID))

  local entry = source and shallowCopy(source) or {}
  entry.itemID = itemID or entry.itemID
  entry.decorID = decorID or entry.decorID
  if not entry.title or entry.title == "" then
    entry.title = reqItem.name
  end

  return entry, resolveKey(itemID, decorID)
end

function BlueprintList:AddMissing(req, blueprintName)
  local d = db()
  if not d or not req then return 0 end
  blueprintName = (type(blueprintName) == "string" and blueprintName ~= "") and blueprintName or "Blueprint"

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

  local touched = 0
  for _, reqItem in ipairs(req.items or {}) do
    local missing = tonumber(reqItem.missing) or 0
    if missing > 0 and not reqItem.invalid then
      local decorID = (tonumber(reqItem.contentType) == 3) and tonumber(reqItem.recordID) or nil
      local entry, key = buildBaseEntry(reqItem, decorID and resolved[decorID])
      if key then
        local category = d[blueprintName]
        if not category then
          category = {}
          d[blueprintName] = category
        end

        local existing = category[key]
        if existing then
          existing.needed = missing
          existing.have = tonumber(reqItem.have) or existing.have
          existing.kind = reqItem.kind or existing.kind
        else
          entry.needed = missing
          entry.have = tonumber(reqItem.have) or 0
          entry.kind = reqItem.kind
          category[key] = entry
        end
        touched = touched + 1
      end
    end
  end

  if touched > 0 then notify() end
  return touched
end

function BlueprintList:Remove(categoryName, key)
  local d = db()
  local category = d and categoryName and d[categoryName]
  if not category or not key or not category[key] then return end
  category[key] = nil
  if not next(category) then d[categoryName] = nil end
  notify()
end

function BlueprintList:RemoveCategory(categoryName)
  local d = db()
  if not d or not categoryName or not d[categoryName] then return end
  d[categoryName] = nil
  notify()
end

function BlueprintList:Clear()
  local d = db()
  if not d or not next(d) then return end
  wipe(d)
  notify()
end

function BlueprintList:Count()
  local d = db()
  if not d then return 0 end
  local n = 0
  for _, category in pairs(d) do
    for _ in pairs(category) do n = n + 1 end
  end
  return n
end

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
  local st = it.source and it.source.type
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

return BlueprintList
