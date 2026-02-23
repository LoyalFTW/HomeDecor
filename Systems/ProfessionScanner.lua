local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local PS = {}
NS.Systems.ProfessionScanner = PS

local SKILL_LINE_TO_NAME = {
    [171] = "Alchemy",
    [164] = "Blacksmithing",
    [185] = "Cooking",
    [333] = "Enchanting",
    [202] = "Engineering",
    [773] = "Inscription",
    [755] = "Jewelcrafting",
    [165] = "Leatherworking",
    [197] = "Tailoring",
}

local EXPANSION_NAME_MAP = {
    ["Dragon Isles"]     = "Dragon Isles",
    ["Khaz Algar"]       = "Khaz Algar",
    ["Shadowlands"]      = "Shadowlands",
    ["Kul Tiran"]        = "Kul Tiran",
    ["Zandalari"]        = "Kul Tiran",
    ["Legion"]           = "Legion",
    ["Draenor"]          = "Draenor",
    ["Pandaria"]         = "Pandaria",
    ["Cataclysm"]        = "Cataclysm",
    ["Northrend"]        = "Northrend",
    ["Outland"]          = "Outland",
    ["Classic"]          = "Classic",
}

local function InitDB()
    HomeDecorDB = HomeDecorDB or {}
    HomeDecorDB.global = HomeDecorDB.global or {}
    local g = HomeDecorDB.global
    if not g.professionScanner then
        g.professionScanner = { characters = {} }
    end
    if not g.professionScanner.characters then
        g.professionScanner.characters = {}
    end
end

local function GetCharKey()
    local name  = UnitName("player") or "Unknown"
    local realm = (GetRealmName() or ""):gsub(" ", "")
    return name .. "-" .. realm
end

local function GetOrCreateChar(charKey)
    InitDB()
    local db = HomeDecorDB.global.professionScanner.characters
    if not db[charKey] then
        db[charKey] = {
            class       = select(2, UnitClass("player")) or "WARRIOR",
            lastScan    = 0,
            professions = {},
        }
    end
    if not db[charKey].class then
        db[charKey].class = select(2, UnitClass("player")) or "WARRIOR"
    end
    return db[charKey]
end

local allCharsWithSkillsCache = nil

local altRecipeFlatCache = nil

local function InvalidateCaches()
    allCharsWithSkillsCache = nil
    altRecipeFlatCache      = nil
end

local function BuildAltRecipeFlatCache()
    if altRecipeFlatCache then return end
    altRecipeFlatCache = {}
    InitDB()
    local chars = HomeDecorDB.global.professionScanner.characters
    for charKey, v in pairs(chars) do
        if v.professions then
            for _, profData in pairs(v.professions) do
                if profData.recipes then
                    for recipeID in pairs(profData.recipes) do
                        if not altRecipeFlatCache[recipeID] then
                            altRecipeFlatCache[recipeID] = {}
                        end
                        local charList = altRecipeFlatCache[recipeID]
                        charList[#charList+1] = charKey
                    end
                end
            end
        end
    end
end

local housingRecipeIndex = nil
local function GetHousingRecipeIndex()
    if housingRecipeIndex then return housingRecipeIndex end
    local index = {}
    local data = NS.Data and NS.Data.Professions
    if not data then return index end
    for profName, expansions in pairs(data) do
        if type(expansions) == "table" then
            for expName, list in pairs(expansions) do
                if type(list) == "table" then
                    for _, entry in ipairs(list) do
                        if type(entry) == "table" and entry.source then
                            local sid = entry.source.skillID
                            local iid = entry.source.itemID
                            if sid then
                                index[sid] = {
                                    profession = profName,
                                    expansion  = expName,
                                    itemID     = iid,
                                    title      = entry.title or "",
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    housingRecipeIndex = index
    return index
end

local function ScanOpenProfession(charKey)
    if not C_TradeSkillUI or not C_TradeSkillUI.IsTradeSkillReady() then return end

    local baseInfo = C_TradeSkillUI.GetBaseProfessionInfo()
    if not baseInfo or not baseInfo.professionID then return end

    local profName = SKILL_LINE_TO_NAME[baseInfo.professionID]
    if not profName then return end

    local charData = GetOrCreateChar(charKey)
    charData.professions[profName] = charData.professions[profName] or {
        skillLevels = {},
        recipes     = {},
    }
    local pd = charData.professions[profName]

    if C_TradeSkillUI.GetChildProfessionInfos then
        local children = C_TradeSkillUI.GetChildProfessionInfos()
        if children then
            for _, child in ipairs(children) do
                local canonical = child.expansionName and EXPANSION_NAME_MAP[child.expansionName]
                if canonical and child.skillLevel and child.maxSkillLevel then
                    pd.skillLevels[canonical] = {
                        current = child.skillLevel,
                        max     = child.maxSkillLevel,
                    }
                end
            end
        end
    end

    local housingIndex = GetHousingRecipeIndex()
    local allRecipes   = C_TradeSkillUI.GetAllRecipeIDs()
    if allRecipes then
        local learned = 0
        for _, recipeID in ipairs(allRecipes) do
            if housingIndex[recipeID] then
                local info = C_TradeSkillUI.GetRecipeInfo(recipeID)
                if info and info.learned then
                    pd.recipes[recipeID] = {
                        recipeName = info.name or housingIndex[recipeID].title,
                        itemID     = housingIndex[recipeID].itemID,
                        learned    = true,
                    }
                    learned = learned + 1
                end
            end
        end
    end

    charData.lastScan = time()
    InvalidateCaches()
end

local function ScanOnLogin(charKey)
    local charData = GetOrCreateChar(charKey)
    local prof1, prof2, _, _, cooking = GetProfessions()
    for _, idx in ipairs({ prof1, prof2, cooking }) do
        if idx then
            local _, _, _, _, _, _, skillLine = GetProfessionInfo(idx)
            local profName = SKILL_LINE_TO_NAME[skillLine]
            if profName and not charData.professions[profName] then
                charData.professions[profName] = { skillLevels = {}, recipes = {} }
            end
        end
    end
    charData.lastScan = time()
    InvalidateCaches()
end

function PS:GetAllCharacters()
    InitDB()
    return HomeDecorDB.global.professionScanner.characters
end

function PS:GetCharacterData(charKey)
    InitDB()
    charKey = charKey or GetCharKey()
    return HomeDecorDB.global.professionScanner.characters[charKey]
end

function PS:GetAllCharactersWithSkills()
    if allCharsWithSkillsCache then return allCharsWithSkillsCache end
    InitDB()
    local chars = HomeDecorDB.global.professionScanner.characters
    local view = {}
    for k, v in pairs(chars) do
        local entry = {
            class       = v.class,
            lastScan    = v.lastScan,
            professions = v.professions,
            professionSkills = {},
            recipes = {},
        }
        if v.professions then
            for profName, profData in pairs(v.professions) do
                entry.professionSkills[profName] = profData.skillLevels or {}
                if profData.recipes then
                    for recipeID, recipeData in pairs(profData.recipes) do
                        entry.recipes[recipeID] = {
                            professionName = profName,
                            recipeName     = recipeData.recipeName,
                            itemID         = recipeData.itemID,
                            learned        = recipeData.learned,
                        }
                    end
                end
            end
        end
        view[k] = entry
    end
    allCharsWithSkillsCache = view
    return view
end

function PS:GetCharactersWithRecipe(recipeID)
    if not recipeID then return {} end
    BuildAltRecipeFlatCache()
    local entries = altRecipeFlatCache[recipeID]
    if not entries then return {} end
    local result = {}
    for i = 1, #entries do result[i] = entries[i] end
    return result

end

function PS:IsRecipeKnownByAnyAlt(recipeID, excludeCurrent)
    if not recipeID then return false, nil end
    BuildAltRecipeFlatCache()
    local entries = altRecipeFlatCache[recipeID]
    if not entries then return false, nil end
    local currentKey = (excludeCurrent ~= false) and GetCharKey() or nil
    for i = 1, #entries do
        local charKey = entries[i]
        if charKey ~= currentKey then
            return true, charKey
        end
    end
    return false, nil
end

function PS:GetCurrentCharacterRecipes()
    local charData = self:GetCharacterData(GetCharKey())
    if not charData or not charData.professions then return {} end
    local flat = {}
    for profName, profData in pairs(charData.professions) do
        if profData.recipes then
            for recipeID, recipeData in pairs(profData.recipes) do
                flat[recipeID] = {
                    professionName = profName,
                    recipeName     = recipeData.recipeName,
                    itemID         = recipeData.itemID,
                    learned        = recipeData.learned,
                }
            end
        end
    end
    return flat
end

function PS:GetAltProfessionSummary()
    local summary = {}
    for charKey, charData in pairs(self:GetAllCharacters()) do
        local profs = {}
        if charData.professions then
            for profName in pairs(charData.professions) do
                table.insert(profs, profName)
            end
        end
        if #profs > 0 then
            summary[charKey] = { professions = profs, lastScan = charData.lastScan }
        end
    end
    return summary
end

function PS:TableCount(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

function PS:Initialize()
    InitDB()

    if HomeDecorDB.global.professionData and HomeDecorDB.global.professionData.characters then
        local migrated = 0
        for charKey, charData in pairs(HomeDecorDB.global.professionData.characters) do
            if charData.professions and not HomeDecorDB.global.professionScanner.characters[charKey] then
                local newEntry = { class = charData.class, lastScan = charData.lastScan or 0, professions = {} }
                for profName, profData in pairs(charData.professions) do
                    newEntry.professions[profName] = {
                        skillLevels = profData.skillLevels or {},
                        recipes     = {},
                    }
                end
                HomeDecorDB.global.professionScanner.characters[charKey] = newEntry
                migrated = migrated + 1
            end
        end
    end

    if HomeDecorDB.global.recipeData and HomeDecorDB.global.recipeData.characters then
        for charKey, charData in pairs(HomeDecorDB.global.recipeData.characters) do
            local entry = HomeDecorDB.global.professionScanner.characters[charKey]
                       or GetOrCreateChar(charKey)
            if charData.recipes then
                for recipeID, recipeData in pairs(charData.recipes) do
                    local profName = recipeData.professionName or "Unknown"
                    entry.professions[profName] = entry.professions[profName]
                                               or { skillLevels = {}, recipes = {} }
                    entry.professions[profName].recipes[recipeID] = {
                        recipeName = recipeData.recipeName,
                        itemID     = recipeData.itemID,
                        learned    = true,
                    }
                end
            end
        end
    end

    local charKey = GetCharKey()
    C_Timer.After(1, function()
        ScanOnLogin(charKey)
    end)

    local f = CreateFrame("Frame")
    f:RegisterEvent("TRADE_SKILL_SHOW")
    f:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    f:RegisterEvent("NEW_RECIPE_LEARNED")
    f:SetScript("OnEvent", function(_, event)
        local delay = (event == "NEW_RECIPE_LEARNED") and 0.5 or 0.3
        C_Timer.After(delay, function()
            ScanOpenProfession(GetCharKey())

            if NS.UI and NS.UI.DecorAH and NS.UI.DecorAH._refreshReagentCache then
                local skillIDs = {}
                if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs then
                    local ids = C_TradeSkillUI.GetAllRecipeIDs() or {}
                    for _, id in ipairs(ids) do tinsert(skillIDs, id) end
                end
                if #skillIDs > 0 then
                    NS.UI.DecorAH._refreshReagentCache(skillIDs)
                end
            end
            if NS.UI and NS.UI.DecorAH and NS.UI.DecorAH._invalidate then
                NS.UI.DecorAH._invalidate()
            end
            if NS.AltsProfessionsInvalidate then
                NS.AltsProfessionsInvalidate()
            end
            if NS.UI and NS.UI.AltsProfessions and NS.UI.AltsProfessions.OnScanComplete then
                NS.UI.AltsProfessions:OnScanComplete()
            end
        end)
    end)
end

function PS:WireAliases()
    local compat = {
        GetAllCharacters         = function(self)
            return PS:GetAllCharactersWithSkills()
        end,
        GetCharacterData         = function(self, k)
            return PS:GetAllCharactersWithSkills()[k or GetCharKey()]
        end,
        GetCharactersWithRecipe  = function(self, id)
            return PS:GetCharactersWithRecipe(id)
        end,
        IsRecipeKnownByAnyAlt    = function(self, id, excl)
            return PS:IsRecipeKnownByAnyAlt(id, excl)
        end,
        GetCurrentCharacterRecipes = function(self)
            return PS:GetCurrentCharacterRecipes()
        end,
        GetAltProfessionSummary  = function(self)
            return PS:GetAltProfessionSummary()
        end,
        TableCount               = function(self, t)
            return PS:TableCount(t)
        end,
    }

    NS.Systems.RecipeTracker     = compat
    NS.Systems.ProfessionTracker = compat
end

if not NS.professionScannerInitialized then
  NS.professionScannerInitialized = true
  C_Timer.After(1.5, function()
    PS:Initialize()
    PS:WireAliases()
  end)
end

return PS
