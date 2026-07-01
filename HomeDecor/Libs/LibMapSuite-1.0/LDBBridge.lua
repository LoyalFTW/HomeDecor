local MAJOR = "LibMapSuite-1.0"
local LibMapSuite = LibStub(MAJOR)
if not LibMapSuite then return end
local private = LibMapSuite.private
if (private.modules.LDBBridge or 0) >= 3 then return end
private.modules.LDBBridge = 3

local LDBBridge = private.LDBBridge or {}
private.LDBBridge = LDBBridge
local loadWatcher = CreateFrame("Frame")
loadWatcher:SetScript("OnEvent", function(self)
    LDBBridge:Init()
    if LDBBridge.initialized then self:UnregisterAllEvents() end
end)

LDBBridge.manualIgnoreList = {}

LibMapSuiteLDBBridgeDB = LibMapSuiteLDBBridgeDB or {}
LDBBridge.db = LibMapSuiteLDBBridgeDB

local function IsAlreadyDisplayedElsewhere(name, ldbObj)
    if LDBBridge.manualIgnoreList[name] then
        return true
    end
    if ldbObj.hideFromLibMapSuite or ldbObj.notMinimap then
        return true
    end

    local LibDBIcon = LibStub("LibDBIcon-1.0", true)
    if LibDBIcon and LibDBIcon.IsRegistered and LibDBIcon:IsRegistered(name) then
        return true
    end

    return false
end

local function WrapLDBObject(name, ldbObj)
    if IsAlreadyDisplayedElsewhere(name, ldbObj) then
        return
    end

    local db = LDBBridge.db[name] or {}
    LDBBridge.db[name] = db

    local buttonData = {
        icon = function() return ldbObj.icon end,
        iconCoords = ldbObj.iconCoords,
        text = ldbObj.label or name,
        OnClick = function(self, button)
            if ldbObj.OnClick then return ldbObj.OnClick(self, button) end
        end,
        OnEnter = function(self)
            if ldbObj.OnEnter then return ldbObj.OnEnter(self) end
        end,
        OnLeave = function(self)
            if ldbObj.OnLeave then return ldbObj.OnLeave(self) end
        end,
        OnTooltipShow = function(tooltip)
            if ldbObj.OnTooltipShow then return ldbObj.OnTooltipShow(tooltip) end
            tooltip:SetText(ldbObj.label or name)
        end,
    }

    LibMapSuite:RegisterMinimapButton("LDB_" .. name, buttonData, db)

    local LDB = LibStub("LibDataBroker-1.1", true)
    if LDB and LDB.RegisterCallback then
        LDB.RegisterCallback(LDBBridge, "LibDataBroker_AttributeChanged_" .. name .. "_icon", function(_, _, _, value)
            LibMapSuite:SetMinimapButtonIcon("LDB_" .. name, value, ldbObj.iconCoords)
        end)
        LDB.RegisterCallback(LDBBridge, "LibDataBroker_AttributeChanged_" .. name .. "_iconCoords", function()
            LibMapSuite:SetMinimapButtonIcon("LDB_" .. name, ldbObj.icon, ldbObj.iconCoords)
        end)
    end
end

function LibMapSuite:SetLDBBridgeIgnoreList(...)
    for i = 1, select("#", ...) do
        LDBBridge.manualIgnoreList[(select(i, ...))] = true
    end
end

function LDBBridge:Init()
    if self.initialized then return end
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then
        return
    end

    self.initialized = true
    for name, obj in LDB:DataObjectIterator() do
        WrapLDBObject(name, obj)
    end

    if LDB.RegisterCallback then
        LDB.RegisterCallback(LDBBridge, "LibDataBroker_DataObjectCreated", function(_, name, obj)
            WrapLDBObject(name, obj)
        end)
    end
end

function LibMapSuite:EnableLDBBridge(savedVariables)
    if type(savedVariables) == "table" then LDBBridge.db = savedVariables end
    LDBBridge:Init()
    if not LDBBridge.initialized then loadWatcher:RegisterEvent("ADDON_LOADED") end
    return LDBBridge.initialized == true
end
