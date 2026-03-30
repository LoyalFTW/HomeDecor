local ADDON, NS = ...
NS.UI = NS.UI or {}

local GatherTrack = {}
NS.UI.GatherTrack = GatherTrack

local Utils = NS.GT.Utils

local sharedCtx = nil

local function GetDB()
  return Utils.GetDB()
end

local function InitializeDefaults(db)
  db.lumberIDs = db.lumberIDs or {}

  if db.showIcons == nil then db.showIcons = true end
  if db.goal == nil then db.goal = 1000 end
  if db.alpha == nil then db.alpha = 0.7 end
  if db.compactMode == nil then db.compactMode = false end
  if db.trackLumber == nil then db.trackLumber = true end
  if db.trackOre == nil then db.trackOre = false end
  if db.trackHerbs == nil then db.trackHerbs = false end
end

function GatherTrack:Create()
  if sharedCtx then return end

  local db = GetDB()
  InitializeDefaults(db)

  local Render = NS.UI.GatherTrackRender
  sharedCtx = Render:Init({
    GetDB = GetDB,
    lumberIDs = db.lumberIDs or {},
    compactMode = db.compactMode and true or false,
    autoStartFarming = db.autoStartFarming and true or false,
    trackLumber = db.trackLumber ~= false,
    trackOre = db.trackOre and true or false,
    trackHerbs = db.trackHerbs and true or false,
  }) or {
    GetDB = GetDB,
    lumberIDs = db.lumberIDs or {},
    compactMode = db.compactMode and true or false,
    autoStartFarming = db.autoStartFarming and true or false,
    trackLumber = db.trackLumber ~= false,
    trackOre = db.trackOre and true or false,
    trackHerbs = db.trackHerbs and true or false,
  }

  local LumberList = NS.UI.GatherTrackLumberList
  if LumberList then LumberList:Create(sharedCtx) end

  local Events = NS.UI.GatherTrackEvents
  if Events then
    sharedCtx.eventFrame = CreateFrame("Frame")
    sharedCtx.frame = sharedCtx.eventFrame
    Events:Attach(self, sharedCtx)
  end

  if Render then Render:Refresh(sharedCtx) end

  if db.lumberListOpen and LumberList then LumberList:Show() end
  if NS.UI and NS.UI.GatherTrackGather and NS.UI.GatherTrackGather.RestoreOpenPanels then
    NS.UI.GatherTrackGather:RestoreOpenPanels()
  end
end

function GatherTrack:GetSharedCtx()
  return sharedCtx
end

function GatherTrack:Toggle()
  if not sharedCtx then self:Create() end
  local LumberList = NS.UI.GatherTrackLumberList
  if LumberList then LumberList:Toggle() end
end

function GatherTrack:ToggleLumberList()
  if not sharedCtx then self:Create() end
  local LumberList = NS.UI.GatherTrackLumberList
  if LumberList then LumberList:Toggle() end
end

function GatherTrack:ToggleFarmingStats()
  local FP = NS.UI and NS.UI.GatherTrackGatherFarmingPanels
  if FP and FP.Toggle then
    FP:Toggle("lumber")
  end
end

return GatherTrack
