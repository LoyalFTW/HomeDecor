local ADDON, NS = ...

local C = NS.UI.Controls
local T = NS.UI.Theme.colors

local M = {}
NS.UI.ViewerWowhead = M

local _wowheadPopup

function M.BuildItemURL(itemID)
    if not itemID then return nil end
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

function M.BuildAchievementURL(achievementID)
    if not achievementID then return nil end
    return "https://www.wowhead.com/achievement=" .. tostring(achievementID)
end

function M.BuildQuestURL(questID)
    if not questID then return nil end
    return "https://www.wowhead.com/quest=" .. tostring(questID)
end

function M.ShowLinks(links)
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

return M
