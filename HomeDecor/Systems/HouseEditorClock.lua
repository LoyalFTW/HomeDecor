local ADDON, NS = ...
NS.Systems = NS.Systems or {}

local Clock = {}
NS.Systems.HouseEditorClock = Clock

local DEFAULTS = {
  enabled = true,
  display = "clock",
  timeSource = "auto",
  timeFormat = "auto",
}

local frame
local sessionSeconds = 0
local totalSeconds = 0
local initialized = false
local editorWired = false

local function L(key)
  local locale = NS.L
  return (locale and locale[key]) or key
end

local function DB()
  local profile = NS.db and NS.db.profile
  if not profile then return DEFAULTS end
  profile.houseEditorClock = profile.houseEditorClock or {}
  for key, value in pairs(DEFAULTS) do
    if profile.houseEditorClock[key] == nil then
      profile.houseEditorClock[key] = value
    end
  end
  return profile.houseEditorClock
end

local function GlobalDB()
  local global = NS.db and NS.db.global
  if not global then return nil end
  global.houseEditorClock = global.houseEditorClock or { totalSeconds = 0 }
  return global.houseEditorClock
end

local function SaveTotal()
  local db = GlobalDB()
  if db then db.totalSeconds = math.floor(totalSeconds) end
end

local function FormatDuration(seconds)
  seconds = math.max(0, math.floor(seconds or 0))
  local hours = math.floor(seconds / 3600)
  local minutes = math.floor((seconds % 3600) / 60)
  local secs = seconds % 60
  if hours > 0 then
    return string.format("%d:%02d:%02d", hours, minutes, secs)
  end
  return string.format("%02d:%02d", minutes, secs)
end

local function UseLocalTime(db)
  if db.timeSource == "local" then return true end
  if db.timeSource == "realm" then return false end
  return C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool("timeMgrUseLocalTime")
end

local function Use24HourTime(db)
  if db.timeFormat == "24" then return true end
  if db.timeFormat == "12" then return false end
  return C_CVar and C_CVar.GetCVarBool and C_CVar.GetCVarBool("timeMgrUseMilitaryTime")
end

local function GetClockText(db)
  local hour, minute
  if UseLocalTime(db) then
    hour = tonumber(date("%H")) or 0
    minute = tonumber(date("%M")) or 0
  else
    hour, minute = GetGameTime()
  end

  if Use24HourTime(db) then
    return string.format("%02d:%02d", hour, minute)
  end

  local suffix = hour >= 12 and "PM" or "AM"
  hour = hour % 12
  if hour == 0 then hour = 12 end
  return string.format("%d:%02d %s", hour, minute, suffix)
end

local function ShowTooltip(self)
  local db = DB()
  GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
  GameTooltip:SetText(L("EDITOR_CLOCK_TITLE"), 1, 0.82, 0)
  GameTooltip:AddDoubleLine(L("EDITOR_CLOCK_DISPLAYED"),
    db.display == "session" and L("EDITOR_CLOCK_SESSION_TIMER") or L("EDITOR_CLOCK_CURRENT_TIME"),
    1, 1, 1, 1, 1, 1)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L("EDITOR_CLOCK_TIME_TRACKED"), 1, 1, 1)
  GameTooltip:AddDoubleLine(L("EDITOR_CLOCK_THIS_SESSION"), FormatDuration(sessionSeconds),
    1, 0.82, 0, 1, 1, 1)
  GameTooltip:AddDoubleLine(L("EDITOR_CLOCK_TOTAL"), FormatDuration(totalSeconds),
    1, 0.82, 0, 1, 1, 1)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(L("EDITOR_CLOCK_CLICK_HINT"), 0.75, 0.75, 0.75, true)
  GameTooltip:Show()
end

local function RefreshText()
  if not frame then return end
  local db = DB()
  frame.Text:SetText(db.display == "session" and FormatDuration(sessionSeconds) or GetClockText(db))
  frame.TimerIcon:SetShown(db.display == "session")
  frame.ClockIcon:SetShown(db.display ~= "session")
end

local function SavePosition()
  if not frame then return end
  local centerX, centerY = frame:GetCenter()
  if not centerX or not centerY then return end
  local db = DB()
  db.x = centerX
  db.y = centerY
end

local function ApplyPosition(anchor)
  if not frame then return end
  local db = DB()
  frame:ClearAllPoints()
  if db.x and db.y then
    frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", db.x, db.y)
  else
    frame:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
  end
end

local function CreateClockFrame()
  if frame or not HousingControlsFrame or not HousingControlsFrame.OwnerControlFrame then return end
  local owner = HousingControlsFrame.OwnerControlFrame
  local anchor = owner.HouseEditorButton or owner

  frame = CreateFrame("Button", nil, owner, "BackdropTemplate")
  frame:SetSize(108, 28)
  ApplyPosition(anchor)
  frame:SetFrameLevel(owner:GetFrameLevel() + 20)
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)
  frame:RegisterForClicks("RightButtonUp")
  frame:RegisterForDrag("LeftButton")
  frame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1,
  })
  frame:SetBackdropColor(0.055, 0.045, 0.035, 0.92)
  frame:SetBackdropBorderColor(0.72, 0.52, 0.25, 0.9)

  frame.ClockIcon = frame:CreateTexture(nil, "ARTWORK")
  frame.ClockIcon:SetSize(16, 16)
  frame.ClockIcon:SetPoint("LEFT", 8, 0)
  frame.ClockIcon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")

  frame.TimerIcon = frame:CreateTexture(nil, "ARTWORK")
  frame.TimerIcon:SetSize(15, 15)
  frame.TimerIcon:SetPoint("LEFT", 8, 0)
  frame.TimerIcon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
  frame.TimerIcon:SetVertexColor(1, 0.75, 0.3)

  frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.Text:SetPoint("LEFT", frame.ClockIcon, "RIGHT", 5, 0)
  frame.Text:SetPoint("RIGHT", frame, "RIGHT", -7, 0)
  frame.Text:SetJustifyH("CENTER")
  frame.Text:SetTextColor(1, 0.86, 0.62)

  frame:SetScript("OnEnter", ShowTooltip)
  frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
  frame:SetScript("OnClick", function(_, button)
    if button ~= "RightButton" then return end
    local db = DB()
    db.display = db.display == "session" and "clock" or "session"
    RefreshText()
    ShowTooltip(frame)
  end)
  frame:SetScript("OnDragStart", function(self)
    if not IsShiftKeyDown() then return end
    self.isDragging = true
    GameTooltip:Hide()
    self:StartMoving()
  end)
  frame:SetScript("OnDragStop", function(self)
    if not self.isDragging then return end
    self.isDragging = nil
    self:StopMovingOrSizing()
    SavePosition()
    if self:IsMouseMotionFocus() then ShowTooltip(self) end
  end)

  frame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    sessionSeconds = sessionSeconds + elapsed
    totalSeconds = totalSeconds + elapsed
    if self.elapsed >= 1 then
      self.elapsed = 0
      RefreshText()
      if GameTooltip:IsOwned(self) then ShowTooltip(self) end
      SaveTotal()
    end
  end)
end

function Clock:Refresh()
  CreateClockFrame()
  if not frame then return end
  local shown = DB().enabled ~= false and HouseEditorFrame and HouseEditorFrame:IsShown()
  frame:SetShown(shown and true or false)
  if shown then RefreshText() else SaveTotal() end
end

function Clock:ResetTotal()
  totalSeconds = 0
  SaveTotal()
  if frame and GameTooltip:IsOwned(frame) then ShowTooltip(frame) end
end

function Clock:ResetPosition()
  local db = DB()
  db.x = nil
  db.y = nil
  if frame and HousingControlsFrame and HousingControlsFrame.OwnerControlFrame then
    local owner = HousingControlsFrame.OwnerControlFrame
    ApplyPosition(owner.HouseEditorButton or owner)
  end
end

function Clock:GetSessionSeconds()
  return sessionSeconds
end

function Clock:GetTotalSeconds()
  return totalSeconds
end

function Clock:Init()
  if initialized then return end
  initialized = true
  DB()
  local global = GlobalDB()
  totalSeconds = global and tonumber(global.totalSeconds) or 0

  local poll = CreateFrame("Frame")
  poll:SetScript("OnUpdate", function(self)
    if not HouseEditorFrame or not HousingControlsFrame or not HousingControlsFrame.OwnerControlFrame then return end
    self:SetScript("OnUpdate", nil)
    CreateClockFrame()
    if not editorWired then
      editorWired = true
      HouseEditorFrame:HookScript("OnShow", function() Clock:Refresh() end)
      HouseEditorFrame:HookScript("OnHide", function() Clock:Refresh() end)
    end
    Clock:Refresh()
  end)

  NS.RegisterEvent(Clock, "PLAYER_LOGOUT", SaveTotal)
end

return Clock
