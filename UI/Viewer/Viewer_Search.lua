local ADDON, NS = ...

NS.UI = NS.UI or {}
local View = NS.UI.Viewer
local Search = View.Search
local Util = View.Util
local Data = View.Data

local Filters = NS.Systems and NS.Systems.Filters

local Trim = Util.Trim
local Copy = Util.CopyShallow

local function SlimVendor(v)
  return Data.SlimVendor(v)
end

local function Hydrate(it, ui, db)
  return Data.HydrateFromDecorIndex(it, ui, db)
end

local function BuildGlobalSearchResults(ui, db)
  local out = {}
  if not Filters or not Filters.Passes then return out end

  local uiSearch = Copy(ui or {})
  uiSearch.activeCategory = "Search"

  local q = Trim((uiSearch.search or ""))
  if q:lower() == "all" then
    uiSearch.search = ""
  end

  local bestByDecor = {}

  local function Prefer(it)
    local id = it and it.decorID
    if not id then return end

    local cur = bestByDecor[id]
    if not cur then
      bestByDecor[id] = it
      return
    end

    local curTitle = cur.title
    local newTitle = it.title
    if (not curTitle or curTitle == "") and (newTitle and newTitle ~= "") then
      bestByDecor[id] = it
      return
    end

    local curItemID = (cur.source and cur.source.itemID) or cur.itemID
    local newItemID = (it.source and it.source.itemID) or it.itemID
    if not curItemID and newItemID then
      bestByDecor[id] = it
    end
  end

  local data = NS.Data or {}

  local vendors = data.Vendors
  if type(vendors) == "table" then
    for expName, expTbl in pairs(vendors) do
      if type(expTbl) == "table" then
        for zoneName, zoneTbl in pairs(expTbl) do
          if type(zoneTbl) == "table" then
            for _, vendor in ipairs(zoneTbl) do
              if type(vendor) == "table" and type(vendor.items) == "table" then
                local vSlim = SlimVendor(vendor)
                for _, vitem in ipairs(vendor.items) do
                  if type(vitem) == "table" and vitem.decorID then
                    local it = Copy(vitem)
                    it.source = it.source or {}
                    it.source.type = it.source.type or "vendor"
                    it.vendor = it.vendor or vSlim
                    it._navVendor = it._navVendor or vSlim
                    it._expansion = it._expansion or expName
                    it.zone = it.zone or (vSlim and vSlim.zone) or zoneName

                    if Filters:Passes(it, uiSearch, db) then
                      Prefer(it)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  local function CollectCategory(catTbl, srcType)
    if type(catTbl) ~= "table" then return end
    for expName, expTbl in pairs(catTbl) do
      if type(expTbl) == "table" then
        for zoneName, list in pairs(expTbl) do
          if type(list) == "table" then
            for _, ptr in ipairs(list) do
              if type(ptr) == "table" and ptr.decorID then
                local it = Copy(ptr)
                it.source = it.source or {}
                it.source.type = srcType
                it._expansion = it._expansion or expName
                it.zone = it.zone or zoneName
                Hydrate(it, uiSearch, db)

                if Filters:Passes(it, uiSearch, db) then
                  Prefer(it)
                end
              end
            end
          end
        end
      end
    end
  end

  CollectCategory(data.Achievements, "achievement")
  CollectCategory(data.Quests, "quest")

  local function Scan(node, forcedType)
    if type(node) ~= "table" then return end

    if node.decorID then
      local it = Copy(node)
      it.source = it.source or {}
      it.source.type = it.source.type or forcedType or "unknown"
      Hydrate(it, uiSearch, db)
      if Filters:Passes(it, uiSearch, db) then
        Prefer(it)
      end
      return
    end

    if node[1] ~= nil then
      for _, child in ipairs(node) do
        Scan(child, forcedType)
      end
      return
    end

    for _, v in pairs(node) do
      Scan(v, forcedType)
    end
  end

  Scan(data.Drops, "drop")
  Scan(data.Professions, "profession")
  Scan(data.PvP or data.PVP, "pvp")
  Scan(data.SavedItems or data["Saved Items"], "saved")

  for _, it in pairs(bestByDecor) do
    out[#out + 1] = it
  end

  table.sort(out, function(a, b)
    return tostring(a.title or ""):lower() < tostring(b.title or ""):lower()
  end)

  return out
end

local function AttachVendorCtx(it, vendor)
  if type(it) ~= "table" or type(vendor) ~= "table" then return it end

  it._navVendor = it._navVendor or vendor
  it.vendor = it.vendor or vendor

  local vsrc = vendor.source
  local vf = vendor.faction or (vsrc and vsrc.faction)
  if vf == "Alliance" or vf == "Horde" then
    it.faction = vf
    it.source = it.source or {}
    it.source.faction = vf
  end

  if not it.zone then
    it.zone = vendor.zone or (vsrc and vsrc.zone)
  end
  if not it.worldmap then
    it.worldmap = vendor.worldmap or (vsrc and vsrc.worldmap)
  end

  return it
end

local function CollectAllFavorites(db)
  db = db or NS.db
  if not db or not db.favorites then return {} end

  local out, seen = {}, {}

  for _, category in pairs(NS.Data or {}) do
    for _, expansions in pairs(category or {}) do
      for _, entries in pairs(expansions or {}) do
        if type(entries) == "table" then
          for _, it in ipairs(entries) do
            if type(it) == "table" and it.source and it.source.type == "vendor" and type(it.items) == "table" then
              local vSlim = SlimVendor(it)
              for _, vit in ipairs(it.items) do
                local id = Util.GetItemID(vit)
                if id and db.favorites[id] and not seen[id] then
                  seen[id] = true
                  local leaf = Copy(vit)
                  AttachVendorCtx(leaf, vSlim or it)
                  out[#out + 1] = leaf
                end
              end
            else
              local id = Util.GetItemID(it)
              if id and db.favorites[id] and not seen[id] then
                seen[id] = true
                out[#out + 1] = Copy(it)
              end
            end
          end
        end
      end
    end
  end

  table.sort(out, function(a, b)
    return tostring(a.title or "") < tostring(b.title or "")
  end)

  return out
end

Search.BuildGlobalSearchResults = BuildGlobalSearchResults
Search.AttachVendorCtx = AttachVendorCtx
Search.CollectAllFavorites = CollectAllFavorites

return Search
