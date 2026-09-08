local _, NS = ...

local Navigation = {}
NS.Systems.Navigation = Navigation

function Navigation:IsActive(record)
  local active = self.active
  return active and record and active.mapID == record.mapID and active.x == record.mapX and active.y == record.mapY
end

function Navigation:Clear()
  if _G.C_Map and _G.C_Map.ClearUserWaypoint then pcall(_G.C_Map.ClearUserWaypoint) end
  if _G.C_SuperTrack and _G.C_SuperTrack.SetSuperTrackedUserWaypoint then pcall(_G.C_SuperTrack.SetSuperTrackedUserWaypoint, false) end
  self.active = nil
end

function Navigation:Set(record)
  if not record or not record.mapID or not record.mapX or not record.mapY then return false end
  if not (_G.C_Map and _G.C_Map.SetUserWaypoint and _G.UiMapPoint and _G.UiMapPoint.CreateFromCoordinates) then return false end
  local point = _G.UiMapPoint.CreateFromCoordinates(record.mapID, record.mapX, record.mapY)
  if not point then return false end
  local ok = pcall(_G.C_Map.SetUserWaypoint, point)
  if not ok then return false end
  if _G.C_SuperTrack and _G.C_SuperTrack.SetSuperTrackedUserWaypoint then pcall(_G.C_SuperTrack.SetSuperTrackedUserWaypoint, true) end
  self.active = { mapID = record.mapID, x = record.mapX, y = record.mapY }
  return true
end

function Navigation:Open(record)
  if not record or not record.mapID or not record.mapX or not record.mapY then return false end
  if _G.C_Map and _G.C_Map.OpenWorldMap then pcall(_G.C_Map.OpenWorldMap, record.mapID) end
  if _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0, function() Navigation:Set(record) end)
    return true
  end
  return self:Set(record)
end

function Navigation:Toggle(record)
  if self:IsActive(record) then
    self:Clear()
    return false
  end
  return self:Set(record)
end
