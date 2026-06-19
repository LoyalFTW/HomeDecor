local ADDON, NS = ...

NS.UI = NS.UI or {}
NS.UI.Architect = NS.UI.Architect or {}

local UIA = NS.UI.Architect

local CreateFrame = CreateFrame
local floor = math.floor
local max = math.max
local min = math.min
local abs = math.abs

local function A()
  return NS.Systems and NS.Systems.Architect
end

local function Theme()
  return (NS.UI.Theme and NS.UI.Theme.colors) or {}
end

local function Controls()
  return NS.UI.Controls
end

local function DropdownWidget()
  return NS.UI and NS.UI.Dropdown
end

local function Backdrop(frame, bg, border)
  local C = Controls()
  if C and C.Backdrop then C:Backdrop(frame, bg, border) end
end

local function Hover(frame, bg, hover)
  local C = Controls()
  if C and C.ApplyHover then C:ApplyHover(frame, bg, hover) end
end

local function TextColor(fs, role, alpha)
  local C = Controls()
  if C and C.TextColor then C:TextColor(fs, role, alpha) end
end

local function FS(parent, template)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  TextColor(fs, "text")
  return fs
end

local function Button(parent, label, width)
  local T = Theme()
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(width or 76, 24)
  Backdrop(b, T.panel, T.border)
  Hover(b, T.panel, T.hover)
  b.text = FS(b, "GameFontNormalSmall")
  b.text:SetPoint("CENTER")
  b.text:SetText(label or "")
  return b
end

local function EditBox(parent)
  local T = Theme()
  local e = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
  Backdrop(e, T.row or T.panel, T.border)
  e:SetAutoFocus(false)
  e:SetFontObject(GameFontHighlightSmall)
  e:SetTextInsets(7, 7, 0, 0)
  e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  return e
end

local function SetBar(bar, used, limit)
  limit = max(1, tonumber(limit) or 1)
  used = tonumber(used) or 0
  local pct = min(1, used / limit)
  bar.fill:SetWidth(max(1, (bar:GetWidth() or 1) * pct))
  if used > limit then
    bar.fill:SetColorTexture(0.90, 0.18, 0.14, 0.95)
  elseif pct > 0.85 then
    bar.fill:SetColorTexture(0.95, 0.60, 0.18, 0.95)
  else
    bar.fill:SetColorTexture(0.08, 0.82, 0.76, 0.95)
  end
end

local function MakeBar(parent)
  local T = Theme()
  local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  f:SetHeight(8)
  Backdrop(f, T.row or T.panel, T.border)
  f.fill = f:CreateTexture(nil, "ARTWORK")
  f.fill:SetPoint("LEFT", 0, 0)
  f.fill:SetHeight(8)
  f:SetScript("OnSizeChanged", function(self)
    if self._used then SetBar(self, self._used, self._limit) end
  end)
  return f
end

local ROOM_BLUE = { 0.30, 0.62, 1.00, 0.95 }
local ROOM_BLUE_SOFT = { 0.12, 0.32, 0.58, 0.38 }
local GOLD = { 1.00, 0.76, 0.28, 1.00 }
local OPPOSITE = { N = "S", S = "N", E = "W", W = "E" }

local function RoomFloor(room)
  return (room and room.capture and tonumber(room.capture.floor)) or tonumber(room and room.floor) or 1
end

local function ShapeRects(shape)
  if shape == "entry" then
    return { { 0.26, 0.42, 0.48, 0.46 }, { 0.38, 0.24, 0.24, 0.24 } }
  elseif shape == "hall" then
    return { { 0.32, 0.04, 0.36, 0.92 } }
  elseif shape == "lLeft" then
    return { { 0.00, 0.00, 0.44, 1.00 }, { 0.00, 0.56, 1.00, 0.44 } }
  elseif shape == "lRight" then
    return { { 0.56, 0.00, 0.44, 1.00 }, { 0.00, 0.56, 1.00, 0.44 } }
  elseif shape == "t" then
    return { { 0.00, 0.00, 1.00, 0.36 }, { 0.34, 0.00, 0.32, 1.00 } }
  elseif shape == "cross" then
    return { { 0.34, 0.00, 0.32, 1.00 }, { 0.00, 0.34, 1.00, 0.32 } }
  elseif shape == "stair" then
    return { { 0.12, 0.10, 0.76, 0.22 }, { 0.12, 0.39, 0.76, 0.22 }, { 0.12, 0.68, 0.76, 0.22 } }
  elseif shape == "stairLeft" then
    return { { 0.10, 0.10, 0.78, 0.24 }, { 0.10, 0.38, 0.58, 0.23 }, { 0.10, 0.65, 0.38, 0.25 } }
  elseif shape == "stairRight" then
    return { { 0.12, 0.10, 0.78, 0.24 }, { 0.32, 0.38, 0.58, 0.23 }, { 0.52, 0.65, 0.38, 0.25 } }
  elseif shape == "octagon" then
    return { { 0.25, 0.00, 0.50, 0.18 }, { 0.07, 0.18, 0.86, 0.64 }, { 0.25, 0.82, 0.50, 0.18 } }
  elseif shape == "gardenDay" or shape == "gardenEve" then
    return { { 0.13, 0.08, 0.74, 0.84 }, { 0.05, 0.24, 0.90, 0.52 } }
  end
  return { { 0.00, 0.00, 1.00, 1.00 } }
end

local function EnsureTexture(parent, pool, i, layer)
  local tex = pool[i]
  if not tex then
    tex = parent:CreateTexture(nil, layer or "ARTWORK", nil, 2)
    pool[i] = tex
  end
  tex:ClearAllPoints()
  tex:SetTexture("Interface\\Buttons\\WHITE8x8")
  tex:Show()
  return tex
end

local function AngleBetween(dx, dy)
  if dx == 0 then
    return dy >= 0 and (math.pi / 2) or -(math.pi / 2)
  end
  local a = math.atan(dy / dx)
  if dx < 0 then a = a + math.pi end
  return a
end

local function DrawLine(parent, pool, i, x1, y1, x2, y2, thickness, r, g, b, a)
  local line = EnsureTexture(parent, pool, i, "OVERLAY")
  local dx, dy = x2 - x1, y2 - y1
  local length = math.sqrt(dx * dx + dy * dy)
  line:SetSize(max(1, length), thickness or 2)
  line:SetPoint("CENTER", parent, "TOPLEFT", (x1 + x2) / 2, -((y1 + y2) / 2))
  line:SetColorTexture(r, g, b, a)
  if line.SetRotation then
    line:SetRotation(AngleBetween(dx, dy))
  end
  return line
end

local function DrawHLine(parent, pool, i, x, y, width, thickness, r, g, b, a)
  local line = EnsureTexture(parent, pool, i, "OVERLAY")
  line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
  line:SetSize(max(1, width), thickness or 2)
  line:SetColorTexture(r, g, b, a)
  if line.SetRotation then line:SetRotation(0) end
  return line
end

local function DrawVLine(parent, pool, i, x, y, height, thickness, r, g, b, a)
  local line = EnsureTexture(parent, pool, i, "OVERLAY")
  line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
  line:SetSize(thickness or 2, max(1, height))
  line:SetColorTexture(r, g, b, a)
  if line.SetRotation then line:SetRotation(0) end
  return line
end

local function HideTexturePool(pool)
  for _, tex in pairs(pool or {}) do
    if tex and tex.Hide then tex:Hide() end
  end
end

local function DrawDiag45(parent, pool, i, x, y, len, downRight, thickness, r, g, b, a)
  local steps = max(6, floor(len / 3))
  local step = len / steps
  for s = 1, steps do
    local dot = EnsureTexture(parent, pool, (i * 100) + s, "OVERLAY")
    local px = x + (s - 0.5) * step
    local py
    if downRight then
      py = y + (s - 0.5) * step
    else
      py = y + len - (s - 0.5) * step
    end
    dot:SetPoint("CENTER", parent, "TOPLEFT", px, -py)
    dot:SetSize(thickness or 2, thickness or 2)
    dot:SetColorTexture(r, g, b, a)
    if dot.SetRotation then dot:SetRotation(0) end
  end
end

local function ShapeOutlinePoints(shape, w, h)
  if shape == "lRight" then
    return {
      { 0.00 * w, 0.56 * h }, { 0.56 * w, 0.56 * h }, { 0.56 * w, 0.00 * h },
      { 1.00 * w, 0.00 * h }, { 1.00 * w, 1.00 * h }, { 0.00 * w, 1.00 * h },
    }
  elseif shape == "lLeft" then
    return {
      { 0.00 * w, 0.00 * h }, { 0.44 * w, 0.00 * h }, { 0.44 * w, 0.56 * h },
      { 1.00 * w, 0.56 * h }, { 1.00 * w, 1.00 * h }, { 0.00 * w, 1.00 * h },
    }
  elseif shape == "t" then
    return {
      { 0.00 * w, 0.00 * h }, { 1.00 * w, 0.00 * h }, { 1.00 * w, 0.36 * h },
      { 0.66 * w, 0.36 * h }, { 0.66 * w, 1.00 * h }, { 0.34 * w, 1.00 * h },
      { 0.34 * w, 0.36 * h }, { 0.00 * w, 0.36 * h },
    }
  elseif shape == "cross" then
    return {
      { 0.34 * w, 0.00 * h }, { 0.66 * w, 0.00 * h }, { 0.66 * w, 0.34 * h },
      { 1.00 * w, 0.34 * h }, { 1.00 * w, 0.66 * h }, { 0.66 * w, 0.66 * h },
      { 0.66 * w, 1.00 * h }, { 0.34 * w, 1.00 * h }, { 0.34 * w, 0.66 * h },
      { 0.00 * w, 0.66 * h }, { 0.00 * w, 0.34 * h }, { 0.34 * w, 0.34 * h },
    }
  end
end

local function DrawGrid(parent, pool, cols, rows, heavyEvery, alpha)
  pool.lines = pool.lines or {}
  for _, line in ipairs(pool.lines) do line:Hide() end
  local idx = 1
  local w, h = parent:GetWidth() or 1, parent:GetHeight() or 1
  for x = 1, cols - 1 do
    local line = EnsureTexture(parent, pool.lines, idx, "BACKGROUND")
    idx = idx + 1
    line:SetWidth(1)
    line:SetPoint("TOP", parent, "TOPLEFT", w * x / cols, 0)
    line:SetPoint("BOTTOM", parent, "BOTTOMLEFT", w * x / cols, 0)
    line:SetColorTexture(0.25, 0.38, 0.55, (x % heavyEvery == 0) and (alpha * 1.8) or alpha)
  end
  for y = 1, rows - 1 do
    local line = EnsureTexture(parent, pool.lines, idx, "BACKGROUND")
    idx = idx + 1
    line:SetHeight(1)
    line:SetPoint("LEFT", parent, "TOPLEFT", 0, -h * y / rows)
    line:SetPoint("RIGHT", parent, "TOPRIGHT", 0, -h * y / rows)
    line:SetColorTexture(0.25, 0.38, 0.55, (y % heavyEvery == 0) and (alpha * 1.8) or alpha)
  end
end

local function DrawShape(parent, roomOrTemplate, pool, selected, scaleGlow)
  pool.pieces = pool.pieces or {}
  pool.outline = pool.outline or {}
  pool.lines = pool.lines or {}
  HideTexturePool(pool.pieces)
  HideTexturePool(pool.outline)
  HideTexturePool(pool.lines)
  if pool.garden then pool.garden:Hide() end

  local shape = (roomOrTemplate and roomOrTemplate.shape) or "rect"
  local art = roomOrTemplate and roomOrTemplate.art
  local rects = ShapeRects(shape)
  local w, h = parent:GetWidth() or 1, parent:GetHeight() or 1

  if shape == "hall" then
    if pool.art then pool.art:Hide() end
    local alpha = selected and 0.72 or 0.52
    local edgeAlpha = selected and 0.98 or 0.80
    local thick = selected and 3 or 2
    local horizontal = w >= h
    local bodyW = horizontal and (w * 0.86) or (w * 0.42)
    local bodyH = horizontal and (h * 0.42) or (h * 0.86)
    local bx = (w - bodyW) / 2
    local by = (h - bodyH) / 2
    local fill = EnsureTexture(parent, pool.pieces, 1, "ARTWORK")
    fill:SetPoint("TOPLEFT", parent, "TOPLEFT", bx, -by)
    fill:SetSize(max(1, bodyW), max(1, bodyH))
    fill:SetColorTexture(ROOM_BLUE_SOFT[1], ROOM_BLUE_SOFT[2], ROOM_BLUE_SOFT[3], alpha)

    DrawHLine(parent, pool.lines, 1, bx, by, bodyW, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha)
    DrawHLine(parent, pool.lines, 2, bx, by + bodyH - thick, bodyW, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha)
    DrawVLine(parent, pool.lines, 3, bx, by, bodyH, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha)
    DrawVLine(parent, pool.lines, 4, bx + bodyW - thick, by, bodyH, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha)

    local stripeCount = horizontal and 5 or 7
    for i = 1, stripeCount do
      local t = i / (stripeCount + 1)
      if horizontal then
        DrawVLine(parent, pool.lines, 4 + i, bx + (bodyW * t), by + 3, max(1, bodyH - 6), 1, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha * 0.22)
      else
        DrawHLine(parent, pool.lines, 4 + i, bx + 3, by + (bodyH * t), max(1, bodyW - 6), 1, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], edgeAlpha * 0.22)
      end
    end
    return
  end

  if art and art ~= "" then
    pool.art = pool.art or parent:CreateTexture(nil, "ARTWORK", nil, 3)
    pool.art:ClearAllPoints()
    pool.art:SetPoint("CENTER", parent, "CENTER")
    local size = min(w, h) * (scaleGlow or 0.96)
    if shape == "hall" then
      if w >= h then
        pool.art:SetSize(w * 0.96, min(h * 0.92, size))
      else
        pool.art:SetSize(min(w * 0.92, size), h * 0.96)
      end
    elseif shape == "closet" then
      pool.art:SetSize(w * 0.92, min(h * 0.92, size))
    else
      pool.art:SetSize(size, size)
    end
    pool.art:SetTexture(art)
    pool.art:SetTexCoord(0, 1, 0, 1)
    pool.art:SetAlpha(selected and 1.0 or 0.88)
    if pool.art.SetRotation then
      pool.art:SetRotation(math.rad(tonumber(roomOrTemplate.rotation) or 0))
    end
    pool.art:Show()
    return
  elseif pool.art then
    pool.art:Hide()
  end

  if shape == "gardenDay" or shape == "gardenEve" then
    local size = min(w, h) * 0.96
    local ox = (w - size) / 2
    local oy = (h - size) / 2
    local bands = { 0.46, 0.74, 0.92, 1.00, 1.00, 0.92, 0.74, 0.46 }
    local bandH = size / #bands
    local alpha = selected and 0.74 or 0.56

    for i, pct in ipairs(bands) do
      local bw = size * pct
      local bx = ox + (size - bw) / 2
      local by = oy + (i - 1) * bandH
      local fill = EnsureTexture(parent, pool.pieces, i, "ARTWORK")
      fill:SetPoint("TOPLEFT", parent, "TOPLEFT", bx, -by)
      fill:SetSize(max(1, bw), max(1, bandH + 1))
      if shape == "gardenDay" then
        fill:SetColorTexture(0.24, 0.56, 0.82, alpha)
      else
        fill:SetColorTexture(0.06, 0.20, 0.42, alpha)
      end
    end

    pool.garden = pool.garden or parent:CreateTexture(nil, "OVERLAY", nil, 2)
    pool.garden:SetTexture(shape == "gardenDay" and "Interface\\Icons\\Spell_Nature_Sun" or "Interface\\Icons\\INV_Misc_Moonstone_01")
    pool.garden:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    pool.garden:SetPoint("CENTER", parent, "CENTER")
    pool.garden:SetSize(size * 0.68, size * 0.68)
    pool.garden:SetAlpha(selected and 0.62 or 0.46)
    pool.garden:Show()

    local thick = selected and 3 or 2
    local edgeAlpha = selected and 0.94 or 0.76
    for i, pct in ipairs(bands) do
      local bw = size * pct
      local bx = ox + (size - bw) / 2
      local by = oy + (i - 1) * bandH
      local lineAlpha = (i == 1 or i == #bands) and edgeAlpha or (edgeAlpha * 0.35)
      DrawHLine(parent, pool.lines, i, bx, by, bw, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], lineAlpha)
    end
    return
  end

  if shape == "octagon" then
    local size = min(w, h) * 0.96
    local ox = (w - size) / 2
    local oy = (h - size) / 2
    local cut = size * 0.25
    local fillRects = {
      { ox + cut, oy, size - (cut * 2), cut },
      { ox, oy + cut, size, size - (cut * 2) },
      { ox + cut, oy + size - cut, size - (cut * 2), cut },
    }
    for i, rect in ipairs(fillRects) do
      local fill = EnsureTexture(parent, pool.pieces, i, "ARTWORK")
      fill:SetPoint("TOPLEFT", parent, "TOPLEFT", rect[1], -rect[2])
      fill:SetSize(max(1, rect[3]), max(1, rect[4]))
      fill:SetColorTexture(ROOM_BLUE_SOFT[1], ROOM_BLUE_SOFT[2], ROOM_BLUE_SOFT[3], selected and 0.62 or 0.44)
    end

    local alpha = selected and 0.98 or 0.80
    local thick = selected and 3 or 2
    DrawHLine(parent, pool.lines, 1, ox + cut, oy, size - cut * 2, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawVLine(parent, pool.lines, 2, ox + size - thick, oy + cut, size - cut * 2, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawHLine(parent, pool.lines, 3, ox + cut, oy + size - thick, size - cut * 2, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawVLine(parent, pool.lines, 4, ox, oy + cut, size - cut * 2, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawDiag45(parent, pool.lines, 5, ox + size - cut, oy, cut, true, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawDiag45(parent, pool.lines, 6, ox + size - cut, oy + size - cut, cut, false, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawDiag45(parent, pool.lines, 7, ox, oy + size - cut, cut, true, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    DrawDiag45(parent, pool.lines, 8, ox, oy, cut, false, thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    return
  end

  local outlinePoints = ShapeOutlinePoints(shape, w, h)
  for i, rect in ipairs(rects) do
    local fill = EnsureTexture(parent, pool.pieces, i, "ARTWORK")
    fill:SetPoint("TOPLEFT", parent, "TOPLEFT", rect[1] * w, -rect[2] * h)
    fill:SetSize(max(1, rect[3] * w), max(1, rect[4] * h))
    fill:SetColorTexture(ROOM_BLUE_SOFT[1], ROOM_BLUE_SOFT[2], ROOM_BLUE_SOFT[3], selected and 0.62 or 0.44)

    if outlinePoints then
      -- Composite shapes get one outer silhouette, matching the website-style room cards.
    else
    local left = rect[1] * w
    local top = -rect[2] * h
    local rw = max(1, rect[3] * w)
    local rh = max(1, rect[4] * h)
    local alpha = selected and 0.96 or 0.78
    local base = (i - 1) * 4

    local topLine = EnsureTexture(parent, pool.outline, base + 1, "OVERLAY")
    topLine:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    topLine:SetSize(rw, 2)
    topLine:SetColorTexture(ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)

    local bottomLine = EnsureTexture(parent, pool.outline, base + 2, "OVERLAY")
    bottomLine:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top - rh + 2)
    bottomLine:SetSize(rw, 2)
    bottomLine:SetColorTexture(ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)

    local leftLine = EnsureTexture(parent, pool.outline, base + 3, "OVERLAY")
    leftLine:SetPoint("TOPLEFT", parent, "TOPLEFT", left, top)
    leftLine:SetSize(2, rh)
    leftLine:SetColorTexture(ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)

    local rightLine = EnsureTexture(parent, pool.outline, base + 4, "OVERLAY")
    rightLine:SetPoint("TOPLEFT", parent, "TOPLEFT", left + rw - 2, top)
    rightLine:SetSize(2, rh)
    rightLine:SetColorTexture(ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    end
  end

  if outlinePoints then
    local alpha = selected and 0.98 or 0.80
    local thick = selected and 3 or 2
    local n = #outlinePoints
    for i = 1, n do
      local p1 = outlinePoints[i]
      local p2 = outlinePoints[(i % n) + 1]
      DrawLine(parent, pool.lines, i, p1[1], p1[2], p2[1], p2[2], thick, ROOM_BLUE[1], ROOM_BLUE[2], ROOM_BLUE[3], alpha)
    end
  end

  if shape == "gardenDay" or shape == "gardenEve" then
    pool.garden = pool.garden or parent:CreateTexture(nil, "OVERLAY", nil, 2)
    pool.garden:SetTexture(shape == "gardenDay" and "Interface\\Icons\\Spell_Nature_Sun" or "Interface\\Icons\\INV_Misc_Moonstone_01")
    pool.garden:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    pool.garden:SetPoint("CENTER")
    local size = min(w, h) * (scaleGlow or 0.74)
    pool.garden:SetSize(size, size)
    pool.garden:SetAlpha(selected and 0.55 or 0.40)
    pool.garden:Show()
  end
end

local function ConnectorForDirection(room, dir)
  local sys = A()
  local conns = sys and sys:GetRoomConnections(room) or {}
  for _, conn in ipairs(conns) do
    if conn[3] == dir then return conn end
  end
  return conns[1] or { 0.5, 0.5, dir or "N" }
end

function UIA:Create(parent)
  if self.panel then
    self.panel:SetParent(parent)
    self.panel:ClearAllPoints()
    self.panel:SetAllPoints(parent)
    return self.panel
  end

  local sys = A()
  if not sys then return nil end

  local Dropdown = DropdownWidget()
  local T = Theme()
  local panel = CreateFrame("Frame", "HomeDecorArchitectPanel", parent, "BackdropTemplate")
  self.panel = panel
  panel:SetAllPoints(parent)
  panel:Hide()
  Backdrop(panel, { 0.035, 0.045, 0.065, 0.96 }, T.border)
  panel.roomFrames = {}
  panel.roomCards = {}
  panel.layoutButtons = {}
  panel.changeRows = {}
  panel.searchRows = {}
  panel.selectedRoomID = nil
  panel.selectedTemplateKey = "squareSmall"
  panel.sortMode = "costAsc"
  panel.canvasZoom = 1
  panel.canvasPanX = 36
  panel.canvasPanY = 36
  panel.baseCellSize = 34
  panel.paletteOffset = 0

  local top = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  top:SetPoint("TOPLEFT", 8, -8)
  top:SetPoint("TOPRIGHT", -8, -8)
  top:SetHeight(62)
  Backdrop(top, { 0.055, 0.075, 0.105, 0.98 }, T.border)

  local title = FS(top, "GameFontNormalLarge")
  title:SetPoint("LEFT", 12, 10)
  title:SetText("Floorplan Builder")
  TextColor(title, "accent")

  local subtitle = FS(top, "GameFontNormalSmall")
  subtitle:SetPoint("LEFT", title, "RIGHT", 12, 0)
  subtitle:SetText("Design your house by snapping rooms together")
  TextColor(subtitle, "textMuted")

  local budgetText = FS(top, "GameFontNormalSmall")
  budgetText:SetPoint("RIGHT", top, "RIGHT", -12, 10)
  budgetText:SetJustifyH("RIGHT")
  TextColor(budgetText, "textMuted")
  panel.budgetText = budgetText

  local budgetBar = MakeBar(top)
  budgetBar:SetPoint("BOTTOMRIGHT", top, "BOTTOMRIGHT", -12, 9)
  budgetBar:SetWidth(210)
  panel.budgetBar = budgetBar

  local captureStatus = FS(top, "GameFontNormalSmall")
  captureStatus:SetPoint("RIGHT", budgetText, "LEFT", -12, 0)
  captureStatus:SetWidth(260)
  captureStatus:SetJustifyH("RIGHT")
  TextColor(captureStatus, "textMuted")
  panel.captureStatus = captureStatus

  local left = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  left:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 8, 8)
  left:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -302, 8)
  left:SetHeight(116)
  Backdrop(left, { 0.045, 0.060, 0.085, 0.98 }, T.border)

  local leftHeader = CreateFrame("Frame", nil, left)
  leftHeader:SetPoint("TOPLEFT", 8, -8)
  leftHeader:SetPoint("TOPRIGHT", -8, -8)
  leftHeader:SetHeight(26)

  local sortLabel = FS(leftHeader, "GameFontNormalSmall")
  sortLabel:SetPoint("LEFT", 0, 0)
  sortLabel:SetText("Sort by:")
  TextColor(sortLabel, "textMuted")

  local sortButton = Button(leftHeader, "Cost (Low to High)", 150)
  sortButton:SetPoint("LEFT", sortLabel, "RIGHT", 6, 0)
  panel.sortButton = sortButton

  local roomsCount = FS(leftHeader, "GameFontNormalSmall")
  roomsCount:SetPoint("RIGHT", 0, 0)
  roomsCount:SetJustifyH("RIGHT")
  TextColor(roomsCount, "textMuted")
  panel.roomsCount = roomsCount

  local nextPalette = Button(leftHeader, ">", 26)
  nextPalette:SetPoint("RIGHT", roomsCount, "LEFT", -8, 0)
  local prevPalette = Button(leftHeader, "<", 26)
  prevPalette:SetPoint("RIGHT", nextPalette, "LEFT", -4, 0)

  local paletteHint = FS(leftHeader, "GameFontNormalSmall")
  paletteHint:SetPoint("LEFT", sortButton, "RIGHT", 14, 0)
  paletteHint:SetPoint("RIGHT", prevPalette, "LEFT", -14, 0)
  paletteHint:SetJustifyH("CENTER")
  paletteHint:SetText("Drag and drop rooms onto the grid.")
  TextColor(paletteHint, "textMuted")

  local paletteScroll = CreateFrame("Frame", nil, left)
  paletteScroll:SetPoint("TOPLEFT", leftHeader, "BOTTOMLEFT", 0, -6)
  paletteScroll:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 8)
  paletteScroll:EnableMouse(true)
  if paletteScroll.SetClipsChildren then paletteScroll:SetClipsChildren(true) end
  if paletteScroll.EnableMouseWheel then paletteScroll:EnableMouseWheel(true) end

  local paletteContent = CreateFrame("Frame", nil, paletteScroll)
  paletteContent:SetSize(1, 82)
  paletteContent:EnableMouse(true)
  local paletteEdgePad = 16
  local function paletteMaxOffset()
    local viewW = paletteScroll:GetWidth() or 1
    local contentW = paletteContent:GetWidth() or 1
    return max(0, contentW - viewW)
  end
  local function applyPaletteOffset()
    local maxOffset = paletteMaxOffset()
    panel.paletteOffset = max(0, min(maxOffset, panel.paletteOffset or 0))
    paletteContent:ClearAllPoints()
    if paletteScroll.SetHorizontalScroll then
      paletteContent:SetPoint("TOPLEFT", paletteScroll, "TOPLEFT", 0, 0)
      paletteScroll:SetHorizontalScroll(panel.paletteOffset or 0)
      if paletteScroll.SetVerticalScroll then paletteScroll:SetVerticalScroll(0) end
    else
      paletteContent:SetPoint("TOPLEFT", paletteScroll, "TOPLEFT", -(panel.paletteOffset or 0), 0)
    end
    paletteContent:SetHeight(max(1, paletteScroll:GetHeight() or 82))
    if prevPalette.text then prevPalette.text:SetTextColor(1, 1, 1, (panel.paletteOffset or 0) <= 0 and 0.35 or 1) end
    if nextPalette.text then nextPalette.text:SetTextColor(1, 1, 1, (panel.paletteOffset or 0) >= maxOffset and 0.35 or 1) end
  end
  panel.ApplyPaletteOffset = applyPaletteOffset
  local function movePalette(delta)
    local maxOffset = paletteMaxOffset()
    local nextOffset = (panel.paletteOffset or 0) + delta
    if nextOffset < 96 then nextOffset = 0 end
    if maxOffset - nextOffset < 96 then nextOffset = maxOffset end
    panel.paletteOffset = nextOffset
    applyPaletteOffset()
  end
  panel.MovePalette = movePalette
  local function wheelPalette(delta)
    local step = 132
    if IsShiftKeyDown and IsShiftKeyDown() then step = 264 end
    movePalette(-(tonumber(delta) or 0) * step)
  end
  prevPalette:SetScript("OnClick", function() movePalette(-240) end)
  nextPalette:SetScript("OnClick", function() movePalette(240) end)
  paletteScroll:SetScript("OnMouseWheel", function(_, delta) wheelPalette(delta) end)
  paletteContent:SetScript("OnMouseWheel", function(_, delta) wheelPalette(delta) end)
  paletteScroll:SetScript("OnSizeChanged", function(_, w, h)
    paletteContent:SetHeight(max(72, (h or 82) - 2))
    applyPaletteOffset()
    if panel.RefreshPalette then panel:RefreshPalette() end
  end)
  panel.paletteContent = paletteContent

  local right = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  right:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", 0, -8)
  right:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 8)
  right:SetWidth(286)
  Backdrop(right, { 0.045, 0.060, 0.085, 0.98 }, T.border)

  local layoutNamePopup = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  layoutNamePopup:SetSize(360, 128)
  layoutNamePopup:SetPoint("CENTER", panel, "CENTER", 0, 20)
  layoutNamePopup:SetFrameStrata("DIALOG")
  layoutNamePopup:SetFrameLevel(panel:GetFrameLevel() + 100)
  layoutNamePopup:SetClampedToScreen(true)
  layoutNamePopup:EnableMouse(true)
  layoutNamePopup:Hide()
  Backdrop(layoutNamePopup, { 0.035, 0.045, 0.065, 0.99 }, T.border)
  panel.layoutNamePopup = layoutNamePopup

  layoutNamePopup.title = FS(layoutNamePopup, "GameFontNormalLarge")
  layoutNamePopup.title:SetPoint("TOPLEFT", 14, -14)
  layoutNamePopup.title:SetText("Name Layout")
  TextColor(layoutNamePopup.title, "accent")

  local layoutNameEdit = EditBox(layoutNamePopup)
  layoutNameEdit:SetPoint("TOPLEFT", layoutNamePopup, "TOPLEFT", 14, -46)
  layoutNameEdit:SetPoint("TOPRIGHT", layoutNamePopup, "TOPRIGHT", -14, -46)
  layoutNameEdit:SetHeight(26)

  local layoutNameSave = Button(layoutNamePopup, "Save", 78)
  layoutNameSave:SetPoint("BOTTOMRIGHT", layoutNamePopup, "BOTTOMRIGHT", -14, 12)
  local layoutNameCancel = Button(layoutNamePopup, "Cancel", 78)
  layoutNameCancel:SetPoint("RIGHT", layoutNameSave, "LEFT", -8, 0)

  local function saveLayoutName()
    local layout = layoutNamePopup.layoutID and sys:RenameLayout(layoutNamePopup.layoutID, layoutNameEdit:GetText() or "")
    if not layout then
      if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r Enter a layout name.") end
      return
    end
    layoutNamePopup:Hide()
    layoutNameEdit:ClearFocus()
    if panel.layoutDropdown and panel.layoutDropdown.ApplyText then panel.layoutDropdown:ApplyText() end
    if panel.Refresh then panel:Refresh() end
  end

  local function openLayoutNamePopup(layout, mode)
    if not layout then return end
    layoutNamePopup.layoutID = layout.id
    layoutNamePopup.title:SetText(mode == "new" and "Name New Layout" or mode == "copy" and "Name Copied Layout" or "Rename Layout")
    layoutNameEdit:SetText(layout.name or "")
    layoutNamePopup:Show()
    layoutNameEdit:SetFocus()
    layoutNameEdit:HighlightText()
  end

  layoutNameSave:SetScript("OnClick", saveLayoutName)
  layoutNameCancel:SetScript("OnClick", function()
    layoutNamePopup:Hide()
    layoutNameEdit:ClearFocus()
  end)
  layoutNameEdit:SetScript("OnEnterPressed", saveLayoutName)
  layoutNameEdit:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    layoutNamePopup:Hide()
  end)

  local function layoutOptions()
    local db = sys:GetDB()
    local opts = {}
    local layouts = (db and db.layouts) or {}
    local canDelete = #layouts > 1
    for _, layout in ipairs(layouts) do
      opts[#opts + 1] = {
        value = layout.id,
        text = (layout.name and layout.name ~= "" and layout.name) or ("Layout " .. tostring(layout.id)),
        deleteTooltip = "Delete layout",
        onDelete = canDelete and function(value)
          if panel.SaveCanvasView then panel:SaveCanvasView() end
          if sys:DeleteLayout(value) then
            local active = sys:GetActiveLayout()
            panel.activeFloor = "all"
            panel.selectedRoomID = active and active.rooms and active.rooms[1] and active.rooms[1].id or nil
            if panel.RestoreCanvasView then panel:RestoreCanvasView(true) end
            if panel.Refresh then panel:Refresh() end
          elseif DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r You need at least one layout.")
          end
        end or nil,
      }
    end
    opts[#opts + 1] = { separator = true }
    opts[#opts + 1] = { value = "new", text = "+ New Layout" }
    opts[#opts + 1] = { value = "duplicate", text = "Copy Current Layout" }
    opts[#opts + 1] = { value = "rename", text = "Rename Current" }
    return opts
  end

  local layoutDropdown
  if Dropdown and Dropdown.Create then
    layoutDropdown = Dropdown.Create(
      top,
      "Layout",
      nil,
      230,
      function()
        local layout = sys:GetActiveLayout()
        return layout and layout.id
      end,
      function(value)
        if panel.SaveCanvasView then panel:SaveCanvasView() end
        local layout, nameMode
        if value == "new" then
          layout = sys:CreateLayout("New Layout")
          nameMode = "new"
        elseif value == "duplicate" then
          local current = sys:GetActiveLayout()
          layout = current and sys:DuplicateLayout(current.id)
          nameMode = "copy"
        elseif value == "rename" then
          layout = sys:GetActiveLayout()
          nameMode = "rename"
        else
          layout = sys:SetActiveLayout(value)
        end
        panel.activeFloor = "all"
        panel.selectedRoomID = layout and layout.rooms and layout.rooms[1] and layout.rooms[1].id or nil
        if panel.RestoreCanvasView then panel:RestoreCanvasView(true) end
        if panel.Refresh then panel:Refresh() end
        if nameMode then openLayoutNamePopup(layout, nameMode) end
      end,
      layoutOptions,
      nil,
      Controls(), T
    )
    layoutDropdown:SetSize(230, 26)
    layoutDropdown:SetPoint("BOTTOMLEFT", top, "BOTTOMLEFT", 12, 8)
    panel.layoutDropdown = layoutDropdown
  else
    layoutDropdown = Button(top, "Layout", 230)
    layoutDropdown:SetPoint("BOTTOMLEFT", top, "BOTTOMLEFT", 12, 8)
    layoutDropdown:SetScript("OnClick", function()
      if panel.SaveCanvasView then panel:SaveCanvasView() end
      local db = sys:GetDB()
      local current = sys:GetActiveLayout()
      local layouts = (db and db.layouts) or {}
      for i, layout in ipairs(layouts) do
        if current and layout.id == current.id then
          local nextLayout = layouts[i + 1] or layouts[1]
          if nextLayout then sys:SetActiveLayout(nextLayout.id) end
          break
        end
      end
      panel.selectedRoomID = nil
      panel.activeFloor = "all"
      if panel.RestoreCanvasView then panel:RestoreCanvasView(true) end
      panel:Refresh()
    end)
    panel.layoutDropdown = layoutDropdown
  end

  local clearBtn = Button(top, "Clear All", 76)

  local importBtn = Button(top, "Import", 64)

  local exportBtn = Button(top, "Export", 64)
  exportBtn:SetPoint("BOTTOMRIGHT", top, "BOTTOMRIGHT", -236, 8)
  importBtn:SetPoint("RIGHT", exportBtn, "LEFT", -6, 0)
  clearBtn:SetPoint("RIGHT", importBtn, "LEFT", -12, 0)

  local captureBtn = Button(top, "Capture House", 104)
  captureBtn:SetPoint("LEFT", layoutDropdown, "RIGHT", 8, 0)
  captureBtn:HookScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Capture House")
    GameTooltip:AddLine("Captures every detected floor and tries to arrange connected rooms automatically.", 1, 1, 1, true)
    GameTooltip:AddLine("Blizzard may not provide complete position data, so capture can occasionally fail or require manual room adjustments.", 0.82, 0.82, 0.82, true)
    GameTooltip:Show()
  end)
  captureBtn:HookScript("OnLeave", function()
    if GameTooltip then GameTooltip:Hide() end
  end)

  local floorDropdown
  if Dropdown and Dropdown.Create then
    floorDropdown = Dropdown.Create(
      top,
      "Floor",
      nil,
      118,
      function() return panel.activeFloor or "all" end,
      function(v)
        if panel.SaveCanvasView then panel:SaveCanvasView() end
        panel.activeFloor = v or "all"
        if panel.RestoreCanvasView then panel:RestoreCanvasView(true) end
        panel:Refresh()
      end,
      function()
        if panel.GetFloorOptions then return panel:GetFloorOptions() end
        return { { value = "all", text = "All Floors" }, { value = 1, text = "Floor 1" } }
      end,
      nil,
      Controls(), T
    )
    floorDropdown:SetSize(118, 26)
    floorDropdown:SetPoint("LEFT", captureBtn, "RIGHT", 6, 0)
    panel.floorDropdown = floorDropdown
  else
    floorDropdown = Button(top, "Floor: All", 118)
    floorDropdown:SetPoint("LEFT", captureBtn, "RIGHT", 6, 0)
    floorDropdown:SetScript("OnClick", function()
      local opts = panel:GetFloorOptions()
      local cur = panel.activeFloor or "all"
      local nextValue = "all"
      for i, opt in ipairs(opts) do
        if opt.value == cur then
          nextValue = (opts[i + 1] and opts[i + 1].value) or opts[1].value
          break
        end
      end
      if panel.SaveCanvasView then panel:SaveCanvasView() end
      panel.activeFloor = nextValue
      if panel.RestoreCanvasView then panel:RestoreCanvasView(true) end
      panel:Refresh()
    end)
    panel.floorDropdown = floorDropdown
  end

  local hideFloorsBtn = Button(top, "Hide Others", 92)
  hideFloorsBtn:SetPoint("LEFT", floorDropdown, "RIGHT", 6, 0)
  panel.hideFloorsBtn = hideFloorsBtn
  panel.hideOtherFloors = false

  function panel:RefreshFloorVisibilityButton()
    local enabled = self:GetActiveFloor() ~= "all"
    hideFloorsBtn:SetEnabled(enabled)
    hideFloorsBtn:EnableMouse(enabled)
    hideFloorsBtn:SetAlpha(enabled and 1 or 0.42)
    hideFloorsBtn.text:SetText(self.hideOtherFloors and enabled and "Show Others" or "Hide Others")
    Backdrop(
      hideFloorsBtn,
      self.hideOtherFloors and enabled and { 0.070, 0.115, 0.160, 0.98 } or T.panel,
      self.hideOtherFloors and enabled and (T.accent or T.border) or T.border
    )
  end

  hideFloorsBtn:SetScript("OnClick", function()
    if panel:GetActiveFloor() == "all" then return end
    panel.hideOtherFloors = not panel.hideOtherFloors
    if panel.SaveCanvasView then panel:SaveCanvasView() end
    panel:RefreshFloorVisibilityButton()
    panel:Refresh()
  end)

  local canvas = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  canvas:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, -8)
  canvas:SetPoint("BOTTOMRIGHT", left, "TOPRIGHT", 0, 8)
  Backdrop(canvas, { 0.060, 0.085, 0.110, 0.98 }, T.border)
  canvas:EnableMouse(true)
  if canvas.SetClipsChildren then canvas:SetClipsChildren(true) end
  if canvas.EnableMouseWheel then canvas:EnableMouseWheel(true) end
  panel.canvas = canvas

  local canvasGrid = CreateFrame("Frame", nil, canvas)
  canvasGrid:SetAllPoints(canvas)
  panel.canvasGrid = canvasGrid
  panel.canvasGridPool = {}

  local canvasInstructions = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
  canvasInstructions:SetPoint("BOTTOMLEFT", canvas, "BOTTOMLEFT", 1, 1)
  canvasInstructions:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -1, 1)
  canvasInstructions:SetHeight(38)
  canvasInstructions:SetFrameLevel(canvas:GetFrameLevel() + 50)
  canvasInstructions:EnableMouse(false)
  Backdrop(canvasInstructions, { 0.035, 0.045, 0.060, 0.94 }, T.border)

  local canvasNavigationHint = FS(canvasInstructions, "GameFontNormalSmall")
  canvasNavigationHint:SetPoint("TOP", canvasInstructions, "TOP", 0, -5)
  canvasNavigationHint:SetText("Right-click and drag to move the grid. Scroll to zoom in or out.")
  TextColor(canvasNavigationHint, "textMuted")

  local canvasHint = FS(canvasInstructions, "GameFontNormalSmall")
  canvasHint:SetPoint("BOTTOM", canvasInstructions, "BOTTOM", 0, 5)
  canvasHint:SetText("Click gold dots to attach rooms. Right-click a room for actions. Drag to snap connectors.")
  TextColor(canvasHint, "textMuted")

  local function canvasMetrics()
    local layout = sys:GetActiveLayout()
    local zoom = panel.canvasZoom or 1
    local cellW = (panel.baseCellSize or 34) * zoom
    local cellH = (panel.baseCellSize or 34) * zoom
    return layout, cellW, cellH
  end

  local function clampNumber(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
  end

  local function visibleLayoutBounds(layout)
    local minX, minY, maxX, maxY = 999999, 999999, 0, 0
    local activeFloor = panel:GetActiveFloor()
    for _, room in ipairs((layout and layout.rooms) or {}) do
      if activeFloor == "all" or RoomFloor(room) == tonumber(activeFloor) then
        minX = min(minX, room.x or 0)
        minY = min(minY, room.y or 0)
        maxX = max(maxX, (room.x or 0) + (room.w or 1))
        maxY = max(maxY, (room.y or 0) + (room.h or 1))
      end
    end
    if minX == 999999 then return nil end
    return minX, minY, maxX, maxY
  end

  local function clampCanvasPan(layout)
    local minX, minY, maxX, maxY = visibleLayoutBounds(layout)
    if not minX then return end
    local cell = (panel.baseCellSize or 34) * (panel.canvasZoom or 1)
    local w, h = canvas:GetWidth() or 1, canvas:GetHeight() or 1
    local pad = 48
    local leftEdge = (panel.canvasPanX or 0) + (minX * cell)
    local rightEdge = (panel.canvasPanX or 0) + (maxX * cell)
    local topEdge = (panel.canvasPanY or 0) + (minY * cell)
    local bottomEdge = (panel.canvasPanY or 0) + (maxY * cell)
    if rightEdge < pad then panel.canvasPanX = (panel.canvasPanX or 0) + (pad - rightEdge) end
    if leftEdge > w - pad then panel.canvasPanX = (panel.canvasPanX or 0) - (leftEdge - (w - pad)) end
    if bottomEdge < pad then panel.canvasPanY = (panel.canvasPanY or 0) + (pad - bottomEdge) end
    if topEdge > h - pad then panel.canvasPanY = (panel.canvasPanY or 0) - (topEdge - (h - pad)) end
  end

  canvas:SetScript("OnMouseWheel", function(self, delta)
    local layout, oldCellW, oldCellH = canvasMetrics()
    if not layout then return end
    local scale = self:GetEffectiveScale() or 1
    local cx, cy = GetCursorPosition()
    local leftPx, bottomPx, widthPx, heightPx = self:GetRect()
    leftPx = leftPx or self:GetLeft() or 0
    heightPx = heightPx or self:GetHeight() or 1
    widthPx = widthPx or self:GetWidth() or 1
    local topPx = bottomPx and (bottomPx + heightPx) or (self:GetTop() or heightPx)
    local localX = (cx / scale) - leftPx
    local localY = topPx - (cy / scale)
    localX = clampNumber(localX, 0, max(1, widthPx))
    localY = clampNumber(localY, 0, max(1, heightPx))
    local worldX = (localX - (panel.canvasPanX or 0)) / oldCellW
    local worldY = (localY - (panel.canvasPanY or 0)) / oldCellH
    local nextZoom = max(0.14, min(2.8, (panel.canvasZoom or 1) * (delta > 0 and 1.12 or 0.89)))
    panel.canvasZoom = nextZoom
    local _, newCellW, newCellH = canvasMetrics()
    panel.canvasPanX = localX - (worldX * newCellW)
    panel.canvasPanY = localY - (worldY * newCellH)
    clampCanvasPan(layout)
    panel:PositionRooms()
    if panel.SaveCanvasView then panel:SaveCanvasView() end
  end)

  canvas:SetScript("OnMouseDown", function(self, btn)
    if panel.roomMenu then panel.roomMenu:Hide() end
    if btn ~= "RightButton" and btn ~= "MiddleButton" then return end
    self.panMode = true
    local x, y = GetCursorPosition()
    local scale = self:GetEffectiveScale() or 1
    self.panStartX, self.panStartY = x / scale, y / scale
    self.panBaseX, self.panBaseY = panel.canvasPanX or 0, panel.canvasPanY or 0
  end)
  canvas:SetScript("OnMouseUp", function(self)
    self.panMode = nil
    if panel.SaveCanvasView then panel:SaveCanvasView() end
  end)
  canvas:SetScript("OnUpdate", function(self)
    if not self.panMode then return end
    if IsMouseButtonDown and not (IsMouseButtonDown("RightButton") or IsMouseButtonDown("MiddleButton")) then
      self.panMode = nil
      if panel.SaveCanvasView then panel:SaveCanvasView() end
      return
    end
    local x, y = GetCursorPosition()
    local scale = self:GetEffectiveScale() or 1
    local nextPanX = (self.panBaseX or 0) + ((x / scale) - (self.panStartX or 0))
    local nextPanY = (self.panBaseY or 0) - ((y / scale) - (self.panStartY or 0))
    if abs(nextPanX - (panel.canvasPanX or 0)) < 0.25 and abs(nextPanY - (panel.canvasPanY or 0)) < 0.25 then return end
    panel.canvasPanX = nextPanX
    panel.canvasPanY = nextPanY
    if panel.PositionCanvasFrames then panel:PositionCanvasFrames() else panel:PositionRooms() end
  end)

  local inspectorTitle = FS(right, "GameFontNormalLarge")
  inspectorTitle:SetPoint("TOPLEFT", 12, -12)
  inspectorTitle:SetText("Room")
  TextColor(inspectorTitle, "accent")
  panel.inspectorTitle = inspectorTitle

  local selectedPreview = CreateFrame("Frame", nil, right, "BackdropTemplate")
  selectedPreview:SetPoint("TOPLEFT", 12, -42)
  selectedPreview:SetSize(88, 88)
  Backdrop(selectedPreview, { 0.035, 0.050, 0.075, 0.98 }, T.border)
  selectedPreview.pool = {}
  selectedPreview.gridPool = {}
  panel.selectedPreview = selectedPreview

  local roomName = EditBox(right)
  roomName:SetPoint("TOPLEFT", selectedPreview, "TOPRIGHT", 10, 0)
  roomName:SetPoint("TOPRIGHT", right, "TOPRIGHT", -12, -42)
  roomName:SetHeight(22)
  panel.roomName = roomName

  local roomStats = FS(right, "GameFontNormalSmall")
  roomStats:SetPoint("TOPLEFT", roomName, "BOTTOMLEFT", 0, -8)
  roomStats:SetPoint("RIGHT", right, "RIGHT", -12, 0)
  roomStats:SetJustifyH("LEFT")
  TextColor(roomStats, "textMuted")
  panel.roomStats = roomStats

  local deleteRoom = Button(right, "Delete Room", 98)
  deleteRoom:SetPoint("TOPLEFT", selectedPreview, "BOTTOMLEFT", 0, -14)

  local rotateRoom = Button(right, "Rotate 90", 86)
  rotateRoom:SetPoint("LEFT", deleteRoom, "RIGHT", 8, 0)

  local changesTitle = FS(right, "GameFontNormal")
  changesTitle:SetPoint("TOPLEFT", deleteRoom, "BOTTOMLEFT", 0, -18)
  changesTitle:SetText("House Changes")
  TextColor(changesTitle, "accent")

  local changesList = CreateFrame("Frame", nil, right)
  changesList:SetPoint("TOPLEFT", changesTitle, "BOTTOMLEFT", 0, -8)
  changesList:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -12, 12)
  panel.changesList = changesList

  local sharePopup = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  sharePopup:SetSize(560, 360)
  sharePopup:SetPoint("CENTER", panel, "CENTER", 0, 0)
  sharePopup:SetFrameStrata("DIALOG")
  sharePopup:SetFrameLevel(panel:GetFrameLevel() + 80)
  sharePopup:EnableMouse(true)
  sharePopup:SetMovable(true)
  sharePopup:RegisterForDrag("LeftButton")
  sharePopup:SetScript("OnDragStart", function(self) self:StartMoving() end)
  sharePopup:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  sharePopup:Hide()
  Backdrop(sharePopup, { 0.035, 0.045, 0.065, 0.98 }, T.border)
  panel.sharePopup = sharePopup

  sharePopup.title = FS(sharePopup, "GameFontNormalLarge")
  sharePopup.title:SetPoint("TOPLEFT", sharePopup, "TOPLEFT", 14, -12)
  sharePopup.title:SetText("Import / Export")
  TextColor(sharePopup.title, "accent")

  sharePopup.hint = FS(sharePopup, "GameFontNormalSmall")
  sharePopup.hint:SetPoint("LEFT", sharePopup.title, "RIGHT", 14, 0)
  sharePopup.hint:SetPoint("RIGHT", sharePopup, "RIGHT", -46, 0)
  sharePopup.hint:SetJustifyH("LEFT")
  TextColor(sharePopup.hint, "textMuted")

  local popupCloseX = Button(sharePopup, "X", 26)
  popupCloseX:SetPoint("TOPRIGHT", sharePopup, "TOPRIGHT", -10, -10)

  local shareBox = EditBox(sharePopup)
  shareBox:SetPoint("TOPLEFT", sharePopup, "TOPLEFT", 14, -46)
  shareBox:SetPoint("BOTTOMRIGHT", sharePopup, "BOTTOMRIGHT", -14, 48)
  shareBox:SetMultiLine(true)
  shareBox:SetMaxLetters(20000)
  panel.shareBox = shareBox

  local popupImport = Button(sharePopup, "Import JSON", 96)
  popupImport:SetPoint("BOTTOMLEFT", sharePopup, "BOTTOMLEFT", 14, 14)
  sharePopup.importBtn = popupImport

  local popupSelect = Button(sharePopup, "Select All", 84)
  popupSelect:SetPoint("LEFT", popupImport, "RIGHT", 8, 0)

  local popupClose = Button(sharePopup, "Close", 70)
  popupClose:SetPoint("BOTTOMRIGHT", sharePopup, "BOTTOMRIGHT", -14, 14)

  local function openSharePopup(mode, text)
    local title = mode == "export" and "Export Floorplan JSON" or mode == "debug" and "Capture Debug JSON" or "Import Floorplan JSON"
    local hint = mode == "export" and "Select the JSON and copy it."
      or mode == "debug" and "This can help diagnose capture issues."
      or "Paste a floorplan JSON string, then import it."
    sharePopup.title:SetText(title)
    sharePopup.hint:SetText(hint)
    popupImport:SetShown(mode ~= "export")
    popupSelect:ClearAllPoints()
    if mode == "export" then
      popupSelect:SetPoint("BOTTOMLEFT", sharePopup, "BOTTOMLEFT", 14, 14)
    else
      popupSelect:SetPoint("LEFT", popupImport, "RIGHT", 8, 0)
    end
    shareBox:SetText(text or "")
    sharePopup:Show()
    shareBox:SetFocus()
    shareBox:HighlightText()
  end
  panel.OpenSharePopup = openSharePopup

  popupCloseX:SetScript("OnClick", function() sharePopup:Hide() end)
  popupClose:SetScript("OnClick", function() sharePopup:Hide() end)
  popupSelect:SetScript("OnClick", function()
    shareBox:SetFocus()
    shareBox:HighlightText()
  end)
  shareBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    sharePopup:Hide()
  end)

  local function activeLayout()
    return sys:GetActiveLayout()
  end

  function panel:CanvasViewKey()
    return tostring(self:GetActiveFloor() or "all")
  end

  function panel:SaveCanvasView()
    local layout = activeLayout()
    if not layout then return end
    layout.canvasView = layout.canvasView or {}
    local key = self:CanvasViewKey()
    layout.canvasView[key] = {
      zoom = max(0.14, min(2.8, tonumber(self.canvasZoom) or 1)),
      panX = tonumber(self.canvasPanX) or 36,
      panY = tonumber(self.canvasPanY) or 36,
      hideOthers = self.hideOtherFloors and true or false,
    }
    if key ~= "all" then layout.currentFloor = tonumber(key) or layout.currentFloor end
  end

  function panel:RestoreCanvasView(fitIfMissing)
    local layout = activeLayout()
    if not layout then return false end
    local view = layout.canvasView and layout.canvasView[self:CanvasViewKey()]
    if view then
      self.canvasZoom = max(0.14, min(2.8, tonumber(view.zoom) or 1))
      self.canvasPanX = tonumber(view.panX) or 36
      self.canvasPanY = tonumber(view.panY) or 36
      self.hideOtherFloors = view.hideOthers and true or false
      if self.RefreshFloorVisibilityButton then self:RefreshFloorVisibilityButton() end
      return true
    end
    if fitIfMissing and self.FitCanvasToLayout then
      self:FitCanvasToLayout()
    end
    return false
  end

  local function selectedRoom()
    local layout = activeLayout()
    if not layout then return nil end
    for _, room in ipairs(layout.rooms or {}) do
      if room.id == panel.selectedRoomID then return room end
    end
  end

  local function selectedTemplate()
    for _, template in ipairs(sys:GetRoomTemplates() or {}) do
      if template.key == panel.selectedTemplateKey then return template end
    end
    return (sys:GetRoomTemplates() or {})[1]
  end

  local function refresh()
    panel:Refresh()
  end

  local function selectRoom(roomID)
    panel.selectedRoomID = roomID
    if panel.roomMenu then panel.roomMenu:Hide() end
    refresh()
  end

  local roomMenu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
  roomMenu:SetSize(128, 72)
  roomMenu:SetFrameStrata("DIALOG")
  roomMenu:SetFrameLevel(panel:GetFrameLevel() + 90)
  roomMenu:SetClampedToScreen(true)
  roomMenu:EnableMouse(true)
  roomMenu:Hide()
  Backdrop(roomMenu, { 0.035, 0.045, 0.065, 0.98 }, T.border)
  panel.roomMenu = roomMenu

  local menuRotate = Button(roomMenu, "Rotate 90", 108)
  menuRotate:SetPoint("TOP", roomMenu, "TOP", 0, -10)

  local menuDelete = Button(roomMenu, "Delete Room", 108)
  menuDelete:SetPoint("TOP", menuRotate, "BOTTOM", 0, -6)

  local function roomMenuTarget()
    local layout = activeLayout()
    if not layout then return nil, nil end
    local id = roomMenu.roomID or panel.selectedRoomID
    for _, room in ipairs(layout.rooms or {}) do
      if room.id == id then return layout, room end
    end
  end

  local function openRoomMenu(roomID)
    panel.selectedRoomID = roomID
    roomMenu.roomID = roomID
    if panel.RefreshInspector then panel:RefreshInspector() end
    if panel.PositionRooms then panel:PositionRooms() end
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    local cx, cy = GetCursorPosition()
    roomMenu:ClearAllPoints()
    roomMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (cx / scale) + 8, (cy / scale) - 8)
    roomMenu:Show()
  end

  menuRotate:SetScript("OnClick", function()
    local layout, room = roomMenuTarget()
    if layout and room then
      sys:RotateRoom(layout, room.id, 1)
      roomMenu:Hide()
      refresh()
    end
  end)

  menuDelete:SetScript("OnClick", function()
    local layout, room = roomMenuTarget()
    if layout and room then
      sys:DeleteRoom(layout, room.id)
      panel.selectedRoomID = layout.rooms and layout.rooms[1] and layout.rooms[1].id or nil
      roomMenu:Hide()
      refresh()
    end
  end)

  local function placeTemplateAtConnector(sourceRoom, sourceConn)
    local layout = activeLayout()
    local template = selectedTemplate()
    if not layout or not sourceRoom or not sourceConn or not template then return end
    local target = sys:AddRoom(layout, template)
    if not target then return end
    target.floor = RoomFloor(sourceRoom)
    target.capture = target.capture or {}
    target.capture.floor = target.floor
    local targetConn = ConnectorForDirection(target, OPPOSITE[sourceConn[3]] or "W")
    target.x = sourceRoom.x + sourceConn[1] * sourceRoom.w - targetConn[1] * target.w
    target.y = sourceRoom.y + sourceConn[2] * sourceRoom.h - targetConn[2] * target.h
    sys:MoveRoom(layout, target.id, floor(target.x + 0.5), floor(target.y + 0.5))
    if sys.NormalizeLayout then sys:NormalizeLayout(layout) end
    panel.selectedRoomID = target.id
    if panel.KeepRoomVisible then panel:KeepRoomVisible(target) end
    refresh()
  end

  local function cursorPoint(frame)
    local scale = frame:GetEffectiveScale() or 1
    local cx, cy = GetCursorPosition()
    local left = frame:GetLeft() or 0
    local top = frame:GetTop() or 0
    return (cx / scale) - left, top - (cy / scale)
  end

  local function cursorOver(frame)
    local x, y = cursorPoint(frame)
    return x >= 0 and y >= 0 and x <= (frame:GetWidth() or 0) and y <= (frame:GetHeight() or 0), x, y
  end

  local function activeDropFloor(layout)
    local activeFloor = panel:GetActiveFloor()
    if activeFloor == "all" then return tonumber(layout and layout.currentFloor) or 1 end
    return tonumber(activeFloor) or 1
  end

  local function templateDropPoint(template)
    local inside, localX, localY = cursorOver(canvas)
    if not inside or not template then return nil, nil, false end
    local cell = (panel.baseCellSize or 34) * (panel.canvasZoom or 1)
    local worldX = (localX - (panel.canvasPanX or 0)) / cell
    local worldY = (localY - (panel.canvasPanY or 0)) / cell
    return floor(worldX - ((template.w or 1) / 2) + 0.5), floor(worldY - ((template.h or 1) / 2) + 0.5), true
  end

  local function hidePaletteGhost()
    if panel.paletteDragGhost then panel.paletteDragGhost:Hide() end
  end

  local function ensurePaletteGhost()
    if panel.paletteDragGhost then return panel.paletteDragGhost end
    local ghost = CreateFrame("Frame", nil, canvas, "BackdropTemplate")
    ghost:SetFrameLevel(canvas:GetFrameLevel() + 40)
    ghost:EnableMouse(false)
    ghost.pool = {}
    ghost.gridPool = {}
    Backdrop(ghost, { 0, 0, 0, 0.05 }, { 0.30, 0.62, 1.00, 0.90 })
    ghost:Hide()
    panel.paletteDragGhost = ghost
    return ghost
  end

  local function updatePaletteGhost(template)
    local gx, gy, inside = templateDropPoint(template)
    if not inside then hidePaletteGhost(); return nil, nil, false end
    local cell = (panel.baseCellSize or 34) * (panel.canvasZoom or 1)
    local ghost = ensurePaletteGhost()
    ghost:ClearAllPoints()
    ghost:SetPoint("TOPLEFT", canvas, "TOPLEFT", (panel.canvasPanX or 0) + (gx * cell), -((panel.canvasPanY or 0) + (gy * cell)))
    ghost:SetSize(max(14, (template.w or 1) * cell - 4), max(14, (template.h or 1) * cell - 4))
    ghost:SetAlpha(0.70)
    DrawGrid(ghost, ghost.gridPool, 8, 6, 4, 0.035)
    DrawShape(ghost, template, ghost.pool, true, 0.74)
    ghost:Show()
    return gx, gy, true
  end

  local function dropTemplateOnCanvas(template)
    local layout = activeLayout()
    local gx, gy, inside = templateDropPoint(template)
    if not layout or not template or not inside then return false end
    local floorNum = activeDropFloor(layout)
    local room
    if sys.AddRoomAt then
      room = sys:AddRoomAt(layout, template, gx, gy, floorNum)
    else
      room = sys:AddRoom(layout, template)
      if room then
        room.x, room.y = gx, gy
        room.floor = floorNum
        room.capture = room.capture or {}
        room.capture.floor = floorNum
        sys:MoveRoom(layout, room.id, gx, gy)
      end
    end
    if not room then return false end
    layout.currentFloor = floorNum
    panel.selectedRoomID = room.id
    panel.selectedTemplateKey = template.key
    if panel.ApplySnap then panel:ApplySnap(room) end
    sys:MoveRoom(layout, room.id, floor((room.x or gx) + 0.5), floor((room.y or gy) + 0.5))
    hidePaletteGhost()
    refresh()
    return true
  end

  local function finishPaletteDrag(card)
    local drag = panel.paletteDrag
    if not drag or drag.card ~= card then return end
    if drag.dragging then
      card.didPaletteDrag = true
      dropTemplateOnCanvas(drag.template)
    end
    hidePaletteGhost()
    panel.paletteDrag = nil
    card:SetScript("OnUpdate", nil)
  end

  local function updatePaletteDrag(card)
    local drag = panel.paletteDrag
    if not drag or drag.card ~= card then return end
    if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
      finishPaletteDrag(card)
      return
    end
    local x, y = GetCursorPosition()
    if not drag.dragging and (abs((x or 0) - (drag.startX or 0)) > 6 or abs((y or 0) - (drag.startY or 0)) > 6) then
      drag.dragging = true
      card.didPaletteDrag = true
      panel.selectedTemplateKey = drag.template and drag.template.key or panel.selectedTemplateKey
      panel:RefreshPalette()
    end
    if drag.dragging then updatePaletteGhost(drag.template) end
  end

  local function MakeRoomCard(i)
    local card = CreateFrame("Button", nil, paletteContent, "BackdropTemplate")
    card:SetSize(112, 76)
    if card.EnableMouseWheel then card:EnableMouseWheel(true) end
    Backdrop(card, { 0.050, 0.065, 0.090, 0.98 }, T.border)
    Hover(card, { 0.050, 0.065, 0.090, 0.98 }, { 0.075, 0.100, 0.135, 0.98 })

    card.preview = CreateFrame("Frame", nil, card)
    card.preview:SetPoint("TOPLEFT", card, "TOPLEFT", 6, -6)
    card.preview:SetSize(38, 30)
    card.preview.pool = {}
    card.preview.gridPool = {}
    card.preview:SetScript("OnSizeChanged", function(self)
      DrawGrid(self, self.gridPool, 8, 6, 2, 0.035)
      if card.template then DrawShape(self, card.template, self.pool, card.template.key == panel.selectedTemplateKey, 0.62) end
    end)

    card.name = FS(card, "GameFontNormalSmall")
    card.name:SetPoint("TOPLEFT", card.preview, "TOPRIGHT", 6, -1)
    card.name:SetPoint("RIGHT", -6, 0)
    card.name:SetJustifyH("LEFT")
    card.name:SetWordWrap(false)

    card.cost = FS(card, "GameFontNormalSmall")
    card.cost:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 7, 8)
    card.cost:SetWidth(36)
    TextColor(card.cost, "textMuted")

    card.costVal = FS(card, "GameFontNormalSmall")
    card.costVal:SetPoint("LEFT", card.cost, "RIGHT", 2, 0)
    card.costVal:SetJustifyH("RIGHT")
    TextColor(card.costVal, "accent")

    card.conn = FS(card, "GameFontNormalSmall")
    card.conn:SetPoint("LEFT", card.costVal, "RIGHT", 10, 0)
    card.conn:SetText("Conn:")
    TextColor(card.conn, "textMuted")

    card.connVal = FS(card, "GameFontNormalSmall")
    card.connVal:SetPoint("LEFT", card.conn, "RIGHT", 2, 0)
    card.connVal:SetJustifyH("RIGHT")
    TextColor(card.connVal, "text")

    card:SetScript("OnClick", function(self)
      if self.didPaletteDrag then
        self.didPaletteDrag = nil
        return
      end
      if not self.template then return end
      panel.selectedTemplateKey = self.template.key
      panel:RefreshPalette()
    end)
    card:SetScript("OnMouseDown", function(self, btn)
      if btn ~= "LeftButton" or not self.template then return end
      local x, y = GetCursorPosition()
      self.didPaletteDrag = nil
      panel.paletteDrag = {
        card = self,
        template = self.template,
        startX = x,
        startY = y,
        dragging = false,
      }
      self:SetScript("OnUpdate", updatePaletteDrag)
    end)
    card:SetScript("OnMouseUp", function(self, btn)
      if btn == "LeftButton" then finishPaletteDrag(self) end
    end)
    card:SetScript("OnMouseWheel", function(_, delta)
      wheelPalette(delta)
    end)

    panel.roomCards[i] = card
    return card
  end

  local function MakeRoomFrame(i)
    local frame = CreateFrame("Button", nil, canvas, "BackdropTemplate")
    frame:SetFrameLevel(canvas:GetFrameLevel() + 4)
    frame:RegisterForClicks("AnyUp")
    frame:EnableMouse(true)
    if frame.EnableMouseWheel then frame:EnableMouseWheel(true) end
    Backdrop(frame, { 0, 0, 0, 0.05 }, T.border)
    frame.pool = {}
    frame.connectors = {}

    frame.name = FS(frame, "GameFontNormalSmall")
    frame.name:SetPoint("CENTER")
    frame.name:SetJustifyH("CENTER")
    frame.name:SetWordWrap(false)

    for ci = 1, 4 do
      local dot = CreateFrame("Button", nil, frame)
      dot:SetSize(12, 12)
      dot.tex = dot:CreateTexture(nil, "OVERLAY")
      dot.tex:SetAllPoints()
      dot.tex:SetTexture("Interface\\Buttons\\WHITE8x8")
      dot.tex:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], GOLD[4])
      dot:SetScript("OnClick", function(self)
        if self.sourceRoom and self.conn then placeTemplateAtConnector(self.sourceRoom, self.conn) end
      end)
      dot:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Attach selected room", 1, 1, 1)
        local template = selectedTemplate()
        if template then GameTooltip:AddLine(template.name .. " - cost " .. tostring(template.cost), 0.30, 0.82, 1.0) end
        GameTooltip:Show()
      end)
      dot:SetScript("OnLeave", function() GameTooltip:Hide() end)
      frame.connectors[ci] = dot
    end

    local function finishDrag(self)
      local didMove = self.dragMode and self.roomStart
      local layout = activeLayout()
      local room = didMove and selectedRoom() or nil
      if layout and room then
        panel:ApplySnap(room)
        sys:MoveRoom(layout, room.id, floor((room.x or 0) + 0.5), floor((room.y or 0) + 0.5))
        if sys.NormalizeLayout then sys:NormalizeLayout(layout) end
        if panel.KeepRoomVisible then panel:KeepRoomVisible(room) end
      end
      self.dragMode = nil
      self.roomStart = nil
      if didMove then refresh() end
    end

    frame:SetScript("OnMouseDown", function(self, btn)
      if self.isGhost then return end
      if btn ~= "LeftButton" then return end
      if panel.roomMenu then panel.roomMenu:Hide() end
      self.wasSelected = (panel.selectedRoomID == self.roomID)
      self.didDrag = nil
      panel.selectedRoomID = self.roomID
      if panel.RefreshInspector then panel:RefreshInspector() end
      if panel.PositionRooms then panel:PositionRooms() end
      local x, y = GetCursorPosition()
      local scale = canvas:GetEffectiveScale() or 1
      self.dragMode = "move"
      self.startX, self.startY = x / scale, y / scale
      local room = selectedRoom()
      if room then self.roomStart = { x = room.x, y = room.y } end
    end)

    frame:SetScript("OnMouseUp", finishDrag)
    frame:SetScript("OnMouseWheel", function(_, delta)
      local wheel = canvas:GetScript("OnMouseWheel")
      if wheel then wheel(canvas, delta) end
    end)
    frame:SetScript("OnUpdate", function(self)
      if not self.dragMode or not self.roomStart then return end
      if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then finishDrag(self); return end
      local layout = activeLayout()
      local room = selectedRoom()
      if not layout or not room then return end
      local cellW = (panel.baseCellSize or 34) * (panel.canvasZoom or 1)
      local cellH = cellW
      local x, y = GetCursorPosition()
      local scale = canvas:GetEffectiveScale() or 1
      local dx = ((x / scale) - self.startX) / cellW
      local dy = (self.startY - (y / scale)) / cellH
      if abs(dx) > 0.08 or abs(dy) > 0.08 then self.didDrag = true end
      sys:MoveRoom(layout, room.id, self.roomStart.x + dx, self.roomStart.y + dy)
      if panel.PositionRoomFrame then panel:PositionRoomFrame(self) else panel:PositionRooms() end
    end)

    frame:SetScript("OnClick", function(self, btn)
      if self.isGhost then return end
      local layout = activeLayout()
      if not layout then return end
      if self.didDrag then
        self.didDrag = nil
        self.wasSelected = nil
        return
      end
      if btn == "RightButton" then
        openRoomMenu(self.roomID)
      elseif self.wasSelected then
        sys:RotateRoom(layout, self.roomID, 1)
        panel.selectedRoomID = self.roomID
        refresh()
      else
        selectRoom(self.roomID)
      end
      self.wasSelected = nil
    end)
    panel.roomFrames[i] = frame
    return frame
  end

  local function MakeChangeRow(i)
    local row = CreateFrame("Frame", nil, changesList)
    row:SetHeight(20)
    row:SetPoint("TOPLEFT", changesList, "TOPLEFT", 0, -((i - 1) * 21))
    row:SetPoint("TOPRIGHT", changesList, "TOPRIGHT", 0, -((i - 1) * 21))
    row.name = FS(row, "GameFontNormalSmall")
    row.name:SetPoint("LEFT", 0, 0)
    row.name:SetPoint("RIGHT", -36, 0)
    row.name:SetWordWrap(false)
    row.cost = FS(row, "GameFontNormalSmall")
    row.cost:SetPoint("RIGHT", 0, 0)
    row.cost:SetWidth(32)
    row.cost:SetJustifyH("RIGHT")
    TextColor(row.cost, "accent")
    panel.changeRows[i] = row
    return row
  end

  function panel:GetSortedTemplates()
    local templates, seen = {}, {}
    for _, template in ipairs(sys:GetRoomTemplates() or {}) do
      local key = tostring(template.key or template.name or "")
      if key ~= "" and not seen[key] then
        seen[key] = true
        templates[#templates + 1] = template
      end
    end
    if self.sortMode == "nameAsc" then
      table.sort(templates, function(a, b) return tostring(a.name) < tostring(b.name) end)
    elseif self.sortMode == "costDesc" then
      table.sort(templates, function(a, b)
        if (a.cost or 0) ~= (b.cost or 0) then return (a.cost or 0) > (b.cost or 0) end
        return tostring(a.name) < tostring(b.name)
      end)
    else
      table.sort(templates, function(a, b)
        if (a.cost or 0) ~= (b.cost or 0) then return (a.cost or 0) < (b.cost or 0) end
        return tostring(a.name) < tostring(b.name)
      end)
    end
    return templates
  end

  function panel:GetFloorOptions()
    local layout = activeLayout()
    local floors, seen = {}, {}
    for _, room in ipairs((layout and layout.rooms) or {}) do
      local f = RoomFloor(room)
      if not seen[f] then
        seen[f] = true
        floors[#floors + 1] = f
      end
    end
    table.sort(floors)
    local opts = { { value = "all", text = "All Floors" } }
    for _, f in ipairs(floors) do opts[#opts + 1] = { value = f, text = "Floor " .. tostring(f) } end
    if #floors == 0 then opts[#opts + 1] = { value = 1, text = "Floor 1" } end
    return opts
  end

  function panel:GetActiveFloor()
    if self.activeFloor == nil then self.activeFloor = "all" end
    return self.activeFloor
  end

  function panel:RefreshPalette()
    local templates = self:GetSortedTemplates()
    self.roomsCount:SetText(tostring(#templates) .. " rooms")
    for _, card in ipairs(self.roomCards) do card:Hide() end

    local cardW, cardH, gap = 112, 76, 6
    local x = 0
    for i, template in ipairs(templates) do
      local card = self.roomCards[i] or MakeRoomCard(i)
      card:ClearAllPoints()
      card:SetSize(cardW, cardH)
      card:SetPoint("TOPLEFT", self.paletteContent, "TOPLEFT", x, 0)
      x = x + cardW + gap
      card.template = template
      local selected = template.key == self.selectedTemplateKey
      Backdrop(card, selected and { 0.070, 0.115, 0.160, 0.98 } or { 0.050, 0.065, 0.090, 0.98 }, selected and { 0.30, 0.62, 1.00, 0.95 } or T.border)
      DrawGrid(card.preview, card.preview.gridPool, 8, 6, 2, 0.035)
      DrawShape(card.preview, template, card.preview.pool, selected, 0.62)
      card.name:SetText(template.name or "Room")
      card.cost:SetText("Cost:")
      card.costVal:SetText(tostring(template.cost or 0))
      card.conn:SetText("Conn:")
      card.connVal:SetText(tostring(#(template.connections or {})))
      card:Show()
    end
    self.paletteContent:SetWidth(max(1, x > 0 and (x - gap + paletteEdgePad) or 1))
    self.paletteContent:SetHeight(cardH)
    if self.ApplyPaletteOffset then self:ApplyPaletteOffset() end
  end

  function panel:DrawCanvasGrid()
    self.canvasGridPool.lines = self.canvasGridPool.lines or {}
    for _, line in ipairs(self.canvasGridPool.lines) do line:Hide() end
    local w, h = canvas:GetWidth() or 1, canvas:GetHeight() or 1
    local cell = max(10, (self.baseCellSize or 34) * (self.canvasZoom or 1))
    local panX, panY = self.canvasPanX or 0, self.canvasPanY or 0
    local idx = 1
    local startX = panX % cell
    local x = startX
    while x <= w do
      local line = EnsureTexture(canvasGrid, self.canvasGridPool.lines, idx, "BACKGROUND")
      idx = idx + 1
      line:ClearAllPoints()
      line:SetWidth(1)
      line:SetPoint("TOP", canvasGrid, "TOPLEFT", x, 0)
      line:SetPoint("BOTTOM", canvasGrid, "BOTTOMLEFT", x, 0)
      local major = (floor((x - panX) / cell + 0.5) % 4) == 0
      line:SetColorTexture(0.25, 0.38, 0.55, major and 0.11 or 0.055)
      line:Show()
      x = x + cell
    end
    local startY = panY % cell
    local y = startY
    while y <= h do
      local line = EnsureTexture(canvasGrid, self.canvasGridPool.lines, idx, "BACKGROUND")
      idx = idx + 1
      line:ClearAllPoints()
      line:SetHeight(1)
      line:SetPoint("LEFT", canvasGrid, "TOPLEFT", 0, -y)
      line:SetPoint("RIGHT", canvasGrid, "TOPRIGHT", 0, -y)
      local major = (floor((y - panY) / cell + 0.5) % 4) == 0
      line:SetColorTexture(0.25, 0.38, 0.55, major and 0.11 or 0.055)
      line:Show()
      y = y + cell
    end
  end

  function panel:ApplySnap(movingRoom)
    local layout = activeLayout()
    if not layout or not movingRoom then return end
    local best, bestDist
    local movingConns = sys:GetRoomConnections(movingRoom)
    for _, other in ipairs(layout.rooms or {}) do
      if other.id ~= movingRoom.id then
        for _, mc in ipairs(movingConns) do
          for _, oc in ipairs(sys:GetRoomConnections(other)) do
            if OPPOSITE[mc[3]] == oc[3] then
              local mx = movingRoom.x + mc[1] * movingRoom.w
              local my = movingRoom.y + mc[2] * movingRoom.h
              local ox = other.x + oc[1] * other.w
              local oy = other.y + oc[2] * other.h
              local dx, dy = ox - mx, oy - my
              local dist = abs(dx) + abs(dy)
              if dist <= 2.0 and (not bestDist or dist < bestDist) then
                bestDist = dist
                best = { dx = dx, dy = dy }
              end
            end
          end
        end
      end
    end
    if best then sys:MoveRoom(layout, movingRoom.id, floor(movingRoom.x + best.dx + 0.5), floor(movingRoom.y + best.dy + 0.5)) end
  end

  function panel:PositionRoomFrame(frame)
    if not frame then return end
    local cell = (self.baseCellSize or 34) * (self.canvasZoom or 1)
    local panX, panY = self.canvasPanX or 0, self.canvasPanY or 0
    local room = frame.room
    if room and frame:IsShown() then
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", canvas, "TOPLEFT", panX + ((room.x or 0) * cell), -(panY + ((room.y or 0) * cell)))
    end
  end

  function panel:PositionCanvasFrames()
    self:DrawCanvasGrid()
    for _, frame in ipairs(self.roomFrames) do
      self:PositionRoomFrame(frame)
    end
  end

  function panel:PositionRooms()
    local layout = activeLayout()
    if not layout then return end
    self:DrawCanvasGrid()
    local cellW = (self.baseCellSize or 34) * (self.canvasZoom or 1)
    local cellH = cellW
    local panX, panY = self.canvasPanX or 0, self.canvasPanY or 0
    local activeFloor = self:GetActiveFloor()

    for _, frame in ipairs(self.roomFrames) do
      frame.room = nil
      frame:Hide()
    end
    local drawRooms = {}
    local isolateFloor = self.hideOtherFloors and activeFloor ~= "all"
    for _, room in ipairs(layout.rooms or {}) do
      if not isolateFloor or RoomFloor(room) == tonumber(activeFloor) then
        drawRooms[#drawRooms + 1] = room
      end
    end
    table.sort(drawRooms, function(a, b)
      if activeFloor == "all" then return (a.id or 0) < (b.id or 0) end
      local af = RoomFloor(a) == tonumber(activeFloor)
      local bf = RoomFloor(b) == tonumber(activeFloor)
      if af ~= bf then return not af end
      return (a.id or 0) < (b.id or 0)
    end)

    for i, room in ipairs(drawRooms) do
      local frame = self.roomFrames[i] or MakeRoomFrame(i)
      local selected = room.id == self.selectedRoomID
      local roomFloor = RoomFloor(room)
      local ghost = activeFloor ~= "all" and roomFloor ~= tonumber(activeFloor)
      frame.roomID = room.id
      frame.room = room
      frame.isGhost = ghost
      frame:EnableMouse(not ghost)
      if frame.EnableMouseWheel then frame:EnableMouseWheel(not ghost) end
      frame:SetFrameLevel(canvas:GetFrameLevel() + (ghost and 3 or 8))
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", canvas, "TOPLEFT", panX + (room.x * cellW), -(panY + (room.y * cellH)))
      frame:SetSize(max(14, room.w * cellW - 4), max(14, room.h * cellH - 4))
      Backdrop(frame, { 0, 0, 0, 0.04 }, selected and { 1, 0.76, 0.28, 1 } or { 0.30, 0.62, 1.00, 0.80 })
      frame:SetAlpha(ghost and 0.28 or 1)
      DrawShape(frame, room, frame.pool, selected, 0.82)
      frame.name:SetText(room.name or "Room")
      TextColor(frame.name, selected and "highlight" or "text")

      local conns = sys:GetRoomConnections(room)
      for ci, dot in ipairs(frame.connectors) do
        local conn = conns[ci]
        dot.conn = conn
        dot.sourceRoom = room
        dot:ClearAllPoints()
        if conn and not ghost then
          dot:SetPoint("CENTER", frame, "TOPLEFT", conn[1] * frame:GetWidth(), -conn[2] * frame:GetHeight())
          dot.tex:SetVertexColor(GOLD[1], GOLD[2], GOLD[3], selected and 1.0 or 0.82)
          dot:Show()
        else
          dot:Hide()
        end
      end
      frame:Show()
    end
  end

  function panel:KeepRoomVisible(room)
    if not room then return end
    local cell = (self.baseCellSize or 34) * (self.canvasZoom or 1)
    local x1 = (self.canvasPanX or 0) + ((room.x or 0) * cell)
    local y1 = (self.canvasPanY or 0) + ((room.y or 0) * cell)
    local x2 = x1 + ((room.w or 1) * cell)
    local y2 = y1 + ((room.h or 1) * cell)
    local pad = 34
    local w, h = canvas:GetWidth() or 1, canvas:GetHeight() or 1
    if x2 > w - pad then self.canvasPanX = (self.canvasPanX or 0) - (x2 - (w - pad)) end
    if y2 > h - pad then self.canvasPanY = (self.canvasPanY or 0) - (y2 - (h - pad)) end
    if x1 < pad then self.canvasPanX = (self.canvasPanX or 0) + (pad - x1) end
    if y1 < pad then self.canvasPanY = (self.canvasPanY or 0) + (pad - y1) end
    if self.SaveCanvasView then self:SaveCanvasView() end
  end

  function panel:FitCanvasToLayout()
    local layout = activeLayout()
    if not layout or not layout.rooms or #layout.rooms == 0 then return end
    local minX, minY, maxX, maxY = 999999, 999999, 0, 0
    local activeFloor = self:GetActiveFloor()
    for _, room in ipairs(layout.rooms or {}) do
      if activeFloor == "all" or RoomFloor(room) == tonumber(activeFloor) then
        minX = min(minX, room.x or 0)
        minY = min(minY, room.y or 0)
        maxX = max(maxX, (room.x or 0) + (room.w or 1))
        maxY = max(maxY, (room.y or 0) + (room.h or 1))
      end
    end
    if minX == 999999 then return end
    local baseCellW = self.baseCellSize or 34
    local baseCellH = self.baseCellSize or 34
    local spanW = max(1, maxX - minX)
    local spanH = max(1, maxY - minY)
    local padX, padY = 46, 42
    local viewW = max(120, (canvas:GetWidth() or 1) - (padX * 2))
    local viewH = max(100, (canvas:GetHeight() or 1) - (padY * 2))
    local zoom = min(viewW / (spanW * baseCellW), viewH / (spanH * baseCellH))
    self.canvasZoom = max(0.14, min(2.4, zoom))
    local cellW = baseCellW * self.canvasZoom
    local cellH = baseCellH * self.canvasZoom
    self.canvasPanX = ((canvas:GetWidth() or 1) - (spanW * cellW)) / 2 - (minX * cellW)
    self.canvasPanY = ((canvas:GetHeight() or 1) - (spanH * cellH)) / 2 - (minY * cellH)
    if self.SaveCanvasView then self:SaveCanvasView() end
  end

  function panel:RefreshInspector()
    local room = selectedRoom()
    if not room then
      self.inspectorTitle:SetText("Room")
      self.roomName:SetText("")
      self.roomStats:SetText("Select a room on the canvas.")
      DrawGrid(self.selectedPreview, self.selectedPreview.gridPool, 8, 6, 2, 0.035)
      DrawShape(self.selectedPreview, selectedTemplate(), self.selectedPreview.pool, true, 0.72)
      return
    end

    self.inspectorTitle:SetText(room.name or "Room")
    self.roomName:SetText(room.name or "")
    self.roomStats:SetText("Cost: " .. tostring(sys:GetRoomCost(room)) ..
      "   Connections: " .. tostring(#(sys:GetRoomConnections(room) or {})) ..
      "   Rotation: " .. tostring(room.rotation or 0))
    DrawGrid(self.selectedPreview, self.selectedPreview.gridPool, 8, 6, 2, 0.035)
    DrawShape(self.selectedPreview, room, self.selectedPreview.pool, true, 0.72)
  end

  function panel:RefreshChanges()
    for _, row in ipairs(self.changeRows) do row:Hide() end
    local layout = activeLayout()
    local rowLimit = max(1, floor(((self.changesList and self.changesList:GetHeight()) or 112) / 21))
    for i, room in ipairs((layout and layout.rooms) or {}) do
      if i > rowLimit then break end
      local row = self.changeRows[i] or MakeChangeRow(i)
      row.name:SetText("+1 " .. (room.name or "Room"))
      row.cost:SetText(tostring(sys:GetRoomCost(room)))
      row:Show()
    end
  end

  function panel:RefreshTotals()
    local layout = activeLayout()
    if not layout then return end
    local valid = false
    local activeFloor = self:GetActiveFloor()
    for _, opt in ipairs(self:GetFloorOptions()) do
      if opt.value == activeFloor then valid = true break end
    end
    if not valid then self.activeFloor = "all" end
    if self.floorDropdown then
      if self.floorDropdown.ApplyText then
        self.floorDropdown:ApplyText()
      elseif self.floorDropdown.text then
        local label = "All"
        for _, opt in ipairs(self:GetFloorOptions()) do
          if opt.value == (self.activeFloor or "all") then label = opt.text break end
        end
        self.floorDropdown.text:SetText("Floor: " .. label:gsub("^Floor%s*", ""))
      end
    end
    if self.RefreshFloorVisibilityButton then self:RefreshFloorVisibilityButton() end
    local used, limit, owned, missing, roomCost = sys:LayoutBudget(layout)
    self.budgetBar._used, self.budgetBar._limit = roomCost, limit
    SetBar(self.budgetBar, roomCost, limit)
    self.budgetText:SetText("Room Budget  " .. tostring(roomCost or 0) .. " / " .. tostring(limit or 0))
    local db = sys:GetDB()
    local last = db and db.capture and db.capture.last
    if last then
      local msg = "Last capture: " .. tostring(last.roomCount or 0) .. " rooms"
      if last.roomCount == 0 then msg = msg .. " (API probe only)" end
      self.captureStatus:SetText(msg)
    else
      self.captureStatus:SetText("Capture: waiting for owned house")
    end
  end

  function panel:Refresh()
    local layout = activeLayout()
    local current = selectedRoom()
    local activeFloor = self:GetActiveFloor()
    if layout and self.hideOtherFloors and activeFloor ~= "all"
        and (not current or RoomFloor(current) ~= tonumber(activeFloor)) then
      self.selectedRoomID = nil
      for _, room in ipairs(layout.rooms or {}) do
        if RoomFloor(room) == tonumber(activeFloor) then
          self.selectedRoomID = room.id
          break
        end
      end
    elseif layout and (not self.selectedRoomID or not current) then
      self.selectedRoomID = layout.rooms and layout.rooms[1] and layout.rooms[1].id or nil
    end
    if self.layoutDropdown then
      if self.layoutDropdown.ApplyText then
        self.layoutDropdown:ApplyText()
      elseif self.layoutDropdown.text then
        self.layoutDropdown.text:SetText("Layout: " .. (layout and layout.name or ""))
      end
    end
    self:RefreshPalette()
    self:PositionRooms()
    self:RefreshInspector()
    self:RefreshChanges()
    self:RefreshTotals()
  end

  sortButton:SetScript("OnClick", function()
    if panel.sortMode == "costAsc" then
      panel.sortMode = "costDesc"
      sortButton.text:SetText("Cost (High to Low)")
    elseif panel.sortMode == "costDesc" then
      panel.sortMode = "nameAsc"
      sortButton.text:SetText("Name")
    else
      panel.sortMode = "costAsc"
      sortButton.text:SetText("Cost (Low to High)")
    end
    panel:RefreshPalette()
  end)

  roomName:SetScript("OnTextChanged", function(self)
    local room = selectedRoom()
    if room and self:HasFocus() then
      room.name = self:GetText() or room.name
      panel:PositionRooms()
      panel:RefreshChanges()
    end
  end)

  clearBtn:SetScript("OnClick", function()
    local layout = activeLayout()
    if layout then
      layout.rooms = {}
      panel.selectedRoomID = nil
      refresh()
    end
  end)

  deleteRoom:SetScript("OnClick", function()
    local layout = activeLayout()
    local room = selectedRoom()
    if layout and room then
      sys:DeleteRoom(layout, room.id)
      panel.selectedRoomID = nil
      refresh()
    end
  end)

  rotateRoom:SetScript("OnClick", function()
    local layout = activeLayout()
    local room = selectedRoom()
    if layout and room then
      sys:RotateRoom(layout, room.id, 1)
      refresh()
    end
  end)

  exportBtn:SetScript("OnClick", function()
    local layout = activeLayout()
    if layout then layout.currentFloor = tonumber(panel:GetActiveFloor()) or 1 end
    openSharePopup("export", sys:ExportWoWDBJSON(layout))
  end)

  local function importFromPopup()
    if panel.SaveCanvasView then panel:SaveCanvasView() end
    local layout, err = sys:ImportAny(shareBox:GetText() or "")
    if layout then
      panel.selectedRoomID = layout.rooms and layout.rooms[1] and layout.rooms[1].id or nil
      if panel.FitCanvasToLayout then panel:FitCanvasToLayout() end
      if sharePopup then sharePopup:Hide() end
      refresh()
    elseif DEFAULT_CHAT_FRAME then
      DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r " .. tostring(err))
    end
  end

  popupImport:SetScript("OnClick", importFromPopup)

  importBtn:SetScript("OnClick", function()
    openSharePopup("import", "")
  end)

  captureBtn:SetScript("OnClick", function()
    if panel.SaveCanvasView then panel:SaveCanvasView() end
    local layout, err, record = sys:CaptureCurrentHouse("manual")
    if layout then
      panel.activeFloor = "all"
      panel.hideOtherFloors = false
      panel.selectedRoomID = layout.rooms and layout.rooms[1] and layout.rooms[1].id or nil
      if panel.FitCanvasToLayout then panel:FitCanvasToLayout() end
      if panel.SaveCanvasView then panel:SaveCanvasView() end
      refresh()
      if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r Captured " .. tostring(record and record.roomCount or #layout.rooms) .. " rooms.") end
    elseif record and record.started then
      if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r Capture started. Stay in your house for " .. tostring(record.maxFloor or 1) .. " floor" .. ((record.maxFloor or 1) == 1 and "." or "s."))
      end
    else
      refresh()
      openSharePopup("debug", sys:GetLastCaptureDebugJSON())
      if DEFAULT_CHAT_FRAME then
        local probes = record and record.probeReport and #record.probeReport or 0
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r Capture probe complete: " .. tostring(err) .. " (" .. probes .. " API probes)")
      end
    end
  end)

  if NS.OnMessage then
    NS.OnMessage("HOMEDECOR_ARCHITECT_CAPTURED", function(layout, record)
      local rootUI = NS.UI
      if rootUI then
        local db = NS.db and NS.db.profile
        if db and db.ui then db.ui.activeCategory = "Architect" end
        rootUI.activeCategory = "Architect"
        if rootUI.CreateMainFrame and not rootUI.MainFrame then rootUI:CreateMainFrame() end
        if rootUI.MainFrame then
          rootUI.MainFrame:Show()
          if rootUI.MainFrame.view then rootUI.MainFrame.view:Hide() end
        end
      end
      if panel then
        panel:Show()
        if layout then
          panel.activeFloor = "all"
          panel.hideOtherFloors = false
          panel.selectedRoomID = layout.rooms and layout.rooms[1] and layout.rooms[1].id or panel.selectedRoomID
          if panel.FitCanvasToLayout then panel:FitCanvasToLayout() end
          if panel.SaveCanvasView then panel:SaveCanvasView() end
        end
        refresh()
      end
      if layout and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd24aHomeDecor Architect:|r Captured " .. tostring(record and record.roomCount or #(layout.rooms or {})) .. " live rooms from the house layout.")
      end
    end)
  end

  panel:SetScript("OnShow", function(self)
    if self.RestoreCanvasView then self:RestoreCanvasView(false) end
    self:Refresh()
  end)
  panel:SetScript("OnSizeChanged", function(self) self:PositionRooms() end)
  canvas:SetScript("OnSizeChanged", function() panel:PositionRooms() end)

  self.panel = panel
  return panel
end

return UIA
