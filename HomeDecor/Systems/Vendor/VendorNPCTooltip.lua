local ADDON, NS = ...

NS.Systems = NS.Systems or {}

local VendorNPCTooltip = {}
NS.Systems.VendorNPCTooltip = VendorNPCTooltip

local L = NS.L

local _G = _G
local GameTooltip = _G.GameTooltip
local UnitGUID = _G.UnitGUID
local tonumber = _G.tonumber
local type = _G.type

local function CanAccess(value)
  if value == nil then return false end
  if _G.issecretvalue and _G.issecretvalue(value) then return false end
  if _G.canaccessvalue and not _G.canaccessvalue(value) then return false end
  return true
end

local function GetNPCIDFromGUID(guid)
  if type(guid) ~= "string" then return nil end
  local ok, npcID = pcall(function()
    return guid:match("Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%x+")
  end)
  if not ok then return nil end
  return npcID and tonumber(npcID) or nil
end

local function IsEnabled()
  local db = NS.db
  local prof = db and db.profile
  if not prof then return false end
  prof.vendor = prof.vendor or {}
  if prof.vendor.showVendorNPCTooltip == nil then prof.vendor.showVendorNPCTooltip = false end
  return prof.vendor.showVendorNPCTooltip
end

local function GetVendorCollectedStats(npcID)
  local DecorCounts = NS.Systems and NS.Systems.DecorCounts
  local MapPopupUtil = NS.UI and NS.UI.MapPopupUtil
  if not DecorCounts or not MapPopupUtil or not MapPopupUtil.GetVendorItems then return nil, nil end

  local items = MapPopupUtil.GetVendorItems(npcID)
  if type(items) ~= "table" or #items == 0 then return nil, nil end

  local total = 0
  local collected = 0
  local seen = {}

  for itemIndex = 1, #items do
    local item = items[itemIndex]
    local itemID = tonumber(item and item.itemID)
    if itemID and not seen[itemID] then
      seen[itemID] = true
      total = total + 1
      local owned = DecorCounts:GetBreakdownByItem(itemID)
      owned = tonumber(owned) or 0
      if owned > 0 then
        collected = collected + 1
      end
    end
  end

  if total > 0 then
    return collected, total
  end
  return nil, nil
end

local function AppendVendorInfo(tooltip, tooltipData)
  if not IsEnabled() then return end
  if tooltip and tooltip.IsForbidden and tooltip:IsForbidden() then return end

  local guid = type(tooltipData) == "table" and tooltipData.guid or nil

  if not guid and tooltip and tooltip.GetTooltipData then
    local dataOk, data = pcall(tooltip.GetTooltipData, tooltip)
    if dataOk and type(data) == "table" then
      guid = data.guid
    end
  end

  if not guid and tooltip and tooltip.GetUnit then
    local ok, unit, tooltipGuid = pcall(function() return tooltip:GetUnit() end)
    if not ok then return end
    guid = tooltipGuid
    if not guid and CanAccess(unit) then
      local guidOk, guidVal = pcall(UnitGUID, unit)
      if guidOk then
        guid = guidVal
      end
    end
  end

  if not CanAccess(guid) then return end
  if not guid then return end

  local npcID = GetNPCIDFromGUID(guid)
  if not npcID then return end

  local collected, total = GetVendorCollectedStats(npcID)
  if not total then return end

  tooltip:AddLine(" ")
  tooltip:AddLine(L["ADDON_NAME"], 1, 0.82, 0, 1)
  tooltip:AddDoubleLine(
    "Decor collected:",
    string.format("%d / %d", collected, total),
    0.7, 0.7, 0.7,
    collected == total and 0.4 or 0.9,
    collected == total and 0.9 or 0.9,
    0.2
  )
  tooltip:Show()
end

function VendorNPCTooltip:Enable()
  if self._enabled then return end
  self._enabled = true

  local TDP = _G.TooltipDataProcessor
  if TDP and TDP.AddTooltipPostCall and _G.Enum and _G.Enum.TooltipDataType then
    local ok = pcall(function()
      TDP.AddTooltipPostCall(_G.Enum.TooltipDataType.Unit, function(tooltip, tooltipData)
        if tooltip == GameTooltip then
          AppendVendorInfo(tooltip, tooltipData)
        end
      end)
    end)
    if ok then return end
  end

  if GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnShow", function(tooltip)
      AppendVendorInfo(tooltip)
    end)
  end
end

NS.RegisterEvent(VendorNPCTooltip, "PLAYER_LOGIN", function()
  NS.UnregisterEvent(VendorNPCTooltip, "PLAYER_LOGIN")
  VendorNPCTooltip:Enable()
end)

return VendorNPCTooltip
