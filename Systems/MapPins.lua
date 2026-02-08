local ADDON, NS = ...

NS.Systems = NS.Systems or {}
local MapPins = {}
NS.Systems.MapPins = MapPins

local LibStub = _G.LibStub
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local UIParent = _G.UIParent
local tonumber = _G.tonumber
local type = _G.type
local pairs = _G.pairs
local wipe = _G.wipe or function(t) for k in pairs(t) do t[k] = nil end end

local HBD = LibStub and LibStub("HereBeDragons-2.0", true)
local HBDPins = LibStub and LibStub("HereBeDragons-Pins-2.0", true)

local NPCNames = NS.Systems and NS.Systems.NPCNames
local TooltipSys = NS.UI and NS.UI.Tooltips

local ICON_TEX = "Interface\\AddOns\\HomeDecor\\Media\\Icon"
local PIN_SIZE_WORLD = 18
local PIN_SIZE_MINI = 14


local C_Map = _G.C_Map
local C_SuperTrack = _G.C_SuperTrack
local UiMapPoint = _G.UiMapPoint
local IsShiftKeyDown = _G.IsShiftKeyDown

local WAYPOINT_CLEAR_YARDS = 25

local activeWaypoint = nil 

local function clearUserWaypoint()
  if C_Map and C_Map.ClearUserWaypoint then
    pcall(C_Map.ClearUserWaypoint)
  end
  if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, false)
  end
  activeWaypoint = nil
end

local function setUserWaypoint(mapID, x, y, npcID)
  if not (C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates) then return end
  local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
  if not point then return end
  pcall(C_Map.SetUserWaypoint, point)
  if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
    pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
  end
  activeWaypoint = { mapID = mapID, x = x, y = y, npcID = npcID }
end

local function isActiveWaypoint(mapID, x, y, npcID)
  local w = activeWaypoint
  if not w then return false end
  if npcID and w.npcID and npcID == w.npcID then return true end
  if mapID and w.mapID == mapID and x and y then
    local dx = (w.x or 0) - x
    local dy = (w.y or 0) - y
    return (dx*dx + dy*dy) < 0.0000005
  end
  return false
end
local mapIndex = {}
local pooled = {}
local usedWorld = {}
local usedMini = {}

local function parseWorldmap(worldmap)
  if type(worldmap) ~= "string" then return end
  local a,b,c = worldmap:match("^(%d+):(%d+):(%d+)$")
  if not a then return end
  local mapID = tonumber(a)
  local x = tonumber(b)
  local y = tonumber(c)
  if not mapID or not x or not y then return end
  x = x / 10000
  y = y / 10000
  if x <= 0 or y <= 0 or x >= 1 or y >= 1 then return end
  return mapID, x, y
end

local function ensurePool()
  if #pooled > 0 then
    local f = pooled[#pooled]
    pooled[#pooled] = nil
    return f
  end

  local b = CreateFrame("Button", nil, UIParent)
  b.__hdMapPin = true
  b:SetSize(PIN_SIZE_WORLD, PIN_SIZE_WORLD)
  b.tex = b:CreateTexture(nil, "ARTWORK")
  b.tex:SetAllPoints()
  b.tex:SetTexture(ICON_TEX)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

  b:SetScript("OnEnter", function(self)
    if not self.vendor then return end
    local v = self.vendor
    local id = v.id
    local zone = v.zone
    local name = v.name
    local shift = _G.IsShiftKeyDown and _G.IsShiftKeyDown()

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(name or "Vendor", 1, 1, 1)
    if zone then GameTooltip:AddLine(zone, 0.8, 0.8, 0.8) end

    GameTooltip:AddLine(" ", 0, 0, 0)
    local wp = (v.mapID and isActiveWaypoint(v.mapID, v.x, v.y, id)) and true or false
    GameTooltip:AddLine(wp and "Left-click: Clear waypoint" or "Left-click: Set waypoint", 1, 0.82, 0)
    GameTooltip:AddLine("Right-click: Open Tracker", 1, 0.82, 0)

    if shift and id then GameTooltip:AddLine("NPC ID: "..id, 0.8, 0.8, 0.8) end

    if id and TooltipSys and type(TooltipSys.AppendNpcMouseover) == "function" then
      pcall(TooltipSys.AppendNpcMouseover, GameTooltip, id)
    end

    GameTooltip:Show()
  end)

  b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)

  b:SetScript("OnClick", function(self, button)
    local v = self.vendor
    if not v then return end

    if button == "LeftButton" then
      local mapID, x, y = v.mapID, v.x, v.y
      if mapID and x and y then
        if isActiveWaypoint(mapID, x, y, v.id) then
          clearUserWaypoint()
        else
          setUserWaypoint(mapID, x, y, v.id)
        end
        MapPins.RefreshTooltip()
      end
      return
    end

    if button == "RightButton" then
      local Tracker = NS.UI and NS.UI.Tracker
      if Tracker and Tracker.Create then
        pcall(function()
          Tracker:Create()
          if Tracker.frame and Tracker.frame.Show then
            Tracker.frame:Show()
            if Tracker.frame.Raise then Tracker.frame:Raise() end
          end
        end)
      end
    end
  end)
  return b
end

function MapPins.RefreshTooltip()
  if not GameTooltip or not GameTooltip.IsShown or not GameTooltip:IsShown() then return end
  local owner = GameTooltip.GetOwner and GameTooltip:GetOwner()
  if not owner or not owner.__hdMapPin then return end
  if owner.IsMouseOver and not owner:IsMouseOver() then return end
  local onEnter = owner.GetScript and owner:GetScript("OnEnter")
  if type(onEnter) ~= "function" then return end
  pcall(onEnter, owner)
end

local mod = CreateFrame("Frame")
mod:RegisterEvent("MODIFIER_STATE_CHANGED")
mod:SetScript("OnEvent", function()
  MapPins.RefreshTooltip()
end)

local function recycleFrame(f)
  if not f then return end
  f.vendor = nil
  f:Hide()
  f:SetParent(UIParent)
  pooled[#pooled + 1] = f
end

local function buildIndex()
  wipe(mapIndex)

  local Vendors = NS.Data and NS.Data.Vendors
  if type(Vendors) ~= "table" then return end

  for _, regions in pairs(Vendors) do
    if type(regions) == "table" then
      for _, vendorList in pairs(regions) do
        if type(vendorList) == "table" then
          for i = 1, #vendorList do
            local v = vendorList[i]
            local src = v and v.source
            local id = src and src.id
            local zone = src and src.zone
            local faction = src and src.faction
            local mapID, x, y = parseWorldmap(src and src.worldmap)
            if mapID and id then
              local t = mapIndex[mapID]
              if not t then t = {}; mapIndex[mapID] = t end
              t[#t + 1] = { id = tonumber(id), mapID = mapID, x = x, y = y, zone = zone, faction = faction }
            end
          end
        end
      end
    end
  end
end

local function resolveNamesFor(list)
  if not NPCNames or type(NPCNames.Get) ~= "function" then return end
  for i = 1, #list do
    local v = list[i]
    if v and v.id and not v.name then
      local got = NPCNames.Get(v.id, function(_, name)
        if name then v.name = name end
      end)
      if got then v.name = got end
    end
  end
end

local function clearWorldPins()
  if not HBDPins then return end
  for icon in pairs(usedWorld) do
    HBDPins:RemoveWorldMapIcon(ADDON, icon)
    recycleFrame(icon)
  end
  wipe(usedWorld)
end

local function clearMiniPins()
  if not HBDPins then return end
  for icon in pairs(usedMini) do
    HBDPins:RemoveMinimapIcon(ADDON, icon)
    recycleFrame(icon)
  end
  wipe(usedMini)
end

local function addWorldPinsForMap(mapID)
  if not HBDPins then return end
  clearWorldPins()
  local list = mapIndex[mapID]
  if type(list) ~= "table" or #list == 0 then return end

  resolveNamesFor(list)

  for i = 1, #list do
    local v = list[i]
    local icon = ensurePool()
    icon.vendor = v
    icon:SetSize(PIN_SIZE_WORLD, PIN_SIZE_WORLD)
    icon.tex:SetTexture(ICON_TEX)
    icon:Show()
    usedWorld[icon] = true
    pcall(function()
      HBDPins:AddWorldMapIconMap(ADDON, icon, mapID, v.x, v.y)
    end)
  end
end

local function addMiniPinsForMap(mapID)
  if not HBDPins then return end
  clearMiniPins()
  local list = mapIndex[mapID]
  if type(list) ~= "table" or #list == 0 then return end

  resolveNamesFor(list)

  for i = 1, #list do
    local v = list[i]
    local icon = ensurePool()
    icon.vendor = v
    icon:SetSize(PIN_SIZE_MINI, PIN_SIZE_MINI)
    icon.tex:SetTexture(ICON_TEX)
    icon:Show()
    usedMini[icon] = true
    pcall(function()
      HBDPins:AddMinimapIconMap(ADDON, icon, mapID, v.x, v.y, true)
    end)
  end
end

local function isEnabled(profile, key, default)
  local mp = profile and profile.mapPins
  if type(mp) ~= "table" then return default end
  local v = mp[key]
  if v == nil then return default end
  return v and true or false
end

function MapPins:RefreshCurrentZone()
  if not self._enabled then return end
  local prof = NS.db and NS.db.profile
  if not prof then return end

  local mapID
  local MT = NS.Systems and NS.Systems.MapTracker
  if MT and type(MT.GetCurrentZone) == "function" then
    local _, mid = MT:GetCurrentZone()
    mapID = mid
  end
  mapID = tonumber(mapID)
  if not mapID then return end

  if isEnabled(prof, "minimap", true) then
    addMiniPinsForMap(mapID)
  else
    clearMiniPins()
  end
end

function MapPins:RefreshWorldMap()
  if not self._enabled then return end
  local prof = NS.db and NS.db.profile
  if not prof then return end

  if not isEnabled(prof, "worldmap", true) then
    clearWorldPins()
    return
  end

  local WM = _G.WorldMapFrame
  if not WM or type(WM.GetMapID) ~= "function" then return end
  local mapID = tonumber(WM:GetMapID())
  if not mapID then return end

  addWorldPinsForMap(mapID)
end

function MapPins:Enable()
  if self._enabled then return end
  if not HBDPins or not HBD then return end

  buildIndex()

  self._enabled = true

  local WM = _G.WorldMapFrame
  if WM and not self._hookedWorldMap then
    self._hookedWorldMap = true
    WM:HookScript("OnShow", function() MapPins:RefreshWorldMap() end)
    if type(WM.GetMapID) == "function" then
      pcall(function()
        hooksecurefunc(WM, "SetMapID", function() MapPins:RefreshWorldMap() end)
      end)
    end
  end

  local MT = NS.Systems and NS.Systems.MapTracker
  if MT and type(MT.RegisterCallback) == "function" then
    pcall(function()
      MT:RegisterCallback("MapPins", function() MapPins:RefreshCurrentZone() end)
    end)
  else
    local f = CreateFrame("Frame")
    f.t = 0
    f:SetScript("OnUpdate", function(self, e)
      self.t = self.t + e
      if self.t < 2 then return end
      self.t = 0
      MapPins:RefreshCurrentZone()
    end)
    self._fallbackTicker = f
  end


  if not self._waypointTicker then
    local wf = CreateFrame("Frame")
    wf.t = 0
    wf:SetScript("OnUpdate", function(self, e)
      self.t = self.t + e
      if self.t < 0.35 then return end
      self.t = 0

      local w = activeWaypoint
      if not w or not w.mapID then return end

      if HBD and type(HBD.GetPlayerZonePosition) == "function" then
        local px, py, pMap = HBD:GetPlayerZonePosition(true)
        if pMap == w.mapID and px and py then
          local dist
          if type(HBD.GetZoneDistance) == "function" then
            dist = select(1, HBD:GetZoneDistance(w.mapID, px, py, w.mapID, w.x, w.y))
          end
          if not dist then
            local dx, dy = (w.x - px), (w.y - py)
            dist = ((dx*dx + dy*dy)^0.5) * 10000
          end
          if dist and dist <= WAYPOINT_CLEAR_YARDS then
            clearUserWaypoint()
            MapPins.RefreshTooltip()
          end
        end
      end
    end)
    self._waypointTicker = wf
  end

  if not self._merchantHook then
    local mf = CreateFrame("Frame")
    mf:RegisterEvent("MERCHANT_SHOW")
    mf:SetScript("OnEvent", function()
      if activeWaypoint then
        clearUserWaypoint()
        MapPins.RefreshTooltip()
      end
    end)
    self._merchantHook = mf
  end

  self:RefreshCurrentZone()
end

function MapPins:Disable()
  if not self._enabled then return end
  self._enabled = false
  clearWorldPins()
  clearMiniPins()
  clearUserWaypoint()
  if self._waypointTicker then
    self._waypointTicker:SetScript("OnUpdate", nil)
    self._waypointTicker = nil
  end
  if self._merchantHook then
    self._merchantHook:SetScript("OnEvent", nil)
    self._merchantHook:UnregisterAllEvents()
    self._merchantHook = nil
  end

  if self._fallbackTicker then
    self._fallbackTicker:SetScript("OnUpdate", nil)
    self._fallbackTicker = nil
  end
end

return MapPins
