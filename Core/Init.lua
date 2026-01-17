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

      expansion   = "ALL",
      zone        = "ALL",
      faction     = "ALL",
      category    = "ALL",
      subcategory = "ALL",

      activeExpansion   = "All",
      activeZone        = "All",
      activeCategory    = "All",
      activeSubcategory = "All",

      expansions = {},
      zones      = {},
      categories = {},
      subcats    = {},

      decorTypes = {
        Chairs = false,
        Floors = false,
      },

      factions = {
        Alliance = true,
        Horde    = true,
      },
    },

    favorites = {},

    collection = {
      completedItems = {},
    },

    minimap = {
      hide = false,
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
    end
  end,

  OnTooltipShow = function(tt)
    tt:AddLine("HomeDecor")
    tt:AddLine("Left Click: Open", 1, 1, 1)
  end,
})

function Addon:OnInitialize()
  self.db = AceDB:New("HomeDecorDB", defaults)
  NS.db = self.db

  if NS.Systems and NS.Systems.Filters and NS.Systems.Filters.EnsureDefaults then
    pcall(function() NS.Systems.Filters:EnsureDefaults(self.db.profile) end)
  end

  if not LDBIcon:IsRegistered(ADDON) then
    LDBIcon:Register(ADDON, minimapObject, self.db.profile.minimap)
  end
  SLASH_HOMEDECOR1 = "/hd"
  SLASH_HOMEDECOR2 = "/homedecor"

  local function SetMinimapHidden(hide)
    if not self.db or not self.db.profile then return end
    self.db.profile.minimap = self.db.profile.minimap or {}
    self.db.profile.minimap.hide = hide and true or false

    if LDBIcon and LDBIcon.IsRegistered and LDBIcon:IsRegistered(ADDON) then
      if hide then
        LDBIcon:Hide(ADDON)
      else
        LDBIcon:Show(ADDON)
      end
    end
  end

  SlashCmdList["HOMEDECOR"] = function(msg)
    msg = tostring(msg or ""):lower()
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")

    local arg1, arg2 = msg:match("^(%S+)%s*(.*)$")

    if arg1 == "minimap" or arg1 == "mm" then
      arg2 = tostring(arg2 or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
      local hide = self.db and self.db.profile and self.db.profile.minimap and self.db.profile.minimap.hide

      if arg2 == "show" then
        SetMinimapHidden(false)
        print("HomeDecor: minimap button shown.")
      elseif arg2 == "hide" then
        SetMinimapHidden(true)
        print("HomeDecor: minimap button hidden.")
      else
        SetMinimapHidden(not hide)
        print("HomeDecor: minimap button " .. ((not hide) and "hidden." or "shown."))
      end
      return
    end

    if NS.UI and NS.UI.ToggleMainFrame then
      NS.UI:ToggleMainFrame()
    end
  end
end

function Addon:OnEnable()
  if NS.Systems and NS.Systems.DecorIndex then
    NS.Systems.DecorIndex:Build()
  end
end
