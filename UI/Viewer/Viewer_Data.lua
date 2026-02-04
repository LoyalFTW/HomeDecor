local ADDON, NS = ...

NS.UI = NS.UI or {}
local View = NS.UI.Viewer
if not View then return end

local Data = View.Data
if not Data then return end

local DecorIndex = NS.Systems and NS.Systems.DecorIndex

Data.TEX_ALLI  = "Interface\\Icons\\INV_BannerPVP_02"
Data.TEX_HORDE = "Interface\\Icons\\INV_BannerPVP_01"

Data.CATEGORY_MAP = Data.CATEGORY_MAP or {
  ["Vendors"]       = "Vendors",
  ["Drops"]         = "Drops",
  ["Quests"]        = "Quests",
  ["Achievements"]  = "Achievements",
  ["Professions"]   = "Professions",
  ["PvP"]           = "PvP",
  ["PVP"]           = "PvP",
  ["Pvp"]           = "PvP",
  ["pvp"]           = "PvP",
  ["Search"]        = "Vendors",
}

local EXPANSION_RANK = {
  Classic = 1,

  BurningCrusade = 2, ["Burning Crusade"] = 2, Outland = 2,
  Wrath = 3, ["Wrath of the Lich King"] = 3, Northrend = 3,
  Cataclysm = 4, Cata = 4,
  Pandaria = 5, MistsOfPandaria = 5, ["Mists of Pandaria"] = 5, Pandaren = 5,
  WarlordsOfDraenor = 6, ["Warlords of Draenor"] = 6, Draenor = 6,
  Legion = 7,
  BattleForAzeroth = 8, ["Battle for Azeroth"] = 8, Kul = 8,
  Shadowlands = 9,
  Dragonflight = 10, Dragon = 10,
  WarWithin = 11, TheWarWithin = 11, ["The War Within"] = 11, Khaz = 11,
}

local function ExpansionRank(name)
  if not name then return 999 end
  return EXPANSION_RANK[name] or 999
end

function Data.GetExpansionOrder(t)
  local order = {}
  if type(t) ~= "table" then return order end
  for k in pairs(t) do order[#order + 1] = k end
  table.sort(order, function(a, b)
    local ra, rb = ExpansionRank(a), ExpansionRank(b)
    if ra ~= rb then return ra < rb end
    return tostring(a) < tostring(b)
  end)
  return order
end

local DecorIconCache, DecorNameCache = {}, {}
local AchTitleCache, QuestTitleCache = {}, {}
local VendorPickCache = {}

local function _capCache(t, max)
  if not t then return end
  local n = 0
  for _ in pairs(t) do
    n = n + 1
    if n > max then break end
  end
  if n > max then
    for k in pairs(t) do t[k] = nil end
  end
end

local function _trim(s)
  if type(s) ~= "string" then return nil end
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s == "" then return nil end
  return s
end

local function _hasValue(v)
  return v ~= nil and v ~= false and v ~= ""
end

local function _extractItemID(entry)
  if type(entry) ~= "table" then return nil end
  local id = entry.itemID or entry.itemId
  if not id and type(entry.item) == "table" then
    id = entry.item.itemID or entry.item.itemId or entry.item.id
  end
  if not id and type(entry.source) == "table" then
    id = entry.source.itemID or entry.source.itemId
  end
  id = tonumber(id)
  if id and id > 0 then return id end
  return nil
end

local function _extractRequirements(entry)
  if type(entry) ~= "table" then return nil end
  if type(entry.requirements) == "table" then return entry.requirements end
  if type(entry.requirement) == "table" then return entry.requirement end
  if type(entry.reqs) == "table" then return entry.reqs end
  return nil
end

local function VendorFaction(v)
  if type(v) ~= "table" then return nil end
  local src = v.source or {}
  local f = v.faction or src.faction
  if f == "Alliance" or f == "Horde" then return f end
  if f == "Neutral" then return "Neutral" end
  return nil
end

local function VendorKeyFromCtx(decorID, expName, zoneKey, desiredFaction)
  return tostring(expName) .. "\031" .. tostring(zoneKey) .. "\031" .. tostring(decorID) .. "\031" .. tostring(desiredFaction or "")
end

local function PickVendorFromZoneData(decorID, expName, zoneKey, desiredFaction)
  if not decorID or not expName or not zoneKey then return nil end

  local k = VendorKeyFromCtx(decorID, expName, zoneKey, desiredFaction)
  local cached = VendorPickCache[k]
  if cached ~= nil then
    if cached == false then return nil end
    return cached.vendor, cached.item
  end

  local vendorsByExp = NS.Data and NS.Data.Vendors and NS.Data.Vendors[expName]
  local list = vendorsByExp and vendorsByExp[zoneKey]
  if type(list) ~= "table" then
    VendorPickCache[k] = false
    return nil
  end

  local bestVendor, bestItem, bestScore = nil, nil, -1
  for _, v in ipairs(list) do
    local items = v and v.items
    if type(items) == "table" then
      local f = VendorFaction(v)
      local facScore = 0
      if desiredFaction and f == desiredFaction then
        facScore = 2
      elseif f == "Neutral" then
        facScore = 1
      end

      if facScore >= bestScore then
        for _, vi in ipairs(items) do
          if vi and vi.decorID == decorID then
            if facScore > bestScore or not bestVendor then
              bestScore = facScore
              bestVendor = v
              bestItem = vi
            end
            if bestScore == 2 then break end
          end
        end
      end
    end
    if bestScore == 2 then break end
  end

  if bestVendor then
    VendorPickCache[k] = { vendor = bestVendor, item = bestItem }
    return bestVendor, bestItem
  end

  VendorPickCache[k] = false
  return nil
end

local Catalog = _G.C_HousingCatalog
local Enum = _G.Enum
local pcall = _G.pcall
local tonumber = _G.tonumber
local pairs = _G.pairs
local type = _G.type

local _decorEntryType
local _entryTypeTried = {}

local function _tryEntryInfo(entryType, recordID, tryOwned)
  if not Catalog or not Catalog.GetCatalogEntryInfoByRecordID then return nil end
  local ok, info = pcall(Catalog.GetCatalogEntryInfoByRecordID, entryType, recordID, tryOwned and true or false)
  if ok and type(info) == "table" then return info end
  return nil
end

local function _discoverDecorEntryType(sampleDecorID)
  if not Catalog or not Catalog.GetCatalogEntryInfoByRecordID or not sampleDecorID then return nil end

  if Enum and Enum.HousingCatalogEntryType then
    for _, v in pairs(Enum.HousingCatalogEntryType) do
      if type(v) == "number" and not _entryTypeTried[v] then
        _entryTypeTried[v] = true
        local info = _tryEntryInfo(v, sampleDecorID, true) or _tryEntryInfo(v, sampleDecorID, false)
        if info then return v end
      end
    end
  end

  for v = 0, 30 do
    if not _entryTypeTried[v] then
      _entryTypeTried[v] = true
      local info = _tryEntryInfo(v, sampleDecorID, true) or _tryEntryInfo(v, sampleDecorID, false)
      if info then return v end
    end
  end

  return nil
end

local function _extractIDs(entry)
  if type(entry) ~= "table" then return nil, nil end

  local catID = entry.categoryID or entry.categoryId
  local subID = entry.subcategoryID or entry.subcategoryId

  if not catID and type(entry.categoryIDs) == "table" then
    catID = entry.categoryIDs[1]
  end

  if not subID and type(entry.subcategoryIDs) == "table" then
    subID = entry.subcategoryIDs[1]
  end

  if not catID and type(entry.category) == "table" then
    catID = entry.category.ID or entry.category.id or entry.category.categoryID
  end
  if not subID and type(entry.subcategory) == "table" then
    subID = entry.subcategory.ID or entry.subcategory.id or entry.subcategory.subcategoryID
  end

  catID = tonumber(catID)
  subID = tonumber(subID)
  return catID, subID
end

function Data.GetDecorCatalogEntry(decorID)
  if not Catalog then return nil end
  if not decorID then return nil end

  if Catalog.GetCatalogEntryInfoByRecordID then
    if not _decorEntryType then
      _decorEntryType = _discoverDecorEntryType(decorID)
    end
    if _decorEntryType then
      local info = _tryEntryInfo(_decorEntryType, decorID, true) or _tryEntryInfo(_decorEntryType, decorID, false)
      if info then return info end
    end
  end

  if Catalog.GetCatalogEntryInfo then
    local ok, info
    if _decorEntryType then
      ok, info = pcall(Catalog.GetCatalogEntryInfo, _decorEntryType, decorID, true)
      if ok and type(info) == "table" then return info end
      ok, info = pcall(Catalog.GetCatalogEntryInfo, _decorEntryType, decorID, false)
      if ok and type(info) == "table" then return info end
      ok, info = pcall(Catalog.GetCatalogEntryInfo, _decorEntryType, decorID)
      if ok and type(info) == "table" then return info end
    end

    ok, info = pcall(Catalog.GetCatalogEntryInfo, decorID)
    if ok and type(info) == "table" then return info end
  end

  return nil
end

Data._catalogCats = Data._catalogCats or {}
Data._catalogSubs = Data._catalogSubs or {}
Data._catalogTaxonomyLoaded = Data._catalogTaxonomyLoaded or false

function Data.EnsureCatalogTaxonomy()
  if Data._catalogTaxonomyLoaded then return true end
  if not C_HousingCatalog or not C_HousingCatalog.SearchCatalogCategories then return false end
  if not Enum or not Enum.HouseEditorMode or not Enum.HouseEditorMode.BasicDecor then return false end

  local ids = C_HousingCatalog.SearchCatalogCategories({
    withOwnedEntriesOnly = false,
    editorModeContext = Enum.HouseEditorMode.BasicDecor,
  })
  if type(ids) ~= "table" or #ids == 0 then return false end

  for i = 1, #ids do
    local catID = ids[i]
    local info = C_HousingCatalog.GetCatalogCategoryInfo(catID)
    if info then
      Data._catalogCats[catID] = info
      if info.subcategoryIDs then
        for j = 1, #info.subcategoryIDs do
          local subID = info.subcategoryIDs[j]
          local subInfo = C_HousingCatalog.GetCatalogSubcategoryInfo(subID)
          if subInfo then
            Data._catalogSubs[subID] = subInfo
          end
        end
      end
    end
  end

  Data._catalogTaxonomyLoaded = true
  return true
end

function Data.GetDecorBreadcrumbFromCatalog(decorID)
  if not Catalog or not decorID then return nil, nil, nil, nil, nil end

  local entry = Data.GetDecorCatalogEntry(decorID)
  Data.EnsureCatalogTaxonomy()
  if not entry then return nil, nil, nil, nil, nil end

  local catID, subID = _extractIDs(entry)
  local catName, subName

  if subID and Catalog.GetCatalogSubcategoryInfo then
    local subInfo = Catalog.GetCatalogSubcategoryInfo(subID)
    if type(subInfo) == "table" then
      subName = _trim(subInfo.name)
      if not catID then
        catID = tonumber(subInfo.categoryID or subInfo.categoryId)
        if not catID and type(subInfo.category) == "table" then
          catID = tonumber(subInfo.category.ID or subInfo.category.id)
        end
      end
    end
  end

  if catID and Catalog.GetCatalogCategoryInfo then
    local catInfo = Catalog.GetCatalogCategoryInfo(catID)
    if type(catInfo) == "table" then
      catName = _trim(catInfo.name)
    end
  end

  if not catName and not subName then return nil, nil, nil, nil, nil end

  local breadcrumb
  if catName and subName then
    breadcrumb = catName .. " - " .. subName
  else
    breadcrumb = catName or subName
  end

  return catID, subID, breadcrumb, catName, subName
end

function Data.DecorBreadcrumbFrom(it)
  if type(it) ~= "table" then return nil, nil, nil, nil, nil end

  if it.decorID then
    local catID, subID, crumb, catName, subName = Data.GetDecorBreadcrumbFromCatalog(it.decorID)
    if crumb then return catID, subID, crumb, catName, subName end
  end

  local tax = NS.Data and NS.Data.DecorTaxonomy
  if tax and it.decorID and tax[it.decorID] then
    local t = tax[it.decorID]
    local cat = _trim(t.category)
    local sub = _trim(t.subcategory)
    if cat and sub then return nil, nil, (cat .. " - " .. sub), cat, sub end
    if cat then return nil, nil, cat, cat, nil end
    if sub then return nil, nil, sub, nil, sub end
  end

  local raw = _trim(it.decorType)
  if raw then
    return nil, nil, raw, nil, nil
  end

  return nil, nil, nil, nil, nil
end

function Data.ApplyDecorBreadcrumb(it)
  if type(it) ~= "table" then return end
  local catID, subID, crumb, catName, subName = Data.DecorBreadcrumbFrom(it)
  it.catalogCategoryID = catID
  it.catalogSubcategoryID = subID
  it.catalogCategoryName = catName
  it.catalogSubcategoryName = subName
  it.decorTypeBreadcrumb = crumb
end

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local GetTime = _G.GetTime

local VendorNameCache = {}
local VendorFailUntil = {}
local VendorNameTip

local function GetVendorTooltip()
  if VendorNameTip then return VendorNameTip end
  VendorNameTip = CreateFrame("GameTooltip", "HomeDecorVendorNameTip", UIParent, "GameTooltipTemplate")
  VendorNameTip:SetOwner(UIParent, "ANCHOR_NONE")
  return VendorNameTip
end

local function TooltipNPCName(npcID)
  npcID = tonumber(npcID)
  if not npcID then return nil end

  local tip = GetVendorTooltip()
  if not tip or not tip.SetHyperlink then return nil end

  local left1 = _G["HomeDecorVendorNameTipTextLeft1"]
  local links = {
    ("unit:Creature-0-0-0-0-%d-0000000000"):format(npcID),
    ("unit:Creature-0-0-0-0-%d"):format(npcID),
  }

  for i = 1, #links do
    tip:ClearLines()
    local ok = pcall(tip.SetHyperlink, tip, links[i])
    if ok and left1 and left1.GetText then
      local name = left1:GetText()
      if type(name) == "string" and name ~= "" then
        return name
      end
    end
  end

  return nil
end

function Data.GetVendorName(npcID)
  npcID = tonumber(npcID)
  if not npcID then return nil end

  local cached = VendorNameCache[npcID]
  if cached ~= nil then return cached end

  local now = GetTime and GetTime() or 0
  local untilT = VendorFailUntil[npcID]
  if untilT and untilT > now then
    return nil
  end

  local name = TooltipNPCName(npcID)
  if type(name) == "string" and name ~= "" then
    VendorNameCache[npcID] = name
    VendorFailUntil[npcID] = nil
    return name
  end

  VendorFailUntil[npcID] = now + 2.0
  return nil
end

function Data.ResolveVendorTitle(vendor)
  if type(vendor) ~= "table" then return nil end
  if type(vendor.title) == "string" and vendor.title ~= "" then return vendor.title end
  local src = vendor.source or {}
  local id = src.id or vendor.id
  return Data.GetVendorName(id)
end

function Data.SlimVendor(v)
  if type(v) ~= "table" then return nil end
  local src = v.source

  local title = v.title
  if (not title or title == "") then
    title = Data.ResolveVendorTitle(v)
  end

  return {
    title    = title,
    name     = v.name,
    zone     = v.zone or (src and src.zone),
    faction  = v.faction or (src and src.faction),
    worldmap = v.worldmap or (src and src.worldmap),
    source   = src,
  }
end

function Data.GetDecorIcon(decorID)
  if not decorID then return end
  if DecorIconCache[decorID] ~= nil then return DecorIconCache[decorID] or nil end

  local entry = Data.GetDecorCatalogEntry(decorID)
  local icon = entry and (entry.iconTexture or entry.icon)
  if icon then
    DecorIconCache[decorID] = icon
    return icon
  end

  DecorIconCache[decorID] = false
end

function Data.GetDecorName(decorID)
  if not decorID then return end
  if DecorNameCache[decorID] ~= nil then return DecorNameCache[decorID] or nil end

  local entry = Data.GetDecorCatalogEntry(decorID)
  local n = entry and entry.name
  if type(n) == "string" and n ~= "" then
    DecorNameCache[decorID] = n
    return n
  end

  DecorNameCache[decorID] = false
end

function Data.GetAchievementTitle(id)
  id = tonumber(id)
  if not id then return end
  if AchTitleCache[id] ~= nil then return AchTitleCache[id] or nil end

  if not GetAchievementInfo then
    AchTitleCache[id] = false
    return
  end

  local name = select(2, GetAchievementInfo(id))
  if name and name ~= "" then
    AchTitleCache[id] = name
    return name
  end

  AchTitleCache[id] = false
end

function Data.GetQuestTitle(id)
  id = tonumber(id)
  if not id then return end
  if QuestTitleCache[id] ~= nil then return QuestTitleCache[id] or nil end

  if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
    C_QuestLog.RequestLoadQuestByID(id)
  end

  local name
  if C_QuestLog and C_QuestLog.GetTitleForQuestID then
    name = C_QuestLog.GetTitleForQuestID(id)
  end

  if name and name ~= "" then
    QuestTitleCache[id] = name
    return name
  end

  QuestTitleCache[id] = false
end

function Data.NormalizeExpansionNode(expNode)
  if type(expNode) ~= "table" then return {} end

  local isArray, count = true, 0
  for k in pairs(expNode) do
    if type(k) ~= "number" then isArray = false break end
    count = count + 1
  end

  if isArray and count > 0 then
    return { ["ALL"] = expNode }
  end

  return expNode
end

function Data.PickDecorIndexVendor(entry, ui, db)
  if type(entry) ~= "table" then return nil end

  local vendors = entry.vendors or (entry.vendor and { entry.vendor }) or {}
  local f = db and db.filters or {}
  local wantFaction = f.faction
  local wantZone = f.zone

  local function vendFaction(v)
    if type(v) ~= "table" then return nil end
    local src = v.source or {}
    return v.faction or src.faction or "Neutral"
  end

  local function vendZone(v)
    if type(v) ~= "table" then return nil end
    local src = v.source or {}
    return v.zone or src.zone
  end

  local function matches(v)
    local vf = vendFaction(v)
    local vz = vendZone(v)

    if wantFaction and wantFaction ~= "ALL" then
      if vf ~= "Neutral" and vf ~= wantFaction then return false end
    end

    if wantZone and wantZone ~= "ALL" and vz and vz ~= wantZone then
      return false
    end

    return true
  end

  local bestNeutral

  for _, v in ipairs(vendors) do
    if matches(v) then
      if wantFaction and wantFaction ~= "ALL" and vendFaction(v) == wantFaction then
        return v
      end
      if vendFaction(v) == "Neutral" then
        bestNeutral = bestNeutral or v
      else
        return v
      end
    end
  end

  if bestNeutral then
    return bestNeutral
  end

  if wantFaction and wantFaction ~= "ALL" then
    return nil
  end

  return entry.vendor or vendors[1]
end

function Data.AttachVendorCtx(it, vendor)
  if type(it) ~= "table" or type(vendor) ~= "table" then return it end

  it._navVendor = vendor
  it.vendor = vendor

  local vsrc = vendor.source or {}

  local vf = vendor.faction or vsrc.faction
  if vf == "Alliance" or vf == "Horde" then
    it.faction = vf
    it.source = it.source or {}
    it.source.faction = it.source.faction or vf
  end

  local vz = vendor.zone or vsrc.zone
  if vz then
    it.zone = it.zone or vz
    it.source = it.source or {}
    it.source.zone = it.source.zone or vz
  end

  local vm = vendor.worldmap or vsrc.worldmap
  if vm then
    it.worldmap = it.worldmap or vm
    it.source = it.source or {}
    it.source.worldmap = it.source.worldmap or vm
  end

  local vid = vsrc.id
  if vid then
    it.npcID = it.npcID or vid
    it.source = it.source or {}
    it.source.npcID = it.source.npcID or vid
  end

  return it
end

local function _copyTableShallow(src)
  local t = {}
  if type(src) ~= "table" then return t end
  for k, v in pairs(src) do t[k] = v end
  return t
end

function Data.HydrateFromDecorIndex(it, ui, db)
  if not it or type(it) ~= "table" then return it end

  if it.decorID and DecorIndex then
    local entry = DecorIndex[it.decorID]
    if entry and entry.item then
      local vitem = entry.item

      if (not _hasValue(it.title)) or it.title == tostring(it.decorID) then
        it.title = it.title or vitem.title
        local cname = Data.GetDecorName(it.decorID)
        if cname then it.title = cname end
      end

      local itemID = (vitem.source and (vitem.source.itemID or vitem.source.itemId)) or vitem.itemID or vitem.itemId

      if not itemID then
        local entryInfo = Data.GetDecorCatalogEntry(it.decorID)
        itemID = _extractItemID(entryInfo)
        if not it.requirements then
          local req = _extractRequirements(entryInfo)
          if type(req) == "table" then it.requirements = req end
        end
      end

      it.source = it.source or {}
      if itemID then
        it.itemID = it.itemID or itemID
        it.source.itemID = it.source.itemID or itemID
      end

      local bestVendor = Data.PickDecorIndexVendor(entry, ui, db)
      local slim = bestVendor and Data.SlimVendor(bestVendor) or nil
      if slim then
        it.vendor = it.vendor or slim
        it._navVendor = it._navVendor or slim

        if not it.faction then
          local vf = slim.faction or (slim.source and slim.source.faction)
          if vf and vf ~= "Neutral" then
            it.faction = vf
            it.source = it.source or {}
            it.source.faction = it.source.faction or vf
          end
        end
      end
    end
  end

  if not it.itemID or (it.requirements == nil) then
    local entryInfo = Data.GetDecorCatalogEntry(it.decorID)
    if entryInfo then
      if not it.itemID then
        local cid = _extractItemID(entryInfo)
        if cid then
          it.itemID = it.itemID or cid
          it.source = it.source or {}
          it.source.itemID = it.source.itemID or cid
        end
      end
      if it.requirements == nil then
        local req = _extractRequirements(entryInfo)
        if type(req) == "table" then it.requirements = req end
      end
    end
  end

  it._hdHydrated = true
  Data.ApplyDecorBreadcrumb(it)

  if it.vendor and (not it.vendor.title or it.vendor.title == "" or it.vendor.title:match("^%d+$")) then
    local t = Data.ResolveVendorTitle(it.vendor)
    if t then it.vendor.title = t end
  end

  return it
end

function Data.ResolveAchievementDecor(it)
  if not it or type(it) ~= "table" or not it.decorID then return it end
  local st = it.source and it.source.type
  if st ~= "achievement" and st ~= "quest" and st ~= "pvp" then
    return Data.HydrateFromDecorIndex(it)
  end

  local resolved = _copyTableShallow(it)
  resolved.source = _copyTableShallow(it.source)

  Data.HydrateFromDecorIndex(resolved)

  local desiredFaction = resolved.faction or (resolved.source and resolved.source.faction)
  if desiredFaction ~= "Alliance" and desiredFaction ~= "Horde" then
    local pf = UnitFactionGroup and UnitFactionGroup("player")
    if pf == "Alliance" or pf == "Horde" then desiredFaction = pf else desiredFaction = nil end
  end

  local picked, pickedItem
  local expName = resolved._expansion
  local zoneKey = resolved._navZoneKey
  if expName and zoneKey then
    picked, pickedItem = PickVendorFromZoneData(resolved.decorID, expName, zoneKey, desiredFaction)
  end

  if DecorIndex then
    local entry = DecorIndex[resolved.decorID]
    local vendors = entry and (entry.vendors or (entry.vendor and { entry.vendor })) or nil

    if not picked and desiredFaction and type(vendors) == "table" then
      for _, v in ipairs(vendors) do
        if VendorFaction(v) == desiredFaction then
          picked = v
          break
        end
      end
      if not picked then
        for _, v in ipairs(vendors) do
          if VendorFaction(v) == "Neutral" then
            picked = v
            break
          end
        end
      end
    end

    if not picked and not desiredFaction then
      picked = picked or (entry and entry.vendor) or (vendors and vendors[1])
    end

    if picked then
      local slim = Data.SlimVendor(picked) or picked
      Data.AttachVendorCtx(resolved, slim)

      if not resolved.vendor or not resolved.vendor.title or resolved.vendor.title == "" then
        local t = Data.ResolveVendorTitle(slim)
        if t then
          resolved.vendor = resolved.vendor or {}
          resolved.vendor.title = t
          if resolved._navVendor then resolved._navVendor.title = t end
        end
      end
    end

    local itemID
    if pickedItem and pickedItem.source and (pickedItem.source.itemID or pickedItem.source.itemId) then
      itemID = pickedItem.source.itemID or pickedItem.source.itemId
    elseif entry and entry.item then
      local vi = entry.item
      itemID = (vi.source and (vi.source.itemID or vi.source.itemId)) or vi.itemID or vi.itemId
    end
    itemID = tonumber(itemID)
    if itemID then
      it.itemID = it.itemID or itemID
      it.source = it.source or {}
      it.source.itemID = it.source.itemID or itemID
    end

    if st == "achievement" then
      local req = it.requirements or (entry and entry.item and entry.item.requirements)
      local ach = req and req.achievement
      if ach then
        it.source.id = it.source.id or ach.id
        it.source.name = it.source.name or Data.GetAchievementTitle(ach.id) or ach.title
      end
    elseif st == "quest" then
      local req = it.requirements or (entry and entry.item and entry.item.requirements)
      local q = (req and req.quest) or (pickedItem and pickedItem.requirements and pickedItem.requirements.quest)
      if q then
        it.source.id = it.source.id or q.id
        it.source.questID = it.source.questID or q.id
        it.source.name = it.source.name or Data.GetQuestTitle(q.id) or q.title
      end
    end
  end

  it._hdResolvedAQ = true
  Data.ApplyDecorBreadcrumb(it)

  if it.vendor and (not it.vendor.title or it.vendor.title == "" or it.vendor.title:match("^%d+$")) then
    local t = Data.ResolveVendorTitle(it.vendor)
    if t then it.vendor.title = t end
  end

  return resolved
end

function Data.GetActiveData(ui)
  ui = ui or {}
  local raw = ui.activeCategory
  local key = (Data.CATEGORY_MAP and Data.CATEGORY_MAP[raw]) or raw

  if not key or not NS.Data then return nil end

  local t = NS.Data[key]
  if t ~= nil then return t end

  if key == "PvP" then
    return NS.Data.PvP or NS.Data.PVP or NS.Data.Pvp or NS.Data.pvp
  end

  if raw == "PVP" or raw == "Pvp" or raw == "pvp" then
    return NS.Data.PvP or NS.Data.PVP or NS.Data.Pvp or NS.Data.pvp
  end

  return nil
end

function Data.KeyExp(cat, exp) return tostring(cat) .. ":exp:" .. tostring(exp) end
function Data.KeyZone(cat, exp, zone) return tostring(cat) .. ":zone:" .. tostring(exp) .. ":" .. tostring(zone) end
function Data.KeyVendor(cat, exp, zone, vendorID)
  return tostring(cat) .. ":vendor:" .. tostring(exp) .. ":" .. tostring(zone) .. ":" .. tostring(vendorID)
end

return Data
