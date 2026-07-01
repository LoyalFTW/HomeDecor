local MAJOR, MINOR = "LibMapSuite-1.0", 23
local LibMapSuite = LibStub:NewLibrary(MAJOR, MINOR)

if not LibMapSuite then
    return
end

LibMapSuite.private = LibMapSuite.private or {}

local private = LibMapSuite.private
private.modules = private.modules or {}
private.modules.Core = MINOR

function LibMapSuite:IsModuleLoaded(name)
    return private.modules[name] ~= nil, private.modules[name]
end

function LibMapSuite:GetLoadedModules()
    local result = {}
    for name, revision in pairs(private.modules) do result[name] = revision end
    return result
end

private.callbacks = private.callbacks or {}

function private:Fire(event, ...)
    local listeners = self.callbacks[event]
    if not listeners then return end
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn, ...)
        if not ok then
            geterrorhandler()(("LibMapSuite-1.0: callback error on %q: %s"):format(event, err))
        end
    end
end

function private:On(event, fn)
    self.callbacks[event] = self.callbacks[event] or {}
    table.insert(self.callbacks[event], fn)
end

LibMapSuite.MAJOR = MAJOR
LibMapSuite.MINOR = MINOR

local mixins = {
    "IsModuleLoaded",
    "GetLoadedModules",
    "OpenMenu",
    "AttachMenu",
    "RegisterMinimapButton",
    "UnregisterMinimapButton",
    "SetMinimapButtonIconSize",
    "SetMinimapButtonIcon",
    "GetMinimapButton",
    "ShowMinimapButton",
    "HideMinimapButton",
    "SetMinimapButtonPosition",
    "SetMinimapButtonLocked",
    "SetMinimapButtonSize",
    "SetMinimapButtonRingGap",
    "RefreshMinimapButton",
    "IsMinimapButtonRegistered",
    "GetMinimapButtonList",
    "IsAddonCompartmentAvailable",
    "IsMinimapButtonInCompartment",
    "AddMinimapButtonToCompartment",
    "RemoveMinimapButtonFromCompartment",
    "SetMinimapButtonOverflowThreshold",
    "RegisterMinimapPin",
    "UnregisterMinimapPin",
    "GetMinimapPin",
    "SetMinimapPinPosition",
    "ShowMinimapPin",
    "HideMinimapPin",
    "RefreshMinimapPins",
    "RegisterMinimapPinProvider",
    "AddMinimapPin",
    "RemoveMinimapPin",
    "RemoveMinimapPinProvider",
    "EnableLDBBridge",
    "SetLDBBridgeIgnoreList",
    "SetMinimapShape",
    "GetMinimapShape",
    "SetMinimapSize",
    "GetMinimapSize",
    "RestoreMinimap",
    "AddMinimapOverlay",
    "RemoveMinimapOverlay",
    "RegisterWorldMapButton",
    "AddWorldMapButton",
    "UnregisterWorldMapButton",
    "GetWorldMapButton",
    "ShowWorldMapButton",
    "HideWorldMapButton",
    "SetWorldMapButtonOffsets",
    "RegisterWorldMapPin",
    "UnregisterWorldMapPin",
    "GetWorldMapPin",
    "SetWorldMapPinPosition",
    "ShowWorldMapPin",
    "HideWorldMapPin",
    "RefreshWorldMapPins",
    "RegisterWorldMapPinProvider",
    "AddWorldMapPin",
    "RemoveWorldMapPin",
    "RemoveWorldMapPinProvider",
    "GetMapInfo",
    "GetLocalizedMap",
    "GetZoneSize",
    "GetPlayerMapPosition",
    "GetPlayerWorldPosition",
    "GetUnitWorldPosition",
    "GetPlayerZone",
    "GetPlayerZonePosition",
    "MapToWorld",
    "WorldToMap",
    "TranslateMapCoordinates",
    "GetMapDistance",
    "GetMapVector",
    "GetWorldCoordinatesFromZone",
    "GetZoneCoordinatesFromWorldInstance",
    "GetZoneCoordinatesFromWorld",
    "TranslateZoneCoordinates",
    "GetZoneDistance",
    "GetWorldDistance",
    "GetWorldVector",
}

local embedTargets = LibMapSuite.embedTargets or {}
LibMapSuite.embedTargets = embedTargets

function LibMapSuite:Embed(target)
    for _, method in ipairs(mixins) do
        local methodName = method
        target[methodName] = function(_, ...)
            local fn = LibMapSuite[methodName]
            assert(type(fn) == "function", MAJOR .. ": method unavailable: " .. methodName)
            return fn(LibMapSuite, ...)
        end
    end
    embedTargets[target] = true
    return target
end

for target in pairs(embedTargets) do
    LibMapSuite:Embed(target)
end
