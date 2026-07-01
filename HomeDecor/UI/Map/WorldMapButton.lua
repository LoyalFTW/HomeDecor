local ADDON, NS = ...
local L = NS.L
NS.UI = NS.UI or {}

local function GetColors()
    local theme = NS.UI and NS.UI.Theme
    return theme and theme.colors, theme and theme.textures
end

local function ensureProfile()
    local prof = NS.db and NS.db.profile
    if not prof then return nil end
    prof.mapPins = prof.mapPins or {}
    if prof.mapPins.minimap   == nil then prof.mapPins.minimap   = true    end
    if prof.mapPins.worldmap  == nil then prof.mapPins.worldmap  = true    end
    if prof.mapPins.pinStyle  == nil then prof.mapPins.pinStyle  = "house" end
    if prof.mapPins.pinSize   == nil then prof.mapPins.pinSize   = 1.0     end
    if prof.mapPins.pinTooltipAnchor == nil then prof.mapPins.pinTooltipAnchor = "ANCHOR_RIGHT" end
    if prof.mapPins.showZoneOverlay == nil then prof.mapPins.showZoneOverlay = true end
    if prof.mapPins.zoneOverlayPosition == nil then prof.mapPins.zoneOverlayPosition = "topLeft" end
    if prof.mapPins.zoneOverlayAlpha == nil then prof.mapPins.zoneOverlayAlpha = 0.90 end
    if prof.mapPins.zoneOverlayIncludeCollected == nil then prof.mapPins.zoneOverlayIncludeCollected = false end
    if prof.mapPins.zoneOverlayMinimized == nil then prof.mapPins.zoneOverlayMinimized = true end
    if prof.mapPins.pinColor  == nil or type(prof.mapPins.pinColor) ~= "table" then
        prof.mapPins.pinColor = { r = 1.0, g = 1.0, b = 1.0 }
    end
    prof.tracker = prof.tracker or {}
    if prof.tracker.hideCompleted        == nil then prof.tracker.hideCompleted        = false end
    if prof.tracker.hideCompletedVendors == nil then prof.tracker.hideCompletedVendors = false end
    return prof
end

local function refreshPins()
    local MP = NS.Systems and NS.Systems.MapPins
    if not MP then return end
    if MP.RefreshCurrentZone then pcall(function() MP:RefreshCurrentZone() end) end
    if MP.RefreshWorldMap    then pcall(function() MP:RefreshWorldMap()    end) end
end

local function applyTrackerFlag(key, value)
    local frame = NS.UI and NS.UI.Tracker and NS.UI.Tracker.frame
    if frame then
        frame[key] = value
        if frame.RequestRefresh then frame:RequestRefresh("worldmapbtn") end
    end
    local p = ensureProfile()
    if p then p.tracker[key:sub(2)] = value end
    local MP = NS.UI and NS.UI.MapPopup
    if MP and MP.frame and MP.frame:IsShown() then
        pcall(function() MP:Refresh() end)
    end
    refreshPins()
end

local dropPanel = nil
local zonePanel = nil
local UpdateZoneOverlayVisibility
local PositionZonePanel

local function hideDropPanel()
    if dropPanel then dropPanel:Hide() end
end

local function hideZonePanel()
    if zonePanel then zonePanel:Hide() end
end

local PIN_STYLES = {
    { value = "house", label = L["OPT_PIN_HOUSE"] },
    { value = "dot", label = L["OPT_PIN_DOT"] },
}

local PANEL_W   = 260
local ZONE_PANEL_W = 300
local ROW_H     = 22
local SEC_H     = 18
local PAD       = 6
local GAP       = 4
local ZONE_H    = 330
local ZONE_ROW_H = 34

local function SavePanelPosition(f)
    local p = NS.db and NS.db.profile and NS.db.profile.mapPins
    if not p or not f then return end
    local point, _, relPoint, x, y = f:GetPoint()
    p.panelPoint    = point
    p.panelRelPoint = relPoint
    p.panelX        = x
    p.panelY        = y
end

local function RestorePanelPosition(f, anchorBtn)
    local p = NS.db and NS.db.profile and NS.db.profile.mapPins
    f:ClearAllPoints()
    if p and p.panelPoint and p.panelX and p.panelY then
        f:SetPoint(p.panelPoint, UIParent, p.panelRelPoint or p.panelPoint, p.panelX, p.panelY)
    else
        f:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -4)
    end
end

local function GetCurrentWorldMapID()
    if WorldMapFrame and WorldMapFrame.GetMapID then
        return tonumber(WorldMapFrame:GetMapID())
    end
end

local function GetMapName(mapID)
    if mapID and C_Map and C_Map.GetMapInfo then
        local info = C_Map.GetMapInfo(mapID)
        if info and info.name then return info.name end
    end
    return "Current Map"
end

local function IsWorldMap(mapID)
    if not (mapID and C_Map and C_Map.GetMapInfo and Enum and Enum.UIMapType) then return false end
    local info = C_Map.GetMapInfo(mapID)
    return info and (info.mapType == Enum.UIMapType.World or info.mapType == Enum.UIMapType.Cosmic)
end

local function GetZoneVendorList(mapID)
    local D = NS.Systems and NS.Systems.MapPinsData
    if not (D and D.GetVendorsForMap) then return {} end

    local out, seen = {}, {}
    local function addVendorList(vendorList, zoneMapID)
        if type(vendorList) ~= "table" then return end
        if D.ResolveNamesFor then D.ResolveNamesFor(vendorList) end
        local zoneName = GetMapName(zoneMapID)
        for i = 1, #vendorList do
            local vendor = vendorList[i]
            local id = vendor and tonumber(vendor.id)
            if id and not seen[id] then
                seen[id] = true
                vendor.zone = vendor.zone or zoneName
                vendor.zoneMapID = vendor.zoneMapID or zoneMapID
                out[#out + 1] = vendor
            end
        end
    end

    addVendorList(D.GetVendorsForMap(mapID), mapID)

    if D.EnsureWorldIndex then D.EnsureWorldIndex() end
    if IsWorldMap(mapID) then
        for zoneMapID in pairs(D.zoneToContinent or {}) do
            if not (D.SPECIAL_ZONES and D.SPECIAL_ZONES[zoneMapID]) then
                addVendorList(D.GetVendorsForMap(zoneMapID), zoneMapID)
            end
        end
        for specialZoneID in pairs(D.SPECIAL_ZONES or {}) do
            addVendorList(D.GetVendorsForMap(specialZoneID), specialZoneID)
        end
    else
        for zoneMapID, continentID in pairs(D.zoneToContinent or {}) do
            if continentID == mapID and not (D.SPECIAL_ZONES and D.SPECIAL_ZONES[zoneMapID]) then
                addVendorList(D.GetVendorsForMap(zoneMapID), zoneMapID)
            end
        end
        for srcContinentID, destContinentID in pairs(D.continentZoneBadgesOnParent or {}) do
            if destContinentID == mapID then
                local excludedBySource = D.continentZoneBadgeExclusionsOnParent and D.continentZoneBadgeExclusionsOnParent[srcContinentID]
                local excludedForDest = excludedBySource and excludedBySource[mapID]
                for zoneMapID, continentID in pairs(D.zoneToContinent or {}) do
                    if continentID == srcContinentID and not (D.SPECIAL_ZONES and D.SPECIAL_ZONES[zoneMapID]) and not (excludedForDest and excludedForDest[zoneMapID]) then
                        addVendorList(D.GetVendorsForMap(zoneMapID), zoneMapID)
                    end
                end
            end
        end
    end

    table.sort(out, function(a, b)
        local az = tostring(a.zone or "")
        local bz = tostring(b.zone or "")
        if az ~= bz then return az < bz end
        return tostring(a.name or a.id or "") < tostring(b.name or b.id or "")
    end)
    return out
end

local function buildDropPanel()
    if dropPanel then return dropPanel end

    local C      = NS.UI.Controls
    local colors = GetColors()

    local f = CreateFrame("Frame", "HomeDecorMapButtonDropPanel", UIParent, "BackdropTemplate")
    f:SetWidth(PANEL_W)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(200)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    if C then C:Backdrop(f, colors and colors.bg, colors and colors.border) end

    WorldMapFrame:HookScript("OnHide", hideDropPanel)
    f:Hide()

    local y = 0

    local TITLE_H = 28
    local titleBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -1)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
    titleBar:SetHeight(TITLE_H)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop",  function()
        f:StopMovingOrSizing()
        SavePanelPosition(f)
    end)
    if C then C:Backdrop(titleBar, colors and colors.header, colors and colors.border) end

    local dragHint = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dragHint:SetPoint("LEFT", titleBar, "LEFT", 8, 0)
    dragHint:SetText("Home|cffff7d0aDecor|r")

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
    local closeFS = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeFS:SetAllPoints(); closeFS:SetJustifyH("CENTER")
    closeFS:SetText("|cff888888x|r")
    closeBtn:SetScript("OnClick",  hideDropPanel)
    closeBtn:SetScript("OnEnter",  function() closeFS:SetText("|cffff7d0ax|r") end)
    closeBtn:SetScript("OnLeave",  function() closeFS:SetText("|cff888888x|r") end)

    y = y + TITLE_H + 2

    local function addSection(label)
        local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
        bar:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -(y + 1))
        bar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -(y + 1))
        bar:SetHeight(SEC_H)
        if C then C:Backdrop(bar, colors and colors.header, colors and colors.border) end
        local lbl = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT", bar, "LEFT", 8, 0)
        lbl:SetTextColor(unpack(colors and colors.accent or {0.9, 0.72, 0.18}))
        lbl:SetText(label:upper())
        y = y + SEC_H + GAP
    end

    local function addCheck(label, getter, setter)
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        row:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -y)
        row:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -y)
        row:SetHeight(ROW_H)
        if C then C:Backdrop(row, colors and colors.row, colors and colors.border) end

        local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        cb:SetSize(18, 18)
        cb:SetPoint("LEFT", row, "LEFT", 6, 0)
        cb:SetChecked(getter())
        cb:SetScript("OnClick", function(self) setter(self:GetChecked() and true or false) end)

        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lbl:SetPoint("LEFT", cb, "RIGHT", 3, 0)
        lbl:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        lbl:SetTextColor(unpack(colors and colors.text or {0.92, 0.92, 0.92}))
        lbl:SetText(label)

        cb.Sync = function() cb:SetChecked(getter()) end
        y = y + ROW_H + GAP
        return cb
    end

    local function addRow(label, buildFn)
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        row:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -y)
        row:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -y)
        row:SetHeight(ROW_H)
        if C then C:Backdrop(row, colors and colors.row, colors and colors.border) end

        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lbl:SetPoint("LEFT", row, "LEFT", 10, 0)
        lbl:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
        lbl:SetText(label)

        buildFn(row, lbl)
        y = y + ROW_H + GAP
        return row
    end

    addSection("Decor Overlay")
    local cbOverlay = addCheck("Show zone decor overlay",
        function() local p = ensureProfile(); return p and p.mapPins.showZoneOverlay ~= false end,
        function(v)
            local p = ensureProfile(); if not p then return end
            p.mapPins.showZoneOverlay = v
            if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
        end)
    y = y + 2

    addSection(L["MAP_PANEL_MAP_PINS"])
    local cbWorld = addCheck(L["MAP_PANEL_SHOW_WORLDMAP"],
        function() local p = ensureProfile(); return p and p.mapPins.worldmap ~= false end,
        function(v) local p = ensureProfile(); if p then p.mapPins.worldmap = v; refreshPins() end end)
    local cbMini  = addCheck(L["MAP_PANEL_SHOW_MINIMAP"],
        function() local p = ensureProfile(); return p and p.mapPins.minimap ~= false end,
        function(v) local p = ensureProfile(); if p then p.mapPins.minimap = v; refreshPins() end end)
    y = y + 2

    addSection(L["MAP_PANEL_VENDOR_TRACKER"])
    local cbHideColl = addCheck(L["MAP_PANEL_HIDE_COLLECTED"],
        function() local p = ensureProfile(); return p and p.tracker.hideCompleted == true end,
        function(v) applyTrackerFlag("_hideCompleted", v) end)
    local cbHideVend = addCheck(L["MAP_PANEL_HIDE_COMPLETED_VEND"],
        function() local p = ensureProfile(); return p and p.tracker.hideCompletedVendors == true end,
        function(v) applyTrackerFlag("_hideCompletedVendors", v) end)
    y = y + 2

    addSection(L["MAP_PANEL_PIN_APPEARANCE"])

    local styleControl
    addRow(L["MAP_PANEL_STYLE"], function(row, lbl)
        local styleValues = {}
        for _, e in ipairs(PIN_STYLES) do styleValues[#styleValues+1] = e.label end

        if C and C.Segmented then
            local BTN_W = 82
            local BTN_H = 18
            local BTN_PAD = 2
            local totalW = #styleValues * BTN_W + (#styleValues - 1) * BTN_PAD

            local seg = CreateFrame("Frame", nil, row)
            seg:SetSize(totalW, BTN_H)
            seg:SetPoint("RIGHT",  row, "RIGHT",  -6, 0)

            local btns = {}
            local function styleRefresh()
                local p  = ensureProfile()
                local cur = p and p.mapPins.pinStyle or "house"
                for i, btn in ipairs(btns) do
                    local isActive = (PIN_STYLES[i].value == cur)
                    if btn.bg then
                        btn.bg:SetVertexColor(
                            isActive and 0.90 or 0.13,
                            isActive and 0.72 or 0.13,
                            isActive and 0.18 or 0.15,
                            isActive and 0.30 or 1.0)
                    end
                    btn.txt:SetTextColor(
                        isActive and 1.0  or (colors and colors.textMuted or {0.65,0.65,0.68})[1],
                        isActive and 0.95 or (colors and colors.textMuted or {0.65,0.65,0.68})[2],
                        isActive and 0.6  or (colors and colors.textMuted or {0.65,0.65,0.68})[3])
                end
            end

            for i, entry in ipairs(PIN_STYLES) do
                local btn = CreateFrame("Button", nil, seg, "BackdropTemplate")
                btn:SetSize(BTN_W, BTN_H)
                if i == 1 then
                    btn:SetPoint("LEFT", seg, "LEFT", 0, 0)
                else
                    btn:SetPoint("LEFT", btns[i-1], "RIGHT", BTN_PAD, 0)
                end
                if C then C:Backdrop(btn, colors and colors.panel, colors and colors.border) end

                btn.bg = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
                btn.bg:SetAllPoints()
                btn.bg:SetColorTexture(0.13, 0.13, 0.15, 1)

                btn.txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                btn.txt:SetAllPoints()
                btn.txt:SetJustifyH("CENTER")
                btn.txt:SetText(entry.label)

                btn:SetScript("OnClick", function()
                    local p = ensureProfile(); if not p then return end
                    p.mapPins.pinStyle = entry.value
                    styleRefresh()
                    refreshPins()
                end)

                btns[i] = btn
            end

            styleControl = seg
            styleControl.Refresh = styleRefresh
            styleRefresh()
        end
    end)

    local swatch
    addRow(L["MAP_PANEL_COLOR"], function(row, lbl)
        local swatchBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
        swatchBtn:SetSize(18, 18)
        swatchBtn:SetPoint("RIGHT", row, "RIGHT", -40, 0)
        if C then C:Backdrop(swatchBtn, {0, 0, 0, 0.7}, colors and colors.border) end

        swatch = swatchBtn:CreateTexture(nil, "ARTWORK")
        swatch:SetPoint("TOPLEFT", 2, -2)
        swatch:SetPoint("BOTTOMRIGHT", -2, 2)
        swatch:SetColorTexture(1, 1, 1)

        local resetBtn = CreateFrame("Button", nil, row, "BackdropTemplate")
        resetBtn:SetSize(34, 16)
        resetBtn:SetPoint("LEFT", swatchBtn, "RIGHT", 3, 0)
        if C then
            C:Backdrop(resetBtn, colors and colors.panel, colors and colors.border)
            C:ApplyHover(resetBtn, colors and colors.panel, colors and colors.hover,
                                   colors and colors.border, colors and colors.accentSoft)
        end
        local rTxt = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rTxt:SetAllPoints(); rTxt:SetJustifyH("CENTER")
        rTxt:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
        rTxt:SetText(L["RESET"])

        resetBtn:SetScript("OnClick", function()
            local p = ensureProfile(); if not p then return end
            p.mapPins.pinColor = { r = 1, g = 1, b = 1 }
            swatch:SetColorTexture(1, 1, 1)
            refreshPins()
        end)
        swatchBtn:SetScript("OnClick", function()
            if not _G.ColorPickerFrame then return end
            local p = ensureProfile(); if not p then return end
            _G.ColorPickerFrame:SetupColorPickerAndShow({
                r = p.mapPins.pinColor.r, g = p.mapPins.pinColor.g, b = p.mapPins.pinColor.b,
                hasOpacity = false,
                swatchFunc = function()
                    local r, g, b = _G.ColorPickerFrame:GetColorRGB()
                    p.mapPins.pinColor.r, p.mapPins.pinColor.g, p.mapPins.pinColor.b = r, g, b
                    swatch:SetColorTexture(r, g, b); refreshPins()
                end,
                cancelFunc = function(restore)
                    p.mapPins.pinColor.r, p.mapPins.pinColor.g, p.mapPins.pinColor.b = restore.r, restore.g, restore.b
                    swatch:SetColorTexture(restore.r, restore.g, restore.b); refreshPins()
                end,
            })
        end)
    end)

    local slider, sizeVal
    local SLIDER_ROW_H = 42
    do
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        row:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -y)
        row:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -y)
        row:SetHeight(SLIDER_ROW_H)
        if C then C:Backdrop(row, colors and colors.row, colors and colors.border) end

        local lbl = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lbl:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -6)
        lbl:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
        lbl:SetText(L["SIZE"])

        sizeVal = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        sizeVal:SetPoint("LEFT", lbl, "RIGHT", 6, 0)
        sizeVal:SetTextColor(unpack(colors and colors.accent or {0.9, 0.72, 0.18}))

        slider = CreateFrame("Slider", nil, row, "OptionsSliderTemplate")
        slider:SetSize(PANEL_W - 24, 14)
        slider:SetPoint("BOTTOMLEFT",  row, "BOTTOMLEFT",  10, 7)
        slider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -10, 7)
        slider:SetMinMaxValues(0.5, 2.0)
        slider:SetValueStep(0.1)
        slider:SetObeyStepOnDrag(true)
        slider.Low:SetText("")
        slider.High:SetText("")
        slider.Low:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
        slider.High:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))

        slider:SetScript("OnValueChanged", function(self, val)
            val = math.floor(val * 10 + 0.5) / 10
            local p = ensureProfile(); if not p then return end
            p.mapPins.pinSize = val
            sizeVal:SetText(string.format("%.1fx", val))
            refreshPins()
        end)

        y = y + SLIDER_ROW_H + GAP
    end

    y = y + 2
    addSection(L["MAP_PANEL_TOOLTIP_ANCHOR_SECTION"] or "TOOLTIP POSITION")

    local ANCHOR_OPTIONS = {
        { value = "ANCHOR_LEFT",   label = L["ANCHOR_LEFT"]   or "Left"   },
        { value = "ANCHOR_RIGHT",  label = L["ANCHOR_RIGHT"]  or "Right"  },
        { value = "ANCHOR_MIDDLE", label = L["ANCHOR_MIDDLE"] or "Middle" },
        { value = "ANCHOR_BOTTOM", label = L["ANCHOR_BOTTOM"] or "Bottom" },
        { value = "ANCHOR_CURSOR", label = L["ANCHOR_CURSOR"] or "Cursor" },
    }

    local anchorSegBtns = {}
    local anchorSegControl

    do
        local row = CreateFrame("Frame", nil, f, "BackdropTemplate")
        row:SetPoint("TOPLEFT",  f, "TOPLEFT",  1, -y)
        row:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -y)
        row:SetHeight(ROW_H)
        if C then C:Backdrop(row, colors and colors.row, colors and colors.border) end

        local C      = NS.UI.Controls
        local colors = GetColors()
        local BTN_W  = 48
        local BTN_H  = 18
        local BTN_PAD = 2
        local totalW = #ANCHOR_OPTIONS * BTN_W + (#ANCHOR_OPTIONS - 1) * BTN_PAD

        local seg = CreateFrame("Frame", nil, row)
        seg:SetSize(totalW, BTN_H)
        seg:SetPoint("CENTER", row, "CENTER", 0, 0)

        local function anchorRefresh()
            local p   = ensureProfile()
            local cur = p and p.mapPins.pinTooltipAnchor or "ANCHOR_RIGHT"
            for i, btn in ipairs(anchorSegBtns) do
                local isActive = (ANCHOR_OPTIONS[i].value == cur)
                if btn.bg then
                    btn.bg:SetVertexColor(
                        isActive and 0.90 or 0.13,
                        isActive and 0.72 or 0.13,
                        isActive and 0.18 or 0.15,
                        isActive and 0.30 or 1.0)
                end
                btn.txt:SetTextColor(
                    isActive and 1.0  or (colors and colors.textMuted or {0.65,0.65,0.68})[1],
                    isActive and 0.95 or (colors and colors.textMuted or {0.65,0.65,0.68})[2],
                    isActive and 0.6  or (colors and colors.textMuted or {0.65,0.65,0.68})[3])
            end
        end

        for i, entry in ipairs(ANCHOR_OPTIONS) do
            local btn = CreateFrame("Button", nil, seg, "BackdropTemplate")
            btn:SetSize(BTN_W, BTN_H)
            if i == 1 then
                btn:SetPoint("LEFT", seg, "LEFT", 0, 0)
            else
                btn:SetPoint("LEFT", anchorSegBtns[i-1], "RIGHT", BTN_PAD, 0)
            end
            if C then C:Backdrop(btn, colors and colors.panel, colors and colors.border) end

            btn.bg = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.13, 0.13, 0.15, 1)

            btn.txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.txt:SetAllPoints()
            btn.txt:SetJustifyH("CENTER")
            btn.txt:SetText(entry.label)

            btn:SetScript("OnClick", function()
                local p = ensureProfile(); if not p then return end
                p.mapPins.pinTooltipAnchor = entry.value
                anchorRefresh()
            end)
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(entry.label, 1, 1, 1)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            anchorSegBtns[i] = btn
        end

        anchorSegControl = seg
        anchorSegControl.Refresh = anchorRefresh
        anchorRefresh()
        y = y + ROW_H + GAP
    end

    y = y + 4
    f:SetHeight(y)

    function f:Sync()
        local p = ensureProfile(); if not p then return end
        local trackerFrame = NS.UI and NS.UI.Tracker and NS.UI.Tracker.frame

        cbOverlay:Sync(); cbWorld:Sync(); cbMini:Sync()
        cbHideColl:SetChecked(
            (trackerFrame and trackerFrame._hideCompleted == true) or p.tracker.hideCompleted == true)
        cbHideVend:SetChecked(
            (trackerFrame and trackerFrame._hideCompletedVendors == true) or p.tracker.hideCompletedVendors == true)

        if styleControl and styleControl.Refresh then styleControl:Refresh() end

        local c = p.mapPins.pinColor
        swatch:SetColorTexture(c.r, c.g, c.b)

        local sz = p.mapPins.pinSize or 1.0
        slider:SetValue(sz)
        sizeVal:SetText(string.format("%.1fx", sz))

        if anchorSegControl and anchorSegControl.Refresh then anchorSegControl:Refresh() end
    end

    dropPanel = f
    return f
end

local function buildZonePanel()
    if zonePanel then return zonePanel end

    local C      = NS.UI.Controls
    local colors = GetColors()
    local Util   = NS.UI and NS.UI.MapPopupUtil
    local IA     = NS.UI and NS.UI.ItemInteractions

    local parent = UIParent
    local f = CreateFrame("Frame", "HomeDecorMapZonePanel", parent, "BackdropTemplate")
    f:SetSize(ZONE_PANEL_W, ZONE_H)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetFrameLevel(210)
    f:EnableMouse(true)
    f:SetClampedToScreen(false)
    if C then C:Backdrop(f, {0.02, 0.02, 0.025, 0.84}, colors and colors.border) end

    WorldMapFrame:HookScript("OnHide", hideZonePanel)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOPLEFT", 10, -8)
    title:SetPoint("TOPRIGHT", -30, -8)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    title:SetTextColor(unpack(colors and colors.accent or {0.9, 0.72, 0.18}))

    local toggleBtn = CreateFrame("Button", nil, f)
    toggleBtn:SetSize(18, 18)
    toggleBtn:SetPoint("TOPRIGHT", -5, -5)
    local toggleFS = toggleBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    toggleFS:SetAllPoints()
    toggleFS:SetJustifyH("CENTER")

    local function ToggleMinimized()
        local p = ensureProfile(); if not p then return end
        p.mapPins.zoneOverlayMinimized = not (p.mapPins.zoneOverlayMinimized == true)
        if f.ApplyMinimized then f:ApplyMinimized() end
        PositionZonePanel(f)
    end

    toggleBtn:SetScript("OnClick", ToggleMinimized)
    local meta = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    meta:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -7)
    meta:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -32)
    meta:SetJustifyH("LEFT")
    meta:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))

    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", meta, "BOTTOMLEFT", 0, -7)
    divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -54)
    divider:SetHeight(1)
    divider:SetColorTexture((colors and colors.accent and colors.accent[1]) or 0.9, (colors and colors.accent and colors.accent[2]) or 0.72, (colors and colors.accent and colors.accent[3]) or 0.18, 0.35)

    local content
    local scroll = CreateFrame("ScrollFrame", nil, f, "ScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -60)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -24, 8)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local step = ZONE_ROW_H + 8
        local current = self:GetVerticalScroll() or 0
        local maxScroll = math.max(0, ((content and content:GetHeight()) or 0) - (self:GetHeight() or 0))
        self:SetVerticalScroll(math.min(maxScroll, math.max(0, current - (delta * step))))
    end)
    if C and C.SkinScrollFrame then C:SkinScrollFrame(scroll) end

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(ZONE_PANEL_W - 40, 1)
    scroll:SetScrollChild(content)

    local empty = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    empty:SetPoint("CENTER", scroll, "CENTER", 0, 0)
    empty:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
    empty:SetText("No HomeDecor decor on this map.")
    empty:Hide()

    function f:ApplyMinimized()
        local p = ensureProfile()
        local minimized = p and p.mapPins and p.mapPins.zoneOverlayMinimized == true

        if minimized then
            f:SetSize(190, 24)
            meta:Hide()
            divider:Hide()
            scroll:Hide()
            empty:Hide()
            toggleFS:SetText("|cff888888+|r")
        else
            f:SetSize(ZONE_PANEL_W, ZONE_H)
            meta:Show()
            divider:Show()
            scroll:Show()
            toggleFS:SetText("|cff888888-|r")
        end

        toggleBtn:SetScript("OnEnter", function()
            toggleFS:SetText(minimized and "|cffff7d0a+|r" or "|cffff7d0a-|r")
        end)
        toggleBtn:SetScript("OnLeave", function()
            toggleFS:SetText(minimized and "|cff888888+|r" or "|cff888888-|r")
        end)
    end

    local rowPools = { vendor = {}, item = {} }
    local activeRows = {}

    local function ResetRowHighlight(self)
        if self.SetButtonState then self:SetButtonState("NORMAL", false) end
        if self.UnlockHighlight then self:UnlockHighlight() end
        if self.SetChecked then self:SetChecked(false) end
        if self.hover then
            if self.IsMouseOver and self:IsMouseOver() then
                self.hover:Show()
            else
                self.hover:Hide()
            end
        end
        if self.SetBackdropColor then self:SetBackdropColor(0, 0, 0, 0) end
        if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0, 0, 0, 0) end
    end

    local function GetRow(kind, i)
        local pool = rowPools[kind]
        local row = pool and pool[i]
        if row then return row end

        row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetHeight(ZONE_ROW_H)
        row:RegisterForClicks("AnyUp")
        if C then C:Backdrop(row, {0, 0, 0, 0}, {0, 0, 0, 0}) end
        row.hover = row:CreateTexture(nil, "BACKGROUND")
        row.hover:SetAllPoints()
        local hoverColor = colors and colors.hover or {0.14, 0.14, 0.17, 1}
        row.hover:SetColorTexture(hoverColor[1], hoverColor[2], hoverColor[3], 0.45)
        row.hover:Hide()
        row:HookScript("OnEnter", function(self)
            if self.hover then self.hover:Show() end
        end)
        row:HookScript("OnLeave", ResetRowHighlight)
        row:HookScript("OnMouseUp", ResetRowHighlight)
        row:HookScript("OnHide", ResetRowHighlight)

        row.arrow = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.arrow:SetPoint("LEFT", 3, 0)
        row.arrow:SetSize(10, 14)
        row.arrow:SetJustifyH("CENTER")
        row.arrow:SetTextColor(unpack(colors and colors.accent or {0.9, 0.72, 0.18}))
        row.arrow:Hide()

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("LEFT", 0, 0)
        row.icon:SetSize(22, 22)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        row.check = row:CreateTexture(nil, "OVERLAY")
        row.check:SetSize(13, 13)
        row.check:SetPoint("BOTTOMLEFT", row.icon, "BOTTOMLEFT", -2, -1)
        if row.check.SetAtlas then
            row.check:SetAtlas("common-icon-checkmark", true)
        else
            row.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        end
        row.check:SetVertexColor(0.75, 0.95, 0.75, 0.95)
        row.check:Hide()

        row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -1)
        row.name:SetPoint("RIGHT", -34, 0)
        row.name:SetJustifyH("LEFT")
        row.name:SetWordWrap(false)

        row.vendorText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.vendorText:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
        row.vendorText:SetPoint("RIGHT", -4, 0)
        row.vendorText:SetJustifyH("LEFT")
        row.vendorText:SetWordWrap(false)
        row.vendorText:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))

        row.owned = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.owned:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -2)
        row.owned:SetJustifyH("RIGHT")
        row.owned:SetTextColor(unpack(colors and colors.accent or {0.9, 0.72, 0.18}))

        row._kind = kind
        pool[i] = row
        return row
    end

    local function VendorKey(vendor)
        if type(vendor) ~= "table" then return "vendor:0" end
        return tostring(vendor.zoneMapID or vendor.mapID or "") .. ":" .. tostring(vendor.id or "")
    end

    local function BuildVendorGroups(vendors)
        local groups, needsItemLoad = {}, false
        local collectedTotal = 0
        for i = 1, #vendors do
            local vendor = vendors[i]
            local items = (Util and Util.GetVendorItems and Util.GetVendorItems(vendor.id)) or {}
            local group = {
                vendor = vendor,
                entries = {},
                total = 0,
                visible = 0,
                collected = 0,
            }
            for j = 1, #items do
                local item = items[j]
                if item then
                    local itemData = Util and Util.GetItemData and Util.GetItemData(item.itemID)
                    if not itemData then needsItemLoad = true end
                    local collected = Util and Util.IsCollected and Util.IsCollected(item.decorID)
                    if collected then collectedTotal = collectedTotal + 1 end
                    group.total = group.total + 1
                    if collected then group.collected = group.collected + 1 end
                    local entry = {
                        item = item,
                        vendor = vendor,
                        name = (itemData and itemData.name) or item.title or ("Decor #" .. tostring(item.decorID or item.itemID or "?")),
                        icon = (itemData and itemData.icon) or (item.source and item.source.icon) or "Interface\\Icons\\INV_Misc_QuestionMark",
                        quality = itemData and itemData.quality,
                        itemID = item.itemID or (item.source and item.source.itemID),
                        collected = collected and true or false,
                    }
                    group.entries[#group.entries + 1] = entry
                    group.visible = group.visible + 1
                end
            end
            if group.total > 0 then
                table.sort(group.entries, function(a, b)
                    if a.collected ~= b.collected then return not a.collected end
                    return tostring(a.name or "") < tostring(b.name or "")
                end)
                groups[#groups + 1] = group
            end
        end
        table.sort(groups, function(a, b)
            local av = a.vendor or {}
            local bv = b.vendor or {}
            local az = tostring(av.zone or "")
            local bz = tostring(bv.zone or "")
            if az ~= bz then return az < bz end
            return tostring(av.name or av.id or "") < tostring(bv.name or bv.id or "")
        end)
        return groups, collectedTotal, needsItemLoad
    end

    function f:Refresh()
        local mapID = GetCurrentWorldMapID()
        local previousMapID = self._lastMapID
        local keepScroll = previousMapID == mapID
        if not keepScroll then self._itemLoadRefreshes = nil end
        local previousScroll = keepScroll and scroll:GetVerticalScroll() or 0
        local vendors = GetZoneVendorList(mapID)
        local groups, collectedTotal, needsItemLoad = BuildVendorGroups(vendors)
        local p = ensureProfile()
        local includeCollected = p and p.mapPins and p.mapPins.zoneOverlayIncludeCollected == true
        local DecorCounts = NS.Systems and NS.Systems.DecorCounts
        self._openVendors = self._openVendors or {}

        for i = 1, #activeRows do
            activeRows[i]:Hide()
        end
        wipe(activeRows)

        local rowIndex, itemIndex, vendorIndex, displayIndex, totalDecorCount = 0, 0, 0, 0, 0
        for i = 1, #groups do
            local group = groups[i]
            local vendor = group.vendor
            local key = VendorKey(vendor)
            if self._pendingOpenVendorID and vendor and tonumber(vendor.id) == tonumber(self._pendingOpenVendorID) then
                self._openVendors[key] = true
            end
            local open = self._openVendors[key] == true
            local visibleEntries = {}
            for j = 1, #group.entries do
                local entry = group.entries[j]
                if includeCollected or not entry.collected then
                    visibleEntries[#visibleEntries + 1] = entry
                end
            end
            totalDecorCount = totalDecorCount + #visibleEntries

            if #visibleEntries > 0 then
                rowIndex = rowIndex + 1
                vendorIndex = vendorIndex + 1
                local row = GetRow("vendor", vendorIndex)
                activeRows[#activeRows + 1] = row
                row.item = nil
                row.vendor = vendor
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((rowIndex - 1) * (ZONE_ROW_H + 2)))
                row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * (ZONE_ROW_H + 2)))
                row:SetAlpha(1)
                row.arrow:Show()
                row.arrow:SetText(open and "-" or "+")
                row.icon:Hide()
                row.check:Hide()
                row.name:ClearAllPoints()
                row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 18, -4)
                row.name:SetPoint("RIGHT", -58, 0)
                row.name:SetText(vendor and (vendor.name or ("Vendor #" .. tostring(vendor.id))) or "Vendor")
                row.name:SetTextColor(unpack(colors and colors.accentBright or colors.accent or {0.9, 0.72, 0.18}))
                row.vendorText:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
                row.vendorText:SetText(vendor and vendor.zone or "")
                row.owned:SetText(tostring(group.collected) .. " / " .. tostring(group.total))
                row.owned:Show()
                row:SetScript("OnMouseUp", function(self)
                    local owner = f
                    if not owner._openVendors then owner._openVendors = {} end
                    owner._openVendors[key] = not (owner._openVendors[key] == true)
                    owner:Refresh()
                end)
                row:Show()

                if open then
                    for j = 1, #visibleEntries do
                        local entry = visibleEntries[j]
                        displayIndex = displayIndex + 1
                        rowIndex = rowIndex + 1
                        itemIndex = itemIndex + 1
                        local itemRow = GetRow("item", itemIndex)
                        activeRows[#activeRows + 1] = itemRow
                        local row = itemRow
            row.item = entry.item
            row.vendor = entry.vendor
            if entry.item and entry.vendor then
                entry.vendor.title = entry.vendor.title or entry.vendor.name or ("Vendor #" .. tostring(entry.vendor.id))
                entry.vendor.zone = entry.vendor.zone or GetMapName(mapID)
                entry.item._navVendor = entry.vendor
                entry.item.vendor = entry.vendor
            end
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 16, -((rowIndex - 1) * (ZONE_ROW_H + 2)))
            row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -((rowIndex - 1) * (ZONE_ROW_H + 2)))
            row.arrow:Hide()
            row.icon:Show()
            row.icon:SetTexture(entry.icon)
            row.check:SetShown(entry.collected)
            row.name:ClearAllPoints()
            row.name:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 8, -1)
            row.name:SetPoint("RIGHT", -34, 0)
            row.name:SetText(entry.name)
            local vendorName = entry.vendor and (entry.vendor.name or ("Vendor #" .. tostring(entry.vendor.id))) or ""
            local vendorZone = entry.vendor and entry.vendor.zone
            if vendorZone and vendorZone ~= "" and vendorZone ~= GetMapName(mapID) then
                row.vendorText:SetText(vendorZone .. " - " .. vendorName)
            else
                row.vendorText:SetText(vendorName)
            end

            local totalOwned = 0
            if DecorCounts and entry.itemID then
                totalOwned = (DecorCounts.GetBreakdownByItem and select(1, DecorCounts:GetBreakdownByItem(entry.itemID))) or 0
            end
            if totalOwned and totalOwned > 0 then
                row.owned:SetText(tostring(totalOwned))
                row.owned:Show()
            else
                row.owned:Hide()
            end

            if entry.collected then
                row.name:SetTextColor(unpack(colors and colors.textMuted or {0.65, 0.65, 0.68}))
                row:SetAlpha(0.62)
            else
                local qc = entry.quality and _G.ITEM_QUALITY_COLORS and _G.ITEM_QUALITY_COLORS[entry.quality]
                if qc then
                    row.name:SetTextColor(qc.r, qc.g, qc.b)
                else
                    row.name:SetTextColor(unpack(colors and colors.text or {0.92, 0.92, 0.92}))
                end
                row:SetAlpha(1)
            end
            if IA and IA.Bind then
                IA:Bind(row, entry.item, entry.vendor)
            end
            row:Show()
                    end
                end
            end
        end

        title:SetText("|TInterface\\AddOns\\HomeDecor\\Media\\Icon:13:13:0:0|t  " .. totalDecorCount .. " decor in this zone")
        meta:SetText(#vendors .. " Vendors  |  " .. collectedTotal .. " collected")
        empty:SetShown(rowIndex == 0)

        content:SetHeight(math.max(1, rowIndex * (ZONE_ROW_H + 2)))
        self._lastMapID = mapID
        self._pendingOpenVendorID = nil
        if keepScroll then
            local maxScroll = math.max(0, (content:GetHeight() or 0) - (scroll:GetHeight() or 0))
            scroll:SetVerticalScroll(math.min(previousScroll or 0, maxScroll))
        else
            scroll:SetVerticalScroll(0)
        end
        if self.ApplyMinimized then self:ApplyMinimized() end

        if not needsItemLoad then
            self._itemLoadRefreshes = nil
        end

        if needsItemLoad and not self.pendingItemLoad and C_Timer and C_Timer.After then
            self._itemLoadRefreshes = (self._itemLoadRefreshes or 0) + 1
            if self._itemLoadRefreshes > 6 then return end
            self.pendingItemLoad = true
            C_Timer.After(0.25, function()
                if f and f:IsShown() then
                    f.pendingItemLoad = nil
                    f:Refresh()
                elseif f then
                    f.pendingItemLoad = nil
                end
            end)
        end
    end

    if WorldMapFrame and not WorldMapFrame.__HomeDecorZonePanelMapHooked then
        WorldMapFrame.__HomeDecorZonePanelMapHooked = true
        pcall(function()
            hooksecurefunc(WorldMapFrame, "SetMapID", function()
                if UpdateZoneOverlayVisibility and zonePanel and zonePanel:IsShown() then
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0, function()
                            if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
                        end)
                    else
                        UpdateZoneOverlayVisibility()
                    end
                end
            end)
        end)
    end

    zonePanel = f
    return f
end

PositionZonePanel = function(panel)
    if not panel then return end
    local p = ensureProfile()
    local pos = p and p.mapPins and p.mapPins.zoneOverlayPosition or "topLeft"
    local anchor = (WorldMapFrame and WorldMapFrame.ScrollContainer) or WorldMapFrame or UIParent

    panel:ClearAllPoints()
    if pos == "bottomRight" then
        panel:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -35, 5)
    else
        local mapID = GetCurrentWorldMapID()
        local groupID = mapID and C_Map and C_Map.GetMapGroupID and C_Map.GetMapGroupID(mapID)
        panel:SetPoint("TOPLEFT", anchor, "TOPLEFT", 7, groupID and -31 or -6)
    end
end

local function UpdateZonePanelAlpha(panel)
    local p = ensureProfile()
    local alpha = (p and p.mapPins and tonumber(p.mapPins.zoneOverlayAlpha)) or 0.90
    if panel and panel.SetBackdropColor then
        panel:SetBackdropColor(0.02, 0.02, 0.025, alpha * 0.95)
        local colors = GetColors()
        local border = colors and colors.border or {0.3, 0.3, 0.3, 1}
        panel:SetBackdropBorderColor(border[1], border[2], border[3], (border[4] or 1) * alpha)
    end
end

UpdateZoneOverlayVisibility = function()
    local p = ensureProfile()
    local enabled = p and p.mapPins and p.mapPins.showZoneOverlay ~= false

    if not enabled or not (WorldMapFrame and WorldMapFrame:IsShown()) then
        hideZonePanel()
        return
    end

    if InCombatLockdown and InCombatLockdown() then return end

    local panel = buildZonePanel()
    panel:Refresh()
    PositionZonePanel(panel)
    UpdateZonePanelAlpha(panel)
    panel:Show()
    panel:Raise()
end

function NS.UI.OpenWorldMapDecorOverlay(mapID, vendorID)
    local function openNow()
        local p = ensureProfile(); if not p then return end
        p.mapPins.showZoneOverlay = true
        p.mapPins.zoneOverlayMinimized = false

        local panel = buildZonePanel()
        panel._pendingOpenVendorID = vendorID
        if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
    end

    if mapID and WorldMapFrame and WorldMapFrame.SetMapID and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID() ~= mapID then
        WorldMapFrame:SetMapID(mapID)
        if C_Timer and C_Timer.After then
            C_Timer.After(0, openNow)
        else
            openNow()
        end
    else
        openNow()
    end
end

HomeDecorWorldMapButtonMixin = {}

function HomeDecorWorldMapButtonMixin:OnLoad() end

function HomeDecorWorldMapButtonMixin:Refresh()
    self:Show()
end

function HomeDecorWorldMapButtonMixin:OnClick()
    local panel = buildDropPanel()
    if panel:IsShown() then
        panel:Hide()
        if self.ActiveTexture then self.ActiveTexture:Hide() end
        return
    end

    panel:Sync()
    RestorePanelPosition(panel, self)
    panel:Show()
    panel:Raise()
    if self.ActiveTexture then self.ActiveTexture:Show() end
end

function HomeDecorWorldMapButtonMixin:OnMouseDown()
    self.Icon:SetPoint("TOPLEFT", 8, -8)
end

function HomeDecorWorldMapButtonMixin:OnMouseUp()
    self.Icon:SetPoint("TOPLEFT", 6, -6)
end

function HomeDecorWorldMapButtonMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Home|cffff7d0aDecor|r")
    GameTooltip:AddLine("Map overlay and pin settings", 1, 1, 1)
    GameTooltip:Show()
end

function HomeDecorWorldMapButtonMixin:OnLeave()
    GameTooltip:Hide()
end

function HomeDecorWorldMapButtonMixin:OnHide()
    hideDropPanel()
    if self.ActiveTexture then self.ActiveTexture:Hide() end
end

local buttonCreated = false
local worldMapHooksInstalled = false

local function InstallWorldMapHooks()
    if worldMapHooksInstalled or not WorldMapFrame then return end
    worldMapHooksInstalled = true

    hooksecurefunc(WorldMapFrame, "Show", function()
        local p = ensureProfile()
        if p and p.mapPins then
            p.mapPins.zoneOverlayMinimized = true
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
            end)
        end
    end)

    hooksecurefunc(WorldMapFrame, "Hide", function()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, hideZonePanel)
        else
            hideZonePanel()
        end
    end)

    if WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            if C_Timer and C_Timer.After then
                C_Timer.After(0.05, function()
                    if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
                end)
            end
        end)
    end
end

local function CreateWorldMapButton()
    if buttonCreated then return end
    buttonCreated = true
    local KWB = LibStub("Krowi_WorldMapButtons-1.4")
    NS.UI.worldMapButton = KWB:Add("HomeDecorWorldMapButtonTemplate", "Button")
    InstallWorldMapHooks()
    local p = ensureProfile()
    if p and p.mapPins then
        p.mapPins.zoneOverlayMinimized = true
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if UpdateZoneOverlayVisibility then UpdateZoneOverlayVisibility() end
        end)
    end
end

function NS.UI.CreateWorldMapButton()
    if buttonCreated then return end
    if WorldMapFrame and WorldMapFrame.AddDataProvider then
        CreateWorldMapButton()
    else
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("ADDON_LOADED")
        frame:SetScript("OnEvent", function(self, event, addonName)
            if addonName == "Blizzard_WorldMap" then
                CreateWorldMapButton()
                self:UnregisterEvent("ADDON_LOADED")
            end
        end)
    end
end
