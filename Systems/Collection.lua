local ADDON, NS = ...

local Collection = {}
NS.Systems.Collection = Collection

Collection.State = {
    COLLECTED = "COLLECTED",
    NOT_COLLECTED = "NOT_COLLECTED",
}

local decorCache = {}

local function getType(it)
    if it.source and it.source.type then
        return it.source.type
    end
    return it.type
end

local function isDecorCollected(it)
    if not it or not it.decorID then
        return false
    end

    if decorCache[it.decorID] ~= nil then
        return decorCache[it.decorID]
    end

    if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID then
        local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(
            1,              -- category
            it.decorID,     -- decorID (INLINE)
            true            -- account-wide
        )

        if info and info.firstAcquisitionBonus ~= nil then
            local collected = info.firstAcquisitionBonus == 0
            decorCache[it.decorID] = collected
            return collected
        end
    end

    decorCache[it.decorID] = false
    return false
end

local function isAchievementCollected(id)
    local _, _, _, completed = GetAchievementInfo(id)
    return completed == true
end

local function isQuestCollected(id)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompletedOnAccount then
        return C_QuestLog.IsQuestFlaggedCompletedOnAccount(id)
    end
    if IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(id)
    end
    return false
end

function Collection:IsCollected(it)
    if not it then return false end

    local t = getType(it)

    if t == "vendor" and it.items then
        for _, child in ipairs(it.items) do
            if not self:IsCollected(child) then
                return false
            end
        end
        return true
    end

    if t == "achievement" then
        return isAchievementCollected(it.source and it.source.id)
    end

    if t == "quest" then
        return isQuestCollected(it.source and it.source.id)
    end

    if t == "vendor" or t == "drop" or t == "profession" or t == "pvp" then
        return isDecorCollected(it)
    end

    return false
end

function Collection:GetState(it)
    if self:IsCollected(it) then
        return self.State.COLLECTED
    end
    return self.State.NOT_COLLECTED
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")

f:SetScript("OnEvent", function()
    wipe(decorCache)
end)

return Collection
