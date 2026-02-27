local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local PT = {}
NS.Systems.ProfessionTracker = PT

local PROFESSION_SKILL_LINES = {
    [171] = "Alchemy",
    [164] = "Blacksmithing",
    [185] = "Cooking",
    [333] = "Enchanting",
    [202] = "Engineering",
    [129] = "First Aid",
    [773] = "Inscription",
    [755] = "Jewelcrafting",
    [165] = "Leatherworking",
    [197] = "Tailoring",
    [186] = "Mining",
    [182] = "Herbalism",
    [393] = "Skinning",
}

local EXPANSION_NAMES = {
    ["Midnight"] = "Mid",
    ["Quel'Thalas"] = "Mid",
    ["Dragon Isles"] = "DF",
    ["Khaz Algar"] = "TWW",
    ["Shadowlands"] = "SL",
    ["Battle for Azeroth"] = "BfA",
    ["Kul Tiran"] = "BfA",
    ["Zandalari"] = "BfA",
    ["Legion"] = "Legion",
    ["Draenor"] = "WoD",
    ["Pandaria"] = "MoP",
    ["Cataclysm"] = "Cata",
    ["Northrend"] = "WotLK",
    ["Outland"] = "TBC",
    ["Classic"] = "Classic",
}

PT.PROFESSION_ORDER = {
    "Alchemy", "Blacksmithing", "Cooking", "Enchanting", "Engineering",
    "Inscription", "Jewelcrafting", "Leatherworking", "Tailoring",
    "Herbalism", "Mining", "Skinning"
}

PT.EXPANSION_ORDER = {
    "Mid", "TWW", "DF", "SL", "BfA", "Legion", "WoD",
    "MoP", "Cata", "WotLK", "TBC", "Classic"
}

PT.GATHERING_PROFESSIONS = {
    Herbalism = true,
    Mining = true,
    Skinning = true,
}

local function GetCharacterKey()
  return NS.Systems.GetCharacterKey()
end

local function NormalizeExpansionName(apiName)
    return EXPANSION_NAMES[apiName] or apiName
end

local function InitializeDB()
    if not HomeDecorDB then
        HomeDecorDB = {}
    end

    if not HomeDecorDB.global then
        HomeDecorDB.global = {}
    end

    if not HomeDecorDB.global.professionData then
        HomeDecorDB.global.professionData = {
            characters = {},
            viewMode = "summary",
        }
    end

    if not HomeDecorDB.global.professionData.characters then
        HomeDecorDB.global.professionData.characters = {}
    end
end

function PT:GetDB()
    InitializeDB()
    return HomeDecorDB.global.professionData
end

function PT:GetCharacterData(charKey)
    InitializeDB()
    charKey = charKey or GetCharacterKey()

    if not HomeDecorDB.global.professionData.characters[charKey] then
        HomeDecorDB.global.professionData.characters[charKey] = {
            professions = {},
            lastScan = time(),
        }
    end

    return HomeDecorDB.global.professionData.characters[charKey]
end

function PT:GetAllCharacters()
    InitializeDB()
    return HomeDecorDB.global.professionData.characters or {}
end

function PT:GetViewMode()
    InitializeDB()
    return HomeDecorDB.global.professionData.viewMode or "summary"
end

function PT:SetViewMode(mode)
    InitializeDB()
    HomeDecorDB.global.professionData.viewMode = mode
end

function PT:ScanProfessions()
    local charKey = GetCharacterKey()
    if not charKey then return end

    InitializeDB()

    local charData = HomeDecorDB.global.professionData.characters[charKey]
    if not charData then
        charData = { professions = {}, lastScan = time() }
        HomeDecorDB.global.professionData.characters[charKey] = charData
    end

    local existingProfs = charData.professions or {}

    local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    local profIndexes = { prof1, prof2, cooking }

    local openProfSkillLevels = {}
    local openProfSkillLine = nil

    if C_TradeSkillUI and C_TradeSkillUI.GetChildProfessionInfos then
        local childInfos = C_TradeSkillUI.GetChildProfessionInfos()
        if childInfos and #childInfos > 0 then
            for _, childInfo in ipairs(childInfos) do
                if childInfo.expansionName and childInfo.skillLevel and childInfo.maxSkillLevel then
                    local normalizedName = NormalizeExpansionName(childInfo.expansionName)
                    openProfSkillLevels[normalizedName] = {
                        current = childInfo.skillLevel,
                        max = childInfo.maxSkillLevel,
                    }
                end
            end

            local baseInfo = C_TradeSkillUI.GetBaseProfessionInfo()
            if baseInfo and baseInfo.professionID then
                openProfSkillLine = baseInfo.professionID
            end
        end
    end

    local newProfessions = {}
    local hasNewData = false

    for _, profIndex in ipairs(profIndexes) do
        if profIndex then
            local name, icon, skillLevel, maxSkillLevel, numAbilities, spelloffset, skillLine = GetProfessionInfo(profIndex)
            local profName = PROFESSION_SKILL_LINES[skillLine]

            if profName then
                local skillLevels = {}

                if existingProfs[profName] and existingProfs[profName].skillLevels then
                    for expName, skillData in pairs(existingProfs[profName].skillLevels) do
                        skillLevels[expName] = {
                            current = skillData.current,
                            max = skillData.max,
                        }
                    end
                end

                if openProfSkillLine == skillLine and next(openProfSkillLevels) then
                    for expName, skillData in pairs(openProfSkillLevels) do
                        skillLevels[expName] = {
                            current = skillData.current,
                            max = skillData.max,
                        }
                    end
                    hasNewData = true
                end

                newProfessions[profName] = {
                    skillLevels = skillLevels,
                    lastUpdate = hasNewData and time() or (existingProfs[profName] and existingProfs[profName].lastUpdate or time()),
                }
            end
        end
    end

    HomeDecorDB.global.professionData.characters[charKey].professions = newProfessions
    HomeDecorDB.global.professionData.characters[charKey].lastScan = time()

    return true
end

function PT:GetAggregatedData()
    local characters = self:GetAllCharacters()
    local aggregated = {}
    local bestChars = {}

    for charKey, charData in pairs(characters) do
        if charData.professions then
            for profName, profData in pairs(charData.professions) do
                if not aggregated[profName] then
                    aggregated[profName] = {}
                    bestChars[profName] = {}
                end

                if profData.skillLevels then
                    for expName, skillData in pairs(profData.skillLevels) do
                        if not aggregated[profName][expName] or
                           skillData.current > aggregated[profName][expName].current then
                            aggregated[profName][expName] = skillData
                            bestChars[profName][expName] = charKey
                        end
                    end
                end
            end
        end
    end

    return aggregated, bestChars
end

local function MigrateOldData()
    if HomeDecorDB and HomeDecorDB.professionData then
        if not HomeDecorDB.global then
            HomeDecorDB.global = {}
        end

        if not HomeDecorDB.global.professionData then
            HomeDecorDB.global.professionData = HomeDecorDB.professionData
        end
    end

    if HomeDecorDB and HomeDecorDB.profiles then
        InitializeDB()
        for profileName, profileData in pairs(HomeDecorDB.profiles) do
            if profileData.professionData and profileData.professionData.characters then
                for charKey, charData in pairs(profileData.professionData.characters) do
                    if charData.professions and next(charData.professions) then
                        if not HomeDecorDB.global.professionData.characters[charKey] then
                            HomeDecorDB.global.professionData.characters[charKey] = charData
                            else
                            for profName, profData in pairs(charData.professions) do
                                if not HomeDecorDB.global.professionData.characters[charKey].professions[profName] then
                                    HomeDecorDB.global.professionData.characters[charKey].professions[profName] = profData
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function PT:Initialize()
    InitializeDB()

    MigrateOldData()

    C_Timer.After(1, function()
        self:ScanProfessions()
    end)

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
    eventFrame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
    eventFrame:RegisterEvent("NEW_RECIPE_LEARNED")

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_LIST_UPDATE" then
            C_Timer.After(0.3, function()
                PT:ScanProfessions()
            end)
        elseif event == "NEW_RECIPE_LEARNED" then
            C_Timer.After(0.5, function()
                PT:ScanProfessions()
            end)
        end
    end)

end

C_Timer.After(1, function()
    PT:Initialize()
end)

return PT
