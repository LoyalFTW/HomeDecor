local ADDON, NS = ...
NS.UI = NS.UI or {}

local Gather = {}
NS.UI.GatherTrackMini = Gather

local Panels = NS.UI.GatherTrackMiniPanels
local GTUtil = NS.UI.GatherTrackMiniUtil
local FarmingPanels = NS.UI.GatherTrackMiniFarmingPanels

local function SetKindEnabled(kind, enabled, deferRefresh)
  local db = GTUtil.GetDB()
  local ctx = GTUtil.GetSharedCtx()

  if kind == "lumber" then
    db.trackLumber = enabled and true or false
    if ctx then ctx.trackLumber = enabled and true or false end
  elseif kind == "ore" then
    db.trackOre = enabled and true or false
    if ctx then ctx.trackOre = enabled and true or false end
  elseif kind == "herb" then
    db.trackHerbs = enabled and true or false
    if ctx then ctx.trackHerbs = enabled and true or false end
  end

  if ctx and not deferRefresh then
    local Render = NS.UI and NS.UI.GatherTrackRender
    if Render and Render.Refresh then
      Render:Refresh(ctx)
    end
  end
end

function Gather:RequestRefresh(ctx, delay)
  if self._refreshTimer then
    self._refreshTimer:Cancel()
    self._refreshTimer = nil
  end

  self._refreshTimer = C_Timer.NewTimer(delay or 0.05, function()
    Gather._refreshTimer = nil
    local sharedCtx = ctx or GTUtil.GetSharedCtx()
    local Render = NS.UI and NS.UI.GatherTrackRender
    if Render and Render.Refresh and sharedCtx then
      Render:Refresh(sharedCtx)
    else
      Gather:RefreshAll(sharedCtx)
    end
  end)
end

function Gather:Ensure()
  local LT = NS.UI and NS.UI.GatherTrack
  if LT and LT.Create then
    LT:Create()
  end

  Panels:Create()
  if FarmingPanels and FarmingPanels.Create then
    FarmingPanels:Create()
  end

  if not self.visibilityFrame then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:SetScript("OnEvent", function()
      C_Timer.After(0, function()
        Gather:RefreshAll()
        local db = GTUtil.GetDB()
        local mini = db and db.gatherMini and db.gatherMini.main
        local farming = db and db.gatherFarming and db.gatherFarming.main
        if GTUtil.ShouldHideInInstance() then
          if Panels and Panels.frame and Panels.frame:IsShown() then
            if Panels.frame.legacySettings and Panels.frame.legacySettings:IsShown() then
              Panels.frame.legacySettings:Hide()
            end
            if Panels.frame.settingsPopup and Panels.frame.settingsPopup:IsShown() then
              Panels.frame.settingsPopup:Hide()
            end
            Panels.frame:Hide()
          end
          if FarmingPanels and FarmingPanels.frame and FarmingPanels.frame:IsShown() then
            if FarmingPanels.frame.settingsPopup and FarmingPanels.frame.settingsPopup:IsShown() then
              FarmingPanels.frame.settingsPopup:Hide()
            end
            FarmingPanels.frame._suppressOpenSave = true
            FarmingPanels.frame:Hide()
          end
        else
          if mini and mini.open and Panels and Panels.Show then
            Panels:Show()
          end
          if farming and farming.open and FarmingPanels and FarmingPanels.Show then
            FarmingPanels:Show()
          end
        end
      end)
    end)
    self.visibilityFrame = frame
  end
end

function Gather:RefreshAll(ctx)
  self:Ensure()
  ctx = ctx or GTUtil.GetSharedCtx()
  Panels:Refresh(nil, ctx)
  if FarmingPanels and FarmingPanels.Refresh then
    FarmingPanels:Refresh(nil, ctx)
  end
end

function Gather:Toggle(kind)
  self:Ensure()
  SetKindEnabled(kind, true, true)
  Panels:Toggle(kind)
  self:RequestRefresh(nil, 0.05)
end

function Gather:Show(kind)
  self:Ensure()
  if kind then
    SetKindEnabled(kind, true, true)
  end
  Panels:Show(kind)
  self:RequestRefresh(nil, 0.05)
end

function Gather:ToggleAll()
  self:Ensure()
  if Panels and Panels.frame and Panels.frame:IsShown() then
    Panels:Hide()
    return
  end

  SetKindEnabled("lumber", true, true)
  SetKindEnabled("ore", true, true)
  SetKindEnabled("herb", true, true)
  Panels:ShowDefaults()
  self:RequestRefresh(nil, 0.05)
end

function Gather:RestoreOpenPanels()
  self:Ensure()
  local db = GTUtil.GetDB()
  local mini = db and db.gatherMini or {}
  if mini.main and mini.main.open then
    SetKindEnabled("lumber", true, true)
    SetKindEnabled("ore", true, true)
    SetKindEnabled("herb", true, true)
    Panels:Show()
  end
  if FarmingPanels and FarmingPanels.RestoreOpen then
    FarmingPanels:RestoreOpen()
  end
  self:RequestRefresh(nil, 0.05)
end

return Gather
