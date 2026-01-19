local ADDON, NS = ...

local FiltersSys = NS.Systems and NS.Systems.Filters

local M = {}
NS.UI.ViewerData = M

local EXPANSION_RANK = {
    Classic = 1,

    BurningCrusade = 2,
    ["Burning Crusade"] = 2,
    Outland = 2,

    Wrath = 3,
    ["Wrath of the Lich King"] = 3,
    Northrend = 3,

    Cataclysm = 4,
    Cata = 4,

    Pandaria = 5,
    MistsOfPandaria = 5,
    ["Mists of Pandaria"] = 5,
    Pandaren = 5,

    WarlordsOfDraenor = 6,
    ["Warlords of Draenor"] = 6,
    Draenor = 6,

    Legion = 7,

    BattleForAzeroth = 8,
    ["Battle for Azeroth"] = 8,
    Kul = 8,

    Shadowlands = 9,

    Dragonflight = 10,
    Dragon = 10,

    WarWithin = 11,
    TheWarWithin = 11,
    ["The War Within"] = 11,
    Khaz = 11,
}

local function ExpansionRank(name)
    if not name then return 999 end
    return EXPANSION_RANK[name] or 999
end

function M.GetExpansionOrder(t)
    local order = {}
    if type(t) ~= "table" then return order end
    for k in pairs(t) do
        order[#order + 1] = k
    end
    table.sort(order, function(a, b)
        local ra, rb = ExpansionRank(a), ExpansionRank(b)
        if ra ~= rb then return ra < rb end
        return tostring(a) < tostring(b)
    end)
    return order
end

function M.Trim(s)
    if type(s) ~= "string" then return "" end
    return (s:gsub("^%s+",""):gsub("%s+$",""))
end

function M.CopyShallow(t)
    local o = {}
    if type(t) == "table" then
        for k, v in pairs(t) do o[k] = v end
    end
    return o
end

function M.SlimVendor(v)
    if type(v) ~= "table" then return nil end
    local src = v.source
    return {
        title    = v.title,
        name     = v.name,
        zone     = v.zone or (src and src.zone),
        faction  = v.faction or (src and src.faction),
        worldmap = v.worldmap or (src and src.worldmap),
        source   = src,
    }
end

local function _pickDecorIndexVendor(entry, ui, db)
    if type(entry) ~= "table" then return nil end
    local vendors = entry.vendors or entry.vendorsSlim or (entry.vendor and { entry.vendor }) or (entry.vendorSlim and { entry.vendorSlim }) or {}
    local f = db and db.filters or {}

    local wantFaction = f.faction
    local wantZone    = f.zone

    local function matches(v)
        if type(v) ~= "table" then return false end
        local src = v.source or {}
        local vf  = v.faction or src.faction or "Neutral"
        local vz  = v.zone or src.zone

        if wantFaction and wantFaction ~= "ALL" and vf ~= "Neutral" and vf ~= wantFaction then
            return false
        end

        if wantZone and wantZone ~= "ALL" and vz and vz ~= wantZone then
            return false
        end

        return true
    end

    for _, v in ipairs(vendors) do
        if matches(v) then return v end
    end

    return entry.vendor or entry.vendorSlim or vendors[1]
end

local function _hydrateFromDecorIndex(it, ui, db)
    local DecorIndex = NS.Systems and NS.Systems.DecorIndex
    if not DecorIndex or not it or not it.decorID then return it end

    if DecorIndex.EnsureBuilt then
        DecorIndex:EnsureBuilt()
    end

    local entry = DecorIndex[it.decorID]
    if not entry or not entry.slim then return it end

    local vitem = entry.slim
    it.title = it.title or vitem.title
    it.decorType = it.decorType or vitem.decorType

    local itemID = (vitem.source and vitem.source.itemID) or vitem.itemID
    it.source = it.source or {}
    if itemID then
        it.itemID = it.itemID or itemID
        it.source.itemID = it.source.itemID or itemID
    end

    local bestVendor = _pickDecorIndexVendor(entry, ui, db)
    if bestVendor then
        it.vendor = it.vendor or bestVendor
        it._navVendor = it._navVendor or bestVendor
    end

    return it
end

function M.ResolveAchievementDecor(it)
    local DecorIndex = NS.Systems and NS.Systems.DecorIndex
    if not it or not it.decorID or not DecorIndex then return it end
    if DecorIndex.EnsureBuilt then
        DecorIndex:EnsureBuilt()
    end

    local st = it.source and it.source.type
    if st ~= "achievement" and st ~= "quest" and st ~= "pvp" then return it end
    if it._navVendor or it.vendor then return it end

    local entry = DecorIndex[it.decorID]
    if not entry then return it end

    it.source = it.source or {}

    local item = entry.slim
    if item then
        it.title     = it.title or item.title
        it.decorType = it.decorType or item.decorType

        if item.source and item.source.itemID then
            it.itemID = it.itemID or item.source.itemID
            it.source.itemID = it.source.itemID or item.source.itemID
        end
    end

    local desiredFaction = it.faction or (it.source and it.source.faction)
    if desiredFaction ~= "Alliance" and desiredFaction ~= "Horde" then
        desiredFaction = nil
    end

    local function vendorFaction(v)
        if type(v) ~= "table" then return nil end
        local src = v.source or {}
        local f = v.faction or src.faction
        if f == "Alliance" or f == "Horde" then return f end
        return nil
    end

    local picked
    local vendors = entry.vendorsSlim or entry.vendors or (entry.vendorSlim and { entry.vendorSlim }) or (entry.vendor and { entry.vendor }) or {}

    if desiredFaction and type(vendors) == "table" then
        for _, v in ipairs(vendors) do
            if vendorFaction(v) == desiredFaction then
                picked = v
                break
            end
        end
    end

    picked = picked or entry.vendorSlim or entry.vendor or vendors[1]

    local vsrc = picked and picked.source
    if vsrc then
        if vsrc.id then
            it.npcID = it.npcID or vsrc.id
            it.source.npcID = it.source.npcID or vsrc.id
        end

        if vsrc.worldmap then
            it.worldmap = it.worldmap or vsrc.worldmap
            it.source.worldmap = it.source.worldmap or vsrc.worldmap
        end

        if vsrc.zone then
            it.zone = it.zone or vsrc.zone
            it.source.zone = it.source.zone or vsrc.zone
        end

        if vsrc.faction then
            it.faction = it.faction or vsrc.faction
            it.source.faction = it.source.faction or vsrc.faction
        end
    end

    if it.source.type == "achievement" then
        local ach = item and item.requirements and item.requirements.achievement
        if ach then
            it.source.id   = it.source.id   or ach.id
            it.source.achievementID = it.source.achievementID or ach.id
            it.source.name = it.source.name or ach.title
        end
    end

    if it.source.type == "quest" then
        local q = item and item.requirements and item.requirements.quest
        if q then
            it.source.id      = it.source.id      or q.id
            it.source.questID = it.source.questID or q.id
            it.source.name    = it.source.name    or q.title
        end
    end

    it.vendor     = picked or entry.vendorSlim or entry.vendor
    it._navVendor = picked or entry.vendorSlim or entry.vendor

    return it
end

function M.BuildGlobalSearchResults(ui, db)
    local out = {}
    if not FiltersSys or not FiltersSys.Passes then return out end

    local ui2 = M.CopyShallow(ui)
    ui2.activeCategory = "Search"

    local seen = {}

    local function addOrPrefer(it)
        local id = it and it.decorID
        if not id then return end
        local cur = seen[id]
        if not cur then
            seen[id] = it
            return
        end

        local curTitle = cur.title
        local newTitle = it.title
        if (not curTitle or curTitle == "") and (newTitle and newTitle ~= "") then
            seen[id] = it
            return
        end

        local curItemID = (cur.source and cur.source.itemID) or cur.itemID
        local newItemID = (it.source and it.source.itemID) or it.itemID
        if not curItemID and newItemID then
            seen[id] = it
        end
    end

    local DecorIndex = NS.Systems and NS.Systems.DecorIndex
    if DecorIndex and DecorIndex.EnsureBuilt then
        DecorIndex:EnsureBuilt()
    end

    local flat = DecorIndex and DecorIndex.flatAll
    if type(flat) == "table" then
        for _, it in ipairs(flat) do
            if it and it.decorID then
                if FiltersSys:Passes(it, ui2, db) then
                    addOrPrefer(it)
                end
            end
        end
    else
        local data = NS.Data or {}
        local vendors = data.Vendors
        if type(vendors) == "table" then
            for expName, expTbl in pairs(vendors) do
                if type(expTbl) == "table" then
                    for zoneName, zoneTbl in pairs(expTbl) do
                        if type(zoneTbl) == "table" then
                            for _, vendor in ipairs(zoneTbl) do
                                if type(vendor) == "table" and type(vendor.items) == "table" then
                                    local vSlim = M.SlimVendor(vendor)
                                    for _, vitem in ipairs(vendor.items) do
                                        if type(vitem) == "table" and vitem.decorID then
                                            local it = M.CopyShallow(vitem)
                                            it.source = it.source or {}
                                            it.source.type = it.source.type or "vendor"
                                            it.vendor = it.vendor or vSlim
                                            it._navVendor = it._navVendor or vSlim
                                            it._expansion = it._expansion or expName
                                            it.zone = it.zone or (vSlim and vSlim.zone) or zoneName

                                            if FiltersSys:Passes(it, ui2, db) then
                                                addOrPrefer(it)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for _, it in pairs(seen) do
        out[#out+1] = it
    end

    table.sort(out, function(a, b)
        return tostring(a.title or "") < tostring(b.title or "")
    end)

    return out
end

function M.MakeSignature(ui, filters, viewMode, search, width, headerVer)
    local parts = {
        ui and ui.activeCategory or "",
        tostring(viewMode or ""),
        tostring(search or ""),
        tostring(width or 0),
        tostring(headerVer or 0),
    }

    filters = filters or {}
    parts[#parts+1] = tostring(filters.expansion or "")
    parts[#parts+1] = tostring(filters.zone or "")
    parts[#parts+1] = tostring(filters.faction or "")
    parts[#parts+1] = tostring(filters.category or "")
    parts[#parts+1] = tostring(filters.subcategory or "")
    parts[#parts+1] = filters.hideCollected and "1" or "0"
    parts[#parts+1] = filters.onlyCollected and "1" or "0"

    return table.concat(parts, "|")
end

function M.AttachVendorCtx(it, vendor)
    if type(it) ~= "table" or type(vendor) ~= "table" then return it end

    it._navVendor = it._navVendor or vendor
    it.vendor = it.vendor or vendor

    local vsrc = vendor.source
    local vf = (vendor.faction) or (vsrc and vsrc.faction)
    if vf == "Alliance" or vf == "Horde" then
        it.faction = vf
        it.source = it.source or {}
        it.source.faction = vf
    end

    if not it.zone then
        it.zone = (vendor.zone) or (vsrc and vsrc.zone)
    end
    if not it.worldmap then
        it.worldmap = (vendor.worldmap) or (vsrc and vsrc.worldmap)
    end

    return it
end

local DecorIconCache = {}

function M.GetDecorIcon(decorID)
    if not decorID then return end
    if DecorIconCache[decorID] ~= nil then
        return DecorIconCache[decorID] or nil
    end
    if not C_HousingCatalog or not C_HousingCatalog.GetCatalogEntryInfoByRecordID then
        DecorIconCache[decorID] = false
        return
    end
    local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
    if info and info.iconTexture then
        DecorIconCache[decorID] = info.iconTexture
        return info.iconTexture
    end
    DecorIconCache[decorID] = false
end

function M.NormalizeExpansionNode(expNode)
    if type(expNode) ~= "table" then return {} end

    local isArray = true
    local count = 0

    for k in pairs(expNode) do
        if type(k) ~= "number" then
            isArray = false
            break
        end
        count = count + 1
    end

    if isArray and count > 0 then
        return { ["ALL"] = expNode }
    end

    return expNode
end

return M
