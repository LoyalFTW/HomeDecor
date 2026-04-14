local ADDON, NS = ...
NS.UI = NS.UI or {}
NS.UI.Endeavors = NS.UI.Endeavors or {}
local EndeavorsUI = NS.UI.Endeavors
local Sys         = NS.Systems.Endeavors
local floor  = math.floor
local min    = math.min
local max    = math.max
local format = string.format
local wipe   = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end
local function Backdrop(f, bg, brd)
    local C = NS.UI.Controls
    if C and C.Backdrop then C:Backdrop(f, bg, brd) return end
    f:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1, insets={left=1,right=1,top=1,bottom=1} })
    if bg  then f:SetBackdropColor(bg[1],bg[2],bg[3],bg[4] or 1) end
    if brd then f:SetBackdropBorderColor(brd[1],brd[2],brd[3],brd[4] or 1) end
end
local function Theme() return NS.UI.Theme and NS.UI.Theme.colors or {} end
local function TC(name, ...)
    local c = Theme()[name]
    if not c then return ... end
    return c[1], c[2], c[3], c[4] or 1
end
local C_ACCENT      = { 0.90, 0.72, 0.18, 1 }
local C_ACCENT_DARK = { 0.28, 0.24, 0.10, 1 }
local C_BORDER      = { 0.24, 0.24, 0.28, 1 }
local C_MUTED       = { 0.55, 0.55, 0.58, 1 }
local C_GREEN       = { 0.30, 0.85, 0.35, 1 }
local C_GOLD        = { 1.00, 0.82, 0.00, 1 }
local C_PANEL       = { 0.07, 0.07, 0.08, 1 }
local C_ROW_ODD     = { 0.06, 0.07, 0.09, 0.60 }
local C_ROW_EVEN    = { 0.04, 0.05, 0.07, 0.40 }
local C_HEADER_BG   = { 0.10, 0.10, 0.12, 0.98 }
local function Tex(parent, layer)
    return parent:CreateTexture(nil, layer or "ARTWORK")
end
local function FS(parent, template, layer)
    return parent:CreateFontString(nil, layer or "OVERLAY", template or "GameFontHighlightSmall")
end
local function SolidBG(f, r, g, b, a)
    local t = Tex(f, "BACKGROUND"); t:SetAllPoints(); t:SetColorTexture(r, g, b, a or 1)
    return t
end
local function HLine(parent, r, g, b, a, anchor, offY)
    local t = Tex(parent, "BORDER")
    t:SetHeight(1)
    t:SetPoint("LEFT",  parent, anchor or "BOTTOMLEFT",  0, offY or 0)
    t:SetPoint("RIGHT", parent, anchor and anchor:gsub("LEFT","RIGHT") or "BOTTOMRIGHT", 0, offY or 0)
    t:SetColorTexture(r, g, b, a or 1)
    return t
end
local function VLine(parent, r, g, b, a)
    local t = Tex(parent, "BORDER")
    t:SetWidth(1)
    t:SetPoint("TOP",    parent, "TOPRIGHT")
    t:SetPoint("BOTTOM", parent, "BOTTOMRIGHT")
    t:SetColorTexture(r, g, b, a or 1)
    return t
end
local function ApplyFont(fs, size, flags)
    fs:SetFont(STANDARD_TEXT_FONT, size or 11, flags or "")
end
local function StatusDot(parent, size)
    size = size or 10
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetSize(size, size)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    f:SetBackdropColor(C_MUTED[1]*0.4, C_MUTED[2]*0.4, C_MUTED[3]*0.4, 1)
    f:SetBackdropBorderColor(C_MUTED[1], C_MUTED[2], C_MUTED[3], 0.7)
    function f:SetState(state)
        if state == "done" then
            f:SetBackdropColor(C_GREEN[1]*0.5, C_GREEN[2]*0.5, C_GREEN[3]*0.5, 1)
            f:SetBackdropBorderColor(C_GREEN[1], C_GREEN[2], C_GREEN[3], 1)
        elseif state == "progress" then
            f:SetBackdropColor(C_GOLD[1]*0.4, C_GOLD[2]*0.3, 0, 1)
            f:SetBackdropBorderColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 1)
        else
            f:SetBackdropColor(C_MUTED[1]*0.2, C_MUTED[2]*0.2, C_MUTED[3]*0.2, 1)
            f:SetBackdropBorderColor(C_MUTED[1], C_MUTED[2], C_MUTED[3], 0.5)
        end
    end
    return f
end
local function PillBtn(parent, label, w, h)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w or 70, h or 20)
    btn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(C_ACCENT_DARK[1], C_ACCENT_DARK[2], C_ACCENT_DARK[3], 0.9)
    btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.6)
    local fs = FS(btn, "GameFontHighlightSmall")
    fs:SetAllPoints()
    fs:SetJustifyH("CENTER")
    fs:SetText(label or "")
    fs:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    ApplyFont(fs, 10)
    btn.label = fs
    btn:SetScript("OnEnter", function() btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1) end)
    btn:SetScript("OnLeave", function() btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.6) end)
    return btn
end
local function TabBtn(parent, label)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetHeight(22)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    local fs = FS(btn, "GameFontHighlightSmall")
    fs:SetPoint("LEFT", 8, 0); fs:SetPoint("RIGHT", -8, 0)
    fs:SetJustifyH("CENTER"); fs:SetText(label)
    ApplyFont(fs, 10)
    btn.label = fs
    local uline = Tex(btn, "OVERLAY")
    uline:SetHeight(2)
    uline:SetPoint("BOTTOMLEFT",1,1); uline:SetPoint("BOTTOMRIGHT",-1,1)
    uline:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1)
    uline:Hide()
    btn.uline = uline
    btn:SetWidth((fs:GetStringWidth() or 50) + 20)
    function btn:SetActive(v)
        if v then
            btn:SetBackdropColor(C_ACCENT[1]*0.22, C_ACCENT[2]*0.18, 0, 0.7)
            btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.5)
            fs:SetTextColor(1, 1, 0.8)
            uline:Show()
        else
            btn:SetBackdropColor(0.10, 0.10, 0.12, 0.5)
            btn:SetBackdropBorderColor(C_BORDER[1], C_BORDER[2], C_BORDER[3], 0.3)
            fs:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
            uline:Hide()
        end
    end
    btn:SetActive(false)
    return btn
end
local function MakeScroll(parent)
    local SBAW = 6
    local wrap = CreateFrame("Frame", nil, parent)
    wrap:SetPoint("TOPLEFT"); wrap:SetPoint("BOTTOMRIGHT")
    local sf = CreateFrame("ScrollFrame", nil, wrap)
    sf:SetPoint("TOPLEFT"); sf:SetPoint("BOTTOMRIGHT", -(SBAW+3), 0)
    local ct = CreateFrame("Frame", nil, sf)
    ct:SetWidth(sf:GetWidth() or 300); ct:SetHeight(1)
    sf:SetScrollChild(ct)
    local track = Tex(wrap, "BACKGROUND")
    track:SetPoint("TOPRIGHT"); track:SetPoint("BOTTOMRIGHT")
    track:SetWidth(SBAW+2)
    track:SetColorTexture(0, 0, 0, 0.3)
    local thumb = CreateFrame("Frame", nil, wrap)
    thumb:SetWidth(SBAW)
    local thumbTex = Tex(thumb)
    thumbTex:SetAllPoints()
    thumbTex:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.4)
    local function UpdateThumb()
        local vh = sf:GetHeight(); local th = ct:GetHeight()
        local trh = wrap:GetHeight()
        if th <= vh or trh < 10 then thumb:Hide(); return end
        thumb:Show()
        local ratio = vh / th
        local tmbH  = max(18, floor(trh * ratio))
        local pct   = sf:GetVerticalScroll() / (th - vh)
        local ty    = -floor((trh - tmbH) * pct)
        thumb:SetSize(SBAW, tmbH)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOPRIGHT", wrap, "TOPRIGHT", -1, ty)
    end
    sf:SetScript("OnVerticalScroll", function(s, d) s:SetVerticalScroll(d); UpdateThumb() end)
    sf:SetScript("OnMouseWheel", function(s, d)
        local cur = s:GetVerticalScroll()
        local mx  = max(0, ct:GetHeight() - s:GetHeight())
        s:SetVerticalScroll(max(0, min(mx, cur - d*28)))
        UpdateThumb()
    end)
    local ds, dss
    thumb:EnableMouse(true)
    thumb:SetScript("OnMouseDown", function(self, btn)
        if btn ~= "LeftButton" then return end
        ds = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        dss = sf:GetVerticalScroll()
        self:SetScript("OnUpdate", function()
            local cy = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local d2 = ds - cy
            local trh = wrap:GetHeight(); local th = ct:GetHeight(); local vh = sf:GetHeight()
            local sr = th - vh
            if sr > 0 and trh > 0 then
                sf:SetVerticalScroll(max(0, min(sr, dss + d2 * sr / trh)))
                UpdateThumb()
            end
        end)
    end)
    thumb:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    sf:SetScript("OnSizeChanged", function(s, w) ct:SetWidth(w - 2); UpdateThumb() end)
    ct:SetScript("OnSizeChanged", UpdateThumb)
    return sf, ct
end
local function CreateMilestoneMarker(bar, i, isFinal, couponIconID)
    local size = isFinal and 36 or 20
    local mk = CreateFrame("Frame", nil, bar)
    mk:SetSize(size, size)
    mk:SetFrameLevel(bar:GetFrameLevel() + 3)
    mk:EnableMouse(true)
    mk:SetScript("OnLeave", function() GameTooltip:Hide() end)
    if isFinal then
        local icon = Tex(mk, "ARTWORK")
        icon:SetSize(28, 28); icon:SetPoint("CENTER")
        if couponIconID and couponIconID > 0 then
            icon:SetTexture(couponIconID)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        else
            icon:SetAtlas("housing-dashboard-fillbar-pip-incomplete")
        end
        mk.icon = icon
        local ck = Tex(mk, "OVERLAY"); ck:SetSize(14,14); ck:SetPoint("CENTER",10,-8)
        ck:SetAtlas("housing-dashboard-small-checkmark"); ck:Hide()
        mk.ck = ck
    else
        local lineInc = Tex(mk, "ARTWORK", nil, 1); lineInc:SetSize(2,25); lineInc:SetPoint("CENTER")
        lineInc:SetAtlas("housing-dashboard-initiatives-fillbar-tickbar-incomplete")
        mk.lineInc = lineInc
        local lineCmp = Tex(mk, "ARTWORK", nil, 1); lineCmp:SetSize(2,25); lineCmp:SetPoint("CENTER")
        lineCmp:SetAtlas("housing-dashboard-initiatives-fillbar-tickbar-complete"); lineCmp:Hide()
        mk.lineCmp = lineCmp
        local pipInc = Tex(mk, "OVERLAY"); pipInc:SetSize(size,size); pipInc:SetPoint("CENTER")
        pipInc:SetAtlas("housing-dashboard-fillbar-pip-incomplete")
        mk.pipInc = pipInc
        local pipCmp = Tex(mk, "OVERLAY"); pipCmp:SetSize(size,size); pipCmp:SetPoint("CENTER")
        pipCmp:SetAtlas("housing-dashboard-fillbar-pip-complete"); pipCmp:Hide()
        mk.pipCmp = pipCmp
        local ck = Tex(mk, "OVERLAY"); ck:SetSize(14,14); ck:SetPoint("CENTER",5,-5)
        ck:SetAtlas("housing-dashboard-small-checkmark"); ck:Hide()
        mk.ck = ck
    end
    mk.isFinal = isFinal
    return mk
end
local function PositionMarkers(bar)
    local milestones = bar._milestones; if not milestones then return end
    local cur  = bar._cur  or 0
    local maxP = bar._maxP or 1
    local bw   = bar:GetWidth()
    if bw < 10 then return end
    for i, ms in ipairs(milestones) do
        local mk = bar.markers[i]; if not mk then break end
        mk:ClearAllPoints()
        if mk.isFinal then
            mk:SetPoint("CENTER", bar, "RIGHT", 16, 0)
        else
            local threshold = ms.threshold or 0
            local ratio = maxP > 0 and (threshold / maxP) or (i / #milestones)
            mk:SetPoint("CENTER", bar, "LEFT", ratio * bw, 0)
        end
    end
end
local function MakeMilestoneBar(parent, h)
    h = h or 20
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetHeight(h)
    bar:SetMinMaxValues(0, 1); bar:SetValue(0)
    local fill = Tex(bar, "ARTWORK")
    fill:SetAllPoints()
    fill:SetAtlas("housing-dashboard-fillbar-fill")
    bar:SetStatusBarTexture(fill)
    local bg = Tex(bar, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.05, 0.05, 0.06, 0.95)
    bar.markers = {}
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        local _, mx = self:GetMinMaxValues()
        local v = self:GetValue()
        local pct = mx > 0 and (v/mx*100) or 0
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Season Progress", 1, 0.82, 0)
        GameTooltip:AddLine(format("%.0f / %d (%.0f%%)", v, mx, pct), 1, 1, 1)
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", function() GameTooltip:Hide() end)
    bar:SetScript("OnSizeChanged", function(self) PositionMarkers(self) end)
    return bar
end
local function UpdateMilestoneMarkers(bar, milestones, cur, maxP, couponIconID)
    if not milestones then return end
    local n = #milestones
    bar._milestones = milestones
    bar._cur        = cur
    bar._maxP       = maxP
    for i, ms in ipairs(milestones) do
        local isFinal = (i == n)
        local mk = bar.markers[i]
        if mk and mk.isFinal ~= isFinal then mk:Hide(); mk = nil end
        if not mk then
            mk = CreateMilestoneMarker(bar, i, isFinal, couponIconID)
            bar.markers[i] = mk
        end
        local threshold = ms.threshold or 0
        local reached   = (cur or 0) >= threshold
        local idx       = i
        if isFinal then
            if reached then mk.ck:Show() else mk.ck:Hide() end
        else
            if reached then
                if mk.pipCmp  then mk.pipCmp:Show()  end
                if mk.pipInc  then mk.pipInc:Hide()  end
                if mk.lineCmp then mk.lineCmp:Show() end
                if mk.lineInc then mk.lineInc:Hide() end
                mk.ck:Show()
            else
                if mk.pipCmp  then mk.pipCmp:Hide()  end
                if mk.pipInc  then mk.pipInc:Show()  end
                if mk.lineCmp then mk.lineCmp:Hide() end
                if mk.lineInc then mk.lineInc:Show() end
                mk.ck:Hide()
            end
        end
        mk.msData = ms; mk.currentProgress = cur
        mk:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if isFinal then
                GameTooltip:SetText("Final Milestone", 1, 0.82, 0)
            else
                GameTooltip:SetText(format("Milestone %d", idx), 1, 0.82, 0)
            end
            GameTooltip:AddLine(format("%d / %d", cur or 0, threshold), 1, 1, 1)
            if ms.rewards then
                for _, r in ipairs(ms.rewards) do
                    if r.title then GameTooltip:AddLine(r.title, 0.4, 0.8, 1) end
                end
            end
            if reached then GameTooltip:AddLine("Complete!", 0.2, 0.9, 0.2) end
            GameTooltip:Show()
        end)
        mk:Show()
    end
    for i = n+1, #bar.markers do bar.markers[i]:Hide() end
    PositionMarkers(bar)
end
local ROW_H = 30
local function MakeTaskRow(parent, idx)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_H)
    local bgTex = Tex(row, "BACKGROUND")
    bgTex:SetAllPoints()
    local c = idx % 2 == 0 and C_ROW_EVEN or C_ROW_ODD
    bgTex:SetColorTexture(c[1], c[2], c[3], c[4])
    row.bgTex = bgTex
    local stripe = Tex(row, "ARTWORK")
    stripe:SetWidth(3)
    stripe:SetPoint("TOPLEFT"); stripe:SetPoint("BOTTOMLEFT")
    stripe:SetColorTexture(C_MUTED[1], C_MUTED[2], C_MUTED[3], 0.3)
    row.stripe = stripe
    local dot = StatusDot(row, 10)
    dot:SetPoint("LEFT", 10, 0)
    row.dot = dot
    local cpnIcon = Tex(row, "OVERLAY")
    cpnIcon:SetSize(13, 13)
    cpnIcon:SetPoint("RIGHT", row, "RIGHT", -6, 1)
    row.cpnIcon = cpnIcon
    local cpnFS = FS(row, "GameFontHighlightSmall")
    cpnFS:SetPoint("RIGHT", cpnIcon, "LEFT", -3, 0)
    cpnFS:SetWidth(24)
    cpnFS:SetJustifyH("RIGHT")
    cpnFS:SetTextColor(1, 0.85, 0.35)
    ApplyFont(cpnFS, 10)
    row.cpnFS = cpnFS
    local xpFS = FS(row, "GameFontHighlightSmall")
    xpFS:SetPoint("RIGHT", cpnFS, "LEFT", -8, 2)
    xpFS:SetWidth(52)
    xpFS:SetJustifyH("RIGHT")
    xpFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
    ApplyFont(xpFS, 10)
    row.xpFS = xpFS
    local progFS = FS(row, "GameFontHighlightSmall")
    progFS:SetPoint("RIGHT", xpFS, "LEFT", -8, 0)
    progFS:SetWidth(64)
    progFS:SetJustifyH("RIGHT")
    progFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
    ApplyFont(progFS, 10)
    row.progFS = progFS
    local nameFS = FS(row, "GameFontHighlightSmall")
    nameFS:SetPoint("LEFT", dot, "RIGHT", 7, 0)
    nameFS:SetPoint("RIGHT", progFS, "LEFT", -8, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    ApplyFont(nameFS, 11)
    row.nameFS = nameFS
    local hl = Tex(row, "HIGHLIGHT")
    hl:SetAllPoints(); hl:SetColorTexture(1, 1, 1, 0.04)
    row:EnableMouse(true)
    return row
end
local RANK_C = { {0.2, 0.9, 0.85, 1}, {0.55, 0.65, 1.0, 1}, {1.0, 0.72, 0.2, 1} }
local function UpdateTaskRow(row, task, rankByID, couponIconID, idx)
    row.task = task
    local c = idx % 2 == 0 and C_ROW_EVEN or C_ROW_ODD
    row.bgTex:SetColorTexture(c[1], c[2], c[3], c[4])
    row.nameFS:SetText(task.name or "?")
    local hasProgress = (task.current or 0) > 0 and not task.completed
    if task.completed then
        row.dot:SetState("done")
        row.nameFS:SetTextColor(C_MUTED[1]*1.2, C_MUTED[2]*1.1, C_MUTED[3], 0.75)
        row.progFS:SetText("Done")
        row.progFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
        row.stripe:SetColorTexture(C_GREEN[1]*0.6, C_GREEN[2]*0.6, C_GREEN[3]*0.6, 0.8)
    else
        row.dot:SetState(hasProgress and "progress" or "empty")
        row.nameFS:SetTextColor(1, 1, 1)
        if (task.max or 1) > 1 then
            row.progFS:SetText(format("%d / %d", task.current or 0, task.max))
        else
            row.progFS:SetText("")
        end
        row.progFS:SetTextColor(hasProgress and C_GOLD[1] or C_MUTED[1],
                                hasProgress and C_GOLD[2] or C_MUTED[2],
                                hasProgress and C_GOLD[3] or C_MUTED[3])
        local rank = rankByID and rankByID[task.id]
        if rank and RANK_C[rank] then
            local rc = RANK_C[rank]
            row.stripe:SetColorTexture(rc[1], rc[2], rc[3], 0.85)
        else
            row.stripe:SetColorTexture(C_MUTED[1], C_MUTED[2], C_MUTED[3], 0.2)
        end
    end
    if (task.points or 0) > 0 then
        row.xpFS:SetText(task.points .. " XP")
        row.xpFS:Show()
    else
        row.xpFS:Hide()
    end
    if (task.couponReward or 0) > 0 then
        if couponIconID and couponIconID > 0 then
            row.cpnIcon:SetTexture(couponIconID)
            row.cpnIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            row.cpnIcon:Show()
        else
            row.cpnIcon:Hide()
        end
        row.cpnFS:SetText(tostring(task.couponReward))
        row.cpnFS:Show()
    else
        row.cpnIcon:Hide()
        row.cpnFS:Hide()
    end
    row:SetScript("OnEnter", function(self)
        if not self.task then return end
        local tk = self.task
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tk.name or "Unknown", 1, 0.82, 0)
        if tk.description and tk.description ~= "" then
            GameTooltip:AddLine(tk.description, 1, 1, 1, true)
        end
        GameTooltip:AddLine(" ")
        if tk.completed then
            GameTooltip:AddLine("Completed", 0.3, 0.9, 0.3)
        else
            GameTooltip:AddLine(format("Progress: %d / %d", tk.current or 0, tk.max or 1), 1, 0.82, 0)
        end
        if (tk.points or 0) > 0 then
            GameTooltip:AddLine("XP Reward: " .. tk.points, C_GREEN[1], C_GREEN[2], C_GREEN[3])
        end
        if (tk.couponReward or 0) > 0 then
            local s = "Coupons: " .. tk.couponReward
            if tk.couponBase and tk.couponBase > tk.couponReward then
                local dr = floor((1 - tk.couponReward/tk.couponBase)*100 + 0.5)
                s = s .. format(" (base %d, -%d%% DR)", tk.couponBase, dr)
            end
            GameTooltip:AddLine(s, 1, 0.9, 0.5)
        end
        if Sys then
            local nx = Sys:GetNextXP(tk.name, tk.id)
            if nx > 0 then GameTooltip:AddLine("Predicted Next XP: ~"..nx, 0.4, 0.7, 1) end
            local rank = rankByID and rankByID[tk.id]
            if rank then
                GameTooltip:AddLine(rank==1 and "|cFF33E5D9#1 Best Task|r" or rank==2 and "|cFF8BA6FF#2 Task|r" or rank==3 and "|cFFFFB833#3 Task|r" or "#"..rank)
            end
            if (tk.accountCompletions or 0) > 0 then GameTooltip:AddLine("Account completions: "..tk.accountCompletions, 0.5,0.5,0.5) end
        end
        if tk.isRepeatable then GameTooltip:AddLine("Repeatable", 0.6,0.6,0.6) end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    row:SetScript("OnMouseDown", function(self, btn)
        if btn == "RightButton" and self.task and self.task.id and Sys then
            if not self.ctxPopup then
                local pop = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                pop:SetFrameStrata("TOOLTIP")
                pop:SetSize(140, 28)
                pop:Hide()
                Backdrop(pop, C_PANEL, C_BORDER)
                pop:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.6)
                local popBtn = CreateFrame("Button", nil, pop, "BackdropTemplate")
                popBtn:SetHeight(20)
                popBtn:SetPoint("TOPLEFT",  pop, "TOPLEFT",   4, -4)
                popBtn:SetPoint("TOPRIGHT", pop, "TOPRIGHT", -4, -4)
                Backdrop(popBtn, C_PANEL, C_BORDER)
                local popLbl = pop:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                popLbl:SetPoint("CENTER", popBtn)
                popLbl:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
                pop.popBtn = popBtn; pop.popLbl = popLbl
                popBtn:SetScript("OnEnter", function(btn)
                    btn:SetBackdropColor(C_ACCENT[1]*0.15, C_ACCENT[2]*0.15, C_ACCENT[3]*0.15, 0.5)
                end)
                popBtn:SetScript("OnLeave", function(btn)
                    btn:SetBackdropColor(0, 0, 0, 0)
                end)
                local catcher = CreateFrame("Frame", nil, UIParent)
                catcher:SetAllPoints(UIParent); catcher:EnableMouse(true); catcher:Hide()
                catcher:SetScript("OnMouseDown", function() pop:Hide(); catcher:Hide() end)
                pop.catcher = catcher
                self.ctxPopup = pop
            end
            local tracked = Sys:IsTaskTracked(self.task.id)
            self.ctxPopup.popLbl:SetText(tracked and "Untrack Endeavor" or "Track Endeavor")
            self.ctxPopup.popBtn:SetScript("OnClick", function()
                self.ctxPopup:Hide(); self.ctxPopup.catcher:Hide()
                if tracked then Sys:UntrackTask(self.task.id)
                else Sys:TrackTask(self.task.id) end
                if self._panel and self._panel.RenderTasks then self._panel:RenderTasks() end
            end)
            self.ctxPopup:ClearAllPoints()
            self.ctxPopup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
            self.ctxPopup:Show()
            self.ctxPopup.catcher:Show()
        end
    end)
end
local function StatRow(parent, labelText, anchorTo, offY)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(20)
    f:SetPoint("TOPLEFT",  anchorTo or parent, anchorTo and "BOTTOMLEFT" or "TOPLEFT",  0, offY or 0)
    f:SetPoint("TOPRIGHT", anchorTo or parent, anchorTo and "BOTTOMRIGHT" or "TOPRIGHT", 0, offY or 0)
    local lbl = FS(f, "GameFontHighlightSmall")
    lbl:SetPoint("LEFT", 0, 0)
    lbl:SetPoint("RIGHT", f, "CENTER", -4, 0)
    lbl:SetJustifyH("LEFT")
    lbl:SetWordWrap(false)
    lbl:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
    lbl:SetText(labelText)
    ApplyFont(lbl, 10)
    f.lbl = lbl
    local val = FS(f, "GameFontHighlightSmall")
    val:SetPoint("LEFT", f, "CENTER", 4, 0)
    val:SetPoint("RIGHT", 0, 0)
    val:SetJustifyH("RIGHT")
    val:SetWordWrap(false)
    val:SetTextColor(1, 1, 1)
    ApplyFont(val, 10)
    f.val = val
    HLine(f, C_BORDER[1], C_BORDER[2], C_BORDER[3], 0.25)
    return f
end
function EndeavorsUI:Create(parent)
    if self.panel then return self.panel end
    local panel = CreateFrame("Frame", "HDEndeavorsPanel", parent)
    panel:SetAllPoints()
    self.panel = panel
    SolidBG(panel, 0.045, 0.045, 0.052)
    local hdr = CreateFrame("Frame", nil, panel)
    hdr:SetPoint("TOPLEFT"); hdr:SetPoint("TOPRIGHT")
    hdr:SetHeight(86)
    SolidBG(hdr, C_HEADER_BG[1], C_HEADER_BG[2], C_HEADER_BG[3], C_HEADER_BG[4])
    HLine(hdr, C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.4)
    local seasonFS = FS(hdr, "GameFontNormal", "OVERLAY")
    seasonFS:SetPoint("TOPLEFT", 10, -8)
    seasonFS:SetTextColor(1, 1, 1)
    ApplyFont(seasonFS, 13)
    panel.seasonFS = seasonFS
    local daysFS = FS(hdr, "GameFontHighlightSmall", "OVERLAY")
    daysFS:SetPoint("TOPRIGHT", -10, -10)
    daysFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
    ApplyFont(daysFS, 10)
    panel.daysFS = daysFS
    local msBar = MakeMilestoneBar(hdr, 22)
    msBar:SetPoint("TOPLEFT",  hdr, "TOPLEFT",  10, -30)
    msBar:SetPoint("TOPRIGHT", hdr, "TOPRIGHT", -48, -30)
    panel.msBar = msBar
    local infoRow = CreateFrame("Frame", nil, hdr)
    infoRow:SetPoint("TOPLEFT",  msBar, "BOTTOMLEFT",  0, -4)
    infoRow:SetPoint("TOPRIGHT", msBar, "BOTTOMRIGHT", 0, -4)
    infoRow:SetHeight(22)
    local filterBtn = CreateFrame("Button", nil, infoRow, "BackdropTemplate")
    filterBtn:SetSize(114, 18)
    filterBtn:SetPoint("LEFT", 0, 0)
    Backdrop(filterBtn, C_PANEL, C_BORDER)
    local filterArrow = Tex(filterBtn, "OVERLAY")
    filterArrow:SetSize(10, 10)
    filterArrow:SetPoint("RIGHT", -4, 0)
    filterArrow:SetAtlas("housing-stair-arrow-down-default")
    local filterLabel = FS(filterBtn, "GameFontHighlightSmall")
    filterLabel:SetPoint("LEFT", 6, 0)
    filterLabel:SetPoint("RIGHT", filterArrow, "LEFT", -3, 0)
    filterLabel:SetJustifyH("LEFT")
    filterLabel:SetWordWrap(false)
    filterLabel:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    filterLabel:SetText("House / Sort")
    ApplyFont(filterLabel, 10)
    filterBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.8)
    end)
    filterBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(C_BORDER[1], C_BORDER[2], C_BORDER[3], C_BORDER[4])
    end)
    panel.filterBtn = filterBtn
    local filterPopup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    filterPopup:SetFrameStrata("TOOLTIP")
    filterPopup:SetWidth(160)
    filterPopup:Hide()
    Backdrop(filterPopup, C_PANEL, C_BORDER)
    filterPopup:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.6)
    local popupTitle = FS(filterPopup, "GameFontNormalSmall")
    popupTitle:SetPoint("TOPLEFT", 8, -6)
    popupTitle:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    ApplyFont(popupTitle, 10, "OUTLINE")
    popupTitle:SetText("HOUSE / SORT")
    local popupRows = {}
    local function ClearPopupRows()
        for _, r in ipairs(popupRows) do r:Hide() end
        wipe(popupRows)
    end
    local function AddPopupDivider(yOff)
        local d = filterPopup:CreateTexture(nil, "ARTWORK")
        d:SetHeight(1)
        d:SetPoint("TOPLEFT",  filterPopup, "TOPLEFT",   6, -yOff)
        d:SetPoint("TOPRIGHT", filterPopup, "TOPRIGHT", -6, -yOff)
        d:SetColorTexture(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.25)
        table.insert(popupRows, d)
        return yOff + 5
    end
    local function AddPopupSectionTitle(text, yOff)
        local fs = FS(filterPopup, "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", filterPopup, "TOPLEFT", 8, -yOff)
        fs:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
        ApplyFont(fs, 9, "OUTLINE")
        fs:SetText(text)
        table.insert(popupRows, fs)
        return yOff + 14
    end
    local function AddPopupRow(text, isSelected, onClick, yOff)
        local btn = CreateFrame("Button", nil, filterPopup, "BackdropTemplate")
        btn:SetHeight(18)
        btn:SetPoint("TOPLEFT",  filterPopup, "TOPLEFT",   4, -yOff)
        btn:SetPoint("TOPRIGHT", filterPopup, "TOPRIGHT", -4, -yOff)
        Backdrop(btn, C_PANEL, C_BORDER)
        if isSelected then
            btn:SetBackdropColor(C_ACCENT[1]*0.2, C_ACCENT[2]*0.2, C_ACCENT[3]*0.2, 0.6)
            btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.5)
        end
        local dot = FS(btn, "GameFontHighlightSmall")
        dot:SetPoint("LEFT", 4, 0)
        dot:SetText(isSelected and "|cFFE8C14A>|r" or " ")
        ApplyFont(dot, 9)
        local lbl = FS(btn, "GameFontHighlightSmall")
        lbl:SetPoint("LEFT", dot, "RIGHT", 2, 0)
        lbl:SetPoint("RIGHT", -4, 0)
        lbl:SetWordWrap(false)
        lbl:SetJustifyH("LEFT")
        lbl:SetText(text)
        ApplyFont(lbl, 10)
        if isSelected then
            lbl:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
        else
            lbl:SetTextColor(0.88, 0.88, 0.88)
        end
        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_ACCENT[1]*0.15, C_ACCENT[2]*0.15, C_ACCENT[3]*0.15, 0.5)
            lbl:SetTextColor(1, 1, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            if isSelected then
                self:SetBackdropColor(C_ACCENT[1]*0.2, C_ACCENT[2]*0.2, C_ACCENT[3]*0.2, 0.6)
                lbl:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
            else
                self:SetBackdropColor(0, 0, 0, 0)
                lbl:SetTextColor(0.88, 0.88, 0.88)
            end
        end)
        btn:SetScript("OnClick", function()
            filterPopup:Hide()
            onClick()
        end)
        table.insert(popupRows, btn)
        return yOff + 20
    end
    local function BuildFilterPopup()
        if not Sys then filterPopup:Hide(); return end
        ClearPopupRows()
        local houses    = Sys:GetHouseList()
        local selIdx    = Sys:GetSelectedHouseIndex()
        local activeGUID = C_NeighborhoodInitiative and
                           C_NeighborhoodInitiative.GetActiveNeighborhood and
                           C_NeighborhoodInitiative.GetActiveNeighborhood()
        local yOff = 20
        yOff = AddPopupSectionTitle("HOUSE", yOff)
        for i, house in ipairs(houses) do
            local lbl = house.neighborhoodName or house.houseName or ("House "..i)
            local isAct = activeGUID and house.neighborhoodGUID == activeGUID
            if isAct then lbl = lbl.." (Active)" end
            local idx = i
            yOff = AddPopupRow(lbl, selIdx == i, function()
                if selIdx ~= idx then Sys:SelectHouse(idx) end
            end, yOff)
        end
        yOff = AddPopupDivider(yOff + 2)
        yOff = AddPopupSectionTitle("SORT TASKS", yOff)
        for _, so in ipairs({{"Default","default"},{"XP","xp"},{"Coupons","coupons"},{"Name","name"},{"Progress","progress"},{"Next XP","nextXP"}}) do
            local lbl, key = so[1], so[2]
            local k = key
            yOff = AddPopupRow(lbl, panel._sortBy == k, function()
                panel._sortBy = k; panel:RenderTasks()
            end, yOff)
        end
        filterPopup:SetHeight(yOff + 6)
    end
    filterPopup:SetScript("OnHide", function()
        filterArrow:SetAtlas("housing-stair-arrow-down-default")
    end)
    local popupCatcher = CreateFrame("Frame", nil, UIParent)
    popupCatcher:SetAllPoints(UIParent)
    popupCatcher:EnableMouse(true)
    popupCatcher:Hide()
    popupCatcher:SetScript("OnMouseDown", function()
        filterPopup:Hide()
        popupCatcher:Hide()
    end)
    filterBtn:SetScript("OnClick", function(self)
        if filterPopup:IsShown() then
            filterPopup:Hide()
            popupCatcher:Hide()
        else
            BuildFilterPopup()
            filterPopup:ClearAllPoints()
            filterPopup:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
            filterPopup:Show()
            popupCatcher:Show()
            filterArrow:SetAtlas("housing-stair-arrow-up-highlight")
        end
    end)
    local cpnIconTex = Tex(infoRow, "OVERLAY")
    cpnIconTex:SetSize(14, 14)
    cpnIconTex:SetPoint("LEFT", filterBtn, "RIGHT", 12, 0)
    panel.cpnIconTex = cpnIconTex
    local cpnFS = FS(infoRow, "GameFontHighlightSmall")
    cpnFS:SetPoint("LEFT", cpnIconTex, "RIGHT", 3, 0)
    cpnFS:SetTextColor(1, 0.85, 0.35)
    ApplyFont(cpnFS, 10)
    panel.cpnFS = cpnFS
    local sep1 = FS(infoRow, "GameFontHighlightSmall")
    sep1:SetPoint("LEFT", cpnFS, "RIGHT", 8, 0)
    sep1:SetText("|"); sep1:SetTextColor(C_BORDER[1], C_BORDER[2], C_BORDER[3])
    ApplyFont(sep1, 10)
    local xpInfoFS = FS(infoRow, "GameFontHighlightSmall")
    xpInfoFS:SetPoint("LEFT", sep1, "RIGHT", 8, 0)
    xpInfoFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
    ApplyFont(xpInfoFS, 10)
    panel.xpInfoFS = xpInfoFS
    local sep2 = FS(infoRow, "GameFontHighlightSmall")
    sep2:SetPoint("LEFT", xpInfoFS, "RIGHT", 8, 0)
    sep2:SetText("|"); sep2:SetTextColor(C_BORDER[1], C_BORDER[2], C_BORDER[3])
    ApplyFont(sep2, 10)
    local capInfoFS = FS(infoRow, "GameFontHighlightSmall")
    capInfoFS:SetPoint("LEFT", sep2, "RIGHT", 8, 0)
    capInfoFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
    ApplyFont(capInfoFS, 10)
    panel.capInfoFS = capInfoFS
    local body = CreateFrame("Frame", nil, panel)
    body:SetPoint("TOPLEFT",  hdr,   "BOTTOMLEFT",  0,  -2)
    body:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0,  0)
    local leftPanel = CreateFrame("Frame", nil, body)
    leftPanel:SetPoint("TOPLEFT"); leftPanel:SetPoint("BOTTOMLEFT")
    local taskHdr = CreateFrame("Frame", nil, leftPanel)
    taskHdr:SetHeight(24)
    taskHdr:SetPoint("TOPLEFT"); taskHdr:SetPoint("TOPRIGHT")
    SolidBG(taskHdr, C_HEADER_BG[1], C_HEADER_BG[2], C_HEADER_BG[3], 0.98)
    HLine(taskHdr, C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.3)
    local taskHdrLbl = FS(taskHdr, "GameFontNormal")
    taskHdrLbl:SetPoint("LEFT", 8, 0)
    taskHdrLbl:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    taskHdrLbl:SetText("ENDEAVOR TASKS")
    ApplyFont(taskHdrLbl, 10, "OUTLINE")
    local function MkHdrToggle(label, tip, anchorTo)
        local btn = PillBtn(taskHdr, label, 26, 16)
        if anchorTo then
            btn:SetPoint("RIGHT", anchorTo, "LEFT", -3, 0)
        else
            btn:SetPoint("RIGHT", taskHdr, "RIGHT", -4, 0)
        end
        btn.active = false
        function btn:Toggle()
            btn.active = not btn.active
            if btn.active then
                btn:SetBackdropColor(C_ACCENT[1]*0.4, C_ACCENT[2]*0.3, 0, 1)
                btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1)
                btn.label:SetTextColor(1, 1, 0.5)
            else
                btn:SetBackdropColor(C_ACCENT_DARK[1], C_ACCENT_DARK[2], C_ACCENT_DARK[3], 0.9)
                btn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.5)
                btn.label:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
            end
        end
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(btn, "ANCHOR_TOP")
            GameTooltip:SetText(tip, 1, 1, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end
    local highlightBtn = MkHdrToggle("HL", "Gold/Silver/Bronze rank highlighting")
    highlightBtn.active = true; highlightBtn:Toggle(); highlightBtn:Toggle()
    highlightBtn.active = true
    highlightBtn:SetBackdropColor(C_ACCENT[1]*0.4, C_ACCENT[2]*0.3, 0, 1)
    highlightBtn:SetBackdropBorderColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 1)
    highlightBtn.label:SetTextColor(1, 1, 0.5)
    local nextXPBtn = MkHdrToggle("~XP", "Show predicted next XP", highlightBtn)
    highlightBtn:SetScript("OnClick", function(self)
        self:Toggle(); panel._highlight = self.active; panel:RenderTasks()
    end)
    nextXPBtn:SetScript("OnClick", function(self)
        self:Toggle(); panel._showNextXP = self.active; panel:RenderTasks()
    end)
    panel._highlight  = true
    panel._showNextXP = false
    local taskScrollWrap = CreateFrame("Frame", nil, leftPanel)
    taskScrollWrap:SetPoint("TOPLEFT",  taskHdr, "BOTTOMLEFT",  0, -2)
    taskScrollWrap:SetPoint("BOTTOMRIGHT", leftPanel, "BOTTOMRIGHT", 0, 0)
    local taskSF, taskContent = MakeScroll(taskScrollWrap)
    taskSF:SetAllPoints()
    local emptyFS = FS(taskContent, "GameFontNormalLarge")
    emptyFS:SetPoint("CENTER", taskContent, "CENTER", 0, 20)
    emptyFS:SetTextColor(0.4, 0.4, 0.4); emptyFS:Hide()
    panel.emptyFS = emptyFS
    local setActiveBtn = PillBtn(taskContent, "Set as Active Endeavor", 180, 24)
    setActiveBtn:SetPoint("TOP", emptyFS, "BOTTOM", 0, -8)
    setActiveBtn:Hide()
    setActiveBtn:SetScript("OnClick", function() if Sys then Sys:SetAsActiveEndeavor() end end)
    panel.setActiveBtn = setActiveBtn
    panel.taskRows    = {}
    panel.taskContent = taskContent
    local rightPanel = CreateFrame("Frame", nil, body)
    local statsHdr = CreateFrame("Frame", nil, rightPanel)
    statsHdr:SetHeight(24)
    statsHdr:SetPoint("TOPLEFT"); statsHdr:SetPoint("TOPRIGHT")
    SolidBG(statsHdr, C_HEADER_BG[1], C_HEADER_BG[2], C_HEADER_BG[3], 0.98)
    HLine(statsHdr, C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.3)
    local statsHdrLbl = FS(statsHdr, "GameFontNormal")
    statsHdrLbl:SetPoint("LEFT", 8, 0)
    statsHdrLbl:SetTextColor(C_ACCENT[1], C_ACCENT[2], C_ACCENT[3])
    statsHdrLbl:SetText("MY STATS")
    ApplyFont(statsHdrLbl, 10, "OUTLINE")
    local statsBody = CreateFrame("Frame", nil, rightPanel)
    statsBody:SetPoint("TOPLEFT",  statsHdr,    "BOTTOMLEFT",  4, -6)
    statsBody:SetPoint("TOPRIGHT", rightPanel,  "TOPRIGHT",   -4, 0)
    statsBody:SetHeight(110)
    local hxpLbl = FS(statsBody, "GameFontHighlightSmall")
    hxpLbl:SetPoint("TOPLEFT"); hxpLbl:SetText("House XP")
    hxpLbl:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
    ApplyFont(hxpLbl, 10)
    local xpBarFrame = CreateFrame("Frame", nil, statsBody)
    xpBarFrame:SetHeight(10)
    xpBarFrame:SetPoint("TOPLEFT",  hxpLbl, "BOTTOMLEFT",  0, -3)
    xpBarFrame:SetPoint("TOPRIGHT", statsBody, "TOPRIGHT",  0, 0)
    SolidBG(xpBarFrame, 0.06, 0.06, 0.07, 0.9)
    local xpBar = CreateFrame("StatusBar", nil, xpBarFrame)
    xpBar:SetAllPoints()
    xpBar:SetMinMaxValues(0, 1); xpBar:SetValue(0)
    xpBar:SetStatusBarColor(C_GREEN[1], C_GREEN[2], C_GREEN[3], 0.85)
    local xpBarBg = Tex(xpBar, "BACKGROUND"); xpBarBg:SetAllPoints()
    xpBarBg:SetColorTexture(0.06, 0.06, 0.07)
    panel.xpBar = xpBar
    local xpValFS = FS(statsBody, "GameFontHighlightSmall")
    xpValFS:SetPoint("TOPLEFT", xpBarFrame, "BOTTOMLEFT", 0, -2)
    xpValFS:SetPoint("TOPRIGHT", xpBarFrame, "BOTTOMRIGHT", 0, -2)
    xpValFS:SetJustifyH("LEFT")
    xpValFS:SetWordWrap(false)
    xpValFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
    ApplyFont(xpValFS, 10)
    panel.xpValFS = xpValFS
    local capRow     = StatRow(statsBody, "XP Cap Status",   xpValFS,  -6)
    local contribRow = StatRow(statsBody, "Contribution",    capRow,   -2)
    local progRow    = StatRow(statsBody, "Season Progress", contribRow, -2)
    panel.capValFS     = capRow.val
    panel.contribValFS = contribRow.val
    panel.progValFS    = progRow.val
    local tabBar = CreateFrame("Frame", nil, rightPanel)
    tabBar:SetHeight(24)
    tabBar:SetPoint("TOPLEFT",  statsBody, "BOTTOMLEFT",  0, -8)
    tabBar:SetPoint("TOPRIGHT", rightPanel, "TOPRIGHT",   0, 0)
    SolidBG(tabBar, C_HEADER_BG[1], C_HEADER_BG[2], C_HEADER_BG[3], 0.8)
    HLine(tabBar, C_ACCENT[1], C_ACCENT[2], C_ACCENT[3], 0.2)
    local actTab  = TabBtn(tabBar, "Activity")
    local lbTab   = TabBtn(tabBar, "Leaderboard")
    local cpnTab2 = TabBtn(tabBar, "Coupons")
    actTab:SetPoint("LEFT", 0, 0)
    lbTab:SetPoint("LEFT", actTab, "RIGHT", 2, 0)
    cpnTab2:SetPoint("LEFT", lbTab, "RIGHT", 2, 0)
    local function MiniToggle(atlas, tip)
        local btn = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
        btn:SetSize(16, 16)
        btn:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
        btn:SetBackdropColor(0.1,0.1,0.12,0.6)
        btn:SetBackdropBorderColor(C_BORDER[1],C_BORDER[2],C_BORDER[3],0.4)
        local ic = Tex(btn); ic:SetSize(12,12); ic:SetPoint("CENTER")
        ic:SetAtlas(atlas); ic:SetAlpha(0.55)
        btn.ic = ic; btn.active = false
        function btn:SetActive(v)
            btn.active = v
            ic:SetAlpha(v and 1 or 0.5)
            ic:SetDesaturated(not v)
            btn:SetBackdropColor(v and C_ACCENT_DARK[1] or 0.1, v and C_ACCENT_DARK[2] or 0.1, v and C_ACCENT_DARK[3] or 0.12, v and 0.9 or 0.6)
            btn:SetBackdropBorderColor(v and C_ACCENT[1] or C_BORDER[1], v and C_ACCENT[2] or C_BORDER[2], v and C_ACCENT[3] or C_BORDER[3], v and 0.7 or 0.4)
        end
        btn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(btn,"ANCHOR_TOP"); GameTooltip:SetText(tip,1,1,1); GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        return btn
    end
    local filterMeBtn  = MiniToggle("housefinder_neighborhood-list-friend-icon",  "Filter: Me Only")
    local filterAltBtn = MiniToggle("housefinder_neighborhood-friends-icon",       "Filter: My Characters")
    local refreshBtn2  = MiniToggle("UI-RefreshButton",                            "Refresh Activity Log")
    refreshBtn2.active = false
    filterMeBtn:SetPoint( "RIGHT", refreshBtn2, "LEFT", -3, 0)
    filterAltBtn:SetPoint("RIGHT", filterMeBtn,  "LEFT", -2, 0)
    refreshBtn2:SetPoint( "RIGHT", tabBar,       "RIGHT", -4, 0)
    refreshBtn2.ic:SetDesaturated(false); refreshBtn2.ic:SetAlpha(0.55)
    filterMeBtn:SetScript("OnClick", function(self)
        local v = not self.active; self:SetActive(v)
        if v then filterAltBtn:SetActive(false) end
        panel:RenderRight()
    end)
    filterAltBtn:SetScript("OnClick", function(self)
        local v = not self.active; self:SetActive(v)
        if v then filterMeBtn:SetActive(false) end
        panel:RenderRight()
    end)
    refreshBtn2:SetScript("OnClick", function()
        if Sys then Sys:RefreshActivityLog() end
    end)
    panel.filterMeBtn  = filterMeBtn
    panel.filterAltBtn = filterAltBtn
    local rightScrollWrap = CreateFrame("Frame", nil, rightPanel)
    rightScrollWrap:SetPoint("TOPLEFT",    tabBar, "BOTTOMLEFT",  0, -2)
    rightScrollWrap:SetPoint("BOTTOMRIGHT", rightPanel, "BOTTOMRIGHT", 0, 0)
    local rightSF, rightContent = MakeScroll(rightScrollWrap)
    rightSF:SetAllPoints()
    panel.rightContent = rightContent
    panel.rightRows    = {}
    local RIGHT_PANEL_W = 340
    rightPanel:ClearAllPoints()
    rightPanel:SetPoint("TOPRIGHT",    body, "TOPRIGHT",    0, 0)
    rightPanel:SetPoint("BOTTOMRIGHT", body, "BOTTOMRIGHT", 0, 0)
    rightPanel:SetWidth(RIGHT_PANEL_W)
    leftPanel:SetPoint("BOTTOMLEFT",  body, "BOTTOMLEFT",  0, 0)
    leftPanel:SetPoint("TOPRIGHT",    rightPanel, "TOPLEFT",    -6, 0)
    local function LayoutBody() end
    panel._rightTab = "activity"
    local function SetTab(key)
        panel._rightTab = key
        actTab:SetActive(key == "activity")
        lbTab:SetActive(key == "leaderboard")
        cpnTab2:SetActive(key == "coupons")
        panel:RenderRight()
    end
    actTab:SetScript( "OnClick", function() SetTab("activity") end)
    lbTab:SetScript(  "OnClick", function() SetTab("leaderboard") end)
    cpnTab2:SetScript("OnClick", function() SetTab("coupons") end)
    function panel:RenderTopBar()
        if not Sys then return end
        local info = Sys:GetEndeavorInfo()
        if not info then return end
        self.seasonFS:SetText(info.seasonName or "")
        self.daysFS:SetText(format("%d days remaining", info.daysRemaining or 0))
        local cur  = info.currentProgress or 0
        local maxP = info.maxProgress or 1
        self.msBar:SetMinMaxValues(0, maxP)
        self.msBar:SetValue(cur)
        local cpnIconID2 = Sys and Sys:GetCouponIconID() or 0
        UpdateMilestoneMarkers(self.msBar, info.milestones, cur, maxP, cpnIconID2)
        local cpnID = Sys:GetCouponIconID()
        self.cpnIconTex:SetTexture(cpnID)
        self.cpnIconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        self.cpnFS:SetText(Sys:GetCommunityCoupons() .. " Coupons")
        local cap = Sys:GetXPCapStatus()
        if cap then
            self.xpInfoFS:SetText(format("%.0f XP", cap.currentXP))
            if cap.isPostCapped then
                self.capInfoFS:SetText("XP Capped!")
                self.capInfoFS:SetTextColor(1, 0.3, 0.3)
            elseif cap.isPreCapped then
                self.capInfoFS:SetText(format("%d / %d XP (pre-cap full)", floor(cap.currentXP), cap.postCap))
                self.capInfoFS:SetTextColor(1, 0.7, 0.3)
            else
                self.capInfoFS:SetText(format("%d XP until cap", cap.preCap - floor(cap.currentXP)))
                self.capInfoFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
            end
        else
            self.xpInfoFS:SetText("0 XP")
            self.capInfoFS:SetText("")
        end
    end
    local cachedHouseLevel = nil
    local cachedHouseXP    = 0
    local cachedHouseMaxXP = 0
    local function RequestHouseLevelFavor()
        if not (C_Housing and C_Housing.GetCurrentHouseLevelFavor) then return end
        local houses = Sys and Sys:GetHouseList()
        local idx    = Sys and Sys:GetSelectedHouseIndex()
        local house  = houses and houses[idx]
        if house and house.houseGUID then
            pcall(C_Housing.GetCurrentHouseLevelFavor, house.houseGUID)
        end
    end
    do
        local evFrame = CreateFrame("Frame")
        evFrame:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED")
        evFrame:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
        evFrame:SetScript("OnEvent", function(_, event, ...)
            if event == "HOUSE_LEVEL_FAVOR_UPDATED" then
                local favor = ...
                if not favor then return end
                cachedHouseLevel = favor.houseLevel or 1
                cachedHouseXP    = favor.houseFavor or 0
                local maxLevel = 50
                if C_Housing and C_Housing.GetMaxHouseLevel then
                    local ok, mx = pcall(C_Housing.GetMaxHouseLevel)
                    if ok and mx then maxLevel = mx end
                end
                if cachedHouseLevel < maxLevel and C_Housing and C_Housing.GetHouseLevelFavorForLevel then
                    local ok, needed = pcall(C_Housing.GetHouseLevelFavorForLevel, cachedHouseLevel + 1)
                    cachedHouseMaxXP = (ok and needed) and needed or 0
                end
                if panel:IsShown() then panel:RenderStats() end
            elseif event == "PLAYER_HOUSE_LIST_UPDATED" then
                cachedHouseLevel = nil
                RequestHouseLevelFavor()
            end
        end)
    end
    function panel:RenderStats()
        if not Sys then return end
        if cachedHouseLevel == nil then RequestHouseLevelFavor() end
        local level      = cachedHouseLevel or "?"
        local houseXP    = cachedHouseXP
        local houseMaxXP = cachedHouseMaxXP
        self.xpBar:SetMinMaxValues(0, max(houseMaxXP, 1))
        self.xpBar:SetValue(min(houseXP, houseMaxXP))
        if houseMaxXP > 0 then
            self.xpValFS:SetText(format("Lvl %s  |  %.0f / %d XP", tostring(level), houseXP, houseMaxXP))
        else
            self.xpValFS:SetText(format("Lvl %s  |  %.0f XP", tostring(level), houseXP))
        end
        local cap = Sys:GetXPCapStatus()
        if cap then
            if cap.isPostCapped then
                self.capValFS:SetText("|cFFFF5555CAPPED|r")
            elseif cap.isPreCapped then
                self.capValFS:SetText("|cFFFFAA33Pre-cap done|r")
            else
                self.capValFS:SetText("|cFF55DD55ON TRACK|r")
            end
        else
            self.capValFS:SetText("Waiting...")
        end
        local contrib = Sys:GetPlayerContribution()
        if contrib and contrib > 0 then
            self.contribValFS:SetText(format("%.1f PTS", contrib))
            self.contribValFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
        else
            self.contribValFS:SetText("Waiting...")
            self.contribValFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
        end
        local info = Sys:GetEndeavorInfo()
        if info and info.maxProgress and info.maxProgress > 0 then
            local pct = floor(info.currentProgress / info.maxProgress * 100 + 0.5)
            self.progValFS:SetText(format("%d%%", pct))
            self.progValFS:SetTextColor(1, 1, 1)
        else
            self.progValFS:SetText("Waiting...")
            self.progValFS:SetTextColor(C_MUTED[1], C_MUTED[2], C_MUTED[3])
        end
    end
    function panel:RenderTasks()
        if not Sys then return end
        local tasks    = Sys:GetTasks(self._sortBy or "default")
        local rankings = self._highlight and Sys:GetTaskRankings() or {}
        local cpnID    = Sys:GetCouponIconID()
        for _, row in ipairs(self.taskRows) do row:Hide() end
        if not tasks or #tasks == 0 then
            local fs = Sys:GetFetchStatus()
            local fetching = fs.state == "fetching" or fs.state == "retrying"
            if fetching then
                self.emptyFS:SetText("Loading endeavor tasks...")
            elseif Sys:IsViewingActiveNeighborhood() then
                self.emptyFS:SetText("No tasks available.")
                self.setActiveBtn:Hide()
            else
                self.emptyFS:SetText("This house has no active endeavor.")
                self.setActiveBtn:Show()
            end
            self.emptyFS:Show()
            taskContent:SetHeight(100)
            return
        end
        self.emptyFS:Hide()
        self.setActiveBtn:Hide()
        local yOff = 0
        for i, task in ipairs(tasks) do
            local row = self.taskRows[i]
            if not row then
                row = MakeTaskRow(taskContent, i)
                row._panel = self
                self.taskRows[i] = row
            end
            UpdateTaskRow(row, task, rankings, cpnID, i)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT",  taskContent, "TOPLEFT",  0, -yOff)
            row:SetPoint("TOPRIGHT", taskContent, "TOPRIGHT", 0, -yOff)
            row:SetHeight(ROW_H)
            row:Show()
            yOff = yOff + ROW_H + 1
        end
        local twrapH = taskScrollWrap:GetHeight() or 0
        taskContent:SetHeight(max(yOff + 4, twrapH > 0 and twrapH or (yOff + 4)))
    end
    function panel:RenderRight()
        if not Sys then return end
        for _, row in ipairs(self.rightRows) do row:Hide() end
        local yOff  = 0
        local ct    = rightContent
        local rIdx  = 1
        local function EnsureRow(h)
            local row = self.rightRows[rIdx]
            if not row then
                row = CreateFrame("Frame", nil, ct, "BackdropTemplate")
                row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
                self.rightRows[rIdx] = row
            end
            if row._tabType and row._tabType ~= self._rightTab then
                local fields = {"timeFS","rankFS","nameFS","taskFS","amtFS","emptyFS"}
                for _, k in ipairs(fields) do
                    if row[k] then row[k]:Hide(); row[k] = nil end
                end
            end
            row._tabType = self._rightTab
            local c = rIdx % 2 == 0 and C_ROW_EVEN or C_ROW_ODD
            row:SetBackdropColor(c[1], c[2], c[3], c[4])
            row:SetHeight(h or 20)
            row:SetPoint("TOPLEFT",  ct, "TOPLEFT",  0, -yOff)
            row:SetPoint("TOPRIGHT", ct, "TOPRIGHT", 0, -yOff)
            local fields = {"timeFS","rankFS","nameFS","taskFS","amtFS","emptyFS"}
            for _, k in ipairs(fields) do
                if row[k] then row[k]:Hide() end
            end
            row:Show()
            return row
        end
        if self._rightTab == "activity" then
            local me    = self.filterMeBtn.active
            local myAlt = self.filterAltBtn.active
            local feed  = Sys:GetActivityFeed(me, myAlt)
            local player = UnitName("player") or ""
            local myChars = Sys.GetMyChars and Sys:GetMyChars() or {}

            local function TaskColor(taskName)
                if not taskName then return 0.75, 0.75, 0.72 end
                local t = taskName:lower()
                if t:find("kill") or t:find("slay") or t:find("defeat") or t:find("rare") then
                    return 0.95, 0.45, 0.35
                elseif t:find("craft") or t:find("tailor") or t:find("smith") or t:find("enchant")
                    or t:find("alche") or t:find("inscri") or t:find("jewel") or t:find("leather") then
                    return 0.35, 0.85, 0.75
                elseif t:find("quest") or t:find("complete") or t:find("weekly") or t:find("bounty") then
                    return 0.45, 0.70, 1.0
                elseif t:find("gather") or t:find("mine") or t:find("herb") or t:find("fish") or t:find("lumber") then
                    return 0.55, 0.85, 0.40
                elseif t:find("pvp") or t:find("battleground") or t:find("arena") then
                    return 1.0, 0.55, 0.20
                end
                return 0.80, 0.75, 0.60
            end

            if #feed == 0 then
                local row = EnsureRow(40)
                if not row.emptyFS then
                    row.emptyFS = FS(row, "GameFontHighlightSmall")
                    row.emptyFS:SetPoint("CENTER")
                    row.emptyFS:SetTextColor(0.4, 0.4, 0.4)
                end
                row.emptyFS:SetText("No activity data."); row.emptyFS:Show()
                yOff = yOff + 40; rIdx = rIdx + 1
            else
                for ri, entry in ipairs(feed) do
                    local row = EnsureRow(20)
                    if not row.timeFS then
                        row.timeFS = FS(row, "GameFontHighlightSmall")
                        row.timeFS:SetPoint("LEFT", 4, 0); row.timeFS:SetWidth(26)
                        row.timeFS:SetJustifyH("LEFT")
                        ApplyFont(row.timeFS, 9)

                        row.nameFS = FS(row, "GameFontHighlightSmall")
                        row.nameFS:SetPoint("LEFT", row.timeFS, "RIGHT", 2, 0); row.nameFS:SetWidth(80)
                        row.nameFS:SetJustifyH("LEFT"); row.nameFS:SetWordWrap(false)
                        ApplyFont(row.nameFS, 10)

                        row.taskFS = FS(row, "GameFontHighlightSmall")
                        row.taskFS:SetPoint("LEFT", row.nameFS, "RIGHT", 4, 0)
                        row.taskFS:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                        row.taskFS:SetJustifyH("RIGHT"); row.taskFS:SetWordWrap(false)
                        ApplyFont(row.taskFS, 9)
                    end

                    local diff = entry.completionTime and (time() - entry.completionTime) or 0
                    local ts
                    if diff < 60 then ts = "<1m"
                    elseif diff < 3600 then ts = floor(diff/60).."m"
                    elseif diff < 86400 then ts = floor(diff/3600).."h"
                    else ts = floor(diff/86400).."d" end

                    local isMe   = (entry.playerName or "") == player
                    local isAlt  = not isMe and myChars[(entry.playerName or "")]

                    local timeR, timeG, timeB
                    if isMe then
                        timeR, timeG, timeB = 0.25, 0.55, 0.25
                    elseif isAlt then
                        timeR, timeG, timeB = 0.20, 0.45, 0.55
                    else
                        timeR, timeG, timeB = 0.38, 0.38, 0.38
                    end
                    row.timeFS:SetTextColor(timeR, timeG, timeB)
                    row.timeFS:SetText(ts); row.timeFS:Show()

                    if isMe then
                        row.nameFS:SetTextColor(0.35, 0.95, 0.45)
                    elseif isAlt then
                        row.nameFS:SetTextColor(0.35, 0.85, 0.95)
                    else
                        row.nameFS:SetTextColor(0.90, 0.88, 0.82)
                    end
                    row.nameFS:SetText(entry.playerName or "?"); row.nameFS:Show()

                    local tr, tg, tb = TaskColor(entry.taskName)
                    if isMe then
                        tr, tg, tb = tr * 1.0, tg * 1.0, tb * 1.0
                    elseif isAlt then
                        tr, tg, tb = tr * 0.85, tg * 0.85, tb * 0.85
                    else
                        tr, tg, tb = tr * 0.70, tg * 0.70, tb * 0.70
                    end
                    row.taskFS:SetTextColor(tr, tg, tb)
                    row.taskFS:SetText(entry.taskName or ""); row.taskFS:Show()

                    yOff = yOff + 21; rIdx = rIdx + 1
                end
            end
        elseif self._rightTab == "leaderboard" then
            local lb = Sys:GetLeaderboard()
            local player = UnitName("player") or ""
            if #lb == 0 then
                local row = EnsureRow(40)
                if not row.emptyFS then
                    row.emptyFS = FS(row, "GameFontHighlightSmall"); row.emptyFS:SetPoint("CENTER")
                    row.emptyFS:SetTextColor(0.4,0.4,0.4)
                end
                row.emptyFS:SetText("No leaderboard data."); row.emptyFS:Show()
                yOff = yOff + 40; rIdx = rIdx + 1
            else
                for rank, entry in ipairs(lb) do
                    local row = EnsureRow(22)
                    if not row.amtFS then
                        row.rankFS = FS(row, "GameFontHighlightSmall")
                        row.rankFS:SetPoint("LEFT", 4, 0); row.rankFS:SetWidth(28); row.rankFS:SetJustifyH("CENTER")
                        ApplyFont(row.rankFS, 10)
                        row.amtFS = FS(row, "GameFontHighlightSmall")
                        row.amtFS:SetPoint("RIGHT", -4, 0); row.amtFS:SetWidth(50); row.amtFS:SetJustifyH("RIGHT")
                        row.amtFS:SetTextColor(C_GREEN[1], C_GREEN[2], C_GREEN[3])
                        ApplyFont(row.amtFS, 10)
                        row.nameFS = FS(row, "GameFontHighlightSmall")
                        row.nameFS:SetPoint("LEFT", row.rankFS, "RIGHT", 4, 0)
                        row.nameFS:SetPoint("RIGHT", row.amtFS, "LEFT", -2, 0)
                        row.nameFS:SetJustifyH("LEFT"); row.nameFS:SetWordWrap(false)
                        ApplyFont(row.nameFS, 10)
                    end
                    local rc = RANK_C[rank] or {0.6,0.6,0.6,1}
                    row.rankFS:SetText("#"..rank); row.rankFS:SetTextColor(rc[1],rc[2],rc[3]); row.rankFS:Show()
                    row.nameFS:SetText(entry.name); row.nameFS:Show()
                    row.nameFS:SetTextColor(
                        entry.isPlayer and 1 or entry.isMyChar and 0.85 or 0.9,
                        entry.isPlayer and 0.82 or entry.isMyChar and 0.92 or 0.9,
                        entry.isPlayer and 0 or entry.isMyChar and 0.5 or 0.9)
                    row.amtFS:SetText(format("%.1f", entry.amount)); row.amtFS:Show()
                    yOff = yOff + 23; rIdx = rIdx + 1
                end
            end
        elseif self._rightTab == "coupons" then
            HomeDecorDB = HomeDecorDB or {}
            HomeDecorDB.endeavors = HomeDecorDB.endeavors or {}
            local gains = HomeDecorDB.endeavors.couponGains or {}
            local sorted = {}
            for _, g in ipairs(gains) do if g.taskName then table.insert(sorted, g) end end
            table.sort(sorted, function(a,b) return (a.timestamp or 0) > (b.timestamp or 0) end)
            if #sorted == 0 then
                local row = EnsureRow(50)
                if not row.emptyFS then
                    row.emptyFS = FS(row, "GameFontHighlightSmall"); row.emptyFS:SetPoint("CENTER")
                    row.emptyFS:SetTextColor(0.4,0.4,0.4)
                end
                row.emptyFS:SetText("No coupon gains tracked yet."); row.emptyFS:Show()
                yOff = yOff + 50; rIdx = rIdx + 1
            else
                for _, g in ipairs(sorted) do
                    local row = EnsureRow(20)
                    if not row.timeFS then
                        row.timeFS = FS(row,"GameFontHighlightSmall"); row.timeFS:SetPoint("LEFT",4,0); row.timeFS:SetWidth(32)
                        row.timeFS:SetJustifyH("LEFT"); row.timeFS:SetTextColor(0.5,0.5,0.5); ApplyFont(row.timeFS,9)
                        row.taskFS = FS(row,"GameFontHighlightSmall")
                        row.taskFS:SetPoint("LEFT",row.timeFS,"RIGHT",2,0); row.taskFS:SetPoint("RIGHT",row,"RIGHT",-36,0)
                        row.taskFS:SetJustifyH("LEFT"); row.taskFS:SetTextColor(0.9,0.9,0.9); ApplyFont(row.taskFS,10)
                        row.amtFS = FS(row,"GameFontHighlightSmall"); row.amtFS:SetPoint("RIGHT",-4,0); row.amtFS:SetJustifyH("RIGHT")
                        row.amtFS:SetTextColor(0.16,0.85,0.80); ApplyFont(row.amtFS,10)
                    end
                    local diff = g.timestamp and (time()-g.timestamp) or 0
                    local ts
                    if diff < 3600 then ts = floor(diff/60).."m"
                    elseif diff < 86400 then ts = floor(diff/3600).."h"
                    else ts = floor(diff/86400).."d" end
                    row.timeFS:SetText(ts); row.timeFS:Show()
                    row.taskFS:SetText(g.taskName); row.taskFS:Show()
                    row.amtFS:SetText("+"..( g.amount or 0)); row.amtFS:Show()
                    yOff = yOff + 21; rIdx = rIdx + 1
                end
            end
        end
        local wrapH = rightScrollWrap:GetHeight() or 0
        rightContent:SetHeight(max(yOff + 8, wrapH > 0 and wrapH or (yOff + 8)))
    end
    function panel:FullRefresh()
        self:RenderTopBar()
        self:RenderStats()
        self:RenderTasks()
        self:RenderRight()
    end
    if Sys then
        Sys.OnDataReady = function()
            if panel:IsShown() then
                panel:RenderTopBar(); panel:RenderStats(); panel:RenderTasks()
            end
        end
        Sys.OnActivityLogReady = function()
            if panel:IsShown() then
                panel:RenderStats()
                panel:RenderRight()
            end
        end
        Sys.OnHouseListUpdated = function()
            if panel:IsShown() then panel:RenderTopBar() end
        end
        Sys.OnActiveNeighborhoodChanged = function()
            if panel:IsShown() then panel:FullRefresh() end
        end
    end
    panel:SetScript("OnShow", function(self)
        if Sys then
            Sys:FetchData()
            Sys:RequestActivityLog()
            if Sys.IsActivityLogLoaded and Sys:IsActivityLogLoaded() then
                Sys:RefreshActivityLog()
            end
        end
        self:FullRefresh()
        C_Timer.After(1.5, function()
            if Sys and panel:IsShown() then
                Sys:RefreshActivityLog(); panel:RenderRight()
            end
        end)
    end)
    SetTab("activity")
    return panel
end
return EndeavorsUI
