local MAJOR = "LibMapSuite-1.0"
local LibMapSuite = LibStub(MAJOR)
if not LibMapSuite then return end
local private = LibMapSuite.private
if (private.modules.Compat or 0) >= 4 then return end
private.modules.Compat = 4

local Compat = {}
private.Compat = Compat
LibMapSuite.Compat = Compat

local projectId = WOW_PROJECT_ID

Compat.IsRetail      = projectId == WOW_PROJECT_MAINLINE
Compat.IsMoP         = WOW_PROJECT_MISTS_CLASSIC and projectId == WOW_PROJECT_MISTS_CLASSIC or false
Compat.IsCata        = WOW_PROJECT_CATACLYSM_CLASSIC and projectId == WOW_PROJECT_CATACLYSM_CLASSIC or false
Compat.IsWrath       = WOW_PROJECT_WRATH_CLASSIC and projectId == WOW_PROJECT_WRATH_CLASSIC or false
Compat.IsTBC         = WOW_PROJECT_BURNING_CRUSADE_CLASSIC and projectId == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or false
Compat.IsClassicEra  = WOW_PROJECT_CLASSIC and projectId == WOW_PROJECT_CLASSIC or false

Compat.IsAnyClassic = not Compat.IsRetail

Compat.HasCanvasContainer     = type(Minimap.GetCanvasContainerFrame) == "function"
Compat.OriginalGetMinimapShape = type(GetMinimapShape) == "function" and GetMinimapShape or nil
Compat.HasModernMinimapShape  = Compat.OriginalGetMinimapShape ~= nil
Compat.HasModernWorldMapCanvas = WorldMapFrame ~= nil and WorldMapFrame.ScrollContainer ~= nil
Compat.HasC_Map               = type(C_Map) == "table"
Compat.HasVector2D            = type(CreateVector2D) == "function"

function Compat:GetMinimapCanvas()
    if self.HasCanvasContainer then
        return Minimap:GetCanvasContainerFrame()
    end
    return Minimap
end

function Compat:GetMinimapAnchorFrame()
    return Minimap
end

function Compat:GetMinimapShape()
    if self.HasModernMinimapShape then
        local ok, shape = pcall(self.OriginalGetMinimapShape)
        if ok and shape then
            return shape
        end
    end
    return "ROUND"
end

function Compat:GetWorldMapCanvas()
    if WorldMapFrame and WorldMapFrame.GetCanvas then
        local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
        if ok and canvas then return canvas end
    end
    if self.HasModernWorldMapCanvas then
        return WorldMapFrame.ScrollContainer
    end
    return WorldMapDetailFrame or WorldMapFrame
end

function Compat:GetWorldMapButtonRailAnchor()
    if not WorldMapFrame then return nil end
    if WorldMapFrame.GetCanvasContainer then
        local ok, frame = pcall(WorldMapFrame.GetCanvasContainer, WorldMapFrame)
        if ok and frame then return frame end
    end
    return WorldMapFrame.ScrollContainer or WorldMapFrame
end

function Compat:GetPlayerMapPosition(mapID)
    if self.HasC_Map and C_Map.GetPlayerMapPosition then
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            return pos:GetXY()
        end
        return nil
    end
    if GetPlayerMapPosition then
        local x, y = GetPlayerMapPosition("player")
        if x and x > 0 or y and y > 0 then
            return x, y
        end
    end
    return nil
end

function Compat:GetCurrentMapID()
    if self.HasC_Map and WorldMapFrame and WorldMapFrame.GetMapID then
        return WorldMapFrame:GetMapID()
    end
    if self.HasC_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
    return nil
end

function Compat:GetDefaultTooltipAnchor(owner)
    return owner, "ANCHOR_LEFT"
end

function Compat:Describe()
    local flavor = "Unknown"
    if self.IsRetail then flavor = "Retail"
    elseif self.IsMoP then flavor = "MoP Classic"
    elseif self.IsCata then flavor = "Cataclysm Classic"
    elseif self.IsWrath then flavor = "Wrath Classic"
    elseif self.IsTBC then flavor = "TBC Classic"
    elseif self.IsClassicEra then flavor = "Classic Era"
    end
    return string.format(
        "%s | canvasContainer=%s shapeAPI=%s modernWorldMap=%s",
        flavor,
        tostring(self.HasCanvasContainer),
        tostring(self.HasModernMinimapShape),
        tostring(self.HasModernWorldMapCanvas)
    )
end
