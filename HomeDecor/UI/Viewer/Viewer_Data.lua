local ADDON, NS = ...

NS.UI = NS.UI or {}
local View = NS.UI.Viewer
if not View then return end

local Data = View.Data
if not Data then return end

local DecorIndex = NS.Systems and NS.Systems.DecorIndex
local NPCNames = NS.Systems and NS.Systems.NPCNames

Data.TEX_ALLI  = "Interface\\FriendsFrame\\PlusManz-Alliance"
Data.TEX_HORDE = "Interface\\FriendsFrame\\PlusManz-Horde"

local function NormalizeFaction(value)
  if type(value) ~= "string" then return nil end
  local v = value:gsub("^%s+", ""):gsub("%s+$", ""):lower()
  if v == "alliance" then return "Alliance" end
  if v == "horde" then return "Horde" end
  if v == "neutral" then return "Neutral" end
  return nil
end

local EXPANSION_RANK = {
  Classic = 1,
  Jewelcrafting = 1, Leatherworking = 1, Tailoring = 1,
  BurningCrusade = 2, Outland = 2,
  Wrath = 3, Northrend = 3,
  Cataclysm = 4, Cata = 4,
  Pandaria = 5, MistsOfPandaria = 5, Pandaren = 5,
  Warlords = 6, WarlordsOfDraenor = 6, Draenor = 6,
  Legion = 7,
  BattleForAzeroth = 8, Kul = 8, KulTiras = 8, ["Kul Tiran"] = 8, Zandalar = 8,
  Shadowlands = 9,
  Dragonflight = 10, Dragon = 10, DragonIsles = 10, ["Dragon Isles"] = 10,
  WarWithin = 11, TheWarWithin = 11, Khaz = 11, KhazAlgar = 11, ["Khaz Algar"] = 11,
  Midnight = 12,
}

local function ExpansionRank(name)
  if not name then return 999 end
  return EXPANSION_RANK[name] or 999
end

function Data.GetExpansionOrder(t, reverse)
  local order = {}
  if type(t) ~= "table" then return order end
  for k in pairs(t) do order[#order + 1] = k end
  table.sort(order, function(a, b)
    local ra, rb = ExpansionRank(a), ExpansionRank(b)
    if ra ~= rb then
      if reverse then return ra > rb else return ra < rb end
    end
    if reverse then return tostring(a) > tostring(b) else return tostring(a) < tostring(b) end
  end)
  return order
end

function Data.GetZoneOrder(expNode)
  local zones = {}
  if type(expNode) ~= "table" then return zones end
  for k in pairs(expNode) do
    if type(expNode[k]) == "table" then
      zones[#zones + 1] = k
    end
  end
  table.sort(zones, function(a, b)
    local ra, rb = ExpansionRank(a), ExpansionRank(b)
    if ra ~= rb then return ra < rb end
    return tostring(a):lower() < tostring(b):lower()
  end)
  return zones
end

Data.EXPANSION_RANK = EXPANSION_RANK

local DecorIconCache, DecorNameCache = {}, {}
local AchTitleCache, QuestTitleCache = {}, {}
local QUEST_TITLE_PENDING = {}
local questTitleTooltip
local VendorPickCache = {}
local prefetchQueued = false
local profItemPrefetchQueued = false
local PVP_VENDOR_IDS = {
  [254603] = true,
  [254606] = true,
}

local function EnsureDecorIndex()
  if DecorIndex and DecorIndex.Ensure then
    DecorIndex:Ensure()
  end
  return DecorIndex
end

local function RequestAsyncRefresh()
  View._renderDataEpoch = (View._renderDataEpoch or 0) + 1
  if not NS.Debounce then
    if View and View.instance and View.instance.RequestRender then
      View.instance:RequestRender(true)
    elseif NS.UI and NS.UI.Layout and NS.UI.Layout.Render then
      NS.UI.Layout:Render()
    end
    return
  end

  View._asyncRefresh = View._asyncRefresh or NS.Debounce(0.1, function()
    if View and View.instance and View.instance.RequestRender then
      View.instance:RequestRender(true)
    elseif NS.UI and NS.UI.Layout and NS.UI.Layout.Render then
      NS.UI.Layout:Render()
    end
  end)
  View._asyncRefresh()
end

function Data.GetLocalQuestTitle(id)
  id = tonumber(id)
  local titles = NS.Data and NS.Data.QuestTitles
  return id and titles and titles[id] or nil
end

local function GetQuestTitleFromTooltip(id)
  if not CreateFrame or not UIParent then return nil end

  if not questTitleTooltip then
    questTitleTooltip = CreateFrame("GameTooltip", "HomeDecorQuestTitleTooltip", UIParent, "GameTooltipTemplate")
    questTitleTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  end

  questTitleTooltip:ClearLines()
  local ok = pcall(questTitleTooltip.SetHyperlink, questTitleTooltip, "quest:" .. tostring(id))
  if not ok then return nil end

  local fs = _G.HomeDecorQuestTitleTooltipTextLeft1
  local title = fs and fs.GetText and fs:GetText()
  if title and title ~= "" and not title:match("^Quest%s*#?%d+$") then
    return title
  end

  return nil
end

local function CleanVendorTitle(s)
  if type(s) ~= "string" then return nil end
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s == "" then return nil end
  if s:match("^%d+$") then return nil end
  if s:match("^%[?[Vv]endor%]?%s*#?%s*%d+$") then return nil end
  if s:match("^[Nn][Pp][Cc]%s*#?%s*%d+$") then return nil end
  return s
end

function Data.ResolveVendorTitle(vendor, refreshCallback)
  if type(vendor) ~= "table" then return nil end

  local t = CleanVendorTitle(vendor.name) or CleanVendorTitle(vendor.title)
  if t then return t end

  local src = vendor.source or {}
  local id = tonumber((src and src.id) or vendor.npcID or vendor.id)
  if not id then return nil end

  if NPCNames and NPCNames.Get then
    local duringLookup = true
    local name = NPCNames.Get(id, function(npcID, resolvedName)
      local resolved = CleanVendorTitle(resolvedName)
      if resolved then
        vendor.name = resolved
        vendor.title = resolved
      end
      if not duringLookup then
        if refreshCallback and type(refreshCallback) == "function" then
          refreshCallback(npcID, resolved)
        else
          RequestAsyncRefresh()
        end
      end
    end)
    duringLookup = false
    name = CleanVendorTitle(name)
    if name then return name end
  end

  return nil
end

function Data.PrefetchVendorNames(vendors)
  if not NPCNames or not NPCNames.PrefetchVendors then return end
  NPCNames.PrefetchVendors(vendors)
end

local function VendorFaction(v)
  if type(v) ~= "table" then return nil end
  local src = v.source or {}
  local f = NormalizeFaction(v.faction or src.faction)
  if f == "Alliance" or f == "Horde" then return f end
  if f == "Neutral" then return "Neutral" end
  return nil
end

local function IsPvPVendor(v)
  if type(v) ~= "table" then return false end
  local src = v.source or {}
  local id = tonumber(src.id or v.npcID or v.id)
  return id and PVP_VENDOR_IDS[id] == true or false
end

local function BuildPvPVendorData()
  local out = {}
  local vendors = NS.Data and NS.Data.Vendors
  if type(vendors) ~= "table" then return out end

  for expName, expTbl in pairs(vendors) do
    if type(expTbl) == "table" then
      for zoneName, zoneTbl in pairs(expTbl) do
        if type(zoneTbl) == "table" then
          for _, vendor in ipairs(zoneTbl) do
            if IsPvPVendor(vendor) then
              out[expName] = out[expName] or {}
              out[expName][zoneName] = out[expName][zoneName] or {}
              out[expName][zoneName][#out[expName][zoneName] + 1] = vendor
            end
          end
        end
      end
    end
  end

  return out
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

function Data.SlimVendor(v)
  if type(v) ~= "table" then return nil end
  local src = v.source
  return {
    title    = v.title,
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

  if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then
    DecorIconCache[decorID] = false
    return
  end

  local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
  local icon = info and info.iconTexture
  if icon then
    DecorIconCache[decorID] = icon
    return icon
  end

  DecorIconCache[decorID] = false
end

function Data.GetDecorName(decorID)
  if not decorID then return end
  if DecorNameCache[decorID] ~= nil then return DecorNameCache[decorID] or nil end

  if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then
    DecorNameCache[decorID] = false
    return
  end

  local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
  local n = info and info.name
  if type(n) == "string" and n ~= "" then
    DecorNameCache[decorID] = n
    return n
  end

  DecorNameCache[decorID] = false
end

local CategoryBreadcrumbCache = {}

local function _trim(s)
  if type(s) ~= "string" then return nil end
  s = s:gsub("^%s+", ""):gsub("%s+$", "")
  if s == "" then return nil end
  return s
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

function Data.GetDecorBreadcrumbFromCatalog(decorID)
  if not decorID then return nil, nil, nil, nil, nil end

  if CategoryBreadcrumbCache[decorID] then
    local cached = CategoryBreadcrumbCache[decorID]
    return cached.catID, cached.subID, cached.breadcrumb, cached.catName, cached.subName
  end

  if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then
    CategoryBreadcrumbCache[decorID] = { breadcrumb = nil }
    return nil, nil, nil, nil, nil
  end

  local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
  if not info then
    CategoryBreadcrumbCache[decorID] = { breadcrumb = nil }
    return nil, nil, nil, nil, nil
  end

  local catID, subID = _extractIDs(info)
  local catName, subName

  if subID and C_HousingCatalog.GetCatalogSubcategoryInfo then
    local subInfo = C_HousingCatalog.GetCatalogSubcategoryInfo(subID)
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

  if catID and C_HousingCatalog.GetCatalogCategoryInfo then
    local catInfo = C_HousingCatalog.GetCatalogCategoryInfo(catID)
    if type(catInfo) == "table" then
      catName = _trim(catInfo.name)
    end
  end

  local breadcrumb
  if catName and subName then
    breadcrumb = catName .. " > " .. subName
  elseif catName then
    breadcrumb = catName
  elseif subName then
    breadcrumb = subName
  end

  CategoryBreadcrumbCache[decorID] = {
    catID = catID,
    subID = subID,
    breadcrumb = breadcrumb,
    catName = catName,
    subName = subName
  }

  return catID, subID, breadcrumb, catName, subName
end

function Data.DecorBreadcrumbFrom(it)
  if type(it) ~= "table" then return nil, nil, nil, nil, nil end

  if it.decorID then
    local catID, subID, crumb, catName, subName = Data.GetDecorBreadcrumbFromCatalog(it.decorID)
    if crumb then return catID, subID, crumb, catName, subName end
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

  C_Timer.After(0.1, function()
    if GetAchievementInfo then
      local name = select(2, GetAchievementInfo(id))
      if name and name ~= "" then
        AchTitleCache[id] = name
        RequestAsyncRefresh()
      else
        AchTitleCache[id] = false
      end
    end
  end)

  AchTitleCache[id] = false
  return nil
end

function Data.GetQuestTitle(id)
  id = tonumber(id)
  if not id then return end

  local cached = QuestTitleCache[id]
  if cached ~= nil and cached ~= QUEST_TITLE_PENDING then return cached or nil end

  if C_QuestLog and C_QuestLog.GetTitleForQuestID then
    local ok, name = pcall(C_QuestLog.GetTitleForQuestID, id)
    if ok and name and name ~= "" then
      QuestTitleCache[id] = name
      return name
    end
  end

  local tooltipName = GetQuestTitleFromTooltip(id)
  if tooltipName and tooltipName ~= "" then
    QuestTitleCache[id] = tooltipName
    return tooltipName
  end

  local localName = Data.GetLocalQuestTitle(id)
  if localName and localName ~= "" then
    QuestTitleCache[id] = localName
    return localName
  end

  if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
    pcall(C_QuestLog.RequestLoadQuestByID, id)

    if cached ~= QUEST_TITLE_PENDING and C_Timer and C_Timer.After then
      C_Timer.After(0.1, function()
        if C_QuestLog and C_QuestLog.GetTitleForQuestID then
          local ok, name = pcall(C_QuestLog.GetTitleForQuestID, id)
          if ok and name and name ~= "" then
            QuestTitleCache[id] = name
            RequestAsyncRefresh()
          else
            QuestTitleCache[id] = nil
          end
        end
      end)
    end
  end

  QuestTitleCache[id] = QUEST_TITLE_PENDING
  return nil
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

  local function matches(v)
    if type(v) ~= "table" then return false end
    local src = v.source or {}
    local vf = v.faction or src.faction or "Neutral"
    local vz = v.zone or src.zone

    if wantFaction and wantFaction ~= "ALL" and vf ~= "Neutral" and vf ~= wantFaction then
      return false
    end
    if wantZone and wantZone ~= "ALL" and vz and vz ~= wantZone then
      return false
    end
    return true
  end

  for _, v in ipairs(vendors) do
    if matches(v) then return v end
  end

  return entry.vendor or vendors[1]
end

function Data.HydrateFromDecorIndex(it, ui, db)
  EnsureDecorIndex()
  if not DecorIndex or not it or not it.decorID then return it end

  local entry = DecorIndex[it.decorID]
  if not entry or not entry.item then return it end

  local vitem = entry.item
  it.title = it.title or vitem.title
  it.decorType = it.decorType or vitem.decorType
  if type(it.colors) ~= "table" and type(vitem.colors) == "table" then
    it.colors = vitem.colors
  end
  if it.budgetCost == nil and vitem.budgetCost ~= nil then
    it.budgetCost = vitem.budgetCost
  end
  if (it.size == nil or it.size == "") and vitem.size then
    it.size = vitem.size
  end

  local itemID = (vitem.source and vitem.source.itemID) or vitem.itemID
  it.source = it.source or {}
  if itemID then
    it.itemID = it.itemID or itemID
    it.source.itemID = it.source.itemID or itemID
  end
  if vitem.source then
    it.source.currency = it.source.currency or vitem.source.currency
    it.source.currencytype = it.source.currencytype or vitem.source.currencytype
    it.source.currencyType = it.source.currencyType or vitem.source.currencyType
    it.source.currencyID = it.source.currencyID or vitem.source.currencyID
    it.source.cost = it.source.cost or vitem.source.cost
    it.source.price = it.source.price or vitem.source.price
  end
  local vitemFaction = NormalizeFaction(vitem.faction)
  if vitemFaction == "Alliance" or vitemFaction == "Horde" then
    it.faction = it.faction or vitemFaction
  end
  local vitemSourceFaction = NormalizeFaction(vitem.source and vitem.source.faction)
  if vitemSourceFaction == "Alliance" or vitemSourceFaction == "Horde" then
    it.source.faction = it.source.faction or vitemSourceFaction
  end
  if vitem.zone then
    it.zone = it.zone or vitem.zone
  end
  if vitem.source and vitem.source.zone then
    it.source.zone = it.source.zone or vitem.source.zone
  end

  local bestVendor = Data.PickDecorIndexVendor(entry, ui, db)
  local slim = Data.SlimVendor(bestVendor)
  if slim then
    it.vendor = it.vendor or slim
    it._navVendor = it._navVendor or slim
  end

  Data.ApplyDecorBreadcrumb(it)

  return it
end

function Data.AttachVendorCtx(it, vendor)
  if type(it) ~= "table" or type(vendor) ~= "table" then return it end

  it._navVendor = vendor
  it.vendor = vendor

  local vsrc = vendor.source or {}

  local vf = NormalizeFaction(vendor.faction or vsrc.faction)
  if vf == "Alliance" or vf == "Horde" then
    it.faction = vf
    it.source = it.source or {}
    it.source.faction = vf
  end

  local vz = vendor.zone or vsrc.zone
  if vz then
    it.zone = vz
    it.source = it.source or {}
    it.source.zone = it.source.zone or vz
  end

  local vm = vendor.worldmap or vsrc.worldmap
  if vm then
    it.worldmap = vm
    it.source = it.source or {}
    it.source.worldmap = it.source.worldmap or vm
  end

  local vid = vsrc.id
  if vid then
    it.npcID = vid
    it.source = it.source or {}
    it.source.npcID = it.source.npcID or vid
  end

  return it
end

function Data.ResolveAchievementDecor(it)
  EnsureDecorIndex()
  if not it or not it.decorID or not DecorIndex then return it end

  local st = it.source and it.source.type
  if st ~= "achievement" and st ~= "quest" and st ~= "pvp" then return it end

  local entry = DecorIndex[it.decorID]
  if not entry then return it end

  local resolved = {}
  for k, v in pairs(it) do resolved[k] = v end

  resolved.source = resolved.source or {}
  if it.source then
    for k, v in pairs(it.source) do resolved.source[k] = v end
  end

  local item = entry.item
  if item then
    resolved.title = item.title or resolved.title
    resolved.decorType = item.decorType or resolved.decorType
    local itemFaction = NormalizeFaction(item.faction)
    if itemFaction == "Alliance" or itemFaction == "Horde" then
      resolved.faction = resolved.faction or itemFaction
      resolved.source.faction = resolved.source.faction or itemFaction
    end
    if item.zone then
      resolved.zone = resolved.zone or item.zone
      resolved.source.zone = resolved.source.zone or item.zone
    end
  end

  local desiredFaction = NormalizeFaction(resolved.faction or (resolved.source and resolved.source.faction))
  if desiredFaction ~= "Alliance" and desiredFaction ~= "Horde" then
    local pf = UnitFactionGroup and UnitFactionGroup("player")
    if pf == "Alliance" or pf == "Horde" then desiredFaction = pf else desiredFaction = nil end
  end

  local picked, pickedItem
  local currentVendor = resolved._navVendor or resolved.vendor
  if type(currentVendor) == "table" then
    local currentFaction = VendorFaction(currentVendor)
    if not desiredFaction or currentFaction == desiredFaction then
      picked = currentVendor
    end
  end

  local expName = resolved._expansion
  local zoneKey = resolved._navZoneKey
  if not picked and expName and zoneKey then
    picked, pickedItem = PickVendorFromZoneData(resolved.decorID, expName, zoneKey, desiredFaction)
  end

  local vendors = entry.vendors or (entry.vendor and { entry.vendor }) or {}

  if not picked and desiredFaction and type(vendors) == "table" then
    for _, v in ipairs(vendors) do
      if VendorFaction(v) == desiredFaction then
        picked = v
        break
      end
    end
  end

  picked = picked or entry.vendor or vendors[1]

  local vsrc = picked and picked.source
  if vsrc then
    if vsrc.id then
      resolved.npcID = vsrc.id
      resolved.source.npcID = vsrc.id
    end
    if vsrc.worldmap then
      resolved.worldmap = vsrc.worldmap
      resolved.source.worldmap = vsrc.worldmap
    end
    if vsrc.zone then
      resolved.zone = vsrc.zone
      resolved.source.zone = vsrc.zone
    end
    local pickedFaction = NormalizeFaction(vsrc.faction)
    if pickedFaction then
      resolved.faction = pickedFaction
      resolved.source.faction = pickedFaction
    end
  end

  local itemID
  if pickedItem and pickedItem.source and pickedItem.source.itemID then
    itemID = pickedItem.source.itemID
  elseif item and item.source and item.source.itemID then
    itemID = item.source.itemID
  end
  if itemID then
    resolved.itemID = resolved.itemID or itemID
    resolved.source.itemID = resolved.source.itemID or itemID
  end

  if resolved.source.type == "achievement" then
    local ach = item and item.requirements and item.requirements.achievement
    if ach then
      resolved.source.id = resolved.source.id or ach.id
      local achName = Data.GetAchievementTitle(ach.id)
      if achName then
        resolved.source.name = achName
      elseif not resolved.source.name then
        resolved.source._achievementID = ach.id
      end
    end
  elseif resolved.source.type == "quest" then
    local q = (item and item.requirements and item.requirements.quest)
      or (pickedItem and pickedItem.requirements and pickedItem.requirements.quest)
      or (picked and picked.requirements and picked.requirements.quest)
    if q then
      resolved.source.id = resolved.source.id or q.id
      resolved.source.questID = resolved.source.questID or q.id
      local questName = Data.GetQuestTitle(q.id)
      if questName then
        resolved.source.name = questName
      elseif not resolved.source.name then
        resolved.source._questID = q.id
      end
    end
  end

  local slim = Data.SlimVendor(picked) or picked or entry.vendor
  resolved.vendor = slim
  resolved._navVendor = slim

  Data.ApplyDecorBreadcrumb(resolved)

  return resolved
end

Data.CATEGORY_MAP = {
  ["Achievements"] = "Achievements",
  ["Quests"]       = "Quests",
  ["Vendors"]      = "Vendors",
  ["Drops"]        = "Drops",
  ["Professions"]  = "Professions",
  ["PvP"]          = "PvP",
  ["PVP"]          = "PvP",
}

function Data.GetActiveData(ui)
  ui = ui or {}
  local key = Data.CATEGORY_MAP[ui.activeCategory]
  if not key or not NS.Data then return nil end

  if key == "PvP" then
    return BuildPvPVendorData()
  end

  local t = NS.Data[key]
  if t ~= nil then return t end
  return nil
end

function Data.PrefetchQuestAndAchievementNames()
  EnsureDecorIndex()
  if not DecorIndex or prefetchQueued then return end
  prefetchQueued = true

  local questIDs = {}
  local achIDs = {}
  local questList = {}
  local achList = {}

  for decorID, entry in pairs(DecorIndex) do
    if type(decorID) == "number" and type(entry) == "table" and entry.item and entry.item.requirements then
      local req = entry.item.requirements

      if req.quest and req.quest.id then
        local id = tonumber(req.quest.id)
        if id and not questIDs[id] then
          questIDs[id] = true
          questList[#questList + 1] = id
        end
      end

      if req.achievement and req.achievement.id then
        local id = tonumber(req.achievement.id)
        if id and not achIDs[id] then
          achIDs[id] = true
          achList[#achList + 1] = id
        end
      end
    end
  end

  local qIndex, aIndex = 1, 1
  local CHUNK = 20

  local function prefetchAchievements()
    local limit = math.min(aIndex + CHUNK - 1, #achList)
    for i = aIndex, limit do
      local id = achList[i]
      if GetAchievementInfo then
        GetAchievementInfo(id)
      end
      Data.GetAchievementTitle(id)
    end
    aIndex = limit + 1
    if aIndex <= #achList then
      C_Timer.After(0.05, prefetchAchievements)
    end
  end

  local function prefetchQuests()
    local limit = math.min(qIndex + CHUNK - 1, #questList)
    for i = qIndex, limit do
      local id = questList[i]
      if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        C_QuestLog.RequestLoadQuestByID(id)
      end
      Data.GetQuestTitle(id)
    end
    qIndex = limit + 1
    if qIndex <= #questList then
      C_Timer.After(0.05, prefetchQuests)
      return
    end
    if #achList > 0 then
      C_Timer.After(0.1, prefetchAchievements)
    end
  end

  if #questList > 0 then
    C_Timer.After(0.1, prefetchQuests)
  elseif #achList > 0 then
    C_Timer.After(0.1, prefetchAchievements)
  end
end

function Data.PrefetchProfessionItemData()
  if profItemPrefetchQueued then return end
  profItemPrefetchQueued = true

  C_Timer.After(0.1, function()
    if not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    local profs = NS.Data and NS.Data.Professions
    if type(profs) ~= "table" then return end

    local seen = {}
    local batch = {}
    for _, expansions in pairs(profs) do
      if type(expansions) == "table" then
        for _, list in pairs(expansions) do
          if type(list) == "table" then
            for _, entry in ipairs(list) do
              local iid = entry.source and entry.source.itemID
              if iid and not seen[iid] then
                seen[iid] = true
                batch[#batch + 1] = iid
              end

              if entry.reagents then
                for _, r in ipairs(entry.reagents) do
                  if r.itemID and not seen[r.itemID] then
                    seen[r.itemID] = true
                    batch[#batch + 1] = r.itemID
                  end
                end
              end
            end
          end
        end
      end
    end

    local idx = 1
    local CHUNK = 25
    local function sendChunk()
      local limit = math.min(idx + CHUNK - 1, #batch)
      for i = idx, limit do
        C_Item.RequestLoadItemDataByID(batch[i])
      end
      idx = limit + 1
      if idx <= #batch then
        C_Timer.After(0.08, sendChunk)
      end
    end
    if #batch > 0 then
      sendChunk()
    end
  end)
end

function Data.KeyExp(cat, exp) return tostring(cat) .. ":exp:" .. tostring(exp) end
function Data.KeyZone(cat, exp, zone) return tostring(cat) .. ":zone:" .. tostring(exp) .. ":" .. tostring(zone) end
function Data.KeyVendor(cat, exp, zone, vendorID)
  return tostring(cat) .. ":vendor:" .. tostring(exp) .. ":" .. tostring(zone) .. ":" .. tostring(vendorID)
end

return Data
