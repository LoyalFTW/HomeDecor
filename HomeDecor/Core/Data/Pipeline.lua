local _, NS = ...

local Pipeline = {}
NS.Systems.Pipeline = Pipeline

local function Normalize(value)
  if type(value) ~= "string" then return "" end
  return value:lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function Matches(record, query, search)
  if not query then return true end
  if query.category and query.category ~= "All" and record.category ~= query.category then return false end
  if query.expansion and NS.Systems.QueryState:NormalizeExpansion(record.expansion) ~= NS.Systems.QueryState:NormalizeExpansion(query.expansion) then return false end
  if query.profession and record.profession ~= query.profession then return false end
  if query.class and query.class ~= "All" and Normalize(NS.Systems.Housing:GetClassRestriction(record)) ~= Normalize(query.class) then return false end
  if query.sourceType and query.sourceType ~= "All" and record.sourceType ~= query.sourceType then return false end
  if query.faction and query.faction ~= "All" and record.faction ~= query.faction then return false end
  if query.zone and query.zone ~= "All" and record.zone ~= query.zone then return false end
  if query.subcategory and query.subcategory ~= "All" and record.subcategory ~= query.subcategory then return false end
  if query.size and query.size ~= "All" and record.size ~= query.size then return false end
  if query.budgetCost and query.budgetCost ~= "All" then
    local cost = tonumber(record.budgetCost)
    if query.budgetCost == "none" and cost and cost > 0 then return false end
    if query.budgetCost == "low" and (not cost or cost < 1 or cost > 2) then return false end
    if query.budgetCost == "medium" and (not cost or cost < 3 or cost > 4) then return false end
    if query.budgetCost == "high" and (not cost or cost < 5) then return false end
  end
  if query.requirement and query.requirement ~= "All" then
    local requirements = record.requirements
    local key = query.requirement:lower()
    if type(requirements) ~= "table" or requirements[key] == nil then return false end
  end
  if query.dyeability == "Dyeable" and not NS.Systems.Housing:IsDyeable(record) then return false end
  if query.dyeability == "Not Dyeable" and NS.Systems.Housing:IsDyeable(record) then return false end
  if type(query.colors) == "table" and next(query.colors) then
    local found = false
    for _, color in ipairs(type(record.colors) == "table" and record.colors or {}) do
      if query.colors[color] == true then found = true break end
      for selected, active in pairs(query.colors) do
        if active == true and Normalize(selected) == Normalize(color) then found = true break end
      end
      if found then break end
    end
    if not found then return false end
  end
  if query.hidePvp and (record.sourceType == "pvp" or record.category == "PvP") then return false end
  if query.requiresReputation then
    local requirements = record.requirements
    if type(requirements) ~= "table" or (requirements.reputation == nil and requirements.rep == nil) then return false end
  end
  if query.requiresRenown and not NS.Systems.Requirements:IsRenown(record) then return false end
  if query.questCompleted then
    local requirements = record.requirements
    local quest = type(requirements) == "table" and requirements.quest
    local questID = tonumber(type(quest) == "table" and quest.id or quest)
    if not questID or not _G.C_QuestLog or not _G.C_QuestLog.IsQuestFlaggedCompleted or not _G.C_QuestLog.IsQuestFlaggedCompleted(questID) then return false end
  end
  if query.achievementCompleted then
    local requirements = record.requirements
    local achievement = type(requirements) == "table" and requirements.achievement
    local achievementID = tonumber(type(achievement) == "table" and achievement.id or achievement)
    local completed = achievementID and _G.GetAchievementInfo and select(4, _G.GetAchievementInfo(achievementID))
    if completed ~= true then return false end
  end
  if query.favoriteOnly and not NS.Systems.Favorites:IsFavorite(record) then return false end
  if query.trackedOnly and not NS.Systems.Tracker:IsTracked(record) then return false end
  if query.ownership == "Owned" and not NS.Systems.Collection:IsOwned(record) then return false end
  if query.ownership == "Missing" and NS.Systems.Collection:IsOwned(record) then return false end
  if search and not NS.Systems.SearchIndex:Matches(record, search) then return false end
  return true
end

function Pipeline:ForEach(query, consume, limit)
  local records = NS.Systems.Catalog.ordered
  local count = 0
  local search = NS.Systems.SearchIndex:Compile(query and query.search)
  local favoriteSeen = query and (query.favoriteOnly or query.trackedOnly) and {} or nil
  for index = 1, #records do
    local record = records[index]
    if Matches(record, query, search) then
      local favoriteKey = favoriteSeen and (record.decorID or record.itemID or record.id)
      if not favoriteKey or not favoriteSeen[favoriteKey] then
        if favoriteKey then favoriteSeen[favoriteKey] = true end
        count = count + 1
        if consume(record, count) == false then break end
        if limit and count >= limit then break end
      end
    end
  end
  return count
end

function Pipeline:Count(query)
  return self:ForEach(query, function() end)
end

function Pipeline:ForRange(query, offset, limit, consume)
  offset = math.max(0, tonumber(offset) or 0)
  limit = math.max(0, tonumber(limit) or 0)
  local matched = 0
  local emitted = 0
  return self:ForEach(query, function(record)
    matched = matched + 1
    if matched <= offset then return true end
    emitted = emitted + 1
    if consume(record, offset + emitted) == false then return false end
    return emitted < limit
  end)
end
