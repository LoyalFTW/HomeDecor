local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local GI = {}
NS.Systems.GlobalIndex = GI

GI.byItemID   = {}
GI.counts     = {}
GI.collected  = {}
GI._built     = false

local Collection = NS.Systems and NS.Systems.Collection
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

local function walkCategory(cat)
    local data = NS.Data and NS.Data[cat]
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
    local DataLoader = NS.Systems and NS.Systems.DataLoader
    if DataLoader and DataLoader.EnsureAllCatalogData then
        DataLoader:EnsureAllCatalogData()
    end

    wipe(self.byItemID)
    wipe(self.counts)
    wipe(self.collected)
    self._categoryScratch = {}

    buildVendorCategories()
    walkCategory("Achievements")
    walkCategory("Quests")
    walkCategory("Professions")
    walkCategory("Drops")
    walkCategory("Saved Items")

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
