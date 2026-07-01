local MAJOR = "LibMapSuite-1.0"
local Lib = LibStub(MAJOR)
if not Lib then return end
local private, Compat = Lib.private, Lib.private.Compat
if (private.modules.MapData or 0) >= 5 then return end
private.modules.MapData = 5

local MapData = private.MapData or { infoCache = {} }
private.MapData = MapData

local function InBounds(x, y)
    return x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1
end

local function Atan2(y, x)
    if math.atan2 then return math.atan2(y, x) end
    if _G.atan2 then return _G.atan2(y, x) end
    if x > 0 then return math.atan(y / x) end
    if x < 0 then return math.atan(y / x) + (y >= 0 and math.pi or -math.pi) end
    if y > 0 then return math.pi / 2 end
    if y < 0 then return -math.pi / 2 end
    return 0
end

function Lib:GetMapInfo(mapID)
    if not mapID then return nil end
    if MapData.infoCache[mapID] then return MapData.infoCache[mapID] end
    if not (C_Map and C_Map.GetMapInfo) then return nil end
    local info = C_Map.GetMapInfo(mapID)
    if info then MapData.infoCache[mapID] = info end
    return info
end

function Lib:GetLocalizedMap(mapID)
    local info = self:GetMapInfo(mapID)
    return info and info.name or nil
end

function Lib:GetZoneSize(mapID)
    if C_Map and C_Map.GetMapWorldSize then
        local ok, width, height = pcall(C_Map.GetMapWorldSize, mapID)
        if ok and width and height then return width, height end
    end
    local x1, y1, instance1 = self:MapToWorld(mapID, 0, 0)
    local x2, y2, instance2 = self:MapToWorld(mapID, 1, 1)
    if not x1 or instance1 ~= instance2 then return 0, 0 end
    return math.abs(x2 - x1), math.abs(y2 - y1)
end

function Lib:GetPlayerMapPosition(mapID, unit)
    unit = unit or "player"
    mapID = mapID or (C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit(unit))
    if not mapID then return nil end
    if C_Map and C_Map.GetPlayerMapPosition then
        local point = C_Map.GetPlayerMapPosition(mapID, unit)
        if point then
            local x, y = point:GetXY()
            if x ~= 0 or y ~= 0 then return x, y, mapID end
        end
    end
    return nil
end

function Lib:MapToWorld(mapID, x, y)
    if not mapID or not x or not y then return nil end
    if C_Map and C_Map.GetWorldPosFromMapPos and Compat.HasVector2D then
        local point = CreateVector2D(x, y)
        local ok, instanceID, world = pcall(C_Map.GetWorldPosFromMapPos, mapID, point)
        if ok and world and world.GetXY then
            local worldY, worldX = world:GetXY()
            return worldX, worldY, instanceID
        end
    end
    return nil
end

function Lib:WorldToMap(instanceID, worldX, worldY, mapID, allowOutOfBounds)
    if not instanceID or not worldX or not worldY or not mapID then return nil end
    if C_Map and C_Map.GetMapPosFromWorldPos and Compat.HasVector2D then
        local world = CreateVector2D(worldY, worldX)
        local ok, result1, result2 = pcall(C_Map.GetMapPosFromWorldPos, instanceID, world, mapID)
        local point = result2 or (type(result1) == "table" and result1 or nil)
        if ok and point and point.GetXY then
            local x, y = point:GetXY()
            if allowOutOfBounds or InBounds(x, y) then return x, y end
        end
    end
    return nil
end

function Lib:TranslateMapCoordinates(x, y, sourceMapID, targetMapID, allowOutOfBounds)
    if sourceMapID == targetMapID then
        if allowOutOfBounds or InBounds(x, y) then return x, y end
        return nil
    end
    local wx, wy, instanceID = self:MapToWorld(sourceMapID, x, y)
    if not wx then return nil end
    return self:WorldToMap(instanceID, wx, wy, targetMapID, allowOutOfBounds)
end

function Lib:GetPlayerWorldPosition(unit)
    unit = unit or "player"
    if UnitPosition then
        local y, x, _, instanceID = UnitPosition(unit)
        if x and y then return x, y, instanceID end
    end
    local x, y, mapID = self:GetPlayerMapPosition(nil, unit)
    if x then return self:MapToWorld(mapID, x, y) end
    return nil
end

Lib.GetUnitWorldPosition = Lib.GetPlayerWorldPosition

function Lib:GetPlayerZone()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local info = mapID and self:GetMapInfo(mapID)
    return mapID, info and info.mapType or nil
end

function Lib:GetPlayerZonePosition(allowOutOfBounds)
    local mapID, mapType = self:GetPlayerZone()
    if not mapID then return nil end
    local x, y = self:GetPlayerMapPosition(mapID, "player")
    if not x or (not allowOutOfBounds and not InBounds(x, y)) then return nil end
    return x, y, mapID, mapType
end

function Lib:GetWorldDistance(instanceID, x1, y1, x2, y2)
    if not (x1 and y1 and x2 and y2) then return nil end
    local dx, dy = x2 - x1, y2 - y1
    return math.sqrt(dx * dx + dy * dy), dx, dy
end

function Lib:GetMapDistance(mapID1, x1, y1, mapID2, x2, y2)
    local wx1, wy1, instance1 = self:MapToWorld(mapID1, x1, y1)
    local wx2, wy2, instance2 = self:MapToWorld(mapID2, x2, y2)
    if not wx1 or not wx2 or instance1 ~= instance2 then return nil end
    return self:GetWorldDistance(instance1, wx1, wy1, wx2, wy2)
end

function Lib:GetMapVector(mapID1, x1, y1, mapID2, x2, y2)
    local distance, dx, dy = self:GetMapDistance(mapID1, x1, y1, mapID2, x2, y2)
    if not distance then return nil end
    local angle = Atan2(-dx, dy)
    if angle > 0 then angle = math.pi * 2 - angle else angle = -angle end
    return angle, distance
end

Lib.GetWorldCoordinatesFromZone = function(self, x, y, mapID)
    return self:MapToWorld(mapID, x, y)
end
Lib.GetZoneCoordinatesFromWorldInstance = function(self, x, y, instanceID, mapID, allowOutOfBounds)
    return self:WorldToMap(instanceID, x, y, mapID, allowOutOfBounds)
end
Lib.GetZoneCoordinatesFromWorld = function(self, x, y, mapID, allowOutOfBounds)
    local _, _, instanceID = self:MapToWorld(mapID, 0.5, 0.5)
    if not instanceID then return nil end
    return self:WorldToMap(instanceID, x, y, mapID, allowOutOfBounds)
end
Lib.TranslateZoneCoordinates = Lib.TranslateMapCoordinates
Lib.GetZoneDistance = Lib.GetMapDistance
Lib.GetWorldVector = function(self, instanceID, x1, y1, x2, y2)
    local distance, dx, dy = self:GetWorldDistance(instanceID, x1, y1, x2, y2)
    if not distance then return nil end
    local angle = Atan2(-dx, dy)
    if angle > 0 then angle = math.pi * 2 - angle else angle = -angle end
    return angle, distance
end

local events = MapData.events or CreateFrame("Frame")
MapData.events = events
events:UnregisterAllEvents()
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("ZONE_CHANGED")
events:SetScript("OnEvent", function()
    MapData.infoCache = {}
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    private:Fire("OnPlayerMapChanged", mapID)
end)
