local _, NS = ...

NS.UI = NS.UI or {}
local Theme = { colors = NS.UI.Controls and NS.UI.Controls.colors or {} }
NS.UI.Theme = Theme

local PRESETS = {
  classic = {
    label = "Classic",
    colors = {
      background = { 0.008, 0.010, 0.010, 0.99 },
      header = { 0.018, 0.019, 0.016, 0.99 },
      panel = { 0.030, 0.031, 0.027, 0.99 },
      row = { 0.044, 0.044, 0.038, 0.98 },
      hover = { 0.080, 0.070, 0.038, 0.98 },
      border = { 0.340, 0.270, 0.080, 1 },
      accent = { 1.000, 0.760, 0.080, 1 },
      highlight = { 0.860, 0.680, 0.040, 1 },
      text = { 0.930, 0.910, 0.850, 1 },
      muted = { 0.640, 0.620, 0.560, 1 },
    },
  },
  gallery = {
    label = "Gallery",
    colors = {
      background = { 0.025, 0.030, 0.034, 0.99 },
      header = { 0.040, 0.046, 0.052, 0.99 },
      panel = { 0.060, 0.067, 0.075, 0.99 },
      row = { 0.095, 0.105, 0.118, 0.98 },
      hover = { 0.140, 0.155, 0.170, 0.98 },
      border = { 0.280, 0.245, 0.165, 1 },
      accent = { 0.950, 0.730, 0.270, 1 },
      highlight = { 0.950, 0.730, 0.270, 1 },
      text = { 0.930, 0.935, 0.940, 1 },
      muted = { 0.630, 0.680, 0.720, 1 },
    },
  },
  workshop = {
    label = "Workshop",
    colors = {
      background = { 0.035, 0.034, 0.030, 0.99 },
      header = { 0.072, 0.061, 0.045, 0.99 },
      panel = { 0.095, 0.083, 0.064, 0.99 },
      row = { 0.145, 0.125, 0.092, 0.98 },
      hover = { 0.185, 0.158, 0.110, 0.98 },
      border = { 0.325, 0.235, 0.125, 1 },
      accent = { 0.930, 0.610, 0.190, 1 },
      highlight = { 0.930, 0.610, 0.190, 1 },
      text = { 0.945, 0.920, 0.865, 1 },
      muted = { 0.710, 0.670, 0.590, 1 },
    },
  },
  arcane = {
    label = "Arcane",
    colors = {
      background = { 0.025, 0.026, 0.045, 0.99 },
      header = { 0.040, 0.042, 0.078, 0.99 },
      panel = { 0.060, 0.062, 0.100, 0.99 },
      row = { 0.095, 0.092, 0.145, 0.98 },
      hover = { 0.135, 0.130, 0.190, 0.98 },
      border = { 0.250, 0.255, 0.430, 1 },
      accent = { 0.525, 0.780, 1.000, 1 },
      highlight = { 0.525, 0.780, 1.000, 1 },
      text = { 0.900, 0.930, 0.975, 1 },
      muted = { 0.610, 0.670, 0.780, 1 },
    },
  },
}

local ORDER = { "classic", "gallery", "workshop", "arcane" }

function Theme:GetCurrentKey()
  local profile = NS.Systems.Database and NS.Systems.Database:GetProfile()
  local key = profile and profile.ui and profile.ui.designPreset or "gallery"
  return PRESETS[key] and key or "gallery"
end

function Theme:GetColors()
  return PRESETS[self:GetCurrentKey()].colors
end

function Theme:GetDesignPresetLabel(key)
  local preset = PRESETS[key or self:GetCurrentKey()]
  return preset and preset.label or PRESETS.gallery.label
end

function Theme:SetDesignPreset(key)
  local profile = NS.Systems.Database and NS.Systems.Database:GetProfile()
  if not profile then return end
  profile.ui = profile.ui or {}
  profile.ui.designPreset = PRESETS[key] and key or "gallery"
  profile.ui.appearance = profile.ui.appearance or { font = "Game Default", fontScale = 1, colors = {} }
  profile.ui.appearance.colors = {}
  if NS.UI.Controls then NS.UI.Controls:ApplyAppearance() end
  if NS.SendMessage then NS.SendMessage("HOMEDECOR_THEME_UPDATED", profile.ui.designPreset) end
end

function Theme:CycleDesignPreset()
  local current = self:GetCurrentKey()
  local nextKey = ORDER[1]
  for index = 1, #ORDER do
    if ORDER[index] == current then
      nextKey = ORDER[(index % #ORDER) + 1]
      break
    end
  end
  self:SetDesignPreset(nextKey)
  return nextKey
end
