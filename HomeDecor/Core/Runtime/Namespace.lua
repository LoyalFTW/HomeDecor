local ADDON, NS = ...

NS.Name = ADDON
NS.Version = 1
NS.Systems = {}

local messageListeners = {}

function NS.OnMessage(message, callback)
  if type(message) ~= "string" or type(callback) ~= "function" then return end
  messageListeners[message] = messageListeners[message] or {}
  messageListeners[message][#messageListeners[message] + 1] = callback
end

function NS.SendMessage(message, ...)
  for _, callback in ipairs(messageListeners[message] or {}) do
    pcall(callback, ...)
  end
end

local eventFrame = CreateFrame("Frame")
local eventListeners = {}

eventFrame:SetScript("OnEvent", function(_, event, ...)
  for _, listener in ipairs(eventListeners[event] or {}) do
    pcall(listener.callback, ...)
  end
end)

function NS.SafeRegisterEvent(owner, event, callback)
  if type(event) ~= "string" or type(callback) ~= "function" then return false end
  if not eventListeners[event] then
    eventListeners[event] = {}
    local ok = pcall(eventFrame.RegisterEvent, eventFrame, event)
    if not ok then
      eventListeners[event] = nil
      return false
    end
  end
  eventListeners[event][#eventListeners[event] + 1] = { owner = owner, callback = callback }
  return true
end

NS.RegisterEvent = NS.SafeRegisterEvent

function NS.UnregisterEvent(owner, event)
  local listeners = eventListeners[event]
  if not listeners then return end
  for index = #listeners, 1, -1 do
    if listeners[index].owner == owner then table.remove(listeners, index) end
  end
  if #listeners == 0 then
    eventListeners[event] = nil
    pcall(eventFrame.UnregisterEvent, eventFrame, event)
  end
end

function NS.Debounce(delay, callback)
  local generation = 0
  return function(...)
    generation = generation + 1
    local current = generation
    local args = { ... }
    C_Timer.After(delay or 0, function()
      if current == generation then callback(unpack(args)) end
    end)
  end
end
