local ADDON, NS = ...
NS.UI = NS.UI or {}

local Farming = {}
NS.UI.GatherTrackFarming = Farming

local GTUtil = NS.UI.GatherTrackUtil
local time = time or GetTime
local floor = math.floor

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
    pauseTime = 0,
    totalPausedTime = 0,
    startTotal = 0,
    totalGained = 0,
    perMinute = 0,
    topItems = {},
  }
  return self.sessions[kind]
end

function Farming:Start(kind, ctx)
  local session = self:EnsureSession(kind)
  session.active = true
  session.paused = false
  session.startTime = time()
  session.pauseTime = 0
  session.totalPausedTime = 0
  session.startTotal = GTUtil.GetTotalForKind(ctx or GTUtil.GetSharedCtx(), kind)
  session.totalGained = 0
  session.perMinute = 0
  session.topItems = GTUtil.GetTopItemsForKind(ctx or GTUtil.GetSharedCtx(), kind, 5)
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
  session.pauseTime = 0
  session.totalPausedTime = 0
  session.startTotal = GTUtil.GetTotalForKind(ctx or GTUtil.GetSharedCtx(), kind)
  session.totalGained = 0
  session.perMinute = 0
  session.topItems = GTUtil.GetTopItemsForKind(ctx or GTUtil.GetSharedCtx(), kind, 5)
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
  local elapsed = session.paused and (session.pauseTime - session.startTime) - session.totalPausedTime
    or (now - session.startTime) - session.totalPausedTime
  return math.max(0, elapsed)
end

function Farming:Update(kind, ctx)
  local session = self:EnsureSession(kind)
  ctx = ctx or GTUtil.GetSharedCtx()
  local currentTotal = GTUtil.GetTotalForKind(ctx, kind)
  session.topItems = GTUtil.GetTopItemsForKind(ctx, kind, 5)

  if not session.active then
    return
  end

  session.totalGained = currentTotal - (session.startTotal or 0)
  if session.totalGained < 0 then
    session.startTotal = currentTotal
    session.totalGained = 0
  end

  local elapsed = self:GetElapsed(kind)
  if elapsed > 0 then
    session.perMinute = (session.totalGained / elapsed) * 60
  else
    session.perMinute = 0
  end
end

function Farming:GetStats(kind, ctx)
  local session = self:EnsureSession(kind)
  self:Update(kind, ctx)
  local elapsed = self:GetElapsed(kind)
  local minutes = floor(elapsed / 60)
  local seconds = floor(elapsed % 60)
  local totalBags = GTUtil.GetTotalForKind(ctx or GTUtil.GetSharedCtx(), kind)
  return {
    active = session.active,
    paused = session.paused,
    totalGained = session.totalGained or 0,
    perMinute = session.perMinute or 0,
    perHour = (session.perMinute or 0) * 60,
    totalBags = totalBags,
    sessionTime = string.format("%d:%02d", minutes, seconds),
    topItems = session.topItems or {},
  }
end

return Farming
