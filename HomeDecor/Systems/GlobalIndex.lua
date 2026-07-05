local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local GI = {}
NS.Systems.GlobalIndex = GI

GI.byItemID   = {}
GI.counts     = {}
GI.collected  = {}
GI._built     = false

local Collection = NS.Systems and NS.Systems.Collection
local Availability = NS.Systems and NS.Systems.CatalogAvailability
local PVP_VENDOR_IDS = {
    [254603] = true,
    [254606] = true,
}

local function NormalizeFaction(value)
    if type(value) ~= "string" then return "" end
    local v = value:gsub("^%s+", ""):gsub("%s+$", ""):lower()
    if v == "alliance" then return "Alliance" end
    if v == "horde" then return "Horde" end
    return value
end

local function GetVariantKey(it)
    if type(it) ~= "table" then return nil end
    local src = it.source or {}
    local id = it.decorID or src.id or src.itemID or src.itemId or it.itemID
    if not id then return nil end
    local faction = NormalizeFaction(it.faction or src.faction or "")
    local questID = it.requirements and it.requirements.quest and (it.requirements.quest.id or it.requirements.quest)
    local achievementID = it.requirements and it.requirements.achievement and (it.requirements.achievement.id or it.requirements.achievement)
    local reqID = questID or achievementID or src.questID or src.achievementID or src.id or ""
    return table.concat({
        tostring(src.type or ""),
        tostring(id),
        tostring(faction),
        tostring(reqID),
    }, ":")
end

local function NormalizeCategory(cat)
    if cat == "Saved Items" then return "Saved Items" end
    if cat == "PVP" then return "PvP" end
    return cat
end

local function AddToCategory(cat, it)
    if type(it) ~= "table" then return end
    local decorID = it.decorID
    if Availability and Availability.IsDecorAvailable and not Availability:IsDecorAvailable(decorID) then return end
    local key = GetVariantKey(it)
    if not key then return end
    cat = NormalizeCategory(cat)
    GI._categoryScratch = GI._categoryScratch or {}
    GI._categoryScratch[cat] = GI._categoryScratch[cat] or {}
    GI._categoryScratch[cat][key] = it
    if decorID then GI.byItemID[decorID] = true end
end

local function CountSet(set)
    local n = 0
    for _ in pairs(set or {}) do n = n + 1 end
    return n
end

local function CountCollected(set)
    local n = 0
    if not Collection or not Collection.IsCollected then return 0 end
    for _, it in pairs(set or {}) do
        if Collection:IsCollected(it) then
            n = n + 1
        end
    end
    return n
end

local function buildVendorCategories()
    local vendors = NS.Data and NS.Data.Vendors
    if type(vendors) ~= "table" then return end
    for _, exp in pairs(vendors) do
        for _, zone in pairs(exp or {}) do
            for _, vendor in ipairs(zone or {}) do
                local src = vendor and vendor.source or {}
                local id = tonumber(src.id or vendor.npcID or vendor.id)
                local isPvPVendor = id and PVP_VENDOR_IDS[id]
                if type(vendor.items) == "table" then
                    for _, it in ipairs(vendor.items) do
                        if type(it) == "table" then
                            it.source = it.source or {}
                            it.source.type = it.source.type or "vendor"
                            it.source.faction = it.source.faction or src.faction
                            it.faction = it.faction or src.faction
                        end
                        AddToCategory("Vendors", it)
                        if isPvPVendor then
                            AddToCategory("PvP", it)
                        end
                    end
                end
            end
        end
    end
end

local function walkCategory(cat, dataKey)
    local data = NS.Data and NS.Data[dataKey or cat]
    if type(data) ~= "table" then return end

    local function walk(node)
        if type(node) ~= "table" then return end
        if node[1] and node[1].decorID then
            for _, it in ipairs(node) do AddToCategory(cat, it) end
            return
        end
        if node.items and type(node.items) == "table" then
            for _, it in ipairs(node.items) do AddToCategory(cat, it) end
            return
        end
        for _, v in pairs(node) do walk(v) end
    end

    walk(data)
end

function GI:Build()
    wipe(self.byItemID)
    wipe(self.counts)
    wipe(self.collected)
    self._categoryScratch = {}

    if NS.Data and NS.Data.Vendors then
        buildVendorCategories()
    end

    if NS.Data then
        if NS.Data.Achievements then
            walkCategory("Achievements")
        end

        if NS.Data.Quests then
            walkCategory("Quests")
        end

        if NS.Data.Professions then
            walkCategory("Professions")
        end

        if NS.Data.Drops then
            walkCategory("Drops")
        end

        if NS.Data.Shops then
            walkCategory("Shop", "Shops")
        end

        if NS.Data.Treasures then
            walkCategory("Treasures")
        end

        if NS.Data["Saved Items"] then
            walkCategory("Saved Items")
        end
    end

    for cat, set in pairs(self._categoryScratch) do
        self.counts[cat] = CountSet(set)
        self.collected[cat] = CountCollected(set)
    end

    self._categoryScratch = nil
    self._built = true
end

function GI:Invalidate(rebuildNow)
    self._built = false
    if rebuildNow then
        self:Build()
    end
end

function GI:Ensure()
    if not self._built then self:Build() end
end

function GI:GetCounts(cat)
    self:Ensure()
    cat = NormalizeCategory(cat)
    return (self.collected[cat] or 0), (self.counts[cat] or 0)
end

if Collection and Collection.RegisterListener then
    Collection:RegisterListener(function()
        GI:Invalidate(false)
    end)
end

return GI
