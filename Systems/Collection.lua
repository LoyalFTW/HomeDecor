local ADDON, NS = ...

local Collection = {}
NS.Systems = NS.Systems or {}
NS.Systems.Collection = Collection

Collection.State = {
    COLLECTED = "COLLECTED",
    NOT_COLLECTED = "NOT_COLLECTED",
}

local decorCache = {}
local listeners = {}

local function NotifyChanged(decorID)
    for i = 1, #listeners do
        local fn = listeners[i]
        if fn then
            pcall(fn, decorID)
        end
    end
end

function Collection:RegisterListener(fn)
    if type(fn) ~= "function" then return end
    listeners[#listeners + 1] = fn
end

function Collection:ClearCache(decorID)
    if decorID then
        decorCache[decorID] = nil
        NotifyChanged(decorID)
    else
        wipe(decorCache)
        NotifyChanged(-1)
    end
end

local cachedEntryType
local entryTypesTried = {}

local function TryRecord(entryType, decorID)
    if not C_HousingCatalog or not C_HousingCatalog.GetCatalogEntryInfoByRecordID then return nil end
    local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByRecordID, entryType, decorID, true)
    if ok and type(info) == "table" then return info end
    ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByRecordID, entryType, decorID, false)
    if ok and type(info) == "table" then return info end
    return nil
end

local function DiscoverEntryType(sampleDecorID)
    if cachedEntryType then return cachedEntryType end
    if not sampleDecorID then return nil end

    if Enum and Enum.HousingCatalogEntryType then
        for _, v in pairs(Enum.HousingCatalogEntryType) do
            if type(v) == "number" and not entryTypesTried[v] then
                entryTypesTried[v] = true
                if TryRecord(v, sampleDecorID) then
                    cachedEntryType = v
                    return v
                end
            end
        end
    end

    for v = 0, 30 do
        if not entryTypesTried[v] then
            entryTypesTried[v] = true
            if TryRecord(v, sampleDecorID) then
                cachedEntryType = v
                return v
            end
        end
    end

    return nil
end

local function IsOwnedViaCatalog(decorID)
    if not decorID then return nil end
    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then return nil end

    local et = DiscoverEntryType(decorID) or 1
    local info = TryRecord(et, decorID) or TryRecord(1, decorID)
    if not info then return nil end

    if type(info.isOwned)     == "boolean" then return info.isOwned end
    if type(info.isCollected) == "boolean" then return info.isCollected end

    local qty    = type(info.quantity)            == "number" and info.quantity            or 0
    local redeem = type(info.remainingRedeemable) == "number" and info.remainingRedeemable or 0
    local placed = type(info.numPlaced)           == "number" and info.numPlaced           or 0
    if (qty + redeem + placed) > 0 then return true end

    return nil
end

function Collection:IsDecorCollected(decorID)
    if not decorID then return false end

    local cached = decorCache[decorID]
    if cached ~= nil then
        return cached
    end

    local owned = IsOwnedViaCatalog(decorID)
    if owned ~= nil then
        decorCache[decorID] = owned and true or false
        return decorCache[decorID]
    end

    decorCache[decorID] = false
    return false
end

function Collection:IsCollected(it)
    if not it then return false end

    local decorID = it.decorID
    if decorID then
        return self:IsDecorCollected(decorID)
    end

    local src = it.source or {}
    local sourceType = src.type

    if sourceType == "achievement" and src.id then

        local ok = select(4, GetAchievementInfo(src.id))
        return ok and true or false
    end

    if sourceType == "quest" and src.id then
        return C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted and C_QuestLog.IsQuestFlaggedCompleted(src.id) or false
    end

    return false
end

function Collection:GetState(it)
    return self:IsCollected(it) and Collection.State.COLLECTED or Collection.State.NOT_COLLECTED
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("HOUSE_DECOR_ADDED_TO_CHEST")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(_, event, decorID)
    if event == "HOUSE_DECOR_ADDED_TO_CHEST" then
        if decorID then
            decorCache[decorID] = nil
            NotifyChanged(decorID)
        else
            wipe(decorCache)
            NotifyChanged(-1)
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then

        wipe(decorCache)
        NotifyChanged(-1)
        return
    end
end)

return Collection
