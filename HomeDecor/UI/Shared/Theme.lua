local ADDON, NS = ...

NS.UI = NS.UI or {}
local MEDIA_DEFAULT_TOKEN = "__HOMEDECOR_DEFAULT__"

local function getSharedMedia()
  return LibStub and LibStub("LibSharedMedia-3.0", true)
end

local defaults = {
    bg          = { 0.045, 0.045, 0.05, 1 },
    header      = { 0.075, 0.075, 0.085, 1 },
    panel       = { 0.095, 0.095, 0.11, 1 },
    row         = { 0.13, 0.13, 0.15, 1 },
    hover       = { 0.17, 0.17, 0.20, 1 },
    border      = { 0.24, 0.24, 0.28, 1 },

    accent      = { 0.90, 0.72, 0.18, 1 },
    accentSoft  = { 0.90, 0.72, 0.18, 0.28 },
    accentBright= { 1, 0.95, 0.6, 1 },
    accentDark  = { 0.28, 0.24, 0.10, 1 },

    text        = { 0.92, 0.92, 0.92, 1 },
    highlight   = { 0.90, 0.72, 0.18, 1 },
    textMuted   = { 0.65, 0.65, 0.68, 1 },
    placeholder = { 0.52, 0.52, 0.55, 1 },

    success     = { 0.30, 0.80, 0.40, 1 },
    successDark = { 0.18, 0.50, 0.24, 1 },
    warning     = { 0.85, 0.55, 0.22, 1 },
    danger      = { 0.80, 0.28, 0.28, 1 },

    rowBG       = { 0.05, 0.07, 0.09, 0.55 },
    counterBG   = { 0.05, 0.08, 0.12, 0.85 },
    progressBG  = { 0.04, 0.04, 0.05, 0.95 },
    iconBG      = { 0.08, 0.08, 0.10, 0.8 },

    grayDark    = { 0.18, 0.18, 0.20, 1 },
    grayLight   = { 0.45, 0.45, 0.48, 1 },
}

local DESIGN_PRESETS = {
  classic = {
    label = "Classic",
    colors = {},
  },
  gallery = {
    label = "Gallery",
    colors = {
      bg = { 0.025, 0.030, 0.034, 1 },
      header = { 0.040, 0.046, 0.052, 1 },
      panel = { 0.060, 0.067, 0.075, 1 },
      row = { 0.095, 0.105, 0.118, 1 },
      hover = { 0.140, 0.155, 0.170, 1 },
      border = { 0.280, 0.245, 0.165, 1 },
      accent = { 0.950, 0.730, 0.270, 1 },
      text = { 0.930, 0.935, 0.940, 1 },
      textMuted = { 0.630, 0.680, 0.720, 1 },
      placeholder = { 0.520, 0.570, 0.610, 1 },
      rowBG = { 0.035, 0.045, 0.052, 0.72 },
      counterBG = { 0.040, 0.055, 0.066, 0.90 },
      iconBG = { 0.055, 0.060, 0.070, 0.88 },
    },
  },
  workshop = {
    label = "Workshop",
    colors = {
      bg = { 0.035, 0.034, 0.030, 1 },
      header = { 0.072, 0.061, 0.045, 1 },
      panel = { 0.095, 0.083, 0.064, 1 },
      row = { 0.145, 0.125, 0.092, 1 },
      hover = { 0.185, 0.158, 0.110, 1 },
      border = { 0.325, 0.235, 0.125, 1 },
      accent = { 0.930, 0.610, 0.190, 1 },
      text = { 0.945, 0.920, 0.865, 1 },
      textMuted = { 0.710, 0.670, 0.590, 1 },
      placeholder = { 0.570, 0.530, 0.465, 1 },
      rowBG = { 0.075, 0.058, 0.040, 0.62 },
      counterBG = { 0.090, 0.064, 0.038, 0.88 },
      iconBG = { 0.105, 0.082, 0.058, 0.86 },
    },
  },
  arcane = {
    label = "Arcane",
    colors = {
      bg = { 0.025, 0.026, 0.045, 1 },
      header = { 0.040, 0.042, 0.078, 1 },
      panel = { 0.060, 0.062, 0.100, 1 },
      row = { 0.095, 0.092, 0.145, 1 },
      hover = { 0.135, 0.130, 0.190, 1 },
      border = { 0.250, 0.255, 0.430, 1 },
      accent = { 0.525, 0.780, 1.000, 1 },
      text = { 0.900, 0.930, 0.975, 1 },
      textMuted = { 0.610, 0.670, 0.780, 1 },
      placeholder = { 0.485, 0.535, 0.650, 1 },
      rowBG = { 0.035, 0.040, 0.075, 0.65 },
      counterBG = { 0.035, 0.045, 0.090, 0.88 },
      iconBG = { 0.050, 0.052, 0.088, 0.86 },
    },
  },
}

local DESIGN_ORDER = { "classic", "gallery", "workshop", "arcane" }

local Theme = {
  colors = {},
  defaults = defaults,
  designPresets = DESIGN_PRESETS,
  designOrder = DESIGN_ORDER,
  MEDIA_DEFAULT_TOKEN = MEDIA_DEFAULT_TOKEN,

  textures = {
    Logo = "Interface\\AddOns\\HomeDecor\\Media\\UI\\logo.tga",
  },
}

local function copyInto(target, source)
  target[1] = source[1]
  target[2] = source[2]
  target[3] = source[3]
  target[4] = source[4] or 1
end

local function appearance()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.ui = profile.ui or {}
  profile.ui.appearance = profile.ui.appearance or {
    fontMedia = MEDIA_DEFAULT_TOKEN,
    fontMediaPath = nil,
    fontScale = 1.0,
    colors = {},
  }
  if profile.ui.appearance.fontMedia == nil then
    local legacy = profile.ui.appearance.font
    local migrate = {
      friz = "builtin:friz",
      arial = "builtin:arial",
      morpheus = "builtin:morpheus",
      skurri = "builtin:skurri",
    }
    profile.ui.appearance.fontMedia = migrate[legacy] or MEDIA_DEFAULT_TOKEN
  end
  profile.ui.appearance.colors = profile.ui.appearance.colors or {}
  return profile.ui.appearance
end

local function getUIOptions()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end
  profile.ui = profile.ui or {}
  if not profile.ui.designPreset then profile.ui.designPreset = "gallery" end
  return profile.ui
end

local BUILTIN_FONTS = {
  { text = "Game Default", value = MEDIA_DEFAULT_TOKEN },
  { text = "Friz Quadrata", value = "builtin:friz", path = "Fonts\\FRIZQT__.TTF" },
  { text = "Arial Narrow", value = "builtin:arial", path = "Fonts\\ARIALN.TTF" },
  { text = "Morpheus", value = "builtin:morpheus", path = "Fonts\\MORPHEUS.TTF" },
  { text = "Skurri", value = "builtin:skurri", path = "Fonts\\SKURRI.TTF" },
}

local SCRIPT_FONTS = {
  koKR = "Fonts\\2002.TTF",
  zhCN = "Fonts\\ARKai_T.ttf",
  zhTW = "Fonts\\blei00d.ttf",
  ruRU = "Fonts\\FRIZQT___CYR.TTF",
}

local SCRIPT_RANGES = {
  { 0x0400, 0x04FF, "ruRU" },
  { 0x1100, 0x11FF, "koKR" },
  { 0x3130, 0x318F, "koKR" },
  { 0x3400, 0x4DBF, nil },
  { 0x4E00, 0x9FFF, nil },
  { 0xAC00, 0xD7AF, "koKR" },
  { 0xF900, 0xFAFF, nil },
}

function Theme:GetDefaultFont()
  if type(STANDARD_TEXT_FONT) == "string" and STANDARD_TEXT_FONT ~= "" then
    return STANDARD_TEXT_FONT
  end
  local locale = GetLocale and GetLocale() or ""
  return SCRIPT_FONTS[locale] or "Fonts\\FRIZQT__.TTF"
end

function Theme:GetFontOptions()
  local options = {}
  local seen = {}
  for _, entry in ipairs(BUILTIN_FONTS) do
    options[#options + 1] = { text = entry.text, value = entry.value }
    seen[entry.text] = true
  end
  local LSM = getSharedMedia()
  if LSM then
    local mediaType = (LSM.MediaType and LSM.MediaType.FONT) or "font"
    for _, name in ipairs(LSM:List(mediaType) or {}) do
      if type(name) == "string" and name ~= "" and not seen[name] then
        options[#options + 1] = { text = name, value = "lsm:" .. name }
        seen[name] = true
      end
    end
  end
  return options
end

function Theme:SetFont(value)
  local opts = appearance()
  if not opts then return end
  opts.fontMedia = value or MEDIA_DEFAULT_TOKEN
  opts.fontMediaPath = nil
  for _, entry in ipairs(BUILTIN_FONTS) do
    if entry.value == opts.fontMedia then
      opts.fontMediaPath = entry.path
      return
    end
  end
  local LSM = getSharedMedia()
  if LSM and type(opts.fontMedia) == "string" and opts.fontMedia:sub(1, 4) == "lsm:" then
    local mediaType = (LSM.MediaType and LSM.MediaType.FONT) or "font"
    opts.fontMediaPath = LSM:Fetch(mediaType, opts.fontMedia:sub(5), true)
  end
end

function Theme:GetFontPath()
  local opts = appearance()
  if not opts or opts.fontMedia == MEDIA_DEFAULT_TOKEN then
    return self:GetDefaultFont()
  end
  if type(opts.fontMediaPath) == "string" and opts.fontMediaPath ~= "" then
    return opts.fontMediaPath
  end
  self:SetFont(opts.fontMedia)
  return opts.fontMediaPath or self:GetDefaultFont()
end

local function detectScriptFont(text)
  if type(text) ~= "string" or text == "" then return nil end
  local locale = GetLocale and GetLocale() or ""
  if not utf8 or not utf8.codes then
    if text:find("[\128-\255]") then
      return SCRIPT_FONTS[locale]
    end
    return nil
  end
  for _, point in utf8.codes(text) do
    for _, range in ipairs(SCRIPT_RANGES) do
      if point >= range[1] and point <= range[2] then
        if range[3] then return SCRIPT_FONTS[range[3]] end
        return locale == "zhTW" and SCRIPT_FONTS.zhTW or SCRIPT_FONTS.zhCN
      end
    end
  end
end

function Theme:ResolveFontForText(text)
  local custom = self:GetFontPath()
  local scriptFont = detectScriptFont(text)
  return scriptFont or custom
end

function Theme:ApplyProfile()
  local opts = appearance()
  local saved = opts and opts.colors or {}
  local ui = getUIOptions()
  local preset = ui and DESIGN_PRESETS[ui.designPreset or "classic"]
  local presetColors = preset and preset.colors or nil

  for key, base in pairs(defaults) do
    self.colors[key] = self.colors[key] or {}
    copyInto(self.colors[key], saved[key] or (presetColors and presetColors[key]) or base)
  end

  local accent = saved.accent or (presetColors and presetColors.accent)
  if accent then
    copyInto(self.colors.accentSoft, { accent[1], accent[2], accent[3], 0.28 })
    copyInto(self.colors.accentBright, {
      math.min(1, accent[1] + 0.10),
      math.min(1, accent[2] + 0.16),
      math.min(1, accent[3] + 0.22),
      1,
    })
    copyInto(self.colors.accentDark, {
      accent[1] * 0.31,
      accent[2] * 0.33,
      accent[3] * 0.56,
      1,
    })
  end

  local bg = saved.bg
  if bg and not saved.header then
    copyInto(self.colors.header, {
      math.min(1, bg[1] + 0.03),
      math.min(1, bg[2] + 0.03),
      math.min(1, bg[3] + 0.035),
      1,
    })
  end
end

function Theme:GetDesignPresetLabel(key)
  local preset = DESIGN_PRESETS[key or (getUIOptions() and getUIOptions().designPreset) or "classic"]
  return preset and preset.label or "Classic"
end

function Theme:SetDesignPreset(key)
  local ui = getUIOptions()
  if not ui then return end
  ui.designPreset = DESIGN_PRESETS[key] and key or "classic"
  self:ApplyProfile()
end

function Theme:CycleDesignPreset()
  local ui = getUIOptions()
  if not ui then return "classic" end
  local cur = ui.designPreset or "classic"
  local nextKey = DESIGN_ORDER[1]
  for i = 1, #DESIGN_ORDER do
    if DESIGN_ORDER[i] == cur then
      nextKey = DESIGN_ORDER[(i % #DESIGN_ORDER) + 1]
      break
    end
  end
  self:SetDesignPreset(nextKey)
  return nextKey
end

function Theme:SetColor(key, r, g, b)
  local opts = appearance()
  if not opts or not defaults[key] then return end
  opts.colors[key] = { r, g, b, defaults[key][4] or 1 }
  self:ApplyProfile()
end

function Theme:ResetAppearance()
  local opts = appearance()
  if not opts then return end
  opts.fontMedia = MEDIA_DEFAULT_TOKEN
  opts.fontMediaPath = nil
  opts.fontScale = 1.0
  opts.colors = {}
  self:ApplyProfile()
end

Theme:ApplyProfile()
NS.UI.Theme = Theme

return Theme
