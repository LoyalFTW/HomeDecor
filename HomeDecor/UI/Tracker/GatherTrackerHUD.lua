local _, NS = ...

local GatherTracker = NS.UI.GatherTracker
local Shared = NS.UI.GatherTrackerShared
local Controls = Shared.Controls
local Label = Shared.Label
local Compact = Shared.Compact
local TimeText = Shared.TimeText
local KIND_ORDER = Shared.kindOrder
local KIND_INFO = Shared.kindInfo

local function AnchoredToMinimap(frame)
  if not frame or frame == Minimap then return false end
  if frame.GetParent then
    local ok, parent = pcall(frame.GetParent, frame)
    if ok and parent == Minimap then return true end
  end
  if not frame.GetNumPoints or not frame.GetPoint then return false end
  local countOK, count = pcall(frame.GetNumPoints, frame)
  if not countOK then return false end
  count = tonumber(count) or 0
  for index = 1, count do
    local ok, _, relative = pcall(frame.GetPoint, frame, index)
    if ok and relative == Minimap then return true end
  end
  return false
end

function GatherTracker:HideMinimapObjects()
  if not Minimap then return end
  self._hiddenMinimapObjects = self._hiddenMinimapObjects or {}
  self._hiddenMinimapLookup = self._hiddenMinimapLookup or {}
  local function HideObject(object)
    if not object or object == Minimap or not object.IsShown or not object.Hide then return end
    local ok, shown = pcall(object.IsShown, object)
    if ok and shown then
      if not GatherTracker._hiddenMinimapLookup[object] then
        GatherTracker._hiddenMinimapLookup[object] = true
        GatherTracker._hiddenMinimapObjects[#GatherTracker._hiddenMinimapObjects + 1] = object
      end
      pcall(object.Hide, object)
    end
  end
  for _, region in ipairs({ Minimap:GetRegions() }) do HideObject(region) end
  for _, child in ipairs({ Minimap:GetChildren() }) do HideObject(child) end
  for _, object in ipairs(self._hiddenMinimapObjects) do HideObject(object) end
  if EnumerateFrames and not self._minimapObjectsScanned then
    self._minimapObjectsScanned = true
    local frame = EnumerateFrames()
    while frame do
      if AnchoredToMinimap(frame) then HideObject(frame) end
      frame = EnumerateFrames(frame)
    end
  end
end

function GatherTracker:RestoreMinimapObjects()
  for _, object in ipairs(self._hiddenMinimapObjects or {}) do
    if object and object.Show then pcall(object.Show, object) end
  end
  self._hiddenMinimapObjects = nil
  self._hiddenMinimapLookup = nil
  self._minimapObjectsScanned = nil
end

local function CaptureMinimap()
  if GatherTracker._minimapState or not Minimap then return end
  local points = {}
  for index = 1, Minimap:GetNumPoints() do points[index] = { Minimap:GetPoint(index) } end
  GatherTracker._minimapState = {
    parent = Minimap:GetParent(),
    points = points,
    width = Minimap:GetWidth(),
    height = Minimap:GetHeight(),
    scale = Minimap:GetScale(),
    strata = Minimap:GetFrameStrata(),
    level = Minimap:GetFrameLevel(),
    alpha = Minimap:GetAlpha(),
    mouse = Minimap:IsMouseEnabled(),
  }
  if MinimapCluster then
    GatherTracker._minimapClusterState = {
      alpha = MinimapCluster:GetAlpha(),
      mouse = MinimapCluster:IsMouseEnabled(),
    }
  end
end

function GatherTracker:RestoreMinimap()
  local state = self._minimapState
  if not state or not Minimap then return end
  Minimap:SetParent(state.parent)
  Minimap:ClearAllPoints()
  for _, point in ipairs(state.points) do Minimap:SetPoint(unpack(point)) end
  Minimap:SetSize(state.width, state.height)
  Minimap:SetScale(state.scale)
  Minimap:SetFrameStrata(state.strata)
  Minimap:SetFrameLevel(state.level)
  Minimap:SetAlpha(state.alpha)
  Minimap:EnableMouse(state.mouse)
  local cluster = self._minimapClusterState
  if cluster and MinimapCluster then
    MinimapCluster:SetAlpha(cluster.alpha)
    MinimapCluster:EnableMouse(cluster.mouse)
  end
  self:RestoreMinimapObjects()
  self._minimapState = nil
  self._minimapClusterState = nil
end

function GatherTracker:ApplyHUDSize()
  local hud = self.hud
  if not hud then return end
  local size = self:GetSettings().hudSize
  hud:SetSize(size, size)
  if self._minimapState and Minimap:GetParent() == hud.mapHolder then Minimap:SetSize(size * 0.9, size * 0.9) end
  local center = size / 2
  for ringIndex, ring in ipairs(hud.rings) do
    local radius = size * (ringIndex == 1 and 0.27 or 0.45)
    for lineIndex, line in ipairs(ring) do
      local startAngle = ((lineIndex - 1) / #ring) * math.pi * 2
      local endAngle = (lineIndex / #ring) * math.pi * 2
      line:SetStartPoint("TOPLEFT", hud, center + (math.cos(startAngle) * radius), -(center + (math.sin(startAngle) * radius)))
      line:SetEndPoint("TOPLEFT", hud, center + (math.cos(endAngle) * radius), -(center + (math.sin(endAngle) * radius)))
    end
  end
  hud.north:ClearAllPoints()
  hud.north:SetPoint("TOP", 0, 5)
  hud.south:ClearAllPoints()
  hud.south:SetPoint("BOTTOM", 0, -5)
  hud.west:ClearAllPoints()
  hud.west:SetPoint("LEFT", -5, 0)
  hud.east:ClearAllPoints()
  hud.east:SetPoint("RIGHT", 5, 0)
  hud.handle:ClearAllPoints()
  hud.handle:SetPoint("TOP", hud, "TOP", 0, -18)
end

function GatherTracker:ApplyHUDLock()
  if not self.hud then return end
  local locked = self:GetSettings().hudLocked
  self.hud.handle:EnableMouse(true)
  if self._minimapState and Minimap:GetParent() == self.hud.mapHolder then Minimap:EnableMouse(not locked) end
  local background = Controls().colors.background
  local border = Controls().colors.border
  self.hud.handle:SetBackdropColor(background[1], background[2], background[3], locked and 0.5 or 0.88)
  self.hud.handle:SetBackdropBorderColor(border[1], border[2], border[3], locked and 0.4 or 0.95)
end

function GatherTracker:ShowHUDTooltip()
  local hud = self.hud
  if not hud or not GameTooltip then return end
  GameTooltip:SetOwner(hud.handle, "ANCHOR_BOTTOM")
  GameTooltip:ClearLines()
  GameTooltip:AddLine("Gathering Session")
  for _, kind in ipairs(KIND_ORDER) do
    if NS.Systems.GatherTracker:IsKindEnabled(kind) then
      local stats = NS.Systems.GatherTracker:GetKindStats(kind)
      local name = stats.name or ("Waiting for " .. KIND_INFO[kind].label:lower())
      GameTooltip:AddLine(name, 1, 1, 1)
      GameTooltip:AddDoubleLine("Session " .. Compact(stats.sessionCount) .. "   Bags " .. Compact(stats.bagCount), Compact(stats.rate) .. "/h", 0.65, 0.62, 0.56, 0.36, 0.92, 0.52)
    end
  end
  GameTooltip:AddLine(self:GetSettings().hudLocked and "Unlock the HUD to drag it." or "Drag this handle to move the HUD.", 0.65, 0.62, 0.56, true)
  GameTooltip:Show()
end

function GatherTracker:AttachMinimap()
  local hud = self:CreateHUD()
  CaptureMinimap()
  if not self._minimapState then return false end
  Minimap:SetParent(hud.mapHolder)
  Minimap:ClearAllPoints()
  Minimap:SetPoint("CENTER", hud.mapHolder, "CENTER")
  Minimap:SetScale(1)
  Minimap:SetFrameStrata("HIGH")
  Minimap:SetFrameLevel(hud:GetFrameLevel() + 1)
  Minimap:SetAlpha(0.62)
  if MinimapCluster then
    MinimapCluster:SetAlpha(0)
    MinimapCluster:EnableMouse(false)
  end
  self:HideMinimapObjects()
  self:ApplyHUDSize()
  self:ApplyHUDLock()
  return true
end

function GatherTracker:CreateHUD()
  if self.hud then return self.hud end
  local hud = CreateFrame("Frame", "HomeDecorGatherHUD", UIParent)
  hud:SetPoint("CENTER")
  hud:SetFrameStrata("HIGH")
  hud:SetFrameLevel(70)
  hud:SetClampedToScreen(true)
  NS.Systems.Layout:Restore(hud, "gatherHUD")
  hud.mapHolder = CreateFrame("Frame", nil, hud)
  hud.mapHolder:SetAllPoints()
  hud.overlay = CreateFrame("Frame", nil, hud)
  hud.overlay:SetAllPoints()
  hud.overlay:SetFrameLevel(hud:GetFrameLevel() + 3)
  hud.rings = {}
  for ringIndex = 1, 2 do
    local ring = {}
    for lineIndex = 1, 64 do
      local line = hud.overlay:CreateLine(nil, "OVERLAY")
      line:SetThickness(ringIndex == 1 and 1 or 1.5)
      line:SetColorTexture(ringIndex == 1 and 0.25 or 0.78, ringIndex == 1 and 0.72 or 0.58, ringIndex == 1 and 0.92 or 0.18, 0.8)
      ring[lineIndex] = line
    end
    hud.rings[ringIndex] = ring
  end
  hud.north = Label(hud.overlay, "GameFontNormalSmall", "accent")
  hud.north:SetText("N")
  hud.south = Label(hud.overlay, "GameFontNormalSmall", "accent")
  hud.south:SetText("S")
  hud.west = Label(hud.overlay, "GameFontNormalSmall", "accent")
  hud.west:SetText("W")
  hud.east = Label(hud.overlay, "GameFontNormalSmall", "accent")
  hud.east:SetText("E")
  hud.handle = CreateFrame("Frame", nil, hud, "BackdropTemplate")
  hud.handle:SetSize(124, 22)
  hud.handle:SetFrameLevel(hud:GetFrameLevel() + 5)
  Controls():Backdrop(hud.handle, Controls().colors.background)
  Controls():MakeMovable(hud, hud.handle, "gatherHUD")
  hud.title = Label(hud.handle, "GameFontNormalSmall", "accent")
  hud.title:SetPoint("LEFT", 6, 0)
  hud.title:SetText("GATHER")
  hud.time = Label(hud.handle, "GameFontNormalSmall", "accent")
  hud.time:SetPoint("RIGHT", -6, 0)
  hud.handle:SetScript("OnDragStart", function() if not GatherTracker:GetSettings().hudLocked then hud:StartMoving() end end)
  hud.handle:SetScript("OnDragStop", function()
    hud:StopMovingOrSizing()
    NS.Systems.Layout:Save(hud, "gatherHUD")
  end)
  hud.handle:SetScript("OnEnter", function() GatherTracker:ShowHUDTooltip() end)
  hud.handle:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  hud:SetScript("OnUpdate", function(self, elapsed)
    self._tick = (self._tick or 0) + elapsed
    if self._tick < 1 then return end
    self._tick = 0
    self.time:SetText(TimeText(NS.Systems.GatherTracker:GetSessionElapsed()))
    GatherTracker:HideMinimapObjects()
    if GameTooltip and GameTooltip:IsOwned(self.handle) then GatherTracker:ShowHUDTooltip() end
  end)
  hud:Hide()
  self.hud = hud
  self:ApplyHUDSize()
  self:ApplyHUDLock()
  NS.SafeRegisterEvent(hud, "PLAYER_LOGOUT", function() GatherTracker:RestoreMinimap() end)
  return hud
end

function GatherTracker:RefreshHUD()
  local settings = self:GetSettings()
  local hud = self.hud
  if not settings.hudEnabled then
    self:RestoreMinimap()
    if hud then hud:Hide() end
    return
  end
  local visible = 0
  for _, kind in ipairs(KIND_ORDER) do if NS.Systems.GatherTracker:IsKindEnabled(kind) then visible = visible + 1 end end
  if visible == 0 then
    self:RestoreMinimap()
    if hud then hud:Hide() end
    return
  end
  hud = self:CreateHUD()
  hud:Show()
  if not self._minimapState then self:AttachMinimap() end
  hud.time:SetText(TimeText(NS.Systems.GatherTracker:GetSessionElapsed()))
  self:HideMinimapObjects()
  self:ApplyHUDSize()
  self:ApplyHUDLock()
end

return GatherTracker
