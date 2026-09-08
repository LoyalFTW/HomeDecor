local _, NS = ...

NS.UI = NS.UI or {}
NS.UI.GatherTracker = NS.UI.GatherTracker or {}

local Shared = {}
NS.UI.GatherTrackerShared = Shared

Shared.kindOrder = { "lumber", "ore", "herb" }
Shared.kindInfo = {
  lumber = { label = "Lumber", short = "L", color = { 0.85, 0.63, 0.28 } },
  ore = { label = "Ore", short = "O", color = { 0.58, 0.72, 0.86 } },
  herb = { label = "Herbs", short = "H", color = { 0.36, 0.82, 0.48 } },
}

function Shared.Controls()
  return NS.UI.Controls
end

function Shared.Label(parent, font, color)
  local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormalSmall")
  Shared.Controls():TextColor(label, color or "text")
  return label
end

function Shared.Compact(value)
  value = tonumber(value) or 0
  if math.abs(value) >= 1000 then return string.format("%.1fk", value / 1000) end
  return tostring(math.floor(value))
end

function Shared.TimeText(seconds)
  seconds = math.max(0, math.floor(tonumber(seconds) or 0))
  return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function Shared.KindLabel(kind)
  local info = Shared.kindInfo[kind]
  return info and info.label or "Material"
end

return Shared
