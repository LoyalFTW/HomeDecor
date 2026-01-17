local ADDON, NS = ...

NS.UI = NS.UI or {}

NS.UI.Theme = {
  colors = {
    bg          = { 0.045, 0.045, 0.05, 1 },
    header      = { 0.075, 0.075, 0.085, 1 },
    panel       = { 0.095, 0.095, 0.11, 1 },
    row         = { 0.13, 0.13, 0.15, 1 },
    hover       = { 0.17, 0.17, 0.20, 1 },
    border      = { 0.24, 0.24, 0.28, 1 },

    accent      = { 0.90, 0.72, 0.18, 1 },
    accentSoft  = { 0.90, 0.72, 0.18, 0.28 },

    text        = { 0.92, 0.92, 0.92, 1 },
    textMuted   = { 0.65, 0.65, 0.68, 1 },
    placeholder = { 0.52, 0.52, 0.55, 1 },

    success     = { 0.30, 0.80, 0.40, 1 },
    warning     = { 0.85, 0.55, 0.22, 1 },
    danger      = { 0.80, 0.28, 0.28, 1 },
  },
}

return NS.UI.Theme
