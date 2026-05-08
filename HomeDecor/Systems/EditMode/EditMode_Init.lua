local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM = NS.Systems.EditMode

local function mergeDefaults(db)
    for k, v in pairs(EM.defaults) do
        if db[k] == nil then
            if type(v) == "table" then
                local copy = {}
                for sk, sv in pairs(v) do copy[sk] = sv end
                db[k] = copy
            else
                db[k] = v
            end
        elseif type(v) == "table" and type(db[k]) == "table" then
            for sk, sv in pairs(v) do
                if db[k][sk] == nil then db[k][sk] = sv end
            end
        end
    end
end

local QB_KEY_DEFAULTS = { "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8" }

local function mergeQuickBarDefaults(db)
    db.enabled  = (db.enabled ~= false)
    db.page     = db.page or 1
    db.hotbars  = db.hotbars or {}
    db.keybinds = db.keybinds or {}
    for i = 1, 8 do
        if db.keybinds[i] == nil then db.keybinds[i] = QB_KEY_DEFAULTS[i] end
    end
end

local function onEditorShown()
    EM.HUD.Boot()
    EM.RotPanel.Boot()
    EM.Keys.Apply()
    EM.HUD.Refresh()
end

local function onEditorHidden()
    EM.HUD.Destroy()
    EM.RotPanel.Hide()
    EM.Keys.Clear()
    EM.Batch.Reset()
end

-- Poll for HouseEditorFrame at file scope so we catch it the instant it
-- exists, even if OnShow fires before ADDON_LOADED reaches us.
local editorWired = false
local pollFrame = CreateFrame("Frame")
pollFrame:Show()
pollFrame:SetScript("OnUpdate", function(self)
    if not HouseEditorFrame then return end
    self:SetScript("OnUpdate", nil)  -- stop polling immediately
    if editorWired then return end
    editorWired = true

    HouseEditorFrame:HookScript("OnShow", onEditorShown)
    HouseEditorFrame:HookScript("OnHide", onEditorHidden)

    -- Frame may already be visible if it showed before we wired it
    if HouseEditorFrame:IsShown() then
        onEditorShown()
    end
end)

local evFrame = CreateFrame("Frame")
evFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "HOUSE_EDITOR_MODE_CHANGED" then
        EM.HUD.Refresh()
        EM.RotPanel.OnModeChange()
        C_Timer.After(0, EM.Keys.Apply)
    elseif event == "HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED" then
        EM.HUD.Refresh()
    elseif event == "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED" then
        EM.Lock.OnSelected(...)
        EM.HUD.Refresh()
    elseif event == "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED" then
        EM.Lock.OnSelected(...)
        EM.RotPanel.OnSelection()
    elseif event == "HOUSING_DECOR_PLACE_SUCCESS" then
        EM.Batch.OnPlaced(...)
    end
end)

function EM.Init()
    local db = NS.db and NS.db.profile
    if db then
        db.editMode = db.editMode or {}
        mergeDefaults(db.editMode)
        db.quickBar = db.quickBar or {}
        mergeQuickBarDefaults(db.quickBar)
    end

    evFrame:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    evFrame:RegisterEvent("HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED")
    evFrame:RegisterEvent("HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED")
    evFrame:RegisterEvent("HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED")
    evFrame:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")

    local AC = NS.Systems.AddonConflict
    if AC and AC.Init then AC.Init() end

    local QB = NS.Systems.QuickBar
    if QB then
        if QB.Init then QB.Init() end
        if AC and not AC.IsFeatureEnabled("EditingFeatures") then
            if QB.Keys and QB.Keys.Clear then QB.Keys.Clear() end
        elseif QB.UI and QB.UI.Init then
            QB.UI.Init()
        end
    end
end
