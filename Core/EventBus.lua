local ADDON, NS = ...

local eventFrame = CreateFrame("Frame")
local handlers = {}  

eventFrame:SetScript("OnEvent", function(_, event, ...)
    local list = handlers[event]
    if not list then return end

    local copy = {}
    for i = 1, #list do copy[i] = list[i] end
    for i = 1, #copy do
        local h = copy[i]
        if h and h.func then
            local ok, err = pcall(h.func, ...)
            if not ok then
                geterrorhandler()(ADDON .. " EventBus [" .. event .. "]: " .. tostring(err))
            end
        end
    end
end)

function NS.RegisterEvent(obj, event, func)
    if not handlers[event] then
        handlers[event] = {}
        eventFrame:RegisterEvent(event)
    end

    local list = handlers[event]
    for i = 1, #list do
        if list[i].obj == obj then
            list[i].func = func  
            return
        end
    end
    list[#list + 1] = { obj = obj, func = func }
end

function NS.UnregisterEvent(obj, event)
    local list = handlers[event]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i].obj == obj then
            table.remove(list, i)
        end
    end
    if #list == 0 then
        handlers[event] = nil
        eventFrame:UnregisterEvent(event)
    end
end

function NS.SafeRegisterEvent(obj, event, func)
    local ok, err = pcall(NS.RegisterEvent, obj, event, func)
    if not ok then
    end
end

function NS.Debounce(delay, func)
    local timer = nil
    return function(...)
        if timer then timer:Cancel(); timer = nil end
        local args = { ... }
        timer = C_Timer.NewTimer(delay, function()
            timer = nil
            func(unpack(args))
        end)
    end
end

function NS.DebounceLeading(delay, func)
    local timer = nil
    local fired = false
    return function(...)
        if not fired then
            fired = true
            func(...)
            timer = C_Timer.NewTimer(delay, function()
                timer = nil
                fired = false
            end)
            return
        end
        if timer then timer:Cancel() end
        local args = { ... }
        timer = C_Timer.NewTimer(delay, function()
            timer = nil
            fired = false
            func(unpack(args))
        end)
    end
end

local messageHandlers = {} 

function NS.OnMessage(msg, func)
    messageHandlers[msg] = messageHandlers[msg] or {}
    messageHandlers[msg][#messageHandlers[msg] + 1] = func
end

function NS.SendMessage(msg, ...)
    local list = messageHandlers[msg]
    if not list then return end
    for i = 1, #list do
        local ok, err = pcall(list[i], ...)
        if not ok then
            geterrorhandler()(ADDON .. " Message [" .. msg .. "]: " .. tostring(err))
        end
    end
end
