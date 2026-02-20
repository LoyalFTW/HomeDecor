local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local RT = {}
NS.Systems.RecipeTracker = RT

local PROFESSION_SKILL_LINES = {
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

local PROFESSION_NAME_TO_ID = {}
for id, name in pairs(PROFESSION_SKILL_LINES) do
    PROFESSION_NAME_TO_ID[name] = id
end

local _housingRecipeIDsCache = nil
local function GetAllHousingRecipeIDs()
    if _housingRecipeIDsCache then return _housingRecipeIDsCache end
    local recipeIDs = {}
    local Data = NS.Data
    if not Data or not Data.Professions then
        return recipeIDs
    end

    for profName, expansions in pairs(Data.Professions) do
        if type(expansions) == "table" then
            for expName, list in pairs(expansions) do
                if type(list) == "table" then
                    for _, entry in ipairs(list) do
                        if type(entry) == "table" and entry.source and entry.source.skillID then
                            recipeIDs[entry.source.skillID] = {
                                profession = profName,
                                expansion = expName,
                                itemID = entry.source.itemID,
                                title = entry.title
                            }
                        end
                    end
                end
            end
        end
    end

    _housingRecipeIDsCache = recipeIDs
    return recipeIDs
end

RT.GetAllHousingRecipeIDs = GetAllHousingRecipeIDs

local function GetCharacterKey()
  return NS.Systems.GetCharacterKey()
end

local function InitializeDB()
    if not HomeDecorDB then
        HomeDecorDB = {}
    end

    if not HomeDecorDB.global then
        HomeDecorDB.global = {}
    end

    if not HomeDecorDB.global.recipeData then
        HomeDecorDB.global.recipeData = {
            characters = {},
            lastUpdate = time(),
        }
    end

    if not HomeDecorDB.global.recipeData.characters then
        HomeDecorDB.global.recipeData.characters = {}
    end
end

function RT:GetDB()
    InitializeDB()
    return HomeDecorDB.global.recipeData
end

function RT:GetCharacterData(charKey)
    InitializeDB()
    charKey = charKey or GetCharacterKey()

    if not HomeDecorDB.global.recipeData.characters[charKey] then
        HomeDecorDB.global.recipeData.characters[charKey] = {
            recipes = {},
            professions = {},
            lastScan = time(),
        }
    end

    return HomeDecorDB.global.recipeData.characters[charKey]
end

function RT:GetAllCharacters()
    InitializeDB()
    return HomeDecorDB.global.recipeData.characters or {}
end

function RT:ScanCurrentProfession()
    if not C_TradeSkillUI or not C_TradeSkillUI.IsTradeSkillReady() then
        return false
    end

    local charKey = GetCharacterKey()
    local charData = self:GetCharacterData(charKey)

    local baseInfo = C_TradeSkillUI.GetBaseProfessionInfo()
    if not baseInfo or not baseInfo.professionID then
        return false
    end

    local professionID = baseInfo.professionID
    local professionName = PROFESSION_SKILL_LINES[professionID]

    if not professionName then
        return false
    end

    charData.professions[professionID] = professionName

    local housingRecipes = GetAllHousingRecipeIDs()

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    if not recipeIDs then
        return false
    end

    local scannedCount = 0
    local learnedCount = 0

    for _, recipeID in ipairs(recipeIDs) do
        if recipeID and housingRecipes[recipeID] then
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID)

            if recipeInfo then
                local isLearned = recipeInfo.learned or false

                if isLearned then
                    charData.recipes[recipeID] = {
                        professionID = professionID,
                        professionName = professionName,
                        learned = true,
                        timestamp = time(),
                        recipeName = recipeInfo.name or housingRecipes[recipeID].title,
                        itemID = housingRecipes[recipeID].itemID,
                    }
                    learnedCount = learnedCount + 1
                end
                scannedCount = scannedCount + 1
            end
        end
    end

    charData.lastScan = time()

    return true
end

function RT:ScanAllProfessions()
end

function RT:IsRecipeKnownByAnyAlt(recipeID, excludeCurrent)
    if not recipeID then return false end

    local allChars = self:GetAllCharacters()
    local currentChar = nil

    if excludeCurrent ~= false then
        currentChar = GetCharacterKey()
    end

    for charKey, charData in pairs(allChars) do
        if charKey ~= currentChar then
            if charData.recipes and charData.recipes[recipeID] then
                return true, charKey
            end
        end
    end

    return false, nil
end

function RT:GetCharactersWithRecipe(recipeID)
    if not recipeID then return {} end

    local chars = {}
    local allChars = self:GetAllCharacters()

    for charKey, charData in pairs(allChars) do
        if charData.recipes and charData.recipes[recipeID] then
            table.insert(chars, charKey)
        end
    end

    return chars
end

function RT:GetCurrentCharacterRecipes()
    local charKey = GetCharacterKey()
    local charData = self:GetCharacterData(charKey)
    return charData.recipes or {}
end

function RT:GetAllLearnedRecipes()
    local allRecipes = {}
    local allChars = self:GetAllCharacters()

    for charKey, charData in pairs(allChars) do
        if charData.recipes then
            for recipeID, recipeData in pairs(charData.recipes) do
                if not allRecipes[recipeID] then
                    allRecipes[recipeID] = {
                        characters = {},
                        professionID = recipeData.professionID,
                        professionName = recipeData.professionName,
                        recipeName = recipeData.recipeName,
                    }
                end
                table.insert(allRecipes[recipeID].characters, charKey)
            end
        end
    end

    return allRecipes
end

function RT:GetAltProfessionSummary()
    local summary = {}
    local allChars = self:GetAllCharacters()

    for charKey, charData in pairs(allChars) do
        local profs = {}
        if charData.professions then
            for profID, profName in pairs(charData.professions) do
                table.insert(profs, profName)
            end
        end

        if #profs > 0 then
            summary[charKey] = {
                professions = profs,
                recipeCount = charData.recipes and self:TableCount(charData.recipes) or 0,
                lastScan = charData.lastScan,
            }
        end
    end

    return summary
end

function RT:TableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function RT:CanAnyAltCraft(itemID)
    if not itemID then return false end

    local recipeID = self:GetRecipeForItem(itemID)
    if not recipeID then return false end

    return self:IsRecipeKnownByAnyAlt(recipeID)
end

function RT:GetRecipeForItem(itemID)
    if not itemID then return nil end

    if not RT._itemToRecipeCache then
        RT._itemToRecipeCache = {}
    end

    if RT._itemToRecipeCache[itemID] then
        return RT._itemToRecipeCache[itemID]
    end

    local allRecipes = self:GetAllLearnedRecipes()
    for recipeID, recipeData in pairs(allRecipes) do
        local link = C_TradeSkillUI.GetRecipeItemLink(recipeID)
        if link then
            local id = link:match("item:(%d+)")
            if id and tonumber(id) == itemID then
                RT._itemToRecipeCache[itemID] = recipeID
                return recipeID
            end
        end
    end

    return nil
end

function RT:GetStatistics()
    local allChars = self:GetAllCharacters()
    local stats = {
        totalCharacters = 0,
        totalRecipes = 0,
        uniqueRecipes = 0,
        professionCoverage = {},
    }

    local uniqueRecipes = {}

    for charKey, charData in pairs(allChars) do
        if charData.recipes and next(charData.recipes) then
            stats.totalCharacters = stats.totalCharacters + 1

            for recipeID, recipeData in pairs(charData.recipes) do
                stats.totalRecipes = stats.totalRecipes + 1
                uniqueRecipes[recipeID] = true

                local profName = recipeData.professionName
                if profName then
                    stats.professionCoverage[profName] = (stats.professionCoverage[profName] or 0) + 1
                end
            end
        end
    end

    for _ in pairs(uniqueRecipes) do
        stats.uniqueRecipes = stats.uniqueRecipes + 1
    end

    return stats
end

function RT:PrintStatistics()
    local stats = self:GetStatistics()

    for profName, count in pairs(stats.professionCoverage) do
    end
end

local eventFrame = nil

function RT:RegisterEvents()
    if eventFrame then return end

    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
    eventFrame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    eventFrame:RegisterEvent("NEW_RECIPE_LEARNED")

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" then
            C_Timer.After(0.5, function()
                RT:ScanCurrentProfession()
            end)
        elseif event == "TRADE_SKILL_LIST_UPDATE" then
            C_Timer.After(0.3, function()
                RT:ScanCurrentProfession()
            end)
        elseif event == "NEW_RECIPE_LEARNED" then
            C_Timer.After(0.5, function()
                RT:ScanCurrentProfession()
            end)
        end
    end)
end

function RT:Initialize()
    InitializeDB()
    self:RegisterEvents()

    C_Timer.After(1, function()
        if C_TradeSkillUI and C_TradeSkillUI.IsTradeSkillReady() then
            self:ScanCurrentProfession()
        end
    end)

end

C_Timer.After(1.5, function()
    RT:Initialize()
end)

SLASH_HDDIAG1 = "/hddiag"
SlashCmdList["HDDIAG"] = function(msg)

    if not HomeDecorDB or not HomeDecorDB.global or not HomeDecorDB.global.recipeData then
    else
        local recipeData = HomeDecorDB.global.recipeData
        local charCount = 0
        local totalRecipes = 0

        if recipeData.characters then
            for charKey, charData in pairs(recipeData.characters) do
                if charData.recipes and next(charData.recipes) then
                    charCount = charCount + 1
                    for _ in pairs(charData.recipes) do
                        totalRecipes = totalRecipes + 1
                    end
                end
            end
        end

        if charCount == 0 then
        else
        end
    end

    local charKey = GetCharacterKey()

    if HomeDecorDB and HomeDecorDB.global and HomeDecorDB.global.recipeData
       and HomeDecorDB.global.recipeData.characters
       and HomeDecorDB.global.recipeData.characters[charKey] then
        local charData = HomeDecorDB.global.recipeData.characters[charKey]
        local recipeCount = RT:TableCount(charData.recipes or {})

        if recipeCount > 0 then
        else
        end
    else
    end

end

SLASH_HDRECIPES1 = "/hdrecipes"
SlashCmdList["HDRECIPES"] = function(msg)
    msg = msg:lower():trim()

    if msg == "stats" or msg == "" then
        RT:PrintStatistics()
    elseif msg == "alts" then
        local summary = RT:GetAltProfessionSummary()
        for charKey, data in pairs(summary) do
        end
    elseif msg == "current" then
        local recipes = RT:GetCurrentCharacterRecipes()
        local count = 0
        for recipeID, data in pairs(recipes) do
            count = count + 1
            if count <= 10 then
            end
        end
    elseif msg:match("^check%s+(%d+)") then
        local recipeID = tonumber(msg:match("^check%s+(%d+)"))
        if recipeID then
            local isKnown, charKey = RT:IsRecipeKnownByAnyAlt(recipeID)
            if isKnown then
            else
            end
        end
    else
    end
end

return RT
