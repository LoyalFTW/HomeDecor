local ADDON, NS = ...
local View = {}
NS.UI.Viewer = View

local C           = NS.UI.Controls
local T           = NS.UI.Theme.colors
local TT          = NS.UI.Tooltips
local Preview     = NS.UI.Preview
local Favorite    = NS.UI.FavoriteStar
local Collection  = NS.Systems.Collection
local StatusIcon  = NS.UI.StatusIcon
local ProgressBar = NS.UI.ProgressBar
local Navigation  = NS.UI.Navigation
local DropPanel   = NS.UI.DropPanel
local HeaderCtrl  = NS.UI.HeaderController
local FiltersSys  = NS.Systems and NS.Systems.Filters

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

local function GetExpansionOrder(t)
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

local DecorIconCache = {}

local DecorIndex = NS.Systems and NS.Systems.DecorIndex

local function ResolveAchievementDecor(it)
    if not it or not it.decorID or not DecorIndex then return it end
    local st = it.source and it.source.type
    if st ~= "achievement" and st ~= "quest" and st ~= "pvp" then return it end
    if it._navVendor or it.vendor then return it end

    local entry = DecorIndex[it.decorID]
    if not entry then return it end

    local resolved = {}
    for k, v in pairs(it) do
        resolved[k] = v
    end

    resolved.source = resolved.source or {}

    local item = entry.item
    if item then
        resolved.title     = item.title
        resolved.decorType = item.decorType

        if item.source and item.source.itemID then
            resolved.itemID = item.source.itemID
            resolved.source.itemID = resolved.source.itemID or item.source.itemID
        end
    end

    local desiredFaction = resolved.faction or (resolved.source and resolved.source.faction)
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

    local picked = nil
    local vendors = entry.vendors or (entry.vendor and { entry.vendor }) or {}

    if desiredFaction and type(vendors) == "table" then
        for _, v in ipairs(vendors) do
            if vendorFaction(v) == desiredFaction then
                picked = v
                break
            end
        end
    end

    picked = picked or entry.vendor or vendors[1]

    local vsrc = picked and picked.source
    if vsrc then
        if vsrc.id then
            resolved.npcID = resolved.npcID or vsrc.id
            resolved.source.npcID = resolved.source.npcID or vsrc.id
        end

        if vsrc.worldmap then
            resolved.worldmap = resolved.worldmap or vsrc.worldmap
            resolved.source.worldmap = resolved.source.worldmap or vsrc.worldmap
        end

        if vsrc.zone then
            resolved.zone = resolved.zone or vsrc.zone
            resolved.source.zone = resolved.source.zone or vsrc.zone
        end

        if vsrc.faction then
            resolved.faction = resolved.faction or vsrc.faction
            resolved.source.faction = resolved.source.faction or vsrc.faction
        end
    end

    if resolved.source.type == "achievement" then
        local ach = item
            and item.requirements
            and item.requirements.achievement

        if ach then
            resolved.source.id   = resolved.source.id   or ach.id
            resolved.source.name = resolved.source.name or ach.title
        end
    end

    if resolved.source.type == "quest" then
        local q = item
            and item.requirements
            and item.requirements.quest
        if q then
            resolved.source.id      = resolved.source.id      or q.id
            resolved.source.questID = resolved.source.questID or q.id
            resolved.source.name    = resolved.source.name    or q.title
        end
    end

    resolved.vendor     = picked or entry.vendor
    resolved._navVendor = picked or entry.vendor

    return resolved
end

local function _trim(s)
    if type(s) ~= "string" then return "" end
    return (s:gsub("^%s+",""):gsub("%s+$",""))
end

local function _copyShallow(t)
    local o = {}
    if type(t) == "table" then
        for k,v in pairs(t) do o[k]=v end
    end
    return o
end

local function _slimVendor(v)
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
    local vendors = entry.vendors or (entry.vendor and { entry.vendor }) or {}
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

    return entry.vendor or vendors[1]
end

local function _hydrateFromDecorIndex(it, ui, db)
    if not DecorIndex or not it or not it.decorID then return it end
    local entry = DecorIndex[it.decorID]
    if not entry or not entry.item then return it end

    local vitem = entry.item
    it.title = it.title or vitem.title
    it.decorType = it.decorType or vitem.decorType

    local itemID = (vitem.source and vitem.source.itemID) or vitem.itemID
    it.source = it.source or {}
    if itemID then
        it.itemID = it.itemID or itemID
        it.source.itemID = it.source.itemID or itemID
    end

    local bestVendor = _pickDecorIndexVendor(entry, ui, db)
    local slim = _slimVendor(bestVendor)
    if slim then
        it.vendor = it.vendor or slim
        it._navVendor = it._navVendor or slim
    end

    return it
end

local function BuildGlobalSearchResults(ui, db)
    local out = {}
    if not FiltersSys or not FiltersSys.Passes then return out end

    local ui2 = _copyShallow(ui)
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

    local data = NS.Data or {}

    local vendors = data.Vendors
    if type(vendors) == "table" then
        for expName, expTbl in pairs(vendors) do
            if type(expTbl) == "table" then
                for zoneName, zoneTbl in pairs(expTbl) do
                    if type(zoneTbl) == "table" then
                        for _, vendor in ipairs(zoneTbl) do
                            if type(vendor) == "table" and type(vendor.items) == "table" then
                                local vSlim = _slimVendor(vendor)
                                for _, vitem in ipairs(vendor.items) do
                                    if type(vitem) == "table" and vitem.decorID then
                                        local it = _copyShallow(vitem)
                                        it.source = it.source or {}
                                        it.source.type = it.source.type or "vendor"
                                        it.decorID = it.decorID
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

    local function collectVirtual(catTbl, stype)
        if type(catTbl) ~= "table" then return end
        for expName, expTbl in pairs(catTbl) do
            if type(expTbl) == "table" then
                for zoneName, list in pairs(expTbl) do
                    if type(list) == "table" then
                        for _, ptr in ipairs(list) do
                            if type(ptr) == "table" and ptr.decorID then
                                local it = _copyShallow(ptr)
                                it.source = it.source or {}
                                it.source.type = stype
                                it._expansion = it._expansion or expName
                                it.zone = it.zone or zoneName
                                _hydrateFromDecorIndex(it, ui2, db)

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

    collectVirtual(data.Achievements, "achievement")
    collectVirtual(data.Quests, "quest")

    local function deepScan(node, forcedType)
        if type(node) ~= "table" then return end

        if node.decorID then
            local it = _copyShallow(node)
            it.source = it.source or {}
            it.source.type = it.source.type or forcedType or "unknown"
            _hydrateFromDecorIndex(it, ui2, db)
            if FiltersSys:Passes(it, ui2, db) then
                addOrPrefer(it)
            end
            return
        end

        if node[1] ~= nil then
            for _, child in ipairs(node) do
                deepScan(child, forcedType)
            end
            return
        end

        for _, v in pairs(node) do
            deepScan(v, forcedType)
        end
    end

    deepScan(data.Drops, "drop")
    deepScan(data.Professions, "profession")
    deepScan(data.PvP or data.PVP, "pvp")
    deepScan(data.SavedItems or data["Saved Items"], "saved")

    for _, it in pairs(seen) do
        out[#out+1] = it
    end

    table.sort(out, function(a,b)
        return tostring(a.title or "") < tostring(b.title or "")
    end)

    return out
end

local function AttachVendorCtx(it, vendor)
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

local function GetDecorIcon(decorID)
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

local function NormalizeExpansionNode(expNode)
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
        return {
            ["ALL"] = expNode
        }
    end

    return expNode
end

local function DB()
    return NS.db and NS.db.profile
end

local function GetItemID(it)
    if not it then return end
    if it.source and it.source.itemID then return it.source.itemID end
    return it.id
end

local _wowheadPopup

local function BuildWowheadItemURL(itemID)
    if not itemID then return nil end
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local function BuildWowheadAchievementURL(achievementID)
    if not achievementID then return nil end
    return "https://www.wowhead.com/achievement=" .. tostring(achievementID)
end

local function BuildWowheadQuestURL(questID)
    if not questID then return nil end
    return "https://www.wowhead.com/quest=" .. tostring(questID)
end


local function GetRequirementLink(it)
    if not it then return nil end

    local r = it.requirements
    if not r and DecorIndex and it.decorID then
        local entry = DecorIndex[it.decorID]
        local item  = entry and entry.item
        r = item and item.requirements or nil
    end
    if not r then return nil end

    if r.quest and r.quest.id then
        return { kind = "quest", id = r.quest.id, text = r.quest.title }
    end
    if r.achievement and r.achievement.id then
        return { kind = "achievement", id = r.achievement.id, text = r.achievement.title }
    end
    return nil
end

local function BuildReqDisplay(req, hover)
    if not req then return "" end
    local sym = (req.kind == "quest") and "!" or "*"
    local symCol = "|cffffd100" .. sym .. "|r "
    local txtCol = hover and "|cfffff2a0" or "|cffffffff"
    return symCol .. txtCol .. (req.text or "") .. "|r"
end


local function ShowWowheadLinks(links)
    if not links or #links == 0 then return end

    if not _wowheadPopup then
        local p = CreateFrame("Frame", "HomeDecorWowheadPopup", UIParent, "BackdropTemplate")
        _wowheadPopup = p

        if type(UISpecialFrames) == "table" then
            local already
            for i = 1, #UISpecialFrames do
                if UISpecialFrames[i] == "HomeDecorWowheadPopup" then
                    already = true
                    break
                end
            end
            if not already then
                tinsert(UISpecialFrames, 1, "HomeDecorWowheadPopup")
            end
        end

        p:SetFrameStrata("FULLSCREEN_DIALOG")
        p:SetFrameLevel(9999)
        p:SetToplevel(true)
        p:SetClampedToScreen(true)
        p:SetPoint("CENTER")

        if C and C.Backdrop then
            C:Backdrop(p, T.panel, T.border)
        else
            p:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 },
            })
            p:SetBackdropColor(0, 0, 0, 0.9)
        end

        p:EnableMouse(true)
        p:SetMovable(true)
        p:RegisterForDrag("LeftButton")
        p:SetScript("OnDragStart", p.StartMoving)
        p:SetScript("OnDragStop", p.StopMovingOrSizing)

        p:EnableKeyboard(true)
        if p.SetPropagateKeyboardInput then
            p:SetPropagateKeyboardInput(false)
        end
        p:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                self:Hide()
            end
        end)

        local header = CreateFrame("Frame", nil, p, "BackdropTemplate")
        header:SetPoint("TOPLEFT", 6, -6)
        header:SetPoint("TOPRIGHT", -6, -6)
        header:SetHeight(44)
        C:Backdrop(header, T.header, T.border)
        p._header = header

        local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("LEFT", 12, 0)
        title:SetText("Wowhead Links")
        title:SetTextColor(unpack(T.accent))
        p._title = title

        local hint = p:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 12, -8)
        hint:SetText("Ctrl+C to copy, then paste into your browser.")
        p._hint = hint

        p._rows = {}
        for i = 1, 3 do
            local row = {}

            local lab = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.label = lab

            local eb = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
            eb:SetAutoFocus(false)
            eb:SetTextInsets(10, 10, 0, 0)
            eb:SetFontObject("ChatFontNormal")
            eb:SetHeight(28)
            eb:SetScript("OnEscapePressed", function() p:Hide() end)
            eb:SetScript("OnEnterPressed", function() p:Hide() end)
            row.editbox = eb

            p._rows[i] = row
        end

        local close = CreateFrame("Button", nil, p, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        close:SetFrameStrata(p:GetFrameStrata())
        close:SetFrameLevel(p:GetFrameLevel() + 20)
        close:SetScript("OnClick", function() p:Hide() end)
        close:Show()
        p._close = close

        local blocker = CreateFrame("Button", nil, UIParent)
        blocker:SetAllPoints(UIParent)
        blocker:SetFrameStrata("FULLSCREEN_DIALOG")
        blocker:SetFrameLevel(9998)
        blocker:EnableMouse(true)
        blocker:RegisterForClicks("AnyUp")
        blocker:SetScript("OnClick", function()
            if _wowheadPopup then _wowheadPopup:Hide() end
        end)
        blocker:Hide()
        p._blocker = blocker

        p:HookScript("OnShow", function(self)
            if self._blocker then self._blocker:Show() end
        end)
        p:HookScript("OnHide", function(self)
            if self._blocker then self._blocker:Hide() end
            if self._rows then
                for i = 1, #self._rows do
                    local eb = self._rows[i] and self._rows[i].editbox
                    if eb and eb:HasFocus() then
                        eb:ClearFocus()
                    end
                end
            end
        end)

        p:Hide()
    end

    local p = _wowheadPopup

    local maxRows = math.min(#links, 3)
    local width = 560
    local topY = -78
    local rowGap = 46

    p:SetWidth(width)
    p:SetHeight(90 + (maxRows * rowGap))

    local focused
    for i = 1, 3 do
        local row = p._rows and p._rows[i]
        if row then
            row.label:Hide()
            row.editbox:Hide()
        end
    end

    for i = 1, maxRows do
        local row = p._rows[i]
        local l = links[i]

        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT", 16, topY - ((i - 1) * rowGap))
        row.label:SetText(l.label or "Link")
        row.label:Show()

        row.editbox:ClearAllPoints()
        row.editbox:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", -6, -6)
        row.editbox:SetPoint("TOPRIGHT", p, "TOPRIGHT", -16, topY - ((i - 1) * rowGap) - 22)
        row.editbox:SetText(l.url or "")
        row.editbox:Show()

        if not focused then
            focused = row.editbox
        end
    end

    p:Show()
    if focused then
        focused:HighlightText()
        focused:SetFocus()
    end
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

local function getActiveData(ui)
    local key = CATEGORY_MAP[ui.activeCategory]
    if not key or not NS.Data then return nil end

    local t = NS.Data[key]
    if t ~= nil then return t end

    if key == "PvP" then
        return NS.Data.PvP or NS.Data.PVP or NS.Data.Pvp or NS.Data.pvp
    end

    return nil
end

local function keyExp(cat, exp) return cat .. ":exp:" .. exp end
local function keyZone(cat, exp, zone) return cat .. ":zone:" .. exp .. ":" .. zone end
local function keyVendor(cat, exp, zone, vendorID)
    return cat .. ":vendor:" .. exp .. ":" .. zone .. ":" .. tostring(vendorID)
end

local function ClampScroll(sf, content, desired)
    if not sf or not content then return 0 end
    local viewH = sf:GetHeight() or 0
    local maxScroll = math.max(0, (content:GetHeight() or 0) - viewH)
    if desired < 0 then return 0 end
    if desired > maxScroll then return maxScroll end
    return desired
end

local function Passes(it)
    local db = DB()
    if not db then return true end
    local ui = db.ui or {}
    if FiltersSys and FiltersSys.Passes then
        return FiltersSys:Passes(it, ui, db)
    end
    return true
end

local function IsCollectedSafe(it)
    if not it then return false end
    if not Collection or not Collection.IsCollected then return false end

    local ok, res = pcall(Collection.IsCollected, Collection, it)
    if ok and type(res) == "boolean" then return res end

    local id = (it.source and it.source.itemID) or it.vendorItemID or it.id or it.decorID
    local ok2, res2 = pcall(Collection.IsCollected, Collection, id)
    if ok2 and type(res2) == "boolean" then return res2 end

    return false
end

local function GetStateSafe(it)
    if not it then return nil end
    if not Collection or not Collection.GetState then return nil end

    local ok, res = pcall(Collection.GetState, Collection, it)
    if ok then return res end

    local id = (it.source and it.source.itemID) or it.vendorItemID or it.id or it.decorID
    local ok2, res2 = pcall(Collection.GetState, Collection, id)
    if ok2 then return res2 end

    return nil
end

local function CollectAllFavorites()
    local db = DB()
    if not db or not db.favorites then return {} end

    local out, seen = {}, {}

    for _, category in pairs(NS.Data or {}) do
        for _, expansions in pairs(category or {}) do
            for _, entries in pairs(expansions or {}) do
                if type(entries) == "table" then
                    for _, it in ipairs(entries) do
                        if type(it) == "table" and it.source and it.source.type == "vendor" and type(it.items) == "table" then
                            local vSlim = _slimVendor(it)
                            for _, vit in ipairs(it.items) do
                                local id = GetItemID(vit)
                                if id and db.favorites[id] and not seen[id] then
                                    seen[id] = true
                                    local leaf = _copyShallow(vit)
                                    AttachVendorCtx(leaf, vSlim or it)
                                    table.insert(out, leaf)
                                end
                            end
                        else
                            local id = GetItemID(it)
                            if id and db.favorites[id] and not seen[id] then
                                seen[id] = true
                                table.insert(out, _copyShallow(it))
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(out, function(a, b)
        return (a.title or "") < (b.title or "")
    end)

    return out
end

local function countItems(items, vendor)
    local total, collected = 0, 0

    local function countLeaf(leaf, vctx)
        if not leaf then return end
        local rit = leaf

        if vctx then
            AttachVendorCtx(rit, vctx)
        end

        if ResolveAchievementDecor then
            rit = ResolveAchievementDecor(rit)
        end

        if Passes(rit) then
            total = total + 1
            if IsCollectedSafe(rit) then
                collected = collected + 1
            end
        end
    end

    if vendor then
        for _, leaf in ipairs(items or {}) do
            countLeaf(leaf, vendor)
        end
        return collected, total
    end

    for _, it in ipairs(items or {}) do
        if type(it) == "table" and it.source and it.source.type == "vendor" and type(it.items) == "table" then
            for _, leaf in ipairs(it.items) do
                countLeaf(leaf, it)
            end
        else
            countLeaf(it, nil)
        end
    end

    return collected, total
end

local ROW_GAP      = 8
local LIST_H       = 46
local LIST_GAP     = 4
local PAD_TOP      = 10
local PAD_BOTTOM   = 16

local tileW, tileH, tileGap, iconSize = 180, 140, 16, 64

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

function View:Create(parent)
    local lastSortBy = nil
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", nil, f, "ScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 8, -52)
    sf:SetPoint("BOTTOMRIGHT", -28, 8)

    local content = CreateFrame("Frame", nil, sf)
    content:SetPoint("TOPLEFT", 0, 0)
    sf:SetScrollChild(content)

    sf:SetScript("OnSizeChanged", function(self, w)
        content:SetWidth((w or 0) - 18)
        if f.UpdateVisible then f:Render() end
    end)

    sf:SetScript("OnVerticalScroll", function()
        if f.UpdateVisible then f:UpdateVisible() end
    end)

    f._poolHeader = {}
    f._poolList   = {}
    f._poolTile   = {}
    f._active     = {}

    local function ClearPooledArtifacts(fr)
        if not fr then return end
        if fr._dropBadge then fr._dropBadge:Hide() end
        if fr._fav then fr._fav:Hide() end
        if fr._factionIcon then fr._factionIcon:Hide() end
        if fr._statusIcon then fr._statusIcon:Hide() end
        if fr._status then fr._status:Hide() end
        if fr.bar then fr.bar:Hide() end
        if fr.req then fr.req:Hide() end
        if fr.reqBtn then fr.reqBtn:Hide() end
        if fr.req then fr.req:Hide() end
        if fr.reqBtn then fr.reqBtn:Hide() end
    end

    local function ReleaseFrame(frame)
        if not frame then return end
        frame:Hide()
        frame:ClearAllPoints()
        frame._entry = nil
        frame:SetParent(content)
    end

    function f:ReleaseAll()
        for i = 1, #self._active do
            local fr = self._active[i]
            ReleaseFrame(fr)
            if fr._kind == "header" then
                table.insert(self._poolHeader, fr)
            elseif fr._kind == "tile" then
                table.insert(self._poolTile, fr)
            else
                table.insert(self._poolList, fr)
            end
        end
        wipe(self._active)
    end

    local function CreateHeader()
        local h = CreateFrame("Button", nil, content, "BackdropTemplate")
        h._kind = "header"
        C:Backdrop(h, T.row, T.border)

        h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h.text:SetPoint("LEFT", 12, 0)

        h.count = h:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        h.count:SetPoint("RIGHT", -40, 0)

	h.check = h:CreateTexture(nil, "OVERLAY")
    h.check:SetSize(14, 14)
    h.check:SetPoint("RIGHT", -14, 0)
    h.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    h.check:Hide()

        C:ApplyHover(h, T.row, T.hover)
        return h
    end

    local function CreateListRow()
        local r = CreateFrame("Frame", nil, content, "BackdropTemplate")
        r._kind = "list"
        C:Backdrop(r, T.panel, T.border)
        r:EnableMouse(true)

        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        r.text:SetPoint("TOPLEFT", 64, -8)

        r.req = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        r.req:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, -2)
        r.req:SetTextColor(0.8, 0.8, 0.8)
        r.req:Hide()

        
		r.req = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		r.req:SetPoint("TOPLEFT", r.text, "BOTTOMLEFT", 0, 0)
        r.req:SetJustifyH("LEFT")
		r.req:Hide()

		r.reqBtn = CreateFrame("Button", nil, r)
		r.reqBtn:Hide()
		r.reqBtn:EnableMouse(true)
		r.reqBtn:RegisterForClicks("AnyUp")

        return r
    end

    local function CreateTile()
        local r = CreateFrame("Frame", nil, content, "BackdropTemplate")
        r._kind = "tile"
        C:Backdrop(r, T.panel, T.border)
        r:EnableMouse(true)

        r.plate = r:CreateTexture(nil, "BACKGROUND")
        r.plate:SetColorTexture(0, 0, 0, 0.35)

        r.icon = r:CreateTexture(nil, "ARTWORK")

        r.label = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        r.label:SetJustifyH("CENTER")

        r.req = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        r.req:SetJustifyH("CENTER")
        r.req:SetText("")
        r.req:Hide()

        r.reqBtn = CreateFrame("Button", nil, r)
        r.reqBtn:Hide()
        r.reqBtn:EnableMouse(true)
        r.reqBtn:RegisterForClicks("AnyUp")

        return r
    end

    local function Acquire(kind)
        local fr
        if kind == "header" then
            fr = table.remove(f._poolHeader)
            if not fr then fr = CreateHeader() end
        elseif kind == "tile" then
            fr = table.remove(f._poolTile)
            if not fr then fr = CreateTile() end
        else
            fr = table.remove(f._poolList)
            if not fr then fr = CreateListRow() end
        end
        fr:Show()
        table.insert(f._active, fr)
        return fr
    end

    local function getAvailableWidth(indent)
        return math.max(0, (content:GetWidth() or 0) - indent - 8)
    end

    local function computeGrid(indent)
        local avail = getAvailableWidth(indent)
        local minTileW, maxTileW = 150, 220
        local minCols, maxCols = 2, 6

        local est = math.floor((avail + tileGap) / (minTileW + tileGap))
        local cols = clamp(est, minCols, maxCols)

        local w = math.floor((avail - (cols - 1) * tileGap) / cols)
        w = clamp(w, minTileW, maxTileW)

        while cols < maxCols do
            local w2 = math.floor((avail - cols * tileGap) / (cols + 1))
            if w2 >= minTileW then
                cols = cols + 1
                w = clamp(w2, minTileW, maxTileW)
            else
                break
            end
        end

        tileW = w
        tileH = math.floor(tileW * 0.78)
        iconSize = clamp(math.floor(tileW * 0.36), 48, 80)

        local total = cols * tileW + (cols - 1) * tileGap
        local startX = indent + math.max(0, (avail - total) / 2)
        return cols, startX
    end

    function f:RebuildEntries()
        local db = DB()
        if not db then self.entries = {}; return end
        local ui = db.ui or {}
        if FiltersSys and FiltersSys.EnsureDefaults then FiltersSys:EnsureDefaults(db) end

        local entries = {}
        local y = PAD_TOP
        local cat = ui.activeCategory or "Achievements"
        local viewMode = ui.viewMode or "Icon"

        local function tagExpansionItem(node, expName)
            if type(node) ~= "table" then return end
            node._expansion = expName

            if expName == "Alliance" or expName == "Horde" then
                node.faction = node.faction or expName
                node.source = node.source or {}
                node.source.faction = node.source.faction or expName
            end

            if node.source and type(node.source) == "table" and node.source.type == "vendor" and type(node.items) == "table" then
                for _, v in ipairs(node.items) do
                    tagExpansionItem(v, expName)
                end
            end
        end

        local function tagExpansionList(items, expName)
            for _, it in ipairs(items or {}) do
                tagExpansionItem(it, expName)
            end
        end
        local function addHeader(indent, height, label, cur, max, expandedState, clickKind, payload)
    cur = cur or 0
    max = max or 0

    if max <= 0 then return end

    table.insert(entries, {
        kind = "header",
        clickKind = clickKind,
        payload = payload,
        indent = indent,
        x = indent,
        y = y,
        w = (content:GetWidth() or 0) - indent - 8,
        h = height,
        label = label,
        cur = cur,
        max = max,
        expanded = expandedState and true or false,
    })
    y = y + height + ROW_GAP
end

        local function addListItem(indent, it, navCtx)
            table.insert(entries, {
                kind = "list",
                x = indent,
                y = y,
                w = (content:GetWidth() or 0) - indent - 8,
                h = LIST_H,
                indent = indent,
                it = it,
                navCtx = navCtx,
            })
            y = y + LIST_H + LIST_GAP
        end

        local function addTile(indent, it, navCtx, col, cols, startX)
            table.insert(entries, {
                kind = "tile",
                x = startX + col * (tileW + tileGap),
                y = y,
                w = tileW,
                h = tileH,
                indent = indent,
                it = it,
                navCtx = navCtx,
            })
        end

	local q = _trim(ui.search)
	local f = db and db.filters or {}
	local searching = (q ~= "")
	local flatMode =
    (q ~= "") or
    (f and ((f.subcategory and f.subcategory ~= "ALL") or (f.category and f.category ~= "ALL")))

if flatMode then
    local results = BuildGlobalSearchResults(ui, db)

    if viewMode == "Icon" then
        local cols, startX = computeGrid(12)
        local col = 0
        for _, it in ipairs(results) do
            addTile(12, it, nil, col, cols, startX)
            col = col + 1
            if col >= cols then
                col = 0
                y = y + tileH + tileGap
            end
        end
        if col > 0 then y = y + tileH + tileGap end
    else
        for _, it in ipairs(results) do
            addListItem(12, it, nil)
        end
    end

    self.entries = entries
    self.totalHeight = y + PAD_BOTTOM
    return
end

        if cat == "Saved Items" then
            if viewMode == "Icon" then
                local cols, startX = computeGrid(12)
                local col = 0
                for _, it in ipairs(CollectAllFavorites()) do
                    if ((FiltersSys and FiltersSys.Passes) and FiltersSys:Passes(it, (DB() and DB().ui) or {}, (DB() or {})) or true) then
                        addTile(12, it, nil, col, cols, startX)
                        col = col + 1
                        if col >= cols then
                            col = 0
                            y = y + tileH + tileGap
                        end
                    end
                end
                if col > 0 then y = y + tileH + tileGap end
            else
                for _, it in ipairs(CollectAllFavorites()) do
                    if ((FiltersSys and FiltersSys.Passes) and FiltersSys:Passes(it, (DB() and DB().ui) or {}, (DB() or {})) or true) then
                        addListItem(12, it, nil)
                    end
                end
            end
            self.entries = entries
            self.totalHeight = y + PAD_BOTTOM
            return
        end

if cat == "Quests" then
    local want = "quest"
    local vendors = (NS.Data and NS.Data.Vendors) or {}

    local expOrder = GetExpansionOrder(vendors)

    for _, expName in ipairs(expOrder) do
        local expTbl = vendors[expName]
        if type(expTbl) == "table" then
            local zoneOrder = {}
            for zoneName in pairs(expTbl) do zoneOrder[#zoneOrder+1] = zoneName end
            table.sort(zoneOrder, function(a,b) return tostring(a) < tostring(b) end)

            local expFlat = {}
            local zoneMap = {}

            for _, zoneName in ipairs(zoneOrder) do
                local zoneTbl = expTbl[zoneName]
                local list = {}

                if type(zoneTbl) == "table" then
                    for _, vendor in ipairs(zoneTbl) do
                        if type(vendor) == "table" and type(vendor.items) == "table" then
                            for _, vit in ipairs(vendor.items) do
                                if type(vit) == "table" and vit.decorID and vit.requirements then
                                    local req = vit.requirements
                                    local r = (want == "achievement") and req.achievement or req.quest
                                    if r and r.id then
                                        local it = _copyShallow(vit)
                                        it.source = it.source or {}
                                        it.source.type = want

                                        it.source.id   = it.source.id   or r.id
                                        it.source.name = it.source.name or r.title

                                        if want == "achievement" then
                                            it.source.achievementID = it.source.achievementID or r.id
                                        else
                                            it.source.questID = it.source.questID or r.id
                                        end

                                        AttachVendorCtx(it, vendor)
                                        it._expansion = expName
                                        it.zone = it.zone or (vendor.source and vendor.source.zone) or zoneName

                                        if not (FiltersSys and FiltersSys.Passes) or FiltersSys:Passes(it, ui, db) then
                                            list[#list+1] = it
                                            expFlat[#expFlat+1] = it
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if #list > 0 then
                    zoneMap[zoneName] = list
                end
            end

            if #expFlat > 0 then
                local cExp, tExp = countItems(expFlat)
                local eKey = keyExp(cat, expName)
                local expOpen = searching or (HeaderCtrl and HeaderCtrl:IsOpen("exp", eKey))

                addHeader(12, 44, expName, cExp, tExp, expOpen, "exp", { key = eKey })

                if expOpen then
                    for _, zoneName in ipairs(zoneOrder) do
                        local list = zoneMap[zoneName]
                        if list and #list > 0 then
                            local cZ, tZ = countItems(list)
                            local zKey = keyZone(cat, expName, zoneName)
                            local zoneOpen = searching or (HeaderCtrl and HeaderCtrl:IsOpen("zone", zKey))

                            addHeader(28, 36, zoneName, cZ, tZ, zoneOpen, "zone", { key = zKey })

                            if zoneOpen then
                                if viewMode == "Icon" then
                                    local cols, startX = computeGrid(28)
                                    local col = 0
                                    for _, it in ipairs(list) do
                                        addTile(28, it, it._navVendor or it.vendor, col, cols, startX)
                                        col = col + 1
                                        if col >= cols then
                                            col = 0
                                            y = y + tileH + tileGap
                                        end
                                    end
                                    if col > 0 then y = y + tileH + tileGap end
                                else
                                    for _, it in ipairs(list) do
                                        addListItem(28, it, it._navVendor or it.vendor)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    self.entries = entries
    self.totalHeight = y + PAD_BOTTOM
    return
end

        local data = getActiveData(ui)
        if not data then
            self.entries = entries
            self.totalHeight = y + PAD_BOTTOM
            return
        end

        local expOrder = GetExpansionOrder(data)
        for _, exp in ipairs(expOrder) do
            local zones = data[exp]
            zones = NormalizeExpansionNode(zones)
            local eCollected, eTotal = 0, 0
            for _, items in pairs(zones) do
                tagExpansionList(items, exp)
                local c, t = countItems(items)
                eCollected = eCollected + c
                eTotal = eTotal + t
            end

            local eKey = keyExp(cat, exp)

            addHeader(12, 44, exp, eCollected, eTotal, HeaderCtrl and HeaderCtrl:IsOpen("exp", eKey), "exp", { key = eKey })

            if HeaderCtrl and HeaderCtrl:IsOpen("exp", eKey) then
                for zone, items in pairs(zones) do
                    tagExpansionList(items, exp)
                    local zCollected, zTotal = countItems(items)
                    local zKey = keyZone(cat, exp, zone)

                    addHeader(28, 36, zone, zCollected, zTotal, HeaderCtrl and HeaderCtrl:IsOpen("zone", zKey), "zone", { key = zKey })

                    if HeaderCtrl and HeaderCtrl:IsOpen("zone", zKey) then
                                                if viewMode == "Icon" then
                                                    for _, it in ipairs(items) do
                                                        if it.source and it.source.type == "vendor" and it.items then
															local vCollected, vTotal = countItems(it.items, it)

															local vendorKeyId =
															(it.source and it.source.id)            
															or it.id                               
															or it.title                             
															or 0
                            								local vKey = keyVendor(cat, exp, zone, vendorKeyId)
                                                            addHeader(44, 30, "[Vendor] " .. (it.title or ""), vCollected, vTotal, HeaderCtrl and HeaderCtrl:IsOpen("vendor", vKey), "vendor", { key = vKey, vendor = it })
                                                            if HeaderCtrl and HeaderCtrl:IsOpen("vendor", vKey) then
                                                                local vCols, vStartX = computeGrid(64)
                                                                local vCol = 0
                                                                for _, vit in ipairs(it.items) do
                                 								 local rit = vit
                                                                    AttachVendorCtx(rit, it)
                                                                    rit = ResolveAchievementDecor(rit)

                                                                    if Passes(rit) then
                                                                        addTile(64, rit, it, vCol, vCols, vStartX)
                                                                        vCol = vCol + 1
                                                                        if vCol >= vCols then
                                                                            vCol = 0
                                                                            y = y + tileH + tileGap
                                                                        end
                                                                    end
                                                                end
                                                                if vCol > 0 then y = y + tileH + tileGap end
                                                            end
                                                        end
                                                    end

                                                    local cols, startX = computeGrid(64)
                                                    local col = 0
                                                    for _, it in ipairs(items) do
                                                        if not (it.source and it.source.type == "vendor" and it.items) then
                                                            if ((FiltersSys and FiltersSys.Passes) and FiltersSys:Passes(it, (DB() and DB().ui) or {}, (DB() or {})) or true) then
                                                                addTile(44, it, nil, col, cols, startX)
                                                                col = col + 1
                                                                if col >= cols then
                                                                    col = 0
                                                                    y = y + tileH + tileGap
                                                                end
                                                            end
                                                        end
                                                    end
                                                    if col > 0 then y = y + tileH + tileGap end
                         							   else
                                                    for _, it in ipairs(items) do
                                                        if it.source and it.source.type == "vendor" and it.items then
                                                            local vCollected, vTotal = countItems(it.items, it)
                                                            local vendorID = (it.source and it.source.id) or it.id or it.title or 0
                                                            local vKey = keyVendor(cat, exp, zone, vendorID)

                                                            addHeader(44, 30, "[Vendor] " .. (it.title or ""), vCollected, vTotal, HeaderCtrl and HeaderCtrl:IsOpen("vendor", vKey), "vendor", { key = vKey, vendor = it })
                                                            if HeaderCtrl and HeaderCtrl:IsOpen("vendor", vKey) then
                                                                for _, vit in ipairs(it.items) do
                                                                    local rit = vit
                                                                    AttachVendorCtx(rit, it)
                                                                    rit = ResolveAchievementDecor(rit)

                                                                    if Passes(rit) then
                                                                        addListItem(64, rit, it)
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end

                                                    for _, it in ipairs(items) do
                                                        if not (it.source and it.source.type == "vendor" and it.items) then
                                                            if ((FiltersSys and FiltersSys.Passes) and FiltersSys:Passes(it, (DB() and DB().ui) or {}, (DB() or {})) or true) then
                                                                addListItem(44, it, nil)
                                                            end
                                                        end
                                                    end
                                                end
                    end
                end
            end
        end

        self.entries = entries
        self.totalHeight = y + PAD_BOTTOM
    end

function f:UpdateVisible()
    if not self.entries then return end
    self:ReleaseAll()

    local ui = (DB() and DB().ui) or {}
    local scrollY = sf:GetVerticalScroll() or 0
    local viewH   = sf:GetHeight() or 0
    local top     = scrollY - 200
    local bottom  = scrollY + viewH + 200

    for _, e in ipairs(self.entries) do
        local eTop    = e.y
        local eBottom = e.y + e.h

        if eBottom >= top and eTop <= bottom then
            local fr = Acquire(
                e.kind == "tile"   and "tile" or
                e.kind == "header" and "header" or
                "list"
            )

            fr._entry = e
            fr:ClearAllPoints()
            fr:SetPoint("TOPLEFT", e.x, -e.y)
            fr:SetSize(e.w, e.h)

            if e.kind == "header" then
                fr:SetHeight(e.h)

                if fr.text then
                    fr.text:SetText(e.label or "")
                end
                if fr.count then
                    fr.count:SetText((e.cur or 0) .. " / " .. (e.max or 0))
                end

                local complete = (e.max and e.max > 0 and (e.cur or 0) >= (e.max or 0))
                if fr.check then
                    if complete then fr.check:Show() else fr.check:Hide() end
                end

                if ProgressBar and e.max and e.max > 0 then
                    if not fr.bar then
                        fr.bar = ProgressBar:Create(fr, 140)
                        fr.bar:SetPoint("BOTTOMLEFT", fr, "BOTTOMLEFT", 12, 2)
                    end
                    fr.bar:Show()
                    fr.bar:SetProgress(e.cur or 0, e.max or 0)
                elseif fr.bar then
                    fr.bar:Hide()
                end

                fr:SetScript("OnClick", function()
                    local entry = fr._entry
                    if not entry or not entry.payload or not entry.payload.key then return end

                    local preScroll = sf:GetVerticalScroll() or 0
                    local anchorY   = entry.y or 0
                    local anchorOff = anchorY - preScroll

                    if not HeaderCtrl or not HeaderCtrl.Toggle then return end
                    HeaderCtrl:Toggle(entry.clickKind, entry.payload.key)
                    self:Render()

                    local newY = anchorY
                    for _, e2 in ipairs(self.entries or {}) do
                        if e2.kind == "header" and e2.payload and e2.payload.key == entry.payload.key then
                            newY = e2.y or newY
                            break
                        end
                    end

                    sf:SetVerticalScroll(ClampScroll(sf, content, newY - anchorOff))
                end)

                fr:SetScript("OnMouseUp", nil)

            elseif e.kind == "tile" then
                local it    = ResolveAchievementDecor(e.it)
                local state = GetStateSafe(it)

                if fr.icon then
                    fr.icon:SetSize(iconSize, iconSize)
                    fr.icon:SetPoint("TOP", 0, -16)
                    fr.icon:SetTexture(GetDecorIcon(it.decorID) or "Interface\\Icons\\INV_Misc_QuestionMark")
                end
                if fr.plate and fr.icon then
                    fr.plate:SetPoint("CENTER", fr.icon)
                    fr.plate:SetSize(iconSize + 8, iconSize + 8)
                end
                if fr.label and fr.icon then
                    fr.label:SetPoint("TOP", fr.icon, "BOTTOM", 0, -6)
                    fr.label:SetWidth(tileW - 20)
                    fr.label:SetText(it.title or "")
                end

local req = GetRequirementLink(it)
if req and fr.req and fr.reqBtn and fr.label then
    fr.req:ClearAllPoints()
    fr.req:SetPoint("TOP", fr.label, "BOTTOM", 0, -2)
    fr.req:SetWidth(tileW - 20)
    fr.req._req = req
    fr.req:SetText(BuildReqDisplay(req, false))
    fr.req:Show()

    fr.reqBtn:ClearAllPoints()
    fr.reqBtn:SetPoint("TOPLEFT", fr.req, "TOPLEFT", -2, 2)
    fr.reqBtn:SetPoint("BOTTOMRIGHT", fr.req, "BOTTOMRIGHT", 2, -2)
    fr.reqBtn:SetFrameStrata(fr:GetFrameStrata())
    fr.reqBtn:SetFrameLevel((fr:GetFrameLevel() or 1) + 10)
    fr.reqBtn:Show()

    fr.reqBtn:SetScript("OnEnter", function()
        fr.req:SetText(BuildReqDisplay(fr.req._req, true))
    end)
    fr.reqBtn:SetScript("OnLeave", function()
        fr.req:SetText(BuildReqDisplay(fr.req._req, false))
    end)
    fr.reqBtn:SetScript("OnClick", function()
        local r = fr.req._req
        if not r then return end
        if r.kind == "quest" then
            ShowWowheadLinks({ { label = "Quest Link", url = BuildWowheadQuestURL(r.id) } })
        else
            ShowWowheadLinks({ { label = "Achievement Link", url = BuildWowheadAchievementURL(r.id) } })
        end
    end)
else
    if fr.req then fr.req:Hide() end
    if fr.reqBtn then fr.reqBtn:Hide() end
end

                if StatusIcon and StatusIcon.Attach then
                    StatusIcon:Attach(fr, state, it)
                end

                if Favorite and Favorite.Attach then
                    local id = GetItemID(it)
                    if fr._fav and fr._fav.SetItemID then
                        fr._fav:SetItemID(id)
                    else
                        if fr._fav then fr._fav:Hide() end
                        fr._fav = Favorite:Attach(fr, id, function() self:Render() end)
                        if fr._fav and fr._fav.SetPoint then
                            fr._fav:SetPoint("TOPLEFT", 6, -6)
                        end
                    end
                end

                if TT and TT.Attach then
                    TT:Attach(fr, it)
                end

                local showDropsBadge = (ui.activeCategory == "Drops") or ((it.source and it.source.type) == "drop")
                if showDropsBadge and DropPanel and DropPanel.AttachBadge then
                    DropPanel:AttachBadge(fr, it, "tile")
                elseif fr._dropBadge then
                    fr._dropBadge:Hide()
                end

                fr:SetScript("OnMouseUp", function(_, btn)
                    local itemID = (it.source and it.source.itemID) or it.vendorItemID or it.id
                    local vendor = it._navVendor or it.vendor
                    if IsAltKeyDown() then
                        local links = {}

                        if it.source and it.source.type == "achievement" then
                            local aid = it.source.achievementID or it.source.id
                            if aid then
                                links[#links + 1] = { label = "Achievement Link", url = BuildWowheadAchievementURL(aid) }
                            end
                        elseif it.source and it.source.type == "quest" then
                            local qid = it.source.questID or it.source.id
                            if qid then
                                links[#links + 1] = { label = "Quest Link", url = BuildWowheadQuestURL(qid) }
                            end
                        end

                        if itemID then
                            links[#links + 1] = { label = "Item Link", url = BuildWowheadItemURL(itemID) }
                        end

                        if #links > 0 then
                            ShowWowheadLinks(links)
                        end
                        return
                    end

                    if btn == "LeftButton" and IsControlKeyDown() then
                        if it.source and it.source.type == "achievement" then
                            OpenAchievementFrameToAchievement(it.source.achievementID or it.source.id)
                        elseif it.source and it.source.type == "quest" then
                            ShowQuest(it.source.id)
                        end
                        return
                    end

                    if btn == "RightButton" then
                        if Navigation and vendor then
                            Navigation:AddWaypoint(vendor, vendor)
                        end
                        return
                    end
                    if btn == "LeftButton" and itemID then
                        DressUpItemLink("item:" .. itemID)
                    end
                end)

            else
                local it    = ResolveAchievementDecor(e.it)
                local state = GetStateSafe(it)

                if fr.text then
                    fr.text:SetText(it.title or "")
                end

                local req = GetRequirementLink(it)
if req and fr.req and fr.reqBtn then
    fr.req:Show()

    local maxW = (e.w or 0) - 72
    fr.req:SetWidth(maxW)

    fr.req._req = req
    fr.req:SetText(BuildReqDisplay(req, false))

    fr.reqBtn:ClearAllPoints()
    fr.reqBtn:SetPoint("TOPLEFT", fr.req, "TOPLEFT", -2, 2)
    fr.reqBtn:SetPoint("BOTTOMRIGHT", fr.req, "BOTTOMRIGHT", 2, -2)
    fr.reqBtn:SetFrameStrata(fr:GetFrameStrata())
    fr.reqBtn:SetFrameLevel((fr:GetFrameLevel() or 1) + 10)
    fr.reqBtn:Show()

    fr.reqBtn:SetScript("OnEnter", function()
        fr.req:SetText(BuildReqDisplay(fr.req._req, true))
    end)
    fr.reqBtn:SetScript("OnLeave", function()
        fr.req:SetText(BuildReqDisplay(fr.req._req, false))
    end)
    fr.reqBtn:SetScript("OnClick", function()
        local r = fr.req._req
        if not r then return end
        if r.kind == "quest" then
            ShowWowheadLinks({ { label = "Quest Link", url = BuildWowheadQuestURL(r.id) } })
        else
            ShowWowheadLinks({ { label = "Achievement Link", url = BuildWowheadAchievementURL(r.id) } })
        end
    end)
else
    if fr.req then fr.req:Hide() end
    if fr.reqBtn then fr.reqBtn:Hide() end
end


                if StatusIcon and StatusIcon.Attach then
                    StatusIcon:Attach(fr, state, it)
                end

                if Favorite and Favorite.Attach then
                    local id = GetItemID(it)
                    if fr._fav and fr._fav.SetItemID then
                        fr._fav:SetItemID(id)
                    else
                        if fr._fav then fr._fav:Hide() end
                        fr._fav = Favorite:Attach(fr, id, function() self:Render() end)
                        if fr._fav and fr._fav.SetPoint then
                            fr._fav:SetPoint("TOPLEFT", 6, -6)
                        end
                    end
                end

                if TT and TT.Attach then
                    TT:Attach(fr, it)
                end

                local showDropsBadge = (ui.activeCategory == "Drops") or ((it.source and it.source.type) == "drop")
                if showDropsBadge and DropPanel and DropPanel.AttachBadge then
                    DropPanel:AttachBadge(fr, it, "list")
                elseif fr._dropBadge then
                    fr._dropBadge:Hide()
                end

                fr:SetScript("OnMouseUp", function(_, btn)
                    local itemID = (it.source and it.source.itemID) or it.vendorItemID or it.id
                    local vendor = it._navVendor or it.vendor

                    if IsAltKeyDown() then
                        local links = {}

                        if it.source and it.source.type == "achievement" then
                            local aid = it.source.achievementID or it.source.id
                            if aid then
                                links[#links + 1] = { label = "Achievement Link", url = BuildWowheadAchievementURL(aid) }
                            end
                        elseif it.source and it.source.type == "quest" then
                            local qid = it.source.questID or it.source.id
                            if qid then
                                links[#links + 1] = { label = "Quest Link", url = BuildWowheadQuestURL(qid) }
                            end
                        end

                        if itemID then
                            links[#links + 1] = { label = "Item Link", url = BuildWowheadItemURL(itemID) }
                        end

                        if #links > 0 then
                            ShowWowheadLinks(links)
                        end
                        return
                    end

                    if btn == "LeftButton" and IsControlKeyDown() then
                        if it.source and it.source.type == "achievement" then
                            OpenAchievementFrameToAchievement(it.source.achievementID or it.source.id)
                        elseif it.source and it.source.type == "quest" then
                            ShowQuest(it.source.id)
                        end
                        return
                    end

                    if btn == "RightButton" then
                        if Navigation and vendor then
                            Navigation:AddWaypoint(vendor, vendor)
                        end
                        return
                    end

                    if btn == "LeftButton" and itemID then
                        DressUpItemLink("item:" .. itemID)
                    end
                end)
            end
        end
    end

    content:SetHeight(self.totalHeight or 0)
end

    function f:Render()
        self:RebuildEntries()
        content:SetHeight(self.totalHeight or 0)
        self:UpdateVisible()
    end

    f.scrollFrame = sf
    f.content = content
    return f
end

return View
