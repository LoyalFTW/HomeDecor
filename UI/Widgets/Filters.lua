local ADDON, NS = ...

local Filters = {}
NS.Systems = NS.Systems or {}
NS.Systems.Filters = Filters

local Collection = NS.Systems and NS.Systems.Collection

local tinsert, tconcat, sort = table.insert, table.concat, table.sort
local type, tostring, tonumber = type, tostring, tonumber
local lower = string.lower

local DEFAULTS = {
    hideCollected = false,
    onlyCollected = false,
    expansion     = "ALL",
    zone          = "ALL",
    faction       = "ALL",
    category      = "ALL",
    subcategory   = "ALL",
}

Filters.Categories = {
    { id = "Accents",       label = "Accents" },
    { id = "Functional",    label = "Functional" },
    { id = "Furnishings",   label = "Furnishings" },
    { id = "Lighting",      label = "Lighting" },
    { id = "Miscellaneous", label = "Miscellaneous" },
    { id = "Nature",        label = "Nature" },
    { id = "Structural",    label = "Structural" },
    { id = "Uncategorized", label = "Uncategorized" },
}

Filters.Subcategories = {
    Accents = { "Floor", "Food and Drink", "Misc Accents", "Ornamental", "Wall Hangings" },
    Functional = { "Misc Functional", "Utility" },
    Furnishings = { "Beds", "Misc Furnishings", "Seating", "Storage", "Tables and Desks" },
    Lighting = { "Ceiling Lights", "Large Lights", "Misc Lighting", "Small Lights", "Wall Lights" },
    Miscellaneous = { "Miscellaneous - All" },
    Nature = { "Bushes", "Ground Cover", "Large Foliage", "Misc Nature", "Small Foliage" },
    Structural = { "Doors", "Large Structures", "Misc Structural", "Walls and Columns", "Windows" },
    Uncategorized = { "Uncategorized" },
}

Filters.DecorTypeToCategory = {
    ["Seating"] = "Furnishings", ["Storage"] = "Furnishings", ["Tables and Desks"] = "Furnishings", ["Beds"] = "Furnishings", ["Misc Furnishings"] = "Furnishings",
    ["Ceiling Lights"] = "Lighting", ["Large Lights"] = "Lighting", ["Small Lights"] = "Lighting", ["Wall Lights"] = "Lighting", ["Misc Lighting"] = "Lighting",
    ["Large Structures"] = "Structural", ["Misc Structural"] = "Structural", ["Walls and Columns"] = "Structural", ["Doors"] = "Structural", ["Windows"] = "Structural",
    ["Bushes"] = "Nature", ["Ground Cover"] = "Nature", ["Large Foliage"] = "Nature", ["Small Foliage"] = "Nature", ["Misc Nature"] = "Nature",
    ["Floor"] = "Accents", ["Food and Drink"] = "Accents", ["Wall Hangings"] = "Accents", ["Ornamental"] = "Accents", ["Misc Accents"] = "Accents",
    ["Utility"] = "Functional", ["Misc Functional"] = "Functional",
    ["Miscellaneous - All"] = "Miscellaneous",
    ["Uncategorized"] = "Uncategorized",
}

local CATEGORY_MAP = {
    Achievements = "Achievements",
    Quests = "Quests",
    Vendors = "Vendors",
    Drops = "Drops",
    Professions = "Professions",
    PvP = "PvP",
    PVP = "PvP",
}

local DecorNameCache = {}
local function GetDecorName(decorID)
    decorID = tonumber(decorID)
    if not decorID then return nil end
    local v = DecorNameCache[decorID]
    if v ~= nil then return v or nil end
    local api = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID
    if not api then DecorNameCache[decorID] = false; return nil end
    local info = api(1, decorID, true)
    local n = info and info.name
    if type(n) == "string" and n ~= "" then
        DecorNameCache[decorID] = n
        return n
    end
    DecorNameCache[decorID] = false
    return nil
end

local function Ensure(db)
    if not db then return end
    local f = db.filters
    if not f then f = {}; db.filters = f end
    for k, v in pairs(DEFAULTS) do
        if f[k] == nil then f[k] = v end
    end
    if f.decorTypes == nil then f.decorTypes = {} end
end

function Filters:EnsureDefaults(db) Ensure(db) end

function Filters:GetCategoryForDecorType(decorType)
    if not decorType or decorType == "" then return "Uncategorized" end
    return self.DecorTypeToCategory[decorType] or "Uncategorized"
end

function Filters:GetActiveData(ui)
    local key = ui and CATEGORY_MAP[ui.activeCategory]
    return key and NS.Data and NS.Data[key] or nil
end

function Filters:GetExpansions()
    local out, seen = { { value = "ALL", text = "All" } }, {}
    for _, cat in pairs(NS.Data or {}) do
        if type(cat) == "table" then
            for exp in pairs(cat) do
                if not seen[exp] then
                    seen[exp] = true
                    out[#out + 1] = { value = exp, text = exp }
                end
            end
        end
    end
    sort(out, function(a, b) return tostring(a.text) < tostring(b.text) end)
    return out
end

function Filters:GetZones(ui, db)
    Ensure(db)
    local out, seen = { { value = "ALL", text = "All Zones" } }, {}

    local function add(z)
        if type(z) == "string" and z ~= "" and not seen[z] then
            seen[z] = true
            out[#out + 1] = { value = z, text = z }
        end
    end

    local function sortOut()
        sort(out, function(a, b) return tostring(a.text) < tostring(b.text) end)
        return out
    end

    if ui and ui.activeCategory == "Vendors" then
        local vendors = NS.Data and NS.Data.Vendors
        local exp = (db and db.filters and db.filters.expansion) or "ALL"
        local function scanExp(expTbl)
            for _, zoneTbl in pairs(expTbl or {}) do
                for _, vendor in ipairs(zoneTbl or {}) do
                    local src = type(vendor) == "table" and vendor.source
                    if src then add(src.zone) end
                end
            end
        end
        if type(vendors) == "table" then
            if exp ~= "ALL" and type(vendors[exp]) == "table" then
                scanExp(vendors[exp])
            else
                for _, expTbl in pairs(vendors) do
                    if type(expTbl) == "table" then scanExp(expTbl) end
                end
            end
        end
        return sortOut()
    end

    local data = self:GetActiveData(ui)
    local expFilter = (db and db.filters and db.filters.expansion) or "ALL"

    local function scanData(tbl)
        for zone in pairs(tbl or {}) do add(zone) end
    end

    if type(data) == "table" then
        if expFilter ~= "ALL" then
            scanData(data[expFilter])
        else
            for _, expTbl in pairs(data) do scanData(expTbl) end
        end
        return sortOut()
    end

    for _, catTbl in pairs(NS.Data or {}) do
        if type(catTbl) == "table" then
            for _, expTbl in pairs(catTbl) do
                scanData(expTbl)
            end
        end
    end
    return sortOut()
end

function Filters:GetCategories()
    local out = { { value = "ALL", text = "All" } }
    for _, c in ipairs(self.Categories or {}) do
        out[#out + 1] = { value = c.id, text = c.label or c.id }
    end
    return out
end

function Filters:GetSubcategories(f)
    local out = { { value = "ALL", text = "All" } }
    local cat = f and f.category
    if cat and cat ~= "ALL" then
        local subs = (self.Subcategories and self.Subcategories[cat]) or {}
        for _, s in ipairs(subs) do
            out[#out + 1] = { value = s, text = s }
        end
    end
    return out
end

local function addText(t, v)
    if type(v) == "string" then
        if v ~= "" then t[#t + 1] = lower(v) end
    elseif v ~= nil then
        t[#t + 1] = lower(tostring(v))
    end
end

function Filters:BuildSearchText(it, ui)
    ui = ui or {}
    local parts = {}
    addText(parts, it.title)

    local dn = GetDecorName(it.decorID)
    if dn then addText(parts, dn) end

    addText(parts, it.decorID)
    addText(parts, it.source and it.source.itemID)
    addText(parts, it.requirements and it.requirements.quest and it.requirements.quest.id)
    addText(parts, it.requirements and it.requirements.achievement and it.requirements.achievement.id)

    addText(parts, it.name)
    addText(parts, it.decorType)
    addText(parts, it.profession)
    addText(parts, it.zone)
    addText(parts, it.expansion)

    local src = it.source
    if src then
        addText(parts, src.type)
        addText(parts, src.title)
        addText(parts, src.name)
        addText(parts, src.zone)
        addText(parts, src.faction)
    end

    local activeCat = ui.activeCategory
    local questCtx = (activeCat == "Quests") or (src and src.type == "quest")
    if not questCtx then
        local v = it.vendor or it._navVendor
        if v then
            addText(parts, v.title)
            addText(parts, v.name)
            addText(parts, v.zone)
            addText(parts, v.faction)
            local vs = v.source
            if vs then
                addText(parts, vs.title)
                addText(parts, vs.name)
                addText(parts, vs.zone)
                addText(parts, vs.faction)
            end
        end
    end

    local ach = it.achievement
    if ach then addText(parts, ach.title); addText(parts, ach.name) end
    local q = it.quest
    if q then addText(parts, q.title); addText(parts, q.name) end

    return tconcat(parts, " ")
end

function Filters:ResolveFaction(it)
    if not it then return "Neutral" end
    local v = it._navVendor or it.vendor
    local f = (v and (v.faction or (v.source and v.source.faction))) or it.faction or (it.source and it.source.faction)
    return f or "Neutral"
end

local function splitCSV(s)
    local out = {}
    for part in s:gmatch("[^,]+") do
        local v = part:gsub("^%s+", ""):gsub("%s+$", "")
        if v ~= "" then out[#out + 1] = v end
    end
    return out
end

local function matchesValue(val, want)
    if not want or want == "ALL" then return true end
    if val == nil or val == "" then return false end
    val = tostring(val)
    if val:find(",", 1, true) then
        for _, p in ipairs(splitCSV(val)) do
            if p == want then return true end
        end
        return false
    end
    return val == want
end

local function safeLower(s) return (type(s) == "string" and lower(s)) or "" end

function Filters:Passes(it, ui, db)
    if not it or not db then return false end
    Ensure(db)

    ui = ui or {}
    local f = db.filters or {}

    local st = it.source and it.source.type
    local isExternalish = (st == "external" or st == "event" or it._isEventTimed or it._isEventHeader)

    if f.faction ~= "ALL" and not isExternalish then
        local fac = tostring(self:ResolveFaction(it) or "Neutral")
        if fac ~= "Neutral" and not matchesValue(fac, f.faction) then return false end
    end

    if f.expansion ~= "ALL" then
        local itExp = it._expansion or it.expansion or (it.source and it.source.expansion)
        if not matchesValue(itExp, f.expansion) then return false end
    end

    if f.zone ~= "ALL" then
        local itZone = it.zone
            or (it.vendor and it.vendor.zone)
            or (it._navVendor and it._navVendor.zone)
            or (it.source and it.source.zone)

        if (not itZone or itZone == "") then
            if not isExternalish then return false end
        else
            if not matchesValue(itZone, f.zone) then return false end
        end
    end

    if f.subcategory ~= "ALL" then
        if tostring(it.decorType or "") ~= tostring(f.subcategory) then return false end
    elseif f.category ~= "ALL" then
        if self:GetCategoryForDecorType(it.decorType) ~= f.category then return false end
    end

    if f.hideCollected and Collection and Collection.IsCollected and Collection:IsCollected(it) then return false end
    if f.onlyCollected and Collection and Collection.IsCollected and not Collection:IsCollected(it) then return false end

    local q = safeLower(ui.search)
    if q ~= "" then
        local txt = safeLower(self:BuildSearchText(it, ui))
        for token in q:gmatch("%S+") do
            if token ~= "" and not txt:find(token, 1, true) then return false end
        end
    end

    return true
end

return Filters
