local _, NS = ...

local SearchIndex = {}
NS.Systems.SearchIndex = SearchIndex

local entries = {}
local entryOrder = {}
local entryHead = 1
local entrySize = 0
local entryToken = 0
local ENTRY_CAPACITY = 512
local compiled = {}
local compiledOrder = {}

local aliases = {
  achievement = "achievement achievements achieve earned reward",
  achievements = "achievement achievements achieve earned reward",
  quest = "quest quests mission reward",
  quests = "quest quests mission reward",
  reputation = "reputation rep renown faction standing",
  rep = "reputation rep renown faction standing",
  vendor = "vendor vendors merchant purchase buy",
  profession = "profession professions crafted crafting recipe",
  drop = "drop drops dropped loot boss mob",
  treasure = "treasure treasures chest",
  shop = "shop store purchase",
  event = "event events holiday",
  pvp = "pvp player versus player honor conquest",
}

local function Normalize(value)
  if type(value) ~= "string" then value = tostring(value or "") end
  return value:lower():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("[^%w]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function Add(parts, value)
  local kind = type(value)
  if kind == "string" or kind == "number" then
    local normalized = Normalize(value)
    if normalized ~= "" then parts[#parts + 1] = normalized end
  elseif kind == "table" then
    for index = 1, #value do Add(parts, value[index]) end
  end
end

local function AddRequirement(parts, name, value)
  if value == nil then return end
  Add(parts, aliases[name] or name)
  if type(value) == "table" then
    Add(parts, value.id)
    Add(parts, value.questID)
    Add(parts, value.achievementID)
    Add(parts, value.title)
    Add(parts, value.name)
    Add(parts, value.faction)
    Add(parts, value.standing)
    Add(parts, value.level)
    Add(parts, value.rank)
  else
    Add(parts, value)
  end
end

local function Build(record)
  local parts = {}
  local classRestriction = NS.Systems.Housing and NS.Systems.Housing:GetClassRestriction(record)
  Add(parts, record.searchText)
  Add(parts, record.title)
  Add(parts, record.name)
  Add(parts, record.sourceName)
  Add(parts, record.vendorName)
  Add(parts, aliases[Normalize(record.sourceType)])
  Add(parts, aliases[Normalize(record.category)])
  Add(parts, record.size)
  Add(parts, classRestriction)
  if classRestriction then Add(parts, "class " .. tostring(classRestriction)) end
  Add(parts, record.note)
  if record.dyeable == true then Add(parts, "dyeable dyable dye dyed dyes color customizable") end
  if record.itemID then Add(parts, "item itemid " .. tostring(record.itemID)) end
  if record.decorID then Add(parts, "decor decorid " .. tostring(record.decorID)) end
  if record.sourceID then Add(parts, "source sourceid " .. tostring(record.sourceID)) end
  if record.skillID then Add(parts, "skill skillid profession " .. tostring(record.skillID)) end
  local requirements = record.requirements
  if type(requirements) == "table" then
    AddRequirement(parts, "quest", requirements.quest)
    AddRequirement(parts, "achievement", requirements.achievement)
    AddRequirement(parts, "reputation", requirements.reputation or requirements.rep)
  end
  local text = " " .. table.concat(parts, " ") .. " "
  if text:find(" gray ", 1, true) then text = text .. " grey " end
  if text:find(" grey ", 1, true) then text = text .. " gray " end
  return { text = text, title = record.title, dyeable = record.dyeable, classRestriction = classRestriction }
end

local function Entry(record)
  local entry = entries[record]
  local classRestriction = NS.Systems.Housing and NS.Systems.Housing:GetClassRestriction(record)
  if not entry or entry.title ~= record.title or entry.dyeable ~= record.dyeable or entry.classRestriction ~= classRestriction then
    entry = Build(record)
    entryToken = entryToken + 1
    entry.cacheToken = entryToken
    local slot
    if entrySize >= ENTRY_CAPACITY then
      slot = entryOrder[entryHead]
      local expired = slot and entries[slot.record]
      if expired and expired.cacheToken == slot.token then entries[slot.record] = nil end
      entryHead = entryHead + 1
      if entryHead > ENTRY_CAPACITY then entryHead = 1 end
    else
      entrySize = entrySize + 1
      slot = entryOrder[entrySize] or {}
      entryOrder[entrySize] = slot
    end
    slot.record = record
    slot.token = entry.cacheToken
    entries[record] = entry
  end
  return entry
end

function SearchIndex:Compile(query)
  local normalized = Normalize(query)
  if normalized == "" then return nil end
  local cached = compiled[normalized]
  if cached then return cached end
  local tokens = {}
  for token in normalized:gmatch("%S+") do tokens[#tokens + 1] = token end
  compiled[normalized] = tokens
  compiledOrder[#compiledOrder + 1] = normalized
  if #compiledOrder > 64 then compiled[table.remove(compiledOrder, 1)] = nil end
  return tokens
end

function SearchIndex:Matches(record, query)
  if not record then return false end
  local tokens = type(query) == "table" and query or self:Compile(query)
  if not tokens then return true end
  local text = Entry(record).text
  for index = 1, #tokens do
    if not text:find(tokens[index], 1, true) then return false end
  end
  return true
end

function SearchIndex:Invalidate(record)
  if record then
    entries[record] = nil
  else
    wipe(entries)
    wipe(entryOrder)
    entryHead = 1
    entrySize = 0
  end
end

return SearchIndex
