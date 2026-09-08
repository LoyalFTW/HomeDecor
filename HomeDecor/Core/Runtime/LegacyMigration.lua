local _, NS = ...

local Migration = {}
NS.Systems.LegacyMigration = Migration

local function Copy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return seen[value] end
  local target = {}
  seen[value] = target
  for key, child in pairs(value) do target[Copy(key, seen)] = Copy(child, seen) end
  return target
end

local function CompactPricing(profile)
  if type(profile) ~= "table" or profile.databaseCleanupVersion == 2 then return end
  local legacy = profile.decorAH
  profile.decorPricing = type(profile.decorPricing) == "table" and profile.decorPricing or {}
  local pricing = profile.decorPricing
  pricing.marketHistory = {}
  pricing.queue = type(pricing.queue) == "table" and pricing.queue or {}
  pricing.queueItems = type(pricing.queueItems) == "table" and pricing.queueItems or {}
  for _, entry in ipairs(type(legacy) == "table" and type(legacy.queue) == "table" and legacy.queue or {}) do
    local itemID = tonumber(entry.itemID)
    if itemID then
      local key = tostring(itemID)
      pricing.queue[key] = math.max(1, tonumber(entry.count) or 1)
      pricing.queueItems[key] = {
        itemID = itemID,
        name = entry.name,
        profit = entry.profit,
        materials = Copy(entry.materials or {}),
      }
    end
  end
  if type(legacy) == "table" and type(legacy.sales) == "table" and type(legacy.sales.history) == "table" then
    pricing.sales = type(pricing.sales) == "table" and pricing.sales or {}
    if type(pricing.sales.history) ~= "table" or #pricing.sales.history == 0 then pricing.sales.history = Copy(legacy.sales.history) end
  end
  if type(legacy) == "table" and type(legacy.favorites) == "table" then pricing.favorites = Copy(legacy.favorites) end
  if type(legacy) == "table" and type(legacy.priceAlerts) == "table" then pricing.priceAlerts = Copy(legacy.priceAlerts) end
  local preferredSource = type(legacy) == "table" and legacy.preferredSource
  local lastAuctionatorScan = type(legacy) == "table" and legacy.lastAuctionatorScan
  profile.decorAH = nil
  if preferredSource ~= nil or lastAuctionatorScan ~= nil then
    profile.decorAH = { preferredSource = preferredSource, lastAuctionatorScan = lastAuctionatorScan }
  end
  profile.databaseCleanupVersion = 2
end

local compactKeys = {
  "itemID", "decorID", "title", "name", "icon", "category", "subcategory", "profession", "expansion", "zone", "faction",
  "sourceType", "sourceID", "sourceName", "vendorName", "skillID", "worldmap", "mapID", "mapX", "mapY", "requirements",
  "budgetCost", "currency", "currencyType", "costs", "classRestriction", "raceRestriction", "size", "colors", "note", "dyeable",
  "needed", "have", "kind",
}

local function CompactBlueprintList(profile)
  if type(profile) ~= "table" or profile.blueprintListCleanupVersion == 1 or type(profile.blueprintList) ~= "table" then return end
  for categoryName, category in pairs(profile.blueprintList) do
    if type(category) == "table" then
      for key, entry in pairs(category) do
        if type(entry) == "table" then
          local compact = {}
          for _, field in ipairs(compactKeys) do
            if entry[field] ~= nil then compact[field] = Copy(entry[field]) end
          end
          if not compact.sourceType and type(entry.source) == "table" then compact.sourceType = entry.source.type end
          if not compact.zone and type(entry.vendor) == "table" then compact.zone = entry.vendor.zone end
          category[key] = compact
        end
      end
    else
      profile.blueprintList[categoryName] = nil
    end
  end
  profile.blueprintListCleanupVersion = 1
end

local function LayoutSignature(layout)
  local parts = { tostring(layout and layout.name or ""), tostring(layout and #(layout.rooms or {}) or 0) }
  for _, room in ipairs((layout and layout.rooms) or {}) do
    parts[#parts + 1] = table.concat({
      tostring(room.templateKey or room.template or ""),
      tostring(room.name or ""),
      tostring(room.x or ""),
      tostring(room.y or ""),
      tostring(room.floor or (room.capture and room.capture.floor) or ""),
    }, ":")
  end
  return table.concat(parts, "|")
end

local function ImportLegacyArchitect(profile)
  if type(profile) ~= "table" or profile.legacyArchitectMigrationVersion == 1 then return end
  if type(_G.HomeDecorRebuildDB) ~= "table" and _G.C_AddOns then
    local exists = type(_G.C_AddOns.DoesAddOnExist) == "function" and _G.C_AddOns.DoesAddOnExist("HomeDecorRebuild")
    if exists and type(_G.C_AddOns.EnableAddOn) == "function" and type(_G.C_AddOns.LoadAddOn) == "function" then
      _G.C_AddOns.EnableAddOn("HomeDecorRebuild")
      pcall(_G.C_AddOns.LoadAddOn, "HomeDecorRebuild")
    end
  end
  local sourceRoot = _G.HomeDecorRebuildDB
  local sourceProfile = type(sourceRoot) == "table" and sourceRoot.profile
  local source = type(sourceProfile) == "table" and sourceProfile.architect
  if type(source) ~= "table" or type(source.layouts) ~= "table" or #source.layouts == 0 then return end

  local target = profile.architect
  local onlyLayout = type(target) == "table" and type(target.layouts) == "table" and #target.layouts == 1 and target.layouts[1]
  local onlyRoom = onlyLayout and type(onlyLayout.rooms) == "table" and #onlyLayout.rooms == 1 and onlyLayout.rooms[1]
  local generatedDefault = onlyLayout and onlyRoom and onlyLayout.name == "First Home" and onlyRoom.name == "Great Room" and onlyRoom.design == "Welcome"
  if type(target) ~= "table" or type(target.layouts) ~= "table" or #target.layouts == 0 or generatedDefault then
    profile.architect = Copy(source)
    profile.legacyArchitectMigrationVersion = 1
    return
  end

  local signatures = {}
  local maxLayoutID, maxRoomID = 0, 0
  for _, layout in ipairs(target.layouts) do
    signatures[LayoutSignature(layout)] = true
    maxLayoutID = math.max(maxLayoutID, tonumber(layout.id) or 0)
    for _, room in ipairs(layout.rooms or {}) do maxRoomID = math.max(maxRoomID, tonumber(room.id) or 0) end
  end
  for _, sourceLayout in ipairs(source.layouts) do
    if not signatures[LayoutSignature(sourceLayout)] then
      local layout = Copy(sourceLayout)
      maxLayoutID = maxLayoutID + 1
      layout.id = maxLayoutID
      for _, room in ipairs(layout.rooms or {}) do
        maxRoomID = maxRoomID + 1
        room.id = maxRoomID
      end
      target.layouts[#target.layouts + 1] = layout
    end
  end
  target.nextLayoutID = math.max(tonumber(target.nextLayoutID) or 1, maxLayoutID + 1)
  target.nextRoomID = math.max(tonumber(target.nextRoomID) or 1, maxRoomID + 1)
  profile.legacyArchitectMigrationVersion = 1
end

function Migration:CompactDatabase()
  local database = _G.HomeDecorDB
  for _, profile in pairs(type(database) == "table" and type(database.profiles) == "table" and database.profiles or {}) do
    CompactPricing(profile)
    CompactBlueprintList(profile)
  end
end

function Migration:Import()
  local profile = NS.Systems.Database:GetProfile()
  local legacy = _G.HomeDecorDB
  local old = profile
  if not profile then return false end
  local oldEndeavors = legacy and legacy.endeavors
  ImportLegacyArchitect(profile)
  if type(oldEndeavors) == "table" and profile.legacyEndeavorsMigrationVersion ~= 1 then
    profile.endeavors = profile.endeavors or {}
    if type(oldEndeavors.myCharacters) == "table" then profile.endeavors.myCharacters = Copy(oldEndeavors.myCharacters) end
    if type(oldEndeavors.couponGains) == "table" then profile.endeavors.couponGains = Copy(oldEndeavors.couponGains) end
    if type(oldEndeavors.taskActualCoupons) == "table" then profile.endeavors.taskActualCoupons = Copy(oldEndeavors.taskActualCoupons) end
    if oldEndeavors.selectedHouseGUID then profile.endeavors.selectedHouseGUID = oldEndeavors.selectedHouseGUID end
    profile.legacyEndeavorsMigrationVersion = 1
  end
  if profile.legacyMigrationVersion == 1 then
    profile.legacyBlueprints = nil
    profile.legacyQuickBar = nil
    profile.legacyMigrationVersion = 2
  end
  if not old or profile.legacyMigrationVersion then return false end
  local settings = profile.settings
  local mapPins = old.mapPins
  local vendor = old.vendor
  local tracker = old.tracker
  local filters = old.filters
  local editMode = old.editMode
  local clock = old.houseEditorClock
  local quickBar = old.quickBar
  local ui = old.ui
  if type(mapPins) == "table" then
    if mapPins.worldmap ~= nil then settings.mapPins = mapPins.worldmap == true end
    if mapPins.minimap ~= nil then settings.mapMinimapPins = mapPins.minimap == true end
    if mapPins.pinStyle ~= nil then settings.mapPinStyle = mapPins.pinStyle end
    if mapPins.pinSize ~= nil then settings.mapPinSize = mapPins.pinSize end
    if type(mapPins.pinColor) == "table" then settings.mapPinColor = Copy(mapPins.pinColor) end
    if mapPins.pinTooltipAnchor ~= nil then settings.mapTooltipAnchor = mapPins.pinTooltipAnchor end
  end
  if type(vendor) == "table" then
    if vendor.showCollectedCheckmark ~= nil then settings.vendorMarkers = vendor.showCollectedCheckmark == true end
  end
  if type(tracker) == "table" then
    if tracker.hideCompleted ~= nil then settings.trackerHideCompleted = tracker.hideCompleted == true end
    if tracker.trackZone ~= nil then settings.trackerTrackCurrentZone = tracker.trackZone == true end
    if tracker.showFavoritesOnZoneEnter ~= nil then settings.zoneFavoriteAlerts = tracker.showFavoritesOnZoneEnter == true end
    if tracker.alpha ~= nil then
      settings.trackerTransparency = math.max(0, math.min(1, 1 - (tonumber(tracker.alpha) or 1)))
      settings.trackerTransparent = settings.trackerTransparency > 0
    end
  end
  if type(filters) == "table" and filters.hideCollected ~= nil then settings.hideCollected = filters.hideCollected == true end
  if type(editMode) == "table" then
    if editMode.on ~= nil then settings.editorFeatures = editMode.on == true end
    if editMode.hud ~= nil then settings.editorHints = editMode.hud == true end
  end
  if type(clock) == "table" then
    if clock.enabled ~= nil then settings.editorClock = clock.enabled == true end
    if clock.display ~= nil then settings.editorClockDisplay = clock.display end
    if clock.timeSource ~= nil then settings.editorClockSource = clock.timeSource end
    if clock.timeFormat ~= nil then settings.editorClockFormat = clock.timeFormat end
  end
  if type(quickBar) == "table" then
    if quickBar.enabled ~= nil then settings.quickBar = quickBar.enabled == true end
    if type(quickBar.hotbars) == "table" and type(quickBar.pages) == "table" and next(quickBar.pages) == nil then quickBar.pages = Copy(quickBar.hotbars) end
  end
  if type(ui) == "table" then
    if ui.activeCategory ~= nil then ui.category = ui.activeCategory end
    if ui.viewMode == "Icon" then ui.view = "grid" elseif ui.viewMode ~= nil then ui.view = "list" end
    if ui.compactMode ~= nil then ui.compact = ui.compactMode == true end
  end
  local favoriteIDs = old.favorites
  if type(favoriteIDs) == "table" then
    for index = 1, #NS.Systems.Catalog.ordered do
      local record = NS.Systems.Catalog.ordered[index]
      local itemID = record.itemID
      local decorID = record.decorID
      local favorite = (itemID and (favoriteIDs[itemID] == true or favoriteIDs[tostring(itemID)] == true)) or (decorID and (favoriteIDs[decorID] == true or favoriteIDs[tostring(decorID)] == true))
      if favorite then
        local key = NS.Systems.Favorites:Key(record)
        if key then profile.favorites[key] = true end
      end
    end
  end
  if type(old.minimap) == "table" then profile.minimap = Copy(old.minimap) end
  profile.legacyMigrationVersion = 2
  return true
end
