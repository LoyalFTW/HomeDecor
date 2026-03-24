local ADDON, NS = ...
NS.UI = NS.UI or {}

local GatherTrack = {}
NS.UI.GatherTrack = GatherTrack

local Panels = NS.UI.GatherTrackPanels
local GTUtil = NS.UI.GatherTrackUtil
local FarmingPanels = NS.UI.GatherTrackFarmingPanels

local function SetKindEnabled(kind, enabled)
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

  if ctx then
    local Render = NS.UI and NS.UI.LumberTrackRender
    if Render and Render.Refresh then
      Render:Refresh(ctx)
    end
  end
end

function GatherTrack:Ensure()
  local LT = NS.UI and NS.UI.LumberTrack
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
        GatherTrack:RefreshAll()
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

function GatherTrack:RefreshAll(ctx)
  self:Ensure()
  ctx = ctx or GTUtil.GetSharedCtx()
  Panels:Refresh(nil, ctx)
  if FarmingPanels and FarmingPanels.Refresh then
    FarmingPanels:Refresh(nil, ctx)
  end
end

function GatherTrack:Toggle(kind)
  self:Ensure()
  SetKindEnabled(kind, true)
  Panels:Toggle(kind)
  self:RefreshAll()
end

function GatherTrack:Show(kind)
  self:Ensure()
  if kind then
    SetKindEnabled(kind, true)
  end
  Panels:Show(kind)
  self:RefreshAll()
end

function GatherTrack:ToggleAll()
  self:Ensure()
  SetKindEnabled("lumber", true)
  SetKindEnabled("ore", true)
  SetKindEnabled("herb", true)
  Panels:ShowDefaults()
  self:RefreshAll()
end

function GatherTrack:RestoreOpenPanels()
  self:Ensure()
  local db = GTUtil.GetDB()
  local mini = db and db.gatherMini or {}
  if mini.main and mini.main.open then
    SetKindEnabled("lumber", true)
    SetKindEnabled("ore", true)
    SetKindEnabled("herb", true)
    Panels:Show()
  end
  if FarmingPanels and FarmingPanels.RestoreOpen then
    FarmingPanels:RestoreOpen()
  end
  self:RefreshAll()
end

return GatherTrack
