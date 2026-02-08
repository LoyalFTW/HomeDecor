local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.Options = NS.UI.Options or {}
local Options = NS.UI.Options

local CreateFrame = _G.CreateFrame
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
local Settings = _G.Settings

local function bool(v)
  return v and true or false
end

local function ensureProfile()
  local db = NS.db
  local prof = db and db.profile
  if not prof then return nil end
  prof.mapPins = prof.mapPins or {}
  if prof.mapPins.minimap == nil then prof.mapPins.minimap = true end
  if prof.mapPins.worldmap == nil then prof.mapPins.worldmap = true end
  prof.minimap = prof.minimap or { hide = false }
  return prof
end

local function refreshPins()
  local MP = NS.Systems and NS.Systems.MapPins
  if not MP then return end
  if MP.RefreshCurrentZone then pcall(function() MP:RefreshCurrentZone() end) end
  if MP.RefreshWorldMap then pcall(function() MP:RefreshWorldMap() end) end
end

local function openCategoryFrame(panel)
  if Settings and Settings.OpenToCategory and panel then
    local cat = panel.category
    local id

    if type(cat) == "table" then
      id = cat.ID
      if not id and type(cat.GetID) == "function" then
        local ok, v = pcall(cat.GetID, cat)
        if ok then id = v end
      end
    elseif type(cat) == "number" then
      id = cat
    end

    if id then
      Settings.OpenToCategory(id)
      return
    end

    if panel.name then
      pcall(function() Settings.OpenToCategory(panel.name) end)
      return
    end
  end

  if InterfaceOptionsFrame_OpenToCategory and panel then
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
  end
end

local function mkCheckbox(parent, label, sub)
  local b = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
  b.Text:SetText(label)
  if sub and sub ~= "" then
    b.tooltipText = label
    b.tooltipRequirement = sub
  end
  return b
end

function Options:Ensure()
  if self.panel then return end

  local panel = CreateFrame("Frame")
  panel.name = "HomeDecor"

  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("HomeDecor")

  local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
  sub:SetText("Quality-of-life settings for the addon.")

  local y = -60

  local cbMinimapButton = mkCheckbox(panel, "Show minimap button")
  cbMinimapButton:SetPoint("TOPLEFT", 16, y)
  y = y - 34

  local cbMiniPins = mkCheckbox(panel, "Show vendor pins on the minimap")
  cbMiniPins:SetPoint("TOPLEFT", 16, y)
  y = y - 34

  local cbWorldPins = mkCheckbox(panel, "Show vendor pins on the world map")
  cbWorldPins:SetPoint("TOPLEFT", 16, y)

  local function syncFromDB()
    local prof = ensureProfile()
    if not prof then return end
    cbMinimapButton:SetChecked(not bool(prof.minimap.hide))
    cbMiniPins:SetChecked(bool(prof.mapPins.minimap))
    cbWorldPins:SetChecked(bool(prof.mapPins.worldmap))
  end

  cbMinimapButton:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    local show = self:GetChecked() and true or false
    prof.minimap.hide = not show
    if NS.UI and NS.UI.SetMinimapHidden then
      pcall(NS.UI.SetMinimapHidden, NS.db, not show)
    else
      local LDBIcon = _G.LibStub and _G.LibStub("LibDBIcon-1.0", true)
      if LDBIcon and LDBIcon:IsRegistered(ADDON) then
        if show then LDBIcon:Show(ADDON) else LDBIcon:Hide(ADDON) end
      end
    end
  end)

  cbMiniPins:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.mapPins.minimap = self:GetChecked() and true or false
    refreshPins()
  end)

  cbWorldPins:SetScript("OnClick", function(self)
    local prof = ensureProfile()
    if not prof then return end
    prof.mapPins.worldmap = self:GetChecked() and true or false
    refreshPins()
  end)

  panel:SetScript("OnShow", syncFromDB)

  if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    panel.category = category
  else
    local add = _G.InterfaceOptions_AddCategory
    if add then add(panel) end
  end

  self.panel = panel
end

function Options:Open()
  self:Ensure()
  openCategoryFrame(self.panel)
end

return Options
