local _, NS = ...

local AltProfessions = {}
NS.Systems.AltProfessions = AltProfessions

local PROFESSION_NAMES = {
  [164] = "Blacksmithing",
  [165] = "Leatherworking",
  [171] = "Alchemy",
  [182] = "Herbalism",
  [185] = "Cooking",
  [186] = "Mining",
  [197] = "Tailoring",
  [202] = "Engineering",
  [333] = "Enchanting",
  [356] = "Fishing",
  [393] = "Skinning",
  [755] = "Jewelcrafting",
  [773] = "Inscription",
}

local PARENT_TIER_LINES = {
  [171] = { 2906, 2871, 2823 },
  [164] = { 2907, 2872, 2822 },
  [333] = { 2909, 2874, 2825 },
  [202] = { 2910, 2875, 2827 },
  [182] = { 2912, 2877, 2832 },
  [773] = { 2913, 2878, 2828 },
  [755] = { 2914, 2879, 2829 },
  [165] = { 2915, 2880, 2830 },
  [186] = { 2916, 2881, 2833 },
  [393] = { 2917, 2882, 2834 },
  [197] = { 2918, 2883, 2831 },
}

local TIER_LEARN_SPELLS = {
  [2906] = 471003, [2871] = 423321, [2823] = 366261,
  [2907] = 471004, [2872] = 423332, [2822] = 365677,
  [2909] = 471006, [2874] = 423334, [2825] = 366255,
  [2910] = 471007, [2875] = 423335, [2827] = 366254,
  [2912] = 471009, [2877] = 441327, [2832] = 366242,
  [2913] = 471010, [2878] = 423338, [2828] = 366251,
  [2914] = 471011, [2879] = 423339, [2829] = 366250,
  [2915] = 471012, [2880] = 423340, [2830] = 366249,
  [2916] = 471013, [2881] = 423341, [2833] = 366264,
  [2917] = 471014, [2882] = 423342, [2834] = 366263,
  [2918] = 471015, [2883] = 423343, [2831] = 366258,
}

local TIER_TO_PARENT = {}
for parentID, lines in pairs(PARENT_TIER_LINES) do
  for _, lineID in ipairs(lines) do TIER_TO_PARENT[lineID] = parentID end
end

local function Accessible(value)
  if value == nil then return nil end
  if issecretvalue and issecretvalue(value) then return nil end
  if canaccessvalue and not canaccessvalue(value) then return nil end
  return value
end

local function State()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.altProfessions = profile.altProfessions or { characters = {} }
  profile.altProfessions.characters = profile.altProfessions.characters or {}
  return profile.altProfessions
end

local function CurrentIdentity()
  local name = Accessible(UnitName and UnitName("player"))
  local realm = Accessible(GetRealmName and GetRealmName())
  if type(name) ~= "string" or name == "" then return nil end
  if type(realm) ~= "string" or realm == "" then realm = "Unknown" end
  return name .. "-" .. realm:gsub("%s+", ""), name, realm
end

local function Now()
  return GetServerTime and GetServerTime() or time()
end

local function PlayerOwnsProfession(parentID)
  if not parentID then return false end
  if not GetProfessions or not GetProfessionInfo then return true end
  local ok, first, second, archaeology, fishing, cooking = pcall(GetProfessions)
  if not ok then return false end
  for _, index in ipairs({ first, second, archaeology, fishing, cooking }) do
    if index then
      local infoOK, _, _, _, _, _, _, skillLineID = pcall(GetProfessionInfo, index)
      if infoOK and tonumber(skillLineID) == tonumber(parentID) then return true end
    end
  end
  return false
end

local function Fingerprint(character)
  local value = 17
  local count = 0
  for professionID, profession in pairs(character.professions or {}) do
    count = count + 1
    value = (value + (tonumber(professionID) or 0) * 31 + (tonumber(profession.current) or 0) * 7 + (tonumber(profession.maximum) or 0) * 11) % 2147483647
    for tierID, tier in pairs(profession.tiers or {}) do
      count = count + 1
      value = (value + (tonumber(tierID) or 0) * 37 + (tonumber(tier.current) or 0) * 13 + (tonumber(tier.maximum) or 0) * 17) % 2147483647
    end
  end
  for recipeID, learned in pairs(character.recipes or {}) do
    if learned then
      count = count + 1
      value = (value + (tonumber(recipeID) or 0) * 41) % 2147483647
    end
  end
  return value .. ":" .. count
end

local function EnsureProfession(character, parentID, name)
  parentID = tonumber(parentID)
  if not parentID then return nil end
  character.professions = character.professions or {}
  local key = tostring(parentID)
  local profession = character.professions[key]
  if type(profession) ~= "table" then
    profession = { id = parentID, name = name or PROFESSION_NAMES[parentID] or ("Profession " .. parentID), tiers = {} }
    character.professions[key] = profession
  end
  profession.id = parentID
  profession.name = name or profession.name or PROFESSION_NAMES[parentID] or ("Profession " .. parentID)
  profession.tiers = profession.tiers or {}
  return profession
end

function AltProfessions:GetCurrentKey()
  return CurrentIdentity()
end

function AltProfessions:GetState()
  return State()
end

function AltProfessions:GetProfessionName(parentID)
  return PROFESSION_NAMES[tonumber(parentID)] or ("Profession " .. tostring(parentID or ""))
end

function AltProfessions:GetProfessionNames()
  local names = {}
  local seen = {}
  for _, character in pairs((State() and State().characters) or {}) do
    for _, profession in pairs(character.professions or {}) do
      if profession.name and not seen[profession.name] then
        seen[profession.name] = true
        names[#names + 1] = profession.name
      end
    end
  end
  table.sort(names)
  return names
end

function AltProfessions:GetOrCreateCurrent()
  local key, name, realm = CurrentIdentity()
  local state = State()
  if not key or not state then return nil end
  local character = state.characters[key]
  if type(character) ~= "table" then
    character = { name = name, realm = realm, professions = {}, recipes = {}, updated = 0 }
    state.characters[key] = character
  end
  character.name = name
  character.realm = realm
  character.professions = character.professions or {}
  character.recipes = character.recipes or {}
  local class
  if UnitClass then
    local _, value = UnitClass("player")
    class = Accessible(value)
  end
  if type(class) == "string" then character.class = class end
  return character, key
end

function AltProfessions:Invalidate()
  self.recipeIndex = nil
  self.crafterNames = nil
  self.revision = (self.revision or 0) + 1
end

function AltProfessions:Notify()
  self:Invalidate()
  NS.SendMessage("HOMEDECOR_ALT_PROFESSIONS_UPDATED")
end

function AltProfessions:CommitCurrent(character)
  local signature = Fingerprint(character)
  if self.currentFingerprint == signature then return false end
  self.currentFingerprint = signature
  character.updated = Now()
  self:Notify()
  return true
end

function AltProfessions:RefreshCurrentProfessions()
  local character = self:GetOrCreateCurrent()
  if not character then return false end
  local foundParents = {}
  local function MarkLine(lineID, info)
    lineID = tonumber(lineID)
    if not lineID then return end
    local parentID = tonumber(info and info.parentProfessionID) or TIER_TO_PARENT[lineID] or (PROFESSION_NAMES[lineID] and lineID)
    if not parentID then return end
    foundParents[parentID] = true
    local profession = EnsureProfession(character, parentID, PROFESSION_NAMES[parentID])
    if lineID ~= parentID then
      local level = tonumber(info and info.skillLevel) or 0
      local maximum = tonumber(info and (info.maxSkillLevel or info.maxSkill)) or 0
      profession.tiers[tostring(lineID)] = {
        id = lineID,
        name = Accessible(info and (info.professionName or info.name)) or tostring(lineID),
        current = level,
        maximum = maximum,
      }
    end
  end
  if C_SpellBook and C_SpellBook.IsSpellKnown then
    for lineID, spellID in pairs(TIER_LEARN_SPELLS) do
      local ok, learned = pcall(C_SpellBook.IsSpellKnown, spellID)
      if ok and learned then MarkLine(lineID) end
    end
  end
  if C_TradeSkillUI and C_TradeSkillUI.GetAllProfessionTradeSkillLines then
    local ok, lines = pcall(C_TradeSkillUI.GetAllProfessionTradeSkillLines)
    if ok and type(lines) == "table" then
      for _, lineID in ipairs(lines) do
        local info
        if C_TradeSkillUI.GetProfessionInfoBySkillLineID then
          local infoOK, value = pcall(C_TradeSkillUI.GetProfessionInfoBySkillLineID, lineID)
          if infoOK then info = value end
        end
        if info and (tonumber(info.skillLevel) or 0) > 0 then MarkLine(lineID, info) end
      end
    end
  end
  if C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID then
    for lineID in pairs(TIER_LEARN_SPELLS) do
      local ok, info = pcall(C_TradeSkillUI.GetProfessionInfoBySkillLineID, lineID)
      if ok and info and (tonumber(info.skillLevel) or 0) > 0 then MarkLine(lineID, info) end
    end
  end
  if GetProfessions and GetProfessionInfo then
    local ok, first, second, archaeology, fishing, cooking = pcall(GetProfessions)
    if ok then
      for _, index in ipairs({ first, second, archaeology, fishing, cooking }) do
        if index then
          local infoOK, name, icon, current, maximum, abilities, offset, parentID = pcall(GetProfessionInfo, index)
          if infoOK and parentID then
            foundParents[parentID] = true
            local profession = EnsureProfession(character, parentID, Accessible(name))
            profession.icon = Accessible(icon)
            profession.current = tonumber(current) or profession.current
            profession.maximum = tonumber(maximum) or profession.maximum
          end
        end
      end
    end
  end
  for parentID in pairs(foundParents) do EnsureProfession(character, parentID) end
  return self:CommitCurrent(character)
end

local function CandidateIndex()
  local index = {}
  local market = NS.Systems.MarketData
  for _, candidate in ipairs(market and market:BuildCandidates() or {}) do
    if candidate.skillID then index[tonumber(candidate.skillID)] = candidate end
  end
  return index
end

local function RecipeLearned(recipeID)
  if not recipeID then return false end
  if C_SpellBook and C_SpellBook.IsSpellKnown then
    local ok, learned = pcall(C_SpellBook.IsSpellKnown, recipeID)
    if ok and learned == true then return true end
  end
  if IsSpellKnown then
    local ok, learned = pcall(IsSpellKnown, recipeID)
    if ok and learned == true then return true end
  end
  if C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo then
    local ok, info = pcall(C_TradeSkillUI.GetRecipeInfo, recipeID)
    if ok and info and info.learned == true then return true end
  end
  if C_TradeSkillUI and C_TradeSkillUI.IsRecipeLearned then
    local ok, learned = pcall(C_TradeSkillUI.IsRecipeLearned, recipeID)
    if ok and learned == true then return true end
  end
  if C_TradeSkillUI and C_TradeSkillUI.IsRecipeKnown then
    local ok, learned = pcall(C_TradeSkillUI.IsRecipeKnown, recipeID)
    if ok and learned == true then return true end
  end
  if C_Professions and C_Professions.IsRecipeKnown then
    local ok, learned = pcall(C_Professions.IsRecipeKnown, recipeID)
    if ok and learned == true then return true end
  end
  return false
end

function AltProfessions:RefreshCurrentRecipes()
  local character = self:GetOrCreateCurrent()
  if not character then return false end
  for recipeID in pairs(CandidateIndex()) do
    if RecipeLearned(recipeID) then character.recipes[tostring(recipeID)] = true end
  end
  return self:CommitCurrent(character)
end

function AltProfessions:ScanOpenProfession()
  if not C_TradeSkillUI or not C_TradeSkillUI.IsTradeSkillReady then return false end
  local readyOK, ready = pcall(C_TradeSkillUI.IsTradeSkillReady)
  if not readyOK or not ready then return false end
  local character = self:GetOrCreateCurrent()
  if not character then return false end
  local baseInfo
  if C_TradeSkillUI.GetBaseProfessionInfo then
    local ok, value = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
    if ok then baseInfo = value end
  end
  local baseLineID = tonumber(baseInfo and (baseInfo.professionID or baseInfo.skillLineID))
  local parentID = tonumber(baseInfo and baseInfo.parentProfessionID) or TIER_TO_PARENT[baseLineID] or (PROFESSION_NAMES[baseLineID] and baseLineID)
  local professionName = PROFESSION_NAMES[parentID] or Accessible(baseInfo and (baseInfo.professionName or baseInfo.name))
  if C_TradeSkillUI.IsNPCCrafting then
    local npcOK, npc = pcall(C_TradeSkillUI.IsNPCCrafting)
    if npcOK and npc then return false end
  end
  if not PlayerOwnsProfession(parentID) then return false end
  if parentID then EnsureProfession(character, parentID, professionName) end
  if C_TradeSkillUI.GetChildProfessionInfos then
    local ok, children = pcall(C_TradeSkillUI.GetChildProfessionInfos)
    if ok and type(children) == "table" then
      for _, child in ipairs(children) do
        local lineID = tonumber(child.professionID or child.skillLineID)
        local detectedParent = parentID or tonumber(child.parentProfessionID) or TIER_TO_PARENT[lineID]
        if detectedParent and lineID then
          local profession = EnsureProfession(character, detectedParent, professionName)
          profession.tiers[tostring(lineID)] = {
            id = lineID,
            name = Accessible(child.expansionName or child.professionName or child.name) or tostring(lineID),
            current = tonumber(child.skillLevel) or 0,
            maximum = tonumber(child.maxSkillLevel) or 0,
          }
        end
      end
    end
  end
  local recipesOK, recipeIDs = pcall(C_TradeSkillUI.GetAllRecipeIDs)
  if not recipesOK or type(recipeIDs) ~= "table" then return false end
  local catalog = CandidateIndex()
  local scanned = {}
  for _, recipeID in ipairs(recipeIDs) do
    recipeID = tonumber(recipeID)
    if catalog[recipeID] then
      local infoOK, info = pcall(C_TradeSkillUI.GetRecipeInfo, recipeID)
      if infoOK and info and info.learned == true then scanned[tostring(recipeID)] = true end
    end
  end
  if parentID and professionName then
    for recipeKey in pairs(character.recipes) do
      local candidate = catalog[tonumber(recipeKey)]
      if candidate and candidate.profession == professionName then character.recipes[recipeKey] = nil end
    end
  end
  for recipeKey in pairs(scanned) do character.recipes[recipeKey] = true end
  self:RefreshCurrentProfessions()
  return true
end

function AltProfessions:ObserveRecipe(recipeID, known)
  recipeID = tonumber(recipeID)
  if not recipeID or known ~= true then return end
  local character, key = self:GetOrCreateCurrent()
  if not character or character.recipes[tostring(recipeID)] then return end
  character.recipes[tostring(recipeID)] = true
  character.updated = Now()
  self.currentFingerprint = Fingerprint(character)
  if self.recipeIndex then
    local list = self.recipeIndex[recipeID]
    if not list then list = {} self.recipeIndex[recipeID] = list end
    list[#list + 1] = key
  end
  if self.crafterNames then self.crafterNames[recipeID] = nil end
  self.revision = (self.revision or 0) + 1
end

function AltProfessions:BuildRecipeIndex()
  if self.recipeIndex then return self.recipeIndex end
  local index = {}
  local state = State()
  for key, character in pairs((state and state.characters) or {}) do
    for recipeID, learned in pairs(character.recipes or {}) do
      if learned then
        local list = index[tonumber(recipeID)]
        if not list then list = {} index[tonumber(recipeID)] = list end
        list[#list + 1] = key
      end
    end
  end
  self.recipeIndex = index
  return index
end

function AltProfessions:GetCrafters(recipeID)
  local state = State()
  local currentKey = CurrentIdentity()
  local crafters = {}
  local hasAlt = false
  for _, key in ipairs(self:BuildRecipeIndex()[tonumber(recipeID)] or {}) do
    local character = state and state.characters[key]
    if character then
      local current = key == currentKey
      crafters[#crafters + 1] = { key = key, name = character.name or key, realm = character.realm, current = current }
      if not current then hasAlt = true end
    end
  end
  table.sort(crafters, function(left, right)
    if left.current ~= right.current then return left.current end
    return (left.name or "") < (right.name or "")
  end)
  return crafters, hasAlt
end

function AltProfessions:GetCrafterNames(recipeID)
  self.crafterNames = self.crafterNames or {}
  recipeID = tonumber(recipeID)
  local cached = self.crafterNames[recipeID]
  if cached then return cached.names, cached.hasAlt, cached.count end
  local state = State()
  local currentKey = CurrentIdentity()
  local currentName
  local names = {}
  local hasAlt = false
  for _, key in ipairs(self:BuildRecipeIndex()[recipeID] or {}) do
    local character = state and state.characters[key]
    if character then
      local name = character.name or key
      if key == currentKey then currentName = name else names[#names + 1] = name hasAlt = true end
    end
  end
  table.sort(names)
  if currentName then table.insert(names, 1, currentName) end
  cached = { names = names, hasAlt = hasAlt, count = #names }
  self.crafterNames[recipeID] = cached
  return cached.names, cached.hasAlt, cached.count
end

function AltProfessions:IsCurrentKnown(recipeID)
  local key = CurrentIdentity()
  local state = State()
  local character = key and state and state.characters[key]
  return character and character.recipes and character.recipes[tostring(recipeID)] == true or false
end

function AltProfessions:GetCharacters()
  local result = {}
  local state = State()
  for key, character in pairs((state and state.characters) or {}) do
    result[#result + 1] = {
      key = key,
      name = character.name,
      realm = character.realm,
      class = character.class,
      updated = character.updated,
      professions = character.professions,
      recipes = character.recipes,
    }
  end
  table.sort(result, function(left, right)
    if (left.name or "") == (right.name or "") then return (left.realm or "") < (right.realm or "") end
    return (left.name or "") < (right.name or "")
  end)
  return result
end

function AltProfessions:ImportLegacy()
  local state = State()
  if not state or state.legacyImported then return end
  local legacy = _G.HomeDecorDB
  local characters = legacy and legacy.global and legacy.global.professionScanner and legacy.global.professionScanner.characters
  for key, old in pairs(type(characters) == "table" and characters or {}) do
    local name, realm = tostring(key):match("^(.-)%-(.+)$")
    local character = state.characters[key] or { name = name or key, realm = realm or "Unknown", professions = {}, recipes = {} }
    character.professions = character.professions or {}
    character.recipes = character.recipes or {}
    character.class = character.class or old.class
    character.updated = math.max(tonumber(character.updated) or 0, tonumber(old.lastScan) or 0)
    for professionName, oldProfession in pairs(old.professions or {}) do
      local parentID
      for id, knownName in pairs(PROFESSION_NAMES) do if knownName == professionName then parentID = id break end end
      if parentID then
        local profession = EnsureProfession(character, parentID, professionName)
        for expansion, levels in pairs(oldProfession.skillLevels or {}) do
          profession.tiers[expansion] = { name = expansion, current = tonumber(levels.current) or 0, maximum = tonumber(levels.max) or 0 }
        end
      end
      for recipeID, recipe in pairs(oldProfession.recipes or {}) do
        if recipe == true or type(recipe) == "table" and recipe.learned ~= false then character.recipes[tostring(recipeID)] = true end
      end
    end
    state.characters[key] = character
  end
  local profile = NS.Systems.Database:GetProfile()
  for key, old in pairs(profile and profile.decorPricing and profile.decorPricing.recipeKnowledge or {}) do
    if type(old) == "table" then
      local name, realm = tostring(key):match("^(.-)%-(.+)$")
      local character = state.characters[key] or { name = old.name or name or key, realm = realm or "Unknown", professions = {}, recipes = {} }
      character.professions = character.professions or {}
      character.recipes = character.recipes or {}
      for recipeID, learned in pairs(old.recipes or {}) do if learned then character.recipes[tostring(recipeID)] = true end end
      character.updated = math.max(tonumber(character.updated) or 0, tonumber(old.updated) or 0)
      state.characters[key] = character
    end
  end
  state.legacyImported = true
  self:Invalidate()
end

function AltProfessions:Initialize()
  if self.initialized then return end
  self.initialized = true
  self:ImportLegacy()
  self:RefreshCurrentProfessions()
  self:RefreshCurrentRecipes()
end

local QueueScan = NS.Debounce(0.3, function()
  AltProfessions:ScanOpenProfession()
  AltProfessions:RefreshCurrentRecipes()
end)

local QueueRefresh = NS.Debounce(0.5, function()
  AltProfessions:RefreshCurrentProfessions()
  AltProfessions:RefreshCurrentRecipes()
end)

NS.SafeRegisterEvent(AltProfessions, "PLAYER_LOGIN", function()
  C_Timer.After(0.5, function() AltProfessions:Initialize() end)
end)
NS.SafeRegisterEvent(AltProfessions, "TRADE_SKILL_SHOW", QueueScan)
NS.SafeRegisterEvent(AltProfessions, "TRADE_SKILL_LIST_UPDATE", QueueScan)
NS.SafeRegisterEvent(AltProfessions, "NEW_RECIPE_LEARNED", QueueScan)
NS.SafeRegisterEvent(AltProfessions, "SKILL_LINES_CHANGED", QueueRefresh)
NS.SafeRegisterEvent(AltProfessions, "SKILL_LINE_SPECS_RANKS_CHANGED", QueueRefresh)
NS.SafeRegisterEvent(AltProfessions, "LEARNED_SPELL_IN_SKILL_LINE", QueueRefresh)

NS.OnMessage("HOMEDECOR_CATALOG_UPDATED", QueueRefresh)

return AltProfessions
