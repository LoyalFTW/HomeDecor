local ADDON, NS = ...
NS.Systems        = NS.Systems or {}
NS.Systems.QuickBar = NS.Systems.QuickBar or {}

local ModeBarMgr = {}
NS.Systems.QuickBar.ModeBar = ModeBarMgr

local savedAnchors  = nil   
local isRelocated   = false
local layoutHooked  = false
local GAP           = 2     

local function GetModeBar()
    return HouseEditorFrame and HouseEditorFrame.ModeBar
end

local function GetBarFrame()
    local UI = NS.Systems.QuickBar.UI
    return UI and UI.barFrame
end

local function SaveAnchors(frame)
    if not frame then return nil end
    local t = {}
    for i = 1, frame:GetNumPoints() do
        local p, rel, rp, x, y = frame:GetPoint(i)
        t[i] = { p = p, rel = rel, rp = rp, x = x, y = y }
    end
    return t
end

local function RestoreAnchors(frame, saved)
    if not (frame and saved) then return end
    frame:ClearAllPoints()
    for _, a in ipairs(saved) do
        frame:SetPoint(a.p, a.rel, a.rp, a.x, a.y)
    end
end

local function ApplyRelocate(mb, barFrame)
    mb:ClearAllPoints()
    mb:SetPoint("BOTTOM", barFrame, "TOP", 0, GAP)
    isRelocated = true
end

function ModeBarMgr:Apply()
    local mb       = GetModeBar()
    local barFrame = GetBarFrame()
    if not (mb and barFrame and barFrame:IsShown()) then return end

    
    if not savedAnchors then
        savedAnchors = SaveAnchors(mb)
    end

    ApplyRelocate(mb, barFrame)

    
    if not layoutHooked and mb.Layout then
        hooksecurefunc(mb, "Layout", function()
            local bf = GetBarFrame()
            if isRelocated and bf and bf:IsShown() then
                mb:ClearAllPoints()
                mb:SetPoint("BOTTOM", bf, "TOP", 0, GAP)
            end
        end)
        layoutHooked = true
    end
end

function ModeBarMgr:Restore()
    if not isRelocated then return end
    local mb = GetModeBar()
    if mb then
        if savedAnchors then
            RestoreAnchors(mb, savedAnchors)
        else
            
            mb:ClearAllPoints()
            mb:SetPoint("BOTTOM", HouseEditorFrame or UIParent, "BOTTOM", 0, 0)
        end
        if mb.Layout then mb:Layout() end
    end
    isRelocated = false
end
