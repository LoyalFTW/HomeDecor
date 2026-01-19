local ADDON, NS = ...

local Collection = {}
NS.Systems.Collection = Collection

Collection.State = {
    COLLECTED = "COLLECTED",
    NOT_COLLECTED = "NOT_COLLECTED",
}

local decorCache = {}

local listeners = {}
local notifyQueued = false
local pendingDecorIDs = {}

local function NotifyChanged(payload)
    if payload and payload.decorID then
        pendingDecorIDs[payload.decorID] = true
    end

    if notifyQueued then return end
    notifyQueued = true
    C_Timer.After(0, function()
        notifyQueued = false

        local deco
        for id in pairs(pendingDecorIDs) do
            deco = id
            break
        end
        wipe(pendingDecorIDs)

        local p = deco and { decorID = deco } or nil
        for i = 1, #listeners do
            local fn = listeners[i]
            if type(fn) == "function" then
                pcall(fn, p)
            end
        end
    end)
end

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

function Collection:OnChange(fn)
    if type(fn) ~= "function" then return end
    listeners[#listeners + 1] = fn
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")
f:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED")
f:RegisterEvent("CRITERIA_UPDATE")
f:RegisterEvent("ACHIEVEMENT_EARNED")

local function InvalidateAndNotify(payload, multiPass)
    if payload and payload.decorID then
        -- Make the UI responsive immediately.
        decorCache[payload.decorID] = true
        NotifyChanged(payload)
    else
        wipe(decorCache)
        NotifyChanged()
    end

    if not multiPass then return end

    -- Catalog updates can lag behind the toast/event; do a couple light follow-ups.
    C_Timer.After(0.25, function()
        if payload and payload.decorID then
            decorCache[payload.decorID] = nil
            NotifyChanged(payload)
        else
            wipe(decorCache)
            NotifyChanged()
        end
    end)
    C_Timer.After(1.0, function()
        if payload and payload.decorID then
            decorCache[payload.decorID] = nil
            NotifyChanged(payload)
        else
            wipe(decorCache)
            NotifyChanged()
        end
    end)
end

f:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        InvalidateAndNotify(nil, false)
        return
    end

    if event == "HOUSE_DECOR_ADDED_TO_CHEST" then
        local _, decorID = ...
        if type(decorID) == "number" then
            InvalidateAndNotify({ decorID = decorID }, true)
        else
            InvalidateAndNotify(nil, true)
        end
        return
    end

    if event == "NEW_HOUSING_ITEM_ACQUIRED" then
        -- This event doesn't reliably include decorID on all clients; treat as a soft trigger.
        InvalidateAndNotify(nil, true)
        return
    end

    if event == "CRITERIA_UPDATE" or event == "ACHIEVEMENT_EARNED" then
        InvalidateAndNotify(nil, false)
        return
    end
end)

return Collection
