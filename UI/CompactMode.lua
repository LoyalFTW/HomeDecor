local ADDON, NS = ...
NS.UI = NS.UI or {}

local CM = {}
NS.UI.CompactMode = CM

local CreateFrame      = _G.CreateFrame
local UIParent         = _G.UIParent
local UISpecialFrames  = _G.UISpecialFrames
local GameTooltip      = _G.GameTooltip
local C_HousingCatalog = _G.C_HousingCatalog
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT

local floor  = math.floor
local max    = math.max
local min    = math.min
local tinsert = table.insert

local function T()
    return NS.UI.Theme and NS.UI.Theme.colors or {}
end

local function Controls()
    return NS.UI.Controls
end

local function Bd(f, bg, bdr)
    local C = Controls()
    if C and C.Backdrop then C:Backdrop(f, bg, bdr) end
end

local function Hov(b, bg, hv)
    local C = Controls()
    if C and C.ApplyHover then C:ApplyHover(b, bg, hv) end
end

local function FS(p, tmpl)
    return p:CreateFontString(nil, "OVERLAY", tmpl or "GameFontNormal")
end

local ROW_H = 22
local MIN_W, MAX_W = 320, 680
local MIN_H, MAX_H = 300, 900

local CATS = { "Achievements", "Quests", "Vendors", "Drops", "Professions", "PVP" }

local CAT_LABEL = {
    Achievements = "Achievements",
    Quests       = "Quests",
    Vendors      = "Vendors",
    Drops        = "Drops",
    Professions  = "Professions",
    PVP          = "PvP",
}

local SRC_TAG = {
    vendor      = "Vendor",
    quest       = "Quest",
    achievement = "Ach",
    drop        = "Drop",
    profession  = "Craft",
    pvp         = "PvP",
}

local EXP_SHORT = {
    Classic           = "Vanilla",
    BurningCrusade    = "TBC",
    Wrath             = "WotLK",
    Cataclysm         = "Cata",
    Pandaria          = "MoP",
    MistsOfPandaria   = "MoP",
    Warlords          = "WoD",
    WarlordsOfDraenor = "WoD",
    Legion            = "Legion",
    BattleForAzeroth  = "BfA",
    Shadowlands       = "SL",
    Dragonflight      = "DF",
    WarWithin         = "TWW",
    TheWarWithin      = "TWW",
    Midnight          = "Mid",
}

local EXP_ORDER = { "Mid", "TWW", "DF", "SL", "BfA", "Legion", "WoD", "MoP", "Cata", "WotLK", "TBC", "Vanilla" }

local EXP_RANK = {
    Classic = 1, BurningCrusade = 2, Wrath = 3, Cataclysm = 4,
    MistsOfPandaria = 5, Pandaria = 5, Warlords = 6, WarlordsOfDraenor = 6,
    Legion = 7, BattleForAzeroth = 8, Shadowlands = 9, Dragonflight = 10,
    WarWithin = 11, TheWarWithin = 11, Midnight = 12,
}

local NameCache = {}

local function GetDecorName(decorID)
    if not decorID then return nil end

    if NameCache[decorID] ~= nil then
        return NameCache[decorID] or nil
    end

    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then
        return nil
    end

    local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
    local n    = info and info.name
    if type(n) == "string" and n ~= "" then
        NameCache[decorID] = n
        return n
    end

    local Boot = NS.Systems and NS.Systems.HousingBootstrap
    if Boot and Boot.ready then
        NameCache[decorID] = false
    end
    return nil
end

local function GetItemIcon(itemID)
    if not itemID then return nil end
    if _G.C_Item and _G.C_Item.GetItemIconByID then
        local ok, icon = pcall(_G.C_Item.GetItemIconByID, itemID)
        if ok and icon then return icon end
    end
    if _G.GetItemIcon then
        local ok, icon = pcall(_G.GetItemIcon, itemID)
        if ok and icon then return icon end
    end
    return nil
end

local function GetEntryIcon(entry)
    if not entry then return "Interface\\Icons\\INV_Misc_QuestionMark" end

    local item = entry.item or entry
    local src = item and item.source
    local itemID = item and (item.itemID or item.vendorItemID or item.id or (src and src.itemID))
    local icon = GetItemIcon(itemID)
    if icon then return icon end

    local VD = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
    if VD and VD.GetDecorIcon then
        icon = VD.GetDecorIcon(entry.decorID or (item and item.decorID))
        if icon then return icon end
    end

    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function GetPreviewSourceText(entry)
    if not entry then return "" end

    local item = entry.item or entry
    local src = item and item.source or {}
    local parts = {}

    if src.type == "vendor" then
        parts[#parts + 1] = "Vendor"
    elseif src.type == "drop" then
        parts[#parts + 1] = "Drop"
    elseif src.type == "quest" then
        parts[#parts + 1] = "Quest"
    elseif src.type == "achievement" then
        parts[#parts + 1] = "Achievement"
    elseif src.type == "profession" then
        parts[#parts + 1] = "Profession"
    elseif src.type == "pvp" then
        parts[#parts + 1] = "PvP"
    end

    local zone = src.zone or entry.zone
    if zone and zone ~= "" then
        parts[#parts + 1] = zone
    end

    local rawExp = entry.exp or item._expansion
    local exp = (rawExp and rawExp ~= "") and (EXP_SHORT[rawExp] or rawExp:sub(1, 4)) or ""
    if exp and exp ~= "" then
        parts[#parts + 1] = exp
    end

    return table.concat(parts, "  •  ")
end

local function GetPreviewSummaryText(entry)
    if not entry then return "" end

    local item = entry.item or entry
    local src = item and item.source or {}
    local parts = {}

    if src.type == "vendor" then
        parts[#parts + 1] = "Vendor"
    elseif src.type == "drop" then
        parts[#parts + 1] = "Drop"
    elseif src.type == "quest" then
        parts[#parts + 1] = "Quest"
    elseif src.type == "achievement" then
        parts[#parts + 1] = "Achievement"
    elseif src.type == "profession" then
        parts[#parts + 1] = "Profession"
    elseif src.type == "pvp" then
        parts[#parts + 1] = "PvP"
    end

    local zone = src.zone or entry.zone
    if zone and zone ~= "" then
        parts[#parts + 1] = zone
    end

    local rawExp = entry.exp or item._expansion
    local exp = (rawExp and rawExp ~= "") and (EXP_SHORT[rawExp] or rawExp:sub(1, 4)) or ""
    if exp and exp ~= "" then
        parts[#parts + 1] = exp
    end

    return table.concat(parts, "  |  ")
end

local function GetPreviewCostText(entry)
    if not entry then return nil end

    local item = entry.item or entry
    local src = item and item.source or {}
    local currencyAmount = tonumber(src.currency or src.currencyText or src.costText)
    local currencyTypeID = src.currencytype or src.currencyType or src.currencyID
    local goldCost = tonumber(src.cost)

    if currencyAmount and currencyTypeID then
        if tostring(currencyTypeID) == "gold" then
            return "Cost: " .. tostring(currencyAmount) .. "g"
        end

        local currencyName = nil
        if type(currencyTypeID) == "string" and not tonumber(currencyTypeID) then
            currencyName = currencyTypeID
        elseif _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCurrencyInfo then
            local ok, info = pcall(_G.C_CurrencyInfo.GetCurrencyInfo, tonumber(currencyTypeID))
            if ok and info and info.name then
                currencyName = info.name
            end
        end

        return "Cost: " .. tostring(currencyAmount) .. " " .. (currencyName or "Currency")
    end

    if goldCost and goldCost > 0 then
        return "Cost: " .. tostring(goldCost) .. "g"
    end

    return nil
end

local function GetPreviewRequirementText(entry)
    if not entry then return nil end

    local item = entry.item or entry
    local R = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Requirements
    if not R then return nil end

    local parts = {}
    if R.GetRequirementLink and R.BuildReqDisplay then
        local req = R.GetRequirementLink(item)
        if req then
            parts[#parts + 1] = R.BuildReqDisplay(req, false)
        end
    end
    if R.GetRepRequirement and R.BuildRepDisplay then
        local rep = R.GetRepRequirement(item)
        if rep then
            parts[#parts + 1] = R.BuildRepDisplay(rep, false)
        end
    end

    if #parts == 0 then return nil end
    return table.concat(parts, "\n")
end

local function IsCollected(it)
    if not it then return false end
    local Col = NS.Systems and NS.Systems.Collection
    if not Col or not Col.IsCollected then return false end
    local ok, r = pcall(Col.IsCollected, Col, it)
    if ok and type(r) == "boolean" then return r end
    local id = it.decorID or (it.source and (it.source.itemID or it.source.id))
    if id then
        local ok2, r2 = pcall(Col.IsCollected, Col, id)
        if ok2 and type(r2) == "boolean" then return r2 end
    end
    return false
end

local function GetSrcTag(it)
    local s = it and it.source
    return (s and SRC_TAG[s.type or ""]) or ""
end

local function GetExpShort(exp)
    if not exp or exp == "" then return "" end
    return EXP_SHORT[exp] or exp:sub(1, 4)
end

local function ScanNode(node, exp, out, seen)
    if type(node) ~= "table" then return end

    if node.decorID then
        local tag = GetSrcTag(node)
        local key = tostring(node.decorID) .. ":" .. tag
        if not seen[key] then
            seen[key] = true
            out[#out + 1] = {
                decorID   = node.decorID,
                exp       = exp or node._expansion or "",
                srcTag    = tag,
                item      = node,
                collected = false,
                name      = "",
            }
        end
        return
    end

    if node.items and type(node.items) == "table" then
        for _, leaf in ipairs(node.items) do
            ScanNode(leaf, exp, out, seen)
        end
        return
    end

    if node[1] then
        for _, child in ipairs(node) do
            ScanNode(child, exp, out, seen)
        end
        return
    end

    for k, v in pairs(node) do
        if type(v) == "table" then
            ScanNode(v, exp or k, out, seen)
        end
    end
end

local function BuildVendorGroupedList()
    local out = {}
    local vendorsData = NS.Data and NS.Data.Vendors
    if type(vendorsData) ~= "table" then return out end

    local expOrder = {}
    for exp in pairs(vendorsData) do expOrder[#expOrder + 1] = exp end
    table.sort(expOrder, function(a, b)
        return (EXP_RANK[a] or 999) < (EXP_RANK[b] or 999)
    end)

    for _, exp in ipairs(expOrder) do
        local expData = vendorsData[exp]
        if type(expData) == "table" then
            local zones = {}
            for zone in pairs(expData) do zones[#zones + 1] = zone end
            table.sort(zones, function(a, b) return a:lower() < b:lower() end)

            for _, zone in ipairs(zones) do
                local vendorList = expData[zone]
                if type(vendorList) == "table" then
                    for _, vendorNode in ipairs(vendorList) do
                        if type(vendorNode) == "table"
                           and vendorNode.source
                           and vendorNode.source.type == "vendor"
                           and type(vendorNode.items) == "table"
                           and #vendorNode.items > 0 then

                            local npcID = tonumber(vendorNode.source.id)
                            local vKey  = exp .. ":" .. zone .. ":" .. tostring(npcID or "?")
                            out[#out + 1] = {
                                kind        = "vendorHeader",
                                npcID       = npcID,
                                _key        = vKey,
                                title       = "",
                                zone        = zone,
                                faction     = vendorNode.source.faction,
                                exp         = exp,
                                _vendorNode = vendorNode,
                            }

                            local seenInVendor = {}
                            for _, leaf in ipairs(vendorNode.items) do
                                if type(leaf) == "table" and leaf.decorID then
                                    local dkey = tostring(leaf.decorID)
                                    if not seenInVendor[dkey] then
                                        seenInVendor[dkey] = true
                                        local VD = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
                                        if VD and VD.AttachVendorCtx then
                                            VD.AttachVendorCtx(leaf, vendorNode)
                                        end
                                        out[#out + 1] = {
                                            kind      = "item",
                                            decorID   = leaf.decorID,
                                            exp       = exp,
                                            srcTag    = "Vendor",
                                            item      = leaf,
                                            collected = false,
                                            name      = "",
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return out
end

local function BuildRawList(category)
    if category == "Vendors" then return BuildVendorGroupedList() end
    local out, seen = {}, {}
    local catData = NS.Data and NS.Data[category]
    if type(catData) == "table" then
        ScanNode(catData, nil, out, seen)
    end
    return out
end

local function SortList(list, vendorGrouped)
    if vendorGrouped then return end
    table.sort(list, function(a, b)
        if a.collected ~= b.collected then return not a.collected end
        local na = a.name ~= "" and a.name or ("~" .. a.decorID)
        local nb = b.name ~= "" and b.name or ("~" .. b.decorID)
        return na:lower() < nb:lower()
    end)
end

local function ApplyFilters(items, q, collFilter, expFilter, vendorGrouped, vendorOpenTbl)
    q = (q and q ~= "") and q:lower() or nil
    local filterExp  = expFilter and expFilter ~= "all"
    local hasSearch  = q ~= nil

    if vendorGrouped then
        local out = {}
        local i = 1
        while i <= #items do
            local entry = items[i]
            if entry.kind == "vendorHeader" then
                if filterExp and GetExpShort(entry.exp) ~= expFilter then
                    i = i + 1
                    while i <= #items and items[i].kind ~= "vendorHeader" do
                        i = i + 1
                    end
                else
                    local hdrEntry  = entry
                    local isOpen    = hasSearch or (vendorOpenTbl and vendorOpenTbl[hdrEntry._key])
                    local hasMatch  = false
                    i = i + 1
                    local itemStart = i
                    while i <= #items and items[i].kind ~= "vendorHeader" do
                        local it   = items[i]
                        local keep = true
                        if   collFilter == "need" and     it.collected then keep = false
                        elseif collFilter == "have" and not it.collected then keep = false
                        end
                        if keep and q then
                            local name = (it.name ~= "" and it.name) or tostring(it.decorID)
                            if not name:lower():find(q, 1, true) then keep = false end
                        end
                        if keep then hasMatch = true end
                        i = i + 1
                    end
                    local itemEnd = i - 1
                    if hasMatch then
                        out[#out + 1] = hdrEntry
                        if isOpen then
                            for j = itemStart, itemEnd do
                                local it   = items[j]
                                local keep = true
                                if   collFilter == "need" and     it.collected then keep = false
                                elseif collFilter == "have" and not it.collected then keep = false
                                end
                                if keep and q then
                                    local name = (it.name ~= "" and it.name) or tostring(it.decorID)
                                    if not name:lower():find(q, 1, true) then keep = false end
                                end
                                if keep then out[#out + 1] = it end
                            end
                        end
                    end
                end
            else
                i = i + 1
            end
        end
        return out
    end

    if not q and (not collFilter or collFilter == "all") and not filterExp then return items end
    local out = {}
    for _, it in ipairs(items) do
        local keep = true
        if   collFilter == "need" and     it.collected then keep = false
        elseif collFilter == "have" and not it.collected then keep = false
        end
        if keep and filterExp then
            if GetExpShort(it.exp) ~= expFilter then keep = false end
        end
        if keep and q then
            local name = (it.name ~= "" and it.name) or tostring(it.decorID)
            if not name:lower():find(q, 1, true) then keep = false end
        end
        if keep then out[#out + 1] = it end
    end
    return out
end

local function CreateRow(parent)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(ROW_H)
    row:RegisterForClicks("AnyUp")

    local accent = row:CreateTexture(nil, "BORDER")
    accent:SetWidth(2)
    accent:SetPoint("TOPLEFT",    row, "TOPLEFT",    0,  0)
    accent:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0,  0)
    accent:Hide()
    row._accent = accent

    local chk = row:CreateTexture(nil, "OVERLAY")
    chk:SetSize(11, 11)
    chk:SetPoint("LEFT", 6, 0)
    chk:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    chk:Hide()
    row._chk = chk

    local dot = row:CreateTexture(nil, "OVERLAY")
    dot:SetSize(6, 6)
    dot:SetPoint("LEFT", 8, 0)
    dot:Hide()
    row._dot = dot

    local iconBG = CreateFrame("Frame", nil, row, "BackdropTemplate")
    iconBG:SetSize(18, 18)
    iconBG:SetPoint("LEFT", row, "LEFT", 22, 0)
    Bd(iconBG, { 0.03, 0.03, 0.04, 0.95 }, { 0.18, 0.18, 0.20, 1 })
    row._iconBG = iconBG

    local icon = iconBG:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    if icon.SetTexCoord then icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    icon:Hide()
    row._icon = icon

    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameFS:SetPoint("LEFT",  row, "LEFT",  46, 0)
    nameFS:SetPoint("RIGHT", row, "RIGHT", -98, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    nameFS:SetMaxLines(1)
    nameFS:SetFont(STANDARD_TEXT_FONT, 11, "")
    row._nameFS = nameFS

    local tagFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tagFS:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    tagFS:SetWidth(90)
    tagFS:SetJustifyH("RIGHT")
    tagFS:SetFont(STANDARD_TEXT_FONT, 10, "")
    row._tagFS = tagFS

    local locBtn = CreateFrame("Button", nil, row)
    locBtn:SetSize(22, ROW_H)
    locBtn:SetPoint("RIGHT", row, "RIGHT", -98, 0)
    locBtn:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
    local locFS = locBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    locFS:SetAllPoints()
    locFS:SetJustifyH("CENTER")
    locFS:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    locFS:SetText("Loc")
    locFS:SetTextColor(1, 0.82, 0, 0.85)
    locBtn:SetScript("OnEnter", function(self)
        locFS:SetTextColor(1, 1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Drop Locations", 1, 0.82, 0)
        GameTooltip:AddLine("Click to see where this item drops from.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    locBtn:SetScript("OnLeave", function(self)
        locFS:SetTextColor(1, 0.82, 0, 0.85)
        GameTooltip:Hide()
    end)
    locBtn:SetScript("OnClick", function(self)
        local DP = NS.UI and NS.UI.DropPanel
        if DP and DP.ShowForItem and self._item then
            DP:ShowForItem(self._item, row)
        end
    end)
    locBtn:Hide()
    row._locBtn = locBtn

    row:Hide()
    return row
end

local function MakeRowPool(parent, poolSize)
    local pool = {}
    for i = 1, poolSize do
        pool[i] = CreateRow(parent)
    end
    return pool
end

local frame     

function CM:IsShown() return frame ~= nil and frame:IsShown() end

function CM:Toggle()
    if not frame then self:_Build() end
    if frame:IsShown() then frame:Hide() else frame:Show() end
end

function CM:Show()
    if not frame then self:_Build() end
    frame:Show()
end

function CM:Hide()
    if frame then frame:Hide() end
end

function CM:_Build()
    if frame then return end

    local col      = T()
    local accent   = col.accent    or { 1, 0.82, 0.2, 1 }
    local border   = col.border    or { 0.22, 0.22, 0.24, 1 }
    local panel    = col.panel     or { 0.06, 0.06, 0.08, 0.97 }
    local header   = col.header    or { 0.09, 0.09, 0.11, 1 }
    local hover    = col.hover     or { 0.16, 0.16, 0.20, 1 }
    local rowBg    = col.row       or { 0.06, 0.06, 0.09, 1 }
    local rowAlt   = col.panel     or { 0.09, 0.09, 0.11, 1 }
    local muted    = col.textMuted or { 0.65, 0.65, 0.68, 1 }
    local success  = col.success   or { 0.30, 0.80, 0.40, 1 }
    local textCol  = col.text      or { 0.92, 0.92, 0.92, 1 }

    frame = CreateFrame("Frame", "HomeDecorCompactFrame", UIParent, "BackdropTemplate")
    Bd(frame, panel, border)
    frame:SetSize(420, 580)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(MIN_W, MIN_H, MAX_W, MAX_H)
    end
    frame:Hide()

    if type(UISpecialFrames) == "table" then
        tinsert(UISpecialFrames, "HomeDecorCompactFrame")
    end

    local hdr = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    Bd(hdr, header, border)
    do
        local C = Controls()
        if C and C.ApplyHeaderTexture then C:ApplyHeaderTexture(hdr, false) end
    end
    hdr:SetPoint("TOPLEFT",  frame, "TOPLEFT",  6, -6)
    hdr:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
    hdr:SetHeight(30)
    hdr:EnableMouse(true)
    hdr:RegisterForDrag("LeftButton")
    hdr:SetScript("OnDragStart", function() frame:StartMoving() end)
    hdr:SetScript("OnDragStop",  function()
        frame:StopMovingOrSizing()
        local pfFrame = frame._previewFrame
        if pfFrame and pfFrame:IsShown() then
            pfFrame:ClearAllPoints()
            local uiW = UIParent:GetWidth() or 1280
            local fl  = frame:GetLeft() or 0
            local fw  = frame:GetWidth() or MIN_W
            local pw  = pfFrame:GetWidth() or 360
            if (fl + fw + 12 + pw) <= uiW then
                pfFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, 0)
            else
                pfFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", -12, 0)
            end
        end
    end)

    local titleFS = FS(hdr, "GameFontNormalLarge")
    titleFS:SetPoint("LEFT", 10, 0)
    titleFS:SetText("HomeDecor")
    titleFS:SetTextColor(accent[1], accent[2], accent[3], 1)
    titleFS:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")

    local subtitleFS = FS(hdr, "GameFontNormalSmall")
    subtitleFS:SetPoint("LEFT", titleFS, "RIGHT", 6, -1)
    subtitleFS:SetText("- Compact")
    subtitleFS:SetTextColor(1, 1, 1, 0.35)
    subtitleFS:SetFont(STANDARD_TEXT_FONT, 10, "")

    local progFS = FS(hdr, "GameFontNormalSmall")
    progFS:SetPoint("LEFT", subtitleFS, "RIGHT", 10, 0)
    progFS:SetTextColor(1, 1, 1, 0.40)
    progFS:SetFont(STANDARD_TEXT_FONT, 10, "")

    local closeBtn = CreateFrame("Button", nil, hdr, "BackdropTemplate")
    Bd(closeBtn, panel, border)
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("RIGHT", -5, 0)
    Hov(closeBtn, panel, hover)
    local closeX = closeBtn:CreateTexture(nil, "OVERLAY")
    closeX:SetSize(12, 12)
    closeX:SetPoint("CENTER")
    closeX:SetTexture("Interface\\Buttons\\UI-StopButton")
    closeX:SetVertexColor(accent[1], accent[2], accent[3], 1)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    local expandBtn = CreateFrame("Button", nil, hdr, "BackdropTemplate")
    Bd(expandBtn, panel, border)
    expandBtn:SetSize(78, 22)
    expandBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)
    Hov(expandBtn, panel, hover)
    local expandFS = FS(expandBtn)
    expandFS:SetAllPoints()
    expandFS:SetJustifyH("CENTER")
    expandFS:SetText("[+]  Full View")
    expandFS:SetFont(STANDARD_TEXT_FONT, 11, "")
    expandFS:SetTextColor(accent[1], accent[2], accent[3], 1)
    expandBtn:SetScript("OnClick", function()
        frame:Hide()
        local db2 = NS.db and NS.db.profile
        if db2 and db2.ui then db2.ui.compactMode = false end
        local UI = NS.UI
        if UI and UI.MainFrame and UI.MainFrame:IsShown() then return end
        if UI and UI.ToggleMainFrame then UI:ToggleMainFrame() end
    end)
    expandBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Full View", 1, 1, 1)
        GameTooltip:AddLine("Switch back to the full HomeDecor browser.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    expandBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local tabBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    Bd(tabBar, panel, border)
    tabBar:SetPoint("TOPLEFT",  hdr, "BOTTOMLEFT",  0, -3)
    tabBar:SetPoint("TOPRIGHT", hdr, "BOTTOMRIGHT", 0, -3)
    tabBar:SetHeight(24)

    local tabs           = {}
    local activeCategory = "Achievements"
    local Refresh        

    local function LayoutTabs()
        local w  = tabBar:GetWidth() or 420
        local tw = w / #CATS
        for i, tab in ipairs(tabs) do
            tab:ClearAllPoints()
            tab:SetPoint("TOPLEFT",     tabBar, "TOPLEFT",    (i - 1) * tw, 0)
            tab:SetPoint("BOTTOMRIGHT", tabBar, "BOTTOMLEFT",  i * tw,       0)
        end
    end

    local function StyleTabs()
        for _, tab in ipairs(tabs) do
            local sel = (tab._cat == activeCategory)
            local C = Controls()
            if C and C.SetSelected then
                C:SetSelected(tab, sel, panel, rowBg)
            end
            tab._fs:SetTextColor(
                sel and 1                or accent[1],
                sel and 0.92             or accent[2],
                sel and 0.92             or accent[3],
                sel and 1                or 0.78
            )
        end
    end

    for i, cat in ipairs(CATS) do
        local tab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
        Bd(tab, panel, border)
        Hov(tab, panel, hover)
        tab._cat = cat
        local fs = FS(tab, "GameFontNormalSmall")
        fs:SetAllPoints()
        fs:SetJustifyH("CENTER")
        fs:SetText(CAT_LABEL[cat] or cat)
        fs:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        tab._fs = fs
        tab:SetScript("OnClick", function()
            if activeCategory == cat then return end
            activeCategory = cat
            expansionFilter = "all"
            StyleTabs()
            if Refresh then Refresh(true) end
        end)
        tabs[i] = tab
    end

    tabBar:SetScript("OnSizeChanged", LayoutTabs)

    local searchRow = CreateFrame("Frame", nil, frame)
    searchRow:SetPoint("TOPLEFT",  tabBar, "BOTTOMLEFT",  0, -3)
    searchRow:SetPoint("TOPRIGHT", tabBar, "BOTTOMRIGHT", 0, -3)
    searchRow:SetHeight(24)

    local searchBg = CreateFrame("Frame", nil, searchRow, "BackdropTemplate")
    Bd(searchBg, panel, border)
    searchBg:SetPoint("TOPLEFT",     searchRow, "TOPLEFT",     0, 0)
    searchBg:SetPoint("BOTTOMRIGHT", searchRow, "BOTTOMRIGHT", -28, 0)

    local searchBox = CreateFrame("EditBox", nil, searchBg)
    searchBox:SetAllPoints()
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject(_G.GameFontHighlightSmall)
    searchBox:SetTextInsets(26, 8, 0, 0)
    searchBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)

    local srchIcon = searchBg:CreateTexture(nil, "OVERLAY")
    srchIcon:SetSize(13, 13)
    srchIcon:SetPoint("LEFT", 6, 0)
    srchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
    srchIcon:SetVertexColor(accent[1], accent[2], accent[3], 0.60)

    local phFS = searchBg:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    phFS:SetPoint("LEFT", 26, 0)
    phFS:SetText("Search...")
    phFS:SetTextColor(1, 1, 1, 0.25)

    local clearSB = CreateFrame("Button", nil, searchRow, "BackdropTemplate")
    Bd(clearSB, panel, border)
    clearSB:SetSize(26, 24)
    clearSB:SetPoint("LEFT", searchBg, "RIGHT", 2, 0)
    Hov(clearSB, panel, hover)
    local clearX = clearSB:CreateTexture(nil, "OVERLAY")
    clearX:SetSize(11, 11)
    clearX:SetPoint("CENTER")
    clearX:SetTexture("Interface\\Buttons\\UI-StopButton")
    clearX:SetVertexColor(accent[1], accent[2], accent[3], 0.80)
    clearSB:Hide()

    searchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText() or ""
        phFS:SetShown(txt == "" and not self:HasFocus())
        clearSB:SetShown(txt ~= "")
        if Refresh then Refresh(false) end
    end)
    searchBox:SetScript("OnEditFocusGained", function() phFS:Hide() end)
    searchBox:SetScript("OnEditFocusLost",   function()
        phFS:SetShown((searchBox:GetText() or "") == "")
    end)
    clearSB:SetScript("OnClick", function()
        searchBox:SetText("")
        searchBox:ClearFocus()
    end)

    local CFILTS       = { "all", "need", "have" }
    local CFILT_LABELS = { all = "All", need = "Need", have = "Have" }
    local collectedFilter = "all"
    local filterBtns      = {}

    local filterBar = CreateFrame("Frame", nil, frame)
    filterBar:SetPoint("TOPLEFT",  searchRow, "BOTTOMLEFT",  0, -3)
    filterBar:SetPoint("TOPRIGHT", searchRow, "BOTTOMRIGHT", 0, -3)
    filterBar:SetHeight(22)

    local function StyleFilterBtns()
        for _, btn in ipairs(filterBtns) do
            local sel = (btn._filt == collectedFilter)
            local C2  = Controls()
            if C2 and C2.Backdrop then
                C2:Backdrop(btn, sel and header or panel, border)
            end
            btn._fs:SetTextColor(
                sel and 1    or accent[1],
                sel and 0.92 or accent[2],
                sel and 0.92 or accent[3],
                sel and 1    or 0.55
            )
        end
    end

    local function LayoutFilterBtns()
        local w  = filterBar:GetWidth() or 420
        local tw = w / #CFILTS
        for i, btn in ipairs(filterBtns) do
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT",     filterBar, "TOPLEFT",    (i - 1) * tw, 0)
            btn:SetPoint("BOTTOMRIGHT", filterBar, "BOTTOMLEFT",  i * tw,       0)
        end
    end

    for i, filt in ipairs(CFILTS) do
        local btn = CreateFrame("Button", nil, filterBar, "BackdropTemplate")
        Bd(btn, panel, border)
        Hov(btn, panel, hover)
        btn._filt = filt
        local fs = FS(btn, "GameFontNormalSmall")
        fs:SetAllPoints()
        fs:SetJustifyH("CENTER")
        fs:SetText(CFILT_LABELS[filt])
        fs:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        btn._fs = fs
        btn:SetScript("OnClick", function()
            if collectedFilter == filt then return end
            collectedFilter = filt
            StyleFilterBtns()
            if Refresh then Refresh(false) end
        end)
        filterBtns[i] = btn
    end
    filterBar:SetScript("OnSizeChanged", LayoutFilterBtns)

    local expansionFilter = "all"
    local expActiveList   = {}
    local expBtnPool      = {}

    local expBar = CreateFrame("Frame", nil, frame)
    expBar:SetPoint("TOPLEFT",  filterBar, "BOTTOMLEFT",  0, -3)
    expBar:SetPoint("TOPRIGHT", filterBar, "BOTTOMRIGHT", 0, -3)
    expBar:SetHeight(20)

    local function StyleExpBtns()
        for _, code in ipairs({ "all", unpack(expActiveList) }) do
            local btn = expBtnPool[code]
            if btn and btn:IsShown() then
                local sel = (expansionFilter == code)
                local C2  = Controls()
                if C2 and C2.Backdrop then
                    C2:Backdrop(btn, sel and header or panel, border)
                end
                btn._fs:SetTextColor(
                    sel and 1    or accent[1],
                    sel and 0.92 or accent[2],
                    sel and 0.92 or accent[3],
                    sel and 1    or 0.55
                )
            end
        end
    end

    local function LayoutExpBtns()
        local all = { "all" }
        for _, c in ipairs(expActiveList) do all[#all + 1] = c end
        local n  = #all
        if n == 0 then return end
        local w  = expBar:GetWidth() or 420
        local tw = w / n
        for i, code in ipairs(all) do
            local btn = expBtnPool[code]
            if btn then
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT",     expBar, "TOPLEFT",    (i - 1) * tw, 0)
                btn:SetPoint("BOTTOMRIGHT", expBar, "BOTTOMLEFT",  i * tw,       0)
                btn:Show()
            end
        end
        for code, btn in pairs(expBtnPool) do
            local inList = (code == "all")
            if not inList then
                for _, c in ipairs(expActiveList) do if c == code then inList = true; break end end
            end
            if not inList then btn:Hide() end
        end
    end

    local function GetExpBtn(code, label)
        if expBtnPool[code] then return expBtnPool[code] end
        local btn = CreateFrame("Button", nil, expBar, "BackdropTemplate")
        Bd(btn, panel, border)
        Hov(btn, panel, hover)
        local fs = FS(btn, "GameFontNormalSmall")
        fs:SetAllPoints()
        fs:SetJustifyH("CENTER")
        fs:SetText(label or code)
        fs:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
        btn._fs  = fs
        btn._exp = code
        btn:SetScript("OnClick", function()
            if expansionFilter == code then return end
            expansionFilter = code
            StyleExpBtns()
            if Refresh then Refresh(false) end
        end)
        expBtnPool[code] = btn
        return btn
    end

    local function RebuildExpansionBtns(presentSet)
        expActiveList = {}
        for _, code in ipairs(EXP_ORDER) do
            if presentSet[code] then
                expActiveList[#expActiveList + 1] = code
                GetExpBtn(code, code)
            end
        end
        GetExpBtn("all", "All")

        if expansionFilter ~= "all" then
            local ok = false
            for _, c in ipairs(expActiveList) do if c == expansionFilter then ok = true; break end end
            if not ok then expansionFilter = "all" end
        end

        StyleExpBtns()
        LayoutExpBtns()
    end

    local colHdr = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    Bd(colHdr, header, border)
    colHdr:SetPoint("TOPLEFT",  expBar, "BOTTOMLEFT",  0, -3)
    colHdr:SetPoint("TOPRIGHT", expBar, "BOTTOMRIGHT", 0, -3)
    colHdr:SetHeight(16)

    local chName = FS(colHdr, "GameFontNormalSmall")
    chName:SetPoint("LEFT", 22, 0)
    chName:SetText("ITEM NAME")
    chName:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    chName:SetTextColor(accent[1], accent[2], accent[3], 0.50)

    local chTag = FS(colHdr, "GameFontNormalSmall")
    chTag:SetPoint("RIGHT", -24, 0)
    chTag:SetText("SOURCE  EXP")
    chTag:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
    chTag:SetTextColor(accent[1], accent[2], accent[3], 0.50)
    chTag:SetJustifyH("RIGHT")

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     colHdr, "BOTTOMLEFT",  0,  -2)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame,  "BOTTOMRIGHT", -24, 12)

    local C = Controls()
    if C and C.SkinScrollFrame then
        C:SkinScrollFrame(scrollFrame)
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(1)
    content:SetHeight(1)
    scrollFrame:SetScrollChild(content)

    scrollFrame:SetScript("OnSizeChanged", function(sf, w)
        if w and w > 1 then content:SetWidth(w) end
        if Refresh then Refresh(false) end
    end)

    local freePool   = MakeRowPool(content, 40)
    local activeRows = {}

    local function AcquireRow()
        local row = table.remove(freePool)
        if not row then row = CreateRow(content) end
        activeRows[#activeRows + 1] = row
        return row
    end

    local function ReleaseAll()
        for _, r in ipairs(activeRows) do
            r:Hide()
            r:ClearAllPoints()
            freePool[#freePool + 1] = r
        end
        for i = 1, #activeRows do activeRows[i] = nil end
    end

    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(16, 16)
    grip:SetPoint("BOTTOMRIGHT", -1, 1)
    grip:SetFrameLevel(frame:GetFrameLevel() + 20)
    local gripTex = grip:CreateTexture(nil, "OVERLAY")
    gripTex:SetAllPoints()
    gripTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    gripTex:SetVertexColor(accent[1], accent[2], accent[3], 0.45)
    grip:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        local w, h = frame:GetSize()
        local cw = max(MIN_W, min(MAX_W, w or MIN_W))
        local ch = max(MIN_H, min(MAX_H, h or MIN_H))
        if cw ~= w or ch ~= h then frame:SetSize(cw, ch) end
        LayoutTabs()
    end)

    local previewCurrentDecorID = nil
    local previewCurrentItem    = nil

    local previewFrame = CreateFrame("Frame", "HomeDecorCompactPreviewFrame", UIParent, "BackdropTemplate")
    Bd(previewFrame, panel, border)
    previewFrame:SetSize(360, 500)
    previewFrame:SetFrameStrata("DIALOG")
    previewFrame:SetFrameLevel(frame:GetFrameLevel() + 5)
    previewFrame:SetClampedToScreen(true)
    previewFrame:Hide()
    frame._previewFrame = previewFrame

    local previewHdr = CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
    Bd(previewHdr, header, border)
    previewHdr:SetPoint("TOPLEFT", 6, -6)
    previewHdr:SetPoint("TOPRIGHT", -6, -6)
    previewHdr:SetHeight(30)

    local previewTitle = FS(previewHdr, "GameFontNormal")
    previewTitle:SetPoint("LEFT", 10, 0)
    previewTitle:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    previewTitle:SetTextColor(accent[1], accent[2], accent[3], 1)
    previewTitle:SetText("Decor Preview")

    local previewClose = CreateFrame("Button", nil, previewHdr, "BackdropTemplate")
    Bd(previewClose, panel, border)
    previewClose:SetSize(22, 22)
    previewClose:SetPoint("RIGHT", -5, 0)
    Hov(previewClose, panel, hover)
    local previewCloseX = previewClose:CreateTexture(nil, "OVERLAY")
    previewCloseX:SetSize(12, 12)
    previewCloseX:SetPoint("CENTER")
    previewCloseX:SetTexture("Interface\\Buttons\\UI-StopButton")
    previewCloseX:SetVertexColor(accent[1], accent[2], accent[3], 1)
    previewClose:SetScript("OnClick", function()
        previewFrame:Hide()
        previewCurrentDecorID = nil
        previewCurrentItem = nil
    end)

    local previewInfo = CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
    Bd(previewInfo, rowBg, border)
    previewInfo:SetPoint("BOTTOMLEFT", previewFrame, "BOTTOMLEFT", 6, 6)
    previewInfo:SetPoint("BOTTOMRIGHT", previewFrame, "BOTTOMRIGHT", -6, 6)
    previewInfo:SetHeight(94)

    local previewIconBG = CreateFrame("Frame", nil, previewInfo, "BackdropTemplate")
    Bd(previewIconBG, panel, border)
    previewIconBG:SetSize(48, 48)
    previewIconBG:SetPoint("TOPLEFT", 10, -10)

    local previewIcon = previewIconBG:CreateTexture(nil, "ARTWORK")
    previewIcon:SetPoint("TOPLEFT", 2, -2)
    previewIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    previewIcon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    if previewIcon.SetTexCoord then previewIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end

    local previewName = FS(previewInfo, "GameFontNormalLarge")
    previewName:SetPoint("TOPLEFT", previewIconBG, "TOPRIGHT", 10, -8)
    previewName:SetPoint("TOPRIGHT", -10, -8)
    previewName:SetJustifyH("LEFT")
    previewName:SetWordWrap(false)
    previewName:SetMaxLines(1)
    previewName:SetTextColor(textCol[1], textCol[2], textCol[3], 1)

    local previewMeta = FS(previewInfo, "GameFontHighlightSmall")
    previewMeta:SetPoint("TOPLEFT", previewName, "BOTTOMLEFT", 0, -4)
    previewMeta:SetPoint("TOPRIGHT", -10, -4)
    previewMeta:SetJustifyH("LEFT")
    previewMeta:SetWordWrap(false)
    previewMeta:SetMaxLines(1)
    previewMeta:SetTextColor(muted[1], muted[2], muted[3], 1)

    local previewDetails = FS(previewInfo, "GameFontHighlightSmall")
    previewDetails:SetPoint("TOPLEFT", previewMeta, "BOTTOMLEFT", 0, -8)
    previewDetails:SetPoint("TOPRIGHT", -10, -4)
    previewDetails:SetJustifyH("LEFT")
    previewDetails:SetWordWrap(false)
    previewDetails:SetMaxLines(1)
    previewDetails:SetTextColor(textCol[1], textCol[2], textCol[3], 0.9)

    local previewModelHost = CreateFrame("Frame", nil, previewFrame, "BackdropTemplate")
    Bd(previewModelHost, { 0.03, 0.03, 0.04, 0.98 }, border)
    previewModelHost:SetPoint("TOPLEFT", previewHdr, "BOTTOMLEFT", 0, -4)
    previewModelHost:SetPoint("TOPRIGHT", previewHdr, "BOTTOMRIGHT", 0, -4)
    previewModelHost:SetPoint("BOTTOMLEFT", previewInfo, "TOPLEFT", 0, 6)
    previewModelHost:SetPoint("BOTTOMRIGHT", previewInfo, "TOPRIGHT", 0, 6)
    previewModelHost:SetClipsChildren(true)

    local previewFallback = FS(previewModelHost, "GameFontHighlight")
    previewFallback:SetPoint("CENTER")
    previewFallback:SetTextColor(muted[1], muted[2], muted[3], 0.9)
    previewFallback:SetText("Loading decor preview...")

    local previewScene = CreateFrame("ModelScene", nil, previewModelHost, "PanningModelSceneMixinTemplate")
    previewScene:SetPoint("TOPLEFT", 10, -34)
    previewScene:SetPoint("BOTTOMRIGHT", -10, 26)
    previewScene:Hide()

    local previewControls = nil
    do
        local ok, ctrl = pcall(CreateFrame, "Frame", nil, previewModelHost, "ModelSceneControlFrameTemplate")
        if ok and ctrl then
            ctrl:SetPoint("BOTTOM", previewModelHost, "BOTTOM", 0, 6)
            pcall(ctrl.SetModelScene, ctrl, previewScene)
            ctrl:Hide()
            previewControls = ctrl
        end
    end

    local corbelL = previewModelHost:CreateTexture(nil, "OVERLAY")
    corbelL:SetSize(66, 50)
    corbelL:SetPoint("BOTTOMLEFT", -2, -2)
    corbelL:SetAtlas("catalog-corbel-bottom-left")

    local corbelR = previewModelHost:CreateTexture(nil, "OVERLAY")
    corbelR:SetSize(66, 50)
    corbelR:SetPoint("BOTTOMRIGHT", 2, -2)
    corbelR:SetAtlas("catalog-corbel-bottom-right")

    local function LayoutPreviewFrame()
        if not previewFrame then return end
        previewFrame:ClearAllPoints()

        local uiW = UIParent:GetWidth() or 1280
        local fl  = frame:GetLeft() or 0
        local fw  = frame:GetWidth() or MIN_W
        local pw  = previewFrame:GetWidth() or 360

        if (fl + fw + 12 + pw) <= uiW then
            previewFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 12, 0)
        else
            previewFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", -12, 0)
        end
    end

    local function GetDefaultSceneID()
        if Constants and Constants.HousingCatalogConsts and Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT then
            return Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT
        end
        return 859
    end

    local function ClearCustomPreviewModel()
        previewScene:Hide()
        if previewControls then previewControls:Hide() end
        previewFallback:Show()
    end

    local function AttachPreviewModel(infoObj)
        if not (previewScene and infoObj and infoObj.asset) then
            ClearCustomPreviewModel()
            previewFallback:SetText("Preview unavailable for this decor.")
            return false
        end

        previewFallback:Hide()

        local sceneID = infoObj.uiModelSceneID or GetDefaultSceneID()
        local ok = pcall(function()
            previewScene:TransitionToModelSceneID(sceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, true)
        end)
        if not ok then
            ClearCustomPreviewModel()
            previewFallback:SetText("Preview unavailable for this decor.")
            return false
        end

        local actor = previewScene.GetActorByTag and previewScene:GetActorByTag("decor")
        if not actor then
            ClearCustomPreviewModel()
            previewFallback:SetText("Preview unavailable for this decor.")
            return false
        end

        actor:SetPreferModelCollisionBounds(true)
        actor:SetModelByFileID(infoObj.asset)
        previewScene:Show()
        if previewControls then previewControls:Show() end
        return true
    end

    local ShowPreview = function(d)
        if previewCurrentDecorID == d.decorID and previewFrame:IsShown() then
            previewFrame:Hide()
            previewCurrentDecorID = nil
            previewCurrentItem    = nil
            return
        end
        previewCurrentDecorID = d.decorID

        local entryType = (Enum and Enum.HousingCatalogEntryType
                           and Enum.HousingCatalogEntryType.Decor) or 1
        local ok, infoObj = pcall(
            C_HousingCatalog.GetCatalogEntryInfoByRecordID, entryType, d.decorID, true)
        if not (ok and infoObj) then return end

        local VD    = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
        local item  = d.item
        local stype = item and item.source and item.source.type
        local enriched = {}
        for k, v in pairs(item or {}) do enriched[k] = v end
        enriched.source = {}
        for k, v in pairs((item and item.source) or {}) do enriched.source[k] = v end
        if stype == "achievement" or stype == "quest" or stype == "pvp" then
            if VD and VD.ResolveAchievementDecor then
                enriched = VD.ResolveAchievementDecor(enriched) or enriched
            end
        end
        if stype == "vendor" and VD and VD.HydrateFromDecorIndex then
            VD.HydrateFromDecorIndex(enriched)
        end

        previewName:SetText((d.name and d.name ~= "" and d.name) or GetDecorName(d.decorID) or ("Decor #" .. tostring(d.decorID)))
        previewMeta:SetText(GetPreviewSummaryText(d))
        do
            local detailLines = {}
            local costText = GetPreviewCostText(d)
            local reqText = GetPreviewRequirementText(d)
            if costText then detailLines[#detailLines + 1] = costText end
            if reqText and reqText ~= "" then
                reqText = tostring(reqText):gsub("\r", " "):gsub("\n.*", "")
                detailLines[#detailLines + 1] = reqText
            end
            previewDetails:SetText(#detailLines > 0 and table.concat(detailLines, "  |  ") or "")
        end
        previewIcon:SetTexture(GetEntryIcon(d))
        previewFallback:SetText("Loading decor preview...")

        LayoutPreviewFrame()
        previewFrame:Show()

        if AttachPreviewModel(infoObj) then
            previewFallback:Hide()
        else
            previewFallback:Show()
            previewFallback:SetText("Preview unavailable for this decor.")
        end

        previewCurrentItem = enriched
    end

    local rawList      = {}
    local shownList    = {}
    local vendorOpen   = {}
    local progTotal    = 0
    local progCollected = 0
    local RenderRows   

    local RenderDeferred = NS.Debounce and NS.Debounce(0.05, function()
        if frame and frame:IsShown() then RenderRows() end
    end) or function()
        if frame and frame:IsShown() then RenderRows() end
    end

    scrollFrame:SetScript("OnVerticalScroll", function(sf, offset)
        sf:SetVerticalScroll(offset)
        RenderDeferred()
    end)

    local rowClick = function(self2, btn)
        local rd = self2._data
        if not rd then return end
        if rd.kind == "vendorHeader" then
            vendorOpen[rd._key] = not vendorOpen[rd._key]
            shownList = ApplyFilters(rawList, searchBox:GetText() or "", collectedFilter, expansionFilter, true, vendorOpen)
            RenderRows()
            return
        end
        local noMod = not (IsControlKeyDown() or IsAltKeyDown() or IsShiftKeyDown())
        if btn == "LeftButton" and noMod then
            ShowPreview(rd)
        else
            local VD2 = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
            local it2 = rd.item
            local st2 = it2 and it2.source and it2.source.type
            if (st2 == "achievement" or st2 == "quest" or st2 == "pvp")
               and VD2 and VD2.ResolveAchievementDecor then
                it2 = VD2.ResolveAchievementDecor(it2) or it2
            end
            local IA = NS.UI and NS.UI.ItemInteractions
            if IA and IA.HandleMouseUp then IA:HandleMouseUp(it2, btn, self2) end
        end
    end

    local vendorHeaderEnter = function(self2)
        local rd = self2._data
        if not rd or rd.kind ~= "vendorHeader" then return end
        local isOpen = vendorOpen[rd._key] or false
        GameTooltip:SetOwner(self2, "ANCHOR_RIGHT")
        GameTooltip:SetText(isOpen and "Click to collapse" or "Click to expand", 1, 1, 1)
        GameTooltip:Show()
    end

    local vendorHeaderLeave = function() GameTooltip:Hide() end

    RenderRows = function()
        local sw = scrollFrame:GetWidth()
        if sw and sw > 4 then content:SetWidth(sw) end

        local items = shownList
        local n     = #items

        content:SetHeight(max(1, n * ROW_H))

        if progTotal > 0 then
            local pct = floor(progCollected / progTotal * 100)
            progFS:SetText(progCollected .. " / " .. progTotal .. "  (" .. pct .. "%)")
        else
            progFS:SetText("")
        end

        ReleaseAll()
        if n == 0 then return end

        local scrollY  = scrollFrame:GetVerticalScroll() or 0
        local viewH    = scrollFrame:GetHeight() or 400
        local OVERSCAN = ROW_H * 4

        local firstIdx = max(1, floor((scrollY - OVERSCAN) / ROW_H) + 1)
        local lastIdx  = min(n, ceil((scrollY + viewH + OVERSCAN) / ROW_H))

        local C2       = Controls()
        local isVendor = (activeCategory == "Vendors")

        for i = firstIdx, lastIdx do
            local d   = items[i]
            local row = AcquireRow()
            row._data   = d
            row._isEven = (i % 2 == 0)

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT",  content, "TOPLEFT",  0, -(i - 1) * ROW_H)
            row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(i - 1) * ROW_H)
            row:SetHeight(ROW_H)

            if d.kind == "vendorHeader" then
                if C2 and C2.Backdrop and row._lastBgKey ~= "header" then
                    row._lastBgKey = "header"
                    C2:Backdrop(row, header, border)
                end

                if row._lastKind ~= "vendorHeader" then
                    row._lastKind = "vendorHeader"
                    row:SetScript("OnEnter", vendorHeaderEnter)
                    row:SetScript("OnLeave", vendorHeaderLeave)
                    row:SetScript("OnClick",  rowClick)
                    row._nameFS:ClearAllPoints()
                    row._nameFS:SetPoint("LEFT",  row, "LEFT",  8, 0)
                    row._nameFS:SetPoint("RIGHT", row, "RIGHT", -120, 0)
                end

                row._chk:Hide()
                row._dot:Hide()
                row._accent:Hide()
                if row._icon then row._icon:Hide() end
                if row._iconBG then row._iconBG:Hide() end
                if row._locBtn then row._locBtn:Hide() end

                local vname  = (d.title ~= "" and d.title)
                               or (d.npcID and ("NPC #" .. d.npcID))
                               or "Vendor"
                local isOpen = vendorOpen[d._key] or false
                local arrow  = isOpen and "|cFFFFD700[-]|r " or "|cFFFFD700[+]|r "
                row._nameFS:SetText(arrow .. vname)
                row._nameFS:SetTextColor(accent[1], accent[2], accent[3], 1.0)

                local expS   = GetExpShort(d.exp)
                local tagStr = d.zone or ""
                if expS ~= "" then
                    tagStr = tagStr ~= "" and (tagStr .. "  " .. expS) or expS
                end
                row._tagFS:SetText(tagStr)
                row._tagFS:SetTextColor(accent[1], accent[2], accent[3], 0.60)
            else
                if row._lastKind ~= "item" then
                    row._lastKind = "item"
                    row:SetScript("OnClick", rowClick)
                    row.__hdTTScripts = nil
                    row._lastItem = nil
                end

                local TT = NS.UI and NS.UI.Tooltips
                if TT and TT.Attach and row._lastItem ~= d.item then
                    row._lastItem = d.item
                    local ttItem = d.item
                    local stype  = ttItem and ttItem.source and ttItem.source.type
                    if stype == "achievement" or stype == "quest" or stype == "pvp" then
                        local VD = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
                        if VD and VD.ResolveAchievementDecor then
                            ttItem = VD.ResolveAchievementDecor(ttItem) or ttItem
                        end
                    end
                    TT:Attach(row, ttItem)
                end

                local bgKey = row._isEven and "alt" or "normal"
                if C2 and C2.Backdrop and row._lastBgKey ~= bgKey then
                    row._lastBgKey = bgKey
                    C2:Backdrop(row, row._isEven and rowAlt or rowBg, border)
                end

                if d.collected then
                    row._chk:Show()
                    row._dot:Hide()
                    row._accent:SetColorTexture(success[1], success[2], success[3], 0.55)
                    row._accent:Show()
                    row._nameFS:SetTextColor(muted[1], muted[2], muted[3], 0.70)
                else
                    row._chk:Hide()
                    row._dot:Show()
                    row._dot:SetColorTexture(muted[1], muted[2], muted[3], 0.50)
                    row._accent:Hide()
                    row._nameFS:SetTextColor(textCol[1], textCol[2], textCol[3], textCol[4] or 0.95)
                end

                local isDrop = d.item and d.item.source and d.item.source.type == "drop"
                local DP = NS.UI and NS.UI.DropPanel
                local hasLoc = isDrop and DP and (DP.GetCount and DP:GetCount(d.item) > 0)

                if row._icon and row._iconBG then
                    row._icon:SetTexture(GetEntryIcon(d))
                    row._icon:Show()
                    row._iconBG:Show()
                end

                local nameLeft = isVendor and 52 or 46
                row._nameFS:ClearAllPoints()
                row._nameFS:SetPoint("LEFT",  row, "LEFT",  nameLeft, 0)
                row._nameFS:SetPoint("RIGHT", row, "RIGHT", hasLoc and -122 or -98, 0)
                local displayName = d.name
                if not displayName or displayName == "" then displayName = "..." end
                row._nameFS:SetText(displayName)

                if row._locBtn then
                    if hasLoc then
                        row._locBtn._item = d.item
                        row._locBtn:Show()
                    else
                        row._locBtn:Hide()
                    end
                end

                local expS = GetExpShort(d.exp)
                local tag
                if isVendor then
                    tag = expS
                else
                    tag = d.srcTag ~= "" and d.srcTag or ""
                    if expS ~= "" then
                        tag = tag ~= "" and (tag .. " / " .. expS) or expS
                    end
                end
                row._tagFS:SetText(tag)
                row._tagFS:SetTextColor(accent[1], accent[2], accent[3], 0.52)
            end

            row:Show()
        end
    end

    Refresh = function(fullRebuild)
        local vendorGrouped = (activeCategory == "Vendors")

        if fullRebuild then
            rawList = BuildRawList(activeCategory)

            for _, it in ipairs(rawList) do
                if it.kind == "vendorHeader" then
                    if it.title == "" then
                        local NPC = NS.Systems and NS.Systems.NPCNames
                        local VD2 = NS.UI and NS.UI.Viewer and NS.UI.Viewer.Data
                        if VD2 and VD2.ResolveVendorTitle then
                            local t = VD2.ResolveVendorTitle(it._vendorNode, function(_, name)
                                if name and name ~= "" then
                                    it.title = name
                                    RenderDeferred()
                                end
                            end)
                            if t then it.title = t end
                        elseif NPC and NPC.Get and it.npcID then
                            local t = NPC.Get(it.npcID, function(_, name)
                                if name and name ~= "" then
                                    it.title = name
                                    RenderDeferred()
                                end
                            end)
                            if t and t ~= "" then it.title = t end
                        end
                    end
                else
                    local n = GetDecorName(it.decorID)
                    it.name      = n or ""
                    it.collected = IsCollected(it.item)
                end
            end

            SortList(rawList, vendorGrouped)

            progTotal   = 0
            progCollected = 0
            for _, it in ipairs(rawList) do
                if it.kind ~= "vendorHeader" then
                    progTotal = progTotal + 1
                    if it.collected then progCollected = progCollected + 1 end
                end
            end

            if vendorGrouped then
                for k in pairs(vendorOpen) do vendorOpen[k] = nil end
            end

            local presentExps = {}
            for _, it in ipairs(rawList) do
                if it.kind ~= "vendorHeader" then
                    local s = GetExpShort(it.exp)
                    if s and s ~= "" then presentExps[s] = true end
                end
            end
            RebuildExpansionBtns(presentExps)
        end

        shownList = ApplyFilters(rawList, searchBox:GetText() or "", collectedFilter, expansionFilter, vendorGrouped, vendorOpen)

        RenderRows()
        scrollFrame:SetVerticalScroll(0)

        if fullRebuild then
            local function RetryNames()
                if not frame or not frame:IsShown() then return end
                local anyUpdated = false
                for _, it in ipairs(rawList) do
                    if it.kind ~= "vendorHeader" and it.name == "" then
                        local n = GetDecorName(it.decorID)
                        if n and n ~= "" then
                            it.name = n
                            anyUpdated = true
                        end
                    end
                end
                if anyUpdated then
                    SortList(rawList, vendorGrouped)
                    shownList = ApplyFilters(rawList, searchBox:GetText() or "", collectedFilter, expansionFilter, vendorGrouped, vendorOpen)
                    RenderRows()
                end
            end
            C_Timer.After(1.5,  RetryNames)
            C_Timer.After(4.0,  RetryNames)
            C_Timer.After(8.0,  RetryNames)
            C_Timer.After(12.0, RetryNames)
        end
    end

    frame:SetScript("OnHide", function()
        if previewFrame then previewFrame:Hide() end
        if previewScene then previewScene:Hide() end
        if previewControls then previewControls:Hide() end
        previewCurrentDecorID = nil
        previewCurrentItem    = nil
    end)
    frame:SetScript("OnShow", function()
        StyleTabs()
        LayoutTabs()
        StyleFilterBtns()
        LayoutFilterBtns()
        LayoutExpBtns()
        C_Timer.After(0, function()
            if frame and frame:IsShown() then Refresh(true) end
        end)
    end)

    frame:SetScript("OnSizeChanged", function()
        LayoutTabs()
        LayoutFilterBtns()
        LayoutExpBtns()
        if previewFrame and previewFrame:IsShown() then
            LayoutPreviewFrame()
        end
    end)

    frame:SetScript("OnMouseWheel", function(_, delta)
        local cur  = scrollFrame:GetVerticalScroll()
        local step = ROW_H * 3
        scrollFrame:SetVerticalScroll(max(0, cur - delta * step))
    end)

    StyleTabs()
    LayoutTabs()
    StyleFilterBtns()
    LayoutFilterBtns()
    LayoutExpBtns()
    CM.frame = frame
end

return CM
