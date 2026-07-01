local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local MapPins = NS.Systems.MapPins or {}
NS.Systems.MapPins = MapPins

local CreateFrame = CreateFrame
local MapPinsUtil = NS.Systems.MapPinsUtil
local MapPinsData = NS.Systems.MapPinsData
local MapPinsPools = NS.Systems.MapPinsPools
local MapPinsRefresh = NS.Systems.MapPinsRefresh
local LibStub = LibStub
local HBD = LibStub and LibStub("HereBeDragons-2.0", true)
local HBDPins = LibStub and LibStub("HereBeDragons-Pins-2.0", true)
local C_Map = C_Map

local activeWaypointRef = {}

local function PinsEnabledFor(profile, which)
  local mapPins = profile and profile.mapPins
  if not mapPins then return false end
  if which == "worldmap" then
    return MapPinsUtil and MapPinsUtil.IsEnabled and MapPinsUtil.IsEnabled(profile, "worldmap", true) or (mapPins.worldmap ~= false)
  end
  if which == "minimap" then
    return MapPinsUtil and MapPinsUtil.IsEnabled and MapPinsUtil.IsEnabled(profile, "minimap", true) or (mapPins.minimap ~= false)
  end
  return false
end

function MapPins:ClearUserWaypoint()
  MapPinsUtil.ClearUserWaypoint(activeWaypointRef)
  self:UpdateWaypointMonitor()
end

function MapPins:SetUserWaypoint(mapID, x, y, npcID)
  MapPinsUtil.SetUserWaypoint(mapID, x, y, npcID, activeWaypointRef)
  self:UpdateWaypointMonitor()
end

function MapPins:IsActiveWaypoint(mapID, x, y, npcID)
  return MapPinsUtil.IsActiveWaypoint(activeWaypointRef[1], mapID, x, y, npcID)
end

function MapPins.RefreshTooltip()
  local GameTooltip = GameTooltip
  if not GameTooltip or not GameTooltip.IsShown or not GameTooltip:IsShown() then return end
  local owner = GameTooltip.GetOwner and GameTooltip:GetOwner()
  if not owner or not (owner.isMapPin or owner.isMapBadge) then return end
  if owner.IsMouseOver and not owner:IsMouseOver() then return end
  local onEnter = owner.GetScript and owner:GetScript("OnEnter")
  if type(onEnter) ~= "function" then return end
  pcall(onEnter, owner)
end

function MapPins:UpdateWaypointMonitor()
  local waypointFrame = self.waypointFrame
  if not waypointFrame then return end

  local waypoint = activeWaypointRef[1]
  if not waypoint or not waypoint.mapID then
    waypointFrame:SetScript("OnUpdate", nil)
    waypointFrame.elapsed = 0
    return
  end

  if waypointFrame:GetScript("OnUpdate") then return end

  waypointFrame.elapsed = 0
  waypointFrame:SetScript("OnUpdate", function(self, delta)
    self.elapsed = self.elapsed + delta
    if self.elapsed < 0.35 then return end
    self.elapsed = 0

    local activeWaypoint = activeWaypointRef[1]
    if not activeWaypoint or not activeWaypoint.mapID then
      self:SetScript("OnUpdate", nil)
      return
    end

    if HBD and type(HBD.GetPlayerZonePosition) == "function" then
      local playerX, playerY, playerMap = HBD:GetPlayerZonePosition(true)
      if playerMap == activeWaypoint.mapID and playerX and playerY then
        local distance
        if type(HBD.GetZoneDistance) == "function" then
          distance = select(1, HBD:GetZoneDistance(activeWaypoint.mapID, playerX, playerY, activeWaypoint.mapID, activeWaypoint.x, activeWaypoint.y))
        end
        if not distance then
          local deltaX = activeWaypoint.x - playerX
          local deltaY = activeWaypoint.y - playerY
          distance = ((deltaX * deltaX + deltaY * deltaY) ^ 0.5) * 10000
        end
        local clearYards = MapPinsUtil and MapPinsUtil.WAYPOINT_CLEAR_YARDS or 25
        if distance and distance <= clearYards then
          MapPins:ClearUserWaypoint()
          MapPins.RefreshTooltip()
        end
      end
    end
  end)
end

function MapPins:ScheduleEventRefresh(delay)
  if self.eventTimer and self.eventTimer.Cancel then
    self.eventTimer:Cancel()
  end
  self.eventTimer = nil

  if not self.enabled or not C_Timer or not C_Timer.NewTimer then return end

  local timerDelay = tonumber(delay) or 60
  if timerDelay < 1 then timerDelay = 1 end

  self.eventTimer = C_Timer.NewTimer(timerDelay, function()
    if not MapPins.enabled then return end

    local Ev = NS.Systems and NS.Systems.Events
    if not Ev or not Ev.RecalcStatus then return end

    local now = time and time() or 0
    local _, newSig = Ev:RecalcStatus(now)
    if newSig ~= MapPins.lastEventSig then
      MapPins.lastEventSig = newSig
      MapPins:RefreshCurrentZone()
      MapPins:RefreshWorldMap()
    end

    local cache = Ev.cache and Ev.cache.status
    local nextCheck = cache and cache.nextCheck
    local nextDelay = (type(nextCheck) == "number" and nextCheck > now) and (nextCheck - now + 1) or 60
    MapPins:ScheduleEventRefresh(nextDelay)
  end)
end

local modifierFrame = CreateFrame("Frame")
modifierFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
modifierFrame:SetScript("OnEvent", function()
  MapPins.RefreshTooltip()
end)

function MapPins:RefreshCurrentZone()
  local profile = NS.db and NS.db.profile
  if not profile then return end
  if not self.enabled then
    if not PinsEnabledFor(profile, "minimap") then return end
    self:Enable()
    if not self.enabled then return end
  end

  local currentMapID
  local mapTracker = NS.Systems and NS.Systems.MapTracker
  if mapTracker and type(mapTracker.GetCurrentZone) == "function" then
    local zoneName, mapID = mapTracker:GetCurrentZone()
    currentMapID = mapID
  end
  currentMapID = tonumber(currentMapID)
  if not currentMapID then return end

  if MapPinsUtil.IsEnabled(profile, "minimap", true) then
    MapPinsRefresh.AddMiniPinsForMap(currentMapID)
  else
    MapPinsPools.ClearMiniPins()
  end
end

function MapPins:RefreshWorldMap()
  local profile = NS.db and NS.db.profile
  if not profile then return end
  if not self.enabled then
    if not PinsEnabledFor(profile, "worldmap") then return end
    self:Enable()
    if not self.enabled then return end
  end

  if not MapPinsUtil.IsEnabled(profile, "worldmap", true) then
    MapPinsPools.ClearWorldPins()
    MapPinsPools.ClearBadges()
    return
  end

  local WorldMapFrame = WorldMapFrame
  if not WorldMapFrame or type(WorldMapFrame.GetMapID) ~= "function" then return end
  local mapID = tonumber(WorldMapFrame:GetMapID())
  if not mapID then return end

  local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
  if not mapInfo then
    MapPinsRefresh.AddWorldPinsForMap(mapID)
    return
  end

  local worldType = Enum.UIMapType.World
  local cosmicType = Enum.UIMapType.Cosmic
  local continentType = Enum.UIMapType.Continent
  if mapInfo.mapType == worldType or mapInfo.mapType == cosmicType then
    MapPinsPools.ClearWorldPins()
    MapPinsRefresh.ShowContinentBadges()
  elseif mapInfo.mapType == continentType then
    MapPinsPools.ClearWorldPins()
    MapPinsRefresh.ShowZoneBadges(mapID)
  else
    MapPinsPools.ClearBadges()
    MapPinsRefresh.AddWorldPinsForMap(mapID)
  end
end

function MapPins:PrimeHooks()
  local worldMap = WorldMapFrame
  if worldMap and not self.hookedWorldMap then
    self.hookedWorldMap = true
    worldMap:HookScript("OnShow", function() MapPins:RefreshWorldMap() end)
    if type(worldMap.GetMapID) == "function" then
      pcall(function()
        hooksecurefunc(worldMap, "SetMapID", function() MapPins:RefreshWorldMap() end)
      end)
    end
  end
end

function MapPins:Enable()
  if self.enabled then return end
  if not HBDPins or not HBD then return end

  self:PrimeHooks()

  local mapTracker = NS.Systems and NS.Systems.MapTracker
  if mapTracker and type(mapTracker.Enable) == "function" then
    mapTracker:Enable(true)
  end

  MapPinsData.BuildIndex()
  self.enabled = true

  if mapTracker and type(mapTracker.RegisterCallback) == "function" then
    pcall(function()
      mapTracker:RegisterCallback("MapPins", function() MapPins:RefreshCurrentZone() end)
    end)
  end

  if not self.waypointFrame then
    local waypointFrame = CreateFrame("Frame")
    waypointFrame.elapsed = 0
    self.waypointFrame = waypointFrame
  end
  self:UpdateWaypointMonitor()

  if not self.merchantFrame then
    local merchantFrame = CreateFrame("Frame")
    merchantFrame:RegisterEvent("MERCHANT_SHOW")
    merchantFrame:SetScript("OnEvent", function()
      if activeWaypointRef[1] then
        MapPins:ClearUserWaypoint()
        MapPins.RefreshTooltip()
      end
    end)
    self.merchantFrame = merchantFrame
  end

  do
    local Events = NS.Systems and NS.Systems.Events
    local now = time and time() or 0
    local nextDelay = 60
    if Events and Events.RecalcStatus then
      local _, sig = Events:RecalcStatus(now)
      self.lastEventSig = sig
      local cache = Events.cache and Events.cache.status
      if cache and type(cache.nextCheck) == "number" and cache.nextCheck > now then
        nextDelay = cache.nextCheck - now + 1
      end
    end
    self:ScheduleEventRefresh(nextDelay)
  end

  self:RefreshCurrentZone()
end

function MapPins:Disable()
  if not self.enabled then return end
  self.enabled = false
  MapPinsPools.ClearWorldPins()
  MapPinsPools.ClearBadges()
  MapPinsPools.ClearMiniPins()
  self:ClearUserWaypoint()
  if self.waypointFrame then
    self.waypointFrame:SetScript("OnUpdate", nil)
    self.waypointFrame = nil
  end
  if self.merchantFrame then
    self.merchantFrame:SetScript("OnEvent", nil)
    self.merchantFrame:UnregisterAllEvents()
    self.merchantFrame = nil
  end
  if self.eventTimer then
    self.eventTimer:Cancel()
    self.eventTimer = nil
  end
  self.lastEventSig = nil
end

return MapPins
