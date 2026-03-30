local ADDON, NS = ...
NS.UI = NS.UI or {}

local Util = {}
NS.UI.GatherTrackMiniUtil = Util

local LTUtils = NS.GT and NS.GT.Utils
local C_Item = C_Item
local GetItemInfo = GetItemInfo
local GetItemInfoInstant = GetItemInfoInstant

Util.KINDS = {
  lumber = { key = "lumber", title = "Lumber", accent = { 0.86, 0.67, 0.25, 1 } },
  ore = { key = "ore", title = "Ore", accent = { 0.67, 0.78, 0.88, 1 } },
  herb = { key = "herb", title = "Herbs", accent = { 0.48, 0.84, 0.58, 1 } },
}

function Util.GetDB()
  local addon = NS.Addon
  local prof = addon and addon.db and addon.db.profile
  prof = prof or {}
  prof.gatherTrack = prof.gatherTrack or {}
  prof.gatherTrack.gatherMini = prof.gatherTrack.gatherMini or {}
  return prof.gatherTrack
end

function Util.GetSharedCtx()
  local LT = NS.UI and NS.UI.GatherTrack
  if LT and LT.GetSharedCtx then
    return LT:GetSharedCtx()
  end
end

function Util.EnsurePanelDB(kind)
  local db = Util.GetDB()
  db.gatherMini = db.gatherMini or {}
  db.gatherMini[kind] = db.gatherMini[kind] or {}
  local panelDB = db.gatherMini[kind]

  if panelDB.width == nil then panelDB.width = 280 end
  if panelDB.height == nil then panelDB.height = 300 end
  if panelDB.collapsed == nil then panelDB.collapsed = false end
  if panelDB.alpha == nil then panelDB.alpha = 0.95 end
  if panelDB.point == nil then panelDB.point = "CENTER" end
  if panelDB.relPoint == nil then panelDB.relPoint = "CENTER" end

  if panelDB.x == nil or panelDB.y == nil then
    if kind == "lumber" then
      panelDB.x, panelDB.y = -270, 60
    elseif kind == "ore" then
      panelDB.x, panelDB.y = 0, 60
    else
      panelDB.x, panelDB.y = 270, 60
    end
  end

  if panelDB.open == nil then panelDB.open = false end
  return panelDB
end

function Util.GetKindInfo(kind)
  return Util.KINDS[kind] or Util.KINDS.lumber
end

function Util.IsKindEnabled(ctx, kind)
  if kind == "lumber" then
    return not ctx or ctx.trackLumber ~= false
  elseif kind == "ore" then
    return ctx and ctx.trackOre and true or false
  elseif kind == "herb" then
    return ctx and ctx.trackHerbs and true or false
  end
  return false
end

function Util.GetEnabledKinds(ctx)
  local enabled = {}
  for kind in pairs(Util.KINDS) do
    if Util.IsKindEnabled(ctx, kind) then
      enabled[#enabled + 1] = kind
    end
  end

  table.sort(enabled, function(a, b)
    local order = {
      lumber = 1,
      ore = 2,
      herb = 3,
    }
    return (order[a] or 99) < (order[b] or 99)
  end)

  return enabled
end

function Util.ShouldHideInInstance()
  local db = Util.GetDB()
  if not (db and db.hideInInstance) then
    return false
  end

  if type(IsInInstance) == "function" then
    local inInstance = IsInInstance()
    return inInstance and true or false
  end

  return false
end

function Util.GetDisplayTitle(kind)
  local info = Util.GetKindInfo(kind)
  return info.title .. " Materials"
end

function Util.EnsureItemMeta(ctx, itemID)
  if not ctx or not itemID then return nil end
  ctx.meta = ctx.meta or {}

  local meta = ctx.meta[itemID]
  if meta and meta.name and meta.icon then
    return meta
  end

  local name, _, _, _, _, _, _, _, _, icon, _, classID, subclassID = GetItemInfo(itemID)
  if (not name or not icon) and C_Item and C_Item.RequestLoadItemDataByID then
    pcall(C_Item.RequestLoadItemDataByID, itemID)
  end

  local _, _, _, _, icon2, classID2, subclassID2 = GetItemInfoInstant(itemID)
  meta = meta or {}
  meta.name = meta.name or name or ("Item " .. tostring(itemID))
  meta.icon = meta.icon or icon or icon2 or "Interface\\Icons\\INV_Misc_QuestionMark"
  meta.classID = meta.classID or classID or classID2
  meta.subclassID = meta.subclassID or subclassID or subclassID2
  ctx.meta[itemID] = meta
  return meta
end

function Util.BuildListForKind(ctx, kind)
  local items = {}
  if not ctx or not ctx.counts then
    return items
  end

  for itemID, count in pairs(ctx.counts) do
    local meta = Util.EnsureItemMeta(ctx, itemID)
    local itemKind = meta and LTUtils and LTUtils.GetTrackedGatheringKind and LTUtils.GetTrackedGatheringKind(meta.name, meta.classID, meta.subclassID)
    if itemKind == kind then
      items[#items + 1] = {
        itemID = itemID,
        count = tonumber(count) or 0,
        name = (meta and meta.name) or ("Item " .. tostring(itemID)),
        icon = meta and meta.icon,
      }
    end
  end

  local recentItemID = ctx.recentByKind and ctx.recentByKind[kind]

  table.sort(items, function(a, b)
    if recentItemID then
      local aRecent = a.itemID == recentItemID
      local bRecent = b.itemID == recentItemID
      if aRecent ~= bRecent then
        return aRecent
      end
    end
    if a.count ~= b.count then return a.count > b.count end
    if a.name ~= b.name then return a.name < b.name end
    return a.itemID < b.itemID
  end)

  return items
end

function Util.GetTotalForKind(ctx, kind)
  local total = 0
  for _, item in ipairs(Util.BuildListForKind(ctx, kind)) do
    total = total + (tonumber(item.count) or 0)
  end
  return total
end

function Util.GetItemCount(ctx, itemID)
  if not ctx or not itemID or not ctx.counts then
    return 0
  end
  return tonumber(ctx.counts[itemID]) or 0
end

function Util.GetBagItemCount(ctx, itemID)
  if not ctx or not itemID then
    return 0
  end

  if ctx.bagCounts then
    return tonumber(ctx.bagCounts[itemID]) or 0
  end

  local AccountWide = NS.UI and NS.UI.GatherTrackAccountWide
  if AccountWide and AccountWide.GetCurrentCharacterCount then
    return tonumber(AccountWide:GetCurrentCharacterCount(itemID)) or 0
  end

  return tonumber(ctx.counts and ctx.counts[itemID]) or 0
end

function Util.GetOverallItemCount(ctx, itemID)
  if not itemID then
    return 0
  end

  local AccountWide = NS.UI and NS.UI.GatherTrackAccountWide
  if AccountWide and AccountWide.GetCharacterBreakdown then
    local total = 0
    local breakdown = AccountWide:GetCharacterBreakdown(itemID)
    for _, entry in ipairs(breakdown or {}) do
      total = total + (tonumber(entry.count) or 0)
    end
    if total > 0 then
      return total
    end
  end

  return Util.GetBagItemCount(ctx, itemID)
end

function Util.GetTopItemsForKind(ctx, kind, maxItems)
  local items = Util.BuildListForKind(ctx, kind)
  local top = {}
  maxItems = maxItems or 5
  for i = 1, math.min(#items, maxItems) do
    top[#top + 1] = items[i]
  end
  return top
end

return Util
