local ADDON, NS = ...

NS.UI = NS.UI or {}

local C = {}
NS.UI.Controls = C
NS.UI.Util = NS.UI.Util or {}
C._backdropFrames = setmetatable({}, { __mode = "k" })

local unpack = _G.unpack or table.unpack
local min = math.min

local function GetTheme()
  local UI = NS.UI
  local Theme = UI and UI.Theme
  return Theme, Theme and Theme.colors, Theme and Theme.textures
end

function C:Backdrop(frame, bgColor, borderColor)
  if not frame then return end
  local _, colors = GetTheme()
  local themedBorder = colors and colors.border or borderColor
  self._backdropFrames[frame] = true
  frame.__hdBackdropBG = bgColor
  frame.__hdBackdropBorder = themedBorder

  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\Buttons\\WHITE8x8",
      tile = false,
      edgeSize = 1,
      insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
  end

  if frame.SetBackdropColor then
    if bgColor then
      frame:SetBackdropColor(unpack(bgColor))
    else
      frame:SetBackdropColor(0, 0, 0, 0.80)
    end
  end

  if frame.SetBackdropBorderColor then
    if themedBorder then
      frame:SetBackdropBorderColor(unpack(themedBorder))
    else
      frame:SetBackdropBorderColor(0.20, 0.20, 0.20, 1)
    end
  end
end

function C:RefreshRegisteredBorders()
  local _, colors = GetTheme()
  local border = colors and colors.border
  if not border then return end
  for frame in pairs(self._backdropFrames) do
    if frame and frame.SetBackdropBorderColor and frame.__hdBackdropBorder then
      frame.__hdBackdropBorder = border
      frame:SetBackdropBorderColor(unpack(border))
    end
  end
end

local function GetAppearance()
  local profile = NS.db and NS.db.profile
  local ui = profile and profile.ui
  return ui and ui.appearance or {}
end

local function ApplyFontString(fs, opts)
  if not fs or not fs.GetFont or not fs.SetFont then return end
  if not fs.__hdBaseFont then
    local path, size, flags = fs:GetFont()
    if not path or not size then return end
    fs.__hdBaseFont = { path, size, flags }
  end
  local base = fs.__hdBaseFont
  local Theme = NS.UI and NS.UI.Theme
  local text = fs.GetText and fs:GetText() or ""
  local path = Theme and Theme.ResolveFontForText and Theme:ResolveFontForText(text) or base[1]
  local scale = tonumber(opts.fontScale) or 1
  fs:SetFont(path, math.max(7, base[2] * scale), base[3])
end

function C:RefreshAppearance(root, refreshColors)
  if not root then return end
  local opts = GetAppearance()
  local _, colors = GetTheme()

  local function apply(frame)
    if refreshColors and frame.__hdBackdropBG and not frame.__hdPreserveBackdrop and frame.SetBackdropColor then
      frame:SetBackdropColor(unpack(frame.__hdBackdropBG))
    end
    if refreshColors and frame.__hdBackdropBorder and frame.SetBackdropBorderColor then
      frame.__hdBackdropBorder = colors and colors.border or frame.__hdBackdropBorder
      frame:SetBackdropBorderColor(unpack(frame.__hdBackdropBorder))
    end
    if frame.GetRegions then
      for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
          ApplyFontString(region, opts)
          if refreshColors and region.__hdTextRole then
            self:TextColor(region, region.__hdTextRole, region.__hdTextAlpha)
          end
        elseif refreshColors and region and region.__hdSolidColorRole then
          self:SolidColor(region, region.__hdSolidColorRole, region.__hdSolidColorAlpha)
        elseif refreshColors and region and region.__hdColorRole then
          self:TextureColor(region, region.__hdColorRole, region.__hdColorAlpha)
        end
      end
    end
  end

  local function walk(frame)
    apply(frame)
    if not frame.GetChildren then return end
    for _, child in ipairs({ frame:GetChildren() }) do
      walk(child)
    end
  end

  walk(root)
end

function C:TextColor(fontString, role, alpha)
  if not fontString then return end
  fontString.__hdTextRole = role or "text"
  fontString.__hdTextAlpha = alpha
  local _, colors = GetTheme()
  local color = colors and colors[role or "text"]
  if color and fontString.SetTextColor then
    fontString:SetTextColor(color[1], color[2], color[3], alpha or color[4] or 1)
  end
end

function C:TextureColor(texture, role, alpha)
  if not texture then return end
  texture.__hdColorRole = role or "accent"
  texture.__hdColorAlpha = alpha
  local _, colors = GetTheme()
  local color = colors and colors[texture.__hdColorRole]
  if color and texture.SetVertexColor then
    texture:SetVertexColor(color[1], color[2], color[3], alpha or color[4] or 1)
  end
end

function C:SolidColor(texture, role, alpha)
  if not texture then return end
  texture.__hdSolidColorRole = role or "accent"
  texture.__hdSolidColorAlpha = alpha
  local _, colors = GetTheme()
  local color = colors and colors[texture.__hdSolidColorRole]
  if color and texture.SetColorTexture then
    texture:SetColorTexture(color[1], color[2], color[3], alpha or color[4] or 1)
  end
end

function NS.UI.Util.SetFont(fontString, size, flags)
  if not fontString or not fontString.SetFont then return end
  local appearance = GetAppearance()
  local Theme = NS.UI and NS.UI.Theme
  local path = Theme and Theme.ResolveFontForText and Theme:ResolveFontForText(fontString:GetText() or "")
    or STANDARD_TEXT_FONT
  fontString:SetFont(path, math.max(7, size * (tonumber(appearance.fontScale) or 1)), flags or "")
end

function C:ApplyHover(btn, bgNormal, bgHover, borderNormal, borderHover)
  if not btn then return end
  if not btn.backdropInfo and not btn.SetBackdrop then
    if Mixin and BackdropTemplateMixin then
      Mixin(btn, BackdropTemplateMixin)
    end
  end

  local _, T = GetTheme()
  local nbg = bgNormal or (T and T.row) or { 0.08, 0.08, 0.10, 1 }
  local hbg = bgHover or (T and T.hover) or { 0.14, 0.14, 0.17, 1 }
  local nbd = (T and T.border) or borderNormal or { 0.35, 0.28, 0.14, 0.9 }
  local hbd = borderHover or (T and T.accentSoft) or { 0.92, 0.78, 0.45, 0.55 }

  if not btn.__hdHasBackdrop then
    self:Backdrop(btn, nbg, nbd)
    btn.__hdHasBackdrop = true
  end

  local function setColors(bg, bd)
    if btn.SetBackdropColor then
      btn:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
    end
    if btn.SetBackdropBorderColor then
      btn:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4] or 1)
    end
  end

  setColors(nbg, nbd)

  if btn.__hdHoverHooked then return end
  btn.__hdHoverHooked = true

  btn:HookScript("OnEnter", function() setColors(hbg, hbd) end)
  btn:HookScript("OnLeave", function() setColors(nbg, nbd) end)
  if not btn.__hdBtnSkinned then
    btn:HookScript("OnMouseDown", function()
      setColors({ hbg[1] * 0.85, hbg[2] * 0.85, hbg[3] * 0.85, hbg[4] }, hbd)
    end)
    btn:HookScript("OnMouseUp", function()
      if btn.IsMouseOver and btn:IsMouseOver() then
        setColors(hbg, hbd)
      else
        setColors(nbg, nbd)
      end
    end)
  end
  btn:HookScript("OnDisable", function()
    setColors({ nbg[1], nbg[2], nbg[3], 0.55 }, { nbd[1], nbd[2], nbd[3], 0.35 })
  end)
  btn:HookScript("OnEnable", function()
    setColors(nbg, nbd)
  end)
end

function C:Segmented(parent, labels, getValue, setValue)
  local _, T = GetTheme()
  labels = labels or {}

  local f = CreateFrame("Frame", nil, parent)
  f:SetHeight(24)

  local btns = {}
  local pad = 2
  local bw = (#labels >= 2) and 44 or 46
  f:SetWidth(#labels * bw + (#labels - 1) * pad)

  local function styleSelected(b, selected)
    if not b then return end
    local bg = b.__hdNormalBG
    if selected then
      if bg then
        bg:SetVertexColor(unpack(T.accent))
        bg:SetAlpha(0.22)
      end
      if b.text then
        self:TextColor(b.text, "highlight")
      end
    else
      if bg then
        bg:SetVertexColor(1, 1, 1, 1)
        bg:SetAlpha(1.0)
      end
      if b.text then
        self:TextColor(b.text, "textMuted")
      end
    end
  end

  local function refresh()
    local cur = getValue and getValue() or nil
    for i = 1, #btns do
      styleSelected(btns[i], labels[i] == cur)
    end
  end

  for i = 1, #labels do
    local label = labels[i]
    local b = CreateFrame("Button", nil, f, "BackdropTemplate")
    b:SetSize(bw, 24)

    if i == 1 then
      b:SetPoint("LEFT", f, "LEFT", 0, 0)
    else
      b:SetPoint("LEFT", btns[i - 1], "RIGHT", pad, 0)
    end

    self:Backdrop(b, T and T.panel, T and T.border)
    self:ApplyHover(b, T and T.panel, T and T.hover, T and T.border, T and T.accentSoft)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.text:SetPoint("CENTER", 0, 0)
    b.text:SetText(label)

    b:SetScript("OnClick", function()
      if setValue then
        setValue(label)
      end
      refresh()
      if f.OnValueChanged then
        f:OnValueChanged(label)
      end
    end)

    btns[i] = b
  end

  f.buttons = btns
  f.Refresh = refresh
  f:SetScript("OnShow", refresh)
  refresh()
  return f
end

function C:SetSelected(frame, selected, normal, selectedBG)
  if not frame or not frame.SetBackdropColor then return end
  frame._selected = selected and true or false

  if selected then
    if selectedBG then
      frame:SetBackdropColor(unpack(selectedBG))
    else
      frame:SetBackdropColor(0.90, 0.75, 0.35, 0.20)
    end
  else
    if normal then
      frame:SetBackdropColor(unpack(normal))
    end
  end
end

function C:SkinButton(btn, isTab)
  if not btn or btn.__hdBtnSkinned then return end

  btn.__hdBtnSkinned = true

  if btn.GetNumRegions and btn.GetRegions then
    for i = 1, btn:GetNumRegions() do
      local r = select(i, btn:GetRegions())
      if r and r.GetObjectType and r:GetObjectType() == "FontString" and r.SetDrawLayer then
        r:SetDrawLayer("OVERLAY", 7)
      end
    end
  end

  if btn.text and btn.text.SetDrawLayer then
    btn.text:SetDrawLayer("OVERLAY", 7)
  end
end

function C:SkinScrollFrame(sf)
  if not sf then return end

  local function looksLikeScrollBar(child)
    return child and (
      child.Thumb or child.ThumbTexture or child.Track or
      (child.GetThumb and child:GetThumb()) or
      (child.GetThumbTexture and child:GetThumbTexture())
    )
  end

  local sb = sf.ScrollBar or sf.scrollBar or (sf.GetScrollBar and sf:GetScrollBar())
  if not sb and sf.GetName then
    local name = sf:GetName()
    if name then
      sb = _G[name .. "ScrollBar"] or _G[name .. "ScrollBarScrollBar"]
    end
  end
  if not sb and sf.GetChildren then
    for i = 1, sf:GetNumChildren() do
      local child = select(i, sf:GetChildren())
      if looksLikeScrollBar(child) then
        sb = child
        break
      end
    end
  end
  if not sb then
    if not sf.__hdSkinRetry and C_Timer and C_Timer.After then
      sf.__hdSkinRetry = true
      C_Timer.After(0, function()
        if sf and sf.GetObjectType then C:SkinScrollFrame(sf) end
      end)
    end
    return
  end
  sf.__hdSkinRetry = nil

  local hasModernThumb = sb.Thumb or (sb.Track and sb.Track.Thumb) or (sb.GetThumb and sb:GetThumb())
  if hasModernThumb and sb.SetPoint and sb ~= sf then
    sb:ClearAllPoints()
    sb:SetPoint("TOPLEFT", sf, "TOPRIGHT", 2, -2)
    sb:SetPoint("BOTTOMLEFT", sf, "BOTTOMRIGHT", 2, 2)
  end

  local function tint(owner, alpha)
    if not owner then return end
    if owner.GetObjectType and owner:GetObjectType() == "Texture" then
      self:TextureColor(owner, "accent", alpha)
      return
    end
    if owner.GetNumRegions then
      for i = 1, owner:GetNumRegions() do
        local r = select(i, owner:GetRegions())
        if r and r.GetObjectType and r:GetObjectType() == "Texture" then
          self:TextureColor(r, "accent", alpha)
        end
      end
    end
    if owner.GetNumChildren then
      for i = 1, owner:GetNumChildren() do
        tint(select(i, owner:GetChildren()), alpha)
      end
    end
  end

  local thumbBtn = sb.Thumb or (sb.Track and sb.Track.Thumb) or (sb.GetThumb and sb:GetThumb())
  local classicThumb = (sb.GetThumbTexture and sb:GetThumbTexture()) or sb.ThumbTexture

  if thumbBtn then
    tint(thumbBtn, 0.9)
  elseif classicThumb then
    self:TextureColor(classicThumb, "accent", 0.9)
  end

  tint(sb.Back or sb.UpButton or sb.ScrollUpButton, 0.9)
  tint(sb.Forward or sb.DownButton or sb.ScrollDownButton, 0.9)
end

function C:ClearHoverHighlights(root)
  if not root or type(root) ~= "table" or not root.GetChildren then return end

  local stack = { root }
  local idx = 1

  while stack[idx] do
    local f = stack[idx]
    idx = idx + 1

    local rs = f._rsHL
    if rs and rs.Hide then
      rs:Hide()
    end

    local hl = f._hl
    if hl then
      if hl.SetAlpha then hl:SetAlpha(0) end
      if hl.Hide then hl:Hide() end
    end

    local ok, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 = pcall(f.GetChildren, f)
    if ok then
      local children = { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10 }
      if #children == 10 then
        children = { f:GetChildren() }
      end
      for i = 1, #children do
        local ch = children[i]
        if ch then
          stack[#stack + 1] = ch
        end
      end
    end
  end
end

function C:SyncScrollChildWidth(scroll, content)
  if not (scroll and content) then return end
  local sw = scroll:GetWidth()
  if sw and sw > 1 then
    content:SetWidth(sw)
  end
end

return C
