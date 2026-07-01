local MAJOR = "LibMapSuite-1.0"
local LibMapSuite = LibStub(MAJOR)
if not LibMapSuite then return end
local private = LibMapSuite.private
if (private.modules.Minimap or 0) >= 5 then return end
private.modules.Minimap = 5
local Compat = private.Compat

local Minimap = private.Minimap or {}
private.Minimap = Minimap

local MASK_TEXTURES = {
    ROUND  = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
    SQUARE = "Interface\\BUTTONS\\WHITE8X8",
}

local OVERLAY_LAYERS = {
    BELOW  = { strata = "LOW",    level = 0  },
    ABOVE  = { strata = "MEDIUM", level = 5  },
    BORDER = { strata = "HIGH",   level = 10 },
}

Minimap.state = Minimap.state or {}
Minimap.state.shape = Minimap.state.shape or Compat:GetMinimapShape()
Minimap.state.width = Minimap.state.width or 140
Minimap.state.height = Minimap.state.height or 140
Minimap.state.overlays = Minimap.state.overlays or {}

local originalGetMinimapShape = Minimap.originalGetMinimapShape or Compat.OriginalGetMinimapShape
Minimap.originalGetMinimapShape = originalGetMinimapShape

local function GetEffectiveMinimapShape()
    if Minimap.state.shapeApplied and Minimap.state.shape then
        return Minimap.state.shape
    end
    if originalGetMinimapShape then
        local ok, shape = pcall(originalGetMinimapShape)
        if ok and shape then return shape end
    end
    return "ROUND"
end

_G.GetMinimapShape = GetEffectiveMinimapShape

local function ApplyHybridMinimapMask(shape)
    local hm = _G.HybridMinimap
    if not hm or not hm.MapCanvas or not hm.CircleMask then return end
    if Minimap.originalHybridMask == nil and hm.CircleMask.GetTexture then
        Minimap.originalHybridMask = hm.CircleMask:GetTexture() or false
        Minimap.originalHybridAtlas = hm.CircleMask.GetAtlas and hm.CircleMask:GetAtlas() or false
    end
    hm.MapCanvas:SetUseMaskTexture(false)
    if shape ~= "SQUARE" and Minimap.originalHybridAtlas and hm.CircleMask.SetAtlas then
        hm.CircleMask:SetAtlas(Minimap.originalHybridAtlas)
    else
        local texturePath = shape == "SQUARE" and MASK_TEXTURES.SQUARE
            or (Minimap.originalHybridMask and Minimap.originalHybridMask or MASK_TEXTURES.ROUND)
        hm.CircleMask:SetTexture(texturePath)
    end
    hm.MapCanvas:SetUseMaskTexture(true)
end

local function ApplyLegacyMask(shape)
    local minimapFrame = _G.Minimap
    if minimapFrame.SetMaskTexture then
        if Minimap.originalLegacyMask == nil and minimapFrame.GetMaskTexture then
            local ok, texture = pcall(minimapFrame.GetMaskTexture, minimapFrame)
            Minimap.originalLegacyMask = ok and texture or false
        end
        local texturePath = shape == "SQUARE" and MASK_TEXTURES.SQUARE
            or (Minimap.originalLegacyMask and Minimap.originalLegacyMask or MASK_TEXTURES.ROUND)
        minimapFrame:SetMaskTexture(texturePath)
    end
end

local function RefreshThirdPartyMinimapButtons()
    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if not LibDBIcon or not LibDBIcon.GetButtonList or not LibDBIcon.Refresh then return end
    for _, name in ipairs(LibDBIcon:GetButtonList()) do
        LibDBIcon:Refresh(name)
    end
end

local blizzBorderSink

local BLIZZ_BORDER_FRAMES = {
    "MinimapBorder",
    "MinimapBorderTop",
    "MinimapNorthTag",
}

local function SetBlizzardBorderHidden(hidden)
    if not blizzBorderSink then
        blizzBorderSink = CreateFrame("Frame", "LibMapSuite10_BorderSink", UIParent)
        blizzBorderSink:Hide()
    end

    for _, name in ipairs(BLIZZ_BORDER_FRAMES) do
        local f = _G[name]
        if f and f.SetParent then
            Minimap.originalBorderParents = Minimap.originalBorderParents or {}
            if Minimap.originalBorderParents[f] == nil then
                Minimap.originalBorderParents[f] = f:GetParent() or false
            end
            f:SetParent(hidden and blizzBorderSink or (Minimap.originalBorderParents[f] or _G.MinimapCluster or UIParent))
        end
    end

    local mc = _G.MinimapCluster
    if mc then
        if mc.BorderTop and mc.BorderTop.SetParent then
            Minimap.originalBorderParents = Minimap.originalBorderParents or {}
            if Minimap.originalBorderParents[mc.BorderTop] == nil then
                Minimap.originalBorderParents[mc.BorderTop] = mc.BorderTop:GetParent() or false
            end
            mc.BorderTop:SetParent(hidden and blizzBorderSink or (Minimap.originalBorderParents[mc.BorderTop] or mc))
        end
        if _G.MinimapBackdrop then
            local backdrop = _G.MinimapBackdrop
            Minimap.originalBorderParents = Minimap.originalBorderParents or {}
            if Minimap.originalBorderParents[backdrop] == nil then
                Minimap.originalBorderParents[backdrop] = backdrop:GetParent() or false
            end
            backdrop:SetParent(hidden and blizzBorderSink or (Minimap.originalBorderParents[backdrop] or mc))
        end
    end
end

local function ApplyShape(shape)
    ApplyHybridMinimapMask(shape)
    ApplyLegacyMask(shape)
    SetBlizzardBorderHidden(shape == "SQUARE")
end

function Minimap:RefreshAllAnchors()
    local canvas = Compat:GetMinimapCanvas()
    for frame, layerName in pairs(self.state.overlays) do
        local layer = OVERLAY_LAYERS[layerName] or OVERLAY_LAYERS.ABOVE
        frame:SetFrameStrata(layer.strata)
        frame:SetFrameLevel(canvas:GetFrameLevel() + layer.level)
        if frame.LibMapSuite_AutoSize then
            frame:SetSize(canvas:GetSize())
        end
    end
end

function LibMapSuite:SetMinimapShape(shape)
    shape = (shape == "SQUARE") and "SQUARE" or "ROUND"
    Minimap.state.shape = shape
    Minimap.state.shapeApplied = true
    ApplyShape(shape)
    private:Fire("OnShapeChanged", shape)
    RefreshThirdPartyMinimapButtons()
end

function LibMapSuite:GetMinimapShape()
    return GetEffectiveMinimapShape()
end

function LibMapSuite:SetMinimapSize(width, height)
    assert(type(width) == "number" and width > 0, "SetMinimapSize: width must be a positive number")
    height = height or width
    assert(type(height) == "number" and height > 0, "SetMinimapSize: height must be a positive number")
    local canvas = Compat:GetMinimapCanvas()
    if not Minimap.originalWidth then
        Minimap.originalWidth, Minimap.originalHeight = canvas:GetSize()
    end
    canvas:SetSize(width, height)
    Minimap.state.width, Minimap.state.height = width, height
    Minimap:RefreshAllAnchors()
    private:Fire("OnSizeChanged", width, height)
end

function LibMapSuite:RestoreMinimap()
    ApplyHybridMinimapMask("ROUND")
    ApplyLegacyMask("ROUND")
    SetBlizzardBorderHidden(false)
    Minimap.state.shapeApplied = nil
    Minimap.state.shape = Compat:GetMinimapShape()
    if Minimap.originalWidth and Minimap.originalHeight then
        local canvas = Compat:GetMinimapCanvas()
        canvas:SetSize(Minimap.originalWidth, Minimap.originalHeight)
        Minimap.state.width, Minimap.state.height = Minimap.originalWidth, Minimap.originalHeight
        Minimap:RefreshAllAnchors()
        private:Fire("OnSizeChanged", Minimap.originalWidth, Minimap.originalHeight)
    end
    private:Fire("OnShapeChanged", Minimap.state.shape)
    RefreshThirdPartyMinimapButtons()
end

function LibMapSuite:GetMinimapSize()
    local canvas = Compat:GetMinimapCanvas()
    local width, height = canvas:GetSize()
    if width and width > 0 and height and height > 0 then return width, height end
    return Minimap.state.width, Minimap.state.height
end

function LibMapSuite:AddMinimapOverlay(frame, layer, autoSize)
    layer = OVERLAY_LAYERS[layer] and layer or "ABOVE"
    Minimap.state.overlays[frame] = layer
    frame.LibMapSuite_AutoSize = autoSize and true or nil
    local canvas = Compat:GetMinimapCanvas()
    if not frame:GetPoint() then
        frame:SetPoint("CENTER", canvas, "CENTER", 0, 0)
    end
    Minimap:RefreshAllAnchors()
end

function LibMapSuite:RemoveMinimapOverlay(frame)
    Minimap.state.overlays[frame] = nil
end

local watcher = Minimap.watcher or CreateFrame("Frame")
Minimap.watcher = watcher
watcher:UnregisterAllEvents()
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function()
    if Minimap.state.shapeApplied then ApplyShape(Minimap.state.shape) end
    Minimap:RefreshAllAnchors()
end)

local hybridWatcher = Minimap.hybridWatcher or CreateFrame("Frame")
Minimap.hybridWatcher = hybridWatcher
hybridWatcher:UnregisterAllEvents()
hybridWatcher:RegisterEvent("ADDON_LOADED")
hybridWatcher:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "Blizzard_HybridMinimap" then
        self:UnregisterEvent(event)
        if Minimap.state.shapeApplied then ApplyHybridMinimapMask(Minimap.state.shape) end
    end
end)
