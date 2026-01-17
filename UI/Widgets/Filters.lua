local ADDON, NS = ...
local Filters = {}
NS.Systems = NS.Systems or {}
NS.Systems.Filters = Filters

local Collection = NS.Systems.Collection

local DEFAULTS = {
    hideCollected = false,    
    onlyCollected = false,

    expansion    = "ALL",
    zone         = "ALL",
    faction      = "ALL",
    category     = "ALL",
    subcategory  = "ALL",
}

function Filters:EnsureDefaults(db)
    if not db then return end
    db.filters = db.filters or {}
    for k, v in pairs(DEFAULTS) do
        if db.filters[k] == nil then
            db.filters[k] = v
        end
    end
    db.filters.decorTypes = db.filters.decorTypes or {}
end

Filters.Categories = {
    { id = "Accents",        label = "Accents" },
    { id = "Functional",     label = "Functional" },
    { id = "Furnishings",    label = "Furnishings" },
    { id = "Lighting",       label = "Lighting" },
    { id = "Miscellaneous",  label = "Miscellaneous" },
    { id = "Nature",         label = "Nature" },
    { id = "Structural",     label = "Structural" },
    { id = "Uncategorized",  label = "Uncategorized" },
}

Filters.Subcategories = {
    Accents = {
        "Floor",
        "Food and Drink",
        "Misc Accents",
        "Ornamental",
        "Wall Hangings",
    },
    Functional = {
        "Misc Functional",
        "Utility",
    },
    Furnishings = {
        "Beds",
        "Misc Furnishings",
        "Seating",
        "Storage",
        "Tables and Desks",
    },
    Lighting = {
        "Ceiling Lights",
        "Large Lights",
        "Misc Lighting",
        "Small Lights",
        "Wall Lights",
    },
    Miscellaneous = {
        "Miscellaneous - All",
    },
    Nature = {
        "Bushes",
        "Ground Cover",
        "Large Foliage",
        "Misc Nature",
        "Small Foliage",
    },
    Structural = {
        "Doors",
        "Large Structures",
        "Misc Structural",
        "Walls and Columns",
        "Windows",
    },
    Uncategorized = {
        "Uncategorized",
    },
}

Filters.DecorTypeToCategory = {
    ["Seating"]            = "Furnishings",
    ["Storage"]            = "Furnishings",
    ["Tables and Desks"]   = "Furnishings",
    ["Beds"]               = "Furnishings",
    ["Misc Furnishings"]   = "Furnishings",

    ["Ceiling Lights"]     = "Lighting",
    ["Large Lights"]       = "Lighting",
    ["Small Lights"]       = "Lighting",
    ["Wall Lights"]        = "Lighting",
    ["Misc Lighting"]      = "Lighting",

    ["Large Structures"]   = "Structural",
    ["Misc Structural"]    = "Structural",
    ["Walls and Columns"]  = "Structural",
    ["Doors"]              = "Structural",
    ["Windows"]            = "Structural",

    ["Bushes"]             = "Nature",
    ["Ground Cover"]       = "Nature",
    ["Large Foliage"]      = "Nature",
    ["Small Foliage"]      = "Nature",
    ["Misc Nature"]        = "Nature",

    ["Floor"]              = "Accents",
    ["Food and Drink"]     = "Accents",
    ["Wall Hangings"]      = "Accents",
    ["Ornamental"]         = "Accents",
    ["Misc Accents"]       = "Accents",

    ["Utility"]            = "Functional",
    ["Misc Functional"]    = "Functional",

    ["Miscellaneous - All"]= "Miscellaneous",

    ["Uncategorized"]      = "Uncategorized",
}

function Filters:GetCategoryForDecorType(decorType)
    if not decorType or decorType == "" then return "Uncategorized" end
    return self.DecorTypeToCategory[decorType] or "Uncategorized"
end

local CATEGORY_MAP = {
    ["Achievements"] = "Achievements",
    ["Quests"]       = "Quests",
    ["Vendors"]      = "Vendors",
    ["Drops"]        = "Drops",
    ["Professions"]  = "Professions",
    ["PvP"]          = "PvP",
    ["PVP"]          = "PvP",
}

function Filters:GetActiveData(ui)
    local key = ui and CATEGORY_MAP[ui.activeCategory]
    return key and NS.Data and NS.Data[key]
end

function Filters:GetExpansions(ui)
    local out = { { value = "ALL", text = "All" } }
    local seen = {}
    for _, cat in pairs(NS.Data or {}) do
        if type(cat) == "table" then
            for exp in pairs(cat) do
                if not seen[exp] then
                    seen[exp] = true
                    out[#out+1] = { value = exp, text = exp }
                end
            end
        end
    end
    table.sort(out, function(a,b) return tostring(a.text) < tostring(b.text) end)
    return out
end

function Filters:GetZones(ui, db)
    if ui and ui.activeCategory == "Vendors" then
        local out = { { value = "ALL", text = "All Zones" } }
        local seen = {}

        local function add(z)
            if type(z) == "string" and z ~= "" and not seen[z] then
                seen[z] = true
                out[#out+1] = { value = z, text = z }
            end
        end

        local vendors = NS.Data and NS.Data.Vendors
        local f = db and db.filters or {}
        local exp = f.expansion or "ALL"

        local function scanExp(expTbl)
            for _, zoneTbl in pairs(expTbl or {}) do
                for _, vendor in ipairs(zoneTbl or {}) do
                    if type(vendor) == "table" and vendor.source then
                        add(vendor.source.zone)
                    end
                end
            end
        end

        if type(vendors) == "table" then
            if exp ~= "ALL" and type(vendors[exp]) == "table" then
                scanExp(vendors[exp])
            else
                for _, expTbl in pairs(vendors) do
                    if type(expTbl) == "table" then
                        scanExp(expTbl)
                    end
                end
            end
        end

        table.sort(out, function(a,b) return tostring(a.text) < tostring(b.text) end)
        return out
    end

    local out = { { value = "ALL", text = "All Zones" } }
    local seen = {}

    local data = self:GetActiveData(ui)
    if type(data) ~= "table" then
        -- fallback: scan all known data
        for _, catTbl in pairs(NS.Data or {}) do
            for _, expTbl in pairs(catTbl or {}) do
                for zone in pairs(expTbl or {}) do
                    if not seen[zone] then
                        seen[zone] = true
                        out[#out+1] = { value = zone, text = zone }
                    end
                end
            end
        end
        table.sort(out, function(a,b) return tostring(a.text) < tostring(b.text) end)
        return out
    end

    local f = db and db.filters or {}
    local expFilter = f and f.expansion or "ALL"

    if expFilter and expFilter ~= "ALL" then
        local expTbl = data[expFilter]
        for zone in pairs(expTbl or {}) do
            if not seen[zone] then
                seen[zone] = true
                out[#out+1] = { value = zone, text = zone }
            end
        end
    else
        for _, expTbl in pairs(data or {}) do
            for zone in pairs(expTbl or {}) do
                if not seen[zone] then
                    seen[zone] = true
                    out[#out+1] = { value = zone, text = zone }
                end
            end
        end
    end

    table.sort(out, function(a,b) return tostring(a.text) < tostring(b.text) end)
    return out
end

function Filters:GetCategories()
    local out = { { value = "ALL", text = "All" } }
    for _, c in ipairs(self.Categories or {}) do
        out[#out+1] = { value = c.id, text = c.label or c.id }
    end
    return out
end

function Filters:GetSubcategories(f)
    local out = { { value = "ALL", text = "All" } }
    local cat = f and f.category
    if cat and cat ~= "ALL" then
        local subs = (self.Subcategories and self.Subcategories[cat]) or {}
        for _, s in ipairs(subs) do
            out[#out+1] = { value = s, text = s }
        end
    end
    return out
end

function Filters:BuildSearchText(it, ui)
    local parts = {}

    local function add(v)
        if type(v) == "string" and v ~= "" then
            parts[#parts+1] = v:lower()
        end
    end

    ui = ui or {}
    local activeCat = ui.activeCategory
    local isQuestContext = (activeCat == "Quests") or (it.source and it.source.type == "quest")

    -- Item fields
    add(it.title)
    add(it.name)
    add(it.decorType)
    add(it.profession)
    add(it.zone)
    add(it.expansion)

    -- Source fields (achievement/quest/vendor)
    if it.source then
        add(it.source.type)
        add(it.source.title)
        add(it.source.name)
        add(it.source.zone)
        add(it.source.faction)
    end

    if not isQuestContext then
        local v = it.vendor or it._navVendor
        if v then
            add(v.title)
            add(v.name)
            add(v.zone)
            add(v.faction)
            if v.source then
                add(v.source.title)
                add(v.source.name)
                add(v.source.zone)
                add(v.source.faction)
            end
        end
    end

    -- Achievement / quest objects if present
    if it.achievement then
        add(it.achievement.title)
        add(it.achievement.name)
    end
    if it.quest then
        add(it.quest.title)
        add(it.quest.name)
    end

    return table.concat(parts, " ")
end

-- Faction resolver (vendor-first, Neutral-safe)
function Filters:ResolveFaction(it)
    if not it then return "Neutral" end

    -- Vendor context ALWAYS wins
    if it.vendor and it.vendor.faction then
        return it.vendor.faction
    end
    if it._navVendor and it._navVendor.faction then
        return it._navVendor.faction
    end
    if it._navVendor and it._navVendor.source and it._navVendor.source.faction then
        return it._navVendor.source.faction
    end

    -- Item-level fallback
    if it.faction then
        return it.faction
    end
    if it.source and it.source.faction then
        return it.source.faction
    end

    return "Neutral"
end

local function _splitCSV(s)
    if type(s) ~= "string" then return nil end
    local out = {}
    for part in s:gmatch("[^,]+") do
        local v = part:gsub("^%s+", ""):gsub("%s+$", "")
        if v ~= "" then out[#out+1] = v end
    end
    return out
end

local function _matchesValue(val, filterVal)
    if not filterVal or filterVal == "ALL" then return true end
    if not val or val == "" then return false end

    val = tostring(val)
    -- Support multi-values: "Alliance,Horde"
    if val:find(",", 1, true) then
        local parts = _splitCSV(val) or {}
        for _, p in ipairs(parts) do
            if p == filterVal then return true end
        end
        return false
    end
    return val == filterVal
end

local function _safeLower(s)
    return (type(s) == "string" and s:lower()) or ""
end

-- Main filter
function Filters:Passes(it, ui, db)
    if not it or not db then return false end
    self:EnsureDefaults(db)

    ui = ui or {}
    local f = db.filters or {}

    -- Faction (vendor-first, Neutral-safe)
    if f.faction and f.faction ~= "ALL" then
        local itFaction = tostring(self:ResolveFaction(it) or "Neutral")

        -- Neutral always passes for everyone
        if itFaction ~= "Neutral" then
            if not _matchesValue(itFaction, f.faction) then
                return false
            end
        end
    end

    -- Expansion (view tags _expansion on items)
    if f.expansion and f.expansion ~= "ALL" then
        local itExp = it._expansion or it.expansion or (it.source and it.source.expansion)
        if not _matchesValue(itExp, f.expansion) then
            return false
        end
    end

    -- Zone (supports vendor->zone and csv lists)
    if f.zone and f.zone ~= "ALL" then
        local itZone =
            it.zone
            or (it.vendor and it.vendor.zone)
            or (it._navVendor and it._navVendor.zone)
            or (it.source and it.source.zone)
        if not _matchesValue(itZone, f.zone) then
            return false
        end
    end

    if f.subcategory and f.subcategory ~= "ALL" then
        if tostring(it.decorType or "") ~= tostring(f.subcategory) then
            return false
        end
    elseif f.category and f.category ~= "ALL" then
        local cat = self:GetCategoryForDecorType(it.decorType)
        if cat ~= f.category then
            return false
        end
    end

    if f.subcategory and f.subcategory ~= "ALL" then
        if tostring(it.decorType or "") ~= tostring(f.subcategory) then
            return false
        end
    end

    -- Collection
    if f.hideCollected and Collection and Collection.IsCollected and Collection:IsCollected(it) then
        return false
    end
    if f.onlyCollected and Collection and Collection.IsCollected and not Collection:IsCollected(it) then
        return false
    end

    local q = _safeLower(ui.search)
    if q ~= "" then
        local searchText = _safeLower(self:BuildSearchText(it, ui))

        for token in q:gmatch("%S+") do
            if token ~= "" and not searchText:find(token, 1, true) then
                return false
            end
        end
    end

    return true
end
