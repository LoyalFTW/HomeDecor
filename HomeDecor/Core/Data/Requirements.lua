local _, NS = ...

local Requirements = { revision = 0 }
NS.Systems.Requirements = Requirements

local achievementNames = {}
local questNames = {
  [14402] = "Ready to Go",
  [24675] = "Last Meal",
  [25720] = "The Downfall of Marl Wormthorn",
  [26754] = "Mor'bent's Bane",
  [26868] = "Axis of Awful",
  [27550] = "Pyrewood's Fall",
  [28035] = "The Mountain-Lord's Support",
  [28064] = "Welcome to the Brotherhood",
  [53566] = "Dark Iron Dwarves",
}
local pendingQuests = {}
local refreshTimer
local factionIDs = {
  ["ironforge"] = 47,
  ["stormwind"] = 72,
  ["gilneas"] = 1134,
  ["wildhammer clan"] = 1174,
  ["council of exarchs"] = 1731,
  ["proudmoore admiralty"] = 2160,
  ["storm's wake"] = 2162,
  ["tranquillien"] = 922,
  ["laughing skull orcs"] = 1708,
  ["zandalari empire"] = 2103,
  ["talanji's expedition"] = 2156,
  ["the honorbound"] = 2157,
  ["honorbound"] = 2157,
  ["order of the cloud serpent"] = 1271,
  ["jogu the drunk"] = 1273,
  ["ella"] = 1275,
  ["tina mudclaw"] = 1280,
  ["farmer fung"] = 1283,
  ["the lorewalkers"] = 1345,
  ["lorewalkers"] = 1345,
  ["arakkoa outcasts"] = 1515,
  ["sha'tari defense"] = 1710,
  ["highmountain tribe"] = 1828,
  ["the nightfallen"] = 1859,
  ["nightfallen"] = 1859,
  ["dreamweavers"] = 1883,
  ["rustbolt resistance"] = 2391,
  ["dragonscale expedition"] = 2507,
  ["valdrakken accord"] = 2510,
  ["council of dornogal"] = 2590,
  ["the assembly of the deeps"] = 2594,
  ["assembly of the deeps"] = 2594,
  ["the cartels of undermine"] = 2653,
  ["cartels of undermine"] = 2653,
  ["the k'aresh trust"] = 2658,
  ["k'aresh trust"] = 2658,
  ["darkfuse solutions"] = 2669,
  ["venture company"] = 2671,
  ["bilgewater cartel"] = 2673,
  ["blackwater cartel"] = 2675,
  ["steamwheedle cartel"] = 2677,
  ["gallagio loyalty rewards club"] = 2685,
  ["flame's radiance"] = 2688,
  ["slayer's duellum"] = 2770,
  ["the singularity"] = 2699,
  ["singularity"] = 2699,
  ["hara'ti"] = 2704,
  ["silvermoon court"] = 2710,
  ["magisters"] = 2711,
  ["blood knights"] = 2712,
  ["farstriders"] = 2713,
  ["shades of the row"] = 2714,
  ["prey: season 1"] = 2764,
  ["ritual sites"] = 2792,
}
local standingCodes = {
  hated = 1,
  hostile = 2,
  unfriendly = 3,
  neutral = 4,
  friendly = 5,
  honored = 6,
  revered = 7,
  exalted = 8,
}

local function Refresh()
  if refreshTimer then return end
  local function Apply()
    refreshTimer = nil
    Requirements.revision = Requirements.revision + 1
    if NS.UI and NS.UI.CatalogView then
      NS.UI.CatalogView:InvalidateDisplay()
    end
    if NS.UI and NS.UI.Inspector and NS.UI.Inspector.record then NS.UI.Inspector:Show(NS.UI.Inspector.record) end
  end
  if _G.C_Timer and _G.C_Timer.NewTimer then refreshTimer = _G.C_Timer.NewTimer(0.05, Apply) else Apply() end
end

local function QuestComplete(id)
  id = tonumber(id)
  if not id then return nil end
  if _G.C_QuestLog and _G.C_QuestLog.IsQuestFlaggedCompleted then return _G.C_QuestLog.IsQuestFlaggedCompleted(id) == true end
  if _G.IsQuestFlaggedCompleted then return _G.IsQuestFlaggedCompleted(id) == true end
  return nil
end

local function AchievementComplete(id)
  id = tonumber(id)
  if not id or not _G.GetAchievementInfo then return nil end
  local _, _, _, completed = _G.GetAchievementInfo(id)
  return completed == true
end

local function ReadQuestTitle(id)
  if _G.C_QuestLog and _G.C_QuestLog.GetTitleForQuestID then
    local ok, value = pcall(_G.C_QuestLog.GetTitleForQuestID, id)
    if ok and type(value) == "string" and value ~= "" then return value end
  end
  if _G.C_QuestLog and _G.C_QuestLog.GetQuestInfo then
    local ok, value = pcall(_G.C_QuestLog.GetQuestInfo, id)
    if ok and type(value) == "table" then return value.title or value.name end
    if ok and type(value) == "string" and value ~= "" then return value end
  end
end

local function QuestTitle(id)
  id = tonumber(id)
  if not id then return nil end
  if questNames[id] then return questNames[id] end
  local titles = NS.Data and NS.Data.QuestTitles
  local title = titles and titles[id] or ReadQuestTitle(id)
  if title then
    questNames[id] = title
    return title
  end
  if _G.C_QuestLog and _G.C_QuestLog.RequestLoadQuestByID then
    if pendingQuests[id] then return nil end
    pendingQuests[id] = true
    pcall(_G.C_QuestLog.RequestLoadQuestByID, id)
    if _G.C_Timer and _G.C_Timer.After then
      _G.C_Timer.After(2, function()
        if not pendingQuests[id] then return end
        pendingQuests[id] = nil
        local value = ReadQuestTitle(id)
        if value then
          questNames[id] = value
          Refresh()
        end
      end)
    end
  end
end

NS.SafeRegisterEvent(Requirements, "QUEST_DATA_LOAD_RESULT", function(questID, success)
  questID = tonumber(questID)
  if not questID then return end
  pendingQuests[questID] = nil
  if success == false then return end
  local title = ReadQuestTitle(questID)
  if title then
    questNames[questID] = title
    Refresh()
  end
end)

local function AchievementTitle(id)
  id = tonumber(id)
  if not id then return nil end
  if achievementNames[id] then return achievementNames[id] end
  if _G.GetAchievementInfo then
    local title = select(2, _G.GetAchievementInfo(id))
    if title and title ~= "" then
      achievementNames[id] = title
      return title
    end
  end
end

local function ResolveFactionID(name)
  if type(name) ~= "string" then return nil end
  return factionIDs[name:lower():match("^%s*(.-)%s*$")]
end

local function StandingCode(standing)
  if type(standing) ~= "string" then return nil end
  local lowered = standing:lower():match("^%s*(.-)%s*$")
  if standingCodes[lowered] then return standingCodes[lowered] end
  for index = 1, 8 do
    local token = _G["FACTION_STANDING_LABEL" .. index]
    local label = token and (_G.GetText and _G.GetText(token) or token)
    if type(label) == "string" and label:lower() == lowered then return index end
  end
end

local function ReputationMet(name, standing, factionID)
  factionID = tonumber(factionID) or ResolveFactionID(name)
  if not factionID or type(standing) ~= "string" then return nil end
  local renown = tonumber(standing:lower():match("renown[^%d]*(%d+)"))
  if renown and _G.C_MajorFactions and _G.C_MajorFactions.GetMajorFactionData then
    if _G.C_MajorFactions.HasMaximumRenown then
      local ok, maximum = pcall(_G.C_MajorFactions.HasMaximumRenown, factionID)
      if ok and maximum == true then return true end
    end
    local ok, data = pcall(_G.C_MajorFactions.GetMajorFactionData, factionID)
    if ok and type(data) == "table" and tonumber(data.renownLevel) then return tonumber(data.renownLevel) >= renown end
    return nil
  end
  local required = StandingCode(standing)
  if required and _G.C_Reputation and _G.C_Reputation.GetFactionDataByID then
    local ok, data = pcall(_G.C_Reputation.GetFactionDataByID, factionID)
    if ok and type(data) == "table" and tonumber(data.reaction) then return tonumber(data.reaction) >= required end
  end
end

local function AddReputation(result, reputation)
  if reputation == nil then return end
  local title, standing, met
  if type(reputation) == "table" then
    title = reputation.name or reputation.title or reputation.faction or reputation.rep
    standing = reputation.standing or reputation.level or reputation.rank
    met = reputation.met
  elseif type(reputation) == "string" and reputation:lower() ~= "true" then
    title = reputation
  end
  if met == nil then met = ReputationMet(title, standing, type(reputation) == "table" and reputation.factionID) end
  result[#result + 1] = { kind = "reputation", title = title or "Reputation required", standing = standing, met = met }
end

function Requirements:Get(record)
  local requirements = record and record.requirements
  if type(requirements) ~= "table" then requirements = {} end
  local result = {}
  local quest = requirements.quest or (record and record.sourceType == "quest" and { id = record.sourceID, title = record.sourceName })
  if quest then
    local id = tonumber(type(quest) == "table" and (quest.id or quest.questID) or quest)
    local title = type(quest) == "table" and (quest.title or quest.name) or type(quest) == "string" and quest or nil
    title = title or QuestTitle(id) or (id and ("Quest #" .. id) or "Quest required")
    if id and not title:find(tostring(id), 1, true) then title = title .. " (#" .. tostring(id) .. ")" end
    result[#result + 1] = { kind = "quest", id = id, title = title, met = QuestComplete(id) }
  end
  local achievement = requirements.achievement or (record and record.sourceType == "achievement" and { id = record.sourceID, title = record.sourceName })
  if achievement then
    local id = tonumber(type(achievement) == "table" and (achievement.id or achievement.achievementID) or achievement)
    local title = type(achievement) == "table" and (achievement.title or achievement.name) or type(achievement) == "string" and achievement or nil
    result[#result + 1] = { kind = "achievement", id = id, title = title or AchievementTitle(id) or (id and ("Achievement #" .. id) or "Achievement required"), met = AchievementComplete(id) }
  end
  AddReputation(result, requirements.reputation or requirements.rep)
  return result
end

function Requirements:Display(record, values)
  values = values or self:Get(record)
  local lines = {}
  for index = 1, #values do
    local value = values[index]
    local display = tostring(value.title or value.id or "Required")
    if value.standing then display = display .. " - " .. tostring(value.standing) end
    if value.met == true then
      lines[#lines + 1] = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t |cff40ff40" .. display .. "|r"
    elseif value.kind == "reputation" then
      lines[#lines + 1] = "|TInterface\\Icons\\Achievement_Reputation_01:14:14|t |cffff5b5b" .. display .. "|r"
    else
      lines[#lines + 1] = "|cffffd100" .. (value.kind == "quest" and "! " or "* ") .. "|r|cffffffff" .. display .. "|r"
    end
  end
  return table.concat(lines, "\n")
end

function Requirements:Badge(record, values)
  values = values or self:Get(record)
  if #values == 0 then return nil end
  local value = values[1]
  local display = tostring(value.title or value.id or "Required")
  if value.standing then display = display .. " - " .. tostring(value.standing) end
  return display, value.met == true and "ready" or value.met == false and "locked" or "unknown"
end

function Requirements:Text(record)
  return self:Display(record)
end

function Requirements:IsRenown(record)
  local requirements = record and record.requirements
  local reputation = type(requirements) == "table" and (requirements.reputation or requirements.rep) or nil
  if type(reputation) == "table" then
    local text = table.concat({ tostring(reputation.name or reputation.title or reputation.faction or ""), tostring(reputation.standing or reputation.level or reputation.rank or "") }, " "):lower()
    return text:find("renown", 1, true) ~= nil
  end
  return type(reputation) == "string" and reputation:lower():find("renown", 1, true) ~= nil
end

function Requirements:FirstOpenable(record)
  local values = self:Get(record)
  for index = 1, #values do
    local value = values[index]
    if value.kind == "quest" or value.kind == "achievement" then return value end
  end
end

NS.SafeRegisterEvent(Requirements, "UPDATE_FACTION", Refresh)
NS.SafeRegisterEvent(Requirements, "MAJOR_FACTION_RENOWN_LEVEL_CHANGED", Refresh)
