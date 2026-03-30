local ADDON, NS = ...
NS.UI = NS.UI or {}

local Farming = {}
NS.UI.GatherTrackMiniFarming = Farming

local GTUtil = NS.UI.GatherTrackMiniUtil
local time = time or GetTime
local floor = math.floor
local STARTUP_RATE_WINDOW = 60

local function ensureDB(kind)
  local db = GTUtil.GetDB()
  db.gatherFarming = db.gatherFarming or {}
  db.gatherFarming[kind] = db.gatherFarming[kind] or {}
  return db.gatherFarming[kind]
end

function Farming:EnsureSession(kind)
  self.sessions = self.sessions or {}
  self.sessions[kind] = self.sessions[kind] or {
    active = false,
    paused = false,
    startTime = 0,
    firstGainTime = 0,
    pauseTime = 0,
    totalPausedTime = 0,
    startTotal = 0,
    totalGained = 0,
    perMinute = 0,
    topItems = {},
    itemGains = {},
    primaryItemID = nil,
    recentItemID = nil,
    recentAmount = 0,
  }
  return self.sessions[kind]
end

function Farming:Start(kind, ctx)
  local session = self:EnsureSession(kind)
  session.active = true
  session.paused = false
  session.startTime = time()
  session.firstGainTime = 0
  session.pauseTime = 0
  session.totalPausedTime = 0
  session.startTotal = GTUtil.GetTotalForKind(ctx or GTUtil.GetSharedCtx(), kind)
  session.totalGained = 0
  session.perMinute = 0
  session.topItems = {}
  session.itemGains = {}
  session.primaryItemID = nil
  session.recentItemID = nil
  session.recentAmount = 0
  ensureDB(kind).open = ensureDB(kind).open or false
end

function Farming:Stop(kind)
  local session = self:EnsureSession(kind)
  session.active = false
  session.paused = false
end

function Farming:Reset(kind, ctx)
  local session = self:EnsureSession(kind)
  session.active = false
  session.paused = false
  session.startTime = 0
  session.firstGainTime = 0
  session.pauseTime = 0
  session.totalPausedTime = 0
  session.startTotal = GTUtil.GetTotalForKind(ctx or GTUtil.GetSharedCtx(), kind)
  session.totalGained = 0
  session.perMinute = 0
  session.topItems = {}
  session.itemGains = {}
  session.primaryItemID = nil
  session.recentItemID = nil
  session.recentAmount = 0
end

function Farming:TogglePause(kind)
  local session = self:EnsureSession(kind)
  if not session.active then return end
  if session.paused then
    session.totalPausedTime = session.totalPausedTime + (time() - session.pauseTime)
    session.pauseTime = 0
    session.paused = false
  else
    session.pauseTime = time()
    session.paused = true
  end
end

function Farming:GetElapsed(kind)
  local session = self:EnsureSession(kind)
  if not session.active then return 0 end
  local now = time()
  local startTime = session.firstGainTime and session.firstGainTime > 0 and session.firstGainTime or session.startTime
  local elapsed = session.paused and (session.pauseTime - startTime) - session.totalPausedTime
    or (now - startTime) - session.totalPausedTime
  return math.max(0, elapsed)
end

function Farming:RecordGain(kind, itemID, amount, ctx)
  if not kind or not itemID or not amount or amount <= 0 then
    return
  end

  local session = self:EnsureSession(kind)
  if kind == "lumber" then
    if session.active and session.primaryItemID and session.primaryItemID ~= itemID then
      self:Start(kind, ctx)
      session = self:EnsureSession(kind)
    end
    session.primaryItemID = itemID
  end
  if session.active and (not session.firstGainTime or session.firstGainTime == 0) then
    session.firstGainTime = time()
  end
  session.itemGains = session.itemGains or {}
  session.itemGains[itemID] = (session.itemGains[itemID] or 0) + amount
  session.recentItemID = itemID
  session.recentAmount = amount

  ctx = ctx or GTUtil.GetSharedCtx()
  if ctx then
    GTUtil.EnsureItemMeta(ctx, itemID)
  end

  self:Update(kind, ctx)
end

local function BuildTopItems(session, ctx, kind, elapsed)
  local items = {}
  local gains = session.itemGains or {}
  local rateElapsed = tonumber(elapsed) or 0
  local effectiveElapsed = rateElapsed > 0 and rateElapsed or STARTUP_RATE_WINDOW

  for itemID, count in pairs(gains) do
    if count and count > 0 then
      local meta = GTUtil.EnsureItemMeta(ctx, itemID)
      local perHour = 0
      if count > 0 then
        perHour = (count / effectiveElapsed) * 3600
      end
      items[#items + 1] = {
        itemID = itemID,
        count = count,
        name = (meta and meta.name) or ("Item " .. tostring(itemID)),
        icon = meta and meta.icon,
        perHour = perHour,
      }
    end
  end

  table.sort(items, function(a, b)
    local recentItemID = session.recentItemID
    if recentItemID then
      local aRecent = a.itemID == recentItemID
      local bRecent = b.itemID == recentItemID
      if aRecent ~= bRecent then
        return aRecent
      end
    end
    if a.count ~= b.count then
      return a.count > b.count
    end
    if a.name ~= b.name then
      return a.name < b.name
    end
    return a.itemID < b.itemID
  end)

  local top = {}
  for i = 1, math.min(#items, 5) do
    top[#top + 1] = items[i]
  end

  return top
end

local function GetSessionGainTotal(session)
  local total = 0
  for _, count in pairs(session.itemGains or {}) do
    total = total + (tonumber(count) or 0)
  end
  return total
end

function Farming:Update(kind, ctx)
  local session = self:EnsureSession(kind)
  ctx = ctx or GTUtil.GetSharedCtx()

  if not session.active then
    session.totalGained = GetSessionGainTotal(session)
    session.topItems = BuildTopItems(session, ctx, kind, 0)
    return
  end

  session.totalGained = GetSessionGainTotal(session)

  local elapsed = self:GetElapsed(kind)
  local effectiveElapsed = elapsed > 0 and elapsed or STARTUP_RATE_WINDOW
  if session.totalGained > 0 then
    session.perMinute = (session.totalGained / effectiveElapsed) * 60
  else
    session.perMinute = 0
  end

  session.topItems = BuildTopItems(session, ctx, kind, elapsed)
end

function Farming:GetStats(kind, ctx)
  local session = self:EnsureSession(kind)
  local elapsed = self:GetElapsed(kind)
  local minutes = floor(elapsed / 60)
  local seconds = floor(elapsed % 60)
  ctx = ctx or GTUtil.GetSharedCtx()
  local focusItemID = kind == "lumber" and session.primaryItemID or session.recentItemID
  if not focusItemID then
    local topItem = session.topItems and session.topItems[1]
    focusItemID = topItem and topItem.itemID or nil
  end
  local focusGain = tonumber(session.itemGains and session.itemGains[focusItemID]) or 0
  local focusBagCount = GTUtil.GetBagItemCount(ctx, focusItemID)
  local focusOverallCount = GTUtil.GetOverallItemCount(ctx, focusItemID)
  local focusPerHour = 0
  local effectiveElapsed = elapsed > 0 and elapsed or STARTUP_RATE_WINDOW
  if focusGain > 0 then
    focusPerHour = (focusGain / effectiveElapsed) * 3600
  end
  local extraItems = 0
  for itemID, count in pairs(session.itemGains or {}) do
    if itemID ~= focusItemID and (tonumber(count) or 0) > 0 then
      extraItems = extraItems + 1
    end
  end
  if kind == "lumber" then
    extraItems = 0
  end
  return {
    active = session.active,
    paused = session.paused,
    totalGained = session.totalGained or 0,
    perMinute = session.perMinute or 0,
    perHour = (session.perMinute or 0) * 60,
    focusItemID = focusItemID,
    primaryItemID = session.primaryItemID,
    focusSessionCount = focusGain,
    focusBagCount = focusBagCount,
    focusOverallCount = focusOverallCount,
    focusPerHour = focusPerHour,
    focusRecentAmount = session.recentItemID == focusItemID and (session.recentAmount or 0) or 0,
    extraItems = extraItems,
    sessionTime = string.format("%d:%02d", minutes, seconds),
    topItems = session.topItems or {},
    recentItemID = session.recentItemID,
    recentAmount = session.recentAmount or 0,
  }
end

return Farming
