local ADDON, NS = ...
NS.Systems        = NS.Systems or {}
NS.Systems.QuickBar = NS.Systems.QuickBar or {}
local function T() return NS.UI and NS.UI.Theme and NS.UI.Theme.colors end

local QB = NS.Systems.QuickBar
local UI = {}
QB.UI = UI

local SLOT_W        = 72
local SLOT_H        = 72
local SLOT_GAP      = 4
local RECENT_W      = 72
local RECENT_H      = 72
local RECENT_GAP    = 16   
local NAV_W         = 24
local NAV_GAP       = 8    
local PAD_H         = 10   
local PAD_V         = 8    
local BOTTOM_MARGIN = 4    
local BORDER_SIZE   = 12   

local SLIDE_IN_DIST  = 80   
local SLIDE_DURATION = 0.4
local SLIDE_OUT_DURATION = 0.25

local C_BORDER_EMPTY  = { 0.24, 0.24, 0.28, 1.0 }
local C_BORDER_FILLED = { 0.90, 0.72, 0.18, 1.0 }
local C_BORDER_OOS    = { 0.80, 0.28, 0.28, 1.0 }
local C_QTY_NORMAL    = { 1.00, 1.00, 1.00, 1.0 }
local C_QTY_OOS       = { 1.00, 0.30, 0.30, 1.0 }

UI.barFrame    = nil    
UI.recentFrame = nil    
local slotFrames = {}
local navFrame   = nil
local isVisible  = false

local function GetQty(recordID)
    if not recordID then return 0 end
    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then return 0 end
    local t = Enum and Enum.HousingCatalogEntryType and Enum.HousingCatalogEntryType.Decor or 1
    local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByRecordID, t, recordID, true)
    if not (ok and info) then return 0 end
    return (info.quantity or 0) + (info.remainingRedeemable or 0)
end

local function EaseOutQuart(t)
    t = math.max(0, math.min(1, t))
    local u = 1 - t
    return 1 - u * u * u * u
end

local function EaseInSine(t)
    t = math.max(0, math.min(1, t))
    return 1 - math.cos(t * math.pi / 2)
end

local function CancelAnim(frame)
    if frame and frame._animDriver then
        frame._animDriver:SetScript("OnUpdate", nil)
        frame._animDriver = nil
    end
end

local function SlideIn(frame, finalY, startOffset, duration, onDone)
    CancelAnim(frame)
    frame:SetAlpha(0)
    frame:Show()
    frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, finalY + startOffset)

    local elapsed = 0
    local driver  = CreateFrame("Frame")
    frame._animDriver = driver

    driver:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        local pct  = math.min(elapsed / duration, 1)
        local ease = EaseOutQuart(pct)
        local curY = (finalY + startOffset) + (finalY - (finalY + startOffset)) * ease
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, curY)
        frame:SetAlpha(ease)
        if pct >= 1 then
            self:SetScript("OnUpdate", nil)
            frame._animDriver = nil
            frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, finalY)
            frame:SetAlpha(1)
            if onDone then onDone() end
        end
    end)
end

local function SlideOut(frame, finalY, targetOffset, duration, onDone)
    CancelAnim(frame)
    local startAlpha = frame:GetAlpha()
    local elapsed = 0
    local driver  = CreateFrame("Frame")
    frame._animDriver = driver

    driver:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        local pct  = math.min(elapsed / duration, 1)
        local ease = EaseInSine(pct)
        local curY = finalY + (targetOffset * ease)
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, curY)
        frame:SetAlpha(startAlpha * (1 - ease))
        if pct >= 1 then
            self:SetScript("OnUpdate", nil)
            frame._animDriver = nil
            frame:Hide()
            frame:SetAlpha(1)
            frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, finalY)
            if onDone then onDone() end
        end
    end)
end

local function UpdateSlotVisuals(slot, data)
    if data and data.recordID then
        local qty = GetQty(data.recordID)
        slot.icon:SetTexture(data.icon or 134400)
        slot.icon:Show()
        slot.emptyBg:Hide()

        if qty > 0 then
            slot:SetBackdropBorderColor(C_BORDER_FILLED[1], C_BORDER_FILLED[2], C_BORDER_FILLED[3], C_BORDER_FILLED[4])
            slot.qty:SetText(qty)
            slot.qty:SetTextColor(C_QTY_NORMAL[1], C_QTY_NORMAL[2], C_QTY_NORMAL[3])
        else
            slot:SetBackdropBorderColor(C_BORDER_OOS[1], C_BORDER_OOS[2], C_BORDER_OOS[3], C_BORDER_OOS[4])
            slot.qty:SetText("0")
            slot.qty:SetTextColor(C_QTY_OOS[1], C_QTY_OOS[2], C_QTY_OOS[3])
        end
        slot.qty:Show()
    else
        slot.icon:Hide()
        slot.qty:Hide()
        slot.emptyBg:Show()
        slot:SetBackdropBorderColor(C_BORDER_EMPTY[1], C_BORDER_EMPTY[2], C_BORDER_EMPTY[3], C_BORDER_EMPTY[4])
    end
end

local function MakeSlot(parent, w, h, frameName)
    local s = CreateFrame("Button", frameName, parent, "BackdropTemplate")
    s:SetSize(w, h)
    s:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    local tc = T()
    s:SetBackdropColor(tc and tc.panel[1] or 0.095, tc and tc.panel[2] or 0.095, tc and tc.panel[3] or 0.11, 0.95)
    s:SetBackdropBorderColor(C_BORDER_EMPTY[1], C_BORDER_EMPTY[2], C_BORDER_EMPTY[3], C_BORDER_EMPTY[4])

    s.icon = s:CreateTexture(nil, "ARTWORK")
    s.icon:SetSize(w - 10, h - 10)
    s.icon:SetPoint("CENTER")
    s.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    s.icon:Hide()

    s.emptyBg = s:CreateTexture(nil, "BACKGROUND", nil, 1)
    s.emptyBg:SetSize(w - 10, h - 10)
    s.emptyBg:SetPoint("CENTER")
    s.emptyBg:SetAtlas("ui-hud-minimap-housing-indoor-static-bg")
    s.emptyBg:SetAlpha(0.50)
    s.emptyBg:Show()

    s.qty = s:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    s.qty:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", -4, 4)
    s.qty:SetTextColor(1, 1, 1)
    s.qty:Hide()

    local hl = s:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.15)

    s:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    return s
end

local function MakeNavButton(parent, isUp, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(NAV_W, 18)

    local atlas = isUp
        and "ui-hud-actionbar-pageuparrow-up"
        or  "ui-hud-actionbar-pagedownarrow-up"
    local atlasHl = isUp
        and "ui-hud-actionbar-pageuparrow-mouseover"
        or  "ui-hud-actionbar-pagedownarrow-mouseover"

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetAtlas(atlas)

    local texHl = btn:CreateTexture(nil, "HIGHLIGHT")
    texHl:SetAllPoints()
    texHl:SetAtlas(atlasHl)
    texHl:SetBlendMode("ADD")

    btn:SetScript("OnClick", onClick)
    return btn
end

local function BuildBar()
    local numSlots = QB.NUM_SLOTS
    local barW = PAD_H * 2
                 + numSlots * SLOT_W
                 + (numSlots - 1) * SLOT_GAP
                 + NAV_GAP + NAV_W
    local barH = PAD_V * 2 + SLOT_H
    local finalY = BOTTOM_MARGIN

    local bar = CreateFrame("Frame", "HomeDecorQuickBar", UIParent, "BackdropTemplate")
    bar:SetSize(barW, barH)
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, finalY)
    bar:SetFrameStrata("FULLSCREEN_DIALOG")
    bar:SetFrameLevel(100)
    bar:SetClampedToScreen(true)
    bar:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets   = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    local c = T()
    if c then
        bar:SetBackdropColor(c.bg[1], c.bg[2], c.bg[3], 0.92)
        bar:SetBackdropBorderColor(c.border[1], c.border[2], c.border[3], 0.8)
    else
        bar:SetBackdropColor(0.045, 0.045, 0.05, 0.92)
        bar:SetBackdropBorderColor(0.24, 0.24, 0.28, 0.8)
    end
    bar:EnableMouse(false)
    bar:SetMovable(false)

    bar:Hide()
    bar._finalY = finalY
    UI.barFrame = bar

    local rec = MakeSlot(bar, RECENT_W, RECENT_H, "HomeDecorQuickBarRecent")
    rec:SetPoint("RIGHT", bar, "LEFT", -RECENT_GAP, 0)
    rec:SetFrameStrata(bar:GetFrameStrata())
    rec:SetFrameLevel(bar:GetFrameLevel())

    rec.label = rec:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rec.label:SetPoint("TOPLEFT", rec, "TOPLEFT", 4, -3)
    rec.label:SetText("Recent")
    local rtc = T()
    rec.label:SetTextColor(rtc and rtc.accent[1] or 0.90, rtc and rtc.accent[2] or 0.72, rtc and rtc.accent[3] or 0.18, 1)

    rec:SetScript("OnClick", function(_, btn)
        if btn == "LeftButton" then
            C_Timer.After(0.1, function() QB:OnRecentClicked() end)
        end
    end)
    rec:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        local r = QB:GetRecent()
        if r then
            GameTooltip:SetText(r.name)
            GameTooltip:AddLine("|cFFFFD700Left-click|r  Place again", 0.8, 0.8, 0.8)
        else
            GameTooltip:SetText("Recent")
            GameTooltip:AddLine("Last placed decoration appears here", 0.65, 0.65, 0.65)
        end
        GameTooltip:Show()
    end)
    rec:SetScript("OnLeave", function() GameTooltip:Hide() end)
    UI.recentFrame = rec

    for i = 1, numSlots do
        local s = MakeSlot(bar, SLOT_W, SLOT_H, "HomeDecorQuickBarSlot" .. i)
        s.slotIndex = i
        local xOff = PAD_H + (i - 1) * (SLOT_W + SLOT_GAP)
        s:SetPoint("LEFT", bar, "LEFT", xOff, 0)

        s.keyLabel = s:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        s.keyLabel:SetPoint("TOPRIGHT", s, "TOPRIGHT", -4, -4)
        s.keyLabel:SetText(QB.Keys and QB.Keys.Label(i) or ("F" .. i))
        local ktc = T()
        s.keyLabel:SetTextColor(ktc and ktc.textMuted[1] or 0.65, ktc and ktc.textMuted[2] or 0.65, ktc and ktc.textMuted[3] or 0.68, 0.90)

        s:SetScript("OnClick", function(self, btn)
            if btn == "LeftButton" then
                C_Timer.After(0.08, function() QB:OnKeyPressed(self.slotIndex) end)
            elseif btn == "RightButton" then
                QB:ClearSlot(QB:GetPage(), self.slotIndex)
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
            end
        end)
        s:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            local data = QB:GetCurrentSlot(self.slotIndex)
            local key  = QB.Keys and QB.Keys.Label(self.slotIndex) or ("F" .. self.slotIndex)
            if data then
                GameTooltip:SetText(data.name)
                GameTooltip:AddLine(string.format("|cFFFFD700%s  /  Left-click|r  Place", key), 0.85, 0.85, 0.85)
                GameTooltip:AddLine("|cFFFFD700Right-click|r  Clear slot", 0.65, 0.65, 0.65)
                GameTooltip:AddLine("Hold a decoration and press key to overwrite", 0.55, 0.55, 0.55)
            else
                GameTooltip:SetText(string.format("Empty Slot  %s", key))
                GameTooltip:AddLine("Hold a decoration, then press key to assign", 0.65, 0.65, 0.65)
            end
            GameTooltip:Show()
        end)
        s:SetScript("OnLeave", function() GameTooltip:Hide() end)

        slotFrames[i] = s
    end

    local nav = CreateFrame("Frame", nil, bar)
    nav:SetSize(NAV_W, SLOT_H)
    nav:SetPoint("LEFT", bar, "LEFT", PAD_H + numSlots * (SLOT_W + SLOT_GAP) - SLOT_GAP + NAV_GAP, 0)
    nav:SetFrameLevel(bar:GetFrameLevel() + 10)  
    navFrame = nav

    nav.label = nav:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nav.label:SetPoint("CENTER", nav, "CENTER", 0, 0)
    local ntc = T()
    nav.label:SetTextColor(ntc and ntc.accent[1] or 0.90, ntc and ntc.accent[2] or 0.72, ntc and ntc.accent[3] or 0.18, 1)

    nav.upBtn = MakeNavButton(nav, true, function()
        QB:NextPage()
    end)
    nav.upBtn:SetPoint("TOP", nav, "TOP", 0, 0)
    nav.upBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Next Page")
        GameTooltip:Show()
    end)
    nav.upBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    nav.dnBtn = MakeNavButton(nav, false, function()
        QB:PrevPage()
    end)
    nav.dnBtn:SetPoint("BOTTOM", nav, "BOTTOM", 0, 0)
    nav.dnBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Previous Page")
        GameTooltip:Show()
    end)
    nav.dnBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function UI:Refresh()
    if not UI.barFrame then return end

    if UI.recentFrame then
        UpdateSlotVisuals(UI.recentFrame, QB:GetRecent())
    end

    for i = 1, QB.NUM_SLOTS do
        local s = slotFrames[i]
        if s then
            UpdateSlotVisuals(s, QB:GetCurrentSlot(i))
        end
    end

    if navFrame and navFrame.label then
        navFrame.label:SetText(QB:GetPage() .. "\n/\n" .. QB:NumPages())
    end
end

function UI.RefreshKeyLabels()
    for i, s in ipairs(slotFrames) do
        if s and s.keyLabel then
            s.keyLabel:SetText(QB.Keys and QB.Keys.Label(i) or ("F" .. i))
        end
    end
end

function UI:Show()
    if not UI.barFrame then BuildBar() end
    if isVisible then return end
    isVisible = true

    local bar    = UI.barFrame
    local finalY = bar._finalY or BOTTOM_MARGIN

    if HouseEditorFrame then
        bar:SetParent(HouseEditorFrame)
        if UI.recentFrame then
            UI.recentFrame:SetParent(HouseEditorFrame)
            UI.recentFrame:Show()
        end
        bar:SetFrameLevel(100)
    end

    self:Refresh()

    SlideIn(bar, finalY, -SLIDE_IN_DIST, SLIDE_DURATION, function()

        if QB.Keys then QB.Keys.Apply() end

        if QB.ModeBar then QB.ModeBar:Apply() end
    end)
end

function UI:Hide()
    if not (UI.barFrame and isVisible) then return end
    isVisible = false

    local bar    = UI.barFrame
    local finalY = bar._finalY or BOTTOM_MARGIN

    if QB.Keys   then QB.Keys.Clear()    end
    if QB.ModeBar then QB.ModeBar:Restore() end

    SlideOut(bar, finalY, -SLIDE_IN_DIST, SLIDE_OUT_DURATION, function()

        bar:SetParent(UIParent)
        if UI.recentFrame then
            UI.recentFrame:SetParent(UIParent)
            UI.recentFrame:Hide()
        end
    end)
end

local function IsEditorActive()
    if HouseEditorFrame and HouseEditorFrame:IsShown() then return true end
    return C_HouseEditor
        and C_HouseEditor.IsHouseEditorActive
        and C_HouseEditor.IsHouseEditorActive()
        or false
end

local function isQBEnabled()
    local prof = NS.db and NS.db.profile
    if not prof then return true end
    if not prof.quickBar then return true end
    return prof.quickBar.enabled ~= false
end

local evFrame = CreateFrame("Frame")
evFrame:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
evFrame:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")
evFrame:RegisterEvent("HOUSING_DECOR_REMOVED")
evFrame:RegisterEvent("HOUSING_CATALOG_CATEGORY_UPDATED")
evFrame:SetScript("OnEvent", function(_, event)
    if event == "HOUSE_EDITOR_MODE_CHANGED" then
        C_Timer.After(0.05, function()
            if IsEditorActive() then
                if isQBEnabled() then
                    UI:Show()
                end
            else
                UI:Hide()
            end
        end)
    else

        C_Timer.After(0.15, function() UI:Refresh() end)
    end
end)

local qbWired = false
local qbPollFrame = CreateFrame("Frame")
qbPollFrame:Show()
qbPollFrame:SetScript("OnUpdate", function(self)
    if not HouseEditorFrame then return end
    self:SetScript("OnUpdate", nil)
    if qbWired then return end
    qbWired = true
    BuildBar()
    HouseEditorFrame:HookScript("OnShow", function()
        if isQBEnabled() then UI:Show() end
    end)
    HouseEditorFrame:HookScript("OnHide", function()
        UI:Hide()
    end)
    if IsEditorActive() and isQBEnabled() then
        UI:Show()
    end
end)

function UI.Init()
    if qbWired and IsEditorActive() and isQBEnabled() then
        UI:Show()
    end
end
