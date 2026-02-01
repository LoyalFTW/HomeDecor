local _, NS = ...
NS.UI = NS.UI or {}

local Tracker = NS.UI.Tracker or {}
NS.UI.Tracker = Tracker

local Events = NS.UI.TrackerEvents or {}
NS.UI.TrackerEvents = Events
Tracker.Events = Events

local MT = NS.Systems and NS.Systems.MapTracker
local U = NS.UI.TrackerUtil

local clamp = (U and U.Clamp) or function(v, a, b)
  v = tonumber(v) or 0
  if v < a then return a end
  if v > b then return b end
  return v
end

function Events:Attach(_, ctx)
  local frame = ctx.frame
  local trackCB = ctx.trackCB
  local settings = ctx.settings
  local GetDB = ctx.GetDB

  if MT and MT.RegisterCallback then
    frame._mtKey = frame._mtKey or "HomeDecorTrackerUI"
    MT:RegisterCallback(frame._mtKey, function(_, name, mapID)
      if not (frame and frame.IsShown and frame:IsShown() and trackCB and trackCB:GetChecked()) then return end
      if (mapID and mapID == frame._lastZoneMapID) or ((not mapID) and name and name ~= "" and name == frame._lastZoneName) then
        return
      end
      frame._lastZoneName, frame._lastZoneMapID = name, mapID
      if not frame._collapsed then
        frame:RequestRefresh("zone")
      end
    end)
  end

  frame:SetScript("OnShow", function()
    local db = GetDB and GetDB() or nil

    if trackCB and db then
      trackCB:SetChecked(db.trackZone ~= false)
    end

    local a = clamp(db and db.alpha or 1, 0, 1)
    local hc = (db and db.hideCompleted) and true or false
    frame._hideCompleted = hc

    if settings and settings.hideCB then
      settings.hideCB:SetChecked(hc)
    end

    if frame._ApplyPanelsAlpha then
      frame:_ApplyPanelsAlpha(a, false)
    end

    if settings and settings.slider then
      settings.slider:SetValue(a)
    end

    if trackCB and trackCB:GetChecked() and MT and MT.Enable then
      MT:Enable(true)
      if MT.GetCurrentZone then
        local name, mapID = MT:GetCurrentZone()
        if (not name or name == "") and GetRealZoneText then
          name = GetRealZoneText() or ""
        end
        frame._lastZoneName, frame._lastZoneMapID = name, mapID
      end
    end

    if not frame._collapsed and frame.RequestRefresh then
      frame:RequestRefresh("show")
    end
  end)
end

return Events
