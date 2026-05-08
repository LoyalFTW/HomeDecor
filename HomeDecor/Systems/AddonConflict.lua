local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local AC = {}
NS.Systems.AddonConflict = AC

local function L(key) return (NS.L and NS.L[key]) or key end

local function getPrefs()
    if not NS.db then return nil end
    NS.db.profile.addonConflict = NS.db.profile.addonConflict or {}
    return NS.db.profile.addonConflict
end

function AC.IsFeatureEnabled(feature)
    local p = getPrefs()
    return not p or p[feature] ~= false
end

local function anotherAddonProvidesEditingFeatures()
    local frames = { "ADTQuickbarFrame", "HousingCompanionQuickBar", "AdvancedDecorationQuickBar" }
    for _, name in ipairs(frames) do
        if _G[name] then return true end
    end
    local addons = { "AdvancedDecorationTools", "HousingCompanion" }
    for _, name in ipairs(addons) do
        if C_AddOns.IsAddOnLoaded(name) then return true end
    end
    return false
end

local function editorShown()
    return HouseEditorFrame and HouseEditorFrame:IsShown()
end

local function disableEditingFeatures()
    local prof = NS.db and NS.db.profile
    if prof then
        prof.quickBar = prof.quickBar or {}
        prof.quickBar.enabled = false
    end
    local QB = NS.Systems.QuickBar
    if QB then
        if QB.UI   then QB.UI:Hide()    end
        if QB.Keys then QB.Keys.Clear() end
    end
    local EM = NS.Systems.EditMode
    if EM then
        local db = EM.DB()
        db.on = false; db.hud = false; db.clipboard = false
        db.batchPlace = false; db.lock = false; db.rotPanel = false
        if editorShown() then
            if EM.HUD      then EM.HUD.Destroy()  end
            if EM.RotPanel then EM.RotPanel.Hide() end
            if EM.Keys     then EM.Keys.Clear()    end
            if EM.Batch    then EM.Batch.Reset()   end
        end
    end
end

local function enableEditingFeatures()
    local prof = NS.db and NS.db.profile
    if prof then
        prof.quickBar = prof.quickBar or {}
        prof.quickBar.enabled = true
    end
    local EM = NS.Systems.EditMode
    if EM then
        local db = EM.DB()
        db.on = true; db.hud = true; db.clipboard = true
        db.batchPlace = true; db.lock = true; db.rotPanel = true
        if editorShown() then
            if EM.HUD      then EM.HUD.Boot(); EM.HUD.Refresh() end
            if EM.RotPanel then EM.RotPanel.Boot()               end
            if EM.Keys     then EM.Keys.Apply()                  end
        end
    end
    local QB = NS.Systems.QuickBar
    if QB and editorShown() then
        if QB.UI   then QB.UI:Show()    end
        if QB.Keys then QB.Keys.Apply() end
    end
end

local dialogFrame

local function buildDialogFrame()
    local parent = (HouseEditorFrame and HouseEditorFrame:IsShown()) and HouseEditorFrame or UIParent
    local f = CreateFrame("Frame", "HomeDecorConflictDialog", parent, "BackdropTemplate")
    f:SetSize(400, 200)
    f:SetPoint("CENTER", parent, "CENTER", 0, 80)
    f:SetFrameStrata("TOOLTIP")
    f:SetFrameLevel(200)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    f:SetBackdropColor(0, 0, 0, 1)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -20)
    title:SetText("|cff00ccffHomeDecor|r  -  " .. L("CONFLICT_TITLE"))

    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0.35, 0.35, 0.35, 0.8)
    divider:SetSize(350, 1)
    divider:SetPoint("TOP", title, "BOTTOM", 0, -8)

    local line1 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line1:SetPoint("TOP", divider, "BOTTOM", 0, -16)
    line1:SetJustifyH("CENTER")
    line1:SetText(L("CONFLICT_LINE1"))

    local line2 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line2:SetPoint("TOP", line1, "BOTTOM", 0, -10)
    line2:SetJustifyH("CENTER")
    line2:SetTextColor(0.7, 0.7, 0.7, 1)
    line2:SetText(L("CONFLICT_LINE2"))

    local line3 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line3:SetPoint("TOP", line2, "BOTTOM", 0, -8)
    line3:SetJustifyH("CENTER")
    line3:SetTextColor(0.5, 0.5, 0.5, 1)
    line3:SetText(L("CONFLICT_LINE3"))

    local btnDisable = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnDisable:SetSize(116, 28)
    btnDisable:SetPoint("BOTTOM", f, "BOTTOM", -136, 18)
    btnDisable:SetText(L("CONFLICT_BTN_DISABLE"))
    btnDisable:SetScript("OnClick", function()
        getPrefs()["EditingFeatures"] = false
        disableEditingFeatures()
        f:Hide()
        print("|cff00ccff[HomeDecor]|r " .. L("CONFLICT_MSG_DISABLED"))
    end)

    local btnKeep = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnKeep:SetSize(116, 28)
    btnKeep:SetPoint("LEFT", btnDisable, "RIGHT", 20, 0)
    btnKeep:SetText(L("CONFLICT_BTN_KEEP"))
    btnKeep:SetScript("OnClick", function()
        getPrefs()["EditingFeatures"] = true
        enableEditingFeatures()
        f:Hide()
        print("|cff00ccff[HomeDecor]|r " .. L("CONFLICT_MSG_KEPT"))
    end)

    local btnLater = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnLater:SetSize(116, 28)
    btnLater:SetPoint("LEFT", btnKeep, "RIGHT", 20, 0)
    btnLater:SetText(L("CONFLICT_BTN_LATER"))
    btnLater:SetScript("OnClick", function()
        f:Hide()
        print("|cff00ccff[HomeDecor]|r " .. L("CONFLICT_MSG_LATER"))
    end)

    return f
end

local dbReady = false

local function tryShowDialog()
    if not dbReady then return end
    local p = getPrefs()
    if p and p["EditingFeatures"] ~= nil then return end
    if not anotherAddonProvidesEditingFeatures() then return end
    if dialogFrame and dialogFrame:IsShown() then return end
    if not dialogFrame then dialogFrame = buildDialogFrame() end
    dialogFrame:Show()
    dialogFrame:Raise()
end

local acWired = false
local acPoll = CreateFrame("Frame")
acPoll:Show()
acPoll:SetScript("OnUpdate", function(self)
    if not HouseEditorFrame then return end
    self:SetScript("OnUpdate", nil)
    if acWired then return end
    acWired = true
    HouseEditorFrame:HookScript("OnShow", tryShowDialog)
    HouseEditorFrame:HookScript("OnHide", function()
        if dialogFrame then dialogFrame:Hide() end
    end)
    if HouseEditorFrame:IsShown() then
        tryShowDialog()
    end
end)

function AC.Init()
    dbReady = true
    if acWired and HouseEditorFrame and HouseEditorFrame:IsShown() then
        tryShowDialog()
    end
end

function AC.ResetConflicts()
    local p = getPrefs()
    if not p then
        print("|cff00ccff[HomeDecor]|r " .. L("CONFLICT_NOT_READY"))
        return
    end
    p["EditingFeatures"] = nil
    print("|cff00ccff[HomeDecor]|r " .. L("CONFLICT_RESET"))
    tryShowDialog()
end
