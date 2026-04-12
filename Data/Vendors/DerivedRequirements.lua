local ADDON, NS = ...

NS.Data = NS.Data or {}

local function sortedKeys(t)
  local keys = {}
  for k in pairs(t or {}) do
    keys[#keys + 1] = k
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)
  return keys
end

local function ensurePath(root, expName, zoneName)
  root[expName] = root[expName] or {}
  root[expName][zoneName] = root[expName][zoneName] or {}
  return root[expName][zoneName]
end

local function addDerived(root, seen, expName, zoneName, decorID, sourceType, requirementID, faction)
  if not expName or not zoneName or not decorID or not sourceType then return end

  local key = table.concat({
    tostring(expName),
    tostring(zoneName),
    tostring(decorID),
    tostring(sourceType),
    tostring(faction or ""),
  }, "\031")
  if seen[key] then return end
  seen[key] = true

  local bucket = ensurePath(root, expName, zoneName)
  bucket[#bucket + 1] = {
    decorID = decorID,
    source = {
      type = sourceType,
      id = requirementID,
      faction = faction,
    },
  }
end

local function mergeLegacyMap(root, seen, legacy, sourceType)
  if type(legacy) ~= "table" then return end

  for _, expName in ipairs(sortedKeys(legacy)) do
    local expTbl = legacy[expName]
    if type(expTbl) == "table" then
      for _, zoneName in ipairs(sortedKeys(expTbl)) do
        local ids = expTbl[zoneName]
        if type(ids) == "table" then
          for _, decorID in ipairs(ids) do
            addDerived(root, seen, expName, zoneName, decorID, sourceType, nil, nil)
          end
        end
      end
    end
  end
end

local function mergeOverrides(root, seen, overrides, sourceType)
  if type(overrides) ~= "table" then return end

  for _, expName in ipairs(sortedKeys(overrides)) do
    local expTbl = overrides[expName]
    if type(expTbl) == "table" then
      for _, zoneName in ipairs(sortedKeys(expTbl)) do
        local items = expTbl[zoneName]
        if type(items) == "table" then
          for _, item in ipairs(items) do
            if type(item) == "table" and item.decorID then
              local src = item.source or {}
              addDerived(
                root,
                seen,
                expName,
                zoneName,
                item.decorID,
                src.type or sourceType,
                tonumber(src.id or src.questID or src.achievementID) or src.id,
                src.faction
              )
            end
          end
        end
      end
    end
  end
end

local function buildDerivedFromVendors()
  local vendors = NS.Data and NS.Data.Vendors
  if type(vendors) ~= "table" then
    NS.Data.Achievements = NS.Data.Achievements or {}
    NS.Data.Quests = NS.Data.Quests or {}
    return
  end

  local achievements = {}
  local quests = {}
  local seenAchievementDecor = {}
  local seenQuestDecor = {}

  local legacy = NS.Data and NS.Data.LegacySourceMap or {}
  mergeLegacyMap(achievements, seenAchievementDecor, legacy.Achievements, "achievement")
  mergeLegacyMap(quests, seenQuestDecor, legacy.Quests, "quest")

  for _, expName in ipairs(sortedKeys(vendors)) do
    local expTbl = vendors[expName]
    if type(expTbl) == "table" then
      for _, zoneName in ipairs(sortedKeys(expTbl)) do
        local vendorList = expTbl[zoneName]
        if type(vendorList) == "table" then
          for _, vendor in ipairs(vendorList) do
            local items = vendor and vendor.items
            local vendorSource = vendor and vendor.source or {}
            local vendorFaction = vendor.faction or vendorSource.faction
            if type(items) == "table" then
              for _, item in ipairs(items) do
                if type(item) == "table" and item.decorID then
                  local req = item.requirements
                  local achID = req and req.achievement and tonumber(req.achievement.id or req.achievement)
                  local questID = req and req.quest and tonumber(req.quest.id or req.quest)

                  if achID then
                    addDerived(achievements, seenAchievementDecor, expName, zoneName, item.decorID, "achievement", achID, vendorFaction)
                  end

                  if questID then
                    addDerived(quests, seenQuestDecor, expName, zoneName, item.decorID, "quest", questID, vendorFaction)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  local overrides = NS.Data and NS.Data.DerivedRequirementOverrides or {}
  mergeOverrides(achievements, seenAchievementDecor, overrides.Achievements, "achievement")
  mergeOverrides(quests, seenQuestDecor, overrides.Quests, "quest")

  NS.Data.Achievements = achievements
  NS.Data.Quests = quests
end

buildDerivedFromVendors()
