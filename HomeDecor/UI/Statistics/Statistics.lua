local ADDON, NS = ...
NS.UI = NS.UI or {}
NS.UI.Statistics = NS.UI.Statistics or {}
local StatisticsUI = NS.UI.Statistics
local floor = math.floor
local max = math.max
local format = string.format

local function Theme() return NS.UI.Theme and NS.UI.Theme.colors or {} end
local function AccentRGB()
    local c = Theme().accent
    if c then return c[1], c[2], c[3] end
    return 0.90, 0.72, 0.18
end
local function Backdrop(f, bg, brd)
    local C = NS.UI.Controls
    if C and C.Backdrop then C:Backdrop(f, bg, brd) end
end
local function TC(fs, role, alpha)
    local C = NS.UI.Controls
    if C and C.TextColor then C:TextColor(fs, role, alpha) end
end
local function SolC(tex, role, alpha)
    local C = NS.UI.Controls
    if C and C.SolidColor then C:SolidColor(tex, role, alpha) end
end
local function Tex(parent, layer)
    return parent:CreateTexture(nil, layer or "ARTWORK")
end
local function FS(parent, template, layer)
    return parent:CreateFontString(nil, layer or "OVERLAY", template or "GameFontHighlightSmall")
end
local function SolidBG(f, r, g, b, a)
    local t = Tex(f, "BACKGROUND")
    t:SetAllPoints()
    t:SetColorTexture(r, g, b, a or 1)
    return t
end
local function HLineAccent(parent, alpha, anchor, offY)
    local r, g, b = AccentRGB()
    local t = Tex(parent, "BORDER")
    t:SetHeight(1)
    t:SetPoint("LEFT", parent, anchor or "BOTTOMLEFT", 0, offY or 0)
    t:SetPoint("RIGHT", parent, anchor and anchor:gsub("LEFT", "RIGHT") or "BOTTOMRIGHT", 0, offY or 0)
    t:SetColorTexture(r, g, b, alpha or 1)
    SolC(t, "accent", alpha)
    return t
end
local function ApplyFont(fs, size, flags)
    fs:SetFont(STANDARD_TEXT_FONT, size or 11, flags or "")
end
local function MakeScroll(parent)
    local sf = CreateFrame("ScrollFrame", nil, parent, "ScrollFrameTemplate")
    sf:SetPoint("TOPLEFT")
    sf:SetPoint("BOTTOMRIGHT", -26, 0)
    local C = NS.UI.Controls
    if C and C.SkinScrollFrame then C:SkinScrollFrame(sf) end
    local ct = CreateFrame("Frame", nil, sf)
    ct:SetSize(1, 1)
    sf:SetScrollChild(ct)
    sf:SetScript("OnSizeChanged", function(s, w) ct:SetWidth(max(1, w)) end)
    return sf, ct
end
local function FormatMoney(copper)
    copper = copper or 0
    if copper < 0 then
        return "-" .. GetCoinTextureString(-copper)
    end
    return GetCoinTextureString(copper)
end
local function ChainCallback(owner, name, fn)
    local prev = owner[name]
    owner[name] = function(...)
        if prev then prev(...) end
        fn(...)
    end
end

local function CreateCard(parent, title)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local T = Theme()
    Backdrop(card, T.panel or { 0.095, 0.095, 0.11, 1 }, T.border or { 0.24, 0.24, 0.28, 1 })

    local titleFS = FS(card, "GameFontNormal")
    titleFS:SetPoint("TOPLEFT", 12, -10)
    titleFS:SetText(title)
    TC(titleFS, "accent")
    ApplyFont(titleFS, 13, "OUTLINE")

    local line = Tex(card, "ARTWORK")
    line:SetPoint("TOPLEFT", titleFS, "BOTTOMLEFT", 0, -8)
    line:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, 0)
    line:SetHeight(1)
    SolC(line, "accent", 0.3)

    card._y = 34
    return card
end

local function AddStatRow(card, label)
    local row = CreateFrame("Frame", nil, card)
    row:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -card._y)
    row:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -card._y)
    row:SetHeight(22)
    card._y = card._y + 24

    local labelFS = FS(row, "GameFontHighlightSmall")
    labelFS:SetPoint("LEFT", 0, 0)
    labelFS:SetText(label)
    TC(labelFS, "textMuted")

    local valueFS = FS(row, "GameFontHighlightSmall")
    valueFS:SetPoint("RIGHT", 0, 0)
    TC(valueFS, "text")

    return valueFS
end

local function AddCategoryRow(card, label)
    local row = CreateFrame("Frame", nil, card)
    row:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -card._y)
    row:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -card._y)
    row:SetHeight(22)
    card._y = card._y + 26

    local labelFS = FS(row, "GameFontHighlightSmall")
    labelFS:SetPoint("LEFT", 0, 0)
    labelFS:SetWidth(150)
    labelFS:SetJustifyH("LEFT")
    labelFS:SetText(label)
    TC(labelFS, "text")

    local bar = NS.UI.ProgressBar:Create(row, 150)
    bar:SetPoint("LEFT", labelFS, "RIGHT", 10, 0)

    local valueFS = FS(row, "GameFontHighlightSmall")
    valueFS:SetPoint("LEFT", bar, "RIGHT", 10, 0)
    valueFS:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    valueFS:SetJustifyH("RIGHT")
    TC(valueFS, "textMuted")

    return bar, valueFS
end

local function AddBarRow(card, width)
    local row = CreateFrame("Frame", nil, card)
    row:SetPoint("TOPLEFT", card, "TOPLEFT", 12, -card._y)
    row:SetPoint("TOPRIGHT", card, "TOPRIGHT", -12, -card._y)
    row:SetHeight(16)
    card._y = card._y + 24

    local bar = NS.UI.ProgressBar:Create(row, width or 200)
    bar:SetPoint("LEFT", row, "LEFT", 0, 0)
    bar:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    return bar
end

local function FinishCard(card)
    card:SetHeight(card._y + 12)
end

local CATEGORY_LIST = {
    { key = "Achievements", label = "Achievements" },
    { key = "Quests", label = "Quests" },
    { key = "Vendors", label = "Vendors" },
    { key = "Drops", label = "Drops / Encounters" },
    { key = "Treasures", label = "Treasures" },
    { key = "Shop", label = "Shop" },
    { key = "Professions", label = "Professions" },
    { key = "PvP", label = "PvP" },
}

function StatisticsUI:Create(parent)
    if self.panel then return self.panel end
    local panel = CreateFrame("Frame", "HDStatisticsPanel", parent)
    panel:SetAllPoints()
    self.panel = panel

    do
        local bg = Theme().bg or { 0.045, 0.045, 0.05, 1 }
        SolC(SolidBG(panel, bg[1], bg[2], bg[3], bg[4]), "bg")
    end

    local hdr = CreateFrame("Frame", nil, panel)
    hdr:SetPoint("TOPLEFT"); hdr:SetPoint("TOPRIGHT")
    hdr:SetHeight(56)
    do
        local h = Theme().header or { 0.075, 0.075, 0.085, 1 }
        SolC(SolidBG(hdr, h[1], h[2], h[3], h[4]), "header")
    end
    HLineAccent(hdr, 0.4)

    local title = FS(hdr, "GameFontNormalLarge")
    title:SetPoint("LEFT", 16, 0)
    title:SetText("Statistics")
    TC(title, "accent")

    local subtitle = FS(hdr, "GameFontHighlightSmall")
    subtitle:SetPoint("LEFT", title, "RIGHT", 12, -1)
    subtitle:SetText("Your collection, endeavors, and crafting at a glance")
    TC(subtitle, "textMuted")

    local body = CreateFrame("Frame", nil, panel)
    body:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, 0)
    body:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 0)

    local sf, content = MakeScroll(body)
    self.scrollFrame = sf
    self.content = content

    local yOff = 16

    local overallCard = CreateCard(content, "Overall Collection")
    overallCard:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -yOff)
    overallCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", -16, -yOff)

    local pctFS = FS(overallCard, "GameFontNormalLarge")
    pctFS:SetPoint("TOPLEFT", 12, -overallCard._y)
    ApplyFont(pctFS, 26, "OUTLINE")
    TC(pctFS, "accent")
    self.overallPctFS = pctFS

    local subFS = FS(overallCard, "GameFontHighlightSmall")
    subFS:SetPoint("LEFT", pctFS, "RIGHT", 12, 0)
    TC(subFS, "textMuted")
    self.overallSubFS = subFS

    overallCard._y = overallCard._y + 34
    self.overallBar = AddBarRow(overallCard, 200)
    FinishCard(overallCard)
    yOff = yOff + overallCard:GetHeight() + 14

    local catCard = CreateCard(content, "Collection By Source")
    catCard:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -yOff)
    catCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", -16, -yOff)

    self.categoryRows = {}
    for _, info in ipairs(CATEGORY_LIST) do
        local bar, valueFS = AddCategoryRow(catCard, info.label)
        self.categoryRows[info.key] = { bar = bar, value = valueFS }
    end
    FinishCard(catCard)
    yOff = yOff + catCard:GetHeight() + 14

    local endeavorsCard = CreateCard(content, "Endeavors")
    endeavorsCard:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -yOff)
    endeavorsCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", -16, -yOff)

    local Dropdown = NS.UI.Dropdown
    if Dropdown and Dropdown.Create then
        local houseDropdown = Dropdown.Create(
            endeavorsCard, nil, nil, 170,
            function()
                local Sys = NS.Systems and NS.Systems.Endeavors
                return Sys and Sys:GetSelectedHouseIndex()
            end,
            function(value)
                local Sys = NS.Systems and NS.Systems.Endeavors
                if Sys and Sys.SelectHouse then Sys:SelectHouse(value) end
                StatisticsUI:FullRefresh()
            end,
            function()
                local Sys = NS.Systems and NS.Systems.Endeavors
                local houses = (Sys and Sys:GetHouseList()) or {}
                local opts = {}
                for i, house in ipairs(houses) do
                    opts[#opts + 1] = { value = i, text = house.neighborhoodName or house.houseName or ("House " .. i) }
                end
                return opts
            end,
            nil,
            NS.UI.Controls, Theme()
        )
        houseDropdown:SetSize(170, 22)
        houseDropdown:SetPoint("TOPRIGHT", endeavorsCard, "TOPRIGHT", -12, -8)
        self.houseDropdown = houseDropdown
    end

    self.seasonFS = AddStatRow(endeavorsCard, "Season")
    self.daysFS = AddStatRow(endeavorsCard, "Days Remaining")
    self.couponsFS = AddStatRow(endeavorsCard, "Community Coupons")
    self.houseXPFS = AddStatRow(endeavorsCard, "House XP")
    self.seasonBar = AddBarRow(endeavorsCard, 200)
    FinishCard(endeavorsCard)
    yOff = yOff + endeavorsCard:GetHeight() + 14

    local craftCard = CreateCard(content, "Crafting & Auction House")
    craftCard:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -yOff)
    craftCard:SetPoint("TOPRIGHT", content, "TOPRIGHT", -16, -yOff)

    self.queueSizeFS = AddStatRow(craftCard, "Items Queued")
    self.queueProfitFS = AddStatRow(craftCard, "Potential Profit")
    self.queueCostFS = AddStatRow(craftCard, "Material Cost")
    self.todaySalesFS = AddStatRow(craftCard, "Sold Today")
    self.weekSalesFS = AddStatRow(craftCard, "Sold This Week")
    FinishCard(craftCard)
    yOff = yOff + craftCard:GetHeight() + 16

    content:SetHeight(yOff)

    function panel:FullRefresh()
        StatisticsUI:FullRefresh()
    end

    local Sys = NS.Systems and NS.Systems.Endeavors
    if Sys then
        ChainCallback(Sys, "OnDataReady", function()
            if panel:IsShown() then StatisticsUI:FullRefresh() end
        end)
        ChainCallback(Sys, "OnHouseListUpdated_callback", function()
            if panel:IsShown() and self.houseDropdown then self.houseDropdown:ApplyText() end
        end)
    end

    return panel
end

function StatisticsUI:RefreshCategory(key)
    local rowData = self.categoryRows and self.categoryRows[key]
    if not rowData then return end

    local GI = NS.Systems and NS.Systems.GlobalIndex
    local collected, total = 0, 0
    if GI and GI.GetCounts then
        collected, total = GI:GetCounts(key)
    end

    rowData.bar:SetProgress(collected, max(total, 1))
    local pct = (total > 0) and floor((collected / total) * 100 + 0.5) or 0
    rowData.value:SetText(format("%d / %d  (%d%%)", collected, total, pct))
end

function StatisticsUI:FullRefresh()
    if not self.panel then return end

    local GI = NS.Systems and NS.Systems.GlobalIndex
    local overallCollected, overallTotal = 0, 0
    if GI and GI.GetTotalUniqueCount then
        overallCollected, overallTotal = GI:GetTotalUniqueCount()
    end
    for _, info in ipairs(CATEGORY_LIST) do
        self:RefreshCategory(info.key)
    end

    local overallPct = (overallTotal > 0) and floor((overallCollected / overallTotal) * 100 + 0.5) or 0
    self.overallPctFS:SetText(format("%d%%", overallPct))
    self.overallSubFS:SetText(format("%d / %d items collected", overallCollected, overallTotal))
    self.overallBar:SetProgress(overallCollected, max(overallTotal, 1))

    if self.houseDropdown then self.houseDropdown:ApplyText() end

    local Endeavors = NS.Systems and NS.Systems.Endeavors
    local info = Endeavors and Endeavors.GetEndeavorInfo and Endeavors:GetEndeavorInfo()
    if info then
        self.seasonFS:SetText(info.seasonName or "-")
        self.daysFS:SetText(tostring(info.daysRemaining or 0))
        self.seasonBar:SetProgress(info.currentProgress or 0, max(info.maxProgress or 1, 1))
    else
        self.seasonFS:SetText("-")
        self.daysFS:SetText("-")
        self.seasonBar:SetProgress(0, 1)
    end

    local coupons = (Endeavors and Endeavors.GetCommunityCoupons and Endeavors:GetCommunityCoupons()) or 0
    self.couponsFS:SetText(tostring(coupons))

    local houseXP = (Endeavors and Endeavors.GetHouseXP and Endeavors:GetHouseXP()) or 0
    self.houseXPFS:SetText(tostring(houseXP))

    local Queue = NS.DecorAH and NS.DecorAH.Queue
    local queueSize = (Queue and Queue.GetQueueSize and Queue.GetQueueSize()) or 0
    local profit = (Queue and Queue.GetTotalProfit and Queue.GetTotalProfit()) or 0
    local cost = (Queue and Queue.GetTotalCost and Queue.GetTotalCost()) or 0
    self.queueSizeFS:SetText(tostring(queueSize))
    self.queueProfitFS:SetText(FormatMoney(profit))
    self.queueCostFS:SetText(FormatMoney(cost))

    local Sales = NS.DecorAH and NS.DecorAH.Sales
    local todayGold, todayCount = 0, 0
    if Sales and Sales.GetTodaysSales then
        local _, g, c = Sales.GetTodaysSales()
        todayGold, todayCount = g or 0, c or 0
    end
    local weekGold, weekCount = 0, 0
    if Sales and Sales.GetWeeklySales then
        local _, g, c = Sales.GetWeeklySales()
        weekGold, weekCount = g or 0, c or 0
    end
    self.todaySalesFS:SetText(format("%s  (%d)", FormatMoney(todayGold), todayCount))
    self.weekSalesFS:SetText(format("%s  (%d)", FormatMoney(weekGold), weekCount))
end
