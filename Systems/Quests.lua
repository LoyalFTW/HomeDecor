local ADDON, NS = ...

NS.Systems = NS.Systems or {}
NS.Systems.Quests = NS.Systems.Quests or {}
local Q = NS.Systems.Quests

local tonumber, tostring, type, pcall = tonumber, tostring, type, pcall
local C_QuestLog = C_QuestLog

local function recordQuestAlt(questID, isComplete)
  local QuestsAlts = NS.Systems and NS.Systems.QuestsAlts
  if not QuestsAlts or not QuestsAlts.Record then return end
  if not questID or isComplete ~= true then return end
  pcall(QuestsAlts.Record, QuestsAlts, questID, true)
end

local function CheckQuest(questID)
  if not (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted) then return false end
  local ok, result = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
  local isComplete = ok and result or false
  if isComplete then recordQuestAlt(questID, true) end
  return isComplete
end

local function GetQuestName(questID)
  if not (C_QuestLog and C_QuestLog.GetQuestInfo) then return nil end
  local ok, info = pcall(C_QuestLog.GetQuestInfo, questID)
  if ok and info then return info.title or info.name end
  return nil
end

function Q.GetRequirement(it)
  if not it then return nil end

  local req = it.requirements
  if not req then
    local DI = NS.Systems and NS.Systems.DecorIndex
    if DI and it.decorID then
      local e = DI[it.decorID]
      local item = e and e.item
      req = item and item.requirements or nil
    end
  end
  if not req then return nil end

  local quest = req.quest
  if not quest then return nil end

  if type(quest) == "table" then
    local questID = tonumber(quest.id)
    if not questID then
      return { text = "Quest required", questID = nil, met = false }
    end
    local isComplete = CheckQuest(questID)
    local questName = quest.name or quest.title or GetQuestName(questID) or ("Quest #" .. tostring(questID))
    return { text = questName, questID = questID, met = isComplete }
  end

  if type(quest) == "number" then
    local questID = tonumber(quest)
    if not questID then
      return { text = "Quest required", questID = nil, met = false }
    end
    local isComplete = CheckQuest(questID)
    return { text = "Quest #" .. tostring(questID), questID = questID, met = isComplete }
  end

  if type(quest) == "string" then
    return { text = quest, questID = nil, met = false }
  end

  return { text = "Quest required", questID = nil, met = false }
end

function Q.IsQuestComplete(questID)
  questID = tonumber(questID)
  if not questID then return false end
  if not (C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted) then return false end
  local ok, result = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
  return ok and result or false
end

function Q.GetQuestInfo(questID)
  questID = tonumber(questID)
  if not questID then return nil end
  if not (C_QuestLog and C_QuestLog.GetQuestInfo) then return nil end
  local ok, info = pcall(C_QuestLog.GetQuestInfo, questID)
  return ok and info or nil
end

return Q