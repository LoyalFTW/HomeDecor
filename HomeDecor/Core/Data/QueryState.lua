local _, NS = ...

local QueryState = {}
NS.Systems.QueryState = QueryState

local sourceTypes = {
  { value = "All", label = "All Sources" },
  { value = "achievement", label = "Achievements" },
  { value = "quest", label = "Quests" },
  { value = "vendor", label = "Vendors" },
  { value = "drop", label = "Drops & Encounters" },
  { value = "shop", label = "Shop" },
  { value = "treasure", label = "Treasures" },
  { value = "profession", label = "Professions" },
  { value = "pvp", label = "PvP" },
  { value = "event", label = "Events" },
}
local factions = { "All", "Alliance", "Horde", "Neutral" }
local sizes = { "All", "Tiny", "Small", "Medium", "Large", "Huge" }
local sorts = {
  { value = "name", label = "Name (A-Z)" },
  { value = "name_desc", label = "Name (Z-A)" },
  { value = "category", label = "Category (A-Z)" },
  { value = "category_desc", label = "Category (Z-A)" },
  { value = "subcategory", label = "Subcategory (A-Z)" },
  { value = "subcategory_desc", label = "Subcategory (Z-A)" },
  { value = "source", label = "Source (A-Z)" },
  { value = "source_desc", label = "Source (Z-A)" },
}

local function NormalizeSort(value)
  for index = 1, #sorts do
    if sorts[index].value == value then return value end
  end
  return "name"
end
local budgets = {
  { value = "All", label = "All Costs" },
  { value = "low", label = "1-2  Low" },
  { value = "medium", label = "3-4  Medium" },
  { value = "high", label = "5+  High" },
  { value = "none", label = "No Cost" },
}
local requirements = { "All", "Quest", "Achievement", "Reputation" }
local dyeability = { "All", "Dyeable", "Not Dyeable" }
local views = { "grid", "list", "text" }
local optionCache = {}

local expansionAliases = {
  vanilla = "Classic", classic = "Classic", jewelcrafting = "Classic", leatherworking = "Classic", tailoring = "Classic",
  tbc = "Burning Crusade", burningcrusade = "Burning Crusade", outland = "Burning Crusade",
  wrath = "Wrath", wotlk = "Wrath", northrend = "Wrath", wrathofthelichking = "Wrath", thelichking = "Wrath",
  cata = "Cataclysm", cataclysm = "Cataclysm",
  mop = "Mists of Pandaria", pandaria = "Mists of Pandaria", mistsofpandaria = "Mists of Pandaria", pandaren = "Mists of Pandaria",
  wod = "Warlords of Draenor", warlords = "Warlords of Draenor", warlordsofdraenor = "Warlords of Draenor", draenor = "Warlords of Draenor",
  legion = "Legion",
  bfa = "Battle for Azeroth", battleforazeroth = "Battle for Azeroth", kul = "Battle for Azeroth", kultiras = "Battle for Azeroth", kultiran = "Battle for Azeroth", zandalar = "Battle for Azeroth", tiragarde = "Battle for Azeroth", tiragardesound = "Battle for Azeroth", zuldazar = "Battle for Azeroth",
  sl = "Shadowlands", shadowlands = "Shadowlands",
  df = "Dragonflight", dragonflight = "Dragonflight", dragon = "Dragonflight", dragonisles = "Dragonflight", dragonislands = "Dragonflight",
  tww = "The War Within", warwithin = "The War Within", thewarwithin = "The War Within", khaz = "The War Within", khazalgar = "The War Within",
  midnight = "Midnight",
}

local expansionRanks = {
  ["Classic"] = 1, ["Burning Crusade"] = 2, ["Wrath"] = 3, ["Cataclysm"] = 4,
  ["Mists of Pandaria"] = 5, ["Warlords of Draenor"] = 6, ["Legion"] = 7,
  ["Battle for Azeroth"] = 8, ["Shadowlands"] = 9, ["Dragonflight"] = 10,
  ["The War Within"] = 11, ["Midnight"] = 12,
}

local function NormalizeExpansion(value)
  if type(value) ~= "string" or value == "" then return value end
  local key = value:lower():gsub("[^%a%d]", "")
  return expansionAliases[key] or value
end

function QueryState:NormalizeExpansion(value)
  return NormalizeExpansion(value)
end

local function OptionValue(option)
  return type(option) == "table" and option.value or option
end

local function DynamicOptions(field, allLabel)
  local values, seen = { { value = "All", label = allLabel } }, {}
  local profile = NS.Systems.Database:GetProfile()
  local category = profile and ((profile.filters and profile.filters.category) or (profile.ui and profile.ui.category))
  local expansion = profile and profile.filters and profile.filters.expansion
  for _, record in ipairs(NS.Systems.Catalog.ordered or {}) do
    local categoryMatch = field ~= "subcategory" or not category or category == "All" or record.category == category
    local expansionMatch = field ~= "zone" or not expansion or NormalizeExpansion(record.expansion) == NormalizeExpansion(expansion)
    if categoryMatch and expansionMatch then
      local value = record[field]
      if field == "expansion" then
        value = NormalizeExpansion(value)
        if not expansionRanks[value] then value = nil end
      end
      if type(value) == "string" and value ~= "" and not seen[value] then
        seen[value] = true
        values[#values + 1] = { value = value, label = value }
      end
    end
  end
  table.sort(values, function(a, b)
    if a.value == "All" then return true end
    if b.value == "All" then return false end
    if field == "expansion" then
      local leftRank = expansionRanks[a.value] or 999
      local rightRank = expansionRanks[b.value] or 999
      if leftRank ~= rightRank then return leftRank < rightRank end
    end
    return tostring(a.label):lower() < tostring(b.label):lower()
  end)
  return values
end

local function ColorOptions()
  local values, seen = { { value = "All", label = "All Colors" } }, {}
  for _, record in ipairs(NS.Systems.Catalog.ordered or {}) do
    for _, color in ipairs(type(record.colors) == "table" and record.colors or {}) do
      local key = type(color) == "string" and color:lower() or nil
      if key and key ~= "" and not seen[key] then
        seen[key] = true
        values[#values + 1] = { value = color, label = color }
      end
    end
  end
  table.sort(values, function(a, b)
    if a.value == "All" then return true end
    if b.value == "All" then return false end
    return tostring(a.label):lower() < tostring(b.label):lower()
  end)
  return values
end

local function ClassOptions()
  local values, seen = { { value = "All", label = "All Classes" } }, {}
  for _, record in ipairs(NS.Systems.Catalog.ordered or {}) do
    local value = NS.Systems.Housing and NS.Systems.Housing:GetClassRestriction(record)
    if type(value) == "string" and value ~= "" and not seen[value] then
      seen[value] = true
      values[#values + 1] = { value = value, label = value }
    end
  end
  table.sort(values, function(a, b)
    if a.value == "All" then return true end
    if b.value == "All" then return false end
    return tostring(a.label):lower() < tostring(b.label):lower()
  end)
  return values
end

function QueryState:GetOptions(kind)
  if kind == "sourceType" then return sourceTypes end
  if kind == "faction" then return factions end
  if kind == "size" then return sizes end
  if kind == "sort" then return sorts end
  if kind == "budgetCost" then return budgets end
  if kind == "requirement" then return requirements end
  if kind == "dyeability" then return dyeability end
  if kind == "view" then return views end
  local profile = NS.Systems.Database:GetProfile()
  local filters = profile and profile.filters or {}
  local cacheKey = table.concat({ tostring(kind), tostring(NS.Systems.Catalog.revision or 0), tostring(filters.category or (profile and profile.ui and profile.ui.category) or ""), tostring(filters.expansion or "") }, "\031")
  local cached = optionCache[kind]
  if cached and cached.key == cacheKey then return cached.options end
  local options
  if kind == "expansion" then options = DynamicOptions("expansion", "All Expansions") end
  if kind == "zone" then options = DynamicOptions("zone", "All Zones") end
  if kind == "profession" then options = DynamicOptions("profession", "All Professions") end
  if kind == "category" then options = DynamicOptions("category", "Current Sidebar Category") end
  if kind == "subcategory" then options = DynamicOptions("subcategory", "All Subcategories") end
  if kind == "class" then options = ClassOptions() end
  if kind == "color" then options = ColorOptions() end
  if options then
    optionCache[kind] = { key = cacheKey, options = options }
    return options
  end
  return {}
end

function QueryState:SetFilter(field, value)
  local profile = self:GetProfile()
  if not profile then return nil end
  if field == "category" then
    profile.filters.subcategory = nil
  end
  if value == nil or value == "All" then
    profile.filters[field] = nil
  else
    local values = self:GetOptions(field)
    profile.filters[field] = value == OptionValue(values[1]) and nil or value
  end
  if field == "expansion" then profile.filters.zone = nil end
  if field == "category" then profile.filters.subcategory = nil end
  return value
end

function QueryState:SetFlag(field, value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.filters[field] = value == true or nil
  return profile.filters[field] == true
end

function QueryState:ToggleColor(value)
  local profile = self:GetProfile()
  if not profile or type(value) ~= "string" or value == "" or value == "All" then return false end
  profile.filters.colors = type(profile.filters.colors) == "table" and profile.filters.colors or {}
  if profile.filters.colors[value] == true then
    profile.filters.colors[value] = nil
  else
    profile.filters.colors[value] = true
  end
  return profile.filters.colors[value] == true
end

function QueryState:GetSelectedColors()
  local profile = self:GetProfile()
  if not profile then return {} end
  profile.filters.colors = type(profile.filters.colors) == "table" and profile.filters.colors or {}
  return profile.filters.colors
end

function QueryState:ClearColors()
  local colors = self:GetSelectedColors()
  wipe(colors)
end

function QueryState:GetColorSignature()
  local values = {}
  for color, active in pairs(self:GetSelectedColors()) do
    if active == true then values[#values + 1] = color end
  end
  table.sort(values)
  return table.concat(values, "\031")
end

function QueryState:GetFilter(field, default)
  local profile = self:GetProfile()
  local fallback = default == nil and "All" or default
  if not profile then return fallback end
  local value = profile.filters[field]
  if value == nil then return fallback end
  return value
end

function QueryState:GetOptionLabel(field, value)
  for _, option in ipairs(self:GetOptions(field)) do
    if OptionValue(option) == value then
      return type(option) == "table" and (option.label or option.text or tostring(value)) or tostring(option)
    end
  end
  return tostring(value or "All")
end

function QueryState:GetActiveFilterCount()
  local profile = self:GetProfile()
  if not profile then return 0 end
  local count = 0
  if profile.ui.ownership and profile.ui.ownership ~= "All" then count = count + 1 end
  for _, value in pairs(profile.filters or {}) do
    if type(value) == "table" then
      if next(value) then count = count + 1 end
    elseif value ~= nil and value ~= false and value ~= "All" then
      count = count + 1
    end
  end
  return count
end

function QueryState:SetView(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.view = value
  return value
end

function QueryState:SetSort(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.sort = NormalizeSort(value)
  return profile.ui.sort
end

function QueryState:SetCategory(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.category = value or "All"
  return profile.ui.category
end

function QueryState:SetSearch(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.search = type(value) == "string" and value or ""
  return profile.ui.search
end

function QueryState:SetOwnership(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.ownership = value or "All"
  return profile.ui.ownership
end

function QueryState:SetCompact(value, syncView)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.compact = value == true
  if syncView then profile.ui.view = profile.ui.compact and "text" or "grid" end
  return profile.ui.compact
end

function QueryState:SetCatalogOnly(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  local enabled = value == true
  if enabled and profile.ui.catalogOnly ~= true then
    profile.ui.catalogOnlyPreviousView = profile.ui.view
    profile.ui.catalogOnlyPreviousCompact = profile.ui.compact == true
    profile.ui.view = "text"
    profile.ui.compact = true
  elseif not enabled and profile.ui.catalogOnly == true then
    profile.ui.view = profile.ui.catalogOnlyPreviousView or "grid"
    profile.ui.compact = profile.ui.catalogOnlyPreviousCompact == true
    profile.ui.catalogOnlyPreviousView = nil
    profile.ui.catalogOnlyPreviousCompact = nil
  end
  profile.ui.catalogOnly = enabled
  return profile.ui.catalogOnly
end

function QueryState:SetPanelVisible(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.panelVisible = value == true
  return profile.ui.panelVisible
end

function QueryState:SetCatalogMode(value)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.catalogMode = value == "Sections" and "Sections" or "All Items"
  return profile.ui.catalogMode
end

function QueryState:SetWindowMetrics(width, height, scale)
  local profile = self:GetProfile()
  if not profile then return nil end
  profile.ui.width = tonumber(width)
  profile.ui.height = tonumber(height)
  profile.ui.windowScale = tonumber(scale)
  profile.ui.scale = tonumber(scale)
  return profile.ui.width
end

function QueryState:ToggleGroup(key)
  local profile = self:GetProfile()
  if not profile or key == nil then return nil end
  profile.ui.groupOpen = profile.ui.groupOpen or {}
  profile.ui.groupOpen[key] = not profile.ui.groupOpen[key]
  return profile.ui.groupOpen[key]
end

function QueryState:GetGroupOpen()
  local profile = self:GetProfile()
  if not profile then return {} end
  profile.ui.groupOpen = profile.ui.groupOpen or {}
  return profile.ui.groupOpen
end

function QueryState:GetProfile()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.filters = profile.filters or {}
  if type(profile.filters.color) == "string" and profile.filters.color ~= "" and profile.filters.color ~= "All" then
    profile.filters.colors = type(profile.filters.colors) == "table" and profile.filters.colors or {}
    profile.filters.colors[profile.filters.color] = true
    profile.filters.color = nil
  end
  if profile.filters.budgetCost == 1 then profile.filters.budgetCost = "low" end
  if profile.filters.budgetCost == 3 then profile.filters.budgetCost = "medium" end
  if profile.filters.budgetCost == 5 then profile.filters.budgetCost = "high" end
  if type(profile.filters.expansion) == "string" and profile.filters.expansion ~= "All" then profile.filters.expansion = NormalizeExpansion(profile.filters.expansion) end
  return profile
end

function QueryState:Fill(target)
  local profile = self:GetProfile()
  if not profile then return target end
  local ui = profile.ui
  local filters = profile.filters
  wipe(target)
  target.category = filters.category or ui.category
  target.search = ui.search
  target.favoriteOnly = ui.favoriteOnly == true
  target.trackedOnly = ui.trackedOnly == true
  target.ownership = ui.ownership or "All"
  if target.ownership == "All" and NS.Systems.Settings:GetValue("hideCollected", false) then target.ownership = "Missing" end
  target.expansion = filters.expansion
  target.profession = filters.profession
  target.class = filters.class
  target.sourceType = filters.sourceType
  target.faction = filters.faction
  target.zone = filters.zone
  target.size = filters.size
  target.budgetCost = filters.budgetCost
  target.requirement = filters.requirement
  target.dyeability = filters.dyeability
  target.subcategory = filters.subcategory
  target.colors = filters.colors
  target.hidePvp = filters.hidePvp == true
  target.requiresReputation = filters.requiresReputation == true
  target.requiresRenown = filters.requiresRenown == true
  target.questCompleted = filters.questCompleted == true
  target.achievementCompleted = filters.achievementCompleted == true
  return target
end

function QueryState:SetRoute(route)
  local profile = self:GetProfile()
  if not profile then return end
  profile.ui.route = route
  profile.ui.favoriteOnly = route == "favorites"
  profile.ui.trackedOnly = route == "tracked"
end

function QueryState:ResetFilters()
  local profile = self:GetProfile()
  if not profile then return end
  wipe(profile.filters)
  profile.ui.search = ""
  profile.ui.ownership = "All"
  profile.ui.sort = "name"
  if NS.Systems.Catalog then NS.Systems.Catalog:Sort("name") end
end

function QueryState:GetRoute()
  local profile = self:GetProfile()
  return profile and profile.ui.route or "catalog"
end

function QueryState:CycleView()
  local profile = self:GetProfile()
  if not profile then return nil end
  if profile.ui.view == "grid" then
    profile.ui.view = "list"
  elseif profile.ui.view == "list" then
    profile.ui.view = "text"
  else
    profile.ui.view = "grid"
  end
  return profile.ui.view
end

function QueryState:Cycle(field, values)
  local profile = self:GetProfile()
  if not profile then return nil end
  local filters = profile.filters
  local current = filters[field] or OptionValue(values[1])
  local nextIndex = 1
  for index = 1, #values do
    if OptionValue(values[index]) == current then
      nextIndex = index + 1
      break
    end
  end
  if nextIndex > #values then nextIndex = 1 end
  local value = OptionValue(values[nextIndex])
  filters[field] = value == OptionValue(values[1]) and nil or value
  return value
end

function QueryState:GetSourceType()
  local profile = self:GetProfile()
  return profile and profile.filters.sourceType or "All"
end

function QueryState:GetFaction()
  local profile = self:GetProfile()
  return profile and profile.filters.faction or "All"
end

function QueryState:CycleSourceType()
  return self:Cycle("sourceType", sourceTypes)
end

function QueryState:CycleFaction()
  return self:Cycle("faction", factions)
end

function QueryState:GetSize()
  local profile = self:GetProfile()
  return profile and profile.filters.size or "All"
end

function QueryState:CycleSize()
  return self:Cycle("size", sizes)
end

function QueryState:GetSort()
  local profile = self:GetProfile()
  if not profile then return "name" end
  profile.ui.sort = NormalizeSort(profile.ui.sort)
  return profile.ui.sort
end

function QueryState:CycleSort()
  local profile = self:GetProfile()
  if not profile then return nil end
  local current = NormalizeSort(profile.ui.sort)
  local nextIndex = 1
  for index = 1, #sorts do
    if OptionValue(sorts[index]) == current then
      nextIndex = index + 1
      break
    end
  end
  if nextIndex > #sorts then nextIndex = 1 end
  profile.ui.sort = OptionValue(sorts[nextIndex])
  return profile.ui.sort
end

function QueryState:GetBudgetCost()
  local profile = self:GetProfile()
  return profile and profile.filters.budgetCost or "All"
end

function QueryState:CycleBudgetCost()
  return self:Cycle("budgetCost", budgets)
end

function QueryState:GetRequirement()
  local profile = self:GetProfile()
  return profile and profile.filters.requirement or "All"
end

function QueryState:CycleRequirement()
  return self:Cycle("requirement", requirements)
end

function QueryState:GetDyeability()
  local profile = self:GetProfile()
  return profile and profile.filters.dyeability or "All"
end

function QueryState:CycleDyeability()
  return self:Cycle("dyeability", dyeability)
end
