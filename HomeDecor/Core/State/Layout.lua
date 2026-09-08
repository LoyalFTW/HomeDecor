local _, NS = ...

local Layout = {}
NS.Systems.Layout = Layout

function Layout:GetStore()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.ui.frames = profile.ui.frames or {}
  return profile.ui.frames
end

function Layout:Restore(frame, key)
  local store = self:GetStore()
  local point = store and store[key]
  if not point then return false end
  frame:ClearAllPoints()
  frame:SetPoint(point.point, UIParent, point.relativePoint, point.x, point.y)
  frame:SetClampedToScreen(true)
  return true
end

function Layout:Save(frame, key)
  local store = self:GetStore()
  if not store then return end
  local point, _, relativePoint, x, y = frame:GetPoint(1)
  if not point then return end
  store[key] = { point = point, relativePoint = relativePoint, x = x, y = y }
end
