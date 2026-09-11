local _, NS = ...

NS.UI = NS.UI or {}
local Controls = {}
NS.UI.Controls = Controls

Controls.colors = {
  background = { 0.008, 0.010, 0.010, 0.99 },
  header = { 0.018, 0.019, 0.016, 0.99 },
  panel = { 0.030, 0.031, 0.027, 0.99 },
  row = { 0.044, 0.044, 0.038, 0.98 },
  hover = { 0.080, 0.070, 0.038, 0.98 },
  border = { 0.34, 0.27, 0.08, 1 },
  accent = { 1.00, 0.76, 0.08, 1 },
  highlight = { 0.86, 0.68, 0.04, 1 },
  text = { 0.93, 0.91, 0.85, 1 },
  muted = { 0.64, 0.62, 0.56, 1 },
  danger = { 1.00, 0.38, 0.38, 1 },
  success = { 0.36, 0.92, 0.52, 1 },
}

Controls.defaultColors = {}
for key, color in pairs(Controls.colors) do
  Controls.defaultColors[key] = { color[1], color[2], color[3], color[4] }
end

Controls.backdrops = setmetatable({}, { __mode = "k" })
Controls.texts = setmetatable({}, { __mode = "k" })

Controls.scrollFrames = setmetatable({}, { __mode = "k" })

local function ColorRegion(region, color, alpha)
  if not region or not region.SetVertexColor then return end
  region:SetVertexColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function ColorRole(color)
  for key, value in pairs(Controls.colors) do
    if value == color then return key end
  end
end

local function ApplyFont(text, entry)
  if not text or not entry or not entry.path or not entry.size then return end
  local profile = NS.Systems.Database and NS.Systems.Database:GetProfile()
  local appearance = profile and profile.ui and profile.ui.appearance
  local scale = math.max(0.8, math.min(1.35, tonumber(appearance and appearance.fontScale) or 1))
  text:SetFont(entry.path, math.max(7, entry.size * scale), entry.flags or "")
end

function Controls:ApplyAppearance()
  local profile = NS.Systems.Database and NS.Systems.Database:GetProfile()
  local appearance = profile and profile.ui and profile.ui.appearance
  local saved = appearance and appearance.colors or {}
  local preset = NS.UI.Theme and NS.UI.Theme.GetColors and NS.UI.Theme:GetColors() or {}
  for key, defaults in pairs(self.defaultColors) do
    local source = saved[key] or preset[key] or defaults
    if type(source) ~= "table" then source = defaults end
    local target = self.colors[key]
    target[1] = tonumber(source.r or source[1]) or defaults[1]
    target[2] = tonumber(source.g or source[2]) or defaults[2]
    target[3] = tonumber(source.b or source[3]) or defaults[3]
    target[4] = defaults[4]
  end
  for frame, entry in pairs(self.backdrops) do
    local background = self.colors[entry.background]
    local border = self.colors[entry.border]
    if background then frame:SetBackdropColor(background[1], background[2], background[3], background[4] or 1) end
    if border then frame:SetBackdropBorderColor(border[1], border[2], border[3], border[4] or 1) end
  end
  for text, entry in pairs(self.texts) do
    local color = self.colors[entry.role] or self.colors.text
    text:SetTextColor(color[1], color[2], color[3], entry.alpha or color[4] or 1)
    ApplyFont(text, entry)
  end
  self:RefreshScrollFrameColors()
end

function Controls:SetAppearanceColor(key, r, g, b)
  local profile = NS.Systems.Database:GetProfile()
  if not profile or not self.colors[key] then return end
  profile.ui.appearance = profile.ui.appearance or { font = "Game Default", fontScale = 1, colors = {} }
  profile.ui.appearance.colors = profile.ui.appearance.colors or {}
  profile.ui.appearance.colors[key] = { r = r, g = g, b = b }
  self:ApplyAppearance()
end

function Controls:ResetAppearance()
  local profile = NS.Systems.Database:GetProfile()
  if not profile then return end
  profile.ui.appearance = { font = "Game Default", fontScale = 1, colors = {} }
  self:ApplyAppearance()
end

function Controls:ApplyScrollFrameColors(scroll)
  if not scroll then return end
  local bar = scroll.ScrollBar or scroll.scrollBar
  if not bar and scroll.GetName then
    local name = scroll:GetName()
    if name then bar = _G[name .. "ScrollBar"] end
  end
  if not bar then return end
  local accent = self.colors.accent
  local border = self.colors.border
  local track = bar.Track
  if track then
    ColorRegion(track.Begin, border, 0.7)
    ColorRegion(track.Middle, border, 0.7)
    ColorRegion(track.End, border, 0.7)
  end
  local thumb = bar.Thumb or bar.ThumbTexture or (bar.GetThumbTexture and bar:GetThumbTexture())
  if thumb then
    ColorRegion(thumb, accent, 0.95)
    ColorRegion(thumb.Begin, accent, 0.95)
    ColorRegion(thumb.Middle, accent, 0.95)
    ColorRegion(thumb.End, accent, 0.95)
  end
  local up = bar.ScrollUpButton or bar.Back
  local down = bar.ScrollDownButton or bar.Forward
  if up then
    ColorRegion(up.Texture, accent, 0.95)
    ColorRegion(up.GetNormalTexture and up:GetNormalTexture(), accent, 0.95)
    ColorRegion(up.GetPushedTexture and up:GetPushedTexture(), accent, 1)
    ColorRegion(up.GetHighlightTexture and up:GetHighlightTexture(), accent, 1)
  end
  if down then
    ColorRegion(down.Texture, accent, 0.95)
    ColorRegion(down.GetNormalTexture and down:GetNormalTexture(), accent, 0.95)
    ColorRegion(down.GetPushedTexture and down:GetPushedTexture(), accent, 1)
    ColorRegion(down.GetHighlightTexture and down:GetHighlightTexture(), accent, 1)
  end
end

function Controls:RefreshScrollFrameColors()
  for scroll in pairs(self.scrollFrames) do self:ApplyScrollFrameColors(scroll) end
end

function Controls:Backdrop(frame, background, border)
  if not frame or not frame.SetBackdrop then return end
  local colors = self.colors
  local bg = background or colors.panel
  local edge = border or colors.border
  frame:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
  frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4] or 1)
  frame:SetBackdropBorderColor(edge[1], edge[2], edge[3], edge[4] or 1)
  local backgroundRole = ColorRole(background) or (background == nil and "panel")
  local borderRole = ColorRole(border) or (border == nil and "border")
  if backgroundRole or borderRole then self.backdrops[frame] = { background = backgroundRole, border = borderRole } end
end

function Controls:ApplyHover(frame, background, hover)
  if not frame or frame._hdSharedHover then return end
  frame._hdSharedHover = true
  frame:HookScript("OnEnter", function(self)
    local color = hover or Controls.colors.hover
    if self.SetBackdropColor then self:SetBackdropColor(color[1], color[2], color[3], color[4] or 1) end
  end)
  frame:HookScript("OnLeave", function(self)
    local color = background or Controls.colors.panel
    if self.SetBackdropColor then self:SetBackdropColor(color[1], color[2], color[3], color[4] or 1) end
  end)
end

function Controls:TextColor(text, color, alpha)
  if not text then return end
  local role
  if type(color) == "string" then
    local aliases = {
      textMuted = "muted",
      highlight = "highlight",
      danger = "danger",
      success = "success",
    }
    role = aliases[color] or color
    color = self.colors[role]
  else
    role = ColorRole(color)
  end
  color = color or self.colors.text
  text:SetTextColor(color[1], color[2], color[3], alpha or color[4] or 1)
  local entry = self.texts[text]
  if not entry then
    local path, size, flags = text.GetFont and text:GetFont()
    entry = { path = path, size = size, flags = flags }
    self.texts[text] = entry
  end
  entry.role = role or "text"
  entry.alpha = alpha
  ApplyFont(text, entry)
end

function Controls:SkinButton(button)
  if not button or button._hdSharedSkin then return button end
  button._hdSharedSkin = true
  if not button.SetBackdrop and Mixin and BackdropTemplateMixin then Mixin(button, BackdropTemplateMixin) end
  local label = button.GetText and button:GetText() or ""
  local normal = button.GetNormalTexture and button:GetNormalTexture()
  local pushed = button.GetPushedTexture and button:GetPushedTexture()
  local disabled = button.GetDisabledTexture and button:GetDisabledTexture()
  if normal then normal:SetAlpha(0) end
  if pushed then pushed:SetAlpha(0) end
  if disabled then disabled:SetAlpha(0) end
  if button.Left then button.Left:SetAlpha(0) end
  if button.Middle then button.Middle:SetAlpha(0) end
  if button.Right then button.Right:SetAlpha(0) end
  self:Backdrop(button)
  local font = button.GetFontString and button:GetFontString()
  if not font and button.CreateFontString then
    font = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    font:SetPoint("CENTER")
    button:SetFontString(font)
  end
  if font then
    font:SetFontObject(GameFontNormalSmall)
    font:SetText(label or "")
    self:TextColor(font)
  end
  button:HookScript("OnEnter", function(self)
    local color = Controls.colors.hover
    if self.SetBackdropColor then self:SetBackdropColor(color[1], color[2], color[3], color[4]) end
  end)
  button:HookScript("OnLeave", function(self)
    local color = self._hdSelected and Controls.colors.hover or Controls.colors.panel
    if self.SetBackdropColor then self:SetBackdropColor(color[1], color[2], color[3], color[4]) end
    local border = self._hdSelected and Controls.colors.accent or Controls.colors.border
    if self.SetBackdropBorderColor then self:SetBackdropBorderColor(border[1], border[2], border[3], border[4]) end
  end)
  button:HookScript("OnDisable", function(self)
    if self.SetBackdropColor then self:SetBackdropColor(0.025, 0.025, 0.022, 0.72) end
    if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.20, 0.17, 0.08, 0.72) end
    local disabledFont = self.GetFontString and self:GetFontString()
    if disabledFont then Controls:TextColor(disabledFont, Controls.colors.muted) end
  end)
  button:HookScript("OnEnable", function(self)
    Controls:SetButtonSelected(self, self._hdSelected)
    local enabledFont = self.GetFontString and self:GetFontString()
    if enabledFont then Controls:TextColor(enabledFont, Controls.colors.text) end
  end)
  return button
end

function Controls:CreateButton(parent, label, width, height)
  local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
  button:SetSize(width or 80, height or 22)
  local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER")
  button:SetFontString(text)
  button.text = text
  button:SetText(label or "")
  self:SkinButton(button)
  return button
end

function Controls:CreateCloseButton(parent, onClick, width, height)
  local button = self:CreateButton(parent, "", width or 28, height or 26)
  button:RegisterForClicks("LeftButtonUp")
  if parent and parent.GetFrameLevel then button:SetFrameLevel(parent:GetFrameLevel() + 20) end
  local icon = button:CreateTexture(nil, "OVERLAY")
  icon:SetSize(14, 14)
  icon:SetPoint("CENTER")
  icon:SetTexture("Interface\\Buttons\\UI-StopButton")
  ColorRegion(icon, self.colors.accent)
  button.icon = icon
  button:SetScript("OnClick", onClick or function()
    if parent and parent.Hide then parent:Hide() end
  end)
  return button
end

function Controls:ToggleFrame(frame, onShow)
  if not frame then return false end
  if frame:IsShown() then
    frame:Hide()
    return false
  end
  frame:Show()
  if onShow then onShow(frame) end
  return true
end

function Controls:CreateDialog(name, title, width, height, layoutKey)
  local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
  frame:SetSize(width or 560, height or 380)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("FULLSCREEN_DIALOG")
  frame:SetFrameLevel(100)
  frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  self:Backdrop(frame, self.colors.background, self.colors.border)
  local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
  header:SetPoint("TOPLEFT", 7, -7)
  header:SetPoint("TOPRIGHT", -7, -7)
  header:SetHeight(48)
  self:Backdrop(header, self.colors.header, self.colors.border)
  local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleText:SetPoint("CENTER")
  titleText:SetText(title or "")
  self:TextColor(titleText, "accent")
  local close = self:CreateCloseButton(header, function() frame:Hide() end)
  close:SetPoint("RIGHT", -10, 0)
  frame.header = header
  frame.title = titleText
  frame.close = close
  self:MakeMovable(frame, header, layoutKey)
  if layoutKey and NS.Systems.Layout then NS.Systems.Layout:Restore(frame, layoutKey) end
  self:RegisterTransientPopup(frame)
  frame:Hide()
  return frame
end

function Controls:CreateReadOnlyEditBox(parent, value)
  local edit = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
  edit:SetHeight(27)
  edit:SetAutoFocus(false)
  edit:SetFontObject("GameFontHighlightSmall")
  edit:SetTextInsets(9, 9, 0, 0)
  self:Backdrop(edit, self.colors.panel, self.colors.border)
  self:TextColor(edit, "text")
  edit._hdReadOnlyValue = value or ""
  edit:SetText(edit._hdReadOnlyValue)
  local function Select(self)
    self:SetFocus()
    self:HighlightText()
  end
  edit:SetScript("OnMouseUp", Select)
  edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
  edit:SetScript("OnTextChanged", function(self, userInput)
    if userInput and self:GetText() ~= self._hdReadOnlyValue then
      self:SetText(self._hdReadOnlyValue)
      self:HighlightText()
    end
  end)
  edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  return edit
end

function Controls:CreateCheckButton(parent, label)
  local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  check:SetSize(22, 22)
  check.label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  check.label:SetPoint("LEFT", check, "RIGHT", 3, 0)
  check.label:SetText(label or "")
  self:TextColor(check.label, "muted")
  return check
end

function Controls:CreateSearchBox(parent, options)
  options = options or {}
  local edit = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
  edit:SetHeight(tonumber(options.height) or 22)
  edit:SetAutoFocus(false)
  if edit.SetPropagateKeyboardInput then edit:SetPropagateKeyboardInput(false) end
  edit:SetTextInsets(tonumber(options.leftInset) or 8, tonumber(options.rightInset) or 8, 0, 0)
  edit:SetFontObject(options.fontObject or GameFontHighlightSmall)
  self:Backdrop(edit, options.background or self.colors.panel, options.border or self.colors.border)
  local placeholder = edit:CreateFontString(nil, "OVERLAY", options.placeholderFont or "GameFontDisableSmall")
  placeholder:SetPoint("LEFT", tonumber(options.leftInset) or 8, 0)
  placeholder:SetText(options.placeholder or "Search")
  if options.placeholderColor then self:TextColor(placeholder, options.placeholderColor) end
  edit.placeholder = placeholder
  edit:SetScript("OnTextChanged", function(self, userInput)
    placeholder:SetShown(self:GetText() == "" and not self:HasFocus())
    if options.onChanged and (userInput or options.notifyProgrammatic) then options.onChanged(self, userInput == true) end
  end)
  edit:SetScript("OnEditFocusGained", function(self)
    placeholder:Hide()
    if NS.UI.QuickBar then NS.UI.QuickBar:DisableKeys() end
    if options.onFocusGained then options.onFocusGained(self) end
  end)
  edit:SetScript("OnEditFocusLost", function(self)
    placeholder:SetShown(self:GetText() == "")
    if NS.UI.QuickBar then NS.UI.QuickBar:EnableKeys() end
    if options.onFocusLost then options.onFocusLost(self) end
  end)
  edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  edit:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  if options.text then edit:SetText(options.text) end
  placeholder:SetShown(edit:GetText() == "")
  return edit
end

function Controls:CreateSlider(parent, options)
  options = options or {}
  local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
  slider:SetSize(tonumber(options.width) or 180, tonumber(options.height) or 12)
  slider:SetOrientation(options.orientation or "HORIZONTAL")
  slider:SetMinMaxValues(tonumber(options.minimum) or 0, tonumber(options.maximum) or 100)
  slider:SetValueStep(tonumber(options.step) or 1)
  slider:SetObeyStepOnDrag(options.obeyStep ~= false)
  self:Backdrop(slider, options.background or self.colors.panel, options.border or self.colors.border)
  local thumb = slider:CreateTexture(nil, "OVERLAY")
  thumb:SetSize(tonumber(options.thumbWidth) or 10, tonumber(options.thumbHeight) or 16)
  local accent = options.accent or self.colors.accent
  thumb:SetColorTexture(accent[1], accent[2], accent[3], accent[4] or 1)
  slider:SetThumbTexture(thumb)
  slider.thumb = thumb
  local fill = slider:CreateTexture(nil, "ARTWORK")
  fill:SetPoint("LEFT", 3, 0)
  fill:SetHeight(tonumber(options.fillHeight) or 6)
  fill:SetColorTexture(accent[1], accent[2], accent[3], options.fillAlpha or 0.75)
  slider.fill = fill
  local function sync(self, value)
    local minimum, maximum = self:GetMinMaxValues()
    local range = maximum - minimum
    local ratio = range > 0 and ((value - minimum) / range) or 0
    fill:SetWidth(math.max(1, (self:GetWidth() - 6) * math.max(0, math.min(1, ratio))))
    if options.onDisplay then options.onDisplay(self, value) end
  end
  slider:SetScript("OnValueChanged", function(self, value)
    sync(self, value)
    if not self._hdSyncing and options.onChanged then options.onChanged(self, value) end
  end)
  function slider:SetValueSilently(value)
    self._hdSyncing = true
    self:SetValue(value)
    sync(self, self:GetValue())
    self._hdSyncing = nil
  end
  slider:SetValueSilently(tonumber(options.value) or tonumber(options.minimum) or 0)
  return slider
end

function Controls:CreateResizeGrip(parent, size)
  local grip = CreateFrame("Button", nil, parent)
  grip:SetSize(tonumber(size) or 18, tonumber(size) or 18)
  grip.texture = grip:CreateTexture(nil, "ARTWORK")
  grip.texture:SetAllPoints()
  grip.texture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  return grip
end

function Controls:MakeMovable(frame, handle, layoutKey, onStopped)
  if not frame then return end
  handle = handle or frame
  frame:SetMovable(true)
  frame:EnableMouse(true)
  handle:EnableMouse(true)
  handle:RegisterForDrag("LeftButton")
  handle:SetScript("OnDragStart", function() frame:StartMoving() end)
  handle:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    if layoutKey and NS.Systems.Layout then NS.Systems.Layout:Save(frame, layoutKey) end
    if onStopped then onStopped(frame) end
  end)
end

function Controls:CreateScrollFrame(parent, template)
  local scroll = CreateFrame("ScrollFrame", nil, parent, template or "ScrollFrameTemplate")
  self:SkinScrollFrame(scroll)
  return scroll
end

function Controls:GetScrollMaximum(scroll)
  if not scroll then return 0 end
  local content = scroll._hdScrollContent or (scroll.GetScrollChild and scroll:GetScrollChild())
  local contentHeight = content and content.GetHeight and content:GetHeight() or 0
  local viewportHeight = scroll.GetHeight and scroll:GetHeight() or 0
  local measured = contentHeight > 0 and viewportHeight > 0 and math.max(0, contentHeight - viewportHeight) or 0
  local reported = math.max(0, scroll.GetVerticalScrollRange and scroll:GetVerticalScrollRange() or 0)
  return math.max(measured, reported)
end

function Controls:SyncScrollFrame(scroll)
  if not scroll then return end
  local maximum = self:GetScrollMaximum(scroll)
  local offset = math.max(0, math.min(maximum, scroll:GetVerticalScroll() or 0))
  local bar = scroll.ScrollBar or scroll.scrollBar
  if bar and bar.SetMinMaxValues then bar:SetMinMaxValues(0, maximum) end
  if bar and bar.SetVisibleExtentPercentage then
    local viewport = math.max(0, scroll:GetHeight() or 0)
    local total = viewport + maximum
    bar:SetVisibleExtentPercentage(total > 0 and viewport / total or 1)
  end
  if bar and bar.SetScrollPercentage and not bar._hdSyncing then
    bar._hdSyncing = true
    bar:SetScrollPercentage(maximum > 0 and offset / maximum or 0, _G.ScrollBoxConstants and _G.ScrollBoxConstants.NoScrollInterpolation)
    bar._hdSyncing = nil
  elseif bar and bar.SetValue and not bar._hdSyncing then
    bar._hdSyncing = true
    bar:SetValue(offset)
    bar._hdSyncing = nil
  end
  local up = bar and (bar.ScrollUpButton or bar.Back)
  local down = bar and (bar.ScrollDownButton or bar.Forward)
  if up and up.SetEnabled then up:SetEnabled(offset > 0) end
  if down and down.SetEnabled then down:SetEnabled(offset < maximum) end
end

function Controls:NotifyScrollFrame(scroll)
  if not scroll or scroll._hdScrollNotifying then return end
  local callback = scroll._hdScrollCallback
  if not callback then return end
  scroll._hdScrollNotifying = true
  callback(scroll, scroll:GetVerticalScroll() or 0)
  scroll._hdScrollNotifying = nil
end

function Controls:SetScrollOffset(scroll, value, notify)
  if not scroll then return 0 end
  local maximum = self:GetScrollMaximum(scroll)
  local offset = math.max(0, math.min(maximum, tonumber(value) or 0))
  scroll._hdSettingOffset = true
  scroll:SetVerticalScroll(offset)
  self:SyncScrollFrame(scroll)
  scroll._hdSettingOffset = nil
  if notify ~= false then self:NotifyScrollFrame(scroll) end
  return offset
end

function Controls:ResetScrollFrame(scroll, notify)
  return self:SetScrollOffset(scroll, 0, notify)
end

function Controls:ScrollFrameByWheel(scroll, delta)
  if not scroll then return end
  local step = scroll._hdScrollStep
  if type(step) == "function" then step = step(scroll) end
  step = tonumber(step) or 48
  local multiplier = tonumber(scroll._hdScrollMultiplier) or 1
  self:SetScrollOffset(scroll, (scroll:GetVerticalScroll() or 0) - (tonumber(delta) or 0) * step * multiplier, true)
end

function Controls:ForwardScrollWheel(target, scroll)
  if not target or not scroll or not target.EnableMouseWheel or not target.SetScript then return end
  if target.EnableMouse then target:EnableMouse(true) end
  target:EnableMouseWheel(true)
  target._hdForwardScroll = scroll
  if target._hdForwardScrollBound then return end
  target._hdForwardScrollBound = true
  target:HookScript("OnMouseWheel", function(self, delta)
    local destination = self._hdForwardScroll
    if destination then Controls:ScrollFrameByWheel(destination, delta) end
  end)
end

function Controls:ForwardScrollWheelTree(target, scroll)
  if not target or not scroll then return end
  self:ForwardScrollWheel(target, scroll)
  if not target.GetChildren then return end
  local children = { target:GetChildren() }
  for index = 1, #children do self:ForwardScrollWheelTree(children[index], scroll) end
end

function Controls:ConfigureScrollFrame(scroll, content, options)
  if not scroll then return scroll end
  options = options or {}
  scroll._hdScrollContent = content or scroll._hdScrollContent
  scroll._hdScrollStep = options.step or scroll._hdScrollStep or 48
  scroll._hdScrollMultiplier = options.multiplier or scroll._hdScrollMultiplier or 1
  scroll._hdScrollCallback = options.onScroll or scroll._hdScrollCallback
  scroll._hdScrollWheel = options.onMouseWheel
  scroll._hdForwardContent = options.forwardContent ~= false
  if content and scroll:GetScrollChild() ~= content then scroll:SetScrollChild(content) end
  scroll:EnableMouse(true)
  scroll:EnableMouseWheel(true)
  scroll:SetScript("OnVerticalScroll", function(self, value)
    if self._hdSettingOffset then return end
    local maximum = Controls:GetScrollMaximum(self)
    local offset = math.max(0, math.min(maximum, tonumber(value) or 0))
    if offset ~= value then
      self._hdSettingOffset = true
      self:SetVerticalScroll(offset)
      self._hdSettingOffset = nil
    end
    Controls:SyncScrollFrame(self)
    Controls:NotifyScrollFrame(self)
  end)
  scroll:SetScript("OnMouseWheel", function(self, delta)
    if self._hdScrollWheel then self._hdScrollWheel(self, delta) else Controls:ScrollFrameByWheel(self, delta) end
  end)
  scroll:HookScript("OnSizeChanged", function(self)
    Controls:SetScrollOffset(self, self:GetVerticalScroll() or 0, false)
    Controls:SyncScrollFrame(self)
  end)
  if content then
    if content.EnableMouse then content:EnableMouse(true) end
    content:EnableMouseWheel(true)
    content:HookScript("OnSizeChanged", function()
      Controls:SetScrollOffset(scroll, scroll:GetVerticalScroll() or 0, false)
      Controls:SyncScrollFrame(scroll)
    end)
  end
  scroll:HookScript("OnScrollRangeChanged", function(self)
    Controls:SetScrollOffset(self, self:GetVerticalScroll() or 0, false)
  end)
  if content and scroll._hdForwardContent then self:ForwardScrollWheelTree(content, scroll) end
  local bar = scroll.ScrollBar or scroll.scrollBar
  local barInset = tonumber(options.barInset) or -8
  if bar then
    bar:ClearAllPoints()
    bar:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", -barInset, -(tonumber(options.barTop) or 12))
    bar:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", -barInset, tonumber(options.barBottom) or 12)
  end
  if bar then
    self:ForwardScrollWheel(bar, scroll)
    self:ForwardScrollWheel(bar.ScrollUpButton or bar.Back, scroll)
    self:ForwardScrollWheel(bar.ScrollDownButton or bar.Forward, scroll)
    self:ForwardScrollWheel(bar.Thumb or bar.ThumbTexture, scroll)
  end
  scroll:HookScript("OnShow", function()
    local root = scroll._hdScrollContent
    if root and scroll._hdForwardContent then Controls:ForwardScrollWheelTree(root, scroll) end
    Controls:SyncScrollFrame(scroll)
  end)
  if content and _G.C_Timer and _G.C_Timer.After then
    _G.C_Timer.After(0, function()
      if scroll and content and scroll._hdForwardContent then Controls:ForwardScrollWheelTree(content, scroll) end
    end)
  end
  self:SyncScrollFrame(scroll)
  return scroll
end

function Controls:IsPointerOver(frame)
  if not frame or not frame.IsVisible or not frame:IsVisible() then return false end
  if frame.IsMouseOver then
    local ok, result = pcall(frame.IsMouseOver, frame)
    if ok then return result == true end
  end
  if _G.MouseIsOver then
    local ok, result = pcall(_G.MouseIsOver, frame)
    if ok then return result == true end
  end
  return false
end

function Controls:IsMousePressed()
  if not _G.IsMouseButtonDown then return false end
  local leftOK, left = pcall(_G.IsMouseButtonDown, "LeftButton")
  local rightOK, right = pcall(_G.IsMouseButtonDown, "RightButton")
  return (leftOK and left == true) or (rightOK and right == true)
end

function Controls:CloseTransientPopups(except)
  self.transientPopups = self.transientPopups or {}
  for popup in pairs(self.transientPopups) do
    if popup ~= except and popup.IsShown and popup:IsShown() then popup:Hide() end
  end
end

function Controls:CollectGarbageIncrementally()
  self._hdGarbageToken = (self._hdGarbageToken or 0) + 1
  local token = self._hdGarbageToken
  local remaining = 80
  local function step()
    if token ~= Controls._hdGarbageToken then return end
    remaining = remaining - 1
    local complete = collectgarbage("step", 128)
    if not complete and remaining > 0 then C_Timer.After(0, step) end
  end
  C_Timer.After(0, step)
end

function Controls:SetTransientAnchor(frame, anchor)
  if not frame then return end
  frame._hdTransientAnchor = anchor
end

function Controls:RegisterTransientPopup(frame)
  if not frame or frame._hdTransientPopup then return frame end
  frame._hdTransientPopup = true
  self.transientPopups = self.transientPopups or {}
  self.transientPopups[frame] = true
  frame:HookScript("OnShow", function(self)
    Controls:CloseTransientPopups(self)
    self._hdTransientMouseDown = Controls:IsMousePressed()
  end)
  frame:HookScript("OnUpdate", function(self)
    local anchor = self._hdTransientAnchor
    if anchor and anchor.IsVisible and not anchor:IsVisible() then self:Hide() return end
    local pressed = Controls:IsMousePressed()
    if pressed and not self._hdTransientMouseDown and not Controls:IsPointerOver(self) and not Controls:IsPointerOver(anchor) then
      self:Hide()
      return
    end
    self._hdTransientMouseDown = pressed
  end)
  local name = frame.GetName and frame:GetName()
  if name and _G.UISpecialFrames then
    local found = false
    for _, value in ipairs(_G.UISpecialFrames) do if value == name then found = true break end end
    if not found then _G.UISpecialFrames[#_G.UISpecialFrames + 1] = name end
  end
  return frame
end

function Controls:SkinScrollFrame(scroll)
  if not scroll or scroll._hdSharedScrollSkin then return scroll end
  scroll._hdSharedScrollSkin = true
  self.scrollFrames[scroll] = true
  local bar = scroll.ScrollBar or scroll.scrollBar
  if not bar and scroll.GetName then
    local name = scroll:GetName()
    if name then bar = _G[name .. "ScrollBar"] end
  end
  local thumb = bar and (bar.Thumb or bar.ThumbTexture or (bar.GetThumbTexture and bar:GetThumbTexture()))
  if bar and bar.SetWidth then bar:SetWidth(8) end
  if thumb and thumb.SetWidth then thumb:SetWidth(8) end
  if thumb and thumb.SetVertexColor then thumb:SetVertexColor(1, 1, 1, 1) end
  local up = bar and (bar.ScrollUpButton or bar.Back)
  local down = bar and (bar.ScrollDownButton or bar.Forward)
  if up then
    if up.SetText then up:SetText("") end
    if up.SetSize then up:SetSize(17, 11) end
    if bar.ScrollUpButton and up.SetNormalAtlas then
      up:SetNormalAtlas("minimal-scrollbar-arrow-top")
      up:SetHighlightAtlas("minimal-scrollbar-arrow-top-over")
      up:SetPushedAtlas("minimal-scrollbar-arrow-top-down")
      up:SetDisabledAtlas("minimal-scrollbar-arrow-top")
    end
  end
  if down then
    if down.SetText then down:SetText("") end
    if down.SetSize then down:SetSize(17, 11) end
    if bar.ScrollDownButton and down.SetNormalAtlas then
      down:SetNormalAtlas("minimal-scrollbar-arrow-bottom")
      down:SetHighlightAtlas("minimal-scrollbar-arrow-bottom-over")
      down:SetPushedAtlas("minimal-scrollbar-arrow-bottom-down")
      down:SetDisabledAtlas("minimal-scrollbar-arrow-bottom")
    end
  end
  self:ApplyScrollFrameColors(scroll)
  scroll:HookScript("OnShow", function(self) Controls:ApplyScrollFrameColors(self) end)
  return scroll
end

function Controls:SetButtonSelected(button, selected)
  if not button then return end
  button._hdSelected = selected == true
  local background = button._hdSelected and self.colors.hover or self.colors.panel
  local border = button._hdSelected and self.colors.accent or self.colors.border
  button:SetBackdropColor(background[1], background[2], background[3], background[4])
  button:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

function Controls:SkinTree(frame)
  if not frame or not frame.GetChildren then return end
  local children = { frame:GetChildren() }
  for index = 1, #children do
    local child = children[index]
    if child.GetObjectType and child:GetObjectType() == "Button" and not child._hdKeepNative then self:SkinButton(child) end
    self:SkinTree(child)
  end
end

function Controls:MakeMinimizable(frame, button, options)
  if not frame or not button then return end
  options = options or {}
  local regions = options.regions or {}
  local key = options.key
  local minimizedHeight = tonumber(options.height) or 28
  frame._hdExpandedHeight = frame:GetHeight()
  local function apply(minimized)
    minimized = minimized == true
    frame._hdMinimized = minimized
    frame._hdApplyingMinimize = true
    if minimized then
      frame._hdExpandedHeight = math.max(frame:GetHeight() or minimizedHeight, minimizedHeight)
      frame:SetHeight(minimizedHeight)
    else
      frame:SetHeight(frame._hdExpandedHeight or tonumber(options.expandedHeight) or 400)
    end
    frame._hdApplyingMinimize = nil
    for index = 1, #regions do regions[index]:SetShown(not minimized) end
    button:SetText(minimized and "+" or "-")
    if key and NS.Systems.Settings then NS.Systems.Settings:SetValue(key, minimized) end
    if options.onChanged then options.onChanged(minimized) end
  end
  button:SetScript("OnClick", function() apply(not frame._hdMinimized) end)
  frame.ApplyMinimized = apply
  apply(key and NS.Systems.Settings:GetValue(key, false) or false)
end

function Controls:MakeResizable(frame, grip, options)
  if not frame or not grip then return end
  options = options or {}
  local minWidth = tonumber(options.minWidth) or 280
  local minHeight = tonumber(options.minHeight) or 240
  local maxWidth = tonumber(options.maxWidth) or 900
  local maxHeight = tonumber(options.maxHeight) or 900
  frame:SetResizable(true)
  if frame.SetResizeBounds then frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight) end
  local size = options.key and NS.Systems.Settings:GetValue(options.key)
  if type(size) == "table" and tonumber(size.width) and tonumber(size.height) then frame:SetSize(size.width, size.height) end
  grip:RegisterForDrag("LeftButton")
  grip:SetScript("OnDragStart", function()
    if not frame._hdMinimized then frame:StartSizing("BOTTOMRIGHT") end
  end)
  grip:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    if not frame._hdMinimized then
      frame._hdExpandedHeight = frame:GetHeight()
      if options.key and NS.Systems.Settings then NS.Systems.Settings:SetValue(options.key, { width = frame:GetWidth(), height = frame:GetHeight() }) end
      if options.onChanged then options.onChanged(frame:GetWidth(), frame:GetHeight()) end
    end
  end)
end
