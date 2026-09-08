local _, NS = ...

NS.UI = NS.UI or {}
local AltProfessions = {}
NS.UI.AltProfessions = AltProfessions

local RequestRefresh = NS.Debounce(0.08, function() AltProfessions:Refresh() end)

local ROW_HEIGHT = 36
local CHARACTER_HEIGHT = 52
local CHARACTER_POOL = 13
local RECIPE_POOL = 18

local OPPORTUNITY_PROFESSIONS = {
  "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering",
  "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring",
}

local OPPORTUNITY_EXPANSIONS = {
  { label = "Classic", keys = { "Classic" } },
  { label = "TBC", keys = { "Outland", "TBC" } },
  { label = "WotLK", keys = { "Northrend", "WotLK" } },
  { label = "Cata", keys = { "Cataclysm", "Cata" } },
  { label = "MoP", keys = { "Pandaria", "Pandaren", "MoP" } },
  { label = "WoD", keys = { "Draenor", "Warlords", "WoD" } },
  { label = "Legion", keys = { "Legion" } },
  { label = "BfA", keys = { "Kul Tiran", "Kul", "BfA" } },
  { label = "SL", keys = { "Shadowlands", "SL" } },
  { label = "DF", keys = { "Dragon Isles", "Dragon", "DF" } },
  { label = "TWW", keys = { "Khaz Algar", "Khaz", "TWW" } },
  { label = "Mid", keys = { "Midnight", "Mid" } },
}

local ITEM_FILTERS = {
  { label = "All Items", value = "all" },
  { label = "With Price Data", value = "priced" },
  { label = "Profitable Only", value = "profitable" },
  { label = "High Profit (>100g)", value = "high" },
  { label = "Mega Profit (>300g)", value = "mega" },
  { label = "Can Craft", value = "craftable" },
}

local ITEM_SORTS = {
  { label = "Profit: High to Low", value = "profitDesc" },
  { label = "Profit: Low to High", value = "profitAsc" },
  { label = "Margin: High to Low", value = "marginDesc" },
  { label = "Market: High to Low", value = "sellDesc" },
  { label = "Cost: High to Low", value = "costDesc" },
  { label = "Crafters: High to Low", value = "crafterCountDesc" },
  { label = "Name: A to Z", value = "nameAsc" },
}

local OPPORTUNITY_COLORS = {
  ready = { 0.04, 0.18, 0.08, 0.98 },
  close = { 0.22, 0.12, 0.02, 0.98 },
  far = { 0.044, 0.044, 0.038, 0.98 },
  empty = { 0.030, 0.031, 0.027, 0.99 },
}

local function Controls()
  return NS.UI.Controls
end

local function Count(source)
  local total = 0
  for _ in pairs(source or {}) do total = total + 1 end
  return total
end

local function Compact(value)
  value = tonumber(value) or 0
  if value >= 1000 then return string.format("%.1fk", value / 1000) end
  return tostring(value)
end

local function Money(value)
  value = tonumber(value)
  if not value then return "--" end
  local gold = value / 10000
  if math.abs(gold) >= 1000 then return string.format("%.1fk", gold / 1000) end
  if math.abs(gold) >= 1 then return string.format("%.1fg", gold) end
  return string.format("%.1fs", value / 100)
end

local function MatchesExpansion(value, expansion)
  value = tostring(value or ""):lower()
  for _, key in ipairs(expansion.keys) do
    if value:find(key:lower(), 1, true) then return true end
  end
  return false
end

local function Stamp(value)
  value = tonumber(value) or 0
  if value <= 0 then return "Not scanned" end
  local age = math.max(0, (GetServerTime and GetServerTime() or time()) - value)
  if age < 60 then return "Just now" end
  if age < 3600 then return math.floor(age / 60) .. "m ago" end
  if age < 86400 then return math.floor(age / 3600) .. "h ago" end
  return math.floor(age / 86400) .. "d ago"
end

local function CreateLabel(parent, font, color)
  local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
  Controls():TextColor(label, color or "text")
  return label
end

local function CreateMetric(parent, title)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Controls():Backdrop(frame, Controls().colors.panel)
  frame.title = CreateLabel(frame, "GameFontNormalSmall", "muted")
  frame.title:SetPoint("TOPLEFT", 12, -10)
  frame.title:SetText(title)
  frame.value = CreateLabel(frame, "GameFontNormalLarge", "accent")
  frame.value:SetPoint("BOTTOMLEFT", 12, 9)
  return frame
end

local function CreateDropdown(parent, width)
  local button = Controls():CreateButton(parent, "", width, 27)
  button.value = "All"
  return button
end

local function CharacterColor(class)
  local color = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
  if color then return color.r, color.g, color.b end
  return 0.93, 0.91, 0.85
end

function AltProfessions:GetSettings()
  local profile = NS.Systems.Database:GetProfile()
  profile.altProfessions = profile.altProfessions or { characters = {} }
  profile.altProfessions.ui = profile.altProfessions.ui or {
    character = "All",
    profession = "All",
    expansion = "All",
    search = "",
    sort = { key = "name", descending = false },
    mode = "opportunities",
    itemFilter = "all",
    itemSort = "profitDesc",
    opportunityProfession = "Alchemy",
    opportunityExpansion = "Mid",
  }
  local settings = profile.altProfessions.ui
  settings.mode = settings.mode or "opportunities"
  settings.itemFilter = settings.itemFilter or "all"
  settings.itemSort = settings.itemSort or "profitDesc"
  settings.opportunityProfession = settings.opportunityProfession or "Alchemy"
  settings.opportunityExpansion = settings.opportunityExpansion or "Mid"
  if settings.accountDefaultApplied ~= true then
    settings.character = "All"
    settings.accountDefaultApplied = true
  end
  return settings
end


function AltProfessions:EnsurePrices()
  local pricing = NS.UI.DecorPricing
  if not pricing or self.priceScan or pricing.scanning or (pricing.entries and pricing.lastRefresh and not pricing.invalidated and time() - pricing.lastRefresh < 120) then return end
  local candidates = NS.Systems.MarketData:BuildCandidates()
  local entries = pricing.entries or {}
  local token = (self.priceToken or 0) + 1
  self.priceToken = token
  self.priceScan = true
  pricing.scanning = true
  local index = 1
  local function step()
    if token ~= AltProfessions.priceToken then return end
    local last = math.min(#candidates, index + 7)
    for position = index, last do entries[position] = NS.Systems.MarketData:Price(candidates[position], entries[position]) end
    index = last + 1
    if index <= #candidates then C_Timer.After(0, step) return end
    for position = #candidates + 1, #entries do entries[position] = nil end
    pricing.entries = entries
    pricing.lastRefresh = time()
    pricing.invalidated = false
    pricing.scanning = false
    AltProfessions.priceScan = false
    if pricing.panel and pricing.panel:IsShown() then pricing:UpdateHeader() pricing:UpdateMetrics() pricing:Render() end
    AltProfessions:Refresh()
  end
  step()
end

function AltProfessions:BuildCandidateIndex()
  if self.candidateIndex then return self.candidateIndex end
  local index = {}
  local expansions = {}
  local expansionSeen = {}
  for _, candidate in ipairs(NS.Systems.MarketData:BuildCandidates()) do
    if candidate.skillID then index[tonumber(candidate.skillID)] = candidate end
    if candidate.expansion and not expansionSeen[candidate.expansion] then
      expansionSeen[candidate.expansion] = true
      expansions[#expansions + 1] = candidate.expansion
    end
  end
  table.sort(expansions)
  self.candidateIndex = index
  self.expansions = expansions
  return index
end

function AltProfessions:BuildModels(includeRecipes)
  local system = NS.Systems.AltProfessions
  local settings = self:GetSettings()
  local characters = system:GetCharacters()
  local visibleCharacters = self.characterModel or {}
  wipe(visibleCharacters)
  self.characterModel = visibleCharacters
  local totalProfessions = 0
  local totalRecipes = 0
  local accountRecipes = self.accountRecipes or {}
  self.accountRecipes = accountRecipes
  wipe(accountRecipes)
  for _, character in ipairs(characters) do
    character.professionCount = Count(character.professions)
    character.recipeCount = Count(character.recipes)
    totalProfessions = totalProfessions + character.professionCount
    for recipeID, learned in pairs(character.recipes or {}) do if learned then accountRecipes[recipeID] = true end end
    visibleCharacters[#visibleCharacters + 1] = character
  end
  totalRecipes = Count(accountRecipes)
  if includeRecipes == false then
    self.metrics = self.metrics or {}
    self.metrics.characters = #characters
    self.metrics.professions = totalProfessions
    self.metrics.recipes = totalRecipes
    self.metrics.visible = 0
    return
  end
  local index = self:BuildCandidateIndex()
  local recipes = self.recipeModel or {}
  wipe(recipes)
  self.recipeModel = recipes
  local recipePool = self.recipeDataPool or {}
  self.recipeDataPool = recipePool
  local search = (settings.search or ""):lower()
  local selectedRecipes
  if settings.character ~= "All" then
    for _, character in ipairs(characters) do
      if character.key == settings.character then selectedRecipes = character.recipes break end
    end
  end
  local pricing = NS.UI.DecorPricing
  local priced = self.pricedByRecipe or {}
  self.pricedByRecipe = priced
  wipe(priced)
  for _, entry in ipairs(pricing and pricing.entries or {}) do priced[tonumber(entry.skillID)] = entry end
  local professionModel = self.professionModel or {}
  wipe(professionModel)
  self.professionModel = professionModel
  local professionRows = self.professionRowsByName or {}
  self.professionRowsByName = professionRows
  professionRows.All = professionRows.All or {}
  professionRows.All.name = "All"
  professionRows.All.label = "All Professions"
  professionRows.All.count = 0
  professionRows.All.profit = 0
  professionRows.All.priced = 0
  professionModel[1] = professionRows.All
  for _, name in ipairs(OPPORTUNITY_PROFESSIONS) do
    local row = professionRows[name]
    if not row then row = {} professionRows[name] = row end
    row.name = name
    row.label = name
    row.count = 0
    row.profit = 0
    row.priced = 0
    professionRows[name] = row
    professionModel[#professionModel + 1] = row
  end
  for recipeID, candidate in pairs(index) do
    local row = professionRows[candidate.profession]
    local market = priced[recipeID]
    local characterMatch = not selectedRecipes or selectedRecipes[tostring(recipeID)] or selectedRecipes[recipeID]
    local expansionMatch = settings.expansion == "All" or candidate.expansion == settings.expansion
    if row and characterMatch and expansionMatch then
      row.count = row.count + 1
      professionRows.All.count = professionRows.All.count + 1
      if market and market.profit then
        row.profit = row.profit + market.profit
        row.priced = row.priced + 1
        professionRows.All.profit = professionRows.All.profit + market.profit
        professionRows.All.priced = professionRows.All.priced + 1
      end
    end
  end
  for recipeID, candidate in pairs(index) do
    if not selectedRecipes or selectedRecipes[tostring(recipeID)] or selectedRecipes[recipeID] then
      local market = priced[recipeID]
      local fallback = candidate.entry and candidate.entry.title
      local name = market and market.name or NS.Systems.ItemResolver:GetName(candidate.itemID, fallback)
      local names, _, crafterCount = system:GetCrafterNames(recipeID)
      local professionMatch = settings.profession == "All" or candidate.profession == settings.profession
      local expansionMatch = settings.expansion == "All" or candidate.expansion == settings.expansion
      local searchMatch = search == "" or (name or ""):lower():find(search, 1, true) or (candidate.profession or ""):lower():find(search, 1, true) or (candidate.expansion or ""):lower():find(search, 1, true)
      local profit = market and market.profit
      local itemFilter = settings.itemFilter
      local filterMatch = itemFilter == "all"
        or itemFilter == "priced" and market and market.sell
        or itemFilter == "profitable" and profit and profit > 0
        or itemFilter == "high" and profit and profit > 1000000
        or itemFilter == "mega" and profit and profit > 3000000
        or itemFilter == "craftable" and crafterCount > 0
      if professionMatch and expansionMatch and searchMatch and filterMatch then
        local position = #recipes + 1
        local row = recipePool[position]
        if not row then row = {} recipePool[position] = row end
        row.recipeID = recipeID
        if row.itemID ~= candidate.itemID then row.icon = nil end
        row.itemID = candidate.itemID
        row.name = name
        row.profession = candidate.profession
        row.expansion = candidate.expansion
        row.crafters = table.concat(names, ", ")
        row.crafterCount = crafterCount
        row.cost = market and market.cost
        row.sell = market and market.sell
        row.profit = profit
        row.margin = market and market.margin
        row.ppl = market and market.ppl
        row.lumber = market and market.lumber
        recipes[position] = row
      end
    end
  end
  local itemSort = settings.itemSort or "profitDesc"
  table.sort(recipes, function(left, right)
    local key = itemSort:match("^(.-)Asc$") or itemSort:match("^(.-)Desc$") or "profit"
    if key == "name" then
      local a, b = (left.name or ""):lower(), (right.name or ""):lower()
      return itemSort:sub(-3) == "Asc" and a < b or a > b
    end
    local a, b = tonumber(left[key]), tonumber(right[key])
    if a == b then return (left.name or "") < (right.name or "") end
    if a == nil then return false end
    if b == nil then return true end
    return itemSort:sub(-3) == "Asc" and a < b or a > b
  end)
  self.metrics = self.metrics or {}
  self.metrics.characters = #characters
  self.metrics.professions = totalProfessions
  self.metrics.recipes = totalRecipes
  self.metrics.visible = #recipes
end

function AltProfessions:SelectCharacter(key)
  local settings = self:GetSettings()
  settings.character = key or "All"
  Controls():ResetScrollFrame(self.panel.recipeScroll, false)
  self:Refresh()
end

function AltProfessions:SelectProfession(name)
  local settings = self:GetSettings()
  settings.profession = name or "All"
  Controls():ResetScrollFrame(self.panel.recipeScroll, false)
  self:Refresh()
end

function AltProfessions:OpenPricing(row)
  local pricing = NS.UI.DecorPricing
  if not pricing or not row then return end
  local settings = pricing:GetSettings()
  settings.search = row.name or ""
  settings.profession = row.profession or "All"
  settings.expansion = row.expansion or "All"
  settings.altsOnly = true
  NS.Systems.QueryState:SetRoute("pricing")
  if NS.UI.CatalogView then NS.UI.CatalogView:Refresh(true) end
end

function AltProfessions:CreateCharacterRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(CHARACTER_HEIGHT - 2)
  Controls():Backdrop(row, Controls().colors.row)
  Controls():ApplyHover(row, Controls().colors.row)
  row.name = CreateLabel(row, "GameFontNormal")
  row.name:SetPoint("TOPLEFT", 12, -9)
  row.summary = CreateLabel(row, "GameFontDisableSmall", "muted")
  row.summary:SetPoint("BOTTOMLEFT", 12, 8)
  row.summary:SetWidth(172)
  row.summary:SetJustifyH("LEFT")
  row.updated = CreateLabel(row, "GameFontDisableSmall", "muted")
  row.updated:SetPoint("RIGHT", -10, 0)
  row:SetScript("OnClick", function(self) AltProfessions:SelectProfession(self.profession) end)
  row:HookScript("OnEnter", function(self)
    local profession = self.data
    if not profession or not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(profession.label)
    GameTooltip:AddDoubleLine("Decor recipes", profession.count, 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Recipes priced", profession.priced, 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Combined profit", Money(profession.profit), 0.65, 0.62, 0.56, 0.36, 0.92, 0.52)
    GameTooltip:Show()
  end)
  row:HookScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  Controls():ForwardScrollWheel(row, scroll)
  return row
end

function AltProfessions:CreateRecipeRow(parent, scroll)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetHeight(ROW_HEIGHT - 2)
  Controls():Backdrop(row, Controls().colors.row)
  Controls():ApplyHover(row, Controls().colors.row)
  row.icon = row:CreateTexture(nil, "ARTWORK")
  row.icon:SetSize(24, 24)
  row.icon:SetPoint("LEFT", 8, 0)
  row.name = CreateLabel(row, "GameFontNormalSmall")
  row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
  row.name:SetWidth(162)
  row.name:SetJustifyH("LEFT")
  row.cost = CreateLabel(row, "GameFontDisableSmall", "muted")
  row.cost:SetPoint("LEFT", 210, 0)
  row.cost:SetWidth(68)
  row.cost:SetJustifyH("RIGHT")
  row.sell = CreateLabel(row, "GameFontDisableSmall", "accent")
  row.sell:SetPoint("LEFT", 286, 0)
  row.sell:SetWidth(68)
  row.sell:SetJustifyH("RIGHT")
  row.profit = CreateLabel(row, "GameFontDisableSmall", "success")
  row.profit:SetPoint("LEFT", 362, 0)
  row.profit:SetWidth(72)
  row.profit:SetJustifyH("RIGHT")
  row.crafters = CreateLabel(row, "GameFontDisableSmall", "success")
  row.crafters:SetPoint("LEFT", 446, 0)
  row.crafters:SetPoint("RIGHT", -10, 0)
  row.crafters:SetJustifyH("LEFT")
  row:SetScript("OnClick", function(self) AltProfessions:OpenPricing(self.data) end)
  row:SetScript("OnEnter", function(self)
    local data = self.data
    if not data or not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(data.name or "Decor Recipe")
    GameTooltip:AddDoubleLine("Profession", data.profession or "--", 0.65, 0.62, 0.56, 1, 0.76, 0.08)
    GameTooltip:AddDoubleLine("Expansion", data.expansion or "--", 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Craft Cost", Money(data.cost), 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Market", Money(data.sell), 0.65, 0.62, 0.56, 1, 0.76, 0.08)
    GameTooltip:AddDoubleLine("Profit", Money(data.profit), 0.65, 0.62, 0.56, data.profit and data.profit >= 0 and 0.36 or 1, data.profit and data.profit >= 0 and 0.92 or 0.38, data.profit and data.profit >= 0 and 0.52 or 0.38)
    GameTooltip:AddDoubleLine("Margin", data.margin and string.format("%.0f%%", data.margin) or "--", 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Per Lumber", Money(data.ppl) .. (data.lumber and data.lumber ~= "-" and ("  " .. data.lumber) or ""), 0.65, 0.62, 0.56, 0.93, 0.91, 0.85)
    GameTooltip:AddDoubleLine("Crafters", data.crafters ~= "" and data.crafters or "None scanned", 0.65, 0.62, 0.56, 0.36, 0.92, 0.52)
    GameTooltip:Show()
  end)
  row:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  Controls():ForwardScrollWheel(row, scroll)
  return row
end

function AltProfessions:RenderCharacters()
  local frame = self.panel
  local model = self.professionModel or {}
  local first = math.max(1, math.floor((frame.characterScroll:GetVerticalScroll() or 0) / CHARACTER_HEIGHT) + 1)
  local selected = self:GetSettings().profession
  for index, row in ipairs(frame.characterRows) do
    local absolute = first + index - 1
    local profession = model[absolute]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * CHARACTER_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((absolute - 1) * CHARACTER_HEIGHT))
    row:SetShown(profession ~= nil)
    if profession then
      row.profession = profession.name
      row.data = profession
      row.name:SetText(profession.label)
      Controls():TextColor(row.name, "text")
      row.summary:SetText(profession.count .. " decor recipes")
      row.updated:SetText(profession.priced > 0 and Money(profession.profit) or "--")
      Controls():SetButtonSelected(row, selected == profession.name)
    end
  end
end

function AltProfessions:RenderRecipes()
  local frame = self.panel
  local model = self.recipeModel or {}
  local first = math.max(1, math.floor((frame.recipeScroll:GetVerticalScroll() or 0) / ROW_HEIGHT) + 1)
  for index, row in ipairs(frame.recipeRows) do
    local absolute = first + index - 1
    local data = model[absolute]
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetPoint("TOPRIGHT", 0, -((absolute - 1) * ROW_HEIGHT))
    row:SetShown(data ~= nil)
    row.data = data
    if data then
      if data.icon == nil and C_Item and C_Item.GetItemIconByID then
        local ok, value = pcall(C_Item.GetItemIconByID, data.itemID)
        if ok then data.icon = value or false end
      end
      row.icon:SetTexture(data.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
      row.name:SetText(data.name)
      row.cost:SetText(Money(data.cost))
      row.sell:SetText(Money(data.sell))
      row.profit:SetText(Money(data.profit))
      Controls():TextColor(row.profit, data.profit and data.profit >= 0 and "success" or data.profit and "danger" or "muted")
      row.crafters:SetText(data.crafters ~= "" and data.crafters or "Unknown")
    end
  end
end

function AltProfessions:UpdateDropdowns()
  local frame = self.panel
  local settings = self:GetSettings()
  local selectedName = "All Characters"
  for _, character in ipairs(self.characterModel or {}) do if character.key == settings.character then selectedName = character.name break end end
  frame.characterButton:SetText(selectedName)
  frame.professionButton:SetText(settings.profession == "All" and "All Professions" or settings.profession)
  frame.expansionButton:SetText(settings.expansion == "All" and "All Expansions" or settings.expansion)
  local filterLabel, sortLabel
  for _, option in ipairs(ITEM_FILTERS) do if option.value == settings.itemFilter then filterLabel = option.label break end end
  for _, option in ipairs(ITEM_SORTS) do if option.value == settings.itemSort then sortLabel = option.label break end end
  frame.filterButton:SetText(filterLabel or "All Items")
  frame.sortButton:SetText(sortLabel or settings.itemSort:gsub("Asc$", ": Low"):gsub("Desc$", ": High"))
  Controls():SetButtonSelected(frame.allCharacters, settings.profession == "All")
end

function AltProfessions:GetOpportunityAlts(professionName, expansion)
  local key = professionName .. "|" .. expansion.label
  local lookup = self.opportunityLookup or {}
  self.opportunityLookup = lookup
  local output = lookup[key]
  local revision = NS.Systems.AltProfessions.revision or 0
  if output and self.opportunityRevision == revision then return output end
  if not output then output = {} lookup[key] = output end
  local count = 0
  for _, character in ipairs(self.characterModel or NS.Systems.AltProfessions:GetCharacters()) do
    for _, profession in pairs(character.professions or {}) do
      if profession.name == professionName then
        for _, tier in pairs(profession.tiers or {}) do
          if MatchesExpansion(tier.name, expansion) then
            local current = tonumber(tier.current) or 0
            local maximum = math.max(1, tonumber(tier.maximum) or 1)
            local remaining = maximum - current
            count = count + 1
            local row = output[count]
            if not row then row = {} output[count] = row end
            row.name = character.name or character.key
            row.current = current
            row.maximum = maximum
            row.status = current >= maximum and "ready" or remaining <= 50 and "close" or "far"
          end
        end
      end
    end
  end
  for index = count + 1, #output do output[index] = nil end
  table.sort(output, function(left, right)
    if left.current == right.current then return left.name < right.name end
    return left.current > right.current
  end)
  return output
end

function AltProfessions:GetTrainers(professionName, expansion)
  local bundles = _G.HomeDecorDataBundles
  local bundle = bundles and bundles.HomeDecor_Data_Trainers
  if not bundle and C_AddOns and C_AddOns.LoadAddOn and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("HomeDecor") then
    pcall(C_AddOns.LoadAddOn, "HomeDecor_Data_Trainers")
    bundles = _G.HomeDecorDataBundles
    bundle = bundles and bundles.HomeDecor_Data_Trainers
  end
  local trainers = bundle and bundle.Trainers
  local output = {}
  for _, key in ipairs(expansion.keys or {}) do
    for _, entry in ipairs(trainers and trainers[professionName] and trainers[professionName][key] or {}) do
      if entry.source then output[#output + 1] = entry.source end
    end
  end
  return output
end

function AltProfessions:OpenTrainers(anchor)
  local settings = self:GetSettings()
  local expansion
  for _, value in ipairs(OPPORTUNITY_EXPANSIONS) do if value.label == settings.opportunityExpansion then expansion = value break end end
  if not expansion then return end
  local options = {}
  for _, trainer in ipairs(self:GetTrainers(settings.opportunityProfession, expansion)) do
    options[#options + 1] = { label = (trainer.name or "Trainer") .. " - " .. (trainer.zone or "Unknown"), value = trainer }
  end
  if #options == 0 then options[1] = { label = "No trainer locations available", value = false, disabled = true } end
  NS.UI.Dropdown:Show(anchor, options, nil, function(trainer)
    if not trainer or not trainer.worldmap then return end
    local mapID, x, y = trainer.worldmap:match("^(%d+):(%d+):(%d+)$")
    mapID, x, y = tonumber(mapID), tonumber(x), tonumber(y)
    if mapID and x and y and UiMapPoint and C_Map and C_Map.SetUserWaypoint then
      local point = UiMapPoint.CreateFromCoordinates(mapID, x / 10000, y / 10000)
      if point then
        C_Map.SetUserWaypoint(point)
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
        if WorldMapFrame then WorldMapFrame:SetMapID(mapID) WorldMapFrame:Show() end
      end
    end
  end)
end

function AltProfessions:RefreshOpportunities()
  local frame = self.panel
  if not frame or not frame.opportunity then return end
  local settings = self:GetSettings()
  local ready, close = 0, 0
  for rowIndex, professionName in ipairs(OPPORTUNITY_PROFESSIONS) do
    for columnIndex, expansion in ipairs(OPPORTUNITY_EXPANSIONS) do
      local cell = frame.opportunityCells[rowIndex][columnIndex]
      local alts = self:GetOpportunityAlts(professionName, expansion)
      cell.alts = alts
      local best = alts[1]
      local status = "empty"
      for _, alt in ipairs(alts) do
        if alt.status == "ready" then status = "ready" break end
        if alt.status == "close" then status = "close" elseif status == "empty" then status = "far" end
      end
      if status == "ready" then ready = ready + 1 elseif status == "close" then close = close + 1 end
      cell.value:SetText(best and (best.current .. "/" .. best.maximum) or "--")
      cell.name:SetText(best and best.name:sub(1, 7) or "")
      local selected = settings.opportunityProfession == professionName and settings.opportunityExpansion == expansion.label
      Controls():SetButtonSelected(cell, selected)
      local color = selected and Controls().colors.hover or OPPORTUNITY_COLORS[status]
      cell:SetBackdropColor(color[1], color[2], color[3], color[4])
    end
  end
  frame.opportunitySummary:SetText(ready .. " ready  |  " .. close .. " within 50 skill points")
  self.opportunityRevision = NS.Systems.AltProfessions.revision or 0
  local selectedExpansion
  for _, expansion in ipairs(OPPORTUNITY_EXPANSIONS) do if expansion.label == settings.opportunityExpansion then selectedExpansion = expansion break end end
  selectedExpansion = selectedExpansion or OPPORTUNITY_EXPANSIONS[#OPPORTUNITY_EXPANSIONS]
  local alts = self:GetOpportunityAlts(settings.opportunityProfession, selectedExpansion)
  frame.opportunityTitle:SetText(settings.opportunityProfession .. " - " .. selectedExpansion.label)
  local lines = self.opportunityLines or {}
  self.opportunityLines = lines
  wipe(lines)
  for _, alt in ipairs(alts) do lines[#lines + 1] = alt.name .. "  " .. alt.current .. "/" .. alt.maximum .. "  " .. (alt.status == "ready" and "Ready" or alt.status == "close" and "Close" or "Training") end
  if #lines == 0 then lines[1] = "No saved skill data. Log onto an alt and open this profession to scan it." end
  frame.opportunityAlts:SetText(table.concat(lines, "\n"))
  local profits = self.opportunityProfits or {}
  self.opportunityProfits = profits
  wipe(profits)
  for _, row in ipairs(NS.UI.DecorPricing and NS.UI.DecorPricing.entries or {}) do
    if row.profession == settings.opportunityProfession and MatchesExpansion(row.expansion, selectedExpansion) then profits[#profits + 1] = row end
  end
  table.sort(profits, function(left, right) return (left.profit or -math.huge) > (right.profit or -math.huge) end)
  wipe(lines)
  for index = 1, math.min(6, #profits) do lines[#lines + 1] = profits[index].name .. "  " .. Money(profits[index].profit) end
  frame.opportunityRecipes:SetText(#lines > 0 and table.concat(lines, "\n") or "Price data is loading for this profession.")
  local trainers = self:GetTrainers(settings.opportunityProfession, selectedExpansion)
  frame.trainerButton:SetText(#trainers > 0 and ("Trainers (" .. #trainers .. ")") or "Trainers")
end

function AltProfessions:SetMode(mode)
  local frame = self.panel
  if not frame then return end
  local settings = self:GetSettings()
  settings.mode = mode == "items" and "items" or "opportunities"
  local items = settings.mode == "items"
  frame.metrics:SetShown(items)
  frame.toolbar:SetShown(items)
  frame.leftPanel:SetShown(items)
  frame.rightPanel:SetShown(items)
  frame.opportunity:SetShown(not items)
  Controls():SetButtonSelected(frame.opportunitiesButton, not items)
  Controls():SetButtonSelected(frame.itemsButton, items)
  self:Refresh()
end

function AltProfessions:Refresh()
  local frame = self.panel
  if not frame or not frame:IsShown() then return end
  local items = self:GetSettings().mode == "items"
  self:BuildModels(items)
  self:EnsurePrices()
  local metrics = self.metrics
  frame.characterMetric.value:SetText(Compact(metrics.characters))
  frame.professionMetric.value:SetText(Compact(metrics.professions))
  frame.recipeMetric.value:SetText(Compact(metrics.recipes))
  frame.visibleMetric.value:SetText(Compact(metrics.visible))
  if items then
    frame.characterContent:SetHeight(math.max(1, #self.professionModel * CHARACTER_HEIGHT))
    frame.recipeContent:SetHeight(math.max(1, #self.recipeModel * ROW_HEIGHT))
    frame.empty:SetShown(#self.recipeModel == 0)
    frame.count:SetText(#self.recipeModel .. " decor recipes")
    self:UpdateDropdowns()
    Controls():SyncScrollFrame(frame.characterScroll)
    Controls():SyncScrollFrame(frame.recipeScroll)
    self:RenderCharacters()
    self:RenderRecipes()
  else
    self:RefreshOpportunities()
  end
end

function AltProfessions:Create(parent)
  if self.panel then
    self.panel:SetParent(parent)
    self.panel:SetAllPoints(parent)
    return self.panel
  end
  local frame = CreateFrame("Frame", nil, parent)
  frame:SetAllPoints(parent)
  self.panel = frame
  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(64)
  Controls():Backdrop(header, Controls().colors.header)
  local title = CreateLabel(header, "GameFontNormalLarge", "accent")
  title:SetPoint("TOPLEFT", 14, -12)
  title:SetText("Alt Professions")
  local subtitle = CreateLabel(header, "GameFontDisableSmall", "muted")
  subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
  subtitle:SetText("Profession tiers and known decor recipes are saved when each character logs in or opens a profession.")
  frame.scanButton = Controls():CreateButton(header, "Scan Current", 108, 28)
  frame.scanButton:SetPoint("RIGHT", -12, 0)
  frame.scanButton:SetScript("OnClick", function()
    if not NS.Systems.AltProfessions:ScanOpenProfession() then NS.Systems.AltProfessions:RefreshCurrentProfessions() end
  end)
  frame.itemsButton = Controls():CreateButton(header, "Item Tracker", 104, 28)
  frame.itemsButton:SetPoint("RIGHT", frame.scanButton, "LEFT", -7, 0)
  frame.itemsButton:SetScript("OnClick", function() AltProfessions:SetMode("items") end)
  frame.opportunitiesButton = Controls():CreateButton(header, "Opportunities", 112, 28)
  frame.opportunitiesButton:SetPoint("RIGHT", frame.itemsButton, "LEFT", -7, 0)
  frame.opportunitiesButton:SetScript("OnClick", function() AltProfessions:SetMode("opportunities") end)
  frame.metrics = CreateFrame("Frame", nil, frame)
  frame.metrics:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
  frame.metrics:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -10)
  frame.metrics:SetHeight(58)
  frame.characterMetric = CreateMetric(frame.metrics, "CHARACTERS")
  frame.professionMetric = CreateMetric(frame.metrics, "PROFESSIONS")
  frame.recipeMetric = CreateMetric(frame.metrics, "KNOWN DECOR RECIPES")
  frame.visibleMetric = CreateMetric(frame.metrics, "CURRENT VIEW")
  local metrics = { frame.characterMetric, frame.professionMetric, frame.recipeMetric, frame.visibleMetric }
  for index, metric in ipairs(metrics) do
    metric:SetPoint("TOP", 0, 0)
    metric:SetPoint("BOTTOM", 0, 0)
    if index == 1 then metric:SetPoint("LEFT", 0, 0) else metric:SetPoint("LEFT", metrics[index - 1], "RIGHT", 7, 0) end
  end
  frame.metrics:SetScript("OnSizeChanged", function(self)
    local width = math.max(1, ((self:GetWidth() or 0) - 21) / 4)
    for _, metric in ipairs(metrics) do metric:SetWidth(width) end
  end)
  local toolbar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  toolbar:SetPoint("TOPLEFT", frame.metrics, "BOTTOMLEFT", 0, -10)
  toolbar:SetPoint("TOPRIGHT", frame.metrics, "BOTTOMRIGHT", 0, -10)
  toolbar:SetHeight(70)
  frame.toolbar = toolbar
  Controls():Backdrop(toolbar, Controls().colors.header)
  frame.search = Controls():CreateSearchBox(toolbar, {
    height = 27,
    placeholder = "Search",
    text = self:GetSettings().search or "",
    onChanged = function(self)
      AltProfessions:GetSettings().search = self:GetText() or ""
      RequestRefresh()
    end,
  })
  frame.search:SetPoint("TOPLEFT", 8, -7)
  frame.search:SetSize(230, 27)
  frame.characterButton = CreateDropdown(toolbar, 148)
  frame.characterButton:SetPoint("LEFT", frame.search, "RIGHT", 8, 0)
  frame.professionButton = CreateDropdown(toolbar, 142)
  frame.professionButton:SetPoint("LEFT", frame.characterButton, "RIGHT", 7, 0)
  frame.expansionButton = CreateDropdown(toolbar, 138)
  frame.expansionButton:SetPoint("LEFT", frame.professionButton, "RIGHT", 7, 0)
  frame.count = CreateLabel(toolbar, "GameFontDisableSmall", "muted")
  frame.count:SetPoint("BOTTOMRIGHT", -10, 12)
  frame.filterButton = CreateDropdown(toolbar, 158)
  frame.filterButton:SetPoint("BOTTOMLEFT", 8, 7)
  frame.sortButton = CreateDropdown(toolbar, 178)
  frame.sortButton:SetPoint("LEFT", frame.filterButton, "RIGHT", 8, 0)
  frame.characterButton:SetScript("OnClick", function(self)
    local options = { { label = "All Characters", value = "All" } }
    for _, character in ipairs(AltProfessions.characterModel or {}) do options[#options + 1] = { label = character.name .. " - " .. (character.realm or "Unknown"), value = character.key } end
    NS.UI.Dropdown:Show(self, options, AltProfessions:GetSettings().character, function(value) AltProfessions:SelectCharacter(value) end)
  end)
  frame.professionButton:SetScript("OnClick", function(self)
    local options = { { label = "All Professions", value = "All" } }
    for _, name in ipairs(OPPORTUNITY_PROFESSIONS) do options[#options + 1] = name end
    NS.UI.Dropdown:Show(self, options, AltProfessions:GetSettings().profession, function(value)
      AltProfessions:GetSettings().profession = value
      Controls():ResetScrollFrame(frame.recipeScroll, false)
      AltProfessions:Refresh()
    end)
  end)
  frame.expansionButton:SetScript("OnClick", function(self)
    AltProfessions:BuildCandidateIndex()
    local options = { { label = "All Expansions", value = "All" } }
    for _, name in ipairs(AltProfessions.expansions or {}) do options[#options + 1] = name end
    NS.UI.Dropdown:Show(self, options, AltProfessions:GetSettings().expansion, function(value)
      AltProfessions:GetSettings().expansion = value
      Controls():ResetScrollFrame(frame.recipeScroll, false)
      AltProfessions:Refresh()
    end)
  end)
  frame.filterButton:SetScript("OnClick", function(self)
    NS.UI.Dropdown:Show(self, ITEM_FILTERS, AltProfessions:GetSettings().itemFilter, function(value)
      AltProfessions:GetSettings().itemFilter = value
      Controls():ResetScrollFrame(frame.recipeScroll, false)
      AltProfessions:Refresh()
    end)
  end)
  frame.sortButton:SetScript("OnClick", function(self)
    NS.UI.Dropdown:Show(self, ITEM_SORTS, AltProfessions:GetSettings().itemSort, function(value)
      AltProfessions:GetSettings().itemSort = value
      Controls():ResetScrollFrame(frame.recipeScroll, false)
      AltProfessions:Refresh()
    end)
  end)
  local left = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  left:SetPoint("TOPLEFT", toolbar, "BOTTOMLEFT", 0, -10)
  left:SetPoint("BOTTOMLEFT", 8, 8)
  left:SetWidth(284)
  frame.leftPanel = left
  Controls():Backdrop(left, Controls().colors.header)
  local leftTitle = CreateLabel(left, "GameFontNormalSmall", "accent")
  leftTitle:SetPoint("TOPLEFT", 12, -12)
  leftTitle:SetText("PROFESSIONS")
  local all = Controls():CreateButton(left, "All Professions", 250, 28)
  all:SetPoint("TOPLEFT", 9, -32)
  all:SetScript("OnClick", function() AltProfessions:SelectProfession("All") end)
  frame.allCharacters = all
  frame.characterScroll = Controls():CreateScrollFrame(left)
  frame.characterScroll:SetPoint("TOPLEFT", 8, -66)
  frame.characterScroll:SetPoint("BOTTOMRIGHT", -16, 8)
  frame.characterContent = CreateFrame("Frame", nil, frame.characterScroll)
  frame.characterContent:SetSize(250, 1)
  Controls():ConfigureScrollFrame(frame.characterScroll, frame.characterContent, { step = CHARACTER_HEIGHT, onScroll = function() AltProfessions:RenderCharacters() end })
  frame.characterRows = {}
  for index = 1, CHARACTER_POOL do frame.characterRows[index] = self:CreateCharacterRow(frame.characterContent, frame.characterScroll) end
  local right = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  right:SetPoint("TOPLEFT", left, "TOPRIGHT", 9, 0)
  right:SetPoint("BOTTOMRIGHT", -8, 8)
  frame.rightPanel = right
  Controls():Backdrop(right, Controls().colors.header)
  local headerRow = CreateFrame("Frame", nil, right, "BackdropTemplate")
  headerRow:SetPoint("TOPLEFT", 7, -7)
  headerRow:SetPoint("TOPRIGHT", -7, -7)
  headerRow:SetHeight(30)
  Controls():Backdrop(headerRow, Controls().colors.panel)
  local columns = {
    { label = "RECIPE", key = "name", x = 38, width = 162 },
    { label = "COST", key = "cost", x = 210, width = 68 },
    { label = "MARKET", key = "sell", x = 286, width = 68 },
    { label = "PROFIT", key = "profit", x = 362, width = 72 },
    { label = "CRAFTERS", key = "crafterCount", x = 446, width = 145 },
  }
  for _, column in ipairs(columns) do
    local sortKey = column.key
    local button = Controls():CreateButton(headerRow, column.label, column.width, 23)
    button:SetPoint("LEFT", column.x, 0)
    button:SetScript("OnClick", function()
      local settings = AltProfessions:GetSettings()
      local ascending = settings.itemSort == sortKey .. "Desc"
      settings.itemSort = sortKey .. (ascending and "Asc" or "Desc")
      Controls():ResetScrollFrame(frame.recipeScroll, false)
      AltProfessions:Refresh()
    end)
  end
  frame.recipeScroll = Controls():CreateScrollFrame(right)
  frame.recipeScroll:SetPoint("TOPLEFT", 7, -42)
  frame.recipeScroll:SetPoint("BOTTOMRIGHT", -16, 8)
  frame.recipeContent = CreateFrame("Frame", nil, frame.recipeScroll)
  frame.recipeContent:SetSize(720, 1)
  Controls():ConfigureScrollFrame(frame.recipeScroll, frame.recipeContent, { step = ROW_HEIGHT, onScroll = function() AltProfessions:RenderRecipes() end })
  frame.recipeRows = {}
  for index = 1, RECIPE_POOL do frame.recipeRows[index] = self:CreateRecipeRow(frame.recipeContent, frame.recipeScroll) end
  frame.empty = CreateLabel(right, "GameFontNormal", "muted")
  frame.empty:SetPoint("CENTER", frame.recipeScroll, "CENTER")
  frame.empty:SetText("No decor recipes match these filters.\nOpen a profession window on each alt to update craftable recipes.")
  frame.empty:SetJustifyH("CENTER")
  frame.opportunity = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  frame.opportunity:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -10)
  frame.opportunity:SetPoint("BOTTOMRIGHT", -8, 8)
  Controls():Backdrop(frame.opportunity, Controls().colors.header)
  frame.opportunitySummary = CreateLabel(frame.opportunity, "GameFontNormalSmall", "accent")
  frame.opportunitySummary:SetPoint("TOPLEFT", 12, -10)
  local grid = CreateFrame("Frame", nil, frame.opportunity)
  grid:SetPoint("TOPLEFT", 10, -32)
  grid:SetPoint("TOPRIGHT", -10, -32)
  grid:SetHeight(366)
  frame.opportunityHeaders = {}
  frame.opportunityLabels = {}
  frame.opportunityCells = {}
  for columnIndex, expansion in ipairs(OPPORTUNITY_EXPANSIONS) do
    local label = CreateLabel(grid, "GameFontDisableSmall", "accent")
    label:SetText(expansion.label)
    label:SetJustifyH("CENTER")
    frame.opportunityHeaders[columnIndex] = label
  end
  for rowIndex, professionName in ipairs(OPPORTUNITY_PROFESSIONS) do
    local label = CreateLabel(grid, "GameFontNormalSmall", "text")
    label:SetText(professionName)
    label:SetJustifyH("RIGHT")
    frame.opportunityLabels[rowIndex] = label
    frame.opportunityCells[rowIndex] = {}
    for columnIndex, expansion in ipairs(OPPORTUNITY_EXPANSIONS) do
      local cellProfession = professionName
      local cellExpansion = expansion
      local cell = CreateFrame("Button", nil, grid, "BackdropTemplate")
      cell:SetHeight(34)
      Controls():Backdrop(cell, Controls().colors.row)
      cell.value = CreateLabel(cell, "GameFontNormalSmall", "text")
      cell.value:SetPoint("TOP", 0, -5)
      cell.name = CreateLabel(cell, "GameFontDisableSmall", "muted")
      cell.name:SetPoint("BOTTOM", 0, 4)
      cell:SetScript("OnClick", function()
        local settings = AltProfessions:GetSettings()
        settings.opportunityProfession = cellProfession
        settings.opportunityExpansion = cellExpansion.label
        AltProfessions:Refresh()
      end)
      frame.opportunityCells[rowIndex][columnIndex] = cell
    end
  end
  grid:SetScript("OnSizeChanged", function(self)
    local leftWidth = 116
    local gap = 3
    local cellWidth = math.max(42, math.floor(((self:GetWidth() or 900) - leftWidth - gap * 11) / 12))
    for columnIndex, label in ipairs(frame.opportunityHeaders) do
      label:ClearAllPoints()
      label:SetPoint("TOPLEFT", leftWidth + (columnIndex - 1) * (cellWidth + gap), 0)
      label:SetWidth(cellWidth)
    end
    for rowIndex, label in ipairs(frame.opportunityLabels) do
      local y = -24 - (rowIndex - 1) * 38
      label:ClearAllPoints()
      label:SetPoint("TOPLEFT", 0, y - 9)
      label:SetWidth(leftWidth - 8)
      for columnIndex, cell in ipairs(frame.opportunityCells[rowIndex]) do
        cell:ClearAllPoints()
        cell:SetPoint("TOPLEFT", leftWidth + (columnIndex - 1) * (cellWidth + gap), y)
        cell:SetWidth(cellWidth)
      end
    end
  end)
  local detail = CreateFrame("Frame", nil, frame.opportunity, "BackdropTemplate")
  detail:SetPoint("TOPLEFT", grid, "BOTTOMLEFT", 0, -5)
  detail:SetPoint("BOTTOMRIGHT", -10, 10)
  Controls():Backdrop(detail, Controls().colors.panel)
  frame.opportunityTitle = CreateLabel(detail, "GameFontNormal", "accent")
  frame.opportunityTitle:SetPoint("TOPLEFT", 12, -10)
  local skillsTitle = CreateLabel(detail, "GameFontDisableSmall", "muted")
  skillsTitle:SetPoint("TOPLEFT", 12, -34)
  skillsTitle:SetText("ALT SKILL LEVELS")
  frame.opportunityAlts = CreateLabel(detail, "GameFontNormalSmall", "text")
  frame.opportunityAlts:SetPoint("TOPLEFT", skillsTitle, "BOTTOMLEFT", 0, -6)
  frame.opportunityAlts:SetPoint("BOTTOMLEFT", 12, 10)
  frame.opportunityAlts:SetWidth(360)
  frame.opportunityAlts:SetJustifyH("LEFT")
  local recipesTitle = CreateLabel(detail, "GameFontDisableSmall", "muted")
  recipesTitle:SetPoint("TOPLEFT", 398, -34)
  recipesTitle:SetText("BEST DECOR OPPORTUNITIES")
  frame.opportunityRecipes = CreateLabel(detail, "GameFontNormalSmall", "success")
  frame.opportunityRecipes:SetPoint("TOPLEFT", recipesTitle, "BOTTOMLEFT", 0, -6)
  frame.opportunityRecipes:SetPoint("BOTTOMRIGHT", -150, 10)
  frame.opportunityRecipes:SetJustifyH("LEFT")
  frame.trainerButton = Controls():CreateButton(detail, "Trainers", 126, 27)
  frame.trainerButton:SetPoint("TOPRIGHT", -10, -8)
  frame.trainerButton:SetScript("OnClick", function(self) AltProfessions:OpenTrainers(self) end)
  frame:SetScript("OnShow", function() AltProfessions:Refresh() end)
  frame:SetScript("OnHide", function() NS.UI.Dropdown:Hide() end)
  NS.OnMessage("HOMEDECOR_ALT_PROFESSIONS_UPDATED", function()
    if AltProfessions.panel and AltProfessions.panel:IsShown() then AltProfessions:Refresh() end
  end)
  NS.Systems.ItemResolver:Subscribe(self, function()
    if AltProfessions.panel and AltProfessions.panel:IsShown() then RequestRefresh() end
  end)
  self:SetMode(self:GetSettings().mode)
  return frame
end

return AltProfessions
