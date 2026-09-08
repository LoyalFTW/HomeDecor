local _, NS = ...

local AddonConflict = {}
NS.Systems.AddonConflict = AddonConflict

local addonNames = {
  { id = "AdvancedDecorationTools", title = "Advanced Decoration Tools" },
  { id = "HousingCompanion", title = "Housing Companion" },
}

local frameNames = {
  { id = "ADTQuickbarFrame", title = "Advanced Decoration Tools" },
  { id = "HousingCompanionQuickBar", title = "Housing Companion" },
  { id = "AdvancedDecorationQuickBar", title = "Advanced Decoration Tools" },
}

local function Preferences()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return nil end
  profile.addonConflict = type(profile.addonConflict) == "table" and profile.addonConflict or {}
  return profile.addonConflict
end

local function ConflictName()
  for index = 1, #frameNames do
    if _G[frameNames[index].id] then return frameNames[index].title end
  end
  if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded then
    for index = 1, #addonNames do
      local ok, loaded = pcall(_G.C_AddOns.IsAddOnLoaded, addonNames[index].id)
      if ok and loaded then return addonNames[index].title end
    end
  end
end

function AddonConflict:Apply(enabled)
  NS.Systems.Settings:SetValue("editorFeatures", enabled == true)
  NS.Systems.Settings:SetValue("quickBar", enabled == true)
  if NS.UI and NS.UI.QuickBar then NS.UI.QuickBar:SyncEditor() end
end

function AddonConflict:CreateDialog()
  if self.dialog then return self.dialog end
  local frame = CreateFrame("Frame", "HomeDecorConflictDialog", UIParent, "BackdropTemplate")
  frame:SetSize(440, 190)
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
  frame:SetFrameStrata("TOOLTIP")
  frame:SetFrameLevel(300)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  NS.UI.Controls:Backdrop(frame, NS.UI.Controls.colors.background, NS.UI.Controls.colors.border)
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -18)
  title:SetText("Home Decor - Editor Addon Conflict")
  NS.UI.Controls:TextColor(title, "accent")
  frame.message = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.message:SetPoint("TOPLEFT", 24, -52)
  frame.message:SetPoint("TOPRIGHT", -24, -52)
  frame.message:SetJustifyH("CENTER")
  frame.message:SetWordWrap(true)
  local disable = NS.UI.Controls:CreateButton(frame, "Use Other Addon", 125, 28)
  disable:SetPoint("BOTTOMLEFT", 18, 18)
  disable:SetScript("OnClick", function()
    local preferences = Preferences()
    if preferences then preferences.EditingFeatures = false end
    AddonConflict:Apply(false)
    frame:Hide()
  end)
  local keep = NS.UI.Controls:CreateButton(frame, "Keep Both", 125, 28)
  keep:SetPoint("BOTTOM", 0, 18)
  keep:SetScript("OnClick", function()
    local preferences = Preferences()
    if preferences then preferences.EditingFeatures = true end
    AddonConflict:Apply(true)
    frame:Hide()
  end)
  local later = NS.UI.Controls:CreateButton(frame, "Decide Later", 125, 28)
  later:SetPoint("BOTTOMRIGHT", -18, 18)
  later:SetScript("OnClick", function() frame:Hide() end)
  frame:Hide()
  self.dialog = frame
  return frame
end

function AddonConflict:Check()
  local preferences = Preferences()
  if not preferences or preferences.EditingFeatures ~= nil then return end
  local conflict = ConflictName()
  if not conflict or not _G.HouseEditorFrame or not _G.HouseEditorFrame:IsShown() then return end
  local dialog = self:CreateDialog()
  dialog.message:SetText(conflict .. " also provides housing editor controls. Choose which addon should own the editor Quick Bar and shortcuts.")
  dialog:Show()
  dialog:Raise()
end

function AddonConflict:Reset()
  local preferences = Preferences()
  if preferences then preferences.EditingFeatures = nil end
  self:Check()
end

function AddonConflict:Init()
  if self.initialized then return end
  self.initialized = true
  local preferences = Preferences()
  if preferences and type(preferences.EditingFeatures) == "boolean" then self:Apply(preferences.EditingFeatures) end
  local watcher = CreateFrame("Frame")
  watcher:SetScript("OnUpdate", function(self)
    if not _G.HouseEditorFrame then return end
    self:SetScript("OnUpdate", nil)
    _G.HouseEditorFrame:HookScript("OnShow", function() AddonConflict:Check() end)
    _G.HouseEditorFrame:HookScript("OnHide", function() if AddonConflict.dialog then AddonConflict.dialog:Hide() end end)
    AddonConflict:Check()
  end)
  self.watcher = watcher
end

return AddonConflict
