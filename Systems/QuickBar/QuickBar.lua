local ADDON, NS = ...
NS.Systems        = NS.Systems or {}
NS.Systems.QuickBar = NS.Systems.QuickBar or {}

local QB = NS.Systems.QuickBar

QB.NUM_SLOTS   = 8
QB.NUM_HOTBARS = 9   

local hotbars  = {}   
local recent   = nil  
local curPage  = 1

local lastStartedRID  = nil
local lastStartedName = nil
local lastStartedIcon = nil

local function DB()
    return NS.db and NS.db.profile and NS.db.profile.quickBar
end

local function EnsureDefaults()
    local db = DB()
    if not db then return end
    db.hotbars  = db.hotbars  or {}
    db.page     = db.page     or 1
    db.recent   = db.recent   or nil
end

local function GetCatalogInfo(recordID)
    if not recordID then return nil, nil, nil, 0 end
    if not (C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID) then
        return nil, nil, nil, 0
    end
    local t   = Enum and Enum.HousingCatalogEntryType and Enum.HousingCatalogEntryType.Decor or 1
    local ok, info = pcall(C_HousingCatalog.GetCatalogEntryInfoByRecordID, t, recordID, true)
    if not (ok and info) then return nil, nil, nil, 0 end
    local icon = info.iconTexture or info.iconAtlas or 134400
    local qty  = (info.quantity or 0) + (info.remainingRedeemable or 0)
    return info.name, icon, info.entryID, qty
end

local function IsEditorActive()
    if HouseEditorFrame and HouseEditorFrame:IsShown() then return true end
    return C_HouseEditor
        and C_HouseEditor.IsHouseEditorActive
        and C_HouseEditor.IsHouseEditorActive()
        or false
end

local function IsHoldingDecor()
    if C_HousingBasicMode then
        if C_HousingBasicMode.IsPlacingNewDecor and C_HousingBasicMode.IsPlacingNewDecor() then return true end
        if C_HousingBasicMode.IsDecorSelected   and C_HousingBasicMode.IsDecorSelected()   then return true end
    end
    if C_HousingExpertMode
       and C_HousingExpertMode.IsDecorSelected
       and C_HousingExpertMode.IsDecorSelected() then return true end
    return false
end

local function GetHeldDecor()
    local info
    
    if C_HousingDecor and C_HousingDecor.GetSelectedDecorInfo then
        info = C_HousingDecor.GetSelectedDecorInfo()
    end
    if not (info and info.decorID) and C_HousingBasicMode and C_HousingBasicMode.GetSelectedDecorInfo then
        info = C_HousingBasicMode.GetSelectedDecorInfo()
    end
    if not (info and info.decorID) and C_HousingExpertMode and C_HousingExpertMode.GetSelectedDecorInfo then
        info = C_HousingExpertMode.GetSelectedDecorInfo()
    end
    if info and info.decorID then
        return info.decorID, info.name, info.iconTexture or info.iconAtlas
    end
    
    if lastStartedRID then
        return lastStartedRID, lastStartedName, lastStartedIcon
    end
    return nil, nil, nil
end

local function CancelHeld()
    if C_HousingBasicMode and C_HousingBasicMode.CancelActiveEditing then
        pcall(C_HousingBasicMode.CancelActiveEditing)
    end
    if C_HousingExpertMode and C_HousingExpertMode.CancelActiveEditing then
        pcall(C_HousingExpertMode.CancelActiveEditing)
    end
end

local function DoPlace(recordID)
    if not IsEditorActive() then return end
    local EM = NS.Systems.EditMode
    if EM and EM.API and EM.API.BeginPlacement then
        EM.API.BeginPlacement(recordID, nil, true)
    else
        
        local _, _, entryID, qty = GetCatalogInfo(recordID)
        if not entryID or qty <= 0 then return end
        if C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor then
            C_HousingBasicMode.StartPlacingNewDecor(entryID)
        end
    end
end

function QB:GetPage()           return curPage end
function QB:NumSlots()          return self.NUM_SLOTS end
function QB:NumPages()          return self.NUM_HOTBARS end

function QB:GetSlot(page, i)
    return hotbars[page] and hotbars[page][i]
end

function QB:GetCurrentSlot(i)
    return self:GetSlot(curPage, i)
end

function QB:GetRecent()         return recent end

function QB:SetSlot(page, i, recordID, name, icon)
    hotbars[page] = hotbars[page] or {}
    if not recordID then
        hotbars[page][i] = nil
    else
        local n, ic = GetCatalogInfo(recordID)
        hotbars[page][i] = {
            recordID = recordID,
            name     = name or n or "Unknown",
            icon     = icon or ic or 134400,
        }
    end
    self:_Save()
    self:_RefreshUI()
end

function QB:ClearSlot(page, i)
    self:SetSlot(page, i, nil)
end

function QB:SetRecent(recordID, name, icon)
    if not recordID then recent = nil; return end
    local n, ic = GetCatalogInfo(recordID)
    recent = { recordID = recordID, name = name or n or "Unknown", icon = icon or ic or 134400 }
    self:_Save()
    self:_RefreshUI()
end

function QB:SetPage(p)
    curPage = math.max(1, math.min(p, self.NUM_HOTBARS))
    local db = DB()
    if db then db.page = curPage end
    self:_RefreshUI()
end

function QB:NextPage()
    self:SetPage(curPage < self.NUM_HOTBARS and curPage + 1 or 1)
end

function QB:PrevPage()
    self:SetPage(curPage > 1 and curPage - 1 or self.NUM_HOTBARS)
end

function QB:OnKeyPressed(slotIndex)
    if not IsEditorActive() then return end

    local holding  = IsHoldingDecor()
    local slotData = self:GetCurrentSlot(slotIndex)

    if holding then
        local rid, name, icon = GetHeldDecor()
        if rid then
            if slotData then
                
                CancelHeld()
                C_Timer.After(0.1, function() DoPlace(slotData.recordID) end)
            else
                
                self:SetSlot(curPage, slotIndex, rid, name, icon)
                CancelHeld()
                PlaySound(SOUNDKIT.UI_70_ARTIFACT_FORGE_APPEARANCE_LOCKED)
            end
        end
    else
        
        if slotData then
            DoPlace(slotData.recordID)
        end
    end
end

function QB:OnRecentClicked()
    if not (IsEditorActive() and recent and recent.recordID) then return end
    DoPlace(recent.recordID)
end

if C_HousingBasicMode and C_HousingBasicMode.StartPlacingNewDecor then
    hooksecurefunc(C_HousingBasicMode, "StartPlacingNewDecor", function(entryID)
        if type(entryID) == "table" and entryID.recordID then
            lastStartedRID = entryID.recordID
            lastStartedName, lastStartedIcon = GetCatalogInfo(entryID.recordID)
        end
    end)
end

local recentEv = CreateFrame("Frame")
recentEv:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")
recentEv:SetScript("OnEvent", function(_, _, decorGUID)
    local rid = lastStartedRID
    
    if decorGUID and C_HousingDecor and C_HousingDecor.GetDecorInstanceInfoForGUID then
        local ok, info = pcall(C_HousingDecor.GetDecorInstanceInfoForGUID, decorGUID)
        if ok and info and info.decorID then rid = info.decorID end
    end
    if rid then
        local name, icon = GetCatalogInfo(rid)
        QB:SetRecent(rid, name, icon)
    end
    lastStartedRID = nil
end)

function QB:_Save()
    local db = DB()
    if not db then return end
    db.hotbars = {}
    db.page    = curPage
    for pg = 1, self.NUM_HOTBARS do
        db.hotbars[pg] = {}
        local h = hotbars[pg]
        if h then
            for i = 1, self.NUM_SLOTS do
                if h[i] then
                    db.hotbars[pg][i] = { recordID = h[i].recordID, name = h[i].name, icon = h[i].icon }
                end
            end
        end
    end
    db.recent = recent and { recordID = recent.recordID, name = recent.name, icon = recent.icon } or nil
end

function QB:_Load()
    EnsureDefaults()
    local db = DB()
    if not db then return end

    
    for pg = 1, self.NUM_HOTBARS do
        hotbars[pg] = {}
    end
    curPage = math.max(1, math.min(db.page or 1, self.NUM_HOTBARS))

    
    if db.hotbars then
        for pg = 1, self.NUM_HOTBARS do
            local saved = db.hotbars[pg]
            if saved then
                for i = 1, self.NUM_SLOTS do
                    local s = saved[i]
                    if s and s.recordID then
                        local name, icon = GetCatalogInfo(s.recordID)
                        hotbars[pg][i] = {
                            recordID = s.recordID,
                            name     = name or s.name or "Unknown",
                            icon     = icon or s.icon or 134400,
                        }
                    end
                end
            end
        end
    end

    
    if db.recent and db.recent.recordID then
        local name, icon = GetCatalogInfo(db.recent.recordID)
        recent = {
            recordID = db.recent.recordID,
            name     = name or db.recent.name or "Unknown",
            icon     = icon or db.recent.icon or 134400,
        }
    else
        recent = nil
    end
end

function QB:_RefreshUI()
    if self.UI and self.UI.Refresh then
        self.UI:Refresh()
    end
end

function QB.Init()
    QB:_Load()
end
