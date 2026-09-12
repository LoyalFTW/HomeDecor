local _, NS = ...

local Database = {}
NS.Systems.Database = Database

local function CopyDefaults(source)
  local target = {}
  for key, value in pairs(source) do
    if type(value) == "table" then
      target[key] = CopyDefaults(value)
    else
      target[key] = value
    end
  end
  return target
end

local function MergeDefaults(target, source)
  for key, value in pairs(source) do
    if type(value) == "table" then
      if type(target[key]) ~= "table" then target[key] = CopyDefaults(value) else MergeDefaults(target[key], value) end
    elseif target[key] == nil then
      target[key] = value
    end
  end
end

local defaults = {
  version = NS.Version,
  global = {
    sales = { history = {}, totals = { characters = {} } },
  },
  profile = {
    ui = {
      category = "All",
      search = "",
      view = "grid",
      sort = "name",
      route = "catalog",
      compact = false,
      catalogOnly = false,
      catalogMode = "All Items",
      designPreset = "gallery",
      groupOpen = {},
      frames = {},
      appearance = { font = "Game Default", fontScale = 1, colors = {} },
    },
    filters = {},
    favorites = {},
    tracked = {},
    lists = { order = {}, entries = {}, nextID = 1 },
    minimap = { hide = false, showInCompartment = true },
    settings = { mapPins = true, mapMinimapPins = true, vendorAssistant = true, vendorMarkers = true, quickBar = true, editorFeatures = true, editorHints = true, editorClock = true, editorClockDisplay = "clock", editorClockSource = "auto", editorClockFormat = "auto", hideCollected = false, zoneFavoriteAlerts = true, mapPinStyle = "house", mapPinSize = 1, mapPinColor = { r = 1, g = 1, b = 1 }, mapTooltipAnchor = "ANCHOR_RIGHT", trackerTransparent = false, trackerTransparency = 0, trackerHideCompleted = false, trackerTrackCurrentZone = true },
    quickBar = { page = 1, pages = {}, recent = nil },
    editorTools = { clipboard = true, batchPlace = true, batchRotate = true, batchStep = 15, lock = true, locks = {}, keybinds = { copy = "CTRL-C", cut = "CTRL-X", paste = "CTRL-V", duplicate = "CTRL-D", lock = "L" } },
    decorPricing = { queue = {}, queueItems = {}, sales = { history = {}, totals = { characters = {} } }, recipeKnowledge = {}, marketHistory = {} },
    altProfessions = { characters = {}, legacyImported = false },
    gatherTracker = { items = {}, characters = {}, goals = {}, recent = {}, session = { active = false, started = 0, elapsed = 0, gained = {} }, settings = { scope = "account", kind = "all", hideZero = false, search = "", sort = "countDesc", trackLumber = true, trackOre = true, trackHerbs = true, autoFarm = true, focusByKind = {}, farmerCompact = false, hudEnabled = false, hudLocked = false, hudSize = 420 }, legacyImported = false },
    endeavors = { myCharacters = {}, couponGains = {}, taskActualCoupons = {}, sort = { key = "default", descending = false }, activitySort = { key = "time", descending = true }, leaderboardSort = { key = "amount", descending = true }, couponSort = { key = "time", descending = true } },
    statistics = { view = "sources", sort = { key = "percent", header = "percentText", descending = true } },
    changelog = { autoOpen = true, lastSeenVersion = "" },
    blueprintList = { categories = {}, active = nil },
    blueprints = { nextID = 1, saved = {} },
  },
}

function Database:Load()
  local foundry = _G.Foundry_1_0
  if not foundry or not foundry.DB then error(NS.Name .. " requires Foundry-1.0") end
  local db = foundry.DB:New({
    name = NS.Name,
    sv = "HomeDecorDB",
    defaults = { global = defaults.global, profile = defaults.profile },
    defaultProfile = true,
  })
  local profile = db.profile
  local hadTrackerTransparency = type(profile.settings) == "table" and profile.settings.trackerTransparency ~= nil
  MergeDefaults(profile, defaults.profile)
  if type(profile.ui) ~= "table" then profile.ui = CopyDefaults(defaults.profile.ui) end
  if type(profile.ui.frames) ~= "table" then profile.ui.frames = {} end
  if type(profile.ui.groupOpen) ~= "table" then profile.ui.groupOpen = {} end
  if type(profile.ui.appearance) ~= "table" then profile.ui.appearance = CopyDefaults(defaults.profile.ui.appearance) end
  if type(profile.ui.appearance.colors) ~= "table" then profile.ui.appearance.colors = {} end
  if profile.ui.catalogMode ~= "Sections" then profile.ui.catalogMode = "All Items" end
  if type(profile.filters) ~= "table" then profile.filters = {} end
  if type(profile.favorites) ~= "table" then profile.favorites = {} end
  if type(profile.tracked) ~= "table" then profile.tracked = {} end
  if type(profile.lists) ~= "table" then profile.lists = CopyDefaults(defaults.profile.lists) end
  if type(profile.lists.order) ~= "table" then profile.lists.order = {} end
  if type(profile.lists.entries) ~= "table" then profile.lists.entries = {} end
  if type(profile.lists.nextID) ~= "number" then profile.lists.nextID = 1 end
  if type(profile.settings) ~= "table" then profile.settings = CopyDefaults(defaults.profile.settings) end
  for key, value in pairs(defaults.profile.settings) do
    if profile.settings[key] == nil then profile.settings[key] = type(value) == "table" and CopyDefaults(value) or value end
  end
  if not hadTrackerTransparency and profile.settings.trackerTransparent == true then profile.settings.trackerTransparency = 1 end
  if type(profile.quickBar) ~= "table" then profile.quickBar = CopyDefaults(defaults.profile.quickBar) end
  if type(profile.decorPricing) ~= "table" then profile.decorPricing = CopyDefaults(defaults.profile.decorPricing) end
  if type(profile.decorPricing.queue) ~= "table" then profile.decorPricing.queue = {} end
  if type(profile.decorPricing.queueItems) ~= "table" then profile.decorPricing.queueItems = {} end
  if type(profile.decorPricing.sales) ~= "table" then profile.decorPricing.sales = { history = {} } end
  if type(profile.decorPricing.sales.history) ~= "table" then profile.decorPricing.sales.history = {} end
  if type(profile.decorPricing.sales.totals) ~= "table" then profile.decorPricing.sales.totals = { characters = {} } end
  if type(profile.decorPricing.sales.totals.characters) ~= "table" then profile.decorPricing.sales.totals.characters = {} end
  if type(profile.decorPricing.recipeKnowledge) ~= "table" then profile.decorPricing.recipeKnowledge = {} end
  if type(profile.decorPricing.marketHistory) ~= "table" then profile.decorPricing.marketHistory = {} end
  if type(profile.altProfessions) ~= "table" then profile.altProfessions = CopyDefaults(defaults.profile.altProfessions) end
  if type(profile.altProfessions.characters) ~= "table" then profile.altProfessions.characters = {} end
  if type(profile.gatherTracker) ~= "table" then profile.gatherTracker = CopyDefaults(defaults.profile.gatherTracker) end
  if type(profile.gatherTracker.items) ~= "table" then profile.gatherTracker.items = {} end
  if type(profile.gatherTracker.characters) ~= "table" then profile.gatherTracker.characters = {} end
  if type(profile.gatherTracker.goals) ~= "table" then profile.gatherTracker.goals = {} end
  if type(profile.gatherTracker.recent) ~= "table" then profile.gatherTracker.recent = {} end
  if type(profile.gatherTracker.session) ~= "table" then profile.gatherTracker.session = CopyDefaults(defaults.profile.gatherTracker.session) end
  if type(profile.gatherTracker.session.gained) ~= "table" then profile.gatherTracker.session.gained = {} end
  profile.gatherTracker.session.active = profile.gatherTracker.session.active == true
  profile.gatherTracker.session.started = tonumber(profile.gatherTracker.session.started) or 0
  profile.gatherTracker.session.elapsed = math.max(0, tonumber(profile.gatherTracker.session.elapsed) or 0)
  if type(profile.gatherTracker.settings) ~= "table" then profile.gatherTracker.settings = CopyDefaults(defaults.profile.gatherTracker.settings) end
  if type(profile.endeavors) ~= "table" then profile.endeavors = CopyDefaults(defaults.profile.endeavors) end
  if type(profile.endeavors.myCharacters) ~= "table" then profile.endeavors.myCharacters = {} end
  if type(profile.endeavors.couponGains) ~= "table" then profile.endeavors.couponGains = {} end
  if type(profile.endeavors.taskActualCoupons) ~= "table" then profile.endeavors.taskActualCoupons = {} end
  if type(profile.blueprintList) ~= "table" then profile.blueprintList = CopyDefaults(defaults.profile.blueprintList) end
  if type(profile.blueprints) ~= "table" then profile.blueprints = CopyDefaults(defaults.profile.blueprints) end
  if type(profile.blueprints.saved) ~= "table" then profile.blueprints.saved = {} end
  if type(profile.changelog) ~= "table" then profile.changelog = CopyDefaults(defaults.profile.changelog) end
  if profile.changelog.autoOpen == nil then profile.changelog.autoOpen = true end
  if type(profile.changelog.lastSeenVersion) ~= "string" then profile.changelog.lastSeenVersion = "" end
  if profile.mapPinVisualVersion ~= 1 then
    profile.settings.mapPinColor = { r = 1, g = 1, b = 1 }
    profile.mapPinVisualVersion = 1
  end
  local global = db.global
  global.sales = type(global.sales) == "table" and global.sales or { history = {}, totals = { characters = {} } }
  global.sales.history = type(global.sales.history) == "table" and global.sales.history or {}
  if global.sales.profileMigrationV1 ~= true then
    local seen = {}
    local function Fingerprint(sale)
      return table.concat({ tostring(sale.timestamp), tostring(sale.itemID), tostring(sale.gold), tostring(sale.count), tostring(sale.characterKey), tostring(sale.name) }, "|")
    end
    for _, sale in ipairs(global.sales.history) do
      local key = Fingerprint(sale)
      seen[key] = (seen[key] or 0) + 1
    end
    for _, savedProfile in pairs(type(HomeDecorDB) == "table" and type(HomeDecorDB.profiles) == "table" and HomeDecorDB.profiles or {}) do
      local history = savedProfile.decorPricing and savedProfile.decorPricing.sales and savedProfile.decorPricing.sales.history
      local occurrences = {}
      for _, sale in ipairs(type(history) == "table" and history or {}) do
        local key = Fingerprint(sale)
        occurrences[key] = (occurrences[key] or 0) + 1
        if occurrences[key] > (seen[key] or 0) then
          global.sales.history[#global.sales.history + 1] = CopyDefaults(sale)
          seen[key] = (seen[key] or 0) + 1
        end
      end
    end
    global.sales.totals = { characters = {} }
    global.sales.profileMigrationV1 = true
  end
  NS.DB = db
  NS.db = db
  return db
end

function Database:GetProfile()
  return NS.DB and NS.DB.profile
end

function Database:GetGlobal()
  return NS.DB and NS.DB.global
end
