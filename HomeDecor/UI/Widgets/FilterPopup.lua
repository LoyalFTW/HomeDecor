local _, NS = ...
NS.UI = NS.UI or {}
NS.UI.Util = NS.UI.Util or {}
local U = NS.UI.Util
local L = NS.L

local unpack = unpack
local wipe = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end

if not U.Backdrop then
    function U.Backdrop(frame, controls, bg, border)
        if not frame or not controls or not controls.Backdrop then return end
        return controls:Backdrop(frame, bg, border)
    end
end

if not U.SetFont then
    function U.SetFont(fs, size)
        if fs then fs:SetFont(STANDARD_TEXT_FONT, size, "") end
    end
end

if not U.SafeBorder then
    function U.SafeBorder(frame, col)
        if frame and frame.SetBackdropBorderColor and col then
            frame:SetBackdropBorderColor(col[1], col[2], col[3], col[4] or 1)
        end
    end
end

if not U.BindBorderHover then
    function U.BindBorderHover(frame, accent, border)
        if not (frame and frame.SetScript and frame.SetBackdropBorderColor) then return end
        frame:SetScript("OnEnter", function() frame:SetBackdropBorderColor(unpack(accent)) end)
        frame:SetScript("OnLeave", function() frame:SetBackdropBorderColor(unpack(border)) end)
    end
end

if not U.BindBackgroundHover then
    function U.BindBackgroundHover(frame, hoverBg, normalBg)
        if not (frame and frame.SetScript and frame.SetBackdropColor) then return end
        frame:SetScript("OnEnter", function() frame:SetBackdropColor(unpack(hoverBg)) end)
        frame:SetScript("OnLeave", function() frame:SetBackdropColor(unpack(normalBg)) end)
    end
end

local function insertAllSeparator(values)
    if type(values) ~= "table" or values.__hasAllSeparator then return values end
    local first = values[1]
    if first and first.value == "ALL" then
        table.insert(values, 2, { separator = true })
        values.__hasAllSeparator = true
    end
    return values
end

local M = {}
NS.UI.FilterPopup = M

function M:Build(popup, env)
    local C, T, Dropdown, FiltersSys, UI = env.C, env.T, env.Dropdown, env.FiltersSys, env.UI
    local HeaderCtrl = NS.UI and NS.UI.HeaderController
    local rerender = env.rerender
    local function TextColor(fs, role, alpha)
        if C and C.TextColor then C:TextColor(fs, role, alpha) end
    end

    popup._rows = popup._rows or {}
    popup._tabs = popup._tabs or {}
    popup._activeTab = popup._activeTab or "filters"
    wipe(popup._rows)

    local function ensureDB()
        local db = NS.db and NS.db.profile
        if db and FiltersSys and FiltersSys.EnsureDefaults then
            pcall(FiltersSys.EnsureDefaults, FiltersSys, db)
        end
        if db then db.filters = db.filters or {} end
        return db
    end

    local function F()
        local db = ensureDB()
        return db and db.filters
    end

    local function rebuild()
        if HeaderCtrl and HeaderCtrl.Reset then HeaderCtrl:Reset() end
        if rerender then rerender() end
    end

    local function setDDText(dd, value)
        local fs = dd and dd.text
        if not fs then return end

        local opts = dd._valuesFn and dd._valuesFn() or nil
        if type(opts) == "table" then
            for i = 1, #opts do
                local o = opts[i]
                if o and not o.separator and o.value == value then
                    fs:SetText(o.text or tostring(value))
                    return
                end
            end
        end
        fs:SetText(tostring(value or ""))
    end

    local function syncAll()
        for i = 1, #popup._rows do
            local r = popup._rows[i]
            if r and r.refresh then r.refresh() end
        end
    end

    local function resetCategoryScope()
        local f = F()
        if not f then return end
        f.category = "ALL"
        f.subcategory = "ALL"
    end

    local function headerRow(titleText)
        local r = {}
        r.title = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        r.title:SetText(titleText)
        TextColor(r.title, "accent")

        r.line = popup:CreateTexture(nil, "ARTWORK")
        r.line:SetHeight(2)
        r.line:SetColorTexture(unpack(T.accent))

        popup._allElements[#popup._allElements + 1] = r.title
        popup._allElements[#popup._allElements + 1] = r.line

        return r
    end

    local function checkRow(titleText, get, set, resetsCategory, tooltip)
        local r = {}
        r.isCheck, r._get = true, get

        local b = CreateFrame("Button", nil, popup, "BackdropTemplate")
        b:SetHeight(26)
        U.Backdrop(b, C, T.panel, T.border)
        U.BindBorderHover(b, T.accent, T.border)

        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        b.text:SetPoint("LEFT", 10, 0)
        b.text:SetText(titleText)
        TextColor(b.text, "text")

        b.indicator = b:CreateTexture(nil, "OVERLAY")
        b.indicator:SetSize(8, 8)
        b.indicator:SetPoint("RIGHT", -10, 0)
        b.indicator:SetTexture("Interface\\Buttons\\WHITE8x8")

        local function updateIndicator()
            if get() == true then
                b.indicator:SetColorTexture(unpack(T.accent))
            else
                b.indicator:SetColorTexture(0.3, 0.3, 0.3, 0.5)
            end
        end

        b:SetScript("OnClick", function()
            set(not get())
            if resetsCategory then resetCategoryScope() end
            updateIndicator()
            rebuild()
        end)

        if tooltip and NS.UI.Tooltips then
            NS.UI.Tooltips:SimpleTooltip(b, tooltip, nil, "ANCHOR_RIGHT")
        end

        r.dd = b
        r.refresh = updateIndicator
        popup._rows[#popup._rows + 1] = r
        updateIndicator()

        popup._allElements[#popup._allElements + 1] = b
        popup._allElements[#popup._allElements + 1] = b.text
        popup._allElements[#popup._allElements + 1] = b.indicator
    end

    local function ddRow(titleText, get, set, valuesFn, resetsCategory)
        local r = headerRow(titleText)
        r._get = get

        local dd = Dropdown.Create(
            popup, nil, nil, 1,
            get,
            function(v)
                set(v)
                if resetsCategory then resetCategoryScope() end
                setDDText(dd, get())
                rebuild()
            end,
            valuesFn,
            function() return true end,
            C, T
        )
        dd._valuesFn = valuesFn
        r.dd = dd
        r.refresh = function() setDDText(dd, get()) end

        popup._rows[#popup._rows + 1] = r
        setDDText(dd, get())

        popup._allElements[#popup._allElements + 1] = dd
    end

    local COLOR_SWATCHES = {
        Black = {0.02, 0.02, 0.02, 1},
        Gray = {0.38, 0.38, 0.38, 1},
        Grey = {0.38, 0.38, 0.38, 1},
        Silver = {0.62, 0.62, 0.6, 1},
        ["Light Gray"] = {0.68, 0.68, 0.66, 1},
        ["Light Grey"] = {0.68, 0.68, 0.66, 1},
        ["Dark Gray"] = {0.22, 0.22, 0.22, 1},
        ["Dark Grey"] = {0.22, 0.22, 0.22, 1},
        White = {0.95, 0.95, 0.9, 1},
        OffWhite = {0.86, 0.86, 0.78, 1},
        ["Off White"] = {0.86, 0.86, 0.78, 1},
        Ivory = {0.9, 0.88, 0.72, 1},
        Cream = {0.9, 0.86, 0.66, 1},
        Beige = {0.74, 0.62, 0.44, 1},
        Red = {0.95, 0.05, 0.04, 1},
        ["Light Red"] = {0.95, 0.28, 0.28, 1},
        ["Deep Red"] = {0.62, 0.02, 0.03, 1},
        ["Dark Red"] = {0.5, 0.02, 0.03, 1},
        Maroon = {0.5, 0.03, 0.08, 1},
        Crimson = {0.75, 0.03, 0.18, 1},
        Pink = {0.95, 0.04, 0.7, 1},
        ["Light Pink"] = {0.95, 0.48, 0.72, 1},
        Rose = {0.72, 0.16, 0.32, 1},
        Magenta = {0.86, 0.02, 0.85, 1},
        Purple = {0.48, 0.34, 0.78, 1},
        ["Light Purple"] = {0.58, 0.43, 0.82, 1},
        ["Dark Purple"] = {0.26, 0.04, 0.42, 1},
        Violet = {0.32, 0.04, 0.5, 1},
        Lavender = {0.58, 0.45, 0.82, 1},
        Blue = {0.08, 0.1, 0.92, 1},
        ["Light Blue"] = {0.25, 0.45, 0.9, 1},
        ["Deep Blue"] = {0.05, 0.06, 0.46, 1},
        ["Dark Blue"] = {0.04, 0.05, 0.42, 1},
        Navy = {0.03, 0.05, 0.24, 1},
        Cyan = {0.08, 0.86, 0.9, 1},
        Aqua = {0.08, 0.78, 0.82, 1},
        Teal = {0.03, 0.48, 0.47, 1},
        Turquoise = {0.03, 0.68, 0.66, 1},
        ["Dark Teal"] = {0.02, 0.32, 0.32, 1},
        Green = {0.02, 0.9, 0.05, 1},
        ["Light Green"] = {0.35, 0.8, 0.28, 1},
        ["Deep Green"] = {0.13, 0.48, 0.14, 1},
        ["Dark Green"] = {0.05, 0.34, 0.08, 1},
        Lime = {0.78, 0.86, 0.02, 1},
        Olive = {0.46, 0.48, 0.05, 1},
        Yellow = {1, 0.95, 0.02, 1},
        ["Light Yellow"] = {0.96, 0.88, 0.28, 1},
        Gold = {1, 0.66, 0.04, 1},
        Orange = {0.93, 0.48, 0.08, 1},
        ["Dark Orange"] = {0.76, 0.3, 0.04, 1},
        Brown = {0.39, 0.24, 0.1, 1},
        ["Light Brown"] = {0.56, 0.34, 0.15, 1},
        ["Dark Brown"] = {0.26, 0.13, 0.05, 1},
        Copper = {0.62, 0.28, 0.09, 1},
        Bronze = {0.68, 0.4, 0.17, 1},
        Rust = {0.58, 0.22, 0.08, 1},
        Tan = {0.78, 0.65, 0.43, 1},
    }

    local function colorForName(name)
        if COLOR_SWATCHES[name] then return COLOR_SWATCHES[name] end

        local key = tostring(name or ""):lower():gsub("[_%-%s]+", " ")
        if key:find("black", 1, true) then return COLOR_SWATCHES.Black end
        if key:find("white", 1, true) then return COLOR_SWATCHES.White end
        if key:find("ivory", 1, true) then return COLOR_SWATCHES.Ivory end
        if key:find("cream", 1, true) then return COLOR_SWATCHES.Cream end
        if key:find("beige", 1, true) then return COLOR_SWATCHES.Beige end
        if key:find("gray", 1, true) or key:find("grey", 1, true) then
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Gray"] end
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Dark Gray"] end
            return COLOR_SWATCHES.Gray
        end
        if key:find("silver", 1, true) then return COLOR_SWATCHES.Silver end
        if key:find("red", 1, true) or key:find("crimson", 1, true) then
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Red"] end
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Deep Red"] end
            return COLOR_SWATCHES.Red
        end
        if key:find("pink", 1, true) or key:find("rose", 1, true) then return COLOR_SWATCHES.Pink end
        if key:find("magenta", 1, true) then return COLOR_SWATCHES.Magenta end
        if key:find("purple", 1, true) or key:find("violet", 1, true) or key:find("lavender", 1, true) then
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Dark Purple"] end
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Purple"] end
            return COLOR_SWATCHES.Purple
        end
        if key:find("teal", 1, true) then
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Dark Teal"] end
            return COLOR_SWATCHES.Teal
        end
        if key:find("turquoise", 1, true) or key:find("aqua", 1, true) or key:find("cyan", 1, true) then return COLOR_SWATCHES.Cyan end
        if key:find("blue", 1, true) or key:find("navy", 1, true) then
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Blue"] end
            if key:find("dark", 1, true) or key:find("deep", 1, true) or key:find("navy", 1, true) then return COLOR_SWATCHES["Dark Blue"] end
            return COLOR_SWATCHES.Blue
        end
        if key:find("green", 1, true) then
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Green"] end
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Deep Green"] end
            return COLOR_SWATCHES.Green
        end
        if key:find("lime", 1, true) then return COLOR_SWATCHES.Lime end
        if key:find("olive", 1, true) then return COLOR_SWATCHES.Olive end
        if key:find("yellow", 1, true) then return COLOR_SWATCHES.Yellow end
        if key:find("gold", 1, true) then return COLOR_SWATCHES.Gold end
        if key:find("orange", 1, true) then return COLOR_SWATCHES.Orange end
        if key:find("copper", 1, true) then return COLOR_SWATCHES.Copper end
        if key:find("bronze", 1, true) then return COLOR_SWATCHES.Bronze end
        if key:find("rust", 1, true) then return COLOR_SWATCHES.Rust end
        if key:find("tan", 1, true) then return COLOR_SWATCHES.Tan end
        if key:find("brown", 1, true) then
            if key:find("light", 1, true) then return COLOR_SWATCHES["Light Brown"] end
            if key:find("dark", 1, true) or key:find("deep", 1, true) then return COLOR_SWATCHES["Dark Brown"] end
            return COLOR_SWATCHES.Brown
        end

        return {0.45, 0.45, 0.45, 1}
    end

    local function hasColorSelection(colors)
        if type(colors) ~= "table" then return false end
        for _, selected in pairs(colors) do
            if selected == true then return true end
        end
        return false
    end

    local function selectedColors()
        local f = F()
        if not f then return nil end

        f.colors = type(f.colors) == "table" and f.colors or {}
        if f.color and f.color ~= "ALL" then
            f.colors[f.color] = true
            f.color = "ALL"
        end

        return f.colors, f
    end

    local function colorSelected(value)
        local colors = selectedColors()
        return type(colors) == "table" and colors[value] == true
    end

    local function colorGrid(titleText, get, set, valuesFn)
        local r = headerRow(titleText)
        r.isColorGrid = true
        r._get = get
        r.swatches = {}

        local function ensureSwatches()
            local opts = valuesFn and valuesFn() or {}
            local needed = 0

            for i = 1, #opts do
                local opt = opts[i]
                if opt and not opt.separator and opt.value ~= "ALL" then
                    needed = needed + 1
                    local b = r.swatches[needed]
                    if not b then
                        b = CreateFrame("Button", nil, popup, "BackdropTemplate")
                        b:SetSize(34, 34)
                        b.fill = b:CreateTexture(nil, "ARTWORK")
                        b.fill:SetPoint("TOPLEFT", 3, -3)
                        b.fill:SetPoint("BOTTOMRIGHT", -3, 3)
                        b.fill:SetTexture("Interface\\Buttons\\WHITE8x8")
                        b.check = b:CreateTexture(nil, "OVERLAY")
                        b.check:SetSize(22, 22)
                        b.check:SetPoint("CENTER", 0, 0)
                        b.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        b.check:Hide()
                        r.swatches[needed] = b
                        popup._allElements[#popup._allElements + 1] = b
                        popup._allElements[#popup._allElements + 1] = b.fill
                        popup._allElements[#popup._allElements + 1] = b.check
                    end

                    local value = opt.value
                    local swatch = colorForName(value)
                    b._value = value
                    b.fill:SetColorTexture(swatch[1], swatch[2], swatch[3], swatch[4] or 1)
                    b:SetScript("OnClick", function(self)
                        local colors, f = selectedColors()
                        if not colors or not f then return end
                        local colorValue = self._value
                        if colors[colorValue] == true then
                            colors[colorValue] = nil
                        else
                            colors[colorValue] = true
                        end
                        f.color = "ALL"
                        set(colors)
                        if r.refresh then r.refresh() end
                        rebuild()
                    end)
                    b:SetScript("OnEnter", function(self)
                        self:SetBackdropBorderColor(unpack(T.accent))
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(value, nil, nil, nil, nil, true)
                        GameTooltip:Show()
                    end)
                    b:SetScript("OnLeave", function(self)
                        local selected = colorSelected(self._value)
                        local border = selected and T.accent or T.border
                        self:SetBackdropBorderColor(unpack(border))
                        GameTooltip:Hide()
                    end)
                end
            end

            for i = needed + 1, #r.swatches do
                r.swatches[i]:Hide()
            end

            r.count = needed
        end

        r.refresh = function()
            ensureSwatches()
            for i = 1, #r.swatches do
                local b = r.swatches[i]
                if b and b._value then
                    local selected = colorSelected(b._value)
                    U.Backdrop(b, C, selected and T.row or T.panel, selected and T.accent or T.border)
                    if b.check then b.check:SetShown(selected) end
                end
            end
        end

        popup._rows[#popup._rows + 1] = r
        r.refresh()
    end

    local function multiCheckGroup(titleText, selectedKey, valuesFn)
        local r = headerRow(titleText)
        r.isMultiCheckGroup = true
        r.buttons = {}
        r.selectedKey = selectedKey

        local function selectedTable()
            local f = F()
            if not f then return nil end
            f[selectedKey] = type(f[selectedKey]) == "table" and f[selectedKey] or {}
            return f[selectedKey], f
        end

        local function ensureButtons()
            local opts = valuesFn and valuesFn() or {}
            local needed = 0

            for i = 1, #opts do
                local opt = opts[i]
                if opt and not opt.separator then
                    needed = needed + 1
                    local b = r.buttons[needed]
                    if not b then
                        b = CreateFrame("Button", nil, popup, "BackdropTemplate")
                        b:SetHeight(24)
                        U.Backdrop(b, C, T.panel, T.border)
                        U.BindBorderHover(b, T.accent, T.border)

                        b.check = b:CreateTexture(nil, "OVERLAY")
                        b.check:SetSize(16, 16)
                        b.check:SetPoint("LEFT", 8, 0)
                        b.check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                        b.check:Hide()

                        b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                        b.label:SetPoint("LEFT", b.check, "RIGHT", 6, 0)
                        b.label:SetPoint("RIGHT", -56, 0)
                        b.label:SetJustifyH("LEFT")
                        TextColor(b.label, "text")

                        b.count = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                        b.count:SetPoint("RIGHT", -8, 0)
                        TextColor(b.count, "muted", 0.85)

                        r.buttons[needed] = b
                        popup._allElements[#popup._allElements + 1] = b
                        popup._allElements[#popup._allElements + 1] = b.check
                        popup._allElements[#popup._allElements + 1] = b.label
                        popup._allElements[#popup._allElements + 1] = b.count
                    end

                    b._value = opt.value
                    b.label:SetText(opt.text or tostring(opt.value))
                    b.count:SetText(opt.count and ("(" .. tostring(opt.count) .. ")") or "")
                    b:SetScript("OnClick", function(self)
                        local selected, f = selectedTable()
                        if not selected or not f then return end
                        local value = self._value
                        if selected[value] == true then
                            selected[value] = nil
                        else
                            selected[value] = true
                        end
                        if r.refresh then r.refresh() end
                        rebuild()
                    end)
                end
            end

            for i = needed + 1, #r.buttons do
                r.buttons[i]:Hide()
            end
            r.count = needed
        end

        r.refresh = function()
            ensureButtons()
            local selected = selectedTable() or {}
            for i = 1, #r.buttons do
                local b = r.buttons[i]
                if b and b._value then
                    local active = selected[b._value] == true
                    U.Backdrop(b, C, active and T.row or T.panel, active and T.accent or T.border)
                    if b.check then b.check:SetShown(active) end
                    TextColor(b.label, active and "highlight" or "text")
                end
            end
        end

        popup._rows[#popup._rows + 1] = r
        r.refresh()
    end

    local function collapsibleSection(titleText, isExpanded, onToggle)
        local r = {}
        r.isCollapsible = true
        r.isExpanded = isExpanded

        local header = CreateFrame("Button", nil, popup, "BackdropTemplate")
        header:SetHeight(28)
        U.Backdrop(header, C, T.header, T.border)
        U.BindBorderHover(header, T.accent, T.border)

        local arrow = header:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(12, 12)
        arrow:SetPoint("LEFT", 8, 0)
        arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")

        local label = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", arrow, "RIGHT", 6, 0)
        label:SetText(titleText)
        TextColor(label, "accent")

        local function updateArrow()
            if r.isExpanded then
                arrow:SetRotation(math.rad(90))
            else
                arrow:SetRotation(0)
            end
        end

        header:SetScript("OnClick", function()
            r.isExpanded = not r.isExpanded
            updateArrow()
            if onToggle then onToggle(r.isExpanded) end
            popup:Refresh()
        end)

        updateArrow()
        r.header = header
        popup._rows[#popup._rows + 1] = r

        popup._allElements[#popup._allElements + 1] = header
        popup._allElements[#popup._allElements + 1] = arrow
        popup._allElements[#popup._allElements + 1] = label

        return r
    end

    local function spacer(height)
        local r = {}
        r.isSpacer = true
        r.height = height or 8
        popup._rows[#popup._rows + 1] = r
    end

    local function hardReset()
        local db = ensureDB()
        local f = db and db.filters
        if not f then return end

        f.expansion, f.zone, f.color, f.sourceType, f.category, f.subcategory, f.faction = "ALL", "ALL", "ALL", "ALL", "ALL", "ALL", "ALL"
        f.colors = {}
        f.budgetCosts = {}
        f.sizes = {}
        f.hideCollected, f.onlyCollected = false, false

        f.availableRepOnly = false
        f.requiresReputation = false
        f.questsCompleted = false
        f.achievementCompleted = false
        f.hidePvpItems = false

        syncAll()
        rebuild()
    end

    popup.ResetAllFilters = function()
        hardReset()
    end

    popup.SyncVisuals = function()
        syncAll()
    end

    local function createTabButton(text, tabId)
        local btn = CreateFrame("Button", nil, popup, "BackdropTemplate")
        btn:SetHeight(26)
        U.Backdrop(btn, C, T.panel, T.border)

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        btn.text:SetPoint("CENTER")
        btn.text:SetText(text)
        TextColor(btn.text, "text")

        btn._tabId = tabId
        popup._tabs[#popup._tabs + 1] = btn

        btn:SetScript("OnClick", function()
            popup._activeTab = tabId
            popup:BuildContent()
            popup:UpdateTabs()
            popup:Refresh()
        end)

        return btn
    end

    if #popup._tabs == 0 then
        createTabButton(L["FILTER_TAB_FILTERS"], "filters")
        createTabButton(L["FILTER_TAB_COMPLETED"], "completion")
    end

    function popup:UpdateTabs()
        for i = 1, #self._tabs do
            local btn = self._tabs[i]
            local isActive = (btn._tabId == self._activeTab)

            if isActive then
                U.Backdrop(btn, C, T.row, T.accent)
                TextColor(btn.text, "highlight")
            else
                U.Backdrop(btn, C, T.panel, T.border)
                TextColor(btn.text, "text", 0.9)
            end
        end
    end

    function popup:BuildContent()
        wipe(popup._rows)

        if popup._allElements then
            for i = 1, #popup._allElements do
                local elem = popup._allElements[i]
                if elem and elem.Hide then
                    elem:Hide()
                end
            end
        end
        popup._allElements = popup._allElements or {}
        wipe(popup._allElements)

        if self._activeTab == "filters" then
            ddRow("Sort",
                function()
                    local db = ensureDB()
                    db.ui = db.ui or {}
                    return db.ui.sortMode or "expAsc"
                end,
                function(v)
                    local db = ensureDB()
                    if not db then return end
                    db.ui = db.ui or {}
                    db.ui.sortMode = v or "expAsc"
                end,
                function()
                    return {
                        { value = "expAsc", text = "Expansion: Old to New" },
                        { value = "expDesc", text = "Expansion: New to Old" },
                    }
                end)

            spacer(8)

            checkRow(L["FILTER_HIDE_COMPLETED_ROW"],
                function() local f = F(); return (f and f.hideCollected) == true end,
                function(v) local f = F(); if f then f.hideCollected = (v == true); if v then f.onlyCollected = false end end end,
                true)

            spacer(8)

            checkRow(L["FILTER_HIDE_PVP_ROW"],
                function() local f = F(); return (f and f.hidePvpItems) == true end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.hidePvpItems = (v == true)
                end,
                true,
                L["FILTER_HIDE_PVP_HINT"])

            spacer(8)

            checkRow("Requires Reputation",
                function() local f = F(); return (f and f.requiresReputation) == true end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.requiresReputation = (v == true)
                end,
                true,
                "Show only items that require a reputation standing to unlock.")

            spacer(8)

            ddRow(L["FILTER_FACTION_ROW"],
                function() local f = F(); return (f and f.faction) or "ALL" end,
                function(v) local f = F(); if f then f.faction = v or "ALL" end end,
                function()
                    return {
                        { value = "ALL", text = L["ALL_FACTIONS"] },
                        { value = "Alliance", text = L["FILTER_ALLIANCE"] },
                        { value = "Horde", text = L["FILTER_HORDE"] },
                    }
                end,
                true)

            ddRow("Source",
                function() local f = F(); return (f and f.sourceType) or "ALL" end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.sourceType = v or "ALL"
                end,
                function()
                    return {
                        { value = "ALL", text = "Source: All" },
                        { value = "vendor", text = "Vendors" },
                        { value = "quest", text = "Quests" },
                        { value = "achievement", text = "Achievements" },
                        { value = "drop", text = "Drops" },
                        { value = "profession", text = "Professions" },
                        { value = "event", text = "Events" },
                        { value = "pvp", text = "PvP" },
                    }
                end,
                true)

            ddRow(L["FILTER_EXPANSION_ROW"],
                function()
                    local f = F()
                    return (f and f.expansion) or "ALL"
                end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.expansion = v or "ALL"
                    f.zone = "ALL"
                end,
                function()
                    local out, seen = { { value = "ALL", text = L["ALL_EXPANSIONS"] } }, {}
                    local vendors = NS.Data and NS.Data.Vendors
                    if type(vendors) == "table" then
                        for exp in pairs(vendors) do
                            if not seen[exp] then
                                seen[exp] = true
                                out[#out + 1] = { value = exp, text = exp }
                            end
                        end
                    end
                    table.sort(out, function(a, b) return a.text < b.text end)
                    return insertAllSeparator(out)
                end,
                true)

            ddRow(L["FILTER_ZONE_ROW"],
                function()
                    local f = F()
                    return (f and f.zone) or "ALL"
                end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.zone = v or "ALL"
                end,
                function()
                    local out, seen = { { value = "ALL", text = L["ALL_ZONES"] } }, {}
                    local f = F()
                    local exp = (f and f.expansion) or "ALL"
                    local vendors = NS.Data and NS.Data.Vendors

                    local function add(z)
                        if type(z) == "string" and z ~= "" and not seen[z] then
                            seen[z] = true
                            out[#out + 1] = { value = z, text = z }
                        end
                    end

                    local function scan(expTbl)
                        for _, zoneTbl in pairs(expTbl or {}) do
                            if type(zoneTbl) == "table" then
                                for _, vendor in ipairs(zoneTbl) do
                                    local src = vendor and vendor.source
                                    if src then add(src.zone) end
                                end
                            end
                        end
                    end

                    if type(vendors) == "table" then
                        if exp ~= "ALL" and type(vendors[exp]) == "table" then
                            scan(vendors[exp])
                        else
                            for _, expTbl in pairs(vendors) do
                                if type(expTbl) == "table" then scan(expTbl) end
                            end
                        end
                    end

                    table.sort(out, function(a, b) return a.text < b.text end)
                    return insertAllSeparator(out)
                end,
                true)

            colorGrid("Colors",
                function()
                    local f = F()
                    if f then f.colors = type(f.colors) == "table" and f.colors or {} end
                    return f and f.colors or {}
                end,
                function(colors)
                    local f = F()
                    if not f then return end
                    f.colors = type(colors) == "table" and colors or {}
                    f.color = "ALL"
                end,
                function()
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    return FS and FS.GetColorOptions and FS:GetColorOptions(UI) or { { value = "ALL", text = "All Colors" } }
                end)

            spacer(8)

            multiCheckGroup("Budget Cost", "budgetCosts", function()
                local FS = NS and NS.Systems and NS.Systems.Filters
                return FS and FS.GetBudgetCostOptions and FS:GetBudgetCostOptions() or {
                    { value = "low", text = "1-2 (Low)" },
                    { value = "medium", text = "3-4 (Medium)" },
                    { value = "high", text = "5+ (High)" },
                    { value = "none", text = "No Budget Cost" },
                }
            end)

            spacer(8)

            multiCheckGroup("Size", "sizes", function()
                local FS = NS and NS.Systems and NS.Systems.Filters
                return FS and FS.GetSizeOptions and FS:GetSizeOptions() or {
                    { value = "Huge", text = "Huge" },
                    { value = "Large", text = "Large" },
                    { value = "Medium", text = "Medium" },
                    { value = "Small", text = "Small" },
                    { value = "Tiny", text = "Tiny" },
                }
            end)

            ddRow(L["FILTER_CATEGORY_ROW"],
                function()
                    local f = F()
                    local v = (f and f.category) or "ALL"
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    if FS and FS.ResolveCategoryID then
                        local nv = FS:ResolveCategoryID(v)
                        if f and nv ~= v then f.category = nv end
                        v = nv
                    end
                    return v
                end,
                function(v)
                    local f = F()
                    if not f then return end
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    local nv = v or "ALL"
                    if FS and FS.ResolveCategoryID then nv = FS:ResolveCategoryID(nv) end
                    f.category = nv
                    f.subcategory = "ALL"
                end,
                function()
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    if FS and FS.GetCategoryOptions then
                        return FS:GetCategoryOptions()
                    end
                    return { { value = "ALL", text = L["ALL_CATEGORIES"] } }
                end
            )

            ddRow(L["FILTER_SUBCATEGORY_ROW"],
                function()
                    local f = F()
                    local v = (f and f.subcategory) or "ALL"
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    if FS and FS.ResolveSubcategoryID then
                        local nv = FS:ResolveSubcategoryID(v)
                        if f and nv ~= v then f.subcategory = nv end
                        v = nv
                    end
                    return v
                end,
                function(v)
                    local f = F()
                    if not f then return end
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    local nv = v or "ALL"
                    if FS and FS.ResolveSubcategoryID then nv = FS:ResolveSubcategoryID(nv) end
                    f.subcategory = nv
                end,
                function()
                    local f = F()
                    local cat = (f and f.category) or "ALL"
                    local FS = NS and NS.Systems and NS.Systems.Filters
                    if FS and FS.GetSubcategoryOptions then
                        return FS:GetSubcategoryOptions(cat)
                    end
                    return { { value = "ALL", text = L["ALL_SUBCATEGORIES"] } }
                end
            )

        elseif self._activeTab == "completion" then
            checkRow(L["FILTER_REPUTATION_ROW"],
                function() local f = F(); return (f and f.availableRepOnly) == true end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.availableRepOnly = (v == true)
                    local db = ensureDB()
                    local ui = db and db.ui
                    if ui then
                        ui.activeCategory = "Vendors"
                    end
                    if NS.UI and NS.UI.Layout and NS.UI.Layout.Render then
                        NS.UI.Layout:Render()
                    end
                end,
                true,
                L["FILTER_ALTS_REP_HINT"])

            checkRow(L["FILTER_QUESTS_ROW"],
                function() local f = F(); return (f and f.questsCompleted) == true end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.questsCompleted = (v == true)
                end,
                true,
                L["FILTER_ALTS_QUEST_HINT"])

            checkRow(L["FILTER_ACHIEVEMENT_ROW"],
                function() local f = F(); return (f and f.achievementCompleted) == true end,
                function(v)
                    local f = F()
                    if not f then return end
                    f.achievementCompleted = (v == true)
                end,
                true,
                L["FILTER_ACH_COMPLETED_HINT"])
        end
    end

    function popup:Refresh()
        local tabWidth = (popup:GetWidth() or 200) / 2
        for i = 1, #self._tabs do
            local btn = self._tabs[i]
            btn:ClearAllPoints()
            btn:SetWidth(tabWidth - 8)
            if i == 1 then
                btn:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4)
            else
                btn:SetPoint("LEFT", self._tabs[i-1], "RIGHT", 4, 0)
            end
        end

        local y = -38
        local left, right = 6, 6

        for i = 1, #self._rows do
            local r = self._rows[i]

            if r.isSpacer then
                y = y - r.height
            elseif r.isCollapsible then
                r.header:Show()
                r.header:ClearAllPoints()
                r.header:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.header:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                y = y - 32
            elseif r.isCheck then
                r.dd:Show()
                r.dd:ClearAllPoints()
                r.dd:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.dd:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                r.dd:SetHeight(26)
                y = y - 32
            elseif r.isColorGrid then
                if r.refresh then r.refresh() end

                r.title:Show()
                r.line:Show()

                r.title:ClearAllPoints()
                r.title:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                y = y - 20

                r.line:ClearAllPoints()
                r.line:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.line:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                y = y - 10

                local count = r.count or 0
                local cols, gap, size = 5, 8, 34
                for j = 1, #r.swatches do
                    local btn = r.swatches[j]
                    if j <= count then
                        btn:Show()
                        btn:ClearAllPoints()
                        btn:SetSize(size, size)
                        local col = (j - 1) % cols
                        local row = math.floor((j - 1) / cols)
                        btn:SetPoint("TOPLEFT", self, "TOPLEFT", left + (col * (size + gap)), y - (row * (size + gap)))
                    else
                        btn:Hide()
                    end
                end

                local rows = math.max(1, math.ceil(count / cols))
                y = y - (rows * size) - ((rows - 1) * gap) - 10
            elseif r.isMultiCheckGroup then
                if r.refresh then r.refresh() end

                r.title:Show()
                r.line:Show()

                r.title:ClearAllPoints()
                r.title:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                y = y - 20

                r.line:ClearAllPoints()
                r.line:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.line:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                y = y - 8

                local count = r.count or 0
                for j = 1, #r.buttons do
                    local btn = r.buttons[j]
                    if j <= count then
                        btn:Show()
                        btn:ClearAllPoints()
                        btn:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                        btn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                        btn:SetHeight(24)
                        y = y - 28
                    else
                        btn:Hide()
                    end
                end
                y = y - 4
            else
                r.title:Show()
                r.line:Show()
                r.dd:Show()

                r.title:ClearAllPoints()
                r.title:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                y = y - 20

                r.line:ClearAllPoints()
                r.line:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.line:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                y = y - 10

                r.dd:ClearAllPoints()
                r.dd:SetPoint("TOPLEFT", self, "TOPLEFT", left, y)
                r.dd:SetPoint("TOPRIGHT", self, "TOPRIGHT", -right, y)
                r.dd:SetHeight(26)
                y = y - 30
            end
        end

        self:SetHeight(-y + 12)
    end

    popup:BuildContent()
    popup:UpdateTabs()
    popup:Refresh()
end

return M
