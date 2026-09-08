local _, NS = ...

local Diagnostics = {}
NS.Systems.Diagnostics = Diagnostics

local previous
local trace = {
  armed = false,
  running = false,
  events = {},
  marks = {},
  checkpoints = {},
}

local function Memory()
  local lua = collectgarbage and collectgarbage("count") or 0
  local addon = _G.GetAddOnMemoryUsage and _G.GetAddOnMemoryUsage(NS.Name) or 0
  return lua, addon
end

local function TrackedCount()
  local count = 0
  NS.Systems.Pipeline:ForEach({ trackedOnly = true }, function()
    count = count + 1
  end)
  return count
end

function Diagnostics:Snapshot()
  local lua, addon = Memory()
  local pins = NS.Systems.MapPins
  local map = _G.WorldMapFrame
  return {
    lua = lua,
    addon = addon,
    catalog = NS.Systems.Catalog:Count(),
    tracked = TrackedCount(),
    cache = NS.Systems.Housing:GetCacheSize(),
    active = #pins.active,
    free = #pins.free,
    created = pins.stats.created,
    refreshes = pins.stats.refreshes,
    clears = pins.stats.clears,
    bound = pins.stats.bound,
    candidates = pins.stats.candidates,
    mapShown = map and map:IsShown() or false,
    mapID = map and map:GetMapID() or nil,
  }
end

function Diagnostics:Print()
  local current = self:Snapshot()
  local luaDelta = previous and current.lua - previous.lua or 0
  local addonDelta = previous and current.addon - previous.addon or 0
  local chat = _G.DEFAULT_CHAT_FRAME
  if chat then
    chat:AddMessage(string.format("|cffed9f2fHomeDecor|r Total Lua %.2f KB (%+.2f) Addon last-report %.2f KB (%+.2f)", current.lua, luaDelta, current.addon, addonDelta))
    chat:AddMessage(string.format("Catalog %d | Tracked %d | Housing cache %d | Pins active %d free %d created %d", current.catalog, current.tracked, current.cache, current.active, current.free, current.created))
    chat:AddMessage(string.format("Map shown %s id %s | refreshes %d | clears %d | locations %d | marker binds %d", tostring(current.mapShown), tostring(current.mapID), current.refreshes, current.clears, current.candidates, current.bound))
  end
  previous = current
end

function Diagnostics:Reset()
  previous = nil
end

function Diagnostics:Mark(name)
  if not trace.armed then return end
  trace.marks[name] = (trace.marks[name] or 0) + 1
end

function Diagnostics:ClearTrace()
  wipe(trace.events)
  wipe(trace.marks)
  wipe(trace.checkpoints)
  if _G.UpdateAddOnMemoryUsage then _G.UpdateAddOnMemoryUsage() end
  trace.startLua, trace.startAddon = Memory()
end

function Diagnostics:Checkpoint(name)
  if not trace.armed then return end
  if _G.UpdateAddOnMemoryUsage then _G.UpdateAddOnMemoryUsage() end
  local lua, addon = Memory()
  local pins = NS.Systems.MapPins
  if #trace.checkpoints >= 200 then table.remove(trace.checkpoints, 1) end
  trace.checkpoints[#trace.checkpoints + 1] = {
    name = name,
    lua = lua,
    addon = addon,
    active = #pins.active,
    free = #pins.free,
    created = pins.stats.created,
  }
end

function Diagnostics:StartTrace()
  trace.armed = true
  self:ClearTrace()
  local map = _G.WorldMapFrame
  if map and map:IsShown() then self:StartMapTrace() end
  local chat = _G.DEFAULT_CHAT_FRAME
  if chat then chat:AddMessage("|cffed9f2fHomeDecor|r map trace armed") end
end

function Diagnostics:StopTrace()
  trace.armed = false
  if trace.running then
    trace.frame:UnregisterAllEvents()
    trace.running = false
  end
  local chat = _G.DEFAULT_CHAT_FRAME
  if chat then chat:AddMessage("|cffed9f2fHomeDecor|r map trace stopped") end
end

function Diagnostics:StartMapTrace()
  if not trace.armed or trace.running then return end
  if not trace.frame then
    trace.frame = CreateFrame("Frame")
    trace.frame:SetScript("OnEvent", function(_, event)
      trace.events[event] = (trace.events[event] or 0) + 1
    end)
  end
  trace.frame:RegisterAllEvents()
  trace.running = true
  self:Mark("Map:OnShow")
  self:Checkpoint("Map:OnShow")
end

function Diagnostics:StopMapTrace()
  if not trace.running then return end
  self:Mark("Map:OnHide")
  self:Checkpoint("Map:OnHide")
  trace.frame:UnregisterAllEvents()
  trace.running = false
end

function Diagnostics:PrintTrace()
  local chat = _G.DEFAULT_CHAT_FRAME
  if not chat then return end
  local lua, addon = Memory()
  chat:AddMessage(string.format("|cffed9f2fHomeDecor|r trace %s | Total Lua %+.2f KB | Addon last-report %+.2f KB", trace.running and "running" or "paused", lua - (trace.startLua or lua), addon - (trace.startAddon or addon)))
  local marks = {}
  for name, count in pairs(trace.marks) do marks[#marks + 1] = { name = name, count = count } end
  table.sort(marks, function(a, b) return a.name < b.name end)
  for index = 1, #marks do
    chat:AddMessage(string.format("Trace %s: %d", marks[index].name, marks[index].count))
  end
  local first = trace.checkpoints[1]
  for index = 1, #trace.checkpoints do
    local point = trace.checkpoints[index]
    chat:AddMessage(string.format("Memory %s | Lua %+.2f KB | Addon %+.2f KB | pins %d active %d free", point.name, point.lua - (first and first.lua or point.lua), point.addon - (first and first.addon or point.addon), point.created, point.active, point.free))
  end
  local events = {}
  for name, count in pairs(trace.events) do events[#events + 1] = { name = name, count = count } end
  table.sort(events, function(a, b)
    if a.count == b.count then return a.name < b.name end
    return a.count > b.count
  end)
  for index = 1, #events do
    chat:AddMessage(string.format("Event %s: %d", events[index].name, events[index].count))
  end
end
