local ADDON, NS = ...
NS.Data     = NS.Data     or {}
NS.Systems  = NS.Systems  or {}
NS.UI       = NS.UI       or {}

NS.Data.Vendors       = NS.Data.Vendors       or {}
NS.Data.Achievements  = NS.Data.Achievements  or {}
NS.Data.Quests        = NS.Data.Quests        or {}
NS.Data.Drops         = NS.Data.Drops         or {}
NS.Data.Professions   = NS.Data.Professions   or {}
NS.Data.PVP           = NS.Data.PVP           or {}

NS.Systems.DecorIndex   = NS.Systems.DecorIndex   or {}
NS.Systems.VendorIndex = NS.Systems.VendorIndex  or {}
NS.Systems.Collection  = NS.Systems.Collection   or {}
NS.Systems.Filters     = NS.Systems.Filters      or {}

NS.UI.HeaderController = NS.UI.HeaderController  or {}
NS.UI.Layout           = NS.UI.Layout            or {}
NS.UI.Tooltips         = NS.UI.Tooltips          or {}

local AceAddon = LibStub("AceAddon-3.0")
local AceDB    = LibStub("AceDB-3.0")
local LDB      = LibStub("LibDataBroker-1.1")
local LDBIcon  = LibStub("LibDBIcon-1.0")

local Addon = AceAddon:NewAddon(ADDON)
NS.Addon = Addon

local defaults = {
  profile = {
    eventTimers = {},
    ui = {
      viewMode = "Icon",
      activeCategory = "Achievements",
      search = "",
    },

    filters = {
      hideCollected = false,
      onlyCollected = false,
      expansion = "ALL",
      zone = "ALL",
      faction = "ALL",
      category = "ALL",
      subcategory = "ALL",
      activeExpansion = "All",
      activeZone = "All",
      activeCategory = "All",
      activeSubcategory = "All",
      expansions = {},
      zones = {},
      categories = {},
      subcats = {},
      decorTypes = {
        Chairs = false,
        Floors = false,
      },
      factions = {
        Alliance = true,
        Horde = true,
      },
    },

    tracker = {
      open = false,
      collapsed = false,
      trackZone = true,
      hideCompleted = false,
      alpha = 0.7,
      width = 310,
      height = 520,
      point = "TOPRIGHT",
      relPoint = "TOPRIGHT",
      x = -40,
      y = -80,
    },

    favorites = {},
    collection = { completedItems = {} },

    minimap = { hide = false },

    mapPins = {
      worldmap = true,
      minimap = true,
    },

    changelog = {
      autoOpen = true,
      lastSeenVersion = "",
    },
  }
}

local minimapObject = LDB:NewDataObject("HomeDecor", {
  type = "launcher",
  text = "HomeDecor",
  icon = "Interface/AddOns/HomeDecor/Media/Icon.tga",
  OnClick = function(_, button)
    if button == "LeftButton" then
      if NS.UI and NS.UI.ToggleMainFrame then
        NS.UI:ToggleMainFrame()
      end
      return
    end

    if button == "RightButton" then
      if NS.UI and NS.UI.Options and NS.UI.Options.Open then
        NS.UI.Options:Open()
      end
      return
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine("HomeDecor")
    tt:AddLine("Left Click: Open", 1, 1, 1)
    tt:AddLine("Right Click: Options", 1, 1, 1)
  end,
})

local function SetMinimapHidden(db, hide)
  if not db or not db.profile then return end
  db.profile.minimap.hide = hide and true or false
  if LDBIcon:IsRegistered(ADDON) then
    if hide then LDBIcon:Hide(ADDON) else LDBIcon:Show(ADDON) end
  end
end

NS.UI.SetMinimapHidden = SetMinimapHidden

local function HandleSlash(msg)
  msg = tostring(msg or ""):lower():trim()
  local cmd, rest = msg:match("^(%S+)%s*(.*)$")

  if not cmd or cmd == "" then
    if NS.UI and NS.UI.ToggleMainFrame then
      NS.UI:ToggleMainFrame()
    end
    return
  end

  if cmd == "minimap" or cmd == "mm" then
    local hide = NS.db.profile.minimap.hide
    rest = rest:lower()

    if rest == "show" then
      SetMinimapHidden(NS.db, false)
    elseif rest == "hide" then
      SetMinimapHidden(NS.db, true)
    else
      SetMinimapHidden(NS.db, not hide)
    end
    return
  end

  if cmd == "pins" or cmd == "mappins" then
    local prof = NS.db and NS.db.profile
    if not prof then return end
    prof.mapPins = prof.mapPins or {}
    local key = rest and rest:lower() or ""
    local which = "minimap"
    if key == "world" or key == "worldmap" then which = "worldmap" end
    if key == "mini" or key == "minimap" or key == "" then which = "minimap" end

    prof.mapPins[which] = not (prof.mapPins[which] and true or false)

    if NS.Systems and NS.Systems.MapPins then
      if which == "worldmap" and NS.Systems.MapPins.RefreshWorldMap then
        pcall(function() NS.Systems.MapPins:RefreshWorldMap() end)
      else
        if NS.Systems.MapPins.RefreshCurrentZone then
          pcall(function() NS.Systems.MapPins:RefreshCurrentZone() end)
        end
      end
    end
    return
  end

  if cmd == "options" or cmd == "opt" or cmd == "config" then
    if NS.UI and NS.UI.Options and NS.UI.Options.Open then
      NS.UI.Options:Open()
    end
    return
  end

  if cmd == "changelog" or cmd == "changes" then
    if NS.UI and NS.UI.ShowChangelogPopup then
      NS.UI:ShowChangelogPopup(true)
    end
    return
  end

  print("|cffFFD200HomeDecor Commands:|r")
  print("/hd                 - Toggle HomeDecor")
  print("/hd minimap [show|hide]")
  print("/hd pins [minimap|worldmap]  - Toggle vendor pins")
  print("/hd options          - Open options")
  print("/hd changelog       - Show What's New")
end

function Addon:OnInitialize()
  self.db = AceDB:New("HomeDecorDB", defaults)
  NS.db = self.db

  if NS.Systems.Filters and NS.Systems.Filters.EnsureDefaults then
    pcall(function()
      NS.Systems.Filters:EnsureDefaults(self.db.profile)
    end)
  end

  if not LDBIcon:IsRegistered(ADDON) then
    LDBIcon:Register(ADDON, minimapObject, self.db.profile.minimap)
  end

  SLASH_HOMEDECOR1 = "/hd"
  SLASH_HOMEDECOR2 = "/homedecor"
  SlashCmdList["HOMEDECOR"] = HandleSlash
end

function Addon:OnEnable()
  if NS.Systems.DecorIndex then
    NS.Systems.DecorIndex:Build()
  end

  if NS.Systems.MapTracker and NS.Systems.MapTracker.Enable then
    pcall(function() NS.Systems.MapTracker:Enable(true) end)
  end

  if NS.Systems.MapPins and NS.Systems.MapPins.Enable then
    pcall(function() NS.Systems.MapPins:Enable() end)
  end

  do
    local prof = self.db and self.db.profile
    local tdb = prof and prof.tracker
    if tdb and tdb.open and NS.UI and NS.UI.Tracker and NS.UI.Tracker.Create then
      NS.UI.Tracker:Create()
    end
  end
end