local _, NS = ...

local Tracker = { revision = 0 }
NS.Systems.Tracker = Tracker

function Tracker:Key(record)
  return NS.Systems.Favorites:Key(record)
end

function Tracker:IsTracked(record)
  local profile = NS.Systems.Database:GetProfile()
  local key = self:Key(record)
  return profile and key and profile.tracked[key] == true or false
end

function Tracker:Toggle(record)
  local profile = NS.Systems.Database:GetProfile()
  local key = self:Key(record)
  if not profile or not key then return false end
  local active = profile.tracked[key] == true
  profile.tracked[key] = active and nil or true
  self.revision = self.revision + 1
  if NS.Systems.MapPins then NS.Systems.MapPins:RebuildTrackedIndex() end
  if NS.UI and NS.UI.TrackerPanel then NS.UI.TrackerPanel:Refresh(false) end
  if NS.UI and NS.UI.Overview then NS.UI.Overview:Refresh() end
  if NS.UI and NS.UI.VendorMarkers then NS.UI.VendorMarkers:Refresh() end
  return not active
end
