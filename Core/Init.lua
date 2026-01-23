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

    favorites = {},
    collection = { completedItems = {} },

    minimap = { hide = false },

    -- Changelog state (FIXED)
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
    if button == "LeftButton" and NS.UI and NS.UI.ToggleMainFrame then
      NS.UI:ToggleMainFrame()
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine("HomeDecor")
    tt:AddLine("Left Click: Open", 1, 1, 1)
  end,
})

local function SetMinimapHidden(db, hide)
  if not db or not db.profile then return end
  db.profile.minimap.hide = hide and true or false
  if LDBIcon:IsRegistered(ADDON) then
    if hide then LDBIcon:Hide(ADDON) else LDBIcon:Show(ADDON) end
  end
end

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

  if cmd == "changelog" or cmd == "changes" then
    if NS.UI and NS.UI.ShowChangelogPopup then
      NS.UI:ShowChangelogPopup(true)
    end
    return
  end

  print("|cffFFD200HomeDecor Commands:|r")
  print("/hd                 - Toggle HomeDecor")
  print("/hd minimap [show|hide]")
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
  -- NO forced changelog popup here (respects autoOpen + version)
end
