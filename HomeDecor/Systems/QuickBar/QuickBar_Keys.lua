local ADDON, NS = ...
NS.Systems        = NS.Systems or {}
NS.Systems.QuickBar = NS.Systems.QuickBar or {}

local QB   = NS.Systems.QuickBar
local Keys = {}
QB.Keys = Keys

local owner    = nil
local btnSlots = {}

local KEY_DEFAULTS = { "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8" }

function Keys.GetKeybind(i)
    local db = NS.db and NS.db.profile and NS.db.profile.quickBar
    local saved = db and db.keybinds and db.keybinds[i]
    if saved ~= nil then return saved end
    return KEY_DEFAULTS[i] or ("F" .. i)
end

function Keys.SetKeybind(i, key)
    if not NS.db or not NS.db.profile then return end
    local qb = NS.db.profile.quickBar
    if not qb then return end
    qb.keybinds = qb.keybinds or {}
    if key == nil then
        qb.keybinds[i] = KEY_DEFAULTS[i] or ("F" .. i)
    else
        qb.keybinds[i] = key
    end
    Keys.Apply()
    if QB.UI and QB.UI.RefreshKeyLabels then QB.UI.RefreshKeyLabels() end
end

local function EnsureOwner()
    if owner then return end
    owner = CreateFrame("Frame", "HD_QB_KeyOwner", UIParent)

    for i = 1, QB.NUM_SLOTS do
        local btn = CreateFrame("Button", "HD_QB_Slot" .. i, owner, "SecureActionButtonTemplate")
        local idx = i  
        btn:SetScript("OnClick", function()
            QB:OnKeyPressed(idx)
        end)
        btnSlots[i] = btn
    end
end

function Keys.Apply()
    EnsureOwner()
    ClearOverrideBindings(owner)

    local EM = NS.Systems.EditMode
    if not (EM and EM.API and EM.API.EditorOpen and EM.API.EditorOpen()) then return end

    for i = 1, QB.NUM_SLOTS do
        local key = Keys.GetKeybind(i)
        if key and key ~= "" then
            SetOverrideBindingClick(owner, false, key, btnSlots[i]:GetName())
        end
    end
end

function Keys.Clear()
    if owner then ClearOverrideBindings(owner) end
end

function Keys.Label(i)
    return Keys.GetKeybind(i)
end
