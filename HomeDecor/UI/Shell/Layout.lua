local ADDON, NS = ...

NS.UI = NS.UI or {}
local L = NS.UI.Layout or {}
NS.UI.Layout = L
local Loc = NS.L

local Dropdown = NS.UI.Dropdown

local C = NS.UI.Controls
local Theme = NS.UI.Theme
local T = (Theme and Theme.colors) or {}
local Textures = (Theme and Theme.textures) or nil

local FiltersSys = NS.Systems and NS.Systems.Filters
local GlobalIndex = NS.Systems and NS.Systems.GlobalIndex
local Collection = NS.Systems and NS.Systems.Collection

local CreateFrame = CreateFrame
local UIParent = UIParent
local tinsert = tinsert
local unpack = unpack
local ipairs = ipairs
local strlower = string.lower
local format = string.format
local GetMouseFocus = GetMouseFocus

local ACCENT = T.accent or { 1, 0.82, 0.2, 1 }
local BORDER = T.border or { 0.20, 0.20, 0.20, 1 }
local TEXT_MUTED = T.textMuted or { 1, 1, 1, 0.55 }
local PLACEHOLDER = T.placeholder or { 1, 1, 1, 0.35 }

local function getDB()
  local profile = NS.db and NS.db.profile
  if not profile then return nil end

  local ui = profile.ui
  if not ui then ui = {}; profile.ui = ui end
  if not ui.viewMode then ui.viewMode = "Icon" end
  if not ui.catalogMode then ui.catalogMode = "All Items" end
  if ui.detailsPanelOpen == nil then ui.detailsPanelOpen = true end
  if not ui.activeCategory then ui.activeCategory = "All" end
  if not ui.expanded then ui.expanded = {} end
  if ui.search == nil then ui.search = "" end
  if not ui.sortMode then ui.sortMode = "expAsc" end
  if ui.compactMode == nil then ui.compactMode = false end
  if not ui.designPreset then ui.designPreset = "gallery" end
  if not ui.galleryDesignApplied then
    ui.galleryDesignApplied = true
    ui.designPreset = "gallery"
    ui.activeCategory = "All"
    ui.catalogMode = "All Items"
  end
  if (ui.galleryDesignVersion or 0) < 3 then
    ui.galleryDesignVersion = 3
  end

  profile.filters = profile.filters or {}
  if FiltersSys and FiltersSys.EnsureDefaults then
    FiltersSys:EnsureDefaults(profile)
  end

  profile.favorites = profile.favorites or {}
  return profile
end

local function Backdrop(f, bg, border)
  if C and C.Backdrop then C:Backdrop(f, bg, border) end
end

local function Hover(b, base, hover)
  if C and C.ApplyHover then C:ApplyHover(b, base, hover) end
end

local function SkinBtn(b)
  if C and C.SkinButton then C:SkinButton(b, true) end
end

local function NewFS(parent, template)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  if C and C.TextColor then C:TextColor(fs, "text") end
  return fs
end

local function TextColor(fs, role, alpha)
  if C and C.TextColor then
    C:TextColor(fs, role, alpha)
  end
end

local function Trim(s)
  if not s or s == "" then return "" end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function LiveFiltersSys()
  return (NS.Systems and NS.Systems.Filters) or FiltersSys
end

local communityPopup

local function ShowCommunityPopup()
  if communityPopup then
    communityPopup:Show()
    return
  end

  local p = CreateFrame("Frame", "HomeDecorCommunityPopup", UIParent, "BackdropTemplate")
  communityPopup = p

  if UISpecialFrames then
    tinsert(UISpecialFrames, "HomeDecorCommunityPopup")
  end

  p:SetSize(560, 360)
  p:SetPoint("CENTER")
  p:SetFrameStrata("FULLSCREEN_DIALOG")
  p:SetFrameLevel(9999)
  p:SetToplevel(true)
  p:SetClampedToScreen(true)

  Backdrop(p, T.panel, T.border)

  p:EnableMouse(true)
  p:SetMovable(true)
  p:RegisterForDrag("LeftButton")
  p:SetScript("OnDragStart", p.StartMoving)
  p:SetScript("OnDragStop", p.StopMovingOrSizing)
  p:SetPropagateKeyboardInput(true)
  p:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then self:Hide() end
  end)

  local header = CreateFrame("Frame", nil, p, "BackdropTemplate")
  Backdrop(header, T.header, T.border)
  header:SetPoint("TOPLEFT", 6, -6)
  header:SetPoint("TOPRIGHT", -6, -6)
  header:SetHeight(48)

  local title = NewFS(header, "GameFontNormalLarge")
  title:SetPoint("CENTER")
  title:SetText(Loc["COMMUNITY"])
  TextColor(title, "accent")

  local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  Backdrop(closeBtn, T.panel, T.border)
  closeBtn:SetSize(26, 26)
  closeBtn:SetPoint("RIGHT", header, "RIGHT", -10, 0)
  Hover(closeBtn, T.panel, T.hover)

  local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
  closeIcon:SetSize(14, 14)
  closeIcon:SetPoint("CENTER")
  closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
  C:TextureColor(closeIcon, "accent")

  closeBtn:SetScript("OnClick", function() p:Hide() end)

  local div = p:CreateTexture(nil, "ARTWORK")
  div:SetColorTexture(1, 1, 1, 0.12)
  div:SetHeight(1)
  div:SetPoint("TOPLEFT", 12, -60)
  div:SetPoint("TOPRIGHT", -12, -60)

  local links = {
    { Loc["JOIN_DISCORD"], "https://discord.gg/G2gCV9Zc57" },
    { Loc["SUPPORT_BUYMEACOFFEE"], "https://buymeacoffee.com/azroaddons" },
    { Loc["DONATE_PAYPAL"], "https://www.paypal.com/donate/?business=Jhookftw1@hotmail.com" },
    { Loc["SHARE_HOMEDECOR"], "https://www.curseforge.com/wow/addons/home-decor" },
  }

  local function Highlight(self)
    self:SetFocus()
    self:HighlightText()
  end

  local y = -78
  local gap = 60

  for i = 1, #links do
    local info = links[i]

    local label = NewFS(p, "GameFontNormal")
    label:SetPoint("TOPLEFT", 16, y - ((i - 1) * gap))
    label:SetText(info[1])
    TextColor(label, "text", 0.95)

    local edit = CreateFrame("EditBox", nil, p, "InputBoxTemplate")
    edit:SetAutoFocus(false)
    edit:SetHeight(30)
    edit:SetPoint("TOPLEFT", label, "BOTTOMLEFT", -6, -6)
    edit:SetPoint("RIGHT", -16, 0)
    edit:SetTextInsets(12, 12, 0, 0)
    edit:SetFontObject("GameFontHighlight")
    edit:SetText(info[2])

    edit:SetScript("OnMouseUp", Highlight)
    edit:SetScript("OnEditFocusGained", Highlight)
    edit:SetScript("OnEscapePressed", function() p:Hide() end)
    edit:SetScript("OnEnterPressed", function() p:Hide() end)
  end

  p:Show()
end

local function findScaleWidgetsOnce(header)
  if not header or not header.GetChildren then return nil end
  if header._hdScale then return header._hdScale[1], header._hdScale[2], header._hdScale[3] end

  local label, slider, value

  local function scan(f, depth)
    if not f or depth > 7 or label then return end

    if f.GetText then
      local ok, t = pcall(f.GetText, f)
      if ok and t == "Scale" then
        label = f
        local parent = f.GetParent and f:GetParent() or nil
        if parent and parent.GetChildren then
          local kids = { parent:GetChildren() }
          for i = 1, #kids do
            local c = kids[i]
            if c ~= f and c and c.GetObjectType then
              local ot = c:GetObjectType()
              if not slider and ot == "Slider" then
                slider = c
              elseif not value and (ot == "EditBox" or ot == "FontString" or ot == "Frame") then
                value = c
              end
            end
          end
        end
      end
    end

    if not label and f.GetChildren then
      local kids = { f:GetChildren() }
      for i = 1, #kids do
        scan(kids[i], depth + 1)
        if label then break end
      end
    end
  end

  scan(header, 0)
  header._hdScale = { label, slider, value }
  return label, slider, value
end

local function dockScale(frame, header)
  if not frame or not header then return end
  local host = header
  if not host then return end
  local group = frame._resizeWidget
  if not group then return end

  header.scaleGroup = group

  if group:GetParent() ~= host then
    group:SetParent(host)
  end

  group:ClearAllPoints()
  group:SetPoint("TOPLEFT", host, "TOPLEFT", 12, -12)
  group:SetSize(218, 17)
  group:Show()
end

local function CreateCategoryIndicators(btn)
  if not btn or btn._hdHasIndicators then return end
  btn._hdHasIndicators = true

  local bg = btn:CreateTexture(nil, "BACKGROUND")
  btn.selBG = bg
  bg:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
  bg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
  bg:SetColorTexture(1, 1, 1, 0.07)
  bg:Hide()

  local function edge()
    local t = btn:CreateTexture(nil, "BORDER")
    t:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.30)
    t:Hide()
    return t
  end

  btn.selTop, btn.selBottom, btn.selLeft, btn.selRight = edge(), edge(), edge(), edge()

  btn.selTop:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
  btn.selTop:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
  btn.selTop:SetHeight(1)

  btn.selBottom:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2, 2)
  btn.selBottom:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
  btn.selBottom:SetHeight(1)

  btn.selLeft:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
  btn.selLeft:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2, 2)
  btn.selLeft:SetWidth(1)

  btn.selRight:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
  btn.selRight:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
  btn.selRight:SetWidth(1)
end

local function SetCategorySelected(btn, selected)
  if not btn then return end
  local show = selected and true or false
  btn._hdNavSelected = show
  if btn.navBG and Textures then
    btn.navBG:SetTexture(show and (Textures.GalleryNavSelected or Textures.GalleryNav) or (Textures.GalleryNav or ""))
    btn.navBG:SetAlpha(show and 1 or 0.86)
  end
  if btn.selBG then btn.selBG:SetShown(show) end
  if btn.selTop then btn.selTop:SetShown(show) end
  if btn.selBottom then btn.selBottom:SetShown(show) end
  if btn.selLeft then btn.selLeft:SetShown(show) end
  if btn.selRight then btn.selRight:SetShown(show) end

  if btn.text then
    if selected then
      TextColor(btn.text, "highlight", 0.95)
    else
      TextColor(btn.text, "text")
    end
  end
end

local function ApplyNavArt(btn)
  if not (btn and btn.CreateTexture and Textures and Textures.GalleryNav) then return end
  if not btn.navBG then
    btn.navBG = btn:CreateTexture(nil, "BACKGROUND", nil, -3)
    btn.navBG:SetAllPoints(btn)
  end
  btn.navBG:SetTexture(Textures.GalleryNav)

  if btn.GetHighlightTexture then
    local ht = btn:GetHighlightTexture()
    if ht then ht:SetAlpha(0) end
  end

  if not btn._hdNavArtHooked then
    btn._hdNavArtHooked = true
    btn:HookScript("OnEnter", function(self)
      if self.navBG and Textures then
        self.navBG:SetTexture(self._hdNavSelected and (Textures.GalleryNavSelected or Textures.GalleryNav) or (Textures.GalleryNavHover or Textures.GalleryNav))
        self.navBG:SetAlpha(1)
      end
      if self.icon and self.icon.SetDrawLayer then self.icon:SetDrawLayer("OVERLAY", 7) end
      if self.text and self.text.SetDrawLayer then self.text:SetDrawLayer("OVERLAY", 7) end
    end)
    btn:HookScript("OnLeave", function(self)
      if self.navBG and Textures then
        self.navBG:SetTexture(self._hdNavSelected and (Textures.GalleryNavSelected or Textures.GalleryNav) or (Textures.GalleryNav or ""))
        self.navBG:SetAlpha(self._hdNavSelected and 1 or 0.86)
      end
      if self.icon and self.icon.SetDrawLayer then self.icon:SetDrawLayer("OVERLAY", 7) end
      if self.text and self.text.SetDrawLayer then self.text:SetDrawLayer("OVERLAY", 7) end
    end)
  end

  if btn.icon and btn.icon.SetDrawLayer then btn.icon:SetDrawLayer("OVERLAY", 7) end
  if btn.text and btn.text.SetDrawLayer then btn.text:SetDrawLayer("OVERLAY", 7) end

  if btn.SetHighlightTexture then
    local blank = btn:CreateTexture(nil, "HIGHLIGHT")
    blank:SetColorTexture(1, 1, 1, 0)
    blank:SetAllPoints(btn)
    btn:SetHighlightTexture(blank)
    local ht = btn:GetHighlightTexture()
    if ht then
      ht:SetAlpha(0)
    end
  end
end

function L:CreateShell()
  local db = getDB()
  if not db or not C then return nil end

  local UI = db.ui
  local Filters = db.filters

  local f = CreateFrame("Frame", "HomeDecorFrame", UIParent, "BackdropTemplate")
  Backdrop(f, T.bg, T.border)

  if C.ApplyBackground and Textures and Textures.MainBackground then
    C:ApplyBackground(f, Textures.MainBackground, 8, 1)
  end

  f:SetSize(1320, 760)
  f:SetPoint("CENTER")

  local function rerender()
    local v = f.view
    if v and v.RequestRender then
      v:RequestRender(true)
    elseif v and v.Render then
      v:Render()
    end
  end

  local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
  Backdrop(header, T.header, T.border)
  header:SetBackdropColor(0, 0, 0, 0)
  header:SetBackdropBorderColor(unpack(BORDER))
  header:SetPoint("TOPLEFT", 8, -8)
  header:SetPoint("TOPRIGHT", -8, -8)
  header:SetHeight(62)
  header:EnableMouse(false)
  header.__hdPreserveBackdrop = true
  f.Header = header

  local headerShade = header:CreateTexture(nil, "BACKGROUND", nil, -2)
  headerShade:SetPoint("TOPLEFT", header, "TOPLEFT", 1, -1)
  headerShade:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -1, 1)
  headerShade:SetColorTexture(0.018, 0.018, 0.022, 0.88)

  local headerTopLine = header:CreateTexture(nil, "ARTWORK")
  headerTopLine:SetPoint("TOPLEFT", header, "TOPLEFT", 8, -5)
  headerTopLine:SetPoint("TOPRIGHT", header, "TOPRIGHT", -8, -5)
  headerTopLine:SetHeight(1)
  headerTopLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.18)

  local headerBottomLine = header:CreateTexture(nil, "ARTWORK")
  headerBottomLine:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 8, 4)
  headerBottomLine:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -8, 4)
  headerBottomLine:SetHeight(1)
  headerBottomLine:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.28)

  header.controls = CreateFrame("Frame", nil, header)
  header.controls:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 8, 4)
  header.controls:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -8, 4)
  header.controls:SetHeight(24)
  header.controls:EnableMouse(false)
  Backdrop(header.controls, T.panel, T.border)
  if C.ApplyHeaderTexture then C:ApplyHeaderTexture(header.controls, false) end

  local logo = header:CreateTexture(nil, "ARTWORK")
  header.logo = logo

  if Textures and Textures.Logo then
    logo:SetTexture(Textures.Logo)
  else
    logo:SetColorTexture(1, 0.82, 0.2, 1)
  end

  logo:SetSize(430, 44)
  logo:SetPoint("TOP", header, "TOP", 0, -8)
  logo:SetTexCoord(0, 1, 0, 1)
  logo:SetAlpha(1)

  local logoUnder = header:CreateTexture(nil, "ARTWORK")
  logoUnder:SetPoint("TOP", logo, "BOTTOM", 0, 1)
  logoUnder:SetSize(360, 2)
  logoUnder:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.34)

  local logoUnderSoft = header:CreateTexture(nil, "ARTWORK")
  logoUnderSoft:SetPoint("TOP", logoUnder, "BOTTOM", 0, -2)
  logoUnderSoft:SetSize(260, 1)
  logoUnderSoft:SetColorTexture(1, 1, 1, 0.08)

  local leftOrnament = header:CreateTexture(nil, "ARTWORK")
  leftOrnament:SetPoint("RIGHT", logo, "LEFT", -20, -2)
  leftOrnament:SetSize(190, 1)
  leftOrnament:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

  local rightOrnament = header:CreateTexture(nil, "ARTWORK")
  rightOrnament:SetPoint("LEFT", logo, "RIGHT", 20, -2)
  rightOrnament:SetSize(190, 1)
  rightOrnament:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.20)

  local leftCap = header:CreateTexture(nil, "ARTWORK")
  leftCap:SetPoint("RIGHT", leftOrnament, "LEFT", -8, 0)
  leftCap:SetSize(28, 3)
  leftCap:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.32)

  local rightCap = header:CreateTexture(nil, "ARTWORK")
  rightCap:SetPoint("LEFT", rightOrnament, "RIGHT", 8, 0)
  rightCap:SetSize(28, 3)
  rightCap:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.32)

  local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  header.closeBtn = closeBtn
  Backdrop(closeBtn, T.panel, T.border)
  closeBtn:SetSize(22, 22)
  closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", -10, -9)
  Hover(closeBtn, T.panel, T.hover)

  local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
  closeBtn.icon = closeIcon
  closeIcon:SetSize(14, 14)
  closeIcon:SetPoint("CENTER", 0, 0)
  closeIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
  C:TextureColor(closeIcon, "accent")
  closeBtn:SetFrameLevel(header:GetFrameLevel() + 6)
  closeIcon:SetDrawLayer("OVERLAY", 7)

  closeBtn:SetScript("OnClick", function()
    if f and f.Hide then f:Hide() end
  end)

  local settingsBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  header.settingsBtn = settingsBtn
  Backdrop(settingsBtn, T.panel, T.border)
  settingsBtn:SetSize(22, 22)
  settingsBtn:SetPoint("RIGHT", closeBtn, "LEFT", -6, 0)
  settingsBtn:SetFrameLevel(header:GetFrameLevel() + 6)
  Hover(settingsBtn, T.panel, T.hover)

  local settingsIcon = settingsBtn:CreateTexture(nil, "OVERLAY")
  settingsBtn.icon = settingsIcon
  settingsIcon:SetSize(16, 16)
  settingsIcon:SetPoint("CENTER", 0, 0)
  settingsIcon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  C:TextureColor(settingsIcon, "accent")

  settingsBtn:SetScript("OnClick", function()
    local popup = NS.UI and NS.UI.SettingsPopup
    if popup and popup.Toggle then popup:Toggle(f, settingsBtn) end
  end)
  settingsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("HomeDecor Settings", 1, 1, 1)
    GameTooltip:Show()
  end)
  settingsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  local trackersBtn = CreateFrame("Button", nil, header.controls, "BackdropTemplate")
  header.trackersBtn = trackersBtn
  Backdrop(trackersBtn, T.panel, T.border)
  trackersBtn:SetSize(88, 20)
  trackersBtn:SetPoint("RIGHT", header.controls, "RIGHT", -8, 0)
  Hover(trackersBtn, T.panel, T.hover)

  local trackersText = NewFS(trackersBtn, "GameFontNormal")
  trackersBtn.text = trackersText
  trackersText:SetPoint("CENTER", -6, 0)
  trackersText:SetText(Loc["TRACKERS"])
  TextColor(trackersText, "text")
  trackersBtn:SetFrameLevel(header:GetFrameLevel() + 6)
  trackersText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
  trackersText:SetShadowColor(0, 0, 0, 0)
  trackersText:SetShadowOffset(0, 0)
  trackersText:SetDrawLayer("OVERLAY", 7)

  local arrow = trackersBtn:CreateTexture(nil, "OVERLAY")
  arrow:SetSize(8, 8)
  arrow:SetPoint("RIGHT", trackersBtn, "RIGHT", -6, 0)
  arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
  C:TextureColor(arrow, "accent")

  local trackersMenu = CreateFrame("Frame", nil, trackersBtn, "BackdropTemplate")
  trackersMenu:SetFrameStrata("FULLSCREEN_DIALOG")
  trackersMenu:SetFrameLevel(trackersBtn:GetFrameLevel() + 10)
  trackersMenu:Hide()
  Backdrop(trackersMenu, T.panel, T.border)
  trackersMenu:SetSize(140, 60)
  trackersMenu:SetPoint("TOP", trackersBtn, "BOTTOM", 0, -2)

  local decorOption = CreateFrame("Button", nil, trackersMenu, "BackdropTemplate")
  Backdrop(decorOption, T.panel, T.border)
  decorOption:SetPoint("TOPLEFT", 4, -4)
  decorOption:SetPoint("TOPRIGHT", -4, -4)
  decorOption:SetHeight(24)
  Hover(decorOption, T.panel, T.hover)

  local decorText = NewFS(decorOption, "GameFontNormal")
  decorText:SetPoint("CENTER", 0, 0)
  decorText:SetText(Loc["DECOR_TRACKER"])
  TextColor(decorText, "text")

  decorOption:SetScript("OnClick", function()
    local Tr = (NS.UI and NS.UI.Tracker) or (NS.UI and NS.UI.DecorTracker) or NS.Tracker
    if Tr and Tr.Toggle then Tr:Toggle() end
    trackersMenu:Hide()
  end)

  local lumberOption = CreateFrame("Button", nil, trackersMenu, "BackdropTemplate")
  Backdrop(lumberOption, T.panel, T.border)
  lumberOption:SetPoint("TOPLEFT", decorOption, "BOTTOMLEFT", 0, -4)
  lumberOption:SetPoint("TOPRIGHT", decorOption, "BOTTOMRIGHT", 0, -4)
  lumberOption:SetHeight(24)
  Hover(lumberOption, T.panel, T.hover)

  local lumberText = NewFS(lumberOption, "GameFontNormal")
  lumberText:SetPoint("CENTER", 0, 0)
  lumberText:SetText(Loc["LUMBER_TRACKER"] or "Gather Tracker")
  TextColor(lumberText, "text")

  lumberOption:SetScript("OnClick", function()
    local GT = (NS.UI and NS.UI.GatherTrack)
    if GT and GT.ToggleAll then
      GT:ToggleAll()
    else
      local LT = (NS.UI and NS.UI.LumberTrack) or NS.LumberTrack
      if LT and LT.Toggle then LT:Toggle() end
    end
    trackersMenu:Hide()
  end)

  trackersBtn:SetScript("OnClick", function()
    if trackersMenu:IsShown() then
      trackersMenu:Hide()
    else
      trackersMenu:Show()
    end
  end)

  trackersMenu:SetScript("OnShow", function(self)
    self._hideTimer = nil
    self:SetScript("OnUpdate", function(self, elapsed)
      local mouseOver = MouseIsOver(self) or MouseIsOver(trackersBtn) or
                        MouseIsOver(decorOption) or MouseIsOver(lumberOption)

      if not mouseOver then
        if not self._hideTimer then
          self._hideTimer = 0
        end
        self._hideTimer = self._hideTimer + elapsed

        if self._hideTimer >= 0.3 then
          self:Hide()
        end
      else
        self._hideTimer = nil
      end
    end)
  end)

  trackersMenu:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
    self._hideTimer = nil
  end)

  local compactBtn = CreateFrame("Button", nil, header.controls, "BackdropTemplate")
  header.compactBtn = compactBtn
  Backdrop(compactBtn, T.panel, T.border)
  compactBtn:SetSize(72, 20)
  compactBtn:SetPoint("RIGHT", trackersBtn, "LEFT", -6, 0)
  Hover(compactBtn, T.panel, T.hover)

  local compactText = NewFS(compactBtn, "GameFontNormal")
  compactBtn.text = compactText
  compactText:SetPoint("CENTER", 0, 0)
  compactText:SetText("Compact")
  TextColor(compactText, "text")
  compactBtn:SetFrameLevel(header:GetFrameLevel() + 6)
  compactText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
  compactText:SetShadowColor(0, 0, 0, 0)
  compactText:SetShadowOffset(0, 0)
  compactText:SetDrawLayer("OVERLAY", 7)

  compactBtn:SetScript("OnClick", function()
    local CM = NS.UI and NS.UI.CompactMode
    if CM then
      CM:Show()
    end
    f:Hide()
    local db2 = NS.db and NS.db.profile
    if db2 and db2.ui then db2.ui.compactMode = true end
  end)
  compactBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Compact View", 1, 1, 1)
    GameTooltip:AddLine("Switch to a small, text-only list view.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end)
  compactBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  compactBtn:Hide()

  local designBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
  header.designBtn = designBtn
  Backdrop(designBtn, T.panel, T.border)
  designBtn:SetSize(94, 20)
  designBtn:SetPoint("RIGHT", compactBtn, "LEFT", -8, 0)
  designBtn:SetFrameLevel(header:GetFrameLevel() + 6)
  Hover(designBtn, T.panel, T.hover)

  local designIcon = designBtn:CreateTexture(nil, "OVERLAY")
  designBtn.icon = designIcon
  designIcon:SetSize(14, 14)
  designIcon:SetPoint("LEFT", 8, 0)
  designIcon:SetTexture("Interface\\Icons\\INV_Inscription_Pigment_Golden")
  designIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  C:TextureColor(designIcon, "accent")

  local designText = NewFS(designBtn, "GameFontNormal")
  designBtn.text = designText
  designText:SetPoint("LEFT", designIcon, "RIGHT", 5, 0)
  designText:SetPoint("RIGHT", designBtn, "RIGHT", -6, 0)
  designText:SetJustifyH("LEFT")
  designText:SetWordWrap(false)
  designText:SetText("Design")
  TextColor(designText, "text")

  local function RefreshDesignButton()
    local ThemeNow = NS.UI and NS.UI.Theme
    local key = (db and db.ui and db.ui.designPreset) or "classic"
    local label = ThemeNow and ThemeNow.GetDesignPresetLabel and ThemeNow:GetDesignPresetLabel(key) or "Classic"
    if designText then designText:SetText(label) end
  end

  designBtn:SetScript("OnClick", function()
    local ThemeNow = NS.UI and NS.UI.Theme
    if ThemeNow and ThemeNow.CycleDesignPreset then
      ThemeNow:CycleDesignPreset()
      RefreshDesignButton()
      if C and C.RefreshAppearance then C:RefreshAppearance(f, true) end
      if C and C.RefreshRegisteredBorders then C:RefreshRegisteredBorders() end
      if rerender then rerender() end
    end
  end)
  designBtn:SetScript("OnEnter", function(self)
    local ThemeNow = NS.UI and NS.UI.Theme
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Design Preset", 1, 1, 1)
    GameTooltip:AddLine("Cycle the addon between Classic, Gallery, Workshop, and Arcane layouts.", 0.7, 0.7, 0.7, true)
    if ThemeNow and ThemeNow.GetDesignPresetLabel then
      GameTooltip:AddLine("Current: " .. ThemeNow:GetDesignPresetLabel((db and db.ui and db.ui.designPreset) or "classic"), 1, 0.82, 0.2, true)
    end
    GameTooltip:Show()
  end)
  designBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  RefreshDesignButton()

  local viewModeButtons = {}
  local function MakeViewGlyph(btn, kind)
    local pieces = {}
    local function piece(x, y, w, h)
      local tex = btn:CreateTexture(nil, "OVERLAY")
      tex:SetPoint("LEFT", btn, "LEFT", x, y)
      tex:SetSize(w, h)
      tex:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.95)
      pieces[#pieces + 1] = tex
      return tex
    end

    if kind == "grid" then
      piece(8, 4, 3, 3); piece(13, 4, 3, 3)
      piece(8, -1, 3, 3); piece(13, -1, 3, 3)
    elseif kind == "text" then
      piece(8, 4, 12, 2)
      piece(8, 0, 16, 2)
      piece(8, -4, 10, 2)
    else
      piece(8, 4, 3, 3); piece(14, 4, 13, 2)
      piece(8, -1, 3, 3); piece(14, -1, 13, 2)
      piece(8, -6, 3, 3); piece(14, -6, 13, 2)
    end

    btn.iconPieces = pieces
  end

  local function TintViewGlyph(btn, selected)
    if not (btn and btn.iconPieces) then return end
    local a = selected and 1 or 0.72
    for i = 1, #btn.iconPieces do
      local tex = btn.iconPieces[i]
      if tex and tex.SetColorTexture then
        tex:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], a)
      end
    end
  end

  local function MakeViewModeButton(parent, width, label, glyphKind, mode)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    Backdrop(b, T.panel, T.border)
    SkinBtn(b)
    Hover(b, T.panel, T.hover)
    b:SetSize(width, 24)
    b._viewMode = mode

    MakeViewGlyph(b, glyphKind)

    b.text = NewFS(b, "GameFontNormalSmall")
    b.text:SetPoint("LEFT", b, "LEFT", (glyphKind == "list") and 31 or 27, 0)
    b.text:SetPoint("RIGHT", b, "RIGHT", -6, 0)
    b.text:SetJustifyH("LEFT")
    b.text:SetWordWrap(false)
    b.text:SetText(label)
    TextColor(b.text, "text")

    b:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
      GameTooltip:SetText(label .. " View", 1, 1, 1)
      if mode == "Icon" then
        GameTooltip:AddLine("Show decor as image cards.", 0.72, 0.72, 0.72, true)
      elseif mode == "Text List" then
        GameTooltip:AddLine("Show a cleaner text-first list.", 0.72, 0.72, 0.72, true)
      else
        GameTooltip:AddLine("Show decor as detailed rows.", 0.72, 0.72, 0.72, true)
      end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    viewModeButtons[#viewModeButtons + 1] = b
    return b
  end

  header.viewModeGroup = CreateFrame("Frame", nil, header)
  header.viewModeGroup:SetSize(222, 24)
  header.iconViewBtn = MakeViewModeButton(header.viewModeGroup, 68, "Grid", "grid", "Icon")
  header.listViewBtn = MakeViewModeButton(header.viewModeGroup, 64, "List", "list", "List")
  header.textListViewBtn = MakeViewModeButton(header.viewModeGroup, 90, "Text List", "text", "Text List")
  header.iconViewBtn:SetPoint("LEFT", header.viewModeGroup, "LEFT", 0, 0)
  header.listViewBtn:SetPoint("LEFT", header.iconViewBtn, "RIGHT", 0, 0)
  header.textListViewBtn:SetPoint("LEFT", header.listViewBtn, "RIGHT", 0, 0)

  local left = CreateFrame("Frame", nil, f, "BackdropTemplate")
  Backdrop(left, T.panel, T.border)
  if C.ApplyBackground and Textures and Textures.LeftPanelBG then
    C:ApplyBackground(left, Textures.LeftPanelBG, 6, 1)
  end
  left:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -1)
  left:SetPoint("BOTTOMLEFT", 8, 46)
  left:SetWidth(204)

  local cats = {
    "All Sources",
    "Achievements",
    "Quests",
    "Vendors",
    "Drops",
    "Treasures",
    "Shop",
    "Professions",
    "PvP",
    "Architect",
    "Decor Pricing",
    "Events",
    "Decor Tracker",
    "Gather Tracker",
    "Alts Professions",
    "Endeavors",
  }
  local catIcons = {
    ["All Sources"] = "Interface\\Icons\\INV_Misc_Map_01",
    Achievements = "Interface\\Icons\\Achievement_General",
    Quests = "Interface\\Icons\\INV_Misc_Note_02",
    Vendors = "Interface\\Icons\\INV_Misc_Coin_01",
    Drops = "Interface\\Icons\\INV_Box_01",
    Treasures = "Interface\\Icons\\INV_Misc_TreasureChest04b",
    Shop = "Interface\\Icons\\INV_Misc_Coin_02",
    Professions = "Interface\\Icons\\Trade_BlackSmithing",
    ["PvP"] = "Interface\\Icons\\INV_BannerPVP_02",
    Architect = "Interface\\Icons\\INV_Inscription_Tradeskill01",
    Events = "Interface\\Icons\\INV_Misc_PocketWatch_01",
    ["Decor Tracker"] = "Interface\\Icons\\Ability_Hunter_BeastCall",
    ["Gather Tracker"] = "Interface\\Icons\\INV_Misc_Map_01",
    ["Decor Pricing"] = "Interface\\Icons\\INV_Misc_Coin_01",
    ["Alts Professions"] = "Interface\\Icons\\INV_Misc_Book_11",
    Endeavors = "Interface\\Icons\\Achievement_Zone_Cataclysm",
  }
  left.buttons = {}

  local function CreateSideSection(label)
    local section = CreateFrame("Frame", nil, left)
    section:SetHeight(16)

    section.text = NewFS(section, "GameFontNormalSmall")
    section.text:SetPoint("LEFT", section, "LEFT", 0, 0)
    section.text:SetText(label)
    section.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    section.text:SetShadowColor(0, 0, 0, 0)
    section.text:SetShadowOffset(0, 0)
    TextColor(section.text, "accent", 0.92)

    section.line = section:CreateTexture(nil, "ARTWORK")
    section.line:SetPoint("LEFT", section.text, "RIGHT", 8, 0)
    section.line:SetPoint("RIGHT", section, "RIGHT", 0, 0)
    section.line:SetHeight(1)
    section.line:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.28)

    return section
  end

  left.sections = {
    quick = CreateSideSection("QUICK ACCESS"),
    catalog = CreateSideSection("CATALOG"),
    featured = CreateSideSection("FEATURED"),
    trackers = CreateSideSection("TRACKERS"),
    account = CreateSideSection("ACCOUNT"),
    filters = CreateSideSection("FILTERS"),
    links = CreateSideSection("LINKS"),
  }

  local function PlaceSideSection(section, yPos, step)
    if not section then return yPos end
    section:ClearAllPoints()
    section:SetPoint("TOPLEFT", left, "TOPLEFT", 10, yPos)
    section:SetPoint("TOPRIGHT", left, "TOPRIGHT", -10, yPos)
    section:Show()
    return yPos - (step or 18)
  end

  local navTips = {
    ["Saved Items"] = "Items you pinned for quick reference.",
    ["All"] = "Browse every known decor source.",
    Achievements = "Decor unlocked from achievements.",
    Quests = "Decor earned from quests.",
    Vendors = "Decor sold by vendors and quartermasters.",
    Drops = "Decor found from creature drops and encounters.",
    Treasures = "Decor found in treasures and world chests.",
    Shop = "Decor from store packs, editions, and preorder bonuses.",
    Professions = "Decor crafted or gathered through professions.",
    ["PvP"] = "Decor tied to PvP sources.",
    Architect = "Plan rooms, decor budgets, and reusable furnishing ideas.",
    Events = "Open active and seasonal event decor.",
    ["Decor Tracker"] = "Open your decor tracker.",
    ["Gather Tracker"] = "Open your gather tracker.",
    ["Decor Pricing"] = "Open the pricing window.",
    ["Alts Professions"] = "Open profession coverage for your alts.",
    Endeavors = "Open endeavor progress and rewards.",
  }

  local function SetupNavTooltip(btn)
    btn:HookScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(self._tooltipTitle or self._fullText or self._category or "", 1, 1, 1)
      if self._fullText and self._tooltipTitle ~= self._fullText then
        GameTooltip:AddLine(self._fullText, 1, 0.82, 0.2, true)
      end
      local tip = navTips[self._category]
      if tip then
        GameTooltip:AddLine(tip, 0.72, 0.72, 0.72, true)
      end
      GameTooltip:Show()
    end)
    btn:HookScript("OnLeave", function() GameTooltip:Hide() end)
  end

  local function RaiseNavContent(btn)
    if btn and btn.icon and btn.icon.SetDrawLayer then btn.icon:SetDrawLayer("OVERLAY", 7) end
    if btn and btn.text and btn.text.SetDrawLayer then btn.text:SetDrawLayer("OVERLAY", 7) end
  end

  local function applyCategoryText(btn, cname)
    if cname == "All Sources" then
      btn._fullText = "All Sources"
      btn._tooltipTitle = "All Sources"
      btn.text:SetText(btn._fullText)
      return
    end
    local displayName = (cname == "Drops") and "Drops/Encounters" or cname
    local collected, total = 0, 0
    if GlobalIndex and GlobalIndex.GetCounts then
      collected, total = GlobalIndex:GetCounts(cname)
    end
    if total > 0 then
      btn._fullText = format("%s (%d / %d)", displayName, collected, total)
    else
      btn._fullText = displayName
    end
    btn._tooltipTitle = btn._fullText
    btn.text:SetText(btn._fullText)
  end

  local function RefreshCategoryTexts()
    for i = 1, #left.buttons do
      local btn = left.buttons[i]
      local cname = btn and btn._category
      if cname and cname ~= "Saved Items" and cname ~= "Decor Tracker" and cname ~= "Gather Tracker" and applyCategoryText then
        applyCategoryText(btn, cname == "All" and "All Sources" or cname)
        RaiseNavContent(btn)
      end
    end
  end

  local y = -12
  y = PlaceSideSection(left.sections.quick, y)

  local savedItemsBtn = CreateFrame("Button", nil, left, "BackdropTemplate")
  Backdrop(savedItemsBtn, T.panel, T.border)
  SkinBtn(savedItemsBtn)
  savedItemsBtn:SetPoint("TOPLEFT", 10, y)
  savedItemsBtn:SetPoint("RIGHT", -10, y)
  savedItemsBtn:SetHeight(28)

  local savedItemsIcon = savedItemsBtn:CreateTexture(nil, "OVERLAY")
  savedItemsIcon:SetSize(14, 14)
  savedItemsIcon:SetPoint("LEFT", savedItemsBtn, "LEFT", 10, 0)
  if savedItemsIcon.SetAtlas then
    savedItemsIcon:SetAtlas("auctionhouse-icon-favorite", false)
  else
    savedItemsIcon:SetTexture("Interface/Common/ReputationStar")
  end
  C:TextureColor(savedItemsIcon, "accent")
  savedItemsBtn.icon = savedItemsIcon

  local savedItemsTxt = NewFS(savedItemsBtn, "GameFontNormal")
  savedItemsTxt:SetPoint("LEFT", savedItemsIcon, "RIGHT", 6, 0)
  savedItemsTxt:SetText(Loc["SAVED_ITEMS"])
  TextColor(savedItemsTxt, "accent")
  savedItemsBtn.text = savedItemsTxt
  savedItemsBtn._category = "Saved Items"
  savedItemsBtn._fullText = Loc["SAVED_ITEMS"] or "Saved Items"
  savedItemsBtn._tooltipTitle = savedItemsBtn._fullText

  CreateCategoryIndicators(savedItemsBtn)
  ApplyNavArt(savedItemsBtn)
  RaiseNavContent(savedItemsBtn)
  Hover(savedItemsBtn, T.panel, T.hover)
  SetupNavTooltip(savedItemsBtn)
  left.buttons[#left.buttons + 1] = savedItemsBtn
  y = y - 36

  local utilityDivider = left:CreateTexture(nil, "ARTWORK")
  utilityDivider:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.28)
  utilityDivider:SetHeight(1)
  utilityDivider:Hide()

  for i = 1, #cats do
    local cname = cats[i]
    local b = CreateFrame("Button", nil, left, "BackdropTemplate")
    Backdrop(b, T.panel, T.border)
    SkinBtn(b)

    b:SetPoint("TOPLEFT", 10, y)
    b:SetPoint("RIGHT", -10, y)
    b:SetHeight(28)

    local icon = b:CreateTexture(nil, "OVERLAY")
    icon:SetSize(15, 15)
    icon:SetPoint("LEFT", b, "LEFT", 9, 0)
    icon:SetTexture(catIcons[cname] or "Interface\\Icons\\INV_Misc_QuestionMark")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    C:TextureColor(icon, "accent", 0.95)
    b.icon = icon

    local txt = NewFS(b, "GameFontNormal")
    b.text = txt
    txt:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    txt:SetPoint("RIGHT", b, "RIGHT", -8, 0)
    txt:SetJustifyH("LEFT")
    txt:SetWordWrap(false)
    if txt.SetMaxLines then txt:SetMaxLines(1) end
    b._category = (cname == "All Sources") and "All" or cname
    if cname == "All Sources" then
      b._sectionBefore = left.sections.catalog
    elseif cname == "Architect" then
      b._sectionBefore = left.sections.featured
    elseif cname == "Decor Tracker" then
      b._sectionBefore = left.sections.trackers
    elseif cname == "Alts Professions" then
      b._sectionBefore = left.sections.account
    end
    if cname == "Decor Tracker" or cname == "Gather Tracker" then b._utilityAction = true end

    CreateCategoryIndicators(b)
    ApplyNavArt(b)
    applyCategoryText(b, cname)
    RaiseNavContent(b)
    Hover(b, T.panel, T.hover)
    SetupNavTooltip(b)

    left.buttons[#left.buttons + 1] = b
    y = y - 32
  end

  local filtersTitle = left.sections.filters
  filtersTitle:SetPoint("TOPLEFT", 10, y - 10)
  y = y - 24

  local filtersLine = left:CreateTexture(nil, "ARTWORK")
  filtersLine:SetColorTexture(1, 1, 1, 0.15)
  filtersLine:SetHeight(1)
  filtersLine:SetPoint("TOPLEFT", 10, y)
  filtersLine:SetPoint("TOPRIGHT", -10, y)
  y = y - 6

  local divider = left:CreateTexture(nil, "ARTWORK")
  divider:SetColorTexture(1, 1, 1, 0.15)
  divider:SetHeight(1)
  divider:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  12, 80)
  divider:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -12, 80)

  local resetFiltersBtn = CreateFrame("Button", nil, left, "BackdropTemplate")
  Backdrop(resetFiltersBtn, T.panel, T.border)
  resetFiltersBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, 86)
  resetFiltersBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 86)
  resetFiltersBtn:SetHeight(26)
  Hover(resetFiltersBtn, T.panel, T.hover)

  local resetIcon = resetFiltersBtn:CreateTexture(nil, "OVERLAY")
  resetIcon:SetSize(14, 14)
  resetIcon:SetPoint("LEFT", 10, 0)
  resetIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
  C:TextureColor(resetIcon, "accent")

  local resetText = NewFS(resetFiltersBtn, "GameFontNormal")
  resetText:SetPoint("LEFT", resetIcon, "RIGHT", 6, 0)
  resetText:SetText(Loc["RESET_ALL_FILTERS"])
  TextColor(resetText, "accent")

  resetFiltersBtn:SetScript("OnClick", function()
    local fc = left.filterContent
    if fc and fc.ResetAllFilters then
      fc:ResetAllFilters()
    else
      local db2 = NS.db and NS.db.profile
      if not db2 then return end
      local flt = db2.filters or {}
      flt.expansion, flt.zone, flt.color, flt.category, flt.subcategory, flt.faction = "ALL", "ALL", "ALL", "ALL", "ALL", "ALL"
      flt.colors = {}
      flt.budgetCosts = {}
      flt.sizes = {}
      flt.hideCollected, flt.onlyCollected = false, false
      flt.availableRepOnly = false
      flt.questsCompleted = false
      flt.achievementCompleted = false
      if Filters then
        Filters.expansion, Filters.zone, Filters.category, Filters.subcategory, Filters.faction =
          flt.expansion, flt.zone, flt.category, flt.subcategory, flt.faction
        Filters.color = "ALL"
        Filters.colors = flt.colors
        Filters.budgetCosts = flt.budgetCosts
        Filters.sizes = flt.sizes
        Filters.hideCollected = false
        Filters.onlyCollected = false
        Filters.availableRepOnly = false
        Filters.questsCompleted = false
        Filters.achievementCompleted = false
      end
      local HeaderCtrl = NS.UI and NS.UI.HeaderController
      if HeaderCtrl and HeaderCtrl.Reset then HeaderCtrl:Reset() end
      if rerender then rerender() end
    end
  end)
  resetFiltersBtn:Hide()

  local divider2 = left:CreateTexture(nil, "ARTWORK")
  divider2:SetColorTexture(1, 1, 1, 0.15)
  divider2:SetHeight(1)
  divider2:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  12, 44)
  divider2:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -12, 44)

  local communityBtn = CreateFrame("Button", nil, left, "BackdropTemplate")
  Backdrop(communityBtn, T.header, T.border)
  communityBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, 50)
  communityBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 50)
  communityBtn:SetHeight(26)
  Hover(communityBtn, T.header, T.hover)

  local commIcon = communityBtn:CreateTexture(nil, "OVERLAY")
  commIcon:SetSize(14, 14)
  commIcon:SetPoint("LEFT", 10, 0)
  commIcon:SetTexture("Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon")

  local commText = NewFS(communityBtn, "GameFontNormal")
  commText:SetPoint("LEFT", commIcon, "RIGHT", 6, 0)
  commText:SetText(Loc["COMMUNITY"])
  communityBtn:SetScript("OnClick", ShowCommunityPopup)

  local whatsNewBtn = CreateFrame("Button", nil, left, "BackdropTemplate")
  Backdrop(whatsNewBtn, T.panel, T.border)
  whatsNewBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, 10)
  whatsNewBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 10)
  whatsNewBtn:SetHeight(26)
  Hover(whatsNewBtn, T.header, T.hover)

  local wnText = NewFS(whatsNewBtn, "GameFontNormal")
  wnText:SetPoint("CENTER")
  wnText:SetText(Loc["WHATS_NEW"])
  whatsNewBtn:SetScript("OnClick", function()
    if NS.UI and NS.UI.ShowChangelogPopup then
      NS.UI:ShowChangelogPopup(true)
    end
  end)

  local filterScroll = CreateFrame("ScrollFrame", nil, left, "ScrollFrameTemplate")
  filterScroll:SetPoint("TOPLEFT", 8, y)
  filterScroll:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -26, 92)
  left.filterScroll = filterScroll

  local filterContent = CreateFrame("Frame", nil, filterScroll)
  filterContent:SetPoint("TOPLEFT", 0, 0)
  filterScroll:SetScrollChild(filterContent)
  filterScroll:SetScript("OnSizeChanged", function(self, w)
    filterContent:SetWidth((w or 0) - 2)
  end)

  left.filterContent = filterContent

  if C and C.SkinScrollFrame then
    C:SkinScrollFrame(filterScroll)
  end

  local function RefreshLeftLayout()
    local panelW = 204
    left:SetWidth(panelW)

    local compactNav = (left:GetHeight() or 0) < 700
    local sectionStep = compactNav and 15 or 18
    local btnH = compactNav and 22 or 25
    local gap = compactNav and 24 or 28
    local savedGap = compactNav and 7 or 10
    local cy = -12

    cy = PlaceSideSection(left.sections and left.sections.quick, cy, sectionStep)

    savedItemsBtn:ClearAllPoints()
    savedItemsBtn:SetPoint("TOPLEFT", 10, cy)
    savedItemsBtn:SetPoint("RIGHT", -10, cy)
    savedItemsBtn:SetHeight(btnH)
    cy = cy - (btnH + savedGap)

    for i = 1, #left.buttons do
      local b = left.buttons[i]
      if b ~= savedItemsBtn then
        if b._sectionBefore then
          cy = PlaceSideSection(b._sectionBefore, cy, sectionStep)
        end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", 10, cy)
        b:SetPoint("RIGHT", -10, cy)
        b:SetHeight(btnH)
        cy = cy - gap
      end
    end
    utilityDivider:Hide()

    if filtersTitle then filtersTitle:Hide() end
    filtersLine:Hide()
    filterScroll:Hide()

    local bottomBtnH = 26
    local b1Off = 86
    local b2Off = 50
    local b3Off = 10
    local d1Off = 100
    local d2Off = 44

    divider:ClearAllPoints()
    divider:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  12, d1Off)
    divider:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -12, d1Off)

    resetFiltersBtn:ClearAllPoints()
    resetFiltersBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, b1Off)
    resetFiltersBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, b1Off)
    resetFiltersBtn:SetHeight(bottomBtnH)
    resetFiltersBtn:Hide()

    divider2:ClearAllPoints()
    divider2:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  12, d2Off)
    divider2:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -12, d2Off)

    if left.sections and left.sections.links then
      left.sections.links:ClearAllPoints()
      left.sections.links:SetPoint("BOTTOMLEFT", left, "BOTTOMLEFT", 10, 78)
      left.sections.links:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, 78)
      left.sections.links:Show()
    end

    communityBtn:ClearAllPoints()
    communityBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, b2Off)
    communityBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, b2Off)
    communityBtn:SetHeight(bottomBtnH)

    whatsNewBtn:ClearAllPoints()
    whatsNewBtn:SetPoint("BOTTOMLEFT",  left, "BOTTOMLEFT",  10, b3Off)
    whatsNewBtn:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -10, b3Off)
    whatsNewBtn:SetHeight(bottomBtnH)
  end

  local right = CreateFrame("Frame", nil, f, "BackdropTemplate")
  Backdrop(right, T.panel, T.border)
  if C.ApplyBackground and Textures then
    local bg = Textures.ModelBG or Textures.ModalBG or Textures.MainBackground
    if bg then C:ApplyBackground(right, bg, 8, 1) end
  end
  right:SetPoint("TOPLEFT", left, "TOPRIGHT", 8, 0)
  right:SetPoint("BOTTOMRIGHT", -8, 46)
  f.Right = right

  local rightToolbar = CreateFrame("Frame", nil, right, "BackdropTemplate")
  Backdrop(rightToolbar, T.panel, T.border)
  if C.ApplyHeaderTexture then C:ApplyHeaderTexture(rightToolbar, false) end
  rightToolbar:SetPoint("TOPLEFT", right, "TOPLEFT", 8, -4)
  rightToolbar:SetPoint("TOPRIGHT", right, "TOPRIGHT", -8, -4)
  rightToolbar:SetHeight(58)
  f.RightToolbar = rightToolbar

  local bar = CreateFrame("Frame", nil, header, "BackdropTemplate")
  Backdrop(bar, T.panel, T.border)
  if C.ApplyHeaderTexture then C:ApplyHeaderTexture(bar, false) end
  bar:SetPoint("BOTTOMLEFT",  header, "BOTTOMLEFT",   8,  4)
  bar:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", -8,  4)
  bar:SetHeight(36)
  f.TopBar = bar
  header.modeBar = bar
  bar:Hide()

  local rightContent = CreateFrame("Frame", nil, right)
  rightContent:SetPoint("TOPLEFT", rightToolbar, "BOTTOMLEFT", 0, -1)
  rightContent:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -8, 8)
  f.RightContent = rightContent

  local function MakeTopButton(parent, w, h)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    Backdrop(b, T.panel, T.border)
    SkinBtn(b)
    b:SetSize(w, h)
    Hover(b, T.panel, T.hover)

    b.icon = b:CreateTexture(nil, "OVERLAY")
    b.icon:SetSize(14, 14)
    b.icon:SetPoint("LEFT", b, "LEFT", 8, 0)

    b.text = NewFS(b, "GameFontNormal")
    b.text:SetPoint("LEFT", b.icon, "RIGHT", 6, 0)
    return b
  end

  local eventsBtn = MakeTopButton(bar, 96, 24)
  eventsBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
  eventsBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  eventsBtn.icon:SetDesaturated(true)
  eventsBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  eventsBtn.text:SetText(Loc["EVENTS"])
  TextColor(eventsBtn.text, "textMuted")

  local glow = eventsBtn:CreateTexture(nil, "ARTWORK")
  eventsBtn.glow = glow
  glow:SetTexture("Interface\\AddOns\\HomeDecor\\Media\\UI\\event_badge_small.tga")
  glow:SetPoint("CENTER", eventsBtn, "CENTER", 0, 0)
  glow:SetSize(110, 34)
  glow:SetBlendMode("ADD")
  glow:SetAlpha(0)

  local glowAnim = eventsBtn:CreateAnimationGroup()
  eventsBtn.glowAnim = glowAnim
  do
    local a1 = glowAnim:CreateAnimation("Alpha")
    a1:SetFromAlpha(0.10)
    a1:SetToAlpha(0.70)
    a1:SetDuration(0.55)
    a1:SetSmoothing("IN_OUT")
    a1:SetOrder(1)

    local a2 = glowAnim:CreateAnimation("Alpha")
    a2:SetFromAlpha(0.70)
    a2:SetToAlpha(0.10)
    a2:SetDuration(0.65)
    a2:SetSmoothing("IN_OUT")
    a2:SetOrder(2)
  end
  glowAnim:SetLooping("REPEAT")

  compactBtn:SetParent(header)
  compactBtn:SetSize(72, 20)
  compactBtn:ClearAllPoints()
  compactBtn:SetPoint("RIGHT", settingsBtn, "LEFT", -8, 0)
  compactBtn:Show()

  designBtn:SetParent(header)
  designBtn:ClearAllPoints()
  designBtn:SetPoint("RIGHT", compactBtn, "LEFT", -8, 0)
  designBtn:Show()

  local decorTrackerBtn = MakeTopButton(bar, 120, 24)
  decorTrackerBtn.icon:SetTexture("Interface\\Icons\\Ability_Hunter_BeastCall")
  decorTrackerBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  decorTrackerBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  decorTrackerBtn.text:SetText("Decor Tracker")
  TextColor(decorTrackerBtn.text, "text")
  decorTrackerBtn:SetScript("OnClick", function()
    local Tr = (NS.UI and NS.UI.Tracker) or (NS.UI and NS.UI.DecorTracker) or NS.Tracker
    if Tr and Tr.Toggle then Tr:Toggle() end
  end)

  local gatherTrackerBtn = MakeTopButton(bar, 128, 24)
  gatherTrackerBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
  gatherTrackerBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  gatherTrackerBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  gatherTrackerBtn.text:SetText(Loc["LUMBER_TRACKER"] or "Gather Tracker")
  TextColor(gatherTrackerBtn.text, "text")
  gatherTrackerBtn:SetScript("OnClick", function()
    local GT = (NS.UI and NS.UI.GatherTrack)
    if GT and GT.ToggleAll then
      GT:ToggleAll()
    else
      local LT = (NS.UI and NS.UI.LumberTrack) or NS.LumberTrack
      if LT and LT.Toggle then LT:Toggle() end
    end
  end)

  trackersBtn:Hide()
  trackersMenu:Hide()
  header.controls:Hide()
  eventsBtn:Hide()
  decorTrackerBtn:Hide()
  gatherTrackerBtn:Hide()

  local decorPricingBtn
  local altProfsTopBtn
  local endeavorsTopBtn

  local function LayoutModeBar()
    local centerClusterWidth = 96 + 6 + 120 + 6 + 130 + 6 + 110

    eventsBtn:ClearAllPoints()
    eventsBtn:SetPoint("LEFT", bar, "CENTER", -math.floor(centerClusterWidth / 2), 0)

    if decorPricingBtn then
      decorPricingBtn:ClearAllPoints()
      decorPricingBtn:SetPoint("LEFT", eventsBtn, "RIGHT", 6, 0)
    end

    if altProfsTopBtn and decorPricingBtn then
      altProfsTopBtn:ClearAllPoints()
      altProfsTopBtn:SetPoint("LEFT", decorPricingBtn, "RIGHT", 6, 0)
    end

    if endeavorsTopBtn and altProfsTopBtn then
      endeavorsTopBtn:ClearAllPoints()
      endeavorsTopBtn:SetPoint("LEFT", altProfsTopBtn, "RIGHT", 6, 0)
    end

    gatherTrackerBtn:ClearAllPoints()
    gatherTrackerBtn:SetPoint("RIGHT", bar, "RIGHT", -8, 0)

    decorTrackerBtn:ClearAllPoints()
    decorTrackerBtn:SetPoint("RIGHT", gatherTrackerBtn, "LEFT", -6, 0)
  end

  local EventsSys = NS.Systems and NS.Systems.Events or nil
  local function getEventState()
    local Ev = EventsSys or (NS.Systems and NS.Systems.Events)
    EventsSys = Ev
    if not Ev then return false, "" end

    if Ev.GetStatus then
      return Ev:GetStatus()
    elseif Ev.GetActive then
      local list = Ev:GetActive()
      local hasActive = (type(list) == "table" and #list > 0)
      return hasActive, (hasActive and "active" or "")
    elseif Ev.HasActive then
      local hasActive = Ev:HasActive() and true or false
      return hasActive, (hasActive and "active" or "")
    end

    return false, ""
  end

  local UpdateTopTabs
  local SelectCategory
  local setSearchUI
  local UpdateSortVisibility
  local UpdateRightToolbarVisibility
  local ScheduleEventStateRefresh
  local RefreshQuickFilters
  local modeBtn
  local detailsBtn

  local function SetToggleButtonState(btn, active)
    if not btn then return end
    C:SetSelected(btn, active, T.panel, T.row)
    if btn.__hdBtnSkinned and Textures then
      if btn.SetNormalTexture then
        btn:SetNormalTexture(active and (Textures.ButtonPushed or Textures.ButtonNormal) or Textures.ButtonNormal)
      end
      local nt = btn.GetNormalTexture and btn:GetNormalTexture()
      if nt then
        nt:SetAllPoints(btn)
        nt:SetAlpha(1)
      end
    end
    if btn.text then
      if active then
        TextColor(btn.text, "highlight", 0.95)
      else
        TextColor(btn.text, "text")
      end
    end
  end

  local function RefreshModeButton()
    if not modeBtn then return end
    local isAllItems = (UI.catalogMode == "All Items")
    if modeBtn.text then
      modeBtn.text:SetText(isAllItems and "All" or "Groups")
    end
    SetToggleButtonState(modeBtn, isAllItems)
  end

  local function RefreshDetailsButton()
    if not detailsBtn then return end
    SetToggleButtonState(detailsBtn, UI.detailsPanelOpen == true)
  end

  local function RefreshViewModeButtons()
    for i = 1, #viewModeButtons do
      local btn = viewModeButtons[i]
      local selected = btn and btn._viewMode == UI.viewMode
      SetToggleButtonState(btn, selected)
      TintViewGlyph(btn, selected)
    end
  end

  local function IsWindowCategory(categoryName)
    return categoryName == "Events"
      or categoryName == "Architect"
      or categoryName == "Decor Pricing"
      or categoryName == "Alts Professions"
      or categoryName == "Endeavors"
  end

  local function ApplyDetailsPanelForCategory(categoryName, skipRender)
    local open = (UI.detailsPanelOpen == true) and not IsWindowCategory(categoryName)
    if db and db.ui then db.ui.detailsPanelOpen = UI.detailsPanelOpen == true end
    if f.view and f.view.SetInspectorOpen then
      f.view:SetInspectorOpen(open, skipRender)
    end
    RefreshDetailsButton()
  end

  header.scaleRightEdge = settingsBtn

  UpdateTopTabs = function()
    local isPricingSelected = UI.activeCategory == "Decor Pricing"
    C:SetSelected(decorPricingBtn, isPricingSelected, T.panel, T.row)
    if isPricingSelected then
      decorPricingBtn.icon:SetVertexColor(1, 1, 1, 1)
      TextColor(decorPricingBtn.text, "highlight", 0.95)
    else
      decorPricingBtn.icon:SetVertexColor(1, 1, 1, 0.9)
      TextColor(decorPricingBtn.text, "text")
    end

    local isAltsSelected = UI.activeCategory == "Alts Professions"
    C:SetSelected(altProfsTopBtn, isAltsSelected, T.panel, T.row)
    if isAltsSelected then
      altProfsTopBtn.icon:SetVertexColor(1, 1, 1, 1)
      TextColor(altProfsTopBtn.text, "highlight", 0.95)
    else
      altProfsTopBtn.icon:SetVertexColor(1, 1, 1, 0.9)
      TextColor(altProfsTopBtn.text, "text")
    end

    local isEndeavorsSelected = UI.activeCategory == "Endeavors"
    C:SetSelected(endeavorsTopBtn, isEndeavorsSelected, T.panel, T.row)
    if isEndeavorsSelected then
      endeavorsTopBtn.icon:SetVertexColor(1, 1, 1, 1)
      TextColor(endeavorsTopBtn.text, "highlight", 0.95)
    else
      endeavorsTopBtn.icon:SetVertexColor(1, 1, 1, 0.9)
      TextColor(endeavorsTopBtn.text, "text")
    end

    local isArchitectSelected = UI.activeCategory == "Architect"
    if NS.UI.ArchitectPanel then
      NS.UI.ArchitectPanel:SetShown(isArchitectSelected)
    end

    if NS.UI.EndeavorsPanel then
      NS.UI.EndeavorsPanel:SetShown(isEndeavorsSelected)
    end
    if f.view then
      f.view:SetShown(not isEndeavorsSelected and not isArchitectSelected)
    end

    C:SetSelected(eventsBtn, UI.activeCategory == "Events", T.panel, T.row)

    local hasActive, sig = getEventState()
    if UI.activeCategory == "Events" and sig ~= "" then
      db.ui.eventsSeenSig = sig
    end

    local seenSig = db.ui.eventsSeenSig or ""
    local isNew = (sig ~= "" and sig ~= seenSig)

    if hasActive then
      eventsBtn.icon:SetDesaturated(false)
      TextColor(eventsBtn.text, "highlight", 0.95)
      eventsBtn:SetAlpha(1.0)

      if isNew then
        glow:SetAlpha(0.10)
        if not glowAnim:IsPlaying() then glowAnim:Play() end
      else
        if glowAnim:IsPlaying() then glowAnim:Stop() end
        glow:SetAlpha(0.25)
      end
    else
      eventsBtn.icon:SetDesaturated(true)
      TextColor(eventsBtn.text, "textMuted")
      eventsBtn:SetAlpha(0.85)
      if glowAnim:IsPlaying() then glowAnim:Stop() end
      glow:SetAlpha(0)
      db.ui.eventsSeenSig = ""
    end
  end

  ScheduleEventStateRefresh = function()
    if f.eventTimer and f.eventTimer.Cancel then
      f.eventTimer:Cancel()
    end
    f.eventTimer = nil

    if not f:IsShown() or not C_Timer or not C_Timer.NewTimer then return end

    local EventsSysLocal = EventsSys or (NS.Systems and NS.Systems.Events)
    local now = time and time() or 0
    local delay = 60

    if EventsSysLocal and EventsSysLocal.RecalcStatus then
      EventsSysLocal:RecalcStatus(now)
      local cache = EventsSysLocal.cache and EventsSysLocal.cache.status
      if cache and type(cache.nextCheck) == "number" and cache.nextCheck > now then
        delay = cache.nextCheck - now + 1
      end
    end

    if delay < 1 then delay = 1 end

    f.eventTimer = C_Timer.NewTimer(delay, function()
      if not f or not f:IsShown() then return end
      if UpdateTopTabs then UpdateTopTabs() end
      ScheduleEventStateRefresh()
    end)
  end

  SelectCategory = function(categoryName)

    UI.activeCategory = categoryName
    db.ui.activeCategory = categoryName
    ApplyDetailsPanelForCategory(categoryName, true)
    UI.search = ""
    db.ui.search = ""
    UI._searchNorm = ""
    UI._searchLast = ""
    UI._searchTokens = UI._searchTokens or {}
    for i = #UI._searchTokens, 1, -1 do UI._searchTokens[i] = nil end
    if FiltersSys and FiltersSys.PrepareSearch then FiltersSys:PrepareSearch(UI) end

    if categoryName ~= "Vendors" then
      local filters = db.filters
      if filters then
        if filters.availableRepOnly or filters.questsCompleted or filters.achievementCompleted then
          filters.availableRepOnly = false
          filters.questsCompleted = false
          filters.achievementCompleted = false

          if Filters then
            Filters.availableRepOnly = false
            Filters.questsCompleted = false
            Filters.achievementCompleted = false
          end

          local filterContent = left.filterContent
          if filterContent and filterContent.SyncVisuals then
            filterContent:SyncVisuals()
          end
        end
      end
    end

    if f.SearchBox then
      local txt = UI.search or ""
      f.SearchBox._squelchCmd = true
      f.SearchBox:SetText(txt)
      f.SearchBox:SetCursorPosition(#txt)
      f.SearchBox._squelchCmd = false
      if setSearchUI then setSearchUI(txt ~= "") end
    end

    for i = 1, #left.buttons do
      local bb = left.buttons[i]
      local sel = (bb._category == categoryName)
      C:SetSelected(bb, sel, T.panel, T.row)
      SetCategorySelected(bb, sel)
    end

    if categoryName == "Endeavors" and NS.UI and NS.UI.Endeavors and not NS.UI.EndeavorsPanel then
      NS.UI.EndeavorsPanel = NS.UI.Endeavors:Create(rightContent)
    end
    if categoryName == "Architect" and NS.UI and NS.UI.Architect and not NS.UI.ArchitectPanel then
      NS.UI.ArchitectPanel = NS.UI.Architect:Create(rightContent)
    end

    if UpdateTopTabs then UpdateTopTabs() end
    if categoryName == "Architect" and NS.UI.ArchitectPanel then
      if NS.UI.ArchitectPanel.Refresh then NS.UI.ArchitectPanel:Refresh() end
      NS.UI.ArchitectPanel:Show()
    end
    if categoryName == "Endeavors" and NS.UI.EndeavorsPanel then
      if NS.UI.EndeavorsPanel.FullRefresh then NS.UI.EndeavorsPanel:FullRefresh() end
      NS.UI.EndeavorsPanel:Show()
    end
    if f.view and f.view.scrollFrame then
      f.view.scrollFrame:SetVerticalScroll(0)
    end

    rerender()

    if NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
      NS.UI.HeaderController:Reset()
    end

    if UpdateSortVisibility then UpdateSortVisibility() end
    if UpdateRightToolbarVisibility then UpdateRightToolbarVisibility() end
  end

  for i = 1, #left.buttons do
    local b = left.buttons[i]
    b:SetScript("OnClick", function()
      if b._category == "Decor Tracker" then
        local Tr = (NS.UI and NS.UI.Tracker) or (NS.UI and NS.UI.DecorTracker) or NS.Tracker
        if Tr and Tr.Toggle then Tr:Toggle() end
        return
      elseif b._category == "Gather Tracker" then
        local GT = (NS.UI and NS.UI.GatherTrack)
        if GT and GT.ToggleAll then
          GT:ToggleAll()
        else
          local LT = (NS.UI and NS.UI.LumberTrack) or NS.LumberTrack
          if LT and LT.Toggle then LT:Toggle() end
        end
        return
      end
      SelectCategory(b._category)
    end)
  end

  eventsBtn:SetScript("OnClick", function()
    SelectCategory("Events")
    local _, sig = getEventState()
    db.ui.eventsSeenSig = sig or ""
    if UpdateTopTabs then UpdateTopTabs() end
  end)

  for i = 1, #left.buttons do
    local b = left.buttons[i]
    local isSel = (b._category == UI.activeCategory)
    C:SetSelected(b, isSel, T.panel, T.row)
    SetCategorySelected(b, isSel)
  end

  if header.viewModeGroup then
    header.viewModeGroup:SetParent(rightToolbar)
    header.viewModeGroup:ClearAllPoints()
    header.viewModeGroup:SetPoint("BOTTOMRIGHT", rightToolbar, "BOTTOMRIGHT", -8, 5)
  end

  for i = 1, #viewModeButtons do
    local b = viewModeButtons[i]
    b:SetScript("OnClick", function(self)
      UI.viewMode = self._viewMode or "Icon"
      if db and db.ui then db.ui.viewMode = UI.viewMode end
      if f.view and f.view.SetViewMode then f.view:SetViewMode(UI.viewMode) end
      RefreshViewModeButtons()
      rerender()
    end)
  end
  RefreshViewModeButtons()

  detailsBtn = CreateFrame("Button", nil, rightToolbar, "BackdropTemplate")
  Backdrop(detailsBtn, T.panel, T.border)
  detailsBtn:SetSize(58, 20)
  detailsBtn:SetPoint("TOPRIGHT", rightToolbar, "TOPRIGHT", -8, -4)
  Hover(detailsBtn, T.panel, T.hover)

  detailsBtn.text = NewFS(detailsBtn, "GameFontNormal")
  detailsBtn.text:SetPoint("CENTER")
  detailsBtn.text:SetText("Panel")

  detailsBtn:SetScript("OnClick", function()
    UI.detailsPanelOpen = not UI.detailsPanelOpen
    if db and db.ui then db.ui.detailsPanelOpen = UI.detailsPanelOpen end
    ApplyDetailsPanelForCategory(UI.activeCategory or "All")
    RefreshDetailsButton()
    rerender()
  end)
  detailsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Details Panel", 1, 1, 1)
    GameTooltip:AddLine("Show or hide the item details panel on the right.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end)
  detailsBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  modeBtn = CreateFrame("Button", nil, rightToolbar, "BackdropTemplate")
  Backdrop(modeBtn, T.panel, T.border)
  modeBtn:SetSize(64, 20)
  modeBtn:SetPoint("TOPRIGHT", detailsBtn, "TOPLEFT", -6, 0)
  Hover(modeBtn, T.panel, T.hover)

  modeBtn.text = NewFS(modeBtn, "GameFontNormal")
  modeBtn.text:SetPoint("CENTER")

  modeBtn:SetScript("OnClick", function()
    UI.catalogMode = (UI.catalogMode == "All Items") and "Sections" or "All Items"
    if db and db.ui then db.ui.catalogMode = UI.catalogMode end
    if NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
      NS.UI.HeaderController:Reset()
    end
    RefreshModeButton()
    rerender()
  end)
  modeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Browse Mode", 1, 1, 1)
    GameTooltip:AddLine("Sections keeps expansion/category progress groups. All Items turns the current category into one unified browser.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
  end)
  modeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  RefreshModeButton()
  RefreshDetailsButton()

  decorPricingBtn = MakeTopButton(bar, 120, 24)
  decorPricingBtn:SetPoint("LEFT", eventsBtn, "RIGHT", 6, 0)
  decorPricingBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
  decorPricingBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  decorPricingBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  decorPricingBtn.text:SetText(Loc["DECOR_PRICING"])
  TextColor(decorPricingBtn.text, "text")

  decorPricingBtn:SetScript("OnClick", function()
    SelectCategory("Decor Pricing")
    if NS.UI and NS.UI.ShowProfessionsTipPopup then NS.UI:ShowProfessionsTipPopup() end
  end)

  altProfsTopBtn = MakeTopButton(bar, 130, 24)
  altProfsTopBtn:SetPoint("LEFT", decorPricingBtn, "RIGHT", 6, 0)
  altProfsTopBtn.icon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
  altProfsTopBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  altProfsTopBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  altProfsTopBtn.text:SetText(Loc["ALTS_PROFESSIONS"])
  TextColor(altProfsTopBtn.text, "text")

  altProfsTopBtn:SetScript("OnClick", function()
    SelectCategory("Alts Professions")
    if NS.UI and NS.UI.ShowProfessionsTipPopup then NS.UI:ShowProfessionsTipPopup() end
  end)

  endeavorsTopBtn = MakeTopButton(bar, 110, 24)
  endeavorsTopBtn:SetPoint("LEFT", altProfsTopBtn, "RIGHT", 6, 0)
  endeavorsTopBtn.icon:SetTexture("Interface\\Icons\\achievement_zone_cataclysm")
  endeavorsTopBtn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  endeavorsTopBtn.icon:SetVertexColor(1, 1, 1, 0.9)
  endeavorsTopBtn.text:SetText("Endeavors")
  TextColor(endeavorsTopBtn.text, "text")

  endeavorsTopBtn:SetScript("OnClick", function()
    if not NS.UI.EndeavorsPanel then
      NS.UI.EndeavorsPanel = NS.UI.Endeavors:Create(rightContent)
    end
    SelectCategory("Endeavors")

    if NS.UI.EndeavorsPanel:IsShown() then
      NS.UI.EndeavorsPanel:FullRefresh()
    else
      NS.UI.EndeavorsPanel:Show()
    end
  end)

  local SORT_CAT_EXCLUDED = {
    ["Events"] = true,
    ["Architect"] = true,
    ["Decor Pricing"] = true,
    ["Alts Professions"] = true,
    ["Endeavors"] = true,
  }

  local SORT_OPTIONS = {
    { value = "expAsc",  text = "Expansion: Old to New" },
    { value = "expDesc", text = "Expansion: New to Old" },
  }


  local sortDropdown = Dropdown.Create(
    bar,
    "",
    nil,
    160,
    function() return (db.ui and db.ui.sortMode) or "expAsc" end,
    function(v)
      db.ui.sortMode = v
      local HeaderCtrl = NS.UI and NS.UI.HeaderController
      if HeaderCtrl and HeaderCtrl.Reset then HeaderCtrl:Reset() end
      rerender()
    end,
    function() return SORT_OPTIONS end,
    nil,
    C, T
  )

  sortDropdown:SetWidth(176)
  sortDropdown:SetParent(rightToolbar)
  sortDropdown:ClearAllPoints()
  sortDropdown:SetPoint("TOPRIGHT", modeBtn, "TOPLEFT", -8, 0)
  f.SortDropdown = sortDropdown

  local function MakeQuickFilterButton(text, width)
    local b = CreateFrame("Button", nil, rightToolbar, "BackdropTemplate")
    Backdrop(b, T.panel, T.border)
    SkinBtn(b)
    b:SetSize(width or 58, 20)
    Hover(b, T.panel, T.hover)
    b.text = NewFS(b, "GameFontNormal")
    b.text:SetPoint("CENTER")
    b.text:SetText(text)
    TextColor(b.text, "text")
    return b
  end

  local ownedQuickBtn = MakeQuickFilterButton("Owned", 58)
  ownedQuickBtn:SetPoint("RIGHT", sortDropdown, "LEFT", -8, 0)

  local missingQuickBtn = MakeQuickFilterButton("Missing", 64)
  missingQuickBtn:SetPoint("RIGHT", ownedQuickBtn, "LEFT", -4, 0)

  local allQuickBtn = MakeQuickFilterButton("All", 44)
  allQuickBtn:SetPoint("RIGHT", missingQuickBtn, "LEFT", -4, 0)

  local moreFiltersBtn = MakeQuickFilterButton("Filters", 66)
  moreFiltersBtn:SetPoint("RIGHT", allQuickBtn, "LEFT", -6, 0)
  local moreFiltersIcon = moreFiltersBtn:CreateTexture(nil, "OVERLAY")
  moreFiltersIcon:SetSize(12, 12)
  moreFiltersIcon:SetPoint("LEFT", moreFiltersBtn, "LEFT", 7, 0)
  moreFiltersIcon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
  C:TextureColor(moreFiltersIcon, "accent")
  moreFiltersBtn.text:ClearAllPoints()
  moreFiltersBtn.text:SetPoint("LEFT", moreFiltersIcon, "RIGHT", 4, 0)

  local resetTopBtn = MakeQuickFilterButton("Reset", 58)
  resetTopBtn:SetPoint("LEFT", moreFiltersBtn, "RIGHT", 6, 0)
  local resetTopIcon = resetTopBtn:CreateTexture(nil, "OVERLAY")
  resetTopIcon:SetSize(12, 12)
  resetTopIcon:SetPoint("LEFT", resetTopBtn, "LEFT", 7, 0)
  resetTopIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
  C:TextureColor(resetTopIcon, "accent")
  resetTopBtn.text:ClearAllPoints()
  resetTopBtn.text:SetPoint("LEFT", resetTopIcon, "RIGHT", 4, 0)

  local topFactionDropdown
  local topSourceDropdown
  local topExpansionDropdown
  local topZoneDropdown
  local topCategoryDropdown

  local function syncFilterSurfaces()
    local filterContent = left and left.filterContent
    if filterContent and filterContent.SyncVisuals then filterContent:SyncVisuals() end
    if topSourceDropdown and topSourceDropdown.ApplyText then topSourceDropdown:ApplyText() end
    if topFactionDropdown and topFactionDropdown.ApplyText then topFactionDropdown:ApplyText() end
    if topExpansionDropdown and topExpansionDropdown.ApplyText then topExpansionDropdown:ApplyText() end
    if topZoneDropdown and topZoneDropdown.ApplyText then topZoneDropdown:ApplyText() end
    if topCategoryDropdown and topCategoryDropdown.ApplyText then topCategoryDropdown:ApplyText() end
    if RefreshQuickFilters then RefreshQuickFilters() end
  end

  local function resetHeaderAndRender()
    local HeaderCtrl = NS.UI and NS.UI.HeaderController
    if HeaderCtrl and HeaderCtrl.Reset then HeaderCtrl:Reset() end
    syncFilterSurfaces()
    rerender()
  end

  local function runFullFilterReset()
    local fc = left and left.filterContent
    if fc and fc.ResetAllFilters then
      fc:ResetAllFilters()
    else
      local flt = db and db.filters
      if not flt then return end
      flt.expansion, flt.zone, flt.color, flt.sourceType, flt.category, flt.subcategory, flt.faction = "ALL", "ALL", "ALL", "ALL", "ALL", "ALL", "ALL"
      flt.colors = {}
      flt.budgetCosts = {}
      flt.sizes = {}
      flt.hideCollected, flt.onlyCollected = false, false
      flt.availableRepOnly = false
      flt.questsCompleted = false
      flt.achievementCompleted = false
      flt.hidePvpItems = false
      if Filters then
        Filters.expansion, Filters.zone, Filters.sourceType, Filters.category, Filters.subcategory, Filters.faction =
          flt.expansion, flt.zone, flt.sourceType, flt.category, flt.subcategory, flt.faction
        Filters.color = "ALL"
        Filters.colors = flt.colors
        Filters.budgetCosts = flt.budgetCosts
        Filters.sizes = flt.sizes
        Filters.hideCollected = false
        Filters.onlyCollected = false
        Filters.availableRepOnly = false
        Filters.questsCompleted = false
        Filters.achievementCompleted = false
        Filters.hidePvpItems = false
      end
      resetHeaderAndRender()
    end
    syncFilterSurfaces()
  end

  topFactionDropdown = Dropdown.Create(
    rightToolbar,
    "",
    nil,
    118,
    function() return (db.filters and db.filters.faction) or "ALL" end,
    function(v)
      db.filters.faction = v or "ALL"
      if Filters then Filters.faction = db.filters.faction end
      local FS = LiveFiltersSys()
      if FS then FS.faction = db.filters.faction end
      resetHeaderAndRender()
    end,
    function()
      return {
        { value = "ALL", text = "Faction: All" },
        { value = "Alliance", text = "Alliance" },
        { value = "Horde", text = "Horde" },
      }
    end,
    nil,
    C, T
  )

  topSourceDropdown = Dropdown.Create(
    rightToolbar,
    "",
    nil,
    120,
    function() return (db.filters and db.filters.sourceType) or "ALL" end,
    function(v)
      db.filters.sourceType = v or "ALL"
      if Filters then Filters.sourceType = db.filters.sourceType end
      local FS = LiveFiltersSys()
      if FS then FS.sourceType = db.filters.sourceType end
      resetHeaderAndRender()
    end,
    function()
      return {
        { value = "ALL", text = "Source: All" },
        { value = "vendor", text = "Vendors" },
        { value = "quest", text = "Quests" },
        { value = "achievement", text = "Achievements" },
        { value = "drop", text = "Drops" },
        { value = "profession", text = "Professions" },
        { value = "event", text = "Events" },
        { value = "pvp", text = "PvP" },
      }
    end,
    nil,
    C, T
  )

  topExpansionDropdown = Dropdown.Create(
    rightToolbar,
    "",
    nil,
    146,
    function() return (db.filters and db.filters.expansion) or "ALL" end,
    function(v)
      db.filters.expansion = v or "ALL"
      db.filters.zone = "ALL"
      if Filters then
        Filters.expansion = db.filters.expansion
        Filters.zone = db.filters.zone
      end
      local FS = LiveFiltersSys()
      if FS then
        FS.expansion = db.filters.expansion
        FS.zone = db.filters.zone
      end
      resetHeaderAndRender()
    end,
    function()
      local FS = LiveFiltersSys()
      local opts = FS and FS.GetExpansions and FS:GetExpansions() or { { value = "ALL", text = "All" } }
      if opts and opts[1] and opts[1].value == "ALL" then opts[1].text = "Expansion: All" end
      return opts
    end,
    nil,
    C, T
  )

  topZoneDropdown = Dropdown.Create(
    rightToolbar,
    "",
    nil,
    126,
    function() return (db.filters and db.filters.zone) or "ALL" end,
    function(v)
      db.filters.zone = v or "ALL"
      if Filters then Filters.zone = db.filters.zone end
      local FS = LiveFiltersSys()
      if FS then FS.zone = db.filters.zone end
      resetHeaderAndRender()
    end,
    function()
      local FS = LiveFiltersSys()
      local opts = FS and FS.GetZones and FS:GetZones(UI, db) or { { value = "ALL", text = "All Zones" } }
      if opts and opts[1] and opts[1].value == "ALL" then opts[1].text = "Zone: All" end
      return opts
    end,
    nil,
    C, T
  )

  topCategoryDropdown = Dropdown.Create(
    rightToolbar,
    "",
    nil,
    136,
    function() return (db.filters and db.filters.category) or "ALL" end,
    function(v)
      local FS = LiveFiltersSys()
      db.filters.category = (FS and FS.ResolveCategoryID and FS:ResolveCategoryID(v)) or v or "ALL"
      db.filters.subcategory = "ALL"
      if Filters then
        Filters.category = db.filters.category
        Filters.subcategory = db.filters.subcategory
      end
      if FS then
        FS.category = db.filters.category
        FS.subcategory = db.filters.subcategory
      end
      resetHeaderAndRender()
    end,
    function()
      local FS = LiveFiltersSys()
      local opts = FS and FS.GetCategoryOptions and FS:GetCategoryOptions() or { { value = "ALL", text = "All Categories" } }
      if opts and opts[1] and opts[1].value == "ALL" then opts[1].text = "Category: All" end
      return opts
    end,
    nil,
    C, T
  )

  local function setCompletionFilter(mode)
    local flt = db and db.filters
    if not flt then return end
    local hideCollected = (mode == "missing")
    local onlyCollected = (mode == "owned")
    if (flt.hideCollected == true) == hideCollected and (flt.onlyCollected == true) == onlyCollected then
      syncFilterSurfaces()
      return
    end
    flt.hideCollected = hideCollected
    flt.onlyCollected = onlyCollected
    if Filters then
      Filters.hideCollected = flt.hideCollected
      Filters.onlyCollected = flt.onlyCollected
    end
    syncFilterSurfaces()
    rerender()
  end

  allQuickBtn:SetScript("OnClick", function() setCompletionFilter("all") end)
  missingQuickBtn:SetScript("OnClick", function() setCompletionFilter("missing") end)
  ownedQuickBtn:SetScript("OnClick", function() setCompletionFilter("owned") end)
  moreFiltersBtn:SetScript("OnClick", function()
    if f.FilterDrawer then
      f.FilterDrawer:SetShown(not f.FilterDrawer:IsShown())
    end
  end)
  resetTopBtn:SetScript("OnClick", runFullFilterReset)

  RefreshQuickFilters = function()
    local flt = (db and db.filters) or {}
    SetToggleButtonState(allQuickBtn, not flt.hideCollected and not flt.onlyCollected)
    SetToggleButtonState(missingQuickBtn, flt.hideCollected == true)
    SetToggleButtonState(ownedQuickBtn, flt.onlyCollected == true)
  end
  RefreshQuickFilters()

  UpdateSortVisibility = function()
    local cat = UI.activeCategory or ""
    if SORT_CAT_EXCLUDED[cat] then
      sortDropdown:Hide()
      if allQuickBtn then allQuickBtn:Hide() end
      if missingQuickBtn then missingQuickBtn:Hide() end
      if ownedQuickBtn then ownedQuickBtn:Hide() end
      if moreFiltersBtn then moreFiltersBtn:Hide() end
      if resetTopBtn then resetTopBtn:Hide() end
      if topSourceDropdown then topSourceDropdown:Hide() end
      if topFactionDropdown then topFactionDropdown:Hide() end
      if topExpansionDropdown then topExpansionDropdown:Hide() end
      if topZoneDropdown then topZoneDropdown:Hide() end
      if topCategoryDropdown then topCategoryDropdown:Hide() end
    else
      sortDropdown:Hide()
      if allQuickBtn then allQuickBtn:Show() end
      if missingQuickBtn then missingQuickBtn:Show() end
      if ownedQuickBtn then ownedQuickBtn:Show() end
      if moreFiltersBtn then moreFiltersBtn:Show() end
      if resetTopBtn then resetTopBtn:Hide() end
      if topSourceDropdown then topSourceDropdown:Hide() end
      if topFactionDropdown then topFactionDropdown:Hide() end
      if topExpansionDropdown then topExpansionDropdown:Hide() end
      if topZoneDropdown then topZoneDropdown:Hide() end
      if topCategoryDropdown then topCategoryDropdown:Hide() end
      if sortDropdown.ApplyText then sortDropdown:ApplyText() end
      if RefreshQuickFilters then RefreshQuickFilters() end
    end
  end

  UpdateRightToolbarVisibility = function()
    local cat = UI.activeCategory or ""
    local hideToolbar = IsWindowCategory(cat)

    rightContent:ClearAllPoints()
    if hideToolbar then
      rightToolbar:Hide()
      rightContent:SetPoint("TOPLEFT", right, "TOPLEFT", 8, -8)
      rightContent:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -8, 8)
    else
      rightToolbar:Show()
      rightContent:SetPoint("TOPLEFT", rightToolbar, "BOTTOMLEFT", 0, -1)
      rightContent:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -8, 8)
    end
  end

  local search = CreateFrame("EditBox", nil, bar, "BackdropTemplate")
  Backdrop(search, T.panel, T.border)
  search:SetParent(rightToolbar)
  search:ClearAllPoints()
  search:SetPoint("TOPLEFT", rightToolbar, "TOPLEFT", 8, -4)
  search:SetPoint("RIGHT", moreFiltersBtn, "LEFT", -8, 0)
  search:SetHeight(20)
  search:SetAutoFocus(false)
  search:SetFontObject(GameFontHighlightSmall)
  search:SetTextInsets(8, 26, 0, 0)
  search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

  allQuickBtn:ClearAllPoints()
  allQuickBtn:SetPoint("BOTTOMLEFT", rightToolbar, "BOTTOMLEFT", 8, 5)

  missingQuickBtn:ClearAllPoints()
  missingQuickBtn:SetPoint("LEFT", allQuickBtn, "RIGHT", 4, 0)

  ownedQuickBtn:ClearAllPoints()
  ownedQuickBtn:SetPoint("LEFT", missingQuickBtn, "RIGHT", 4, 0)

  topExpansionDropdown:ClearAllPoints()
  topExpansionDropdown:SetPoint("LEFT", ownedQuickBtn, "RIGHT", 8, 0)
  topExpansionDropdown:SetPoint("BOTTOM", rightToolbar, "BOTTOM", 0, 4)
  topExpansionDropdown:SetWidth(146)
  topExpansionDropdown:Hide()

  topCategoryDropdown:ClearAllPoints()
  topCategoryDropdown:SetPoint("RIGHT", header.viewModeGroup or rightToolbar, "LEFT", -8, 0)
  topCategoryDropdown:SetPoint("BOTTOM", rightToolbar, "BOTTOM", 0, 4)
  topCategoryDropdown:SetWidth(136)

  topZoneDropdown:ClearAllPoints()
  topZoneDropdown:SetPoint("RIGHT", topCategoryDropdown, "LEFT", -6, 0)
  topZoneDropdown:SetPoint("BOTTOM", rightToolbar, "BOTTOM", 0, 4)
  topZoneDropdown:SetWidth(126)

  topFactionDropdown:ClearAllPoints()
  topFactionDropdown:SetPoint("RIGHT", topZoneDropdown, "LEFT", -6, 0)
  topFactionDropdown:SetPoint("BOTTOM", rightToolbar, "BOTTOM", 0, 4)
  topFactionDropdown:SetWidth(118)

  topSourceDropdown:ClearAllPoints()
  topSourceDropdown:SetPoint("RIGHT", topFactionDropdown, "LEFT", -6, 0)
  topSourceDropdown:SetPoint("BOTTOM", rightToolbar, "BOTTOM", 0, 4)
  topSourceDropdown:SetWidth(120)

  resetTopBtn:ClearAllPoints()
  resetTopBtn:SetPoint("TOPRIGHT", sortDropdown, "TOPLEFT", -6, 0)
  resetTopBtn:Hide()

  moreFiltersBtn:ClearAllPoints()
  moreFiltersBtn:SetPoint("TOPRIGHT", modeBtn, "TOPLEFT", -8, 0)

  local placeholder = search:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  placeholder:SetPoint("LEFT", search, "LEFT", 8, 0)
  placeholder:SetText(Loc["SEARCH_PLACEHOLDER"])
  TextColor(placeholder, "placeholder")

  f.SearchBox = search
  f.SearchPlaceholder = placeholder

  local clearBtn = CreateFrame("Button", nil, search, "BackdropTemplate")
  Backdrop(clearBtn, T.panel, T.border)
  clearBtn:SetSize(18, 18)
  clearBtn:SetPoint("RIGHT", search, "RIGHT", -6, 0)
  Hover(clearBtn, T.panel, T.hover)

  local clearIcon = clearBtn:CreateTexture(nil, "OVERLAY")
  clearIcon:SetSize(12, 12)
  clearIcon:SetPoint("CENTER", 0, 0)
  clearIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
  C:TextureColor(clearIcon, "accent", 0.95)

  clearBtn:Hide()
  search._clearBtn = clearBtn

  setSearchUI = function(hasText)
    clearBtn:SetShown(hasText)
    placeholder:SetShown((not hasText) and (not search:HasFocus()))
  end

  local function routeCategoryCommand(q)
    if q == "achievement" or q == "achievements" then return "Achievements" end
    if q == "quest" or q == "quests" then return "Quests" end
    if q == "vendor" or q == "vendors" then return "Vendors" end
    if q == "drop" or q == "drops" then return "Drops" end
    if q == "profession" or q == "professions" then return "Professions" end
    if q == "pvp" then return "PvP" end
    if q == "all" or q == "everything" or q == "all sources" then return "All" end
    if q == "event" or q == "events" then return "Events" end
    if q == "pricing" or q == "decor pricing" or q == "price" then return "Decor Pricing" end
    if q == "architect" or q == "planner" or q == "blueprint" or q == "layouts" then return "Architect" end
    if q == "alts" or q == "alts professions" or q == "professions alts" then return "Alts Professions" end
    if q == "endeavor" or q == "endeavors" then return "Endeavors" end
    return nil
  end

  clearBtn:SetScript("OnClick", function()
    search._squelchCmd = true
    search:SetText("")
    search:ClearFocus()
    search._squelchCmd = false

    UI.search = ""
    db.ui.search = ""
    UI._searchNorm = ""
    UI._searchLast = ""
    UI._searchTokens = UI._searchTokens or {}
    for i = #UI._searchTokens, 1, -1 do UI._searchTokens[i] = nil end

    if FiltersSys and FiltersSys.PrepareSearch then
      FiltersSys:PrepareSearch(UI)
    end

    setSearchUI(false)

    if UI.activeCategory == "Search" and UI._searchPrevCategory then
      UI.activeCategory = UI._searchPrevCategory
      UI._searchPrevCategory = nil
    end

    rerender()
  end)

  search:SetText(UI.search or "")
  setSearchUI((search:GetText() or "") ~= "")

  search:SetScript("OnTextChanged", function(self)
    if self._squelchCmd then return end

    local txt = self:GetText() or ""
    UI.search = txt
    db.ui.search = txt

    local q = strlower(Trim(txt))
    local cmd = routeCategoryCommand(q)

    if cmd then
      if UI.activeCategory ~= cmd then SelectCategory(cmd) end
      setSearchUI(true)
      rerender()
      return
    end

    if q ~= "" then
      if UI.activeCategory ~= "Search" then
        UI._searchPrevCategory = UI.activeCategory
        UI.activeCategory = "Search"
      end
    else
      if UI.activeCategory == "Search" and UI._searchPrevCategory then
        UI.activeCategory = UI._searchPrevCategory
        UI._searchPrevCategory = nil
      end
    end

    setSearchUI(txt ~= "")
    rerender()
  end)

  search:SetScript("OnEditFocusGained", function()
    placeholder:Hide()
    setSearchUI((search:GetText() or "") ~= "")
  end)

  search:SetScript("OnEditFocusLost", function()
    setSearchUI((search:GetText() or "") ~= "")
  end)

  if NS.UI and NS.UI.FilterPopup and NS.UI.FilterPopup.Build then
    NS.UI.FilterPopup:Build(filterContent, {
      C = C,
      T = T,
      Dropdown = Dropdown,
      Filters = Filters,
      FiltersSys = FiltersSys,
      UI = UI,
      db = db,
      rerender = rerender,
    })
  end

  local filterDrawer = CreateFrame("Frame", nil, f, "BackdropTemplate")
  f.FilterDrawer = filterDrawer
  Backdrop(filterDrawer, T.panel, T.border)
  if C.ApplyBackground and Textures and Textures.GalleryPanel then
    C:ApplyBackground(filterDrawer, Textures.GalleryPanel, 0, 1)
  end
  filterDrawer:SetFrameStrata("FULLSCREEN_DIALOG")
  filterDrawer:SetFrameLevel((f:GetFrameLevel() or 100) + 40)
  filterDrawer:SetSize(360, 560)
  filterDrawer:SetMovable(true)
  filterDrawer:EnableMouse(true)
  filterDrawer:SetClampedToScreen(true)
  filterDrawer:RegisterForDrag("LeftButton")
  filterDrawer:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)
  filterDrawer:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local db2 = NS.db and NS.db.profile
    if db2 and db2.ui then
      db2.ui.filterDrawerPoint = nil
      db2.ui.filterDrawerX = self:GetLeft()
      db2.ui.filterDrawerY = self:GetTop()
    end
  end)
  filterDrawer:SetPoint("TOPLEFT", rightToolbar, "BOTTOMLEFT", 0, -4)
  filterDrawer:SetScript("OnShow", function(self)
    local db2 = NS.db and NS.db.profile
    local ui2 = db2 and db2.ui
    if ui2 and ui2.filterDrawerX and ui2.filterDrawerY then
      self:ClearAllPoints()
      self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ui2.filterDrawerX, ui2.filterDrawerY)
    end
  end)
  filterDrawer:Hide()

  local drawerTitle = NewFS(filterDrawer, "GameFontNormal")
  drawerTitle:SetPoint("TOPLEFT", 10, -8)
  drawerTitle:SetText("Filters")
  TextColor(drawerTitle, "accent")

  local drawerClose = CreateFrame("Button", nil, filterDrawer, "BackdropTemplate")
  Backdrop(drawerClose, T.panel, T.border)
  drawerClose:SetSize(20, 20)
  drawerClose:SetPoint("TOPRIGHT", -8, -6)
  Hover(drawerClose, T.panel, T.hover)
  local drawerCloseIcon = drawerClose:CreateTexture(nil, "OVERLAY")
  drawerCloseIcon:SetSize(12, 12)
  drawerCloseIcon:SetPoint("CENTER")
  drawerCloseIcon:SetTexture("Interface\\Buttons\\UI-StopButton")
  C:TextureColor(drawerCloseIcon, "accent")
  drawerClose:SetScript("OnClick", function() filterDrawer:Hide() end)

  local drawerReset = CreateFrame("Button", nil, filterDrawer, "BackdropTemplate")
  Backdrop(drawerReset, T.panel, T.border)
  drawerReset:SetPoint("BOTTOMLEFT", 8, 8)
  drawerReset:SetPoint("BOTTOMRIGHT", -8, 8)
  drawerReset:SetHeight(26)
  Hover(drawerReset, T.panel, T.hover)
  local drawerResetIcon = drawerReset:CreateTexture(nil, "OVERLAY")
  drawerResetIcon:SetSize(14, 14)
  drawerResetIcon:SetPoint("LEFT", 10, 0)
  drawerResetIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
  C:TextureColor(drawerResetIcon, "accent")
  local drawerResetText = NewFS(drawerReset, "GameFontNormal")
  drawerResetText:SetPoint("LEFT", drawerResetIcon, "RIGHT", 6, 0)
  drawerResetText:SetText(Loc["RESET_ALL_FILTERS"] or "Reset All Filters")
  TextColor(drawerResetText, "accent")
  drawerReset:SetScript("OnClick", function()
    local fc = left and left.filterContent
    if fc and fc.ResetAllFilters then
      fc:ResetAllFilters()
    end
  end)

  local drawerScroll = CreateFrame("ScrollFrame", nil, filterDrawer, "ScrollFrameTemplate")
  drawerScroll:SetPoint("TOPLEFT", 8, -34)
  drawerScroll:SetPoint("BOTTOMRIGHT", -26, 42)
  drawerScroll:SetScrollChild(filterContent)
  drawerScroll:SetScript("OnSizeChanged", function(self, w)
    filterContent:SetWidth((w or 0) - 2)
    if filterContent.Refresh then filterContent:Refresh() end
  end)
  if C and C.SkinScrollFrame then C:SkinScrollFrame(drawerScroll) end

  filterContent:SetParent(drawerScroll)
  filterContent:ClearAllPoints()
  filterContent:SetPoint("TOPLEFT", 0, 0)
  filterContent:SetWidth(248)
  if filterContent.Refresh then filterContent:Refresh() end

  filterScroll:Hide()
  filtersTitle:Hide()
  filtersLine:Hide()

  if NS.UI and NS.UI.ResizeBar then
    NS.UI.ResizeBar:Attach(f, header)
    dockScale(f, header)
  end

  if header then
    header:HookScript("OnShow", function() dockScale(f, header); if LayoutModeBar then LayoutModeBar() end end)
    header:HookScript("OnSizeChanged", function() dockScale(f, header); if LayoutModeBar then LayoutModeBar() end end)
  end
  f:HookScript("OnShow", function() dockScale(f, header); if LayoutModeBar then LayoutModeBar() end; RefreshLeftLayout() end)
  f:HookScript("OnSizeChanged", function() dockScale(f, header); if LayoutModeBar then LayoutModeBar() end; RefreshLeftLayout() end)
  RefreshLeftLayout()
  if LayoutModeBar then LayoutModeBar() end

  if NS.UI and NS.UI.ViewFactory and NS.UI.ViewFactory.Create then
    f.view = NS.UI.ViewFactory:Create(f, UI, db)
  elseif NS.UI and NS.UI.Viewer and NS.UI.Viewer.Create then
    f.view = NS.UI.Viewer:Create(rightContent or right)
  end
  if UI.activeCategory == "Architect" and NS.UI and NS.UI.Architect and not NS.UI.ArchitectPanel then
    NS.UI.ArchitectPanel = NS.UI.Architect:Create(rightContent)
    if NS.UI.ArchitectPanel and NS.UI.ArchitectPanel.Refresh then NS.UI.ArchitectPanel:Refresh() end
    if NS.UI.ArchitectPanel then NS.UI.ArchitectPanel:Show() end
  end
  if f.view and f.view.SetInspectorOpen then
    ApplyDetailsPanelForCategory(UI.activeCategory or "All", true)
  end
  if f.view and f.view.OnShow then f.view:OnShow() end
  rerender()

  if NS.UI and NS.UI.HeaderController and NS.UI.HeaderController.Reset then
    NS.UI.HeaderController:Reset()
  end

  local function CancelTicker()
    if f.eventTimer and f.eventTimer.Cancel then
      f.eventTimer:Cancel()
    end
    f.eventTimer = nil
  end

  f:HookScript("OnShow", function()
    if UpdateTopTabs then UpdateTopTabs() end
    if UpdateSortVisibility then UpdateSortVisibility() end
    if UpdateRightToolbarVisibility then UpdateRightToolbarVisibility() end
    if ScheduleEventStateRefresh then ScheduleEventStateRefresh() end
  end)

  f:HookScript("OnHide", function()
    CancelTicker()
  end)

  if UpdateTopTabs then UpdateTopTabs() end
  if UpdateSortVisibility then UpdateSortVisibility() end
  if UpdateRightToolbarVisibility then UpdateRightToolbarVisibility() end
  RefreshModeButton()
  RefreshViewModeButtons()
  RefreshDetailsButton()

  if Collection and Collection.RegisterListener and not f._hdCategoryCountsListener then
    f._hdCategoryCountsListener = true
    Collection:RegisterListener(function()
      C_Timer.After(0, function()
        if not f or not left or not left.buttons then return end
        RefreshCategoryTexts()
      end)
    end)
  end

  return f
end

return L
